---
tags: [example]
level: 2
aliases: ["&& as conditional expression", "ternary operator semantics", "cond-tt cond-ff"]
created: 2026-11-12
---

# Example: Short-Circuit-As-Nested-Conditionals

> [!info] Level 2 — intermediate
> Combines the short-circuit rules with the conditional expression `b ? e₁ : e₂`: `&&` and `||` are conditional expressions in disguise, which is exactly why they compile to branches rather than to a boolean instruction.

## Goal

Give rules for `b ? e₁ : e₂`, show that `&&`/`||` are derivable from them, and recognize the shape in bytecode. Belongs to [[State-And-Expressions]].

## Rules for the conditional expression

```
   ⟨b, σ⟩ →ₑ tt    ⟨e₁, σ⟩ →ₑ v                ⟨b, σ⟩ →ₑ ff    ⟨e₂, σ⟩ →ₑ v
  ─────────────────────────────── (cond-tt)    ─────────────────────────────── (cond-ff)
     ⟨b ? e₁ : e₂, σ⟩ →ₑ v                        ⟨b ? e₁ : e₂, σ⟩ →ₑ v
```

Only the chosen branch appears as a premise — the other one is never evaluated.

## Desugaring

```
e₁ && e₂   ≡   e₁ ? e₂ : false
e₁ || e₂   ≡   e₁ ? true : e₂
!e         ≡   e ? false : true
```

Check `&&` against [[Expression-Semantics-Rules]]: if `e₁ →ₑ ff`, `(cond-ff)` yields `false →ₑ ff` — that's `(and-ff)`; if `e₁ →ₑ tt`, `(cond-tt)` yields whatever `e₂` gives — that's `(and-tt)`. Same results, same premises.

## Worked example

`y != 0 && x / y > 2` in `σ = {x ↦ 9, y ↦ 0}`:

```
  ⟨y != 0, σ⟩ →ₑ ff   (rel)      ⟨false, σ⟩ →ₑ ff   (const-false)
  ─────────────────────────────────────────────────── (cond-ff)
     ⟨y != 0 ? (x / y > 2) : false, σ⟩ →ₑ ff
```

The blocked `x / y` never appears in the tree.

## Compiled

```smali
# x in v0, y in v1; result in v2
if-eqz v1, :false             # y != 0 ?   (cond-ff path when y == 0)
div-int v2, v0, v1            # only reached when y != 0
const/4 v3, 0x2
if-le v2, v3, :false
const/4 v2, 0x1               # true
goto :end
:false
const/4 v2, 0x0               # false
:end
```

## Step by step

1. **A conditional expression evaluates its guard, then exactly one branch.** That's the semantic content of "short-circuit".
2. **`&&`/`||` need no rules of their own** once `?:` exists — the desugaring is the definition. This is also why `&&` can *guard* an operation that would otherwise block.
3. **No boolean "and" instruction is used.** Dalvik has `and-int`, but compilers don't use it for `&&`, because `and-int` needs both operands evaluated (strict) — wrong semantics when the right operand has effects or can fail.
4. **Recognize it in bytecode** as a chain of conditional branches to a shared `false` (for `&&`) or `true` (for `||`) target, ending in `const/4 vX, 0x1` / `0x0`.
5. **Nested conditionals** (`a ? b : c ? d : e`) produce the same kind of branch chain; jadx often renders such chains back as `?:` or as `if`/`return` sequences, which are equivalent.

## Compared with real code

- [[Conditional-Expression-In-PressReader-Html-Encode]] — a real `?:` compiled to one conditional branch.
- [[Short-Circuit-Equals-In-PressReader-HttpUrl]] — a real `&&` whose left operand guards a cast.

## See also

- [[State-And-Expressions]]
- [[Evaluating-Expressions-In-A-State]]
- [[Short-Circuit-Conditions-And-CCMP]] in [[ARM64-Android]] — the same desugaring in native code

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
