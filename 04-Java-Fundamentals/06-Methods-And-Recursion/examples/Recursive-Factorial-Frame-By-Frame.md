---
tags: [example]
level: 2
aliases: ["recursion call stack", "factorial frames", "recursive derivation"]
created: 2026-11-12
---

# Example: Recursive-Factorial-Frame-By-Frame

> [!info] Level 2 — intermediate
> Combines method calls with `if` and return values: each recursive call builds its own frame with its own `n`, the frames stack up until the base case, and results flow back down as each frame is discarded.

## Goal

Evaluate `fact(3)` frame by frame, see the derivation's nesting mirror the call stack, and read the recursion in smali. Belongs to [[Methods-And-Recursion]].

## Program

```java
static int fact(int n) {
    if (n <= 1) return 1;
    return n * fact(n - 1);
}
```

## Frames over time

```
call fact(3)    stack: {n↦3}
call fact(2)    stack: {n↦2} · {n↦3}
call fact(1)    stack: {n↦1} · {n↦2} · {n↦3}
  n <= 1 → tt   fact(1) returns 1                 pop {n↦1}
  2 * 1         fact(2) returns 2                 pop {n↦2}
  3 * 2         fact(3) returns 6                 pop {n↦3}
```

## Derivation (abbreviated, `F(k)` = body of `fact` in frame `{n ↦ k}`)

```
                                     ⟨1 <= 1⟩ →ₑ tt
                                     ─────────────── (if-tt)
                                       F(1) ⟶ 1
                     ⟨2 <= 1⟩ →ₑ ff   ⟨fact(1)⟩ →ₑ 1  (method-call)
                     ──────────────────────────────── (if-ff), (arith)
                                F(2) ⟶ 2 * 1 = 2
  ⟨3 <= 1⟩ →ₑ ff    ⟨fact(2)⟩ →ₑ 2  (method-call)
  ──────────────────────────────────────────── (if-ff), (arith)
                 F(3) ⟶ 3 * 2 = 6
```

The derivation tree's height equals the maximum stack depth.

## Compiled

```smali
.method static fact(I)I
    .locals 1
    const/4 v0, 0x1
    if-gt p0, v0, :recurse            # n <= 1 ?
    return v0                         # base case: 1
    :recurse
    add-int/lit8 v0, p0, -0x1         # n - 1
    invoke-static {v0}, LMath;->fact(I)I
    move-result v0                    # result of the inner frame
    mul-int/2addr v0, p0              # n * fact(n - 1) — p0 is still this frame's n
    return v0
.end method
```

## Step by step

1. **Every call gets a fresh `{n ↦ …}` frame.** The three `n`s never interfere: each frame's `n` is a different binding, just as each invocation has its own `p0` register.
2. **The recursive call is a premise.** `(arith)` for `n * fact(n - 1)` can't conclude until the sub-derivation for `fact(n - 1)` is complete — that's "waiting for the callee" in tree form.
3. **The base case stops the growth.** Without `n <= 1 → tt` eventually becoming true, the tree would grow without end — the semantic counterpart of `StackOverflowError`.
4. **Values return, frames vanish.** When a call returns, its frame is discarded and only the value `v` survives into the caller's expression.
5. **`p0` after the call is still this frame's `n`.** The callee's registers are separate, so the multiplication after `move-result` uses the caller's own `p0`.

## Compared with real code

- [[Call-Chain-Frames-In-PressReader-HttpUrl-Builder]] — real nested (non-recursive) calls three frames deep, with the same push/return discipline.
- [[A-Method-Call-Frame]] — the single-frame case.

## See also

- [[Methods-And-Recursion]]
- [[Object-And-Method-Semantics-Rules]]
- [[Functions-And-Calling-Convention]] in [[ARM64-Android]] — the same discipline with a real machine stack

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
