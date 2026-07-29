---
tags: [fundamentals]
aliases: [ARM64 Registers, AArch64 Registers]
created: 2026-07-28
---

# Registers-And-Data

## In short

AArch64 gives you 31 general-purpose 64-bit registers, viewable as either 64-bit (`Xn`) or 32-bit (`Wn`), plus a separate **SIMD&FP (Single Instruction, Multiple Data & Floating Point)** register file, a stack pointer, and a flags register. On top of that generic picture, every Android runtime you'll actually reverse — ART's native side and especially the Dart VM inside a Flutter app — permanently reserves a handful of these registers for its own bookkeeping (a "thread" pointer, a constant pool pointer, ...) and never lets the register allocator touch them. Recognizing those reserved roles on sight is most of what separates "a wall of `ldr`/`str`" from an actual read of the code.

## Explanation

### The 64-bit general-purpose registers

| Register | 32-bit view | Typical role (AAPCS64) |
| --- | --- | --- |
| `X0`–`X7` | `W0`–`W7` | Argument registers / return value(s) |
| `X8` | `W8` | Indirect result register (hidden pointer for large struct returns) |
| `X9`–`X15` | `W9`–`W15` | Caller-saved temporaries |
| `X16`, `X17` | `W16`, `W17` | `IP0`/`IP1` — intra-procedure-call scratch, used by linker veneers and PLT stubs (very common as a generic "just need a register" scratch in generated code too) |
| `X18` | `W18` | Platform register — **reserved on Android**, never allocated by the compiler; skip over it |
| `X19`–`X28` | `W19`–`W28` | Callee-saved ("must be preserved across calls") |
| `X29` | `W29` | Frame pointer (`FP`) |
| `X30` | `W30` | Link register (`LR`) — return address |
| `SP` | — | Stack pointer, 16-byte aligned at every public interface |
| `PC` | — | Program counter — not directly readable/writable by data-processing instructions |
| `XZR`/`WZR` |  | The zero register: reads as 0, writes are discarded. Lets `mov x0, xzr` stand in for "clear register" and `subs xzr, x0, x1` stand in for a compare that discards the result |

Writing to a `Wn` register **zero-extends into the full `Xn`** — `mov w0, #1` clears the top 32 bits of `X0` too. This is the opposite of x86-64, where a 32-bit write also zero-extends but for a different underlying reason (fixed-width RISC encoding vs. the historical x86 shortcut) — worth remembering once, since it means "some instruction touched `w0`" is never a partial, `x0`-stays-dirty update.

### Data types and sizes

| Suffix / mnemonic hint   | Size               |
| ------------------------ | ------------------ |
| `b`                      | byte, 8 bit        |
| `h`                      | halfword, 16 bit   |
| (none) / `w` register    | word, 32 bit       |
| `x` register             | doubleword, 64 bit |
| `q` / SIMD `Vn.16b` etc. | quadword, 128 bit  |

The condition flags live in `PSTATE`, referred to as **NZCV** — Negative, Zero, Carry, oVerflow — set by `S`-suffixed instructions (`adds`, `subs`, `cmp`, `cmn`, ...) and consumed by conditional branches/selects. See [[Instructions]] for how those flags actually get produced and read.

### Reserved registers you'll meet in Android native code

A stock C/C++ `.so` built with the NDK only uses the table above. The moment you're looking at managed-runtime-generated code, several callee-saved registers stop being general-purpose and become **permanently reserved globals** for the life of the process — the compiler's register allocator is simply told never to hand them out. You cannot tell this from the register number alone; you tell it from usage patterns repeating identically across every function. In the Dart VM specifically (see [[Flutter-Dart-AOT]] for the full picture):

| Symbolic name (as tools annotate it) | Role | How to recognize it even unaannotated |
| --- | --- | --- |
| `THR` | Pointer to the current `Thread` structure: stack limit, heap bump-allocation top/end, per-isolate field-table | `ldr x16, [THR, #0x38]` then `cmp SP, x16` then `b.ls <slow path>`, near-identical at the top of almost every function — this is the stack-overflow check |
| `PP` | Pointer to the current object pool — see [[Flutter-Dart-AOT]] | `ldr x1, [PP, #0x3f8]` right before a call or a comparison against something that isn't a small immediate |
| `CODE_REG` | Pointer to the currently executing `Code` object | Rarely shown directly in a decompiler's friendly output; matters mainly for stack-walking/GC, not for reading logic |
| Dispatch-table register (often shown raw, e.g. `x21`) | Base of the **global dispatch table (GDT)** for virtual/dynamic calls by class id | `add lr, x0, x17` / `ldr lr, [x21, lr, lsl #3]` / `blr lr` — a computed call through this register instead of a direct `bl` |
| A fixed register for the canonical `null` object (and, at small constant offsets from it, the canonical `true`/`false` singletons) | Lets a comparison against `null`, or loading the boolean singletons, skip the object pool entirely | `cmp w1, NULL` ; `add x0, NULL, #0x20 ; true` / `#0x30 ; false` |
| A fixed heap-base register used for **pointer decompression** | Recovers a full 64-bit heap pointer from a 32-bit compressed field | `add x2, x2, HEAP, lsl #32` immediately after most `ldur w.., [xN, #offset]` field loads |

The exact register _number_ behind each of these is stable per Dart SDK version (and documented in the SDK's own `runtime/vm/constants_arm64.h` — see [[ARM64-Android-Bibliography|Bibliography]]), but memorizing the number is the wrong thing to optimize for: annotating disassemblers (see [[Tools]]) already print the friendly name, and even when they don't, the _shape_ of the surrounding instructions (a compare against a stack limit, a load right before a call that isn't to a small integer, an `lsl #3` computed branch) identifies the role regardless of which literal `xN` it happens to be. This chapter's [[Registers-And-Data#More examples|examples]] below and the real excerpts under this chapter's `snippets/` walk through spotting these live.

## Worked example

A tiny, hand-written leaf function and how its registers map to AAPCS64 roles:

```c
int add_and_double(int a, int b) {
    return (a + b) * 2;
}
```

```asm
add_and_double:
    add   w0, w0, w1      ; w0 = a (arg 0), w1 = b (arg 1) -> a + b, result in return register w0
    lsl   w0, w0, #1      ; w0 = w0 * 2 (left shift by 1 == multiply by 2)
    ret                   ; return address is already in LR (X30); no explicit load needed
```

Note there's no `stp fp, lr` prologue at all — a genuine **leaf function** (calls nothing else, needs no stack slots) has no reason to save anything. See [[Functions-And-Calling-Convention]] for when a prologue _does_ show up, and why almost every Dart-compiled function has one even when this C example wouldn't.

## More examples

- [[Basic-Arithmetic-And-Moves]] — the `mov`/`movz`/`movk`/`movn` family and why large constants take two instructions
- [[Register-Width-And-Sign-Extension]] — `Wn` vs `Xn` views, and sign- vs zero-extending loads

## See also

- [[Instructions]]
- [[Functions-And-Calling-Convention]]
- [[Flutter-Dart-AOT]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]

## Flashcards
#flashcards

What happens to the top 32 bits of `X0` when you write `W0`?::They're zero-extended (cleared), never left as stale data from a previous 64-bit write.
Which register is reserved on Android and never allocated by the compiler?::`X18`, the platform register.
In Dart AOT-compiled code, what does a load from `THR` immediately followed by a compare against `SP` almost always mean?::A stack-overflow check (`CheckStackOverflow`) — comparing the current stack pointer against the thread's stack limit.
What does `PP` point to in Dart-compiled ARM64 code?::The current object pool — the per-isolate table of constants (strings, type arguments, stub addresses) that code indexes into instead of embedding literals.
