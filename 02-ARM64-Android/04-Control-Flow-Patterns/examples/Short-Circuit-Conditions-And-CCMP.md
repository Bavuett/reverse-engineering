---
tags: [example]
level: 2
aliases: ["ccmp ARM64", "short-circuit && || ARM64"]
created: 2026-11-12
---

# Example: Short-Circuit-Conditions-And-CCMP

> [!info] Level 2 — intermediate
> `&&`/`||` compiled two ways: as a chain of branches to a shared "false" label, and branch-free with `ccmp`, the conditional compare that chains conditions inside the flags.

## Goal

Recover compound boolean conditions from both of their common compiled shapes, and learn to read `ccmp`'s fallback-flags operand. Belongs to [[Control-Flow-Patterns]].

## Source

```c
int valid(const char *s, int n) {
    return s != 0 && n > 0 && s[0] != '#';
}

int pick(int a, int b, int c) {
    return (a > b || c == 0) ? a : b;
}
```

## Compiled (clang -O2, AArch64)

```asm
valid:
    cbz     x0, .Lfalse            ; s == NULL      -> false
    cmp     w1, #1
    b.lt    .Lfalse                ; n < 1          -> false
    ldrb    w8, [x0]               ; s[0]  (only reached when s != NULL)
    cmp     w8, #0x23              ; '#'
    cset    w0, ne                 ; last condition becomes the result
    ret
.Lfalse:
    mov     w0, wzr
    ret

pick:
    cmp     w0, w1                 ; flags = a ? b
    ccmp    w2, #0, #4, le         ; if (a <= b) flags = c ? 0  else flags = nzcv(0b0100) -> Z=1
    csel    w0, w0, w1, eq         ; Z ? a : b
    ret
```

## Step by step

1. **Branch chain (`valid`).** Each condition that can make the whole `&&` false jumps to one shared label. The order of the tests is the source order, and it matters: `ldrb w8, [x0]` is only reached after `cbz x0` proved `s` non-null — short-circuiting is what makes the dereference safe. When reconstructing, keep the order.
2. **The last condition is computed, not branched.** `cset w0, ne` turns `s[0] != '#'` directly into the return value. A run of branches to a "return 0" label followed by a `cset` is the canonical `return a && b && c;`.
3. **Condition codes are inverted, as in Dalvik.** `n > 0` appears as `cmp w1, #1` / `b.lt .Lfalse` — "leave if `n < 1`". Translate back by negating the branch condition ([[If-Else-And-Comparisons]] shows the same idea in smali).
4. **`ccmp` (`pick`).** `ccmp Rn, #imm, #nzcv, cond` means: *if* `cond` holds on the current flags, compare `Rn` with `imm`; *otherwise* set the flags to the literal `nzcv`. Here:
   - If `a > b`, the `le` condition is false → flags := `#4` = `0b0100` = Z set → the final `eq` is true → result `a`. That's the left side of `||` short-circuiting to true.
   - If `a <= b`, compare `c` with `0` → `eq` iff `c == 0` → result `a` iff `c == 0`.
5. **Decoding `#nzcv`.** It's a 4-bit value: N=8, Z=4, C=2, V=1. `#4` forces "equal", `#0` forces "not equal / unsigned lower / positive". Ask: "if the first condition already decided the answer, which final condition does this immediate make true?" — that tells you whether the chain is `&&` or `||`.
6. **Why both shapes exist.** Branches are needed when a later condition is unsafe to evaluate early (the `s[0]` load). When every operand is a plain register, the compiler prefers `ccmp` + `csel`: no branches, no mispredictions.

## Compared with real code

- [[Conditional-Cleanup-Chain-In-Libencrypt]] — real native code with a fallback retry, independent `if (p) release(p)` steps, and early-error branches converging on one exit.
- [[Enum-Switch-Via-Pointer-Comparison]] — a chain of `cmp` + `b.eq` in Dart AOT code, the multi-way cousin of the branch chain here.
- [[Outline-Atomics-LSE-Vs-LLSC-In-Datastore]] — real `csel` + `cset` combining two conditions without branches.

## See also

- [[Control-Flow-Patterns]]
- [[If-Else-As-Branches]]
- [[Compare-And-Conditional-Select]]
- [[CSEL-CSINC-And-Conditional-Select]]
- [[CBZ-CBNZ-And-TBZ-TBNZ]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
