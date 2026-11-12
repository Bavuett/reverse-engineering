---
tags: [example]
level: 1
aliases: ["ARM64 shifted operands", "add orr and eor ARM64"]
created: 2026-11-12
---

# Example: Arithmetic-And-Logical-Instructions

> [!info] Level 1 — basics
> One idea: ARM64's data-processing instructions take an optional shifted second operand, so a single `add` or `orr` often does the work of two C operators.

## Goal

Read `add`/`sub`/`and`/`orr`/`eor` with immediate and shifted-register operands, and translate them back into C expressions. Belongs to [[Instructions]].

## Source

```c
unsigned pack(unsigned hi, unsigned lo) { return (hi << 16) | (lo & 0xffff); }

int times9(int x)              { return x * 8 + x; }

int clear_bit2(int flags)      { return flags & ~4; }

int toggle(int a, int b)       { return a ^ (b >> 3); }

long index_addr(long base, long i) { return base + i * 8; }
```

## Compiled (-O2, AArch64)

```asm
pack:
    and     w8, w1, #0xffff         ; lo & 0xffff
    orr     w0, w8, w0, lsl #16     ; ... | (hi << 16)
    ret

times9:
    add     w0, w0, w0, lsl #3      ; x + (x << 3)
    ret

clear_bit2:
    and     w0, w0, #0xfffffffb     ; flags & ~4
    ret

toggle:
    eor     w0, w0, w1, asr #3      ; a ^ (b >> 3), arithmetic shift: b is signed
    ret

index_addr:
    add     x0, x0, x1, lsl #3      ; base + i*8
    ret
```

## Step by step

1. **Three-operand form.** `op dst, src1, src2` — the destination is written, the sources are untouched. `add w0, w0, w0, lsl #3` reads `w0` twice and writes it once.
2. **Shifted register operand.** The last operand can be shifted before use: `lsl` (left), `lsr` (logical right, unsigned), `asr` (arithmetic right, signed), `ror` (rotate, logical ops only). `orr w0, w8, w0, lsl #16` is `w8 | (w0 << 16)` in one instruction.
3. **Multiply by a constant becomes shifts.** `x * 9` → `x + (x << 3)`. Whenever you see `add xA, xB, xB, lsl #n`, think "multiply by 2ⁿ + 1". Similarly `sub` with a shift gives 2ⁿ − 1.
4. **`asr` vs `lsr` reveals signedness.** `toggle` uses `asr #3` because `b` is a signed `int`; an `unsigned` would produce `lsr`. Shift kind is one of the few places the C type's signedness survives compilation.
5. **Logical immediates are bitmasks.** `and w0, w0, #0xfffffffb` is legal because ARM64 can encode repeating/rotated runs of ones. `~4` is easier to recognize when you invert the immediate yourself: `~0xfffffffb` = `0x4`, "clear bit 2". `0xffff` = "keep the low 16 bits".
6. **Scaled index = array arithmetic.** `add x0, x0, x1, lsl #3` is `&base[i]` for 8-byte elements; the shift amount gives the element size (`lsl #2` → 4-byte, `lsl #3` → 8-byte). See [[Array-Indexing-With-Scaled-Registers]].
7. Some compilers emit a bitfield instruction instead for `pack` (`bfi w1, w0, #16, #16`) — same result; see [[UBFM-SBFM-And-Bitfield-Aliases]].

## Compared with real code

- [[Bitfield-Class-Id-Extraction]] — a real Dart AOT `ubfx` extracting a 20-bit field, the bitfield cousin of `and` + `lsr`.
- [[Outline-Atomics-LSE-Vs-LLSC-In-Datastore]] — real `and x8, x19, #0x100` / `lsr x19, x8, #8` testing one CPU feature bit.

## See also

- [[Instructions]]
- [[Multiply-Divide-And-Modulo]]
- [[Basic-Arithmetic-And-Moves]]
- [[Compare-And-Conditional-Select]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
