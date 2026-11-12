---
tags: [example]
level: 1
aliases: ["Java is pass-by-value", "parameter passing semantics"]
created: 2026-11-12
---

# Example: Pass-By-Value-Of-References

> [!info] Level 1 — basics
> One idea: a call binds each formal parameter to the *value* of the actual argument in a fresh frame — for objects that value is a location, so the callee can change the object but never the caller's variable.

## Goal

Trace two methods — one that mutates its argument's field, one that reassigns its parameter — and see which change the caller observes. Belongs to [[Methods-And-Recursion]].

## Program

```java
class Box { int v; }
static void bump(Box b)  { b.v = b.v + 1; }        // mutates the object
static void swap(Box b)  { b = new Box(); b.v = 99; }  // rebinds the parameter

Box x = new Box();  x.v = 1;
bump(x);            // x.v == 2
swap(x);            // x.v still 2
```

## Trace

```
caller:   σ = {x ↦ ℓ₀}                     θ = {ℓ₀ ↦ (Box, {v↦1})}

bump(x):  ρ_call = {b ↦ ℓ₀}                (formal b ← value of x = ℓ₀)
          b.v = b.v + 1  (field-write)      θ = {ℓ₀ ↦ (Box, {v↦2})}
          return: caller σ = {x ↦ ℓ₀}       ← change visible through x

swap(x):  ρ_call = {b ↦ ℓ₀}
          b = new Box()  (assign)           ρ_call = {b ↦ ℓ₁}      θ += ℓ₁ ↦ (Box, {v↦0})
          b.v = 99                          θ(ℓ₁) = (Box, {v↦99})
          return: ρ_call discarded          caller σ = {x ↦ ℓ₀}, θ(ℓ₀).v = 2   ← x untouched
```

## Step by step

1. **`(method-call)` builds `ρ_call` from values.** Each actual argument is evaluated in the caller's state, and the formal is bound to the result in a *new* frame ([[Object-And-Method-Semantics-Rules]]). There is no link back to the caller's variable.
2. **Objects arrive as locations.** `b ↦ ℓ₀` and `x ↦ ℓ₀` are aliases for the duration of the call ([[Aliasing-Two-References-One-Object]]), so writes to `ℓ₀`'s fields persist after the call — the heap θ is passed back.
3. **Rebinding a parameter only changes `ρ_call`.** `b = new Box()` updates the callee's frame, which the rule throws away on return. The caller's frame was never in scope.
4. **So Java is always pass-by-value** — "pass-by-reference" behavior for objects is just pass-by-value of a reference.
5. **In bytecode** the callee's parameters are its own registers `p0…pN`; writing `p0` (as `swap` does) never affects the caller's `vX`.

## Compiled

```smali
.method static swap(LBox;)V
    .locals 1
    new-instance p0, LBox;                 # b = new Box()  — overwrites the callee's own p0
    invoke-direct {p0}, LBox;-><init>()V
    const/16 v0, 0x63
    iput v0, p0, LBox;->v:I
    return-void
.end method
```

## Compared with real code

- [[Overload-Forwarding-Call-In-PressReader]] — a real call that passes its parameters straight through to another method's fresh frame.
- [[Builder-Field-Initializers-And-Aliasing-In-PressReader]] in [[Classes-And-Objects]] — a real mutation through an aliasing reference.

## See also

- [[Methods-And-Recursion]]
- [[A-Method-Call-Frame]]
- [[Static-Method-Frames-Without-This]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
