---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/w50/q$a.smali, constructor <init>()V (decompiled: Case-Studies/pressreader/source/java/w50/q.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Builder-Field-Initializers-And-Aliasing-In-PressReader

> [!info] Level 3 — real code
> A real constructor traced object-state by object-state: OkHttp's `HttpUrl.Builder()` (PressReader's `w50.q$a.<init>`) merges field initializers into `<init>`, then stores a new list in a field and mutates it through a second reference — aliasing in five instructions.

## Context

A fresh `HttpUrl.Builder` starts with empty username/password, port "unset" (`-1`), and a path containing one empty segment (so that the root path `/` prints correctly). Part of [[PressReader]]; class identity in [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]].

## Original path

`smali_classes2/w50/q$a.smali` → `.method public constructor <init>()V`

## Snippet

```smali
.method public constructor <init>()V
    .locals 2
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V        # super()
    const-string v0, ""
    iput-object v0, p0, Lw50/q$a;->b:Ljava/lang/String;      # encodedUsername = ""   (initializer)
    iput-object v0, p0, Lw50/q$a;->c:Ljava/lang/String;      # encodedPassword = ""   (initializer)
    const/4 v1, -0x1
    iput v1, p0, Lw50/q$a;->e:I                             # port = -1              (initializer)
    new-instance v1, Ljava/util/ArrayList;                  # body starts
    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V
    iput-object v1, p0, Lw50/q$a;->f:Ljava/util/ArrayList;   # this.f = list
    invoke-virtual {v1, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z   # list.add("")
    return-void
.end method
```

## Decompiled vs reconstructed

```java
// jadx
public String f46918b = BrazeConfigurationProvider.DEFAULT_NOTIFICATION_CHANNEL_DESCRIPTION_DEFAULT_VALUE;
public String f46919c = BrazeConfigurationProvider.DEFAULT_NOTIFICATION_CHANNEL_DESCRIPTION_DEFAULT_VALUE;
public int f46921e = -1;
public a() {
    ArrayList arrayList = new ArrayList();
    this.f46922f = arrayList;
    arrayList.add(BrazeConfigurationProvider.DEFAULT_NOTIFICATION_CHANNEL_DESCRIPTION_DEFAULT_VALUE);
}

// OkHttp (Kotlin) source, equivalent
class Builder {
    internal var encodedUsername = ""
    internal var encodedPassword = ""
    internal var port = -1
    internal val encodedPathSegments = mutableListOf<String>()
    init { encodedPathSegments.add("") }
}
```

## Trace

```
(new)            ℓ_b fresh       θ(ℓ_b) = (q$a, {a↦null, b↦null, c↦null, d↦null, e↦0, f↦null, g↦null, h↦null})
super()          Object.<init>
initializers     b = "", c = "", e = -1
                                 θ(ℓ_b) = (q$a, {…, b↦"", c↦"", e↦-1, f↦null, …})
body             list = new ArrayList()      θ += ℓ_l ↦ (ArrayList, [])        σ = {this↦ℓ_b, list↦ℓ_l}
(field-write)    this.f = list               θ(ℓ_b).f = ℓ_l                    ← two references to ℓ_l
(method-call)    list.add("")                θ(ℓ_l) = (ArrayList, [""])
result           θ(ℓ_b).f ↦ ℓ_l whose contents are [""]   — the write through `list` is visible through `this.f`
```

## Notes

- **Initializers first, body after.** The three initialized fields are written right after `super()`, before anything else — the order of [[Constructor-Execution-Order]]. Fields without initializers (`a` scheme, `d` host, `g` query, `h` fragment) keep their JVM default `null`.
- **Aliasing makes the code shorter.** After `iput-object v1, … ->f`, the field and register `v1` hold the same location; `add` is called through `v1` and the change shows through the field ([[Aliasing-Two-References-One-Object]]). The Kotlin source writes `encodedPathSegments.add("")`, i.e. through the field — equivalent, because both name `ℓ_l`.
- **One string object, three uses.** The single `const-string v0, ""` reference is stored in `b`, `c`, and added to the list. Strings are immutable, so sharing is safe — and literal strings are interned anyway.
- **The Braze constant is a decompiler illusion.** The smali loads a plain `""`; jadx displays it as `BrazeConfigurationProvider.DEFAULT_…` because that unrelated `static final String` has the same value. The semantics only sees the value `""` ([[Same-Method-Debug-Vs-R8-Release]] for more R8/decompiler artifacts).
- **`val` list, mutable contents.** `f` is a final field (assigned once), but the object it points to is mutable — "final reference" is not "immutable object". The builder relies on exactly this when later calls add segments.

## See also

- [[Classes-And-Objects]]
- [[Objects-On-The-Heap]]
- [[Java-Fundamentals-Reference|Reference]]
