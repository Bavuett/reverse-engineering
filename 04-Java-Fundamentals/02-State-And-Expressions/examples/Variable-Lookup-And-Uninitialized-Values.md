---
tags: [example]
level: 1
aliases: ["ide rule", "uninitialized variable semantics", "bottom vs dollar"]
created: 2026-11-12
---

# Example: Variable-Lookup-And-Uninitialized-Values

> [!info] Level 1 — basics
> One idea: looking up a variable can fail in two distinct ways — the name isn't in scope (`⊥`), or it's declared but has no value yet (`$`) — and the `(ide)` rule refuses both.

## Goal

Evaluate variable lookups in a state that contains a declared-but-unassigned variable, and see how Java and Dalvik handle each failure. Belongs to [[State-And-Expressions]].

## State

```
σ = { a ↦ 4, b ↦ $ }          (b declared with "int b;" but not yet assigned)
σ(a) = 4      σ(b) = $      σ(c) = ⊥   (c never declared)
```

## Lookups

```
  σ(a) = 4    4 ∉ {⊥, $}
  ──────────────────────── (ide)        ⟨a, σ⟩ →ₑ 4
       ⟨a, σ⟩ →ₑ 4

  σ(b) = $    $ ∉ {⊥, $}  ✗              ⟨b, σ⟩ blocked   → ⟨a + b, σ⟩ blocked too
  σ(c) = ⊥    ⊥ ∉ {⊥, $}  ✗              ⟨c, σ⟩ blocked

After  b = a * 2;   (assign):   σ′ = { a ↦ 4, b ↦ 8 }   and now ⟨a + b, σ′⟩ →ₑ 12
```

## Step by step

1. **A state is a partial function** from identifiers to values. `⊥` means "no binding": the identifier is outside `dom(σ)`. `$` is a real binding to a special *uninitialized* marker, created by a declaration without initializer ([[Declaration-Without-Initializer]]).
2. **`(ide)` has a side condition**: the looked-up value must be neither `⊥` nor `$`. Otherwise no rule applies and the expression is blocked ([[Blocked-Configurations-And-Runtime-Errors]]).
3. **Blocking propagates** through strict operators: `a + b` needs both operands, so it's blocked whenever `b` is.
4. **Java rejects both cases at compile time.** `c` → "cannot find symbol" (scope); `b` → "variable b might not have been initialized" (definite assignment). So well-typed Java never executes a blocked lookup — the semantics explains *why* those compile errors exist.
5. **Dalvik has no `$` marker.** A register holding a never-assigned local simply contains garbage; the bytecode verifier rejects code that reads such a register, which is the bytecode-level counterpart of definite assignment.

## Compiled

```smali
const/4 v0, 0x4               # a = 4
# int b;  -> no instruction at all: a declaration without initializer emits nothing
mul-int/lit8 v1, v0, 0x2      # b = a * 2   (v1 first written here)
add-int v2, v0, v1            # a + b
```

## Compared with real code

- [[Conditional-Expression-In-PressReader-Html-Encode]] — a real method whose single parameter is looked up three times, once per branch it might take.
- [[Branch-Assigned-Locals-In-PressReader-HttpUrl-Builder]] in [[Declarations-And-Scope]] — a real local declared without initializer and assigned on both branches.

## See also

- [[State-And-Expressions]]
- [[Evaluating-Expressions-In-A-State]]
- [[State-And-Environment-Substitution]]
- [[Expression-Semantics-Rules]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
