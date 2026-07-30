---
tags: [fundamentals]
aliases: ["Classes", "Objects", "Heap", "References", "new"]
created: 2026-07-30
---

# Classes And Objects

## In short

A **class** is a template: a set of instance-variable declarations plus method definitions. An **object** is one live instance of that template, modelled as a pair `(class name, frame)` — the frame being the object's own state (its instance variables). Objects don't live on the stack; they live in the **heap** ζ, a table from **locations** (references) to object representations. A variable of class type holds only a **reference** (an arrow into the heap), not the object — the single most important distinction in the whole model, and the one that explains aliasing, `null`, and identity. Creating the object is `new`; declaring the variable only reserves a slot to point with.

## Explanation

### Three semantic structures

Objects need the state to grow from a stack into a **triple** `⟨ρc, σ, ζ⟩`:

- **ρc — the class environment** ("the library"): maps each class name to `(instance-var frame template, method environment)`. Built once when the program's class declarations are processed, then never changed. See [[Memory-Model]].
- **σ — the stack of frames**: local/parameter variables, as before ([[Declarations-And-Scope]]).
- **ζ — the heap**: `Loc → (Ide × Φ)`, i.e. each live object is stored as `(class, frame)` at some location.

### Declaring a class populates ρc

```
class Foo { int x; int y; <methods> }
```

processing this adds `Foo ↦ (ϕ_Foo, ρ_m)` to ρc, where `ϕ_Foo = {x ↦ $, y ↦ $}` is the fresh-object template and `ρ_m` is its method table (see [[Methods-And-Recursion]]). This is the "library" entry consulted every time a `Foo` is created.

### `new` allocates in the heap and returns a reference

```
  ρc(c) = (ϕ, ρm)    l = newloc(ζ)
  ─────────────────────────────────────      (fresh location l, object (c,ϕ) stored there, l returned)
  ⟨new c, ⟨ρc,σ,ζ⟩⟩ →new ⟨l, ζ[(c,ϕ)/l]⟩
```

`newloc(ζ)` picks an unused location. The **value** of `new Foo` is the location `l` — a reference — and the heap now maps `l` to a fresh `(Foo, {x↦$, y↦$})`.

### A variable holds a reference, not the object

```
Foo myobj = new Foo;       // stack: myobj ↦ l ;  heap: l ↦ (Foo,{x↦$,y↦$})
```

The stack frame binds `myobj` to the location `l`; the object itself sits in the heap. Declaring `Foo other;` without `new` binds `other ↦ null`, the empty reference. Two variables can hold the *same* `l` (aliasing): mutating through one is visible through the other, because they name one heap object.

### Reading and writing instance variables goes through the heap

```
  ⟨E,σ⟩→v   ζ(σ(o)) = (c,ϕ)   ϕ′ = ϕ[v/x]                 ζ(σ(o)) = (c,ϕ)
  ────────────────────────────────────────  (o.x = E;)    ─────────────────  (o.x)
  ⟨o.x = E;, …⟩ → ⟨σ, ζ[(c,ϕ′)/σ(o)]⟩                      ⟨o.x, …⟩ → ϕ(x)
```

`o.x = E;` follows `o`'s reference `σ(o)` into the heap, gets the object `(c, ϕ)`, updates its frame, and writes the object back. Crucially the **stack is unchanged** — only the heap moves. That's why passing an object into a method lets the method mutate it (the reference is copied, the object is shared).

### Worked example

```
Foo o1 = new Foo;  Fie o2 = new Fie;
o1.x = 5;  o2.x = 10;  o1.y = o1.x + o2.x;   // o1 = (Foo,{x↦5, y↦15}), o2 = (Fie,{x↦10})
```

`o1` and `o2` hold two distinct locations; the final assignment reads two heap objects and writes back into `o1`'s.

> [!tip] Connection to Dalvik
> This is the model behind smali object handling, almost one-to-one:
> - **`new` = `new-instance` + a `<init>` call.** `new-instance v0, LFoo;` allocates the heap object (the `(Foo, template)` here); the following `invoke-direct {v0}, LFoo;-><init>()V` runs the constructor. `new-instance` alone is `⟨new c⟩ → l`.
> - **A reference is an object register.** `v0` holding the result of `new-instance`, moved with `move-object`, compared with `if-eqz` (that's the `null` check), is exactly a variable bound to a location `l`.
> - **`o.x` = `iget`/`iput`.** `iget v1, v0, LFoo;->x:I` is `⟨o.x⟩ → ϕ(x)`; `iput v1, v0, LFoo;->x:I` is the heap-update rule. Static fields (`sget`/`sput`) target a per-class frame instead. See [[Classes]], [[Types]], and [[Dalvik-Instructions]] in [[Dalvik-Bytecode]].
> - **ρc, the class environment, is the loaded-classes table** — the dex's class definitions as resolved by a `ClassLoader`. Reflection and dynamic class loading (see [[Reflection-and-Runtime-Internals]]) are literally operations on ρc at runtime.

## More examples

- [[Objects-On-The-Heap]] — the two-object worked example above, drawn as stack + heap, mapped to smali.

## See also

- [[Declarations-And-Scope]] — the stack half of the state.
- [[Methods-And-Recursion]] — the method environment part of a class, and how `this` names the receiver reference.
- [[Memory-Model]] — heap vs. stack vs. class environment as memory regions.
- [[Classes]] and [[Memory-And-Data-Structures]] in [[Dalvik-Bytecode]]/[[ARM64-Android]] — object layout in bytecode and in native memory.

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]

## Flashcards
#flashcards

What does a variable of class type actually hold — the object or something else?::A reference (a location into the heap), not the object itself; the object `(class, frame)` lives in the heap, and several variables can hold the same reference (aliasing).
How is an object modelled, and where does it live?::As a pair `(class name, frame)` — the frame being its instance variables — stored in the heap ζ at a location produced by `new`.
When you execute `o.x = E;`, which part of the state changes — stack or heap?::Only the heap: you follow `o`'s reference to the object, update the object's frame, and write it back; the stack binding for `o` is unchanged.
Map `new`, an object reference, and `o.x` to Dalvik.::`new` ≈ `new-instance` (+ `<init>`); a reference is an object register (`move-object`, `if-eqz` null-check); `o.x` read/write are `iget`/`iput` (static fields: `sget`/`sput`).
