---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "Case-Studies/pressreader/source/java/bp/m1.java, methods k() and c() (smali: smali_classes2/bp/m1.smali)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Static-Command-Queue-Outliving-Its-Producer-In-PressReader

> [!info] Level 3 — real code
> Objects created in an instance method, stored in a static collection, and read back later by a static method: PressReader's server-command queue shows the three regions cooperating — and why the commands outlive both the frame and the object that created them.

## Context

When a response contains `<command name="…">` elements, `m1.k()` turns each into an `m1$a` object and appends it to the static queue `r`; later, `c()` returns a snapshot and `j(Service)` consumes `ReloadCatalog` commands ([[Discovering-The-Core-XML-Protocol]]). The `m1` instance that parsed the response is short-lived — one per request. Part of [[PressReader]].

## Original path

`Case-Studies/pressreader/source/java/bp/m1.java` → `k()` and `c()`; bytecode for `c()` in [[Synchronized-Block-Locals-In-PressReader]].

## Snippet

```java
// instance method, runs once per parsed response
public final void k() {
    for (dx.b bVar : this.f8646h.f19629f) {              // children of the parsed document
        if (bVar.f19624a.equals("command")) {
            a aVar = new a();                            // new heap object
            aVar.a(bVar.c("name"));                      // kind from the name attribute
            aVar.f8652b = bVar.f19629f.get(0).f19625b;   // payload from the <data> child
            LinkedList linkedList = f8638r;              // the static queue
            synchronized (linkedList) {
                linkedList.add(aVar);                    // now reachable from a static root
            }
        } else if (bVar.f19624a.equals("response")) {
            ...                                          // error-code / error-message onto this
        }
    }
}

// static method, called at any later time
public static ArrayList c() {
    synchronized (f8638r) { return new ArrayList(f8638r); }   // shallow snapshot
}
```

## Regions over time

```
during k() on request object ℓ_req:
  σ:  { this ↦ ℓ_req, bVar ↦ ℓ_x, aVar ↦ ℓ_cmd, linkedList ↦ ℓ_r } · …
  ζ:  ℓ_req ↦ (m1, {h ↦ ℓ_doc, …})   ℓ_cmd ↦ (m1$a, {a ↦ ReloadCatalog, b ↦ "…"})
      ℓ_r ↦ (LinkedList, [ℓ_cmd])
  ρc: m1.r ↦ ℓ_r

after k() returns and the request object is dropped:
  σ:  (k's frame popped; nobody holds ℓ_req)
  reachable from roots:   ρc: m1.r → ℓ_r → ℓ_cmd           ← the command survives
  garbage:                ℓ_req, ℓ_doc, ℓ_x               ← the producer is gone

later, c():
  σ:  { arrayList ↦ ℓ_snap }
  ζ:  ℓ_snap ↦ (ArrayList, [ℓ_cmd])   ← new list, same command object
```

## Notes

- **Reachability decides lifetime, not creation site.** `ℓ_cmd` is created in a frame of `k()` and referenced by its local `aVar`, but once added to `ℓ_r` it's reachable from the static root `m1.r`. Popping `k()`'s frame and dropping the `m1` instance don't affect it ([[Garbage-And-Reachability]]).
- **A per-iteration local.** `aVar` is declared inside the loop body: a fresh binding each iteration, discarded at the end of the iteration — its only lasting effect is the reference stored in the queue ([[Loop-Body-Block-Per-Iteration]]).
- **Shared across threads.** Every `m1` instance and any thread can reach `r`, so both the `add` and the snapshot are done inside `synchronized (r)`. Without the lock, `new ArrayList(r)` could observe the list mid-modification.
- **Snapshot = shallow copy.** `c()` returns a new list whose elements are the same `m1$a` objects ([[Copying-References-Vs-Copying-Objects]]). A caller can iterate it without holding the lock, but changing a command's fields through it would change the queued command too.
- **Leak potential.** Commands are removed only when consumed (`j(Service)` pops the first `ReloadCatalog`). Anything never consumed stays reachable for the lifetime of the class — a typical static-collection leak, harmless here because the queue is small.

## See also

- [[Memory-Model]]
- [[Static-Initializer-Choosing-An-Implementation-In-PressReader]] — where `r` is created
- [[Command-Kind-If-Chain-In-PressReader]] in [[Commands-And-Control-Flow]] — what `aVar.a(...)` does
- [[Java-Fundamentals-Reference|Reference]]
