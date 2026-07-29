---
tags: [fundamentals]
aliases: [ARM64 Instructions, AArch64 Instruction Set]
created: 2026-07-28
---

# Instructions

## In short

You don't need all ~1500 pages of the Arm Architecture Reference Manual to read compiled Android code. In practice, static analysis lives on a few dozen instructions from five families: data processing (arithmetic/logic/shift/move), load/store, compare, branch, and conditional-select. This chapter is a working vocabulary of exactly those, biased toward the forms that actually show up in real disassembly (including the Dart-AOT dumps used throughout this topic's [[Classeviva-Flutter-Case-Study|case study]]).

## Explanation

### Data processing

| Instruction | Meaning |
| --- | --- |
| `add`/`sub` (`Xd, Xn, Xm`\|`#imm`) | `Xd = Xn + Xm` (or `+ imm`) |
| `adds`/`subs` | Same, and update NZCV flags — the form `cmp` is an alias of (`subs` with the result discarded) |
| `mul`, `sdiv`/`udiv` | Multiply, signed/unsigned divide (no integer division exception on ARM — divide by zero yields 0) |
| `and`/`orr`/`eor`/`bic` | Bitwise AND / OR / XOR / AND-NOT |
| `lsl`/`lsr`/`asr`/`ror` | Logical shift left/right, arithmetic shift right (sign-extending), rotate right |
| `sbfx`/`ubfx` | Signed/Unsigned Bitfield eXtract — pull `width` bits starting at `lsb` out of a register, sign- or zero-extending the rest. See [[Register-Width-And-Sign-Extension]] |
| `sbfiz`/`ubfiz` | Signed/Unsigned Bitfield Insert in Zero — the inverse: place a value into a bit range within an otherwise-zeroed register. This is exactly how a Dart Smi gets **tagged** (shift left by 1 into a zeroed register) — see [[Memory-And-Data-Structures]] |
| `mov`, `movz`/`movk`/`movn` | Register-to-register move; constant loading — see [[Basic-Arithmetic-And-Moves]] |
| `adrp`/`add` (pair) | PC-relative addressing: `adrp` gets the page (4 KiB-aligned) containing a target, a following `add`/`ldr` supplies the page-internal offset. This is how PIE binaries reference their own data/functions without a relocation at every call site |

### Load/store

| Instruction | Meaning |
| --- | --- |
| `ldr`/`str` `Xt, [Xn, #imm]` | Load/store a register from/to `[base + offset]` |
| `ldur`/`stur` | The _unscaled_-offset forms — offset is a raw signed byte count (`-256`..`255`), not scaled by access size. Dart-AOT-compiled code prefers these almost exclusively for field access, because compressed-pointer field offsets aren't always multiples of the access size |
| `ldp`/`stp` `Xt1, Xt2, [Xn, #imm]` | Load/store **pair** — two registers in one instruction. The canonical function prologue/epilogue idiom `stp fp, lr, [SP, #-0x10]!` / `ldp fp, lr, [SP], #0x10` is this |
| `ldrb`/`ldrh`/`ldrsb`/`ldrsh`/`ldrsw` | Sub-word loads, zero- or sign-extending — see [[Register-Width-And-Sign-Extension]] |
| `!` suffix (pre-index) | Compute the address, use it, **then** write it back into the base register (`[SP, #-0x10]!` decrements SP first, then stores) |
| trailing `, #imm` after `]` (post-index) | Use the address as-is, **then** add the offset into the base register (`[SP], #0x10` uses SP, then increments it — the other half of the prologue/epilogue pair) |
| `ldar`/`stlr`/`ldaxr`/`stlxr` | Acquire/release (and exclusive) variants — atomics and memory ordering; rare in application-level static analysis, common in runtime/allocator internals |

### Compare, branch, conditional select

| Instruction | Meaning |
| --- | --- |
| `cmp Xn, Xm`\|`#imm` | `subs xzr, Xn, Xm` — compare and set flags, discard the result |
| `cbz`/`cbnz Xt, label` | Branch if register is/isn't zero — no flags needed, common for null checks |
| `tbz`/`tbnz Xt, #bit, label` | Branch on a single bit — common for tag-bit checks (Smi vs. heap pointer: `tbz w0, #0, <is_smi>`) |
| `b label` | Unconditional branch |
| `b.cond label` | Conditional branch — `eq`,`ne`,`lt`,`le`,`gt`,`ge`,`lo`(`cc`),`ls`,`hi`,`hs`(`cs`),`vs`,`vc`,`mi`,`pl` |
| `bl label` | Branch-with-link — call: `LR = PC + 4`, then branch |
| `blr Xn` | Branch-with-link to an address held in a register — every **indirect/virtual call** (vtable-style dispatch, computed dispatch-table calls) looks like this |
| `ret` (`{Xn}`) | Return — branches to `LR` (or an explicit register) |
| `csel`/`csinc`/`csinv`/`csneg Xd, Xn, Xm, cond` | Conditional select: `Xd = cond ? Xn : Xm` (or `Xm+1`/`~Xm`/`-Xm` for the variants) — branch-free `?:`, extremely common for boolean results (`csel x0, true_val, false_val, eq`) |

### Condition codes at a glance

| Code | True when | Typical use |
| --- | --- | --- |
| `eq`/`ne` | Z=1 / Z=0 | equality |
| `lt`/`le`/`gt`/`ge` | signed less-than/etc. | signed comparisons |
| `lo`(`cc`)/`ls`/`hi`/`hs`(`cs`) | unsigned less-than/etc. | unsigned comparisons — **watch for `b.ls` guarding a stack/heap-limit check**, that's an unsigned "at or below" |
| `mi`/`pl` | N=1 / N=0 | sign check |
| `vs`/`vc` | overflow set/clear | overflow-checked arithmetic |

## Worked example

```c
int clamp_or_double(int x) {
    if (x < 0) return 0;
    return x * 2;
}
```

```asm
clamp_or_double:
    cmp     w0, #0
    b.lt    .Lret_zero     ; b = branch, lt = larger than
    lsl     w0, w0, #1     ; w1 = x * 2, computed conditionally
    ret
.Lret_zero:
    mov     w0, #0
    ret
```

The branch-free equivalent a compiler is just as likely to emit instead:

```asm
clamp_or_double:
    lsl     w1, w0, #1      ; w1 = x * 2, computed unconditionally
    cmp     w0, #0
    csel    w0, wzr, w1, lt ; w0 = (x < 0) ? 0 : (x * 2)  -- no branch at all
    ret
```

Both are correct translations of the same C; which one a real compiler picks depends on optimization level and how cheap the "wrong" branch's work is. Recognizing the `csel` form as an `if`/`else` in disguise is one of the most valuable pattern-matches in this whole topic — see [[Control-Flow-Patterns]].

## More examples

- [[Load-Store-Addressing-Modes]] — pre-/post-index, `ldp`/`stp`, and why unscaled `ldur` dominates Dart-compiled field access
- [[Compare-And-Conditional-Select]] — building booleans and doing three-way comparisons without branching

## See also

- [[Registers-And-Data]]
- [[Control-Flow-Patterns]]
- [[Functions-And-Calling-Convention]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]

## Flashcards
#flashcards

What's the difference between `ldr` and `ldur`?::Both load from `[base + offset]`; `ldr`'s immediate offset is scaled by the access size and non-negative in its simple form, while `ldur`'s is an unscaled, signed byte offset — `ldur` is what compilers emit when the offset isn't a multiple of the access size.
What does `tbz w0, #0, label` typically test for in Dart-compiled code?::Whether the low tag bit of a value is 0 — i.e. whether it's an unboxed Smi rather than a heap pointer.
What does `csel x0, x1, x2, eq` compute?::`x0 = (flags indicate equal) ? x1 : x2` — a branch-free conditional move/select.
Which condition codes should make you think "unsigned comparison" on sight?::`lo`/`cc`, `ls`, `hi`, `hs`/`cs` — as opposed to the signed `lt`/`le`/`gt`/`ge`.
