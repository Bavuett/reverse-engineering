---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/w50/q$a.smali, methods a()Lw50/q;, b()I, toString() (decompiled: Case-Studies/pressreader/source/java/w50/q.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Call-Chain-Frames-In-PressReader-HttpUrl-Builder

> [!info] Level 3 — real code
> A real call chain three frames deep: OkHttp's `HttpUrl.Builder.build()` (PressReader's `w50.q$a.a()`) calls `b()` (effective port), which calls `String.equals`; later it calls `toString()`, which calls `b()` again. Each call is a fresh frame on the same receiver, and only values and heap effects come back.

## Context

The builder's methods call each other on `this`. Following the frames shows which state each method can see: all of them reach the builder's fields through `this` (the heap), none can see the others' locals. Part of [[PressReader]]; method bodies in [[Deriving-HttpUrl-Effective-Port-In-PressReader]] and [[Path-Segment-Loops-In-PressReader-HttpUrl]].

## Original path

`smali_classes2/w50/q$a.smali` → `a()Lw50/q;` (call sites), `b()I`, `toString()Ljava/lang/String;`.

## Snippet — call sites in `build()`

```smali
    invoke-virtual {p0}, Lw50/q$a;->b()I                      # port = this.b()
    move-result v7
    ...
    invoke-virtual {p0}, Lw50/q$a;->toString()Ljava/lang/String;   # url = this.toString()
    move-result-object v11
    new-instance v12, Lw50/q;
    ...                                                      # new q(v1, v4, v5, v6, v7, v8, v10, v9, v11)
```

and in `b()`:

```smali
    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z   # scheme.equals("http")
    move-result v2
```

## Frames for `build()` on a builder `ℓ_b` with scheme `"https"`, port `-1`

```
build():            {this ↦ ℓ_b}                                   ← frame 1
  b():              {this ↦ ℓ_b} · (frame 1 suspended)             ← frame 2, same receiver
    "https".equals("http"):  {this ↦ ℓ_s, o ↦ ℓ_"http"}             ← frame 3: receiver is the String
    returns ff → frame 3 popped
    "https".equals("https") → tt (frame 3′, popped)
  b() returns 443 → frame 2 popped;  build's v7 = 443
  toString():       {this ↦ ℓ_b}                                   ← frame 2′
    b():            {this ↦ ℓ_b}                                   ← frame 3″, called again
    returns 443;    toString omits ":443" (default for https)
  toString() returns "https://…" → build's v11
  new q(…)          constructor frame {this ↦ ℓ_u, scheme ↦ …, …}
build() returns ℓ_u
```

## Notes

- **Same receiver, separate frames.** `b()` and `toString()` run with `this ↦ ℓ_b` like `build()`, but each has its own frame (and own `p0`/`v` registers). They communicate only through fields of `ℓ_b` and return values ([[A-Method-Call-Frame]]).
- **The receiver changes along the chain.** Inside `equals` the receiver is the scheme *string*: `(method-call)` evaluates `scheme` to `ℓ_s` and binds `this ↦ ℓ_s`. `this` is per-frame, not per-object-graph.
- **`b()` runs twice.** Once for the port argument, once inside `toString()` to decide whether to print it. Calling a side-effect-free method twice is equivalent to calling it once and reusing the value ([[Semantic-Equivalence-Of-Two-Fragments]]) — which is why it's harmless here, and why an optimizer *could* merge them only after proving `b()` pure.
- **Stack depth = derivation nesting.** The deepest point (frame 3) corresponds to the deepest premise in the derivation of `build()`. No recursion here, but the same push/pop discipline as [[Recursive-Factorial-Frame-By-Frame]].
- **What a stack trace shows.** A Frida-forced stack trace taken inside `equals` would read `String.equals ← w50.q$a.b ← w50.q$a.a ← …` — exactly the suspended frames above. That's the technique behind [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]].

## See also

- [[Methods-And-Recursion]]
- [[Object-And-Method-Semantics-Rules]]
- [[Java-Fundamentals-Reference|Reference]]
