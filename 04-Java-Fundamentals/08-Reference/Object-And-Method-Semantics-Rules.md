---
tags: [reference, reference-entry]
category: "rules"
created: 2026-11-11
---

# Object-And-Method-Semantics-Rules

## Signature / syntax

```
Program configuration:  (Δ, σ, θ)   or   ⟨ρc, σ, ζ⟩
  Δ (or ρc) : ClassName ⇀ (FieldTemplate × MethodTable)      (class environment / library)
  σ         : FrameStack                                      (stack of activation/block frames)
  θ (or ζ)  : Loc ⇀ (ClassName × Frame)                       (heap mapping locations ℓ to objects)

Object Allocation (new C()):
   Δ(C) = (ϕ_init, ρₘ)    ℓ = newloc(θ)    θ′ = θ[ℓ ↦ (C, ϕ_init)]
  ────────────────────────────────────────────────────────────────── (new)
                 ⟨new C(), (Δ, σ, θ)⟩ →_new ⟨ℓ, θ′⟩

Field Read (e.f):
   ⟨e, (Δ, σ, θ)⟩ →ₑ ℓ    ℓ ≠ null    θ(ℓ) = (C, ϕ)    ϕ(f) = v    v ≠ $
  ──────────────────────────────────────────────────────────────────────── (field-read)
                          ⟨e.f, (Δ, σ, θ)⟩ →ₑ v

Field Write (e₁.f = e₂;):
   ⟨e₁, (Δ, σ, θ)⟩ →ₑ ℓ    ℓ ≠ null    ⟨e₂, (Δ, σ, θ)⟩ →ₑ v
   θ(ℓ) = (C, ϕ)           ϕ′ = ϕ[f ↦ v]    θ′ = θ[ℓ ↦ (C, ϕ′)]
  ──────────────────────────────────────────────────────────────────────── (field-write)
                   ⟨e₁.f = e₂;, (Δ, σ, θ)⟩ →_c ⟨σ, θ′⟩

Method Invocation (e₀.m(e₁, …, eₙ)):
   ⟨e₀, (Δ, σ, θ)⟩ →ₑ ℓ    ℓ ≠ null    θ(ℓ) = (C, ϕ_obj)
   Δ(C) = (ϕ_init, ρₘ)     ρₘ(m) = ((x₁, …, xₙ), B)
   ⟨e₁, (Δ, σ, θ)⟩ →ₑ v₁   …   ⟨eₙ, (Δ, σ, θ)⟩ →ₑ vₙ
   ρ_call = ω[this ↦ ℓ, x₁ ↦ v₁, …, xₙ ↦ vₙ]
   ⟨B, (Δ, ρ_call · Ω, θ)⟩ →_c ⟨σ_end, θ′⟩
  ──────────────────────────────────────────────────────────────────────── (method-call)
               ⟨e₀.m(e₁, …, eₙ), (Δ, σ, θ)⟩ →_c ⟨σ, θ′⟩
```

## Description

Consolidated quick-reference of the big-step operational semantics rules over the three-region configuration $(\Delta, \sigma, \theta)$ — written $\langle \rho_c, \sigma, \zeta \rangle$ in [[Classes-And-Objects]], [[Methods-And-Recursion]], and [[Memory-Model]] — covering heap allocation, instance field access, and method invocation:

- **Object allocation (`(new)`):** Looks up class $C$ in the class environment $\Delta$ (or $\rho_c$) to obtain its initial instance-field template $\phi_{\text{init}} = \{f_1 \mapsto \$, \dots, f_k \mapsto \$\}$, allocates a fresh location $\ell = \text{newloc}(\theta) \notin \text{dom}(\theta)$, binds $\ell \mapsto (C, \phi_{\text{init}})$ in the updated heap $\theta'$, and returns the reference $\ell$ as the expression's value.
- **Field read (`(field-read)`):** Evaluates the receiver expression $e$ to a heap location $\ell \neq \texttt{null}$, dereferences $\theta(\ell) = (C, \phi)$ in the heap, and returns the field value $\phi(f)$ (provided it has been initialized, $\phi(f) \neq \$$). If $e$ evaluates to `null`, the side condition $\ell \neq \texttt{null}$ fails and the configuration is **blocked** (modelling `NullPointerException`).
- **Field write (`(field-write)`):** Evaluates the receiver $e_1$ to $\ell \neq \texttt{null}$ and the right-hand side $e_2$ to $v$, looks up $\theta(\ell) = (C, \phi)$, and updates the object's frame in the heap to $\phi' = \phi[f \mapsto v]$. Crucially, the stack $\sigma$ in the conclusion $\langle \sigma, \theta' \rangle$ is **unchanged** — field assignments mutate the heap $\theta$, never stack bindings.
- **Method invocation (`(method-call)`):** Evaluates the receiver $e_0$ to a location $\ell \neq \texttt{null}$, finds the receiver's dynamic class $C$ from $\theta(\ell) = (C, \phi_{\text{obj}})$, looks up method $m$ in $\Delta(C)$'s method table $\rho_m$ to get formal parameters $(x_1, \dots, x_n)$ and body block $B$, evaluates actual arguments $e_1, \dots, e_n$ to values $v_1, \dots, v_n$, builds a fresh activation frame $\rho_{\text{call}} = \{ \texttt{this} \mapsto \ell, x_1 \mapsto v_1, \dots, x_n \mapsto v_n \}$, executes $B$ against that activation frame, and on return restores the caller's stack $\sigma$ while keeping the updated heap $\theta'$.

## Example

```
Given class Counter { int count; void add(int d) { this.count = this.count + d; } } in Δ:

1. Counter c = new Counter();
   - (new) picks fresh ℓ₀, sets θ₁ = { ℓ₀ ↦ (Counter, { count ↦ $ }) }, returns ℓ₀.
   - (decl-init) binds c ↦ ℓ₀ in σ₁ = { c ↦ ℓ₀ } · Ω.

2. c.count = 10;
   - (field-write) resolves σ₁(c) = ℓ₀, updates θ₁(ℓ₀) to θ₂ = { ℓ₀ ↦ (Counter, { count ↦ 10 }) }.
   - Stack σ₁ = { c ↦ ℓ₀ } · Ω is unchanged.

3. c.add(5);
   - (method-call) evaluates receiver c → ℓ₀, argument 5 → 5.
   - Builds activation frame ρ_call = { this ↦ ℓ₀, d ↦ 5 }.
   - Executes body this.count = this.count + d:
     (field-read) reads θ₂(ℓ₀).count = 10; adds d = 5 → 15;
     (field-write) updates θ₂(ℓ₀) to θ₃ = { ℓ₀ ↦ (Counter, { count ↦ 15 }) }.
   - Pops ρ_call and returns ⟨σ₁, θ₃⟩.
```

## Notes

- **Dynamic dispatch via $\theta(\ell) = (C, \phi_{\text{obj}})$:** Notice that `(method-call)` looks up the method $m$ in $\Delta(C)$ where $C$ is the **runtime class tag stored in the heap object $\theta(\ell)$**, not the static type of the expression $e_0$. This single lookup step is the semantic foundation of virtual method dispatch (`invoke-virtual` in Dalvik).
- **Dalvik and Frida correspondence:** In [[Dalvik-Bytecode]] (see [[Classes]], [[Methods]], [[Smali-Exercises]]), `(new)` is `new-instance` + `invoke-direct <init>`, `(field-read)` is `iget*`, `(field-write)` is `iput*`, and `(method-call)` is `invoke-*` where register `p0` holds `this` ($\ell$) and `p1..pN` hold $v_1, \dots, v_n$. In [[Frida-Dynamic-Instrumentation]], hooking `Counter.add.implementation = function(d) { ... }` intercepts `(method-call)` right as $\rho_{\text{call}}$ is formed, with JS `this` bound to $\ell$ and `d` bound to $v_1$, while `Java.choose("Counter", ...)` scans $\text{dom}(\theta)$ for all live locations $\ell$ tagged with class `Counter`.

## See also

- [[Java-Fundamentals-Reference|Reference]]
- [[Classes-And-Objects]]
- [[Methods-And-Recursion]]
- [[Memory-Model]]
- [[Objects-On-The-Heap]]
- [[A-Method-Call-Frame]]
- [[Tracing-A-Value-Through-The-Three-Regions]]
- [[State-And-Environment-Substitution]]
- [[Command-Semantics-Rules]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
