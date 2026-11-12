---
tags: [example]
level: 1
aliases: ["Type descriptors smali"]
created: 2026-11-12
---

# Example: Primitive-And-Reference-Descriptors

> [!info] Level 1 — basics
> One idea: every Java type has exactly one descriptor string, and a method's whole signature is just descriptors glued together.

## Goal

Map each kind of Java type to its smali descriptor on a single class, then read a method descriptor left to right without a table. Belongs to [[Types]].

## Java source

```java
public class Profile {
    boolean active;
    byte flags;
    char initial;
    short year;
    int age;
    long id;
    float score;
    double balance;
    String name;
    int[] scores;
    String[][] grid;
    java.util.List<String> tags;

    public static Profile find(long id, String name, int[] hints) { return null; }
}
```

## Generated smali

```smali
.class public LProfile;
.super Ljava/lang/Object;

# instance fields
.field active:Z
.field age:I
.field balance:D
.field flags:B
.field grid:[[Ljava/lang/String;
.field id:J
.field initial:C
.field name:Ljava/lang/String;
.field score:F
.field scores:[I
.field tags:Ljava/util/List;
.field year:S

.method public static find(JLjava/lang/String;[I)LProfile;
    .locals 0
    const/4 p0, 0x0
    return-object p0
.end method
```

## Step by step

Fields come out in alphabetical order (that's how DEX sorts them), not declaration order.

1. **Primitives are one letter**: `Z` boolean, `B` byte, `C` char, `S` short, `I` int, `J` long, `F` float, `D` double, `V` void (return types only). The two odd ones out are `Z` (because `B` is taken) and `J` (because `L` is taken).
2. **Classes are `L<path>;`** with `/` instead of `.` and a mandatory trailing `;`: `java.lang.String` → `Ljava/lang/String;`. The `;` is what lets descriptors be concatenated without separators.
3. **Arrays add one `[` per dimension**: `int[]` → `[I`, `String[][]` → `[[Ljava/lang/String;`.
4. **Generics vanish**: `List<String>` is just `Ljava/util/List;`. The type argument may survive in a `Signature` annotation (see [[Generics-Erasure-And-Signature-Annotations]]), but never in the descriptor.
5. **Reading `find(JLjava/lang/String;[I)LProfile;`** left to right: `J` → `long`; `L…;` → up to the next `;` is `String`; `[I` → `int[]`; after `)` the return type `LProfile;`. So: `static Profile find(long, String, int[])`.
6. **Register cost follows the descriptor**: `J` and `D` take two registers, everything else one. Here `find` has 2 + 1 + 1 = 4 parameter registers, `p0`–`p3` ([[Counting-Locals-And-Parameters]]).
7. `const/4 p0, 0x0` is how `null` is written — there's no separate "null" constant instruction; a zero in a register used as a reference *is* `null`.

## Try it

Decode `([BIILjava/lang/String;Z)[Ljava/lang/Object;` before reading on.

> [!tip]- Answer
> `Object[] m(byte[], int, int, String, boolean)` — five parameters, five registers (plus `p0` = `this` if it's an instance method).

## Compared with real code

- [[Encrypted-String-Table-Array-Data]] — a real `[B` (`byte[]`) table baked in with `fill-array-data`.
- [[Parcelable-Creator-Erased-Generics]] — real descriptors where the generic type is visible only in the `Signature` annotation.

## See also

- [[Types]]
- [[Dalvik-Type-Table]]
- [[Autoboxing-In-Smali]]
- [[Multidimensional-Arrays]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
