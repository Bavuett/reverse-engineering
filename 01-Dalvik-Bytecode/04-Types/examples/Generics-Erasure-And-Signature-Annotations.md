---
tags: [example]
level: 2
aliases: ["Generic erasure smali", "Signature annotation"]
created: 2026-11-12
---

# Example: Generics-Erasure-And-Signature-Annotations

> [!info] Level 2 — intermediate
> Type parameters erase to their **bound**, not always to `Object`; the generic declaration survives only as `Signature` strings, and the caller's `check-cast` reveals the concrete type argument.

## Goal

Follow one bounded generic class through compilation and recover its type parameters from three kinds of evidence: erased descriptors, `Signature` annotations, and call-site casts. Belongs to [[Types]].

## Java source

```java
import java.util.ArrayList;
import java.util.List;

public class Repo<T extends Comparable<T>> {
    private final List<T> items = new ArrayList<>();

    public void add(T item) { items.add(item); }

    public T max() {
        T best = items.get(0);
        for (T t : items) if (t.compareTo(best) > 0) best = t;
        return best;
    }
}

// elsewhere:
//   Repo<String> r = new Repo<>();
//   String top = r.max();
```

## Generated smali (abridged)

```smali
.class public LRepo;
.super Ljava/lang/Object;

.annotation system Ldalvik/annotation/Signature;
    value = {
        "<T::",
        "Ljava/lang/Comparable<",
        "TT;>;>",
        "Ljava/lang/Object;"
    }
.end annotation

.field private final items:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "TT;>;"
        }
    .end annotation
.end field

.method public add(Ljava/lang/Comparable;)V
    .annotation system Ldalvik/annotation/Signature;
        value = { "(TT;)V" }
    .end annotation
    .locals 1
    iget-object v0, p0, LRepo;->items:Ljava/util/List;
    invoke-interface {v0, p1}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    return-void
.end method

.method public max()Ljava/lang/Comparable;
    .annotation system Ldalvik/annotation/Signature;
        value = { "()TT;" }
    .end annotation
    # ... iterator loop with check-cast v?, Ljava/lang/Comparable;
    #     and invoke-interface ... Comparable->compareTo(Ljava/lang/Object;)I
.end method

# call site in another class:
invoke-virtual {v0}, LRepo;->max()Ljava/lang/Comparable;
move-result-object v0
check-cast v0, Ljava/lang/String;
```

## Step by step

1. **Erasure to the bound.** `T extends Comparable<T>` erases to `Comparable`, so `add(T)` has descriptor `(Ljava/lang/Comparable;)V` and `max()` returns `Ljava/lang/Comparable;`. An unbounded `T` would have erased to `Object`. A parameter typed as an interface like `Comparable` in a class with a `Signature` annotation is a hint you're looking at a bounded type parameter, not a hand-written interface parameter.
2. **`Signature` strings are a mini-language**, split into chunks: `<T::Ljava/lang/Comparable<TT;>;>Ljava/lang/Object;` reads "type parameter `T` with interface bound `Comparable<T>`, superclass `Object`". `TT;` means "type variable `T`". The double colon `::` marks an *interface* bound (a class bound would use a single `:`).
3. **Field and method signatures** restore `List<T>`, `(T)V`, `()T`. Tools like jadx read these to print generic source; if R8 stripped them (common unless `-keepattributes Signature`), only the erased descriptors from step 1 remain.
4. **The call site knows `T`.** `max()` returns `Comparable`, and the caller immediately `check-cast`s to `String`: that cast *is* `Repo<String>`. Even with every `Signature` stripped, casts right after calls to generic methods recover type arguments one call site at a time.
5. **Inside the class, casts go to the bound.** The `for (T t : items)` loop gets `Object` from `Iterator.next()` and casts to `Comparable` — the most the class itself knows about `T`.

## Compared with real code

- [[Parcelable-Creator-Erased-Generics]] — a real Kotlin class implementing `Parcelable.Creator<AccountDevice>`, whose only generic evidence is a class-level `Signature` annotation.
- [[Overloading-And-Bridge-Methods]] — the bridge methods erasure forces the compiler to generate.

## See also

- [[Types]]
- [[Annotations]]
- [[Autoboxing-In-Smali]]
- [[Primitive-And-Reference-Descriptors]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
