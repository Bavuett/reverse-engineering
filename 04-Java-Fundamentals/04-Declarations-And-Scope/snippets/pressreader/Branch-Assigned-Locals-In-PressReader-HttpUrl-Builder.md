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

# Branch-Assigned-Locals-In-PressReader-HttpUrl-Builder

> [!info] Level 3 — real code
> Real locals in OkHttp's `HttpUrl.Builder.build()` (PressReader's `w50.q$a.a()`): one declared without initializer and assigned on both branches, and registers that carry several different source variables over the method's lifetime.

## Context

`build()` converts the builder's mutable fields into the arguments of an immutable `HttpUrl`. The query (field `g`) is optional: if present, a canonicalized copy is built; otherwise the result is `null`. Part of [[PressReader]]; see also [[Blocked-Null-Checks-In-HttpUrl-Builder]] for the method's first lines.

## Original path

`smali_classes2/w50/q$a.smali` → `.method public final a()Lw50/q;` (`.locals 14`).

## Snippet — the optional query

```smali
    iget-object v0, p0, Lw50/q$a;->g:Ljava/util/ArrayList;    # v0 := this.g   (v0 was the segment iterator just before)
    const/4 v9, 0x0                                          # v9 := null     (shared "null" for later)
    if-eqz v0, :cond_2                                       # query == null ?
    new-instance v10, Ljava/util/ArrayList;                  # then: v10 = new ArrayList(...)
    ...                                                      #   loop :goto_1 adds canonicalized-or-null per item
    ...                                                      #   and exits with "if-eqz v11, :cond_3" (hasNext false)
    :cond_2
    move-object v10, v9                                      # else: v10 = null
    :cond_3
    iget-object v0, p0, Lw50/q$a;->h:Ljava/lang/String;      # v0 := this.h (fragment) — third meaning of v0
    if-eqz v0, :cond_4
    invoke-static {v0, v2, v2, v2, v3}, Lw50/q$b;->c(Ljava/lang/String;IIZI)Ljava/lang/String;
    move-result-object v0
    move-object v9, v0                                       # v9 := canonical fragment (else stays null)
    :cond_4
```

## Decompiled

```java
ArrayList arrayList;                                       // declared, no initializer
ArrayList<String> arrayList4 = this.f46923g;
if (arrayList4 != null) {
    arrayList = new ArrayList(o10.n.E(arrayList4));        // assigned on the then-branch
    for (String str3 : arrayList4)
        arrayList.add(str3 != null ? b.c(str3, 0, 0, true, 3) : null);
} else {
    arrayList = null;                                      // assigned on the else-branch
}
String str4 = this.f46924h;
return new q(..., arrayList, str4 != null ? b.c(str4, 0, 0, false, 7) : null, toString());
```

## Trace sketch (query present: `g ↦ ℓ_g` with items `["a=1"]`)

```
(decl)        ArrayList arrayList;              {arrayList↦$, …}
(decl-init)   arrayList4 = this.g               {arrayList↦$, arrayList4↦ℓ_g, …}
(if-tt)       arrayList4 != null →ₑ tt
  (assign)    arrayList = new ArrayList(1)      {arrayList↦ℓ_q, …}      θ += ℓ_q ↦ (ArrayList, [])
  (loop)      one item: add "a=1" (canonical)   θ(ℓ_q) = (ArrayList, ["a=1"])
(decl-init)   str4 = this.h                     …
```

With `g ↦ null`, `(if-ff)` takes `arrayList = null` instead; in both cases `arrayList` is definitely assigned before `new q(…)` reads it.

## Notes

- **Definite assignment, in real code.** `ArrayList arrayList;` holds `$` until one of the two branches assigns it — the [[Declaration-Without-Initializer]] pattern. Kotlin's source was an expression (`val q = g?.map { … }`); Java needs a declared-then-assigned local to express the same thing.
- **One register, three variables.** `v0` holds the segment iterator (previous loop), then field `g`, then field `h` and its canonical form. Their *scopes* overlap in the source, but their *lifetimes* in the bytecode don't ([[Scope-Vs-Lifetime-In-Registers]]).
- **A shared `null` register.** `v9` is set to `null` once and used both for the "no query" case (`move-object v10, v9`) and as the default fragment — a register used as a constant, not a variable.
- **`.locals 14`** reflects the maximum number of values live at once (nine constructor arguments plus temporaries), not the number of source variables.
- **The conditional element** `str3 != null ? … : null` inside the loop is a conditional expression ([[Short-Circuit-As-Nested-Conditionals]]); in smali it's `if-eqz v11, :cond_1` / `move-object v11, v9`.

## See also

- [[Declarations-And-Scope]]
- [[Path-Segment-Loops-In-PressReader-HttpUrl]] in [[Commands-And-Control-Flow]]
- [[Java-Fundamentals-Reference|Reference]]
