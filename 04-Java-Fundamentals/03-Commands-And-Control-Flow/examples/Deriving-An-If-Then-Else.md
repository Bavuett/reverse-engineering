---
tags: [example]
level: 1
aliases: ["if-tt if-ff derivation", "conditional command derivation"]
created: 2026-11-12
---

# Example: Deriving-An-If-Then-Else

> [!info] Level 1 — basics
> One idea: an `if` command evaluates its guard once and then runs exactly one branch; the derivation tree for the untaken branch simply doesn't exist.

## Goal

Derive `if (x > y) m = x; else m = y;` (the maximum of two numbers) in two states, and match each derivation to the path through the bytecode. Belongs to [[Commands-And-Control-Flow]].

## Derivation in `σ₁ = {x ↦ 7, y ↦ 3, m ↦ 0}`

```
  ⟨x,σ₁⟩→ₑ7  ⟨y,σ₁⟩→ₑ3  (7 > 3) = tt          ⟨x, σ₁⟩ →ₑ 7  (ide)
  ───────────────────────────────── (rel)      ─────────────────────────────── (assign)
        ⟨x > y, σ₁⟩ →ₑ tt                       ⟨m = x;, σ₁⟩ →_c σ₁[m ↦ 7]
  ──────────────────────────────────────────────────────────────────────── (if-tt)
   ⟨if (x > y) m = x; else m = y;, σ₁⟩ →_c {x ↦ 7, y ↦ 3, m ↦ 7}
```

## Derivation in `σ₂ = {x ↦ 2, y ↦ 5, m ↦ 0}`

```
        ⟨x > y, σ₂⟩ →ₑ ff  (rel)                ⟨m = y;, σ₂⟩ →_c σ₂[m ↦ 5]  (assign)
  ──────────────────────────────────────────────────────────────────────── (if-ff)
   ⟨if (x > y) m = x; else m = y;, σ₂⟩ →_c {x ↦ 2, y ↦ 5, m ↦ 5}
```

## Compiled

```smali
# x in v0, y in v1, m in v2
if-le v0, v1, :else           # NOT (x > y) -> else branch
move v2, v0                   # then: m = x
goto :end
:else
move v2, v1                   # else: m = y
:end
```

## Step by step

1. **The guard is evaluated in the initial state**, and its value selects the rule: `tt` → `(if-tt)`, `ff` → `(if-ff)` ([[Command-Semantics-Rules]]).
2. **Each rule has two premises**: the guard's value and *one* branch's execution. The other branch contributes nothing — not even a check that it would terminate.
3. **Both branches start from the same state σ.** The else-branch doesn't see effects of the then-branch, because the then-branch never ran.
4. **The compiler inverts the test.** Java's `x > y` becomes `if-le` ("jump to else if `x <= y`"), so the then-branch can be the fall-through. Reading bytecode, flip the condition back to recover the source guard.
5. **The `goto :end`** skips the else-branch after the then-branch — the bytecode form of "discard the untaken branch".

## Compared with real code

- [[Command-Kind-If-Chain-In-PressReader]] — a real chain of `if`/`else if` commands with early exits.
- [[If-Else-And-Comparisons]] in [[Dalvik-Bytecode]] — the same shape at bytecode level, all comparison opcodes covered.

## See also

- [[Commands-And-Control-Flow]]
- [[Evaluating-A-While-Loop]]
- [[Conditional-Branches]] in [[ARM64-Android]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
