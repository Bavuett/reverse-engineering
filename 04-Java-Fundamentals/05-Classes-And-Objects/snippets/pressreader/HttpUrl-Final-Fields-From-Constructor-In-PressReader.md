---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/w50/q.smali, constructor <init>(...)V, equals, hashCode (decompiled: Case-Studies/pressreader/source/java/w50/q.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# HttpUrl-Final-Fields-From-Constructor-In-PressReader

> [!info] Level 3 — real code
> A real immutable object built in one constructor: OkHttp's `HttpUrl` (PressReader's `w50.q`) checks two parameters *before* calling `super()`, writes ten `final` fields, and computes one of them from another — every step a heap update on the new object.

## Context

`HttpUrl` is created only by its builder ([[Blocked-Null-Checks-In-HttpUrl-Builder]]) and never changes afterwards; `equals`/`hashCode` rely on the canonical string field `i`. In PressReader, a forced stack trace through `w50.q.i()` (which turns it into a `java.net.URL`) was what led to identifying the class ([[Deobfuscating-Call-Chains-With-Forced-Stacktraces]]). Part of [[PressReader]].

## Original path

`smali_classes2/w50/q.smali` → `.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/util/ArrayList;Ljava/util/ArrayList;Ljava/lang/String;Ljava/lang/String;)V`

## Snippet

```smali
    .locals 1
    const-string v0, "scheme"
    invoke-static {p1, v0}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V   # scheme != null
    const-string v0, "host"
    invoke-static {p4, v0}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V   # host != null
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V          # super() — after the checks
    iput-object p1, p0, Lw50/q;->a:Ljava/lang/String;          # scheme
    iput-object p2, p0, Lw50/q;->b:Ljava/lang/String;          # username
    iput-object p3, p0, Lw50/q;->c:Ljava/lang/String;          # password
    iput-object p4, p0, Lw50/q;->d:Ljava/lang/String;          # host
    iput p5, p0, Lw50/q;->e:I                                 # port
    iput-object p6, p0, Lw50/q;->f:Ljava/util/List;            # pathSegments
    iput-object p7, p0, Lw50/q;->g:Ljava/util/List;            # queryNamesAndValues
    iput-object p8, p0, Lw50/q;->h:Ljava/lang/String;          # fragment
    iput-object p9, p0, Lw50/q;->i:Ljava/lang/String;          # url (canonical string)
    const-string p2, "https"
    invoke-virtual {p1, p2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z
    move-result p1
    iput-boolean p1, p0, Lw50/q;->j:Z                         # isHttps = scheme.equals("https")
    return-void
```

## Reconstructed source

```java
public q(String scheme, String username, String password, String host, int port,
         ArrayList pathSegments, ArrayList query, String fragment, String url) {
    Intrinsics.checkNotNullParameter(scheme, "scheme");
    Intrinsics.checkNotNullParameter(host, "host");
    super();                                  // (not legal Java syntax here; legal in bytecode)
    this.a = scheme;  this.b = username;  this.c = password;  this.d = host;  this.e = port;
    this.f = pathSegments;  this.g = query;  this.h = fragment;  this.i = url;
    this.j = scheme.equals("https");
}
public boolean equals(Object o) { return o instanceof q && Intrinsics.areEqual(((q) o).i, this.i); }
public int hashCode()            { return this.i.hashCode(); }
```

## Trace sketch — `new q("https", "", "", "example.org", 443, ℓ_p, null, null, "https://example.org/")`

```
(new)           ℓ_u fresh: θ(ℓ_u) = (q, {a…i ↦ null/0, j ↦ false})
checks          scheme ≠ null ✓, host ≠ null ✓          (otherwise: exception, object never escapes)
super()         Object.<init>
9 field-writes  θ(ℓ_u) = (q, {a↦"https", b↦"", c↦"", d↦"example.org", e↦443, f↦ℓ_p, g↦null, h↦null, i↦"https://…/", j↦false})
derived field   ⟨scheme.equals("https"), …⟩ →ₑ tt  ⇒  θ(ℓ_u).j = tt
```

## Notes

- **Checks before `super()`.** Bytecode allows instructions that don't use `this` before the superclass constructor; Kotlin places parameter null-checks there so a bad argument fails before the object is even initialized ([[Constructor-Execution-Order]]). Java source can't express this order directly.
- **Final fields = written once, in the constructor.** All ten fields are `final`; after `<init>` returns, no rule can change them. Immutability of the *object* still depends on what they point to: `f` is a list, so `HttpUrl` stays immutable only because nothing else modifies `ℓ_p` — the builder made a fresh copy for it ([[Path-Segment-Loops-In-PressReader-HttpUrl]]).
- **Derived state computed last.** `j` is computed from `a` after it's stored; it could equally read `p1` (as the bytecode does). Caching a derived value in a final field is safe precisely because its inputs can't change.
- **Identity vs equality.** Two `new q(…)` calls give two locations `ℓ₁ ≠ ℓ₂`; `==` compares locations (false), the overridden `equals` compares the `i` fields (true for the same URL). Which `equals` runs is decided by dynamic dispatch on the runtime class ([[Dynamic-Dispatch-Through-Overriding]], [[Short-Circuit-Equals-In-PressReader-HttpUrl]]).
- **Parameter registers.** Nine parameters plus `this` occupy `p0`–`p9`, so `.locals 1` suffices; the compiler even reuses `p1`/`p2` as scratch once their values are stored ([[Counting-Locals-And-Parameters]] in [[Dalvik-Bytecode]]).

## See also

- [[Classes-And-Objects]]
- [[Object-And-Method-Semantics-Rules]]
- [[Java-Fundamentals-Reference|Reference]]
