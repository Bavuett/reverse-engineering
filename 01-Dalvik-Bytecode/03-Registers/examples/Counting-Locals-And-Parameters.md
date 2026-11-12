---
tags: [example]
level: 1
aliases: ["Register counting smali"]
created: 2026-11-12
---

# Example: Counting-Locals-And-Parameters

> [!info] Level 1 — basics
> One idea: work out the exact `v`↔`p` register mapping of a method from nothing but its `.method` line and `.locals` count.

## Goal

Practice the arithmetic every smali reader does constantly: given the descriptor, the `static` flag, and `.locals N`, list which `vN` each `pN` aliases and which parameters take two registers. Belongs to [[Registers]].

## Java source

```java
public class Scaler {
    public static int sum3(int a, int b, int c) {
        int t = a + b;
        return t + c;
    }

    public long scaled(int x, long factor, boolean neg) {
        long r = x * factor;
        return neg ? -r : r;
    }
}
```

## Generated smali

```smali
.method public static sum3(III)I
    .locals 0
    add-int/2addr p0, p1
    add-int/2addr p0, p2
    return p0
.end method

.method public scaled(IJZ)J
    .locals 2
    int-to-long v0, p1
    mul-long/2addr v0, p2
    if-eqz p4, :cond_0
    neg-long v0, v0
    :cond_0
    return-wide v0
.end method
```

## Step by step

1. **Count the parameter slots** ("ins"): `this` = 1 (instance methods only), `int`/`boolean`/`float`/references = 1, `long`/`double` = 2.
   - `sum3(III)I`, static: 1 + 1 + 1 = **3** ins.
   - `scaled(IJZ)J`, instance: 1 (`this`) + 1 (`I`) + 2 (`J`) + 1 (`Z`) = **5** ins.
2. **Total registers** = `.locals` + ins. `sum3` has 0 + 3 = 3, `scaled` has 2 + 5 = 7.
3. **Parameters sit at the top.** `p0` is always `v<locals>`:

   | method | v0 | v1 | v2 | v3 | v4 | v5 | v6 |
   | --- | --- | --- | --- | --- | --- | --- | --- |
   | `sum3` | `p0` = a | `p1` = b | `p2` = c | | | | |
   | `scaled` | local | local | `p0` = this | `p1` = x | `p2` = factor (lo) | `p3` = factor (hi) | `p4` = neg |

4. **Wide parameters are named by their first register.** `factor` is `p2`, and `p3` is its upper half — you'll never see `p3` used alone. That's why `neg` is `p4`, not `p3`. Miscounting this is the most common reason a reconstructed method "uses the wrong parameter".
5. **The local `t` disappeared.** `sum3` declares `int t`, but the compiler simply accumulated into `p0`. Local variable names and even local variable *count* don't survive compilation — `.locals` reflects what the compiler needed, not what the source declared.
6. **Wide locals too.** In `scaled`, `long r` lives in `v0`/`v1`, which is why `.locals 2` and not 1.

## Compared with real code

- [[Exercise-02-HttpURLConnection-Factory]] — a real method that reuses `v0` and `p0` across three different types; the counting here is what lets you keep track.
- [[Device-Id-Wide-Register-Uuid]] — a real `long` built from two `int`s and passed as a wide register pair.

## See also

- [[Registers]]
- [[Constructor-and-Fields]] — the same mapping written with `.registers`
- [[Wide-Registers-For-Long-And-Double]]
- [[Dalvik-Type-Table]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
