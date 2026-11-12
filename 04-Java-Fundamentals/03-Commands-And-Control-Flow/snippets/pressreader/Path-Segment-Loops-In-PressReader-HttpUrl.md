---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/w50/q$a.smali, methods toString() and a()Lw50/q; (decompiled: Case-Studies/pressreader/source/java/w50/q.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Path-Segment-Loops-In-PressReader-HttpUrl

> [!info] Level 3 — real code
> Two real loops over the same list in OkHttp's `HttpUrl.Builder` (PressReader's `w50.q$a`): an index-based `for` in `toString()` and an iterator `for-each` in `build()` — each read back from its smali to the `{ init; while (guard) { body; update; } }` desugaring.

## Context

The builder keeps the URL path as a list of segments (field `f`). `toString()` prints them as `/seg1/seg2…`; `build()` copies them into a new list, canonicalizing each. Part of [[PressReader]]; identity in [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]].

## Original path

`smali_classes2/w50/q$a.smali` → `toString()Ljava/lang/String;` (loop excerpt) and `a()Lw50/q;` (loop excerpt).

## Snippet 1 — index loop in `toString()`

```smali
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I     # v1 = this.f (segments)
    move-result v2                                          # size, evaluated once
    const/4 v3, 0x0                                         # init:   i = 0
    :goto_4
    if-ge v3, v2, :cond_b                                   # guard:  exit when !(i < size)
    const/16 v4, 0x2f                                       # '/'
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v4
    check-cast v4, Ljava/lang/String;
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    add-int/lit8 v3, v3, 0x1                                # update: i++
    goto :goto_4                                            # back-edge
    :cond_b
```

```java
int size = arrayList.size();
for (int i = 0; i < size; i++) { sb.append('/'); sb.append((String) arrayList.get(i)); }
```

## Snippet 2 — iterator loop in `build()`

```smali
    iget-object v0, p0, Lw50/q$a;->f:Ljava/util/ArrayList;
    new-instance v8, Ljava/util/ArrayList;                  # result list
    ...
    invoke-virtual {v0}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;
    move-result-object v0                                   # init:   it = f.iterator()
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z
    move-result v9
    if-eqz v9, :cond_0                                      # guard:  it.hasNext()
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v9                                   # body:   String s = it.next();
    check-cast v9, Ljava/lang/String;
    invoke-static {v9, v2, v2, v2, v3}, Lw50/q$b;->c(Ljava/lang/String;IIZI)Ljava/lang/String;
    move-result-object v9
    invoke-virtual {v8, v9}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    goto :goto_0
    :cond_0
```

```java
for (String s : this.f) out.add(b.c(s, 0, 0, false, 7));
//  ≡  { Iterator it = this.f.iterator(); while (it.hasNext()) { String s = it.next(); out.add(…); } }
```

## Derivation sketch — `toString()` loop with segments `["api", "v1"]`

```
(block)      push ω; int i = 0                    {i↦0} · {size↦2, sb↦ℓ_sb, …}
(while-tt)   0 < 2;  sb: "…" + "/api";  i = 1      {i↦1} · …
(while-tt)   1 < 2;  sb: "…/api" + "/v1"; i = 2    {i↦2} · …
(while-ff)   2 < 2 = ff
(block)      pop {i↦2}                             sb now holds "…/api/v1"
```

The appends change the `StringBuilder` object on the heap (`ℓ_sb`); only `i` changes on the stack.

## Notes

- **The guard's bound is hoisted.** `size()` is called once, before the loop, and kept in `v2` — so the guard is `i < size` with a fixed `size`, equivalent to `i < list.size()` only because the body doesn't modify the list. This is a Kotlin `for (i in 0 until size)` compiled straight; in Java source it's the classic "cache the length" idiom.
- **Two desugarings, one shape.** Both loops are `init; :loop; guard → exit; body; update; goto :loop`. In the iterator form the "update" is folded into the body (`it.next()` advances), and the guard is a method call ([[For-Loop-As-Desugared-While]]).
- **`check-cast` after `get`/`next`.** Generic `ArrayList<String>` is erased to `Object` in bytecode; the cast restores the static type ([[Generics-Erasure-And-Signature-Annotations]] in [[Dalvik-Bytecode]]).
- **Same back-edge, same rule.** Each `goto :goto_4` / `goto :goto_0` is one more recursive premise of `(while-tt)` ([[Evaluating-A-While-Loop]]).
- **Register reuse across loops.** In `build()`, `v0` holds the list, then its iterator; `v9` holds the guard boolean, then the element. Registers are storage, not variables — scope is a source-level notion ([[Branch-Assigned-Locals-In-PressReader-HttpUrl-Builder]]).

## See also

- [[Commands-And-Control-Flow]]
- [[For-Loop-Over-An-Array]] in [[Dalvik-Bytecode]]
- [[Java-Fundamentals-Reference|Reference]]
