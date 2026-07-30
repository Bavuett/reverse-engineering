---
tags: [fundamentals]
aliases: ["Declarations", "Scope", "Stack Of Frames", "Blocks"]
created: 2026-07-30
---

# Declarations And Scope

## In short

A **declaration** (`int x;`) introduces a name into the state; **nested blocks** are why the state can't stay a single flat frame. To model scope — a name declared in a block is visible in inner blocks and vanishes when the block ends — the state becomes a **stack of frames** σ = ϕₙ.….ϕ₁.Ω. Entering a block pushes a fresh frame; leaving it pops that frame (discarding its locals but keeping changes to outer names). Name lookup walks the stack top-down: the **most recent** binding wins. This stack is the second of the three memory regions and the direct ancestor of a call stack.

## Explanation

### Declarations add bindings

```
  σ = ϕ.σ″    σ′ = ϕ[$/x].σ″                σ = ϕ.σ″    ⟨E,σ⟩→v    σ′ = ϕ[v/x].σ″
  ──────────────────────────  (uninit)      ────────────────────────────────────────  (init)
     ⟨T x;, σ⟩ → σ′                              ⟨T x = E;, σ⟩ → σ′
```

A declaration adds a binding to the **current (top) frame** — either the symbolic "undefined" value `$` (uninitialized `int x;`) or the value of an initializer. The type `T` (`int`/`boolean`) fixes what the variable may hold but is otherwise a job for the *static* semantics (type checking), not this dynamic one.

### A block pushes a frame; leaving pops it

```
  ⟨Slist, ω.σ⟩ → ϕ.σ′
  ─────────────────────      (run the body on a fresh empty frame ω pushed onto σ; on exit, drop it)
  ⟨{Slist}, σ⟩ → σ′
```

Entering `{ … }` pushes an empty frame ω; the block's declarations populate it; on exit the whole top frame is discarded — so **locals cease to exist**, while assignments the block made to *outer* variables survive (they modified a frame further down the stack).

### Lookup and modification walk the stack top-down

```
              ⊥            if σ = Ω
  σ(x) =      ϕ(x)         if σ = ϕ.σ′ and ϕ(x) ≠ ⊥      (most recent binding wins)
              σ′(x)        if σ = ϕ.σ′ and ϕ(x) = ⊥      (else look deeper)
```

`σ[v/x]` modifies the **most recent** frame that binds `x`; if no frame binds `x`, the modification has no effect. So a variable reference always resolves to its nearest enclosing declaration — the operational meaning of lexical scope.

### Worked example (shadowing)

```
{ int x = 10; int y = 20;
  { int x = 100;      // pushes a frame; new x shadows the outer x
    y = y + x; }      // y (outer frame) += 100  → y = 120
  y = y + x; }        // inner x is gone; x resolves to the outer 10 → y = 130
```

The inner `x = 100` lives only in the inner frame; after the block pops, `x` in `y = y + x` sees the outer `10`. (Java itself forbids re-declaring `x` in a nested block — a *static* error — but the runtime model handles it exactly as Algol/Pascal/C do.)

> [!tip] Connection to Dalvik
> Two things map here, and one deliberately doesn't. (1) The **stack of frames** is the ancestor of the JVM/ART **call stack** — every method activation is a frame (see [[Methods-And-Recursion]]). (2) But Dalvik does **not** push a frame per `{ }` block: a method's registers are allocated once for the whole method, and the compiler resolves lexical scope *statically*, reusing register numbers for non-overlapping locals. So when you read smali you won't see block entry/exit — you'll see a flat register file where the *same* `v2` may mean different source variables in different regions. Knowing the scoping rules here is what lets you recover "these two uses of `v2` are actually different locals" when decompiling. The per-activation frame does show up, though: each `invoke-*` pushes a new method frame with its own registers.

## More examples

- [[Nested-Blocks-And-Shadowing]] — a block evaluated frame-by-frame with the graphical stack.

## See also

- [[Commands-And-Control-Flow]] — the commands whose state these frames hold.
- [[Methods-And-Recursion]] — the call stack, the same frame-stack idea for method activations.
- [[Memory-Model]] — the stack as one of the three memory regions.
- [[Registers]] in [[Dalvik-Bytecode]] — why Dalvik uses one flat register file instead of per-block frames.

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]

## Flashcards
#flashcards

Why does the state have to become a stack of frames rather than a single flat table?::To model nested-block scope: a block's local names must be visible in inner blocks and disappear when the block ends, which a stack (push on entry, pop on exit) captures and a single flat table cannot.
When several frames bind the same name, which binding does `σ(x)` return?::The one in the most recent (topmost) frame that has a binding for `x` — lookup walks the stack top-down and stops at the first hit.
What survives a block's exit and what doesn't?::Local variables declared in the block are discarded with its frame; modifications the block made to variables declared in outer (deeper) frames survive.
Does Dalvik push a frame per `{ }` block? What's the consequence for reading smali?::No — registers are allocated once per method and scope is resolved statically, so the same register number can represent different source locals in different regions; recovering that separation is part of decompiling smali.
