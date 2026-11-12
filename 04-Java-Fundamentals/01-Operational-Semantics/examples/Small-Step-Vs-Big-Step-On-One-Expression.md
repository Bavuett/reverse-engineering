---
tags: [example]
level: 1
aliases: ["small-step vs big-step", "structural vs natural semantics"]
created: 2026-11-12
---

# Example: Small-Step-Vs-Big-Step-On-One-Expression

> [!info] Level 1 — basics
> One idea: the same evaluation can be described as one judgement justified by a tree (big-step, the style used in this topic) or as a chain of single rewriting steps (small-step) — and the small-step chain is what a bytecode listing actually looks like.

## Goal

Evaluate `(x + 2) * y` in `σ = {x ↦ 3, y ↦ 4}` both ways and see what each style makes visible. Belongs to [[Operational-Semantics]].

## Big-step (natural semantics)

One judgement, justified by a derivation tree whose leaves are axioms:

```
 ⟨x,σ⟩→ₑ3 (ide)   ⟨2,σ⟩→ₑ2 (const-int)
 ───────────────────────────────── (arith)    ⟨y,σ⟩→ₑ4 (ide)
        ⟨x + 2, σ⟩ →ₑ 5
 ────────────────────────────────────────────────────── (arith)
                ⟨(x + 2) * y, σ⟩ →ₑ 20
```

## Small-step (structural semantics)

A sequence of configurations, each obtained from the previous by rewriting exactly one innermost sub-expression:

```
⟨(x + 2) * y, σ⟩
  → ⟨(3 + 2) * y, σ⟩      look up x
  → ⟨5 * y, σ⟩            add
  → ⟨5 * 4, σ⟩            look up y
  → ⟨20, σ⟩               multiply — a value: no further step
```

## Compiled

```smali
# x in v0, y in v1
add-int/lit8 v2, v0, 0x2      # 3 + 2  -> v2 = 5
mul-int v2, v2, v1            # 5 * 4  -> v2 = 20
```

## Step by step

1. **Big-step answers "what is the result?"** — `⟨e, σ⟩ →ₑ v` relates an expression directly to its final value. Intermediate results exist only as the conclusions of sub-trees.
2. **Small-step answers "what happens next?"** — each `→` performs one elementary operation. Intermediate expressions like `5 * y` are explicit configurations.
3. **Same answer.** For terminating expressions both styles agree on the value (20). They differ in what they can *say*: small-step can describe a computation that runs forever or gets stuck halfway, step by step; big-step can only say "no derivation exists".
4. **Bytecode is small-step.** Each Dalvik instruction is one step on a machine state (registers ≈ σ plus temporaries). The big-step tree's evaluation order (left operand first, then right, then the operator) is exactly the order of the instructions.
5. **This topic uses big-step** ([[Expression-Semantics-Rules]], [[Command-Semantics-Rules]]) because derivation trees make the *structure* of a program's meaning visible; reading compiled code is the small-step view of the same thing.

## Compared with real code

- [[Deriving-HttpUrl-Effective-Port-In-PressReader]] — a big-step derivation for a real method, set beside its small-step Dalvik listing.

## See also

- [[Operational-Semantics]]
- [[Deriving-An-Arithmetic-Expression]]
- [[Inference-Rule-Notation]]
- [[Dalvik-Instructions]] in [[Dalvik-Bytecode]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
