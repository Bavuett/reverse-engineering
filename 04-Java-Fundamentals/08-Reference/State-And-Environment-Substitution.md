---
tags: [reference, reference-entry]
category: "formalism"
created: 2026-11-11
---

# State-And-Environment-Substitution

## Signature / syntax

```
Flat frame / single environment (ϕ or ρ):
  ϕ : Ide ⇀ Val                                 (finite partial function; ϕ(x) = ⊥ if x ∉ dom(ϕ))
  ω                                             (empty frame: ω(x) = ⊥ for all x)
  ϕ[x ↦ v]   or   ϕ[v/x]                        (functional update / override of x to v in frame ϕ)

Environment stack / stack of frames (σ):
  σ = ρ₁ · ρ₂ · … · ρₖ   or   ϕₙ.….ϕ₁.Ω         (ρ₁ / ϕₙ = innermost/topmost frame; Ω = empty stack)
  σ(x)                                          (lookup from innermost frame ρ₁ outward to ρₖ)
  σ[x ↦ v]   or   σ[v/x]                        (in-place update of the innermost frame that binds x)

Heap (θ or ζ):
  θ : Loc ⇀ Obj      where Obj = ClassName × Frame
  θ(ℓ) = (C, ϕ)                                 (heap lookup at location/reference ℓ)
  θ[ℓ ↦ (C, ϕ′)]    or   ζ[(C, ϕ′)/ℓ]          (heap update at location ℓ)
```

## Description

The operational semantics represents program memory through finite partial functions and functional overrides (substitutions) across three structures — a **flat frame** ($\phi$ or $\rho$), a **stack of frames** ($\sigma$), and the **heap** ($\theta$ or $\zeta$):

- **Frame lookup $\phi(x)$ and functional update $\phi[x \mapsto v]$ (also written $\phi[v/x]$):** A single frame maps a finite set of identifiers ($\text{dom}(\phi)$) to values ($\text{Val}$, including primitives, locations $\ell \in \text{Loc}$, `null`, or the uninitialized marker `$`). For any identifier $y$, the updated frame $\phi[x \mapsto v]$ (equivalently $\phi[v/x]$ in Barbuti–Mancarella–Turini's notation) satisfies $\phi[x \mapsto v](y) = v$ if $y = x$, and $\phi[x \mapsto v](y) = \phi(y)$ if $y \neq x$. If $x \notin \text{dom}(\phi)$, this extends the frame with a new binding (used by variable declarations); if $x \in \text{dom}(\phi)$, it overrides the old value (used by assignments).
- **Environment stack $\sigma = \rho_1 \cdot \rho_2 \cdots \rho_k$ (or $\phi_n.\dots.\phi_1.\Omega$) lookup $\sigma(x)$:** When blocks or method activations nest, the state $\sigma$ is a sequence of frames with $\rho_1$ (or $\phi_n$) as the **innermost (topmost)** active frame. Looking up $\sigma(x)$ searches from innermost to outermost frame so that the most recent declaration shadows outer ones: $(\rho_1 \cdot \sigma')(x) = \rho_1(x)$ if $x \in \text{dom}(\rho_1)$ (i.e. $\rho_1(x) \neq \perp$), $(\rho_1 \cdot \sigma')(x) = \sigma'(x)$ if $x \notin \text{dom}(\rho_1)$, and $\Omega(x) = \perp$.
- **Environment stack update $\sigma[x \mapsto v]$ (or $\sigma[v/x]$):** Assigning to an existing variable `x = e` updates the **first (innermost) frame** in $\sigma$ where $x$ is already bound, leaving all other frames untouched: $(\rho_1 \cdot \sigma')[x \mapsto v] = \rho_1[x \mapsto v] \cdot \sigma'$ if $x \in \text{dom}(\rho_1)$, and $\rho_1 \cdot (\sigma'[x \mapsto v])$ if $x \notin \text{dom}(\rho_1)$. By contrast, a **declaration** `T x = v;` always extends the topmost frame $\rho_1$ directly as $(\rho_1[x \mapsto v]) \cdot \sigma'$, even if an outer frame in $\sigma'$ already binds $x$ (lexical shadowing).
- **Heap lookup $\theta(\ell)$ and update $\theta[\ell \mapsto (C, \phi')]$ (written $\zeta$ in chapters 05–07):** The heap maps abstract object locations $\ell \in \text{Loc}$ to objects $(C, \phi)$, where $C$ is the runtime class tag and $\phi$ is the object's field frame. Reading a field `e.f` evaluates $e$ to $\ell$, looks up $\theta(\ell) = (C, \phi)$, and returns $\phi(f)$. Writing a field `e1.f = e2` updates only the field frame inside the heap at $\ell$ to $\theta[\ell \mapsto (C, \phi[f \mapsto v])]$, leaving the stack $\sigma$ unchanged.

## Example

```
Suppose the stack σ has two frames (innermost ρ₁ on the left, outer ρ₂ on the right) and heap θ has one object:
  σ = ρ₁ · ρ₂ · Ω    where ρ₁ = { x ↦ 100 },  ρ₂ = { x ↦ 10, y ↦ 20, p ↦ ℓ₀ }
  θ = { ℓ₀ ↦ (Point, { x ↦ 3, y ↦ 4 }) }

1. Stack lookup σ(x) and σ(y):
   σ(x) = ρ₁(x) = 100                 (found in innermost frame ρ₁; shadows ρ₂(x) = 10)
   σ(y) = ρ₂(y) = 20                  (x ∉ dom(ρ₁), so lookup falls through to ρ₂)

2. Stack assignment update σ[y ↦ 120]  (from executing y = y + x;):
   y ∉ dom(ρ₁), so ρ₁ is unchanged and ρ₂ is updated:
   σ[y ↦ 120] = { x ↦ 100 } · { x ↦ 10, y ↦ 120, p ↦ ℓ₀ } · Ω

3. Popping the block frame ρ₁ on block exit:
   σ_after = ρ₂′ · Ω = { x ↦ 10, y ↦ 120, p ↦ ℓ₀ } · Ω
   Now σ_after(x) = 10 (inner x is gone), while y = 120 persists!

4. Heap field update θ[ℓ₀ ↦ (Point, ϕ[x ↦ 99])]  (from executing p.x = 99;):
   σ(p) = ℓ₀,  θ(ℓ₀) = (Point, { x ↦ 3, y ↦ 4 })
   θ′ = { ℓ₀ ↦ (Point, { x ↦ 99, y ↦ 4 }) }   (stack σ is completely unchanged)
```

## Notes

- **Notation equivalence across chapters and textbooks:** The notes in `04-Java-Fundamentals` follow Barbuti–Mancarella–Turini's notation ($\phi$ for a frame, $\sigma[v/x]$ for substitution, $\rho_c$ for the class environment, $\zeta$ for the heap), which is completely isomorphic to standard programming-language semantics notation ($\rho$ for a frame, $\sigma[x \mapsto v]$ for functional override, $\Delta$ for the class table, $\theta$ for the heap). Both notations are listed side by side across the reference entries in `08-Reference/`.
- **Why $\sigma$ and $\theta$ must both exist:** If objects were stored directly inside $\sigma$, copying an object variable (`q = p`) or passing an object to a method would copy the entire field map, breaking aliasing, and objects created inside a block or method would be destroyed when the top frame $\rho_1$ is popped. Storing $\ell \in \text{Loc}$ in $\sigma$ and $(C, \phi)$ in $\theta$ decouples variable lifetime (LIFO stack) from object lifetime (heap reachability).

## See also

- [[Java-Fundamentals-Reference|Reference]]
- [[State-And-Expressions]]
- [[Commands-And-Control-Flow]]
- [[Declarations-And-Scope]]
- [[Classes-And-Objects]]
- [[Nested-Blocks-And-Shadowing]]
- [[Objects-On-The-Heap]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
