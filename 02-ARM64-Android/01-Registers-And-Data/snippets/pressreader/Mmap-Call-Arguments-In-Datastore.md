---
tags: [snippet]
level: 3
project: "PressReader"
source: "com.newspaperdirect.pressreader.android — bundled AndroidX DataStore native library"
version: "unknown"
source_path: "lib/arm64-v8a/libdatastore_shared_counter.so, function datastore::CreateSharedCounter(int, void**) at 0xf68"
date_added: 2026-11-12
license_note: "Disassembly of an AndroidX (Apache-2.0) component shipped inside the app; personal study/research purposes only."
---

# Mmap-Call-Arguments-In-Datastore

> [!info] Level 3 — real code
> A real function that sets up six arguments for `mmap` from constants, a saved parameter, and the zero register — every argument register explained, then turned back into C++.

## Context

PressReader's APK ships `libdatastore_shared_counter.so`, the native half of AndroidX DataStore's multi-process mode: a 4-byte counter in a memory-mapped file, shared between processes. The library is tiny (9 functions), unstripped of its dynamic symbols, and open source upstream — an ideal place to compare real compiler output with known intent. Interestingly, the Kotlin class that calls it isn't in the APK's DEX at all (R8 removed it as unused), so the library is dead weight in this build; the code is still a faithful sample of NDK clang output.

## Original path

`lib/arm64-v8a/libdatastore_shared_counter.so` → `_ZN9datastore19CreateSharedCounterEiPPv` (`datastore::CreateSharedCounter(int, void**)`), address `0xf68`, 88 bytes.

## Snippet

```asm
f68:  stp     x29, x30, [sp, #-0x20]!
f6c:  str     x19, [sp, #0x10]
f70:  mov     x29, sp
f74:  mov     x19, x1               ; keep counter_address (void**) across the call
f78:  mov     w4, w0                ; arg5: fd
f7c:  mov     x0, xzr               ; arg1: addr   = NULL
f80:  mov     w1, #4                ; arg2: length = 4
f84:  mov     w2, #3                ; arg3: prot   = PROT_READ | PROT_WRITE
f88:  mov     w3, #0x8001           ; arg4: flags  = MAP_SHARED | MAP_POPULATE
f8c:  mov     x5, xzr               ; arg6: offset = 0
f90:  bl      mmap                  ; (via PLT 0x1180)
f94:  cmn     x0, #1                ; result == (void*)-1 ?  (MAP_FAILED)
f98:  b.eq    0xfa8
f9c:  mov     w8, wzr               ; ret = 0
fa0:  str     x0, [x19]             ; *counter_address = mapping
fa4:  b       0xfb0
fa8:  bl      __errno               ; (via PLT 0x1170)
fac:  ldr     w8, [x0]              ; ret = errno
fb0:  ldr     x19, [sp, #0x10]
fb4:  mov     w0, w8
fb8:  ldp     x29, x30, [sp], #0x20
fbc:  ret
```

(Disassembled with Capstone; PLT targets resolved from `.rela.plt`.)

## Reconstructed source

```cpp
namespace datastore {
int CreateSharedCounter(int fd, void** counter_address) {
    void* mapping = mmap(nullptr, sizeof(uint32_t), PROT_READ | PROT_WRITE,
                         MAP_SHARED | MAP_POPULATE, fd, 0);
    if (mapping == MAP_FAILED) {
        return errno;
    }
    *counter_address = mapping;
    return 0;
}
}
```

## Notes

- **Argument registers in order.** `mmap(void* addr, size_t len, int prot, int flags, int fd, off_t off)` takes six arguments → `x0`–`x5`. Reading the `mov`s into `x0`…`x5` immediately before a `bl` *is* reading the call's argument list. They needn't be in order: here `w4` is set first because `w0` (the incoming `fd`) must be copied out before `x0` is overwritten with `NULL`.
- **Width follows the C type.** `int` arguments (`prot`, `flags`, `fd`) use `w` registers; pointer and `size_t`/`off_t` arguments use `x`. `mov w1, #4` for a `size_t` is fine because writing a `w` register zeroes the upper 32 bits ([[Register-Width-And-Sign-Extension]]).
- **Decoding the constants.** `3` = `PROT_READ (1) | PROT_WRITE (2)`. `0x8001` = `MAP_SHARED (0x1) | MAP_POPULATE (0x8000)`. Length `4` = one `uint32_t`. Constants passed to well-known libc calls are always worth decoding against the headers — they spell out intent.
- **`xzr` as `NULL` and `0`.** `mov x0, xzr` and `mov x5, xzr` (see [[Zero-Register-And-Special-Registers]]).
- **`cmn x0, #1`** is `adds xzr, x0, #1`: it sets Z when `x0 == -1`, i.e. compares against `MAP_FAILED` without loading `-1` into a register.
- **Callee-saved parking.** The out-pointer `x1` must survive the `mmap` call, so it's moved to `x19`, which the prologue saved and the epilogue restores. A parameter copied into `x19`–`x28` right at the start is a parameter used *after* a call.
- **`errno` is a function call.** On Android, `errno` is `*__errno()` (thread-local), so `bl __errno; ldr w8, [x0]` is just reading `errno`.
- **Compared with the basic examples.** Every element here was covered in isolation in [[Basic-Arithmetic-And-Moves]] (small immediates) and [[Zero-Register-And-Special-Registers]]; real code mixes them in one dense run, and the skill is mapping each register to a parameter slot.

## See also

- [[Registers-And-Data]]
- [[Functions-And-Calling-Convention]]
- [[Return-Value-Widening-In-Datastore-JNI]] — the JNI wrapper around this function's sibling
- [[Reading-Datastore-Shared-Counter-Cold]] — the whole library read cold
- [[PressReader]]
- [[ARM64-Android-Reference|Reference]]
