---
tags: [example]
level: 1
aliases: ["if else smali", "comparison branches smali"]
created: 2026-11-12
---

# Example: If-Else-And-Comparisons

> [!info] Level 1 — basics
> One idea: every `if` in Java becomes a conditional jump with the *opposite* condition, and `&&` is just two such jumps to the same label.

## Goal

Read an `if`/`else if`/`else` chain and a short-circuit `&&` straight off the smali, and decode the `const/16` thresholds back into source constants. Belongs to [[Dalvik-Instructions]].

## Java source

```java
public class Rules {
    static String grade(int score) {
        if (score >= 90) return "A";
        else if (score >= 60) return "pass";
        else return "fail";
    }

    static boolean inRange(int x, int lo, int hi) {
        return x >= lo && x <= hi;
    }
}
```

## Generated smali

```smali
.method static grade(I)Ljava/lang/String;
    .locals 1
    const/16 v0, 0x5a          # 90
    if-lt p0, v0, :cond_0      # NOT (score >= 90) -> next test
    const-string p0, "A"
    return-object p0
    :cond_0
    const/16 v0, 0x3c          # 60
    if-lt p0, v0, :cond_1
    const-string p0, "pass"
    return-object p0
    :cond_1
    const-string p0, "fail"
    return-object p0
.end method

.method static inRange(III)Z
    .locals 0
    if-lt p0, p1, :cond_0      # x < lo  -> false
    if-gt p0, p2, :cond_0      # x > hi  -> false
    const/4 p0, 0x1
    return p0
    :cond_0
    const/4 p0, 0x0
    return p0
.end method
```

## Step by step

1. **Negated conditions.** `score >= 90` compiles to `if-lt p0, v0, :cond_0` — "jump past the then-block when the condition is false". Translate back by negating: `lt` ↔ `ge`, `gt` ↔ `le`, `eq` ↔ `ne`.
2. **Two-register vs zero forms.** `if-lt vA, vB` compares two registers; `if-ltz vA` compares against zero. Comparisons against any other constant first load it: `const/16 v0, 0x5a`. Decode hex to decimal (`0x5a` = 90, `0x3c` = 60) — these thresholds are usually the most meaningful values in the method.
3. **`else` needs no instruction here.** Each branch ends with `return-object`, so the code after `:cond_0` is reached only when the test failed. When branches don't return, you'll instead see a `goto :goto_0` at the end of the then-block jumping over the else-block.
4. **`&&` = two jumps, one target.** Both `if-lt` and `if-gt` jump to `:cond_0` (the "false" result). Any failing condition short-circuits; falling through both means both held. `||` is the mirror image: the conditions jump to the "true" block instead (see the real example below).
5. **Booleans are ints.** `return true` is `const/4 p0, 0x1` + `return p0`. Dalvik has no boolean registers; the method's `Z` return type is the only clue.

## Compared with real code

- [[String-Equals-Chain-In-PressReader]] — a real `if`/`else if` chain on strings, including an `||` whose two tests share one target label.
- [[Recognizing-An-Opaque-Predicate-Guard]] — a branch that looks like this one but whose outcome is fixed, used as an anti-tamper trap.

## See also

- [[Dalvik-Instructions]]
- [[Conditional-Branches]]
- [[For-Loop-Over-An-Array]]
- [[If-Else-As-Branches]] in [[ARM64-Android]]
- [[Deriving-An-If-Then-Else]] in [[Java-Fundamentals]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
