---
tags: [example]
level: 2
aliases: ["program equivalence", "same meaning different code"]
created: 2026-11-12
---

# Example: Semantic-Equivalence-Of-Two-Fragments

> [!info] Level 2 — intermediate
> Combines derivations with a definition: two commands are equivalent when they relate every initial state to the same final state. This is the precise sense in which an optimizer's (or decompiler's) output "means the same" as the source.

## Goal

Prove two small equivalences, find a plausible-looking non-equivalence, and connect this to reading optimized bytecode. Belongs to [[Operational-Semantics]].

## Definition

```
c₁ ≡ c₂   iff   for all σ, σ′:   ⟨c₁, σ⟩ →_c σ′  ⇔  ⟨c₂, σ⟩ →_c σ′
```

## Equivalence 1: `x = x + 1; x = x + 1;`  ≡  `x = x + 2;`

```
Left:   ⟨x = x + 1;, σ⟩ →_c σ[x ↦ σ(x)+1]                         (assign)
        ⟨x = x + 1;, σ[x ↦ σ(x)+1]⟩ →_c σ[x ↦ σ(x)+2]             (assign)
        ⟨x = x + 1; x = x + 1;, σ⟩ →_c σ[x ↦ σ(x)+2]              (seq)
Right:  ⟨x = x + 2;, σ⟩ →_c σ[x ↦ σ(x)+2]                         (assign)
```

Same final state for every `σ` in which `x` is initialized; in states where it isn't, both sides are blocked. Hence equivalent.

## Equivalence 2: `if (b) c else c`  ≡  `c` — only if `b` can't block

```
If ⟨b, σ⟩ →ₑ tt:  (if-tt) gives ⟨c, σ⟩ →_c σ′.   If ⟨b, σ⟩ →ₑ ff:  (if-ff) gives the same.
But if ⟨b, σ⟩ is blocked (e.g. b = (x / y > 0) with y = 0), the left side is blocked, the right is not.
```

So the equivalence holds only for guards that always evaluate — side-effect-free and error-free.

## A non-equivalence: swapping two assignments

`x = 1; y = x;` vs `y = x; x = 1;` from `σ = {x ↦ 5, y ↦ 0}`: the left ends in `{x ↦ 1, y ↦ 1}`, the right in `{x ↦ 1, y ↦ 5}`. A single counterexample state is enough to refute equivalence.

## Step by step

1. **Equivalence is about all states.** Testing one input proves nothing; a derivation with a *symbolic* `σ` covers them all.
2. **Blocking counts.** "Same result when both finish" isn't enough — one side being blocked (an exception) where the other completes breaks equivalence. That's why compilers don't remove `x / y` even when its result is unused.
3. **Dependence decides reordering.** Two assignments can be swapped iff neither reads the variable the other writes — the dependence check every optimizer performs.
4. **This is what R8 relies on.** Release builds rewrite code (constant folding, merging, reordering, inlining) under exactly this contract. A decompiled method can look nothing like the source and still be equivalent to it.

## Compared with real code

- [[Same-Method-Debug-Vs-R8-Release]] in [[Dalvik-Bytecode]] — a debug and an R8 build of the same method: different instructions, equivalent meaning.
- [[Deriving-HttpUrl-Effective-Port-In-PressReader]] — real Kotlin-compiled code where a `return` inside `if` and a shared exit `goto :goto_0` are two equivalent shapes of the same conditional.

## See also

- [[Operational-Semantics]]
- [[Command-Semantics-Rules]]
- [[Blocked-Configurations-And-Runtime-Errors]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
