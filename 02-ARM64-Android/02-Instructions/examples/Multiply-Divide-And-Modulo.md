---
tags: [example]
level: 1
aliases: ["madd msub sdiv", "ARM64 modulo", "magic number division"]
created: 2026-11-12
---

# Example: Multiply-Divide-And-Modulo

> [!info] Level 1 — basics
> One idea: ARM64 has no modulo instruction — `%` is a divide followed by a multiply-subtract — and division by a constant usually isn't a division at all.

## Goal

Recognize the multiply-accumulate family (`madd`, `msub`, `mul`, `umull`) and the three shapes division takes: a real `sdiv`/`udiv`, a shift for powers of two, and a "magic number" multiply for other constants. Belongs to [[Instructions]].

## Source

```c
int mac(int a, int b, int c)  { return a * b + c; }

int mod(int a, int b)         { return a % b; }

int div4(int x)               { return x / 4; }

unsigned div10(unsigned x)    { return x / 10; }
```

## Compiled (clang -O2, AArch64)

```asm
mac:
    madd    w0, w0, w1, w2          ; a*b + c
    ret

mod:
    sdiv    w8, w0, w1              ; q = a / b
    msub    w0, w8, w1, w0          ; a - q*b
    ret

div4:
    add     w8, w0, #3              ; bias for negative x
    cmp     w0, #0
    csel    w8, w8, w0, lt          ; x < 0 ? x+3 : x
    asr     w0, w8, #2              ; >> 2
    ret

div10:
    mov     w8, #0xcccd
    movk    w8, #0xcccc, lsl #16    ; w8 = 0xCCCCCCCD
    umull   x8, w0, w8              ; 64-bit product
    lsr     x0, x8, #35             ; >> 35
    ret
```

## Step by step

1. **`madd d, n, m, a` = `n*m + a`**; `mul` is `madd` with `xzr` as the addend. `msub d, n, m, a` = `a - n*m`.
2. **`%` is two instructions.** `sdiv` + `msub` using the quotient is the universal modulo pattern. Division by zero does *not* trap on ARM64 — `sdiv` returns 0 — so any "divide by zero" exception you expect from the source must be an explicit check (Dalvik's `div-int` does throw; native code doesn't).
3. **Signed division by 2ⁿ** needs a correction because `asr` rounds toward −∞ while C rounds toward zero: add `2ⁿ − 1` only when `x` is negative (`csel`), then shift. The constant added (`#3`) and the shift (`#2`) give you the divisor: 4.
4. **Magic-number division.** `x / 10` becomes "multiply by `0xCCCCCCCD`, keep the high bits" — because `0xCCCCCCCD / 2³⁵ ≈ 1/10`. To recover the divisor from code: divisor ≈ 2^(32 + extra shift) ÷ magic → 2³⁵ ÷ 3 435 973 837 ≈ 10.0. A `movz`/`movk` pair loading a strange constant followed by `umull`/`smull`/`umulh`/`smulh` and a shift is almost always a division by a constant.
5. **`umull` vs `smull`** (32×32→64) and `umulh`/`smulh` (high 64 bits of 64×64) also reveal signedness, like `lsr`/`asr` in [[Arithmetic-And-Logical-Instructions]].

## Compared with real code

- [[Smi-Boxing-And-Unboxing]] — real Dart AOT code where integer tagging is a multiply-by-two done with a shift (`sbfiz`).
- [[Walking-An-Unknown-Function-Cold]] — recovering arithmetic intent from an unlabeled function.

## See also

- [[Instructions]]
- [[Arithmetic-And-Logical-Instructions]]
- [[Compare-And-Conditional-Select]] — the `csel` in `div4`
- [[Basic-Arithmetic-And-Moves]] — `movz`/`movk`

## References

- [[ARM64-Android-Bibliography|Bibliography]]
