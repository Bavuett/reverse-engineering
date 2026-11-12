---
tags: [example]
level: 2
aliases: ["left-to-right evaluation", "i++ semantics", "side-effecting expressions"]
created: 2026-11-12
---

# Example: Evaluation-Order-And-Side-Effects

> [!info] Level 2 — intermediate
> Combines evaluation rules with state change: pure expressions (`⟨e, σ⟩ →ₑ v`) can be evaluated in any order, but as soon as an expression *changes* the state — `i++`, `x = …` inside an expression, a method call — the judgement must return a new state, and Java's left-to-right order becomes part of the meaning.

## Goal

Evaluate `i++ + i` and `a[i] = i = 2` precisely, extend the judgement to side effects, and read the order off the bytecode. Belongs to [[State-And-Expressions]].

## Extending the judgement

The core rules say `⟨e, σ⟩ →ₑ v` — the state is only read. For expressions with side effects the judgement threads the state, left to right:

```
       ⟨e₁, σ⟩ →ₑ ⟨n₁, σ₁⟩    ⟨e₂, σ₁⟩ →ₑ ⟨n₂, σ₂⟩
  ────────────────────────────────────────────────── (arith-se)
           ⟨e₁ + e₂, σ⟩ →ₑ ⟨n₁ + n₂, σ₂⟩

       σ(i) = n
  ─────────────────────────────────── (post-inc)
   ⟨i++, σ⟩ →ₑ ⟨n, σ[i ↦ n + 1]⟩
```

## `i++ + i` from `σ = {i ↦ 5}`

```
  ⟨i++, {i↦5}⟩ →ₑ ⟨5, {i↦6}⟩  (post-inc)      ⟨i, {i↦6}⟩ →ₑ ⟨6, {i↦6}⟩  (ide)
  ─────────────────────────────────────────────────────────────────── (arith-se)
                    ⟨i++ + i, {i↦5}⟩ →ₑ ⟨11, {i↦6}⟩
```

Right-to-left evaluation would give `⟨i, {i↦5}⟩ →ₑ 5` first, then `i++ → 5` — result 10. Java specifies left-to-right, so 11 is *the* answer.

## Compiled

```smali
# i in v0
move v1, v0                   # old value of i (the value of i++)
add-int/lit8 v0, v0, 0x1      # side effect: i = i + 1
add-int v1, v1, v0            # 5 + 6 = 11
```

## Step by step

1. **Pure expressions don't care about order.** In `x * y + z`, evaluating `z` before `x` changes nothing because nothing is written. That's why the core rules can leave the order implicit.
2. **Side effects make σ an output.** `(arith-se)` passes the state produced by `e₁` into `e₂` — a sequencing, exactly like `(seq)` for commands ([[Command-Semantics-Rules]]).
3. **Java fixes the order: left operand fully before right**, arguments left to right, and the left side of an array assignment before the right. `a[i] = i = 2` with `i = 0` stores into `a[0]` — the index is evaluated before the assignment to `i` happens.
4. **Bytecode makes the order explicit.** The `move v1, v0` saving the old value of `i` *before* the increment is the compiler implementing `(post-inc)` + left-to-right.
5. **Method calls are side effects too.** `f() + g()` must call `f` first; if both touch shared state, the order is observable. When decompiled code shows `int t = f(); … t + g()`, the temporary is preserving this order.

## Compared with real code

- [[Short-Circuit-Equals-In-PressReader-HttpUrl]] — real `instanceof && …` code where order isn't just a convention: evaluating the right operand first would be an error.
- [[Builder-Field-Initializers-And-Aliasing-In-PressReader]] in [[Classes-And-Objects]] — a real constructor where statement order determines what a field ends up containing.

## See also

- [[State-And-Expressions]]
- [[Expression-Semantics-Rules]]
- [[Short-Circuit-As-Nested-Conditionals]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
