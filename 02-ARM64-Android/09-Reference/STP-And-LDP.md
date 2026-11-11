---
tags: [reference, reference-entry]
category: "instruction"
created: 2026-11-11
---

# STP-And-LDP

## Signature / syntax

```asm
; Signed offset (base register unchanged):
stp   Xt1, Xt2, [Xn|SP, #imm]
ldp   Xt1, Xt2, [Xn|SP, #imm]

; Pre-index (update base register FIRST, then access memory):
stp   Xt1, Xt2, [Xn|SP, #imm]!
ldp   Xt1, Xt2, [Xn|SP, #imm]!

; Post-index (access memory at current base FIRST, then update base register):
stp   Xt1, Xt2, [Xn|SP], #imm
ldp   Xt1, Xt2, [Xn|SP], #imm

; 32-bit and sign-extending variants:
stp   Wt1, Wt2, [Xn|SP, #imm]
ldp   Wt1, Wt2, [Xn|SP, #imm]
ldpsw Xt1, Xt2, [Xn|SP, #imm]   ; load pair of 32-bit words and sign-extend each to 64 bits
```

## Description

`stp` (**Store Pair of Registers**) and `ldp` (**Load Pair of Registers**) transfer two contiguous words or doublewords between a pair of registers (`Xt1`, `Xt2` or `Wt1`, `Wt2`) and memory in a single 32-bit instruction. Regardless of whether the offset is positive or negative, `Xt1` is always stored at or loaded from the lower memory address (`addr`), and `Xt2` is always stored at or loaded from the adjacent higher memory address (`addr + 8` for 64-bit registers, `addr + 4` for 32-bit registers).

The immediate offset `#imm` is encoded in the instruction as a **signed 7-bit scaled integer** (`-64` to `+63` in scaled units):

| Register width | Scale factor | Byte offset range | Alignment requirement on `#imm` |
| --- | --- | --- | --- |
| 32-bit (`Wt1, Wt2`) | 4 bytes | `-256` to `+252` (`-0x100` to `+0xfc`) | Multiple of 4 |
| 64-bit (`Xt1, Xt2`) | 8 bytes | `-512` to `+504` (`-0x200` to `+0x1f8`) | Multiple of 8 |
| 128-bit SIMD (`Qt1, Qt2`) | 16 bytes | `-1024` to `+1008` (`-0x400` to `+0x3f0`) | Multiple of 16 |

The three addressing modes control whether and when the base register (`Xn` or `SP`) is updated:

1. **Signed offset (`[Xn, #imm]`)** — computes `addr = Xn + imm` and reads or writes the pair there without modifying `Xn`. Used to spill or restore callee-saved register pairs (`x19`/`x20`, `x21`/`x22`, ...) inside an already-allocated stack frame, or to read/write adjacent struct fields (such as Dart's `THR::top` and `THR::end` bump pointers via `ldp x0, x1, [THR, #0x50]`).
2. **Pre-index (`[Xn, #imm]!`)** — updates `Xn = Xn + imm` **before** accessing memory at the new `Xn`. In an AAPCS64 or Dart AOT function prologue, `stp x29, x30, [sp, #-N]!` decrements `SP` by `N` bytes to allocate the stack frame (or the header of the frame) and immediately stores the caller's frame pointer (`x29`/`fp`) at `[sp]` and link register (`x30`/`lr`) at `[sp + 8]`.
3. **Post-index (`[Xn], #imm`)** — accesses memory at the current `Xn` **first**, and then updates `Xn = Xn + imm`. In a function epilogue, `ldp x29, x30, [sp], #N` reloads the saved `fp` and `lr` from `[sp]` and `[sp + 8]` and then increments `SP` by `N` bytes to deallocate the frame in one step right before `ret`.

## Example

```asm
; Standard non-leaf AAPCS64 function prologue and epilogue:
my_nonleaf_fn:
    stp   x29, x30, [sp, #-0x30]!   ; pre-index: SP -= 0x30, then [SP] = x29 (fp), [SP+8] = x30 (lr)
    mov   x29, sp                   ; establish new frame pointer at the base of the frame
    stp   x19, x20, [sp, #0x10]     ; signed offset: spill callee-saved x19/x20 into [SP+0x10..0x1f]
    stp   x21, x22, [sp, #0x20]     ; signed offset: spill callee-saved x21/x22 into [SP+0x20..0x2f]

    ; ... function body (may execute `bl` calls safely since lr and x19-x22 are saved) ...

    ldp   x21, x22, [sp, #0x20]     ; restore x21/x22
    ldp   x19, x20, [sp, #0x10]     ; restore x19/x20
    ldp   x29, x30, [sp], #0x30     ; post-index: reload x29/x30 from [SP], then SP += 0x30
    ret

; Dart AOT EnterFrame / LeaveFrame + stack argument push:
    stp   fp, lr, [SP, #-0x10]!     ; EnterFrame: always allocates 0x10 for fp/lr first
    mov   fp, SP
    sub   SP, SP, #0x20             ; AllocStack(0x20): locals allocated separately below fp
    ; ...
    stp   x16, x0, [SP]             ; push two outgoing arguments onto the stack for a Dart call
```

## Notes

- **Why almost every non-leaf function starts with `stp x29, x30, [sp, #-N]!` and ends with `ldp x29, x30, [sp], #N`**: AArch64 has no dedicated `push` or `pop` instructions, and `SP` must remain **16-byte aligned** whenever it is used as a base register for memory accesses. Because a pair of 64-bit registers (`x29` and `x30`) is already 16 bytes (`0x10`), saving and restoring them together via pre-indexed `stp` and post-indexed `ldp` satisfies the 16-byte alignment rule, updates `SP`, and preserves both the frame chain (`fp`) and return address (`lr`) in a single instruction at each end of the function.
- **NDK single-step allocation vs. Dart AOT two-step allocation**: When a plain NDK C/C++ function needs at most 504 bytes of total frame space, the compiler folds the entire frame allocation into the opening pre-indexed instruction (`stp x29, x30, [sp, #-0x30]!`) and places saved registers at positive offsets above `sp` (`[sp, #0x10]`, `[sp, #0x20]`). Dart's AOT compiler instead always emits `stp fp, lr, [SP, #-0x10]!` followed by `mov fp, SP` (`EnterFrame`) and a separate `sub SP, SP, #0xNN` (`AllocStack`), so locals sit at negative offsets below `fp` (`[fp, #-8]`, `[fp, #-0x10]`) while outgoing stack arguments are written at `[SP]` and `[SP, #0x10]` via `stp`/`str`.
- **Unpredictable register overlap**: For any `ldp` (and for pre-/post-indexed `stp`), encoding the same register twice (`ldp x0, x0, [sp]`) or using one of the transferred registers as the writeback base register (`ldp x0, x1, [x0], #0x10`) is **CONSTRAINED UNPREDICTABLE** in AArch64 — you will never see a valid compiler emit it, and if it appears in disassembly you are almost certainly disassembling data bytes (such as a jump table or embedded pool) as code.
- **Zero-register pairing**: `xzr`/`wzr` is a valid source operand for `stp` (for example, `stp xzr, xzr, [sp, #0x10]` clears a 16-byte stack slot in one instruction, and `stp xzr, x1, [SP]` pushes `(0, x1)` for a Dart call in [[Reading-Raw-Disassembly]]).

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Instructions]]
- [[Functions-And-Calling-Convention]]
- [[Load-Store-Addressing-Modes]]
- [[Stack-Frame-With-Locals]]
- [[Dart-Function-Prologue-In-The-Wild]]
- [[LDR-And-STR]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
