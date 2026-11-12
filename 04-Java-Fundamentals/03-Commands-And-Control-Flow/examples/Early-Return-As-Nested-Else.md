---
tags: [example]
level: 2
aliases: ["guard clause semantics", "return inside if", "else-if chain"]
created: 2026-11-12
---

# Example: Early-Return-As-Nested-Else

> [!info] Level 2 — intermediate
> Combines `if`, `(seq)` and the idea of a command that "ends the rest": a guard clause `if (b) return;` followed by more code means the same as putting that code into an `else` — so chains of early returns are nested conditionals.

## Goal

Rewrite a method with early returns into the core language (which has no `return` command), derive it, and recognize both shapes in decompiled code. Belongs to [[Commands-And-Control-Flow]].

## Source with early returns

```java
void classify(int t) {
    if (t < 0) return;
    if (t == 0) { kind = 1; return; }
    if (t < 10 || t > 100) kind = 2;
}
```

## Equivalent nested form (core language)

```java
if (t < 0) skip;
else if (t == 0) kind = 1;
else if (t < 10 || t > 100) kind = 2;
else skip;
```

## Derivation for `σ = {t ↦ 50, kind ↦ 0}`

```
⟨t < 0, σ⟩ →ₑ ff                        → (if-ff), go to the else-command
  ⟨t == 0, σ⟩ →ₑ ff                     → (if-ff)
    ⟨t < 10 || t > 100, σ⟩ →ₑ ff        → (or-ff): both operands evaluated, both ff
    ⟨skip, σ⟩ →_c σ                     → (if-ff) + (skip)
result: σ unchanged, kind = 0
```

With `t = 5`: the third guard is `tt` by `(or-tt)` after evaluating only `t < 10`, and `(if-tt)` yields `σ[kind ↦ 2]`.

## Step by step

1. **`return` means "skip everything after me in this method".** In a sequence `if (b) { c₁; return; } c₂`, the command `c₂` runs only when `b` is false — exactly `if (b) c₁ else c₂`.
2. **Each guard clause adds one nesting level.** A chain of `n` guard clauses is an `if`/`else if` chain of depth `n`; the derivation descends through `(if-ff)` until a guard is true.
3. **Bytecode doesn't distinguish the two styles.** Both compile to tests that jump forward; a `return` becomes either a `return-void` in place or a `goto` to one shared `return-void` at the end. jadx picks one rendering; neither is "the original".
4. **`||` inside a guard** adds a short-circuit branch to the same targets ([[Short-Circuit-As-Nested-Conditionals]]): "first operand true → then-branch directly".
5. **Falling off the end.** When no guard matches, nothing happens — the final `else skip` makes this explicit. Forgetting that case is a classic source of "the field keeps its default" behavior.

## Compared with real code

- [[Command-Kind-If-Chain-In-PressReader]] — this exact shape (empty-check guard, two single-value tests, one `||` test) in real PressReader code.
- [[Deriving-HttpUrl-Effective-Port-In-PressReader]] in [[Operational-Semantics]] — early returns compiled to a shared exit.

## See also

- [[Commands-And-Control-Flow]]
- [[Deriving-An-If-Then-Else]]
- [[Semantic-Equivalence-Of-Two-Fragments]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
