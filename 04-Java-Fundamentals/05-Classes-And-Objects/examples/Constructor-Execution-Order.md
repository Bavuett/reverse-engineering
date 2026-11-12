---
tags: [example]
level: 2
aliases: ["field initializer order", "object initialization order", "super constructor first"]
created: 2026-11-12
---

# Example: Constructor-Execution-Order

> [!info] Level 2 — intermediate
> Combines `(new)` with constructor bodies: creating an object is allocation (all fields `$`/default) followed by a sequence — superclass constructor, then field initializers in textual order, then the constructor body — and that sequence is visible line by line in `<init>`.

## Goal

Determine the heap contents at each point of `new Counter(5)`, and read the order back from bytecode. Belongs to [[Classes-And-Objects]].

## Program

```java
class Counter {
    int start = 10;
    int count;
    String label = "c";
    Counter(int extra) { count = start + extra; }
}
Counter c = new Counter(5);
```

## Trace of `new Counter(5)`

```
(new)            ℓ₀ fresh:         θ(ℓ₀) = (Counter, {start↦0, count↦0, label↦null})   ← JVM defaults
super()          Object.<init>:    no fields to set
initializer 1    start = 10:       θ(ℓ₀) = (Counter, {start↦10, count↦0, label↦null})
initializer 2    label = "c":      θ(ℓ₀) = (Counter, {start↦10, count↦0, label↦"c"})
body             count = start+5:  θ(ℓ₀) = (Counter, {start↦10, count↦15, label↦"c"})
(decl-init)      c = ℓ₀
```

## Compiled

```smali
.method public constructor <init>(I)V
    .locals 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V     # 1. super()
    const/16 v0, 0xa
    iput v0, p0, LCounter;->start:I                     # 2. field initializers, in source order
    const-string v0, "c"
    iput-object v0, p0, LCounter;->label:Ljava/lang/String;
    iget v0, p0, LCounter;->start:I                     # 3. constructor body
    add-int/2addr v0, p1
    iput v0, p0, LCounter;->count:I
    return-void
.end method
```

## Step by step

1. **Allocation gives defaults, not `$`.** The semantics' `ϕ_init` marks fields uninitialized; the JVM actually zeroes them (`0`, `false`, `null`). Fields are therefore always readable — unlike locals — which is why reading a field "too early" yields 0 instead of a compile error.
2. **Field initializers aren't separate code.** The compiler copies them into *every* constructor, right after the `super(...)` call. In bytecode there's no visible difference between `int start = 10;` and `start = 10;` written at the top of the constructor.
3. **`count` has no initializer**, so nothing is emitted for it; it keeps its default until the body assigns it.
4. **Superclass first.** The `invoke-direct … <init>` of the superclass comes before any field write of this class; a superclass constructor that calls an overridden method would see this class's fields still at their defaults — a classic initialization bug.
5. **Arguments can be checked before `super()`.** Bytecode allows code that doesn't touch `this` to run before the superclass constructor; Kotlin uses this for parameter null-checks ([[HttpUrl-Final-Fields-From-Constructor-In-PressReader]]).

## Compared with real code

- [[Builder-Field-Initializers-And-Aliasing-In-PressReader]] — real field initializers (`= ""`, `= -1`) merged into a constructor, followed by the body.
- [[HttpUrl-Final-Fields-From-Constructor-In-PressReader]] — a real constructor with checks before `super()` and a derived field computed last.

## See also

- [[Classes-And-Objects]]
- [[Objects-On-The-Heap]]
- [[Classes]] in [[Dalvik-Bytecode]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
