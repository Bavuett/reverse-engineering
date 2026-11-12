---
tags: [snippet]
level: 3
project: "PressReader"
source: "com.newspaperdirect.pressreader.android — bundled AndroidX DataStore native library"
version: "unknown"
source_path: "lib/arm64-v8a/libdatastore_shared_counter.so, functions Java_androidx_datastore_core_NativeSharedCounter_nativeCreateSharedCounter (0xe54) and ThrowIoException (0xd80)"
date_added: 2026-11-12
license_note: "Disassembly of an AndroidX (Apache-2.0) component shipped inside the app; personal study/research purposes only."
---

# Stack-Protector-And-Tail-Call-In-Datastore-JNI

> [!info] Level 3 — real code
> Two real frames side by side: a JNI function with a local whose address escapes (so it gets a stack canary from `tpidr_el0`), and a helper that restores its frame *before* jumping into a JNI function pointer — a tail call through a register.

## Context

Both functions come from AndroidX DataStore's `libdatastore_shared_counter.so` inside PressReader (background in [[Mmap-Call-Arguments-In-Datastore]]). `nativeCreateSharedCounter` maps the shared counter and returns its address to Kotlin as a `long`; `ThrowIoException` raises a Java `IOException` from native code. Between them they show the frame features that [[Functions-And-Calling-Convention]] describes separately.

## Original path

`lib/arm64-v8a/libdatastore_shared_counter.so` → `Java_androidx_datastore_core_NativeSharedCounter_nativeCreateSharedCounter` (`0xe54`, 192 bytes) and `_Z16ThrowIoExceptionP7_JNIEnvPKc` (`0xd80`, 92 bytes).

## Snippet 1 — frame with a canary

```asm
e54:  sub     sp, sp, #0x40             ; 64-byte frame
e58:  stp     x29, x30, [sp, #0x10]     ; frame record ABOVE the locals
e5c:  add     x29, sp, #0x10
e60:  stp     x22, x21, [sp, #0x20]
e64:  stp     x20, x19, [sp, #0x30]
e68:  mrs     x22, tpidr_el0            ; thread pointer
e6c:  mov     x20, x0                   ; env
e70:  ldr     x8, [x22, #0x28]          ; canary = TLS[5]
e74:  mov     x1, sp                    ; &address  (local at [sp])
e78:  mov     w0, w2                    ; fd
e7c:  str     x8, [sp, #8]              ; save canary next to the local
e80:  str     xzr, [sp]                 ; void* address = nullptr
e84:  bl      datastore::CreateSharedCounter
e88:  mov     w19, w0                   ; err
e8c:  cbz     w0, 0xed8
      ...                               ; err != 0: strerror + FindClass + ThrowNew -> x8
ed8:  b       0xee0
edc:  mov     x8, #-1
ee0:  ldr     x9, [sp]                  ; address
ee4:  cmp     w19, #0
ee8:  ldr     x10, [x22, #0x28]         ; canary now
eec:  ldr     x11, [sp, #8]             ; canary saved
ef0:  csel    x0, x9, x8, eq            ; err == 0 ? address : error result
ef4:  cmp     x10, x11
ef8:  b.ne    0xf10                     ; smashed -> abort
efc:  ldp     x20, x19, [sp, #0x30]
f00:  ldp     x22, x21, [sp, #0x20]
f04:  ldp     x29, x30, [sp, #0x10]
f08:  add     sp, sp, #0x40
f0c:  ret
f10:  bl      __stack_chk_fail          ; never returns
```

## Snippet 2 — tail call through a function pointer

```asm
d80:  stp     x29, x30, [sp, #-0x20]!
d84:  stp     x20, x19, [sp, #0x10]
d88:  mov     x29, sp
d8c:  ldr     x8, [x0]                  ; env->functions
d90:  mov     x19, x1                   ; message
d94:  adrp    x1, #0
d98:  mov     x20, x0                   ; env
d9c:  add     x1, x1, #0xa8b            ; "java/io/IOException"
da0:  ldr     x8, [x8, #0x30]           ; FindClass
da4:  blr     x8
da8:  cbz     x0, 0xdcc
dac:  ldr     x8, [x20]
db0:  mov     x1, x0                    ; jclass
db4:  mov     x0, x20                   ; env
db8:  mov     x2, x19                   ; message
dbc:  ldp     x20, x19, [sp, #0x10]     ; restore callee-saved ...
dc0:  ldr     x3, [x8, #0x70]           ; ThrowNew
dc4:  ldp     x29, x30, [sp], #0x20     ; ... and the frame
dc8:  br      x3                        ; tail call: ThrowNew returns to OUR caller
dcc:  ldp     x20, x19, [sp, #0x10]
dd0:  mov     w0, #-1
dd4:  ldp     x29, x30, [sp], #0x20
dd8:  ret
```

## Reconstructed source

```cpp
static int ThrowIoException(JNIEnv* env, const char* message) {
    jclass cls = env->FindClass("java/io/IOException");
    if (cls == nullptr) return -1;
    return env->ThrowNew(cls, message);                // tail call
}

extern "C" JNIEXPORT jlong JNICALL
Java_androidx_datastore_core_NativeSharedCounter_nativeCreateSharedCounter(JNIEnv* env, jobject, jint fd) {
    void* address = nullptr;
    if (int err = datastore::CreateSharedCounter(fd, &address)) {
        return ThrowIoException(env, strerror(err));    // inlined here
    }
    return reinterpret_cast<jlong>(address);
}
```

## Notes

- **Compared with the textbook frames.** [[Leaf-Function-Prologue-Epilogue]] has no frame, [[Stack-Frame-With-Locals]] has the frame record at the bottom (`stp x29, x30, [sp, #-N]!`). Snippet 1 is the third common layout: `sub sp` first, frame record stored *above* the locals (`[sp, #0x10]`), `x29` pointing at it. Locals live between `sp` and `x29`.
- **Why a canary here and not in snippet 2?** Taking the address of a local (`mov x1, sp` → `&address`) passes a pointer into this frame to another function, so `-fstack-protector-strong` inserts a canary. Snippet 2 has no addressable locals, so no canary.
- **Recognizing the canary.** `mrs xN, tpidr_el0` + `ldr [xN, #0x28]` (bionic's TLS slot for the stack guard), stored next to the locals in the prologue, reloaded and compared in the epilogue, with `bl __stack_chk_fail` on mismatch. It's compiler boilerplate: skip it when reading logic, but note which locals it protects (the ones whose addresses escape — here, the out-parameter).
- **`csel` instead of two returns.** Success and failure paths merge before the epilogue and pick the result with `csel x0, x9, x8, eq` — one epilogue, one canary check. Compare [[Compare-And-Conditional-Select]].
- **Tail call through a register.** In snippet 2, the epilogue (`ldp … ldp`) runs *before* the call, then `br x3` jumps into `ThrowNew` with the original `x30` restored, so `ThrowNew`'s `ret` goes straight back to `ThrowIoException`'s caller. The tell: `br` (not `blr`) to a register right after the frame has been torn down. Disassemblers often show the `br` as the end of the function with no visible call — read it as `return env->ThrowNew(...)`.
- **Interleaved epilogue.** The compiler mixed the restore of `x19`/`x20` with the load of `x3` and the argument setup — the epilogue isn't a contiguous block. Register *roles* matter more than instruction order.

## See also

- [[Functions-And-Calling-Convention]]
- [[Passing-Arguments-And-Return-Values]] — the `b` tail call in its simplest form
- [[STP-And-LDP]]
- [[B-BL-BLR-And-RET]] — `br` vs `blr`
- [[Return-Value-Widening-In-Datastore-JNI]] — the sibling JNI function, return paths in detail
- [[PressReader]]
- [[ARM64-Android-Reference|Reference]]
