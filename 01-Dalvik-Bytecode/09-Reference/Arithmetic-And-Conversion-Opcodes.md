---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-11-11
---

# Arithmetic and Conversion Opcodes

## Signature / syntax

```
# 3-register binary arithmetic (-int, -long, -float, -double)
add-<type> vAA, vBB, vCC    sub-<type> vAA, vBB, vCC
mul-<type> vAA, vBB, vCC    div-<type> vAA, vBB, vCC    rem-<type> vAA, vBB, vCC

# 2-address in-place variants (vA = vA op vB)
add-<type>/2addr vA, vB     sub-<type>/2addr vA, vB
mul-<type>/2addr vA, vB     div-<type>/2addr vA, vB     rem-<type>/2addr vA, vB

# Integer literal variants (32-bit int only: /lit16 and /lit8)
add-int/lit16 vA, vB, #+CCCC    rsub-int vA, vB, #+CCCC
mul-int/lit16 vA, vB, #+CCCC    div-int/lit16 vA, vB, #+CCCC    rem-int/lit16 vA, vB, #+CCCC
add-int/lit8 vAA, vBB, #+CC     rsub-int/lit8 vAA, vBB, #+CC
mul-int/lit8 vAA, vBB, #+CC     div-int/lit8 vAA, vBB, #+CC     rem-int/lit8 vAA, vBB, #+CC

# Unary negation
neg-int vA, vB    neg-long vA, vB    neg-float vA, vB    neg-double vA, vB

# Primitive numeric conversions
int-to-long vA, vB      int-to-float vA, vB     int-to-double vA, vB
long-to-int vA, vB      long-to-float vA, vB    long-to-double vA, vB
float-to-int vA, vB     float-to-long vA, vB    float-to-double vA, vB
double-to-int vA, vB    double-to-long vA, vB   double-to-float vA, vB
int-to-byte vA, vB      int-to-char vA, vB      int-to-short vA, vB
```

## Description

Perform binary arithmetic (`+`, `-`, `*`, `/`, `%`), unary arithmetic negation (`-x`), and explicit primitive type conversions.

- **Three-register forms** (`op-<type> vAA, vBB, vCC`) compute `vAA = vBB op vCC` without modifying `vBB` or `vCC` (unless `vAA` aliases one of them). For `-long` and `-double`, each named register is the low half of an adjacent 64-bit register pair (`vAA`/`vAA+1`, `vBB`/`vBB+1`, `vCC`/`vCC+1` — see [[Registers]]).
- **Two-address forms** (`op-<type>/2addr vA, vB`) compute `vA = vA op vB` in a compact 16-bit instruction, using 4-bit register fields (`v0`–`v15`) where the destination register doubles as the left-hand operand.
- **Immediate-literal forms** (`op-int/lit8` with a signed 8-bit constant, `op-int/lit16` with a signed 16-bit constant) exist only for 32-bit `int`. Adding a negative constant (`add-int/lit8 v0, v1, -0x5`) already covers `register - constant`, so Dalvik omits `sub-int/lit8` and `sub-int/lit16` entirely and instead defines **reverse subtraction** (`rsub-int` and `rsub-int/lit8`), which computes `vA = #lit - vB` (`constant - register`).
- **Primitive conversions** convert `vB` into `vA`. Widening conversions (`int-to-long`, `int-to-double`, etc.) preserve sign and magnitude; `long-to-int` truncates to the low 32 bits; floating-point-to-integer conversions (`float-to-int`, `double-to-long`, etc.) round toward zero and saturate to `MIN_VALUE`/`MAX_VALUE` (or `0` for `NaN`), matching Java's `(int) d` cast; sub-32-bit narrowing conversions (`int-to-byte`, `int-to-short`, `int-to-char`) sign-extend (`byte`, `short`) or zero-extend (`char`) the low 8 or 16 bits back into a 32-bit register.

## Example

In-place `/2addr` arithmetic in an R8-outlined helper from [[Exercise-01-Outlined-StringBuilder-Helpers]], and `rsub-int/lit8` plus `int-to-byte` in the string-decoder prologue from [[Reading-Raw-Dalvik]]'s worked example 3:

```smali
# Exercise 01: static int a(int x, int y, int z, int w) { return x * y / z + w; }
.method public static a(IIII)I
    .locals 0
    mul-int/2addr p0, p1
    div-int/2addr p0, p2
    add-int/2addr p0, p3
    return p0
.end method
```

```smali
# Reading-Raw-Dalvik worked example 3: linear parameter disguise and byte truncation
mul-int/lit8 p1, p1, 0x2        # p1 = p1 * 2
rsub-int/lit8 v0, p1, 0x1       # v0 = 1 - p1  (literal minus register!)
...
int-to-byte v4, p2              # narrow running int accumulator to signed byte
aput-byte v4, v0, v3            # store into byte[] output array
```

## Notes

Two pitfalls recur when reading arithmetic in real APKs:

1. **`rsub-int` operand order.** Because `add-int/lit8 vA, vB, -k` handles `vB - k`, `rsub-int/lit8 vA, vB, k` is strictly `k - vB` (`rsub-int/lit8 v0, p1, 0x0` is unary negation `v0 = -p1`, and `rsub-int/lit8 v0, p1, 0x1` is `1 - p1`). Obfuscators use `rsub-int/lit8` heavily in string-decoder prologues because readers skimming left-to-right routinely misread it as `p1 - 1`.
2. **Deliberate `div-int/lit8 ..., 0x0` traps.** Integer division or remainder (`div-int`, `rem-int`, `div-long`, `rem-long`) by zero throws `ArithmeticException` at runtime. Hardened apps frequently place `div-int/lit8 v1, v1, 0x0` behind an opaque-predicate branch (see [[Reading-Raw-Dalvik]]'s worked example 2 and [[Recognizing-An-Opaque-Predicate-Guard]]) to trigger an uncatchable-looking crash without any `new-instance` or `throw` instruction appearing in the disassembly.

For bitwise `and-*`, `or-*`, `xor-*`, shifts (`shl-*`, `shr-*`, `ushr-*`), and one's-complement `not-*`, see [[Bitwise-Operations]].

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Bitwise-Operations]]
- [[Registers]] — 64-bit register pairs for `-long` and `-double`
- [[Device-Id-Wide-Register-Uuid]] — `int-to-long` paired with `shl-long/2addr`
- [[Exercise-01-Outlined-StringBuilder-Helpers]]
- [[Reading-Raw-Dalvik]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
