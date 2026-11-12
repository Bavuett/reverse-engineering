---
tags: [example]
level: 2
aliases: ["shallow copy vs deep copy", "defensive copy", "copy constructor semantics"]
created: 2026-11-12
---

# Example: Copying-References-Vs-Copying-Objects

> [!info] Level 2 — intermediate
> Combines aliasing with allocation: `y = x` copies a reference, `new ArrayList(x)` copies the *list object* (a new location) but not the elements, and only an explicit element-by-element copy duplicates everything. Each choice leaves a different heap shape.

## Goal

Draw the heap after three kinds of "copy" of a list of mutable objects, and predict which later writes each copy observes. Belongs to [[Memory-Model]].

## Program

```java
class Item { int qty; }
List<Item> orig = new ArrayList<>();  orig.add(new Item());     // list ℓ_L, item ℓ_i (qty 0)

List<Item> alias   = orig;                                       // 1. reference copy
List<Item> shallow = new ArrayList<>(orig);                      // 2. shallow copy
List<Item> deep    = new ArrayList<>();                          // 3. deep copy
for (Item it : orig) { Item c = new Item(); c.qty = it.qty; deep.add(c); }

orig.get(0).qty = 5;      // write to the shared element
orig.add(new Item());     // structural change to the original list
```

## Heap after the copies (before the writes)

```
σ:  orig ↦ ℓ_L   alias ↦ ℓ_L   shallow ↦ ℓ_S   deep ↦ ℓ_D
ζ:  ℓ_L ↦ (ArrayList, [ℓ_i])
    ℓ_S ↦ (ArrayList, [ℓ_i])        ← new list, same element reference
    ℓ_D ↦ (ArrayList, [ℓ_c])        ← new list, new element
    ℓ_i ↦ (Item, {qty ↦ 0})     ℓ_c ↦ (Item, {qty ↦ 0})
```

## Who sees which write

| Copy | sees `qty = 5`? | sees the added item? | Why |
| --- | --- | --- | --- |
| `alias` | yes | yes | same list `ℓ_L` |
| `shallow` | yes | no | own list `ℓ_S`, but its element is still `ℓ_i` |
| `deep` | no | no | own list, own element `ℓ_c` |

## Step by step

1. **Assignment copies values; a reference's value is a location.** `alias = orig` adds a binding to `ℓ_L` and allocates nothing ([[Aliasing-Two-References-One-Object]]).
2. **A copy constructor allocates one new object.** `new ArrayList<>(orig)` creates `ℓ_S` and copies the *element references* into it — the semantic meaning of "shallow".
3. **Deep copy allocates per element.** Only code that creates new `Item` objects (`new Item()` per element) separates the element state.
4. **Choose by what must be protected.** Shallow copies protect against structural changes (add/remove) — the common need when handing a snapshot to another thread. Deep copies protect element state too, at higher cost.
5. **Immutable elements make shallow = deep.** For a list of `String`s, sharing element references is harmless because no write to an element exists.

## Compared with real code

- [[Static-Command-Queue-Outliving-Its-Producer-In-PressReader]] — a real shallow snapshot (`new ArrayList(queue)`) taken under a lock.
- [[Path-Segment-Loops-In-PressReader-HttpUrl]] in [[Commands-And-Control-Flow]] — a real element-by-element copy that transforms each element on the way.

## See also

- [[Memory-Model]]
- [[Garbage-And-Reachability]]
- [[Tracing-A-Value-Through-The-Three-Regions]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
