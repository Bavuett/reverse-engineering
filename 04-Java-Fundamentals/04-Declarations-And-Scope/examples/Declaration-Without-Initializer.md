---
tags: [example]
level: 1
aliases: ["decl rule", "definite assignment", "uninitialized marker $"]
created: 2026-11-12
---

# Example: Declaration-Without-Initializer

> [!info] Level 1 — basics
> One idea: `int x;` and `int x = 5;` are different rules — the first binds `x` to the uninitialized marker `$` in the top frame, the second to a value — and Java's definite-assignment check guarantees the `$` is overwritten before any read.

## Goal

Trace a block that declares a variable without an initializer and assigns it on both branches of an `if`, frame by frame. Belongs to [[Declarations-And-Scope]].

## Program

```java
{
    int sign;
    if (n < 0) sign = -1; else sign = 1;
    r = sign * n;
}
```

## Trace from `σ = {n ↦ -4, r ↦ 0} · Ω`

```
(block)        push ω                              ω · {n↦-4, r↦0} · Ω
(decl)         int sign;                           {sign↦$} · {n↦-4, r↦0} · Ω
(if-tt)        n < 0 →ₑ tt;  (assign) sign = -1    {sign↦-1} · {n↦-4, r↦0} · Ω
(assign)       r = sign * n   (ide finds sign=-1)  {sign↦-1} · {n↦-4, r↦4} · Ω
(block)        pop {sign↦-1}                       {n↦-4, r↦4} · Ω
```

## Step by step

1. **`(decl)` creates the binding, `(assign)` fills it.** After `int sign;` the name is in scope (`σ(sign) ≠ ⊥`) but holds `$`, so `(ide)` would refuse to read it ([[Variable-Lookup-And-Uninitialized-Values]]).
2. **Assignment updates the frame that binds the name.** `sign = -1` finds `sign` in the top frame and overwrites `$` there; `r = …` finds `r` in the outer frame and updates it there ([[State-And-Environment-Substitution]]).
3. **Both branches assign.** Whatever the guard, `sign` holds a real value before `sign * n` — Java's compiler proves this ("definitely assigned") and would reject the program if the `else` were missing.
4. **Leaving the block removes `sign`**, but the effect on `r` survives — the outer frame was updated in place.
5. **Bytecode has no declaration instruction.** `int sign;` emits nothing; the register is simply first written on each branch. Decompilers re-insert the declaration where they see fit, often at the top of the method.

## Compiled

```smali
# n in v0, r in v1
if-gez v0, :pos
const/4 v2, -0x1              # sign = -1   (first write of v2 on this path)
goto :join
:pos
const/4 v2, 0x1               # sign = 1    (first write of v2 on this path)
:join
mul-int v1, v2, v0            # r = sign * n
```

## Compared with real code

- [[Branch-Assigned-Locals-In-PressReader-HttpUrl-Builder]] — a real `ArrayList arrayList;` assigned on both branches of an `if`, exactly this pattern.
- [[Synchronized-Block-Locals-In-PressReader]] — a declaration the decompiler invented that doesn't exist in the bytecode at all.

## See also

- [[Declarations-And-Scope]]
- [[Nested-Blocks-And-Shadowing]]
- [[Command-Semantics-Rules]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
