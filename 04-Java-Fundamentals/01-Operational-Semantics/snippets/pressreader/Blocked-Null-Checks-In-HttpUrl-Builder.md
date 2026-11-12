---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/w50/q$a.smali, method a()Lw50/q; (decompiled: Case-Studies/pressreader/source/java/w50/q.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Blocked-Null-Checks-In-HttpUrl-Builder

> [!info] Level 3 — real code
> A real method that checks a rule's side condition itself: OkHttp's `HttpUrl.Builder.build()` (PressReader's `w50.q$a.a()`) tests `scheme != null` and `host != null` up front and throws a descriptive exception — turning a configuration that would block deep inside the computation into an immediate, explained failure.

## Context

`build()` assembles an immutable `HttpUrl` from the builder's mutable fields. Two fields are mandatory. Without the checks, a `null` scheme would block much later — at a `(field-read)` or method call whose `ℓ ≠ null` premise fails — with an unhelpful `NullPointerException`. Part of [[PressReader]]; class identity in [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]].

## Original path

`smali_classes2/w50/q$a.smali` → `.method public final a()Lw50/q;` (fields `a` = scheme, `d` = host).

## Snippet

```smali
.method public final a()Lw50/q;
    .locals 14
    iget-object v1, p0, Lw50/q$a;->a:Ljava/lang/String;     # scheme
    if-eqz v1, :cond_6                                     # null -> throw "scheme == null"
    iget-object v0, p0, Lw50/q$a;->b:Ljava/lang/String;
    ...                                                    # encode username, password
    iget-object v6, p0, Lw50/q$a;->d:Ljava/lang/String;     # host
    if-eqz v6, :cond_5                                     # null -> throw "host == null"
    invoke-virtual {p0}, Lw50/q$a;->b()I                   # effective port
    ...                                                    # build path/query lists, new q(...)
```

## Reconstructed source

```java
public final q a() {                                          // OkHttp: HttpUrl.Builder.build()
    String scheme = this.a;
    if (scheme == null) throw new IllegalStateException("scheme == null");
    String user = b.c(this.b, 0, 0, false, 7);
    String pass = b.c(this.c, 0, 0, false, 7);
    String host = this.d;
    if (host == null) throw new IllegalStateException("host == null");
    int port = b();
    ...
    return new q(scheme, user, pass, host, port, segments, query, fragment, toString());
}
```

## Notes

- **Where it would block without the check.** Later, `new q(...)` passes `scheme` into the constructor, which calls `scheme.equals("https")` ([[HttpUrl-Final-Fields-From-Constructor-In-PressReader]]). In the semantics, that method call needs `⟨scheme, …⟩ →ₑ ℓ` with `ℓ ≠ null`; with `null` the configuration is blocked ([[Blocked-Configurations-And-Runtime-Errors]]).
- **A guard that preserves meaning on good inputs.** For every state where `scheme` and `host` are non-null, the checks evaluate to `ff`, `(if-ff)` skips the `throw`, and the method's result is unchanged — the checks only change *which* failure occurs on bad inputs, and when.
- **Fail early, fail clearly.** Checking side conditions at the boundary makes the blocked point coincide with the actual mistake (a builder missing its scheme), which is what the message `"scheme == null"` reports.
- **Kotlin does the same implicitly.** In `b()`, `Intrinsics.checkNotNull(scheme)` (`l.c`) is the compiler-inserted version of this check for the `!!` operator ([[Deriving-HttpUrl-Effective-Port-In-PressReader]]); in `q`'s constructor, `Intrinsics.checkNotNullParameter` (`l.f`) guards non-null parameters.
- **Throw sites are out of line.** The `if-eqz … :cond_6` branches jump to throw blocks at the end of the method; the fall-through path is the normal case — a layout compilers use to keep the common path straight.

## See also

- [[Operational-Semantics]]
- [[Object-And-Method-Semantics-Rules]]
- [[Dalvik-Instructions]] in [[Dalvik-Bytecode]]
- [[Java-Fundamentals-Reference|Reference]]
