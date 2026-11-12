---
tags: [example]
level: 2
aliases: ["static call rule", "invoke-static frame", "no receiver"]
created: 2026-11-12
---

# Example: Static-Method-Frames-Without-This

> [!info] Level 2 — intermediate
> Combines the call rule with the absence of a receiver: a static call skips the receiver evaluation and the `this` binding, finds the body by the class named at the call site, and so has no dynamic dispatch and no `p0 = this`.

## Goal

State the static-call rule next to the instance one, trace a static and an instance call side by side, and fix the parameter-register numbering for each. Belongs to [[Methods-And-Recursion]].

## Rule

```
   Δ(C) = (ϕ_C, ρₘ)   ρₘ(m) = ((x₁, …, xₙ), B)
   ⟨e₁, (Δ, σ, θ)⟩ →ₑ v₁  …  ⟨eₙ, (Δ, σ, θ)⟩ →ₑ vₙ
   ρ_call = ω[x₁ ↦ v₁, …, xₙ ↦ vₙ]               ← no "this"
   ⟨B, (Δ, ρ_call · Ω, θ)⟩ →_c ⟨σ_end, θ′⟩
  ─────────────────────────────────────────────── (static-call)
         ⟨C.m(e₁, …, eₙ), (Δ, σ, θ)⟩ →_c ⟨σ, θ′⟩
```

Compared with `(method-call)` ([[Object-And-Method-Semantics-Rules]]): no receiver premise, no `ℓ ≠ null`, and `C` comes from the call's text, not from `θ(ℓ)`.

## Program

```java
class Temp {
    double c;
    static double toF(double c) { return c * 9 / 5 + 32; }   // static
    double asF()                { return toF(this.c); }       // instance, calls the static one
}
```

## Frames for `t.asF()` with `θ(ℓ₀) = (Temp, {c ↦ 20.0})`

```
asF():  ρ_call = {this ↦ ℓ₀}                        registers: p0 = this
  this.c → 20.0 (field-read)
  toF(20.0):  ρ_call′ = {c ↦ 20.0}                  registers: p0:p1 = c (a double: wide pair)
              20.0 * 9 / 5 + 32 = 68.0
  returns 68.0
```

## Compiled

```smali
.method static toF(D)D                  # static: parameters start at p0
    .locals 2
    const-wide/high16 v0, 0x4022000000000000L   # 9.0
    mul-double/2addr v0, p0                     # c * 9
    ...
.end method

.method asF()D                          # instance: p0 = this, parameters from p1
    .locals 2
    iget-wide v0, p0, LTemp;->c:D
    invoke-static {v0, v1}, LTemp;->toF(D)D     # no receiver register in the call
    move-result-wide v0
    return-wide v0
.end method
```

## Step by step

1. **No receiver, no `this`.** A static frame binds only the formals. Inside `toF`, a reference to a *field* `c` wouldn't even compile without an object — the parameter `c` shadows nothing because no `this.c` is in scope.
2. **Name collision resolved by frames.** The instance field `c` lives in the heap object; the static method's parameter `c` lives in its frame. Same name, different regions ([[Memory-Model]]).
3. **No dispatch.** `(static-call)` uses the class written at the call site; subclasses can *hide* a static method but not override it. `invoke-static` names its target exactly.
4. **Register numbering shifts by one.** Instance methods: `p0 = this`, first parameter `p1`. Static methods: first parameter `p0`. Wide types (`long`, `double`) take two registers — here `p0:p1` ([[Wide-Registers-For-Long-And-Double]] in [[Dalvik-Bytecode]]).
5. **Static methods can't block on a null receiver** — there isn't one. That's why utility code (and R8's outliner) prefers static methods.

## Compared with real code

- [[Conditional-Expression-In-PressReader-Html-Encode]] in [[State-And-Expressions]] — a real static method whose only parameter is `p0`.
- [[Synchronized-Block-Locals-In-PressReader]] in [[Declarations-And-Scope]] — `static synchronized`: with no `this` to lock, the class object is the lock.

## See also

- [[Methods-And-Recursion]]
- [[A-Method-Call-Frame]]
- [[Static-Vs-Instance-Methods]] in [[Dalvik-Bytecode]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
