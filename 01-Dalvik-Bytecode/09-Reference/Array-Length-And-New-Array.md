---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-11-11
---

# Array-Length, New-Array, and Filled-New-Array

## Signature / syntax

```
array-length vA, vB
new-array vA, vB, [type
filled-new-array {vC, vD, vE, vF, vG}, [type
filled-new-array/range {vC .. vN}, [type
```

## Description

Query an array's size or allocate a new array instance:

- **`array-length vA, vB`** reads the number of elements in the array referenced by `vB` and stores that 32-bit `int` count into `vA` (throws `NullPointerException` if `vB` is `null`).
- **`new-array vA, vB, [type`** allocates a new single-dimension array of array descriptor `[type` (for example `[I` for `int[]`, `[Ljava/lang/String;` for `String[]`, or `[[I` for the outer spine of an `int[][]`) with length `vB`, zero-/null-initialized, and stores the resulting reference directly into `vA` (throws `NegativeArraySizeException` if `vB < 0`).
- **`filled-new-array {vC, ...}, [type`** and **`filled-new-array/range {vC .. vN}, [type`** allocate an array of `[type` whose length equals the number of listed registers (up to 5 registers in the compact form, or a contiguous range `{vC .. vN}` in `/range` form) and populate its elements directly from those registers in order. Unlike `new-array`, **`filled-new-array` does not name a destination register** — just like `invoke-*`, it places the newly allocated array reference into the implicit result slot, so the very next instruction must be `move-result-object vAA` to capture it.

## Example

Building a 5-element `Pair[]` array with `filled-new-array` + `move-result-object` to feed Kotlin's `mapOf(...)` in [[Exercise-08-Server-Mode-Map-Constructor]], and iterating an array with `array-length` in [[Reading-Raw-Dalvik]]'s worked example 7:

```smali
# Exercise 08 (nr.d.<init>): mapOf(p1, p2, p3, p4, p5) via filled-new-array
filled-new-array {v1, p1, p2, p4, p5}, [Ln10/i;
move-result-object p1
invoke-static {p1}, Lo10/d0;->p([Ln10/i;)Ljava/util/Map;
move-result-object p1
iput-object p1, p0, Lnr/d;->c:Ljava/util/Map;
```

```smali
# Reading-Raw-Dalvik worked example 7: standard indexed array loop
array-length v5, v1                    # v5 = rules.length
move v6, v9                            # v6 = 0
:goto_0
if-ge v6, v5, :cond_0                  # while (v6 < v5)
aget-object v7, v1, v6                 # v7 = rules[v6]
...
add-int/lit8 v6, v6, 0x1               # v6++
goto :goto_0
:cond_0
```

## Notes

Dalvik provides **three distinct idioms for populating an array**, and recognizing which one a compiler chose tells you what the source looked like:

1. **`new-array` + `fill-array-data`** (see [[Fill-Array-Data]]): used for primitive arrays whose elements are all compile-time constants (`new byte[]{ 0x0b, 0x54, ... }`), storing the raw bytes in a trailing `.array-data` payload block rather than emitting code per element.
2. **`filled-new-array` + `move-result-object`**: used for small arrays whose elements already sit in registers (varargs calls like `String.format(fmt, a, b)` or `mapOf(pair1, pair2, ...)` — see [[Exercise-08-Server-Mode-Map-Constructor]] and [[Exercise-12-The-DQ-Request-Callable]]) or as the dimension-sizes argument passed to `Array.newInstance(Class, int[])` for multi-dimensional array allocation (see [[Multidimensional-Arrays]]).
3. **`new-array` + repeated `aput*`** (see [[Aget-And-Aput]]): used when elements are computed one by one in a loop (such as [[Exercise-06-Static-Monitors-And-Iterators]]'s `h()` copying `o.keySet()` into `new String[o.size()]`) or when an object array is larger than 5 elements and its values aren't already in consecutive registers for `filled-new-array/range`.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Types]] — array type descriptors (`[I`, `[Ljava/lang/String;`, `[[I`)
- [[Multidimensional-Arrays]]
- [[Aget-And-Aput]]
- [[Fill-Array-Data]]
- [[Move-Result]]
- [[Exercise-08-Server-Mode-Map-Constructor]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
