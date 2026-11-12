---
tags: [example]
level: 2
aliases: ["virtual dispatch semantics", "overriding semantics", "runtime class lookup"]
created: 2026-11-12
---

# Example: Dynamic-Dispatch-Through-Overriding

> [!info] Level 2 — intermediate
> Combines inheritance with the `(method-call)` rule: the method body is looked up in the class stored *in the heap object* (`θ(ℓ) = (C, …)`), not in the variable's declared type — and that one premise is the whole of dynamic dispatch.

## Goal

Derive which `speak()` runs for `Animal a = new Dog(); a.speak();`, extend the class environment with inheritance, and see why `invoke-virtual` and `invoke-super` differ. Belongs to [[Classes-And-Objects]].

## Program

```java
class Animal { String speak() { return "..."; } }
class Dog extends Animal { String speak() { return "Woof"; } }

Animal a = new Dog();     // static type Animal, runtime class Dog
String s = a.speak();
```

## Class environment with inheritance

```
Δ(Animal) = (ϕ_A, { speak ↦ ((), return "...") })
Δ(Dog)    = (ϕ_D, { speak ↦ ((), return "Woof") })      super(Dog) = Animal

lookup(C, m) = ρₘ(m)                 if Δ(C) = (_, ρₘ) and m ∈ dom(ρₘ)
             = lookup(super(C), m)   otherwise
```

## Derivation

```
(new)          new Dog()  →  ℓ₀,   θ = {ℓ₀ ↦ (Dog, ϕ_D)}
(decl-init)    σ = {a ↦ ℓ₀}

  ⟨a, …⟩ →ₑ ℓ₀    ℓ₀ ≠ null    θ(ℓ₀) = (Dog, ϕ_D)    lookup(Dog, speak) = ((), return "Woof")
  ρ_call = ω[this ↦ ℓ₀]        ⟨return "Woof", ρ_call · Ω, θ⟩ ⟶ "Woof"
  ──────────────────────────────────────────────────────────────────────────── (method-call)
                         ⟨a.speak(), (Δ, σ, θ)⟩ →ₑ "Woof"
```

The declared type `Animal` appears nowhere in the derivation.

## Step by step

1. **The class comes from the object.** `(method-call)` reads `C` from `θ(ℓ)`; `new Dog()` stored the tag `Dog` there. Every call on that object, through any variable of any declared type, finds `Dog`.
2. **Lookup walks up the superclass chain** until a class defines the method. `Dog` defines `speak`, so the search stops immediately; a method `Dog` doesn't override would be found in `Animal`.
3. **The static type matters only at compile time** — it decides whether `a.speak()` is legal (does `Animal` have `speak`?) and which method *signature* is meant, not which *body* runs.
4. **`invoke-virtual` implements this**: the runtime class's vtable is consulted. **`invoke-super`** deliberately skips it, starting the lookup at the superclass of the *caller's* class — that's how `super.speak()` reaches `Animal`'s version.
5. **Static, private, and constructor calls don't dispatch** (`invoke-static`, `invoke-direct`): their target is fixed at compile time. `final` methods dispatch formally but can't be overridden, so R8 often turns them into direct calls.

## Compiled

```smali
new-instance v0, LDog;
invoke-direct {v0}, LDog;-><init>()V
invoke-virtual {v0}, LAnimal;->speak()Ljava/lang/String;   # names Animal.speak; runs Dog.speak
move-result-object v1
```

## Compared with real code

- [[Short-Circuit-Equals-In-PressReader-HttpUrl]] — a real override of `Object.equals`/`hashCode`, the methods `HashMap` reaches by dynamic dispatch.
- [[Kotlin-Enum-Entries-In-PressReader]] in [[Dalvik-Bytecode]] — a real enum: every constant is an object whose runtime class (`.super Ljava/lang/Enum;`) supplies inherited methods like `name()` and `ordinal()`.
- [[Inheritance-And-Super-Calls]] in [[Dalvik-Bytecode]] — the same `Animal`/`Dog` shape in smali, with `invoke-super`.

## See also

- [[Classes-And-Objects]]
- [[Object-And-Method-Semantics-Rules]]
- [[Constructor-Execution-Order]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
