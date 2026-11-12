---
tags: [example]
level: 2
aliases: ["Bridge methods smali", "Overloads in smali"]
created: 2026-11-12
---

# Example: Overloading-And-Bridge-Methods

> [!info] Level 2 — intermediate
> Overloads are distinguished only by descriptor; generics and covariant returns make the compiler invent extra `bridge synthetic` methods you didn't write.

## Goal

Show how several methods with the same name coexist in smali, and where `bridge synthetic` methods come from, so they're recognized as compiler plumbing rather than logic to reverse. Belongs to [[Methods]].

## Java source

```java
public class Box implements Comparable<Box>, Cloneable {
    int size;

    public void put(int v)    { size += v; }
    public void put(long v)   { size += (int) v; }
    public void put(String s) { size += s.length(); }

    @Override
    public int compareTo(Box other) {
        return Integer.compare(size, other.size);
    }

    @Override
    public Box clone() {               // covariant return: Object -> Box
        Box b = new Box();
        b.size = size;
        return b;
    }
}
```

## Generated smali (abridged)

```smali
.class public LBox;
.super Ljava/lang/Object;
.implements Ljava/lang/Comparable;
.implements Ljava/lang/Cloneable;

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ljava/lang/Comparable<",
        "LBox;",
        ">;",
        "Ljava/lang/Cloneable;"
    }
.end annotation

# virtual methods
.method public put(I)V                 # three overloads, three descriptors
.method public put(J)V
.method public put(Ljava/lang/String;)V

.method public compareTo(LBox;)I
    .locals 1
    iget v0, p0, LBox;->size:I
    iget p1, p1, LBox;->size:I
    invoke-static {v0, p1}, Ljava/lang/Integer;->compare(II)I
    move-result p1
    return p1
.end method

.method public bridge synthetic compareTo(Ljava/lang/Object;)I
    .locals 0
    check-cast p1, LBox;
    invoke-virtual {p0, p1}, LBox;->compareTo(LBox;)I
    move-result p1
    return p1
.end method

.method public clone()LBox;
    # ... new-instance, iget/iput size, return-object
.end method

.method public bridge synthetic clone()Ljava/lang/Object;
    .locals 1
    invoke-virtual {p0}, LBox;->clone()LBox;
    move-result-object v0
    return-object v0
.end method
```

## Step by step

1. **Overloads.** The three `put` methods differ only in descriptor: `(I)V`, `(J)V`, `(Ljava/lang/String;)V`. A call site names the exact descriptor (`invoke-virtual {p0, v0, v1}, LBox;->put(J)V`), so overload resolution was entirely done at compile time — there's never any ambiguity in smali about which one is called. Note `put(J)V` takes a `long`, so its parameter occupies the pair `p1`/`p2` ([[Registers]]).
2. **Why a bridge for `compareTo`.** After type erasure, `Comparable<Box>` only declares `compareTo(Ljava/lang/Object;)I`. Your method has descriptor `(LBox;)I` — a *different* method as far as the VM is concerned. So the compiler adds a `bridge synthetic compareTo(Object)` that `check-cast`s and forwards to the real one. Anyone calling through the `Comparable` interface hits the bridge first.
3. **Why a bridge for `clone`.** A covariant return type (`Box` instead of `Object`) also changes the descriptor. The bridge `clone()Ljava/lang/Object;` overrides `Object.clone()` and forwards to `clone()LBox;`.
4. **What to do with bridges.** Skip them when reconstructing logic: they contain only a cast, a forward, and a return. They are, however, useful evidence — a bridge from `(Ljava/lang/Object;)I` to `(LBox;)I` tells you the generic type argument (`Comparable<Box>`) even if the `Signature` annotation was stripped.
5. **Hooking consequence.** In [[Java-Layer-Hooking]], `compareTo` now has two overloads; hooking the wrong one (the bridge) still works for interface calls but misses direct calls to `compareTo(Box)`. Pick by descriptor.

## Compared with real code

PressReader's `NewspaperFilter` has exactly the covariant-`clone` bridge from step 3 — the real implementation was renamed to `a()` by R8, but the bridge must keep the name `clone` because it overrides `Object.clone()`:

```smali
.method public final bridge synthetic clone()Ljava/lang/Object;
    .locals 1
    invoke-virtual {p0}, Lcom/newspaperdirect/pressreader/android/core/catalog/NewspaperFilter;->a()Lcom/newspaperdirect/pressreader/android/core/catalog/NewspaperFilter;
    move-result-object v0
    return-object v0
.end method
```

That makes bridges a de-obfuscation aid: the bridge's preserved name tells you what the renamed target `a()` really is (`clone()`). See also [[Parcelable-Creator-Erased-Generics]] for a real Kotlin class that implements a generic interface *without* bridges.

## See also

- [[Methods]]
- [[Types]] — descriptors and erasure
- [[Generics-Erasure-And-Signature-Annotations]]
- [[New-Instance-And-Check-Cast]]
- [[Calling-Through-An-Overload-Without-Recursing]] in [[Frida-Dynamic-Instrumentation]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
