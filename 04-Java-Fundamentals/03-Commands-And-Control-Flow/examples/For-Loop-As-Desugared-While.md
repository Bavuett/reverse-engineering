---
tags: [example]
level: 2
aliases: ["for loop semantics", "for to while desugaring"]
created: 2026-11-12
---

# Example: For-Loop-As-Desugared-While

> [!info] Level 2 — intermediate
> Combines blocks, declarations and `while`: a `for` loop needs no rule of its own — it is a block containing its initializer and a `while` whose body is the original body followed by the update.

## Goal

Desugar `for (int i = 0; i < n; i++) s = s + i;`, derive it for `n = 2`, and recognize the result in bytecode. Belongs to [[Commands-And-Control-Flow]].

## Desugaring

```
for (init; guard; update) body
   ≡
{ init; while (guard) { body; update; } }
```

So our loop is `{ int i = 0; while (i < n) { s = s + i; i = i + 1; } }`.

## Derivation from `σ = {n ↦ 2, s ↦ 0} · Ω`

```
(block)      push ω:                              ω · {n↦2, s↦0} · Ω
(decl-init)  int i = 0;                           {i↦0} · {n↦2, s↦0} · Ω
(while-tt)   i < n → tt;  body: s = 0+0, i = 1    {i↦1} · {n↦2, s↦0} · Ω
(while-tt)   i < n → tt;  body: s = 0+1, i = 2    {i↦2} · {n↦2, s↦1} · Ω
(while-ff)   i < n → ff                           {i↦2} · {n↦2, s↦1} · Ω
(block)      pop {i↦2}:                           {n↦2, s↦1} · Ω
```

(The inner `{ body; update; }` block declares nothing, so its push/pop leaves no trace.)

## Compiled

```smali
# n in v0, s in v1
const/4 v2, 0x0               # init:   i = 0
:loop
if-ge v2, v0, :done           # guard:  exit when !(i < n)
add-int/2addr v1, v2          # body:   s = s + i
add-int/lit8 v2, v2, 0x1      # update: i++
goto :loop                    # back-edge = the recursive premise of (while-tt)
:done
```

## Step by step

1. **The outer block scopes `i`.** Because the initializer lives in the desugared block, `i` disappears when the loop ends — `(block)` pops its frame. That's why `i` can't be used after a `for` loop, but could after a hand-written `int i = 0; while (…)`.
2. **The update runs after the body, every iteration**, as the last command of the `while` body. `continue` (not in the core language) jumps to the update, not to the guard — the desugaring explains why.
3. **Each `(while-tt)` step = one trip around the back-edge.** The bytecode's `goto :loop` is the recursive premise "and then the same `while` again in the new state" ([[Evaluating-A-While-Loop]]).
4. **Guard inverted, at the top.** `i < n` becomes `if-ge … :done`. Some compilers place the test at the bottom (loop rotation) with an initial jump into it; the meaning is the same.
5. **For-each loops desugar one step further**: over arrays to an index loop like this one; over `Iterable` to `Iterator it = …; while (it.hasNext()) { T x = it.next(); body }`.

## Compared with real code

- [[Path-Segment-Loops-In-PressReader-HttpUrl]] — a real index `for` and a real iterator `while` in the same class, both read back to this desugaring.
- [[For-Loop-Over-An-Array]] in [[Dalvik-Bytecode]] — the bytecode view of the same pattern over an array.

## See also

- [[Commands-And-Control-Flow]]
- [[Command-Semantics-Rules]]
- [[Loop-As-Backward-Branch]] in [[ARM64-Android]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
