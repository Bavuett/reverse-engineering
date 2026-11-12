---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/bp/m1.smali, methods <clinit>()V and n()Z (decompiled: Case-Studies/pressreader/source/java/bp/m1.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Static-Initializer-Choosing-An-Implementation-In-PressReader

> [!info] Level 3 — real code
> A real `<clinit>` populating the library region: PressReader's `bp.m1` fills three static fields when the class is first used — one with an object whose *class* is chosen at runtime from a feature flag — and a `static synchronized` method later reads it under the class lock.

## Context

`bp.m1` is PressReader's XML API client ([[Discovering-The-Core-XML-Protocol]]). Its static state is shared by every request: a helper `n` of interface type `lr.b` (implemented by `h2` or `p2`), a string→string cache `o`, and the command queue `r`. Part of [[PressReader]].

## Original path

`smali_classes2/bp/m1.smali` → `.method static constructor <clinit>()V`, `.method public static declared-synchronized n()Z`; fields `.field public static final n:Llr/b;`, `o:Ljava/util/HashMap;`, `r:Ljava/util/LinkedList;`.

## Snippet

```smali
.method static constructor <clinit>()V
    .locals 1
    sget-object v0, Lzk/g;->a:Ljava/util/concurrent/atomic/AtomicBoolean;   # another class's static flag
    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z
    move-result v0
    if-eqz v0, :cond_0
    new-instance v0, Lbp/h2;                                 # flag true  -> h2
    invoke-direct {v0}, Ljava/lang/Object;-><init>()V
    goto :goto_0
    :cond_0
    new-instance v0, Lbp/p2;                                 # flag false -> p2
    invoke-direct {v0}, Lbp/p2;-><init>()V
    :goto_0
    sput-object v0, Lbp/m1;->n:Llr/b;
    new-instance v0, Ljava/util/HashMap;
    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V
    sput-object v0, Lbp/m1;->o:Ljava/util/HashMap;
    new-instance v0, Ljava/util/LinkedList;
    invoke-direct {v0}, Ljava/util/LinkedList;-><init>()V
    sput-object v0, Lbp/m1;->r:Ljava/util/LinkedList;
    return-void
.end method

.method public static declared-synchronized n()Z
    .locals 2
    const-class v0, Lbp/m1;
    monitor-enter v0                                          # lock = the class object
    :try_start_0
    sget-object v1, Lbp/m1;->n:Llr/b;
    invoke-interface {v1}, Llr/b;->b()Z                       # dispatch on h2 or p2
    move-result v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0
    monitor-exit v0
    return v1
    ...
.end method
```

## Reconstructed source

```java
public static final lr.b n = zk.g.a.get() ? new h2() : new p2();
public static final HashMap<String, String> o = new HashMap<>();
public static final LinkedList r = new LinkedList();

public static synchronized boolean n() { return n.b(); }
```

## State after `<clinit>` (flag false)

```
ρc(m1).statics = { n ↦ ℓ₁, o ↦ ℓ₂, p ↦ null, q ↦ null, r ↦ ℓ₃ }
ζ = { ℓ₁ ↦ (p2, …),  ℓ₂ ↦ (HashMap, {}),  ℓ₃ ↦ (LinkedList, []) }
```

`p` (a `String`) and `q` (a `Boolean`) have no initializer: they stay `null` until other code assigns them.

## Notes

- **Statics point into the heap.** The three objects are ordinary heap objects; what's in `ρc` is only the references. Because those references are roots, the objects live as long as the class ([[Garbage-And-Reachability]]).
- **Initialization order across classes.** Reading `zk.g.a` triggers `zk.g`'s own `<clinit>` first if it hasn't run — class initialization is lazy and recursive. The flag's value at that moment fixes `n` forever (`final`).
- **The static type is an interface, the runtime class varies.** `n` is declared `lr.b`; whether it holds an `h2` or a `p2` is decided once, at class initialization. Every `n.b()` call then dispatches on that runtime class via `invoke-interface` ([[Dynamic-Dispatch-Through-Overriding]]).
- **R8 inlined a constructor.** `new h2` is followed by `invoke-direct … Object;-><init>`, not `h2;-><init>`: `h2`'s own `<init>` does nothing but call `Object.<init>`, so R8 inlined it at this call site. `p2;-><init>` is still called, since it does real work. (`h2` also implements two unrelated interfaces besides `lr.b` — a sign of R8 class merging.)
- **One lock for the class.** `static synchronized` locks the class object (`const-class v0, Lbp/m1;`), so concurrent callers of `n()` are serialized — the static region is shared by all threads ([[Synchronized-Block-Locals-In-PressReader]]).

## See also

- [[Memory-Model]]
- [[Static-Fields-And-Class-Initialization]]
- [[Java-Fundamentals-Reference|Reference]]
