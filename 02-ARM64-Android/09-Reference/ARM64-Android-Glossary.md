---
tags: [reference]
aliases: ["ARM64-Android Glossary"]
---

# ARM64-Android · Glossary

Terminology used across this topic, in alphabetical order. Add a term as soon as you introduce it in a chapter note, rather than assuming it's obvious.

| Term | Meaning |
| --- | --- |
| AAPCS64 | The Procedure Call Standard for the ARM 64-bit Architecture — the standard calling convention: which registers hold arguments/return values, which are callee-saved, stack alignment rules. See [[Functions-And-Calling-Convention]]. |
| AArch64 | The 64-bit execution state of the ARM architecture (as opposed to AArch32/Thumb). "ARM64" and "AArch64" are used interchangeably in this topic. |
| AOT (ahead-of-time) compilation | Compiling source straight to native machine code at build time, as opposed to interpreting bytecode or JIT-compiling at run time. Flutter release builds AOT-compile Dart to ARM64. See [[Flutter-Dart-AOT]]. |
| ART (Android Runtime) | Android's managed runtime for Dalvik bytecode — interprets/JITs/AOT-compiles `.dex` code, distinct from the Dart VM. Covered from the native side in [[Android-Native-Internals]]. |
| Bitfield move (`ubfm`/`sbfm`) | The underlying AArch64 instruction family behind `ubfx`, `sbfx`, `ubfiz`, `sbfiz`, immediate shifts (`lsl`, `lsr`, `asr`), and integer sign/zero extensions (`uxtb`, `sxtw`, ...). See [[UBFM-SBFM-And-Bitfield-Aliases]]. |
| Class ID (cid) | A small integer identifying a Dart object's runtime class, stored in the object header and extracted via `ldur` + `ubfx` (see [[Bitfield-Class-Id-Extraction]] and [[UBFM-SBFM-And-Bitfield-Aliases]]) to index the [[Flutter-Dart-AOT\|Global Dispatch Table]] for virtual calls. |
| Compressed pointer | A 32-bit heap-offset representation used by 64-bit Dart AOT to halve pointer-field size; loaded with a 32-bit `ldur wN` (see [[LDR-And-STR]]) and expanded back to 64 bits via `add xN, xN, HEAP, lsl #32`. See [[Memory-And-Data-Structures]]. |
| Conditional select (`csel`/`csinc`) | Branch-free instructions that choose between two source registers (optionally incrementing, inverting, or negating the second) based on `NZCV` flags. See [[CSEL-CSINC-And-Conditional-Select]]. |
| Dispatch table / GDT | The Dart VM's table of function pointers indexed by class id, used to implement virtual/dynamic calls (`blr lr`, see [[B-BL-BLR-And-RET]]) without a per-class vtable lookup chain. See [[Flutter-Dart-AOT]]. |
| ELF (Executable and Linkable Format) | The binary format for Android's native `.so` libraries and, structurally, the Dart AOT snapshot embedded as `libapp.so`. See [[Android-Native-Internals]]. |
| Frame pointer (`FP` / `X29`) | Register pointing to the fixed base of the current stack frame, saved alongside the Link Register (`LR` / `X30`) at function entry via `stp x29, x30, [sp, #-N]!`. See [[STP-And-LDP]] and [[Functions-And-Calling-Convention]]. |
| JNI (Java Native Interface) | The calling convention and API Java/Kotlin code uses to call into native (C/C++/Rust) code and vice versa. See [[Android-Native-Internals]]. |
| Link register (`LR` / `X30`) | Register that receives the return address (`PC + 4`) on every `bl` or `blr` call and is jumped back to by `ret`. See [[B-BL-BLR-And-RET]] and [[Registers-And-Data]]. |
| NZCV | The four condition flags in `PSTATE` (Negative, Zero, Carry, oVerflow), written by `cmp`/`tst`/`adds`/`subs` and read by `b.<cond>` and `csel` — but neither read nor modified by `cbz`/`cbnz`/`tbz`/`tbnz`. See [[CBZ-CBNZ-And-TBZ-TBNZ]] and [[CSEL-CSINC-And-Conditional-Select]]. |
| Object pool (PP) | A per-isolate table of constants (strings, type arguments, stub addresses, other objects) that Dart AOT code indexes into via the dedicated `PP` register instead of embedding literals inline. See [[Flutter-Dart-AOT]]. |
| PIE / PC-relative addressing (`adr`/`adrp`) | Position-Independent Executable addressing: computing runtime addresses of `.rodata`, `.data`, and `.got` symbols relative to the current `PC` (`adrp` 4 KiB page + 12-bit offset) so the `.so` works at any ASLR load base. See [[ADR-And-ADRP]] and [[Android-Native-Internals]]. |
| PLT/GOT | Procedure Linkage Table / Global Offset Table — the indirection mechanism (`adrp` + `ldr` + `br`, see [[ADR-And-ADRP]] and [[B-BL-BLR-And-RET]]) a dynamically-linked ELF binary uses to call functions in other shared objects. See [[Android-Native-Internals]]. |
| Smi (small integer) | A tagged, unboxed integer representation: the value is shifted left by one bit with the low tag bit clear (`tbz w0, #0`, see [[CBZ-CBNZ-And-TBZ-TBNZ]] and [[UBFM-SBFM-And-Bitfield-Aliases]]), distinguishing it from a heap pointer without a separate type check. See [[Memory-And-Data-Structures]]. |
| Stub | A small, hand-written (not AOT-compiled-from-Dart) routine the compiler emits calls to for common runtime operations — allocation, stack-overflow checks, `await`. See [[Flutter-Dart-AOT]]. |
| Tagged pointer | A pointer value that also encodes a small amount of type information in its low bits (e.g. Smi bit 0 = `0` vs. heap object bit 0 = `1`, causing Dart field accesses to use unscaled `ldur`/`stur` at odd byte offsets — see [[LDR-And-STR]]). See [[Memory-And-Data-Structures]]. |
| THR (Thread register) | The reserved register (`x26` in Dart's ARM64 ABI) pointing at the current `Thread` structure — stack limit, heap bump-allocation pointers, field-table values. See [[Flutter-Dart-AOT]]. |
| Write barrier | A check (and, if needed, a runtime call) inserted after a pointer store into an old-generation object, so the garbage collector's generational invariant stays correct. See [[Memory-And-Data-Structures]]. |

## See also

- [[ARM64-Android-Reference|Reference]]
