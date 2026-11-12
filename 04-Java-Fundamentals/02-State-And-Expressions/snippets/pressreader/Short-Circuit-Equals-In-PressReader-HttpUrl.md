---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/w50/q.smali, method equals(Ljava/lang/Object;)Z; w50/q$a.smali, method toString() (decompiled: Case-Studies/pressreader/source/java/w50/q.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Short-Circuit-Equals-In-PressReader-HttpUrl

> [!info] Level 3 — real code
> Two real short-circuit expressions from OkHttp's `HttpUrl` as bundled in PressReader: an `equals` whose `&&` protects a cast, and a `||` in `Builder.toString()` — each derived with the short-circuit rules and matched to its branch chain.

## Context

`w50.q` is OkHttp's `HttpUrl` ([[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]]). Its `equals` compares the canonical URL string `i`; the builder's `toString` decides whether to print a `user:password@` part. Part of [[PressReader]].

## Original path

`smali_classes2/w50/q.smali` → `equals(Ljava/lang/Object;)Z`; `smali_classes2/w50/q$a.smali` → `toString()Ljava/lang/String;`.

## Snippet 1 — `equals`

```smali
.method public final equals(Ljava/lang/Object;)Z
    .locals 1
    instance-of v0, p1, Lw50/q;                   # e₁ = obj instanceof q
    if-eqz v0, :cond_0                            # ff -> result false   (and-ff)
    check-cast p1, Lw50/q;
    iget-object p1, p1, Lw50/q;->i:Ljava/lang/String;
    iget-object v0, p0, Lw50/q;->i:Ljava/lang/String;
    invoke-static {p1, v0}, Lkotlin/jvm/internal/l;->a(Ljava/lang/Object;Ljava/lang/Object;)Z   # e₂
    move-result p1
    if-eqz p1, :cond_0
    const/4 p1, 0x1
    goto :goto_0
    :cond_0
    const/4 p1, 0x0
    :goto_0
    return p1
.end method
```

```java
public final boolean equals(Object obj) {
    return (obj instanceof q) && Intrinsics.areEqual(((q) obj).i, this.i);
}
```

## Snippet 2 — `toString`'s userinfo test

```java
if (this.b.length() > 0 || this.c.length() > 0) {     // username or password present
    sb.append(this.b);
    if (this.c.length() > 0) { sb.append(':'); sb.append(this.c); }
    sb.append('@');
}
```

## Derivations

`equals` with `obj` a `String` (σ binds `obj ↦ ℓ_s`, `θ(ℓ_s) = (String, …)`):

```
  ⟨obj instanceof q, …⟩ →ₑ ff
  ────────────────────────────────────────────── (and-ff)
  ⟨obj instanceof q && areEqual(((q) obj).i, i), …⟩ →ₑ ff
```

No premise mentions `((q) obj).i` — the cast that would fail (`ClassCastException`, a blocked configuration) is never evaluated.

`toString` with `b ↦ ""`, `c ↦ "secret"`:

```
  ⟨b.length() > 0, …⟩ →ₑ ff   ⟨c.length() > 0, …⟩ →ₑ tt
  ───────────────────────────────────────────────────── (or-ff)
       ⟨b.length() > 0 || c.length() > 0, …⟩ →ₑ tt
```

With `b ↦ "user"` instead, `(or-tt)` concludes `tt` from the first operand alone.

## Notes

- **Order is semantic here.** Swapping the operands of `&&` in `equals` would evaluate the cast first and block for every non-`q` argument. Left-to-right short-circuit evaluation is what makes the idiom `x instanceof T && ((T) x)…` safe ([[Short-Circuit-As-Nested-Conditionals]]).
- **Branch chain shape.** `&&` = "first test fails → jump to the shared `false` block (`:cond_0`)"; the second test reuses the same target. That's the `(and-ff)`/`(and-tt)` pair as control flow.
- **`instance-of` vs `check-cast`.** `instance-of` is an expression yielding a boolean (never blocks, `null` → false); `check-cast` is a guarded operation that throws on mismatch. The compiler emits `check-cast` only on the path where `instance-of` already returned true.
- **Kotlin's `areEqual`** (`l.a`) is null-safe equality (`a == null ? b == null : a.equals(b)`) — itself a conditional expression hidden behind a call.
- **`hashCode` agrees with `equals`**: it returns `this.i.hashCode()`, so equal URLs (same `i`) have equal hashes — the contract that makes `HttpUrl` usable as a map key.

## See also

- [[State-And-Expressions]]
- [[Expression-Semantics-Rules]]
- [[String-Equals-Chain-In-PressReader]] in [[Dalvik-Bytecode]]
- [[Java-Fundamentals-Reference|Reference]]
