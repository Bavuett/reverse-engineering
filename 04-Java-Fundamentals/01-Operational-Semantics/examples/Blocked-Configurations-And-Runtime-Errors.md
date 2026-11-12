---
tags: [example]
level: 2
aliases: ["stuck configuration", "blocked derivation", "no rule applies"]
created: 2026-11-12
---

# Example: Blocked-Configurations-And-Runtime-Errors

> [!info] Level 2 — intermediate
> Combines rule side conditions with Java's exceptions: when no rule's premises can be satisfied, the configuration is *blocked* — the semantics' model of a runtime error — and each Java exception corresponds to a specific failed side condition.

## Goal

Find the exact premise that fails in three erroneous programs, and connect each to the exception Java throws and the bytecode that throws it. Belongs to [[Operational-Semantics]].

## Three blocked configurations

```
(1) Division by zero, σ = {x ↦ 7, y ↦ 0}
    ⟨x, σ⟩ →ₑ 7    ⟨y, σ⟩ →ₑ 0    0 ≠ 0  ✗
    ───────────────────────────────────── (exp÷)   no other rule for "/"  ⇒  ⟨x / y, σ⟩ blocked

(2) Uninitialized variable, σ = {z ↦ $}
    σ(z) = $    $ ∉ {⊥, $}  ✗
    ──────────────────────── (ide)                 ⇒  ⟨z + 1, σ⟩ blocked

(3) Null receiver, σ = {p ↦ null}, any θ
    ⟨p, …⟩ →ₑ null    null ≠ null  ✗
    ─────────────────────────────── (field-read)  ⇒  ⟨p.x, (Δ, σ, θ)⟩ blocked
```

## Step by step

1. **A rule applies only if all its premises hold.** Side conditions (`n₂ ≠ 0`, `v ∉ {⊥, $}`, `ℓ ≠ null`) are premises like any other. If, for the configuration's shape, every candidate rule has a false premise, there is no derivation: the configuration is blocked.
2. **Blocked ≠ non-terminating.** A non-terminating loop has an *infinite* derivation attempt ([[Evaluating-A-While-Loop]]); a blocked configuration has a *finite* attempt that cannot be completed. Big-step semantics can't tell them apart (both: "no result"); small-step can ([[Small-Step-Vs-Big-Step-On-One-Expression]]).
3. **Blocking propagates.** If a sub-expression is blocked, every expression whose rule needs it as a premise is blocked too: `x / y + 1` is blocked because `(arith)` needs `⟨x / y, σ⟩ →ₑ n₁`. The exception: short-circuit rules that don't evaluate the blocked operand ([[Evaluating-Expressions-In-A-State]]).
4. **Java's mapping.** (1) → `ArithmeticException` thrown by `div-int`; (2) → rejected *at compile time* by Java's definite-assignment rule, so it never reaches bytecode; (3) → `NullPointerException` thrown by `iget`. The semantics models (1) and (3) as "stuck"; real Java turns the stuck point into a thrown exception that a `catch` can handle.
5. **Explicit checks are guards that avoid blocking.** `if (y != 0) r = x / y;` is never blocked: `(if-ff)` skips the division when its side condition would fail.

## Compiled

```smali
div-int v0, v1, v2            # (1): throws ArithmeticException when v2 == 0
iget v0, v3, LPoint;->x:I     # (3): throws NullPointerException when v3 == null
```

## Compared with real code

- [[Blocked-Null-Checks-In-HttpUrl-Builder]] — a real builder that tests the side condition itself and throws a descriptive exception instead of letting the configuration block later.
- [[Reimplementing-Trapped-Methods-In-JavaScript]] in [[Frida-Dynamic-Instrumentation]] — anti-tampering code that blocks *deliberately* (`div-int/lit8 v1, v1, 0x0`, `throw null`).

## See also

- [[Operational-Semantics]]
- [[Expression-Semantics-Rules]]
- [[Object-And-Method-Semantics-Rules]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
