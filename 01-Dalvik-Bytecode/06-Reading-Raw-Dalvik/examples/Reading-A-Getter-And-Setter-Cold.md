---
tags: [example]
level: 1
aliases: ["Reading an obfuscated model class"]
created: 2026-11-12
---

# Example: Reading-A-Getter-And-Setter-Cold

> [!info] Level 1 — basics
> One idea: in an obfuscated class, the *shape* of each tiny method (read a field and return it, write a parameter into a field, compare a field against the clock) tells you what it is long before any name does.

## Goal

Recover a meaningful class definition from a fully renamed model class with four one-line methods, using only method shapes, field types, and one leaked string. Belongs to [[Reading-Raw-Dalvik]].

## The smali (no source available)

```smali
.class public final Lq3/b;
.super Ljava/lang/Object;

.field private a:Ljava/lang/String;
.field private b:J
.field private final c:Ljava/util/ArrayList;

.method public final a()Ljava/lang/String;
    .locals 1
    iget-object v0, p0, Lq3/b;->a:Ljava/lang/String;
    return-object v0
.end method

.method public final a(Ljava/lang/String;)V
    .locals 1
    const-string v0, "<set-?>"
    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V
    iput-object p1, p0, Lq3/b;->a:Ljava/lang/String;
    return-void
.end method

.method public final b()Z
    .locals 4
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v0
    iget-wide v2, p0, Lq3/b;->b:J
    cmp-long v0, v0, v2
    if-lez v0, :cond_0
    const/4 v0, 0x1
    return v0
    :cond_0
    const/4 v0, 0x0
    return v0
.end method

.method public final c(Ljava/lang/Object;)V
    .locals 1
    iget-object v0, p0, Lq3/b;->c:Ljava/util/ArrayList;
    invoke-virtual {v0, p1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    return-void
.end method
```

## Step by step

1. **Getter shape**: `iget` + `return`, no parameters → `a()` is a getter for field `a`.
2. **Setter shape**: one parameter, `iput` of that parameter into a field, `return-void` → `a(String)` is the setter for the same field. Same name, different descriptor: an overload pair, which is how R8 renames a getter/setter pair (`getX`/`setX` → `a()`/`a(String)`).
3. **The leaked string**: `"<set-?>"` passed to `Intrinsics.checkNotNullParameter` is what the Kotlin compiler uses as the parameter name of a **property setter**. So this isn't just *a* setter — it's the setter of a Kotlin `var` of non-null type `String`.
4. **Time comparison shape**: `System.currentTimeMillis()` compared against a `long` field with `cmp-long` and returning `1` when "now > field" → `b()` returns "is the stored timestamp in the past", i.e. *is expired*. That makes field `b` an expiry timestamp in milliseconds.
5. **Collection field**: `c` is `final`, an `ArrayList`, and `c(Object)` only appends to it → a list of something registered with this object (listeners, pending callbacks, …). The parameter type is erased to `Object`, so the element type has to come from callers (look for the `check-cast` when items are read back).
6. **Write it down** as a hypothesis, with the evidence next to each name:

```kotlin
class Session /* q3.b */ {
    var token: String = ""                         // a, setter has "<set-?>"
    private var expiresAt: Long = 0                // b, compared to currentTimeMillis
    private val listeners = ArrayList<Any>()       // c

    fun isExpired() = System.currentTimeMillis() > expiresAt   // b()
    fun addListener(l: Any) { listeners.add(l) }               // c(Object)
}
```

Names like `Session`/`token` are guesses until a caller confirms them (for instance, `a()` being passed to an `Authorization` header builder). The shapes are not guesses.

## Compared with real code

- [[Parcelable-Creator-Erased-Generics]] — a real Kotlin class where `checkNotNullParameter`'s string argument leaks the parameter name `"parcel"`.
- [[Exercise-05-Kotlin-Data-Class-Reconstruction]] — the same reasoning scaled up to a whole real data class.

## See also

- [[Reading-Raw-Dalvik]] — worked example 1 applies the same shape-first reading to a lazy-init cache
- [[Iget-And-Iput]]
- [[Wide-Registers-For-Long-And-Double]] — `cmp-long`
- [[Annotating-A-Short-Method-Line-By-Line]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
