---
tags: [snippet]
level: 3
project: "PressReader"
source: "com.newspaperdirect.pressreader.android — bundled AndroidX DataStore native library"
version: "unknown"
source_path: "lib/arm64-v8a/libdatastore_shared_counter.so, functions at 0xfc0, 0xfc8, 0xff0 and the .init_array constructor at 0x1020"
date_added: 2026-11-12
license_note: "Disassembly of an AndroidX (Apache-2.0) component shipped inside the app; personal study/research purposes only."
---

# Outline-Atomics-LSE-Vs-LLSC-In-Datastore

> [!info] Level 3 — real code
> One line of C++ (`counter->fetch_add(1)`) compiled into a call to a compiler-generated helper that picks, at runtime, between a single ARMv8.1 atomic instruction and an ARMv8.0 load-exclusive/store-exclusive retry loop — plus the startup code that makes the choice.

## Context

DataStore's shared counter is a `std::atomic<uint32_t>` in memory shared between processes, so incrementing it must be atomic. Modern NDK clang compiles atomics as **outline atomics**: instead of inlining one fixed instruction sequence, it calls a tiny helper that uses LSE instructions (`ldadd…`) if the CPU has them and falls back to exclusive-monitor loops otherwise. This library contains the whole mechanism in ~150 bytes, symbols stripped from the helpers.

## Original path

`lib/arm64-v8a/libdatastore_shared_counter.so`: `datastore::GetCounterValue` (`0xfc0`), `datastore::IncrementAndGetCounterValue` (`0xfc8`), unnamed helper (`0xff0`), unnamed initializer listed in `.init_array` (`0x1020`).

## Snippet

```asm
; uint32_t GetCounterValue(std::atomic<uint32_t>* a)
fc0:  ldar    w0, [x0]              ; load-acquire
fc4:  ret

; uint32_t IncrementAndGetCounterValue(std::atomic<uint32_t>* a)
fc8:  stp     x29, x30, [sp, #-0x10]!
fcc:  mov     x29, sp
fd0:  mov     x1, x0                ; helper(value, ptr)
fd4:  mov     w0, #1
fd8:  bl      0xff0                 ; old = fetch_add(1)
fdc:  add     w0, w0, #1            ; return old + 1
fe0:  ldp     x29, x30, [sp], #0x10
fe4:  ret

; helper: __aarch64_ldadd4_acq_rel(uint32_t val, uint32_t* ptr) -> old value
ff0:  bti     c
ff4:  adrp    x16, #0x9000
ff8:  ldrb    w16, [x16, #0x428]    ; global "CPU has LSE" flag
ffc:  cbz     w16, 0x1008
1000: ldaddal w0, w0, [x1]          ; LSE: atomic add, acquire+release, one instruction
1004: ret
1008: mov     w16, w0
100c: ldaxr   w0, [x1]              ; LL/SC: load-acquire exclusive
1010: add     w17, w0, w16
1014: stlxr   w15, w17, [x1]        ; store-release exclusive, w15 = 0 on success
1018: cbnz    w15, 0x100c           ; lost the race -> retry
101c: ret

; initializer (runs at load time via .init_array): decide the flag
1020: paciasp
1024: sub     sp, sp, #0x70
1028: stp     x30, x19, [sp, #0x60]
102c: mov     w0, #0x10             ; AT_HWCAP
1030: bl      getauxval
1034: mov     x19, x0
1038: tbnz    w19, #8, 0x1058       ; HWCAP_ATOMICS (bit 8) set?
103c: mov     w8, wzr               ;   no  -> flag = 0
...   (store flag, return)
1058: adrp    x0, #0
105c: add     x1, sp, #4
1060: add     x0, x0, #0xa9f        ; "ro.arch"
1064: bl      __system_property_get
1068: cmp     w0, #1
106c: b.lt    0x1098                ; property empty -> trust HWCAP
1070: adrp    x1, #0
1074: add     x0, sp, #4
1078: add     x1, x1, #0xa80        ; "exynos9810"
107c: mov     w2, #0xa
1080: and     x8, x19, #0x100
1084: lsr     x19, x8, #8
1088: bl      strncmp
108c: cmp     w0, #0
1090: csel    w8, wzr, w19, eq      ; Exynos 9810 -> force LL/SC
1094: b       0x109c
1098: ubfx    x8, x19, #8, #1
109c: cmp     w8, #0
10a0: cset    w8, ne
10a4: ...     strb w8, [0x9428]; autiasp; ret
```

## Reconstructed source

```cpp
namespace datastore {
uint32_t GetCounterValue(std::atomic<uint32_t>* address) {
    return address->load();                       // seq_cst load -> ldar
}
uint32_t IncrementAndGetCounterValue(std::atomic<uint32_t>* address) {
    return address->fetch_add(1) + 1;             // -> outline-atomic helper
}
}

// Supplied by the compiler runtime, not by DataStore:
//   static bool have_lse;   // 0x9428
//   __attribute__((constructor)) void init_have_lse() {
//       unsigned long hw = getauxval(AT_HWCAP);
//       have_lse = (hw & HWCAP_ATOMICS) && !cpu_is("exynos9810");
//   }
```

## Notes

- **Compared with the textbook instruction.** [[Instructions]] presents loads and stores; atomics add two flavours. **LL/SC** (`ldaxr` … `stlxr` + `cbnz` back) is the ARMv8.0 way: load exclusively, compute, store only if nobody else wrote in between, otherwise retry. **LSE** (`ldaddal`) is ARMv8.1's single read-modify-write instruction. Recognize the LL/SC loop by the exclusive pair and the backward `cbnz` on the status register.
- **Memory-order suffixes.** `ldar` = load-acquire; the `a`/`l` in `ldaxr`/`stlxr`/`ldaddal` = acquire/release. A C++ `seq_cst` RMW maps to the `acq_rel` helper. Plain `ldr`/`str` would mean a non-atomic or relaxed access.
- **Recovering a stripped helper's name.** The helper has no symbol, but its interface (value in `w0`, pointer in `x1`, returns old value), its two paths, and the `ldadd` + `al` suffix + `4`-byte width match compiler-rt's naming scheme `__aarch64_ldadd4_acq_rel`. Every outline-atomic helper looks like this; learn the shape once.
- **`fetch_add(1) + 1`.** The helper returns the *old* value, so the trailing `add w0, w0, #1` is what turns `fetch_add` into "increment and get".
- **Feature detection.** `getauxval(AT_HWCAP)` with `AT_HWCAP = 16` and a test of bit 8 (`HWCAP_ATOMICS`) is how Android code asks "does this CPU support LSE?". The extra `ro.arch` == `"exynos9810"` check disables LSE on a Samsung SoC whose atomics were unreliable — a workaround living in the compiler runtime, visible to anyone who disassembles any outline-atomics binary.
- **`paciasp`/`autiasp`/`bti c`** are pointer-authentication and branch-target-identification instructions; on CPUs without those features they execute as no-ops. They're hardening, not logic.
- **Bit tests three ways.** `tbnz w19, #8`, `and` + `lsr`, and `ubfx x8, x19, #8, #1` all extract the same bit 8 — the compiler picked a different idiom on each path. See [[Arithmetic-And-Logical-Instructions]] and [[CBZ-CBNZ-And-TBZ-TBNZ]].
- **Frida angle.** Hooking `IncrementAndGetCounterValue` with `Interceptor.attach` and reading `args[0]` gives the counter's address in shared memory; `ptr.readU32()` shows the live value ([[NativePointer-And-Memory-API]]).

## See also

- [[Instructions]]
- [[Loading-Addresses-With-ADRP-And-ADD]] — the flag and string addresses
- [[Compare-And-Conditional-Select]] — `csel`/`cset`
- [[Mmap-Call-Arguments-In-Datastore]] — where the shared counter's memory comes from
- [[PressReader]]
- [[ARM64-Android-Reference|Reference]]
