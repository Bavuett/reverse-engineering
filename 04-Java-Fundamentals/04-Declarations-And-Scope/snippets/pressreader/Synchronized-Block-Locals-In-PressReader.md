---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/bp/m1.smali, methods c()Ljava/util/ArrayList; and n()Z (decompiled: Case-Studies/pressreader/source/java/bp/m1.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Synchronized-Block-Locals-In-PressReader

> [!info] Level 3 — real code
> A real `synchronized` block whose decompiled form declares a local *outside* the block — a declaration that doesn't exist in the bytecode. Comparing the two shows the decompiler choosing a scope to make Java's rules work, and how a block's frame relates to a monitor region.

## Context

`bp.m1` keeps a static queue of server commands (`r`, a `LinkedList`). `c()` returns a snapshot copy, taken while holding the queue's lock so no other thread modifies it mid-copy. Part of [[PressReader]]; the class is described in [[Discovering-The-Core-XML-Protocol]].

## Original path

`smali_classes2/bp/m1.smali` → `.method public static c()Ljava/util/ArrayList;` and `.method public static declared-synchronized n()Z`.

## Snippet

```smali
.method public static c()Ljava/util/ArrayList;
    .locals 2
    sget-object v0, Lbp/m1;->r:Ljava/util/LinkedList;     # the lock object (and the list)
    monitor-enter v0
    :try_start_0
    new-instance v1, Ljava/util/ArrayList;
    invoke-direct {v1, v0}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V
    monitor-exit v0
    return-object v1                                     # returns from inside the region
    :catchall_0
    move-exception v1
    monitor-exit v0                                      # release the lock on any exception
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0
    throw v1
.end method
```

## Decompiled (jadx) vs reconstructed source

```java
// jadx output
public static ArrayList c() {
    ArrayList arrayList;                       // declared outside the block...
    LinkedList linkedList = f8638r;
    synchronized (linkedList) {
        arrayList = new ArrayList(linkedList); // ...assigned inside
    }
    return arrayList;                          // ...read after
}

// what the bytecode actually says
public static ArrayList c() {
    synchronized (r) {
        return new ArrayList(r);
    }
}
```

## Trace (jadx form) from `σ = Ω` (static method: empty frame), `θ(ℓ_r) = (LinkedList, [cmd₁])`

```
(decl)        ArrayList arrayList;          {arrayList↦$} · Ω
(decl-init)   linkedList = r                {arrayList↦$, linkedList↦ℓ_r} · Ω
(block)       synchronized body: push ω     ω · {arrayList↦$, linkedList↦ℓ_r} · Ω
(assign)      arrayList = new ArrayList(..) ω · {arrayList↦ℓ_c, …} · Ω     θ += ℓ_c ↦ (ArrayList, [cmd₁])
(block)       pop ω                         {arrayList↦ℓ_c, linkedList↦ℓ_r} · Ω
              return arrayList → ℓ_c
```

## Notes

- **Why jadx hoists the declaration.** Its decompiler builds structured `synchronized` blocks from the monitor region and then needs the result to be usable after the block. Declaring `arrayList` outside and assigning inside is the `(decl)` + `(assign)` pattern of [[Declaration-Without-Initializer]]: legal Java, definitely assigned, same meaning.
- **The bytecode has no such variable.** The new list lives only in `v1`, and the method returns *from inside* the monitor region (after `monitor-exit`). Both Java versions are equivalent ([[Semantic-Equivalence-Of-Two-Fragments]]); the second is closer to the bytecode.
- **A block is also a lock region.** `synchronized (x) { … }` is a block (fresh frame, popped at exit) plus `monitor-enter`/`monitor-exit` around it. The `catchall` handler guarantees the exit happens even if the body throws — the bytecode version of "the frame is popped however the block ends".
- **`declared-synchronized` methods.** `n()` is `static synchronized`: its smali header says `declared-synchronized`, and the body brackets the call with `monitor-enter`/`monitor-exit` on `const-class v0, Lbp/m1;` — the class object is the lock for static synchronized methods.
- **The copy is a new heap object.** `new ArrayList(r)` copies the *references* in the queue, not the command objects ([[Copying-References-Vs-Copying-Objects]]).

## See also

- [[Declarations-And-Scope]]
- [[Nested-Blocks-And-Shadowing]]
- [[Static-Command-Queue-Outliving-Its-Producer-In-PressReader]] in [[Memory-Model]]
- [[Java-Fundamentals-Reference|Reference]]
