---
tags: [reference, reference-entry]
category: "rules"
created: 2026-11-11
---

# Command-Semantics-Rules

## Signature / syntax

```
Judgement:  ⟨c, σ⟩ →_c σ′      (executing command c in state σ terminates in updated state σ′)

No-op (skip / empty statement):
  ───────────────────── (skip)
    ⟨skip, σ⟩ →_c σ

Variable Assignment:
       ⟨e, σ⟩ →ₑ v
  ─────────────────────────── (assign)
   ⟨x = e;, σ⟩ →_c σ[x ↦ v]

Sequential Composition:
   ⟨c₁, σ⟩ →_c σ″    ⟨c₂, σ″⟩ →_c σ′
  ──────────────────────────────────── (seq)
          ⟨c₁; c₂, σ⟩ →_c σ′

Declarations & Block Scope (stack of frames σ = ρ₁ · σ_rest):
   σ = ρ₁ · σ₀    σ′ = (ρ₁[x ↦ $]) · σ₀             σ = ρ₁ · σ₀    ⟨e, σ⟩ →ₑ v    σ′ = (ρ₁[x ↦ v]) · σ₀
  ──────────────────────────────────────── (decl)   ────────────────────────────────────────────────────── (decl-init)
             ⟨T x;, σ⟩ →_c σ′                                         ⟨T x = e;, σ⟩ →_c σ′

      ⟨D c, ω · σ⟩ →_c ρ_local · σ′
  ───────────────────────────────────── (block)
            ⟨{ D c }, σ⟩ →_c σ′

Conditional (if / else):
   ⟨e, σ⟩ →ₑ tt    ⟨c₁, σ⟩ →_c σ′                    ⟨e, σ⟩ →ₑ ff    ⟨c₂, σ⟩ →_c σ′
  ─────────────────────────────────── (if-tt)       ─────────────────────────────────── (if-ff)
   ⟨if (e) c₁ else c₂, σ⟩ →_c σ′                     ⟨if (e) c₁ else c₂, σ⟩ →_c σ′

While Loop:
           ⟨e, σ⟩ →ₑ ff                              ⟨e, σ⟩ →ₑ tt    ⟨c, σ⟩ →_c σ″    ⟨while (e) c, σ″⟩ →_c σ′
  ─────────────────────────────── (while-ff)        ────────────────────────────────────────────────────────── (while-tt)
     ⟨while (e) c, σ⟩ →_c σ                                           ⟨while (e) c, σ⟩ →_c σ′
```

## Description

Consolidated quick-reference of the big-step operational semantics transition rules $\langle c, \sigma \rangle \to_c \sigma'$ for commands, declarations, blocks, and structured control flow (see [[Commands-And-Control-Flow]] and [[Declarations-And-Scope]]):

- **`skip` (`(skip)`):** The empty command performs no state change and returns $\sigma$ unchanged.
- **Variable assignment (`(assign)`):** Evaluates the right-hand side $\langle e, \sigma \rangle \to_e v$ and returns $\sigma[x \mapsto v]$ (also written $\sigma[v/x]$), updating the innermost frame in $\sigma$ where $x$ is bound (see [[State-And-Environment-Substitution]]). Assignment is the fundamental primitive that mutates stack state.
- **Sequential composition (`(seq)`):** Executes $c_1$ in state $\sigma$ to obtain intermediate state $\sigma''$, then threads $\sigma''$ as the input state to $c_2$ to produce final state $\sigma'$.
- **Declarations and blocks (`(decl)`, `(decl-init)`, `(block)`):** Entering a block `{ D c }` pushes a fresh empty frame $\omega$ onto the stack ($\omega \cdot \sigma$), executes the block's declarations $D$ (which bind new local identifiers in that top frame) and statements $c$, and pops the top frame $\rho_{\text{local}}$ on exit so local bindings vanish while mutations made to outer frames in $\sigma'$ survive.
- **Conditional (`(if-tt)`, `(if-ff)`):** Evaluates boolean guard $e$ in $\sigma$; depending on whether the result is $\text{tt}$ or $\text{ff}$, executes either $c_1$ or $c_2$ in $\sigma$ and discards the untaken branch.
- **While loop (`(while-ff)`, `(while-tt)`):** Defined inductively on the number of iterations. When $\langle e, \sigma \rangle \to_e \text{ff}$, `(while-ff)` terminates immediately with $\sigma$. When $\langle e, \sigma \rangle \to_e \text{tt}$, `(while-tt)` executes the loop body $c$ once to reach $\sigma''$ and then recursively requires a derivation of the same loop $\langle \texttt{while (}e\texttt{) } c, \sigma'' \rangle \to_c \sigma'$ from the updated state $\sigma''$.

## Example

```
Trace ⟨{ int z = x; while (z > 0) z = z - 1; x = z; }, σ⟩ from σ = { x ↦ 1 } · Ω:

1. Push empty frame ω:                     ω · { x ↦ 1 } · Ω
2. Declaration int z = x; (decl-init):     { z ↦ 1 } · { x ↦ 1 } · Ω
3. while (z > 0) z = z - 1; (while-tt):    guard z > 0 →ₑ tt; body sets z ↦ 0 in top frame:
                                           { z ↦ 0 } · { x ↦ 1 } · Ω
4. Next iteration (while-ff):              guard z > 0 →ₑ ff; loop finishes with { z ↦ 0 } · { x ↦ 1 } · Ω
5. Assignment x = z; (assign):             z looks up 0 in top frame; x updates in outer frame:
                                           { z ↦ 0 } · { x ↦ 0 } · Ω
6. Pop top frame on block exit (block):    { x ↦ 0 } · Ω   (local z discarded; outer x = 0 survives)
```

## Notes

- **Non-termination in `(while-tt)`:** If executing $c$ never leads to a state where $\langle e, \sigma'' \rangle \to_e \text{ff}$, attempting to build a derivation tree for `(while-tt)` unfolds infinitely and no terminal state $\sigma'$ is ever derived.
- **Dalvik and ARM64 control-flow correspondence:** In compiled bytecode and native code ([[Dalvik-Instructions]], [[Conditional-Branches]], [[Control-Flow-Patterns]], [[Loop-As-Backward-Branch]]), `(seq)` is fall-through instruction order, `(if-tt)`/`(if-ff)` is a conditional branch past the untaken block, and `(while-tt)`'s recursive premise is a backward `goto` / `b` to the loop header.

## See also

- [[Java-Fundamentals-Reference|Reference]]
- [[Commands-And-Control-Flow]]
- [[Declarations-And-Scope]]
- [[Evaluating-A-While-Loop]]
- [[Nested-Blocks-And-Shadowing]]
- [[Expression-Semantics-Rules]]
- [[Object-And-Method-Semantics-Rules]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
