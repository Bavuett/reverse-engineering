---
tags: [example]
created: 2026-07-28
---

# Example: Load-Store-Addressing-Modes

## Goal

Walk through every addressing mode you'll actually meet, from a plain offset load to the
pre-/post-indexed pair that builds a stack frame. Belongs to [[Instructions]].

## Walkthrough

```asm
ldr   x0, [x1, #0x10]      ; plain offset: x0 = *(x1 + 0x10), x1 unchanged
ldur  x0, [x1, #-0x8]      ; unscaled offset, can be any byte count (incl. negative)
ldr   x0, [x1, x2]         ; register offset: x0 = *(x1 + x2)
ldr   x0, [x1, x2, lsl #3] ; scaled register offset: x0 = *(x1 + x2*8) -- classic array indexing

stp   x29, x30, [sp, #-0x10]!   ; pre-index: sp -= 0x10, THEN store the pair at [sp]
ldp   x29, x30, [sp], #0x10     ; post-index: load the pair from [sp], THEN sp += 0x10
```

## Step by step

1. `ldr x0, [x1, #0x10]` reads an 8-byte field at a fixed offset from a pointer in `x1` — the
   bread-and-butter "read an object field" or "read a local variable" instruction.
2. `ldur` is the same idea but with an unscaled, signed 9-bit immediate offset — this is what you
   see for **almost every Dart-object field access**, because compressed-pointer field offsets are
   frequently not multiples of the natural access size that `ldr`'s scaled encoding requires.
3. Register-offset forms (`[x1, x2]`, optionally `lsl #N`) implement indexing: `array[i]` compiles
   to a base pointer plus an index register, shifted by `log2(element size)`.
4. `stp`/`ldp` with `!` (pre-index) and trailing `, #imm` (post-index) are the two halves of a
   **stack frame**: push both `fp` and `lr` in one instruction while also moving `sp`, then later
   pop both while restoring `sp` — see [[Functions-And-Calling-Convention]] for the full prologue.

## Diagram

```mermaid
graph LR
    A["stp fp, lr, [SP, #-0x10]!"] -->|"SP -= 0x10, store"| B["frame set up"]
    B --> C["... function body ..."]
    C --> D["ldp fp, lr, [SP], #0x10"] -->|"load, then SP += 0x10"| E["frame torn down"]
```

## See also

- [[Instructions]]
- [[Functions-And-Calling-Convention]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
