---
tags: [reference, reference-entry]
category: "formalism"
created: 2026-11-11
---

# Inference-Rule-Notation

## Signature / syntax

```
Axiom (no premises):
  ─────────────── (rule-name)
      γ → γ′

Conditional inference rule (premises above, conclusion below, optional side conditions):
    π₁    π₂    …    πₙ        [side condition, e.g. n′ ≠ 0]
  ─────────────────────────── (rule-name)
            γ → γ′

Big-step vs. small-step judgements:
  Big-step (natural semantics):     ⟨e, σ⟩ →ₑ v        ⟨c, σ⟩ →_c σ′        ⟨P, σ⟩ → σ′
  Small-step (structural/eval):     ⟨e, σ⟩ →₁ ⟨e′, σ⟩   ⟨c, σ⟩ →₁ ⟨c′, σ′⟩   γ →* γ′
```

## Description

Operational semantics defines the transition relation $\to$ of a transition system $\langle \Gamma, T, \to \rangle$ inductively using **inference rules** (also called *conditional rules* or *structural operational semantics* rules). Each rule is written as a horizontal bar with zero or more **premises** $\pi_1, \dots, \pi_n$ above the bar and a single **conclusion** $\gamma \to \gamma'$ below the bar:

- **Axioms:** A rule with zero premises above the bar holds unconditionally whenever its syntactic pattern (and any side condition) matches. Axioms form the leaves of every derivation tree — for example, evaluating a literal constant $\langle n, \sigma \rangle \to_e n$ or looking up a variable $\langle x, \sigma \rangle \to_e \sigma(x)$.
- **Conditional (recursive) rules:** A rule with one or more transition premises above the bar concludes the bottom transition only if every premise above the bar can itself be derived. When a premise is a transition of the same relation on a sub-construct (e.g., $\langle e_1, \sigma \rangle \to_e n_1$), the rule is **recursive** (syntax-directed).
- **Side conditions:** Non-transition constraints written alongside the premises (such as $n_2 \neq 0$ for division, $k = n_1 + n_2$ for addition, or $\ell \notin \text{dom}(\theta)$ for fresh heap allocation) restrict when a rule schema may be instantiated. When no rule's premises and side conditions are satisfied for a non-terminal configuration, that configuration is **blocked**.
- **Derivation trees:** A proof that $\gamma \to \gamma'$ holds is a finite tree in which the root at the bottom is $\gamma \to \gamma'$, every internal node is an instantiated inference rule whose children are derivations of its premises, and every leaf at the top is an axiom.
- **Big-step ($\langle P, \sigma \rangle \to \sigma'$) vs. small-step ($\gamma \to_1 \gamma'$):** In **big-step (natural) semantics**, a single transition relates a construct and starting state directly to its final terminal result (a value $v$ for expressions, or a final state $\sigma'$ for commands), hiding intermediate steps inside the structure of the derivation tree. In **small-step semantics**, each transition $\to_1$ performs a single atomic step of reduction, and a complete execution is a reflexive-transitive chain $\gamma_0 \to_1 \gamma_1 \to_1 \dots \to_1 \gamma_k \in T$ (written $\gamma_0 \to^* \gamma_k$).

## Example

```
Big-step derivation tree for ⟨(x + 3) * 2, σ⟩ →ₑ 16  where σ(x) = 5:

    σ(x) = 5
  ───────────── (ide)   ───────────── (const)
  ⟨x, σ⟩ →ₑ 5           ⟨3, σ⟩ →ₑ 3            8 = 5 + 3
  ──────────────────────────────────────────────────────── (exp+)   ───────────── (const)
                     ⟨x + 3, σ⟩ →ₑ 8                                ⟨2, σ⟩ →ₑ 2            16 = 8 * 2
                     ───────────────────────────────────────────────────────────────────────────────── (exp*)
                                                ⟨(x + 3) * 2, σ⟩ →ₑ 16

Corresponding small-step reduction chain (→*):
  ⟨(x + 3) * 2, σ⟩  →₁  ⟨(5 + 3) * 2, σ⟩  →₁  ⟨8 * 2, σ⟩  →₁  16
```

## Notes

- **Rule schemas and substitution:** Inference rules are written with meta-variables ($e, e_1, e_2$ for expressions, $c$ for commands, $\sigma$ for states, $n, v$ for values). Applying a rule means choosing a consistent substitution that maps every meta-variable to a concrete syntax tree, state, or value.
- **Non-termination vs. blocked states in big-step semantics:** In big-step semantics, both a runtime error (such as division by zero, where the side condition $n_2 \neq 0$ fails and no finite tree exists) and an infinite loop (`while (true) skip`, where trying to build a tree unfolds forever) result in **no finite derivation tree** $\langle c, \sigma \rangle \to_c \sigma'$. Small-step semantics distinguishes them: a blocked configuration has no outgoing $\to_1$ step ($\gamma \not\to_1$), whereas an infinite loop has an infinite chain $\gamma_0 \to_1 \gamma_1 \to_1 \cdots$.

## See also

- [[Java-Fundamentals-Reference|Reference]]
- [[Operational-Semantics]]
- [[Deriving-An-Arithmetic-Expression]]
- [[Expression-Semantics-Rules]]
- [[Command-Semantics-Rules]]
- [[Object-And-Method-Semantics-Rules]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
