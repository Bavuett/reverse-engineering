---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Bitwise Operations

## Signature / syntax

```
and-int vAA, vBB, vCC       or-int vAA, vBB, vCC       xor-int vAA, vBB, vCC
shl-int vAA, vBB, vCC       shr-int vAA, vBB, vCC      ushr-int vAA, vBB, vCC
not-int vA, vB
```

(each with a `-long` variant on register pairs; `and-`/`or-`/`xor-`/`shl-`/`shr-`/`ushr-` also come in
`/2addr` two-operand and `/lit8`/`/lit16` immediate-operand forms, exactly like the arithmetic family
in [[Dalvik-Instructions|Instructions]])

## Description

Bitwise AND/OR/XOR, left shift, arithmetic right shift (`shr-`, sign-extending), logical right shift
(`ushr-`, zero-filling), and one's-complement negation, on 32-bit or 64-bit integers. Shift amounts are
taken modulo the operand width (32 for `-int`, 64 for `-long`), same as Java's own `<<`/`>>`/`>>>`
operators, which is what these instructions compile from directly.

## Example

```smali
shl-int/lit8 v0, v10, 0xd    # v0 = T << 13
xor-int/2addr v0, v10        # v0 = T ^ (T << 13)
ushr-int/lit8 v1, v0, 0x11   # v1 = v0 >>> 17
xor-int/2addr v0, v1         # v0 ^= v1
shl-int/lit8 v1, v0, 0x5     # v1 = v0 << 5
xor-int/2addr v0, v1         # v0 ^= v1 -- final mixed value
```

(from [[Reading-Raw-Dalvik]]'s worked example 8 — the **xorshift(13, 17, 5)** PRNG mixing step,
recognizable purely from this three-shift-and-XOR shape regardless of what feeds it)

## Notes

A chain of `or-int`/`not-int`/`mul-int` (or similar) feeding a final `xor`/`shl`/`ushr` sequence is
easy to dismiss as "some hash," but specific shift-and-XOR shapes are worth naming on sight the same
way [[Reading-Raw-Disassembly]] treats a class-id-extraction-into-computed-`blr` as always dispatch:
xorshift's `x ^= x << a; x ^= x >>> b; x ^= x << c` is one of the most common such idioms in
hand-rolled obfuscation and lightweight PRNGs alike, and recognizing it lets you skip straight to what
actually varies (the seed) rather than re-deriving the mixing function from scratch. `xor-int` in
particular is also the core operation behind XOR-cascade string/data decoders — see
[[Reading-Raw-Dalvik]]'s worked example 6 for one built from `xor-long`/`xor-int` against static key
material rather than a shift-mixing PRNG.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Reading-Raw-Dalvik]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
