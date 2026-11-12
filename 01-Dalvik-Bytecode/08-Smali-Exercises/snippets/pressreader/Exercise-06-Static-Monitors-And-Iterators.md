---
tags: [snippet, exercise]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/bp/m1.smali"
difficulty: "★★"
skills: "monitor-enter/monitor-exit, post-increment, declared-synchronized"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-06-Static-Monitors-And-Iterators

## Context

`bp.m1` keeps process-wide state in static fields: `r`, a `LinkedList` of pending server commands; `o`, a `HashMap` of server URLs; and `n`, an `lr.b` — an interface with `a(String)String`, `b()Z` and `isRunning()Z`. These three static methods are the thread-safe accessors around them. The class header shows the fields' generic signatures.

## Original path

`smali_classes2/bp/m1.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.class public final Lbp/m1;
.super Ljava/lang/Object;
.source "SourceFile"

# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lbp/m1$a;
    }
.end annotation

# static fields
.field public static final n:Llr/b;

.field public static final o:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field public static p:Ljava/lang/String;

.field public static q:Ljava/lang/Boolean;

.field public static final r:Ljava/util/LinkedList;

# instance fields
.field public final a:Ljava/lang/String;

.field public b:Ljava/lang/String;

.field public c:Z

.field public d:Z

.field public final e:Z

.field public final f:Landroid/sax/RootElement;

.field public final g:Landroid/sax/Element;

.field public final h:Ldx/b;

.field public i:Ldx/b;

.field public j:I

.field public k:Ljava/lang/String;

.field public final l:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Lcom/newspaperdirect/pressreader/android/devicemanagement/model/AccountDevice;",
            ">;"
        }
    .end annotation
.end field

.field public m:Ljava/lang/String;

.method public static c()Ljava/util/ArrayList;
    .locals 2

    sget-object v0, Lbp/m1;->r:Ljava/util/LinkedList;

    monitor-enter v0

    :try_start_0
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1, v0}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    monitor-exit v0

    return-object v1

    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method

.method public static h()[Ljava/lang/String;
    .locals 5

    sget-object v0, Lbp/m1;->o:Ljava/util/HashMap;

    invoke-virtual {v0}, Ljava/util/HashMap;->size()I

    move-result v1

    new-array v1, v1, [Ljava/lang/String;

    invoke-virtual {v0}, Ljava/util/HashMap;->keySet()Ljava/util/Set;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    const/4 v2, 0x0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    add-int/lit8 v4, v2, 0x1

    aput-object v3, v1, v2

    move v2, v4

    goto :goto_0

    :cond_0
    return-object v1
.end method

.method public static declared-synchronized n()Z
    .locals 2

    const-class v0, Lbp/m1;

    monitor-enter v0

    :try_start_0
    sget-object v1, Lbp/m1;->n:Llr/b;

    invoke-interface {v1}, Llr/b;->b()Z

    move-result v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    monitor-exit v0

    return v1

    :catchall_0
    move-exception v1

    monitor-exit v0

    throw v1
.end method
```

## Task

Rewrite `c`, `h` and `n` in Java.

## Check your reading

1. In `c`, the handler `:catchall_0` sits inside the very `:try_start_0 .. :try_end_0` range it handles. What does that achieve?
2. In `h`, what source statement compiles to `add-int/lit8 v4, v2, 0x1`, `aput-object v3, v1, v2`, `move v2, v4`?
3. `n` has the `declared-synchronized` flag *and* an explicit `monitor-enter` on `const-class Lbp/m1;`. Which of the two actually locks at runtime?
4. What does `h` iterate over, and what tells you the element type besides the `check-cast`?

> [!tip]- Hints
> - An enhanced `for` over an `Iterable` compiles to `iterator()`, then a `hasNext()`/`next()` loop.
> - Look up `ACC_SYNCHRONIZED` vs `ACC_DECLARED_SYNCHRONIZED` in the dex format specification.

> [!success]- Solution
> ```java
> public static ArrayList c() {
>     synchronized (r) {
>         return new ArrayList(r);
>     }
> }
>
> public static String[] h() {
>     String[] keys = new String[o.size()];
>     int i = 0;
>     for (String key : o.keySet()) {
>         keys[i++] = key;
>     }
>     return keys;
> }
>
> public static synchronized boolean n() {
>     return n.b();
> }
> ```
>
> **Answers**
>
> 1. If `monitor-exit` itself throws, the same handler catches it and tries `monitor-exit` again. javac generates this for every `synchronized` block so the lock is released on every path; it looks like a potential infinite loop but isn't reachable in practice.
> 2. `keys[i++] = key;`: the incremented copy is computed into a temporary first, the store uses the old index, then the temporary becomes the new index.
> 3. The explicit `monitor-enter`/`monitor-exit`. In dex, `declared-synchronized` has no effect on execution — the flag that makes the runtime lock (`synchronized`) is only valid on native methods — so D8 emits the locking as instructions.
> 4. `o.keySet()`, through `Set.iterator()` and a `hasNext()`/`next()` loop. The `Ldalvik/annotation/Signature;` on field `o` in the header records `HashMap<String, String>`, and the `check-cast Ljava/lang/String;` is that erased generic type being restored.

## See also

- [[Smali-Exercises]]
- [[Monitor-Enter-And-Monitor-Exit]]
- [[Methods]] — exception handling and `.catchall`
- [[Array-Length-And-New-Array]]
- [[Aget-And-Aput]]
- [[Reflection-and-Runtime-Internals]] — monitors in ART
- [[Dalvik-Bytecode-Reference|Reference]]
