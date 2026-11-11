---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Conditional Branches

## Signature / syntax

```
if-eq vA, vB, :label     if-ne vA, vB, :label     if-lt vA, vB, :label
if-ge vA, vB, :label     if-gt vA, vB, :label      if-le vA, vB, :label

if-eqz vAA, :label       if-nez vAA, :label        if-ltz vAA, :label
if-gez vAA, :label       if-gtz vAA, :label        if-lez vAA, :label

cmp-long vAA, vBB, vCC
cmpg-float vAA, vBB, vCC   cmpl-float vAA, vBB, vCC
cmpg-double vAA, vBB, vCC  cmpl-double vAA, vBB, vCC
```

## Description

The two-register `if-*` family compares `vA` against `vB` directly and branches to `:label` if the condition holds, falling through to the next instruction otherwise; the `-z` suffixed family compares a single register against the constant zero instead of a second register. Both families only operate on 32-bit values (`int` or object references, where only `-eqz`/`-nez` make sense — a null check). 64-bit and floating-point comparisons don't have their own `if-*` forms at all: `cmp-long` and the `cmpg-`/`cmpl-` float/double variants instead produce a three-way result (`-1`, `0`, or `1`) into a 32-bit register, which an `if-*z` then branches on. `cmpg-`/`cmpl-` differ only in how they handle `NaN` — `cmpg` treats it as greater, `cmpl` as less — matching Java's own `>`-vs-`<` `NaN` semantics.

## Example

```smali
invoke-virtual {v9}, Ljava/lang/Long;->longValue()J
move-result-wide v9
cmp-long v0, v0, v9
if-ltz v0, :cond_4
```

(from [[Reading-Raw-Dalvik]]'s patch 2 — a `long` comparison decomposed into `cmp-long` plus an `if-ltz` on its three-way result)

## Notes

A `cmp-long`/`cmpg-*`/`cmpl-*` immediately followed by an `if-*z` is a single logical comparison split across two instructions purely because Dalvik has no direct 64-bit/float/double branch — reading the pair together as one unit (rather than puzzling over why an apparently-unused three-way result feeds a zero-check) is the fast way to recognize it. [[Reading-Raw-Dalvik]]'s patch 2 treats exactly this `cmp-*`/`if-*z` pair as the right static-patching target when the comparison's *outcome* is what needs neutralizing, rather than trying to spoof whatever produced its operands — a single two-instruction target is far easier to redirect than re-deriving how either operand was computed. Note also that compilers frequently invert source conditions to branch around the `then` block: a Java `if (x != null) { ... }` typically compiles to `if-eqz vX, :cond_after` (jump *over* the body when `x == null`), as seen throughout [[Exercise-05-Kotlin-Data-Class-Reconstruction]] and [[Exercise-12-The-DQ-Request-Callable]].

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Reading-Raw-Dalvik]]
- [[Exercise-05-Kotlin-Data-Class-Reconstruction]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
