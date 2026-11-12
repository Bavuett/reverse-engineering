---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali/bp/m1.smali"
date_added: 2026-09-06
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Final-Instance-Methods-Still-Dispatch-Virtually

## Context

`bp.m1` — PressReader's core XML API manager (see [[Discovering-The-Core-XML-Protocol]]) — is declared `public final class m1` in Java, and its raw `baksmali` output shows every one of its real instance methods (`e`, `f`, `k`, `l`, `m`) individually marked `.method public final` too, redundant with the class-level flag but explicit in the bytecode. `l()`'s own body calls `m()` — a same-class, final-to-final call, about as "resolved" as a virtual call could ever be — which makes it a clean real instance of [[Methods]]'s point that `final` changes nothing about *how* a call is compiled: it's still `invoke-virtual`, not `invoke-direct`.

## Original path

`smali/bp/m1.smali` (see [[PressReader]]; full file under `Case-Studies/pressreader/source/smali/`)

## Snippet

```smali
.class public final Lbp/m1;

.method public final l(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;)V
    .registers 4

    const/16 v0, 0x7530

    invoke-virtual {p0, p1, p2, v0, v0}, Lbp/m1;->m(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;II)V

    return-void
.end method

.method public final m(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;II)V
    .registers 26
    # ... body elided (1,245 instruction units — too large for JADX to reconstruct as Java at all,
    # see [[Discovering-The-Core-XML-Protocol]]) ...
.end method
```

## Notes

`l()` hardcodes `0x7530` (30000, a millisecond timeout) into both of `m()`'s trailing `int` parameters and calls it with `invoke-virtual {p0, p1, p2, v0, v0}, Lbp/m1;->m(...)V` — `p0` is `this`, so this is an ordinary same-object method call, yet it still goes through a vtable lookup rather than being resolved directly, purely because `m()` is a public instance method and Dalvik has no separate "I happen to know this exact call can only reach one implementation" opcode. Contrast this with the static-method call sites elsewhere in the same file (`bp.m1.a`, `b`, `c`, `d`, `g`, `h`, `i`, `j`, `n` — none of them marked `final`, since `final` on a `static` method would be meaningless: static methods were never virtual to begin with) — those compile to `invoke-static`, a genuinely different resolution rule, not just a different-looking annotation on an otherwise-identical `invoke-virtual`. See [[Invoke-Direct-Static-Virtual-Interface]] for the full breakdown of which `invoke-*` kind each method shape gets.

## See also

- [[Methods]]
- [[Invoke-Direct-Static-Virtual-Interface]]
- [[Exercise-03-Authentication-Block-Builder]] — `bp.m1.e(Service)`, another `.method public final` on the same class
- [[Dalvik-Bytecode-Reference|Reference]]
