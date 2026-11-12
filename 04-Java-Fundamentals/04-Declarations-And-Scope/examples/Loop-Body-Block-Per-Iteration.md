---
tags: [example]
level: 2
aliases: ["fresh variable per iteration", "loop body scope"]
created: 2026-11-12
---

# Example: Loop-Body-Block-Per-Iteration

> [!info] Level 2 — intermediate
> Combines `(block)` with `(while-tt)`: a variable declared inside a loop body is created and destroyed on every iteration — each trip around the loop pushes a fresh frame — which is why it can't carry a value from one iteration to the next.

## Goal

Trace a loop whose body declares a local, and see what changes when the declaration moves outside the loop. Belongs to [[Declarations-And-Scope]].

## Program A — declaration inside the body

```java
int i = 0, last = 0;
while (i < 2) { int sq = i * i; last = sq; i = i + 1; }
```

## Trace from `{i ↦ 0, last ↦ 0} · Ω`

```
(while-tt)  i<2 tt   (block) push ω
                     (decl-init) sq = 0           {sq↦0} · {i↦0, last↦0} · Ω
                     last = 0; i = 1              {sq↦0} · {i↦1, last↦0} · Ω
                     (block) pop                  {i↦1, last↦0} · Ω          ← sq gone
(while-tt)  i<2 tt   (block) push ω
                     (decl-init) sq = 1           {sq↦1} · {i↦1, last↦0} · Ω   ← a *new* sq
                     last = 1; i = 2              {sq↦1} · {i↦2, last↦1} · Ω
                     (block) pop                  {i↦2, last↦1} · Ω
(while-ff)  i<2 ff                                {i↦2, last↦1} · Ω
```

## Program B — declaration hoisted out

```java
int i = 0, last = 0;  int sq;
while (i < 2) { sq = i * i; last = sq; i = i + 1; }
// after the loop: sq is still in scope and holds 1
```

## Step by step

1. **`(while-tt)` executes the body as a command**; the body `{ … }` is a block, so `(block)` pushes a frame at the start of *every* iteration and pops it at the end.
2. **Each `sq` is a new binding** in a new frame. Nothing links the first iteration's `sq` to the second's; the value survives only if copied to an outer variable (`last`).
3. **Hoisting changes scope, not results here.** In program B, `sq` lives in the outer frame, is updated by `(assign)` each time, and remains readable after the loop. For this program both versions compute the same `last` — but B leaks `sq` into the rest of the method.
4. **Same bytecode.** A compiler can emit identical code for A and B: one register for `sq`, rewritten each iteration. The per-iteration frame is a scope fact the machine doesn't need ([[Scope-Vs-Lifetime-In-Registers]]).
5. **Where it becomes observable: closures.** A lambda created in the body captures *that iteration's* variable — so each lambda sees its own value. Java requires captured locals to be effectively final, which the per-iteration declaration satisfies and the hoisted one doesn't.

## Compared with real code

- [[Path-Segment-Loops-In-PressReader-HttpUrl]] in [[Commands-And-Control-Flow]] — real for-each loops whose element variable (`String s = it.next()`) is a fresh per-iteration local.
- [[R8-Merged-Lambdas-Packed-Switch-In-PressReader]] in [[Dalvik-Bytecode]] — what captured variables become in compiled lambdas.

## See also

- [[Declarations-And-Scope]]
- [[For-Loop-As-Desugared-While]]
- [[Command-Semantics-Rules]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
