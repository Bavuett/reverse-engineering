---
tags: [reference, reference-entry]
category: "rules"
created: 2026-11-11
---

# Expression-Semantics-Rules

## Signature / syntax

```
Judgement:  ⟨e, σ⟩ →ₑ v      (in state σ, expression e evaluates to value v ∈ Val)

Literals & Variables:
  ───────────────── (const-int)     ─────────────────── (const-true)     ──────────────────── (const-false)
    ⟨n, σ⟩ →ₑ n                      ⟨true, σ⟩ →ₑ tt                      ⟨false, σ⟩ →ₑ ff

    σ(x) = v    v ∉ {⊥, $}
  ────────────────────────── (ide)
         ⟨x, σ⟩ →ₑ v

Binary Arithmetic & Comparison Operators:
  ⟨e₁, σ⟩ →ₑ n₁    ⟨e₂, σ⟩ →ₑ n₂    k = n₁ ⊕ n₂                   (⊕ ∈ {+, *, -} with n₁ ≥ n₂ for - over ℕ)
  ──────────────────────────────────────────────── (arith)
                 ⟨e₁ ⊕ e₂, σ⟩ →ₑ k

  ⟨e₁, σ⟩ →ₑ n₁    ⟨e₂, σ⟩ →ₑ n₂    n₂ ≠ 0    k = n₁ div n₂       (similarly mod for %)
  ──────────────────────────────────────────────────────────── (exp÷)
                        ⟨e₁ / e₂, σ⟩ →ₑ k

  ⟨e₁, σ⟩ →ₑ n₁    ⟨e₂, σ⟩ →ₑ n₂    b = (n₁ ⋈ n₂)                 (⋈ ∈ {==, !=, <, <=, >, >=})
  ────────────────────────────────────────────────── (rel)
                  ⟨e₁ ⋈ e₂, σ⟩ →ₑ b

Boolean Negation & Short-Circuit Connectives (&& and ||):
     ⟨e, σ⟩ →ₑ b
  ────────────────── (not)
   ⟨!e, σ⟩ →ₑ ¬b

        ⟨e₁, σ⟩ →ₑ ff                            ⟨e₁, σ⟩ →ₑ tt    ⟨e₂, σ⟩ →ₑ b
  ────────────────────────── (and-ff)          ───────────────────────────────── (and-tt)
   ⟨e₁ && e₂, σ⟩ →ₑ ff                                ⟨e₁ && e₂, σ⟩ →ₑ b

        ⟨e₁, σ⟩ →ₑ tt                            ⟨e₁, σ⟩ →ₑ ff    ⟨e₂, σ⟩ →ₑ b
  ────────────────────────── (or-tt)           ───────────────────────────────── (or-ff)
   ⟨e₁ || e₂, σ⟩ →ₑ tt                                ⟨e₁ || e₂, σ⟩ →ₑ b
```

## Description

Consolidated quick-reference of the big-step operational semantics rules $\langle e, \sigma \rangle \to_e v$ for pure expressions in the Java core (see [[State-And-Expressions]]):

- **Literals (`(const-int)`, `(const-true)`, `(const-false)`):** Axioms (zero premises) that evaluate integer numerals $n$ and boolean literals `true`/`false` directly to their semantic values ($n$, $\text{tt}$, $\text{ff}$) independent of $\sigma$.
- **Variable lookup (`(ide)`):** Looks up identifier $x$ in the current state $\sigma$ (either a single frame $\phi(x)$ in [[State-And-Expressions]] or a frame stack $\sigma(x)$ in [[Declarations-And-Scope]]). The side condition $v \notin \{\perp, \$\}$ requires $x$ to be both in scope ($\neq \perp$) and initialized ($\neq \$$); otherwise $\langle x, \sigma \rangle$ is **blocked**.
- **Binary arithmetic and relational operators (`(arith)`, `(exp÷)`, `(rel)`):** Strict binary operators evaluate **both** $\langle e_1, \sigma \rangle \to_e n_1$ and $\langle e_2, \sigma \rangle \to_e n_2$ before combining $n_1$ and $n_2$. Division `/` and remainder `%` carry the side condition $n_2 \neq 0$; when $\langle e_2, \sigma \rangle \to_e 0$, no rule applies and the configuration is blocked (modelling `ArithmeticException`).
- **Short-circuit boolean connectives (`(and-ff)`, `(and-tt)`, `(or-tt)`, `(or-ff)`):** Unlike arithmetic and relational operators, `&&` and `||` do **not** evaluate both operands unconditionally. If $\langle e_1, \sigma \rangle \to_e \text{ff}$, `(and-ff)` concludes $\langle e_1 \mathbin{\&\&} e_2, \sigma \rangle \to_e \text{ff}$ without any premise for $e_2$; similarly, if $\langle e_1, \sigma \rangle \to_e \text{tt}$, `(or-tt)` concludes $\langle e_1 \mathbin{\|} e_2, \sigma \rangle \to_e \text{tt}$ without evaluating $e_2$. Only when $e_1$ does not determine the result (`tt` for `&&`, `ff` for `||`) do `(and-tt)` and `(or-ff)` evaluate $e_2$.

## Example

```
In state σ = { x ↦ 6, y ↦ 2, flag ↦ ff }:

1. Arithmetic + relational:
   ⟨x, σ⟩ →ₑ 6,  ⟨y, σ⟩ →ₑ 2,  2 ≠ 0  ⊢  ⟨x / y, σ⟩ →ₑ 3
   ⟨x / y, σ⟩ →ₑ 3,  ⟨2, σ⟩ →ₑ 2      ⊢  ⟨(x / y) > 2, σ⟩ →ₑ tt

2. Short-circuit avoidance of a blocked sub-expression:
   In σ₂ = { x ↦ 4, y ↦ 2, flag ↦ ff }, ⟨(x / y) > 2, σ₂⟩ →ₑ ff.
   By (and-ff), ⟨(x / y > 2) && (x / (y - 2) == 0), σ₂⟩ →ₑ ff
   even though ⟨x / (y - 2), σ₂⟩ is blocked (division by zero).
```

## Notes

- **Side-effect-free expressions:** In this core grammar, pure expressions only *read* $\sigma$ and never modify it ($\langle e, \sigma \rangle \to_e v$ returns a value $v$, not a new state $\sigma'$). Object allocation `new C()` is treated separately in [[Object-And-Method-Semantics-Rules]] because it allocates a fresh location in the heap.
- **Dalvik bytecode translation:** Arithmetic and relational rules compile to three-register instructions (`add-int`, `div-int`, `sub-int`) in [[Dalvik-Instructions]], whereas the four short-circuit boolean rules `(and-ff)`, `(and-tt)`, `(or-tt)`, `(or-ff)` compile directly to conditional branch chains (`if-eqz`, `if-nez`, `if-le`, ...) in [[Conditional-Branches]].

## See also

- [[Java-Fundamentals-Reference|Reference]]
- [[State-And-Expressions]]
- [[Evaluating-Expressions-In-A-State]]
- [[Deriving-An-Arithmetic-Expression]]
- [[Inference-Rule-Notation]]
- [[State-And-Environment-Substitution]]
- [[Command-Semantics-Rules]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
