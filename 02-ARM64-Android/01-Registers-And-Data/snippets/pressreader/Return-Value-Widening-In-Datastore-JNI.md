---
tags: [snippet]
level: 3
project: "PressReader"
source: "com.newspaperdirect.pressreader.android — bundled AndroidX DataStore native library"
version: "unknown"
source_path: "lib/arm64-v8a/libdatastore_shared_counter.so, function Java_androidx_datastore_core_NativeSharedCounter_nativeTruncateFile at 0xddc"
date_added: 2026-11-12
license_note: "Disassembly of an AndroidX (Apache-2.0) component shipped inside the app; personal study/research purposes only."
---

# Return-Value-Widening-In-Datastore-JNI

> [!info] Level 3 — real code
> A real JNI function returning a 64-bit value from three paths: `xzr` for success, `sxtw` widening an `int` error, and `mov x0, #-1` for "couldn't even find the exception class".

## Context

`nativeTruncateFile` is the JNI entry point that resizes DataStore's shared-counter file. Its interesting part for this chapter is the *return value*: three different instructions produce it, each showing a different way a 32-bit or constant value ends up in a 64-bit `x0`. (See [[Mmap-Call-Arguments-In-Datastore]] for the library's background.)

## Original path

`lib/arm64-v8a/libdatastore_shared_counter.so` → `Java_androidx_datastore_core_NativeSharedCounter_nativeTruncateFile`, address `0xddc`, 120 bytes.

## Snippet

```asm
ddc:  stp     x29, x30, [sp, #-0x20]!
de0:  stp     x20, x19, [sp, #0x10]
de4:  mov     x29, sp
de8:  mov     x19, x0               ; x19 = JNIEnv*
dec:  mov     w0, w2                ; fd (x0=env, x1=jobject/jclass, w2=fd)
df0:  bl      datastore::TruncateFile   ; (via PLT 0x1100)
df4:  cbz     w0, 0xe3c             ; 0 -> success
df8:  bl      strerror              ; w0 = errno value -> x0 = char*
dfc:  ldr     x8, [x19]             ; env->functions
e00:  adrp    x1, #0
e04:  mov     x20, x0               ; x20 = message
e08:  add     x1, x1, #0xa8b        ; "java/io/IOException"
e0c:  mov     x0, x19
e10:  ldr     x8, [x8, #0x30]       ; functions[6] = FindClass
e14:  blr     x8
e18:  cbz     x0, 0xe44             ; class not found
e1c:  ldr     x8, [x19]
e20:  mov     x1, x0                ; jclass
e24:  mov     x0, x19               ; env
e28:  mov     x2, x20               ; message
e2c:  ldr     x8, [x8, #0x70]       ; functions[14] = ThrowNew
e30:  blr     x8
e34:  sxtw    x0, w0                ; (jint) ThrowNew result -> 64-bit return
e38:  b       0xe48
e3c:  mov     x0, xzr               ; return 0
e40:  b       0xe48
e44:  mov     x0, #-1               ; return -1
e48:  ldp     x20, x19, [sp, #0x10]
e4c:  ldp     x29, x30, [sp], #0x20
e50:  ret
```

## Reconstructed source

```cpp
static int ThrowIoException(JNIEnv* env, const char* message) {
    jclass cls = env->FindClass("java/io/IOException");
    if (cls == nullptr) return -1;
    return env->ThrowNew(cls, message);
}

extern "C" JNIEXPORT jlong JNICALL
Java_androidx_datastore_core_NativeSharedCounter_nativeTruncateFile(JNIEnv* env, jobject, jint fd) {
    if (int err = datastore::TruncateFile(fd)) {
        return ThrowIoException(env, strerror(err));   // int -> jlong
    }
    return 0;
}
```

## Notes

- **Three ways to fill `x0`.**
  - `mov x0, xzr` — the constant `0`, full width.
  - `mov x0, #-1` — assembled as `movn x0, #0` (all bits set); a negative constant needs no sign extension because it's built at full width.
  - `sxtw x0, w0` — `ThrowNew` returns a `jint` (32 bits, in `w0`), but this function returns 64 bits, so the compiler sign-extends. Had the function returned `jint`, there'd be no `sxtw` at all.
- **The `sxtw` tells you the return type.** The Kotlin declaration of this method isn't present in this APK (R8 removed the unused class), so the binary is the only evidence of the signature — and the `sxtw` before `ret`, plus `mov x0` (not `mov w0`) on the other paths, says the return type is 64-bit (`jlong`). Width instructions at a function's exit are type information. See [[Register-Width-And-Sign-Extension]].
- **Parameters of a JNI function.** `x0` = `JNIEnv*`, `x1` = `jobject`/`jclass`, then the Java parameters: `w2` = `fd` (a Java `int`, so a `w` register).
- **Inlining.** The library also exports `ThrowIoException` as a standalone function (at `0xd80`), but here its body was inlined. The standalone copy ends in `br x3` — a tail call into `ThrowNew` — which is analysed in [[Stack-Protector-And-Tail-Call-In-Datastore-JNI]].
- **Data flow through `strerror`.** `TruncateFile` returns `errno` in `w0`; with `cbz` not taken, `w0` is passed unchanged as `strerror`'s argument. No `mov` is needed because the return register and first argument register are the same.
- **JNI table offsets.** `[x8, #0x30]` and `[x8, #0x70]` are entries 6 and 14 of `JNINativeInterface` (offset ÷ 8): `FindClass` and `ThrowNew`. See [[JNIEnv-Function-Table-Offsets]].

## See also

- [[Registers-And-Data]]
- [[Zero-Register-And-Special-Registers]]
- [[Loading-Addresses-With-ADRP-And-ADD]] — the `adrp`/`add` pair at `0xe00`/`0xe08`
- [[Android-Native-Internals]]
- [[PressReader]]
- [[ARM64-Android-Reference|Reference]]
