---
tags: [fundamentals]
aliases: ["Transition Systems", "Big-Step Semantics", "Natural Semantics"]
created: 2026-07-30
---

# Operational Semantics

## In short

The **meaning** of a program construct is defined by *how a machine's state changes when it runs*. Formally that machine is a **transition system** ⟨Γ, T, →⟩: a set of configurations Γ (the states the system can be in), a subset T of terminal configurations (finished states), and a transition relation → (γ → γ′ means "from γ the system can step to γ′"). A program's meaning is a **derivation**: a chain of transitions from an initial configuration to a terminal one. This is the notation every other chapter in this topic is written in — and it's not far from what a bytecode interpreter literally does.

## Explanation

### Configurations, transitions, derivations

- A **configuration** γ ∈ Γ is a snapshot of the whole machine at one moment (later: an expression plus a state, or a command plus a state).
- **Terminal** configurations T ⊆ Γ are the ones where computation is done (a plain value, or a final state).
- A **derivation** γ₀ → γ₁ → … → γₙ is one run; `γ ∗→ γ′` means "some derivation leads from γ to γ′". A non-terminal configuration with **no** outgoing transition is **blocked** — which later models a runtime error or non-termination (see [[Commands-And-Control-Flow]]).

### Conditional (inference) rules

The transition relation is defined by **conditional rules** written as a fraction — premises on top, the concluded transition on the bottom:

```
   π₁   π₂   …   πₙ
  ─────────────────
       γ → γ′
```

A premise πᵢ can be an equality (`k = n + m`), a side condition (`n′ ≠ 0`), or **another transition** (`E → n`). When a premise is a transition of the *same* relation, the rule is **recursive** — which is exactly how the meaning of a compound construct is defined in terms of its parts. A rule with variables is really a *schema*: instantiating its variables with concrete values (a **substitution**) yields a concrete rule whose premises you can check.

### Big-step (natural) vs. small-step (evaluation) semantics

Two styles, differing only in how much detail a single transition exposes:

| | Small-step (evaluation) | Big-step (natural) |
|---|---|---|
| A transition describes | one elementary step of the computation | the whole computation, start → final result |
| `2+3+8` | `2+3+8 → 5+8 → 13` (many steps) | `2+3+8 → 13` (one step, justified by a tree) |
| Best for | modelling interleaving, cost, non-termination detail | reasoning about *results* — cleaner for everything here |

This topic uses **big-step** semantics throughout: `⟨E, σ⟩ → v` says "expression E in state σ evaluates to v", and the *justification* is a **derivation tree** whose leaves are axioms (rules with no premises) and whose internal nodes are rule applications.

### A worked derivation tree

Evaluating `2+3+8` (with the parse `2+[3+8]`) under the rule `(exp+): ⟨E⟩→n, ⟨E′⟩→m, k=n+m ⊢ ⟨E+E′⟩→k`:

```
                     3 → 3      8 → 8     11 = 3+8
   2 → 2            ───────────────────────────── (exp+)
  (num)                    3 + 8 → 11                      13 = 2+11
  ────────────────────────────────────────────────────────────────── (exp+)
                        2 + 3 + 8 → 13
```

Each node is a rule instance; a rule with no premises (`2 → 2`) is a leaf. The tree *is* the proof that the program means `13`.

> [!tip] Connection to Dalvik
> A bytecode interpreter is a transition system you can almost read off this page: its configuration is `⟨program counter, register array, heap, …⟩`, and each opcode is a transition rule (`add-int/2addr v0, v1` is a rule that reads two registers and writes their sum back — an instance of the same `k = n + m` premise above). Reading a smali method by hand (see [[Reading-Raw-Dalvik]] in [[Dalvik-Bytecode]]) is exactly building a derivation: you carry a state across instructions and apply one opcode's "rule" at a time. The rest of this topic makes that state — registers/frames, the heap, the class table — precise.

## More examples

- [[Deriving-An-Arithmetic-Expression]] — a full big-step derivation, step by step.

## See also

- [[State-And-Expressions]] — the first real use of this machinery: expressions over a state.
- [[Reading-Raw-Dalvik]] in [[Dalvik-Bytecode]] — reading a method as a state-carrying walk, the informal version of a derivation.

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]

## Flashcards
#flashcards

What are the three components of a transition system?::A set of configurations Γ, a subset T ⊆ Γ of terminal configurations, and a transition relation → between configurations.
What does a premise that is itself a transition (e.g. `E → n`) make a conditional rule?::Recursive — the meaning of a compound construct is defined in terms of transitions of its own sub-parts.
What's the difference between big-step (natural) and small-step (evaluation) semantics?::Big-step relates a construct directly to its final result in one transition (justified by a derivation tree); small-step exposes each individual intermediate step of the computation.
Why is reading a smali method like building a derivation?::You carry a machine state (registers/heap) across the method and apply one opcode's transition rule at a time — the interpreter's configuration and per-opcode rules are exactly a transition system.
