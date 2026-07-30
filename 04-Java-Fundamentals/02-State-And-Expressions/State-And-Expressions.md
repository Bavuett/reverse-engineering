---
tags: [fundamentals]
aliases: ["State", "Frame", "Expression Evaluation"]
created: 2026-07-30
---

# State And Expressions

## In short

The value of an expression like `x + 2` depends on what `x` holds — so evaluation needs a **state**. In its simplest form a state is a **frame** ϕ: a finite partial function from identifiers to values, `ϕ : Ide ⇀ Val`. `ϕ(x)` is the value bound to `x`; `ϕ(x) = ⊥` means `x` is unbound. Expression evaluation becomes a big-step transition over configurations `⟨E, ϕ⟩`, written `E[[E]]ϕ = k ⟺ ⟨E, ϕ⟩ → k`. This frame — one table of name→value bindings — is the atom the whole memory model is built from, and it's the direct analogue of a Dalvik method's register array.

## Explanation

### The state as a function

A frame is just a lookup table:

```
ϕ = {x ↦ 5, y ↦ 2}     ϕ(x) = 5, ϕ(y) = 2, ϕ(z) = ⊥ (unbound)
```

Real programs bind only a handful of names, so ϕ is *partial* — defined on the few identifiers in scope, undefined everywhere else. The empty frame is ω (everything ⊥).

### Evaluating expressions, guided by syntax

The rules follow the grammar `Exp ::= Const | Ide | (Exp) | Exp Op Exp | !Exp`. One rule per syntactic case; a value in the state is looked up, a constant evaluates to itself, and a compound expression evaluates its sub-expressions first:

```
                         ϕ(x) = n
  ⟨n, ϕ⟩ → n           ─────────────           (a constant is itself; a variable is a lookup)
  (const)              ⟨x, ϕ⟩ → n  (ide)

  ⟨E, ϕ⟩ → n    ⟨E′, ϕ⟩ → n′    m = n + n′
  ─────────────────────────────────────────      (arithmetic: evaluate both sides, then combine)
              ⟨E + E′, ϕ⟩ → m
```

The same shape covers `*`, `-` (with side condition `n ≥ n′` to stay in the naturals), `/` and `%` (side condition `n′ ≠ 0`), the relational operators (`==`, `<`, …, producing a boolean), and the boolean connectives `&&`, `||`, `!`. Booleans are values too: `⟨true, ϕ⟩ → tt`, `⟨false, ϕ⟩ → ff`.

### Side conditions carve out "no value"

`5 - 8` over the naturals, or `x / 0`, simply have **no** applicable rule instance — the configuration is *blocked* (see [[Commands-And-Control-Flow]]). Whether a configuration is blocked can depend on the state: `⟨x / y, ϕ⟩` is blocked exactly when `ϕ(y) = 0`.

### Worked example

With `ϕ(x) = 5, ϕ(y) = 2`, evaluate `(x + 8) / y`:

```
  ⟨x,ϕ⟩→5   ⟨8,ϕ⟩→8   13 = 5+8
  ────────────────────────────         ⟨y,ϕ⟩→2   2 ≠ 0   6 = 13 div 2
     ⟨x+8, ϕ⟩ → 13  → ⟨(x+8),ϕ⟩→13    ─────────────────────────────────
                                                ⟨(x+8)/y, ϕ⟩ → 6
```

The result `6` is `E[[(x+8)/y]]ϕ`.

> [!tip] Connection to Dalvik
> A frame **is** a Dalvik method's register file. When ART runs a method it allocates an array of registers `v0, v1, …` (plus parameter registers `p0, p1, …`); each register is one binding in the frame, and evaluating an expression is a short run of opcodes that leaves the result in a register — `const/4 v0, 0x8` then `add-int v0, p1, v0` is precisely `⟨x + 8⟩ → 13` with `p1 = x`. A variable read `ϕ(x)` is just "the value currently in the register holding `x`". See [[Registers]] in [[Dalvik-Bytecode]] for the concrete register model this abstracts.

## More examples

- [[Deriving-An-Arithmetic-Expression]] — a full evaluation derivation with a state.

## See also

- [[Operational-Semantics]] — the rule notation used here.
- [[Commands-And-Control-Flow]] — where expressions get *used* to change the state.
- [[Registers]] in [[Dalvik-Bytecode]] — the concrete register array a frame corresponds to.

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]

## Flashcards
#flashcards

What is a frame, formally?::A finite partial function ϕ : Ide ⇀ Val from identifiers to values — one table of name→value bindings, undefined (⊥) on names not in scope.
Why does expression evaluation need a state at all?::Because the value of an expression containing names (e.g. `x + 2`) depends on the values bound to those names; the state supplies them via `ϕ(x)`.
What does it mean for a configuration like `⟨x / y, ϕ⟩` to be blocked, and why can it be state-dependent?::No transition rule applies (no value exists) — for division that happens exactly when `ϕ(y) = 0`, so the same expression is blocked in some states and not others.
How does a frame correspond to something in Dalvik?::It's the method's register array (`v0,v1,…`, `p0,p1,…`): each binding name↦value is one register holding a value, and a variable read is "read the register holding that name".
