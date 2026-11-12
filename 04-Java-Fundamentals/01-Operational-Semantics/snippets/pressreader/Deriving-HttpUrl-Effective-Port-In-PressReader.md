---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/w50/q$a.smali, method b()I (decompiled: Case-Studies/pressreader/source/java/w50/q.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Deriving-HttpUrl-Effective-Port-In-PressReader

> [!info] Level 3 — real code
> A full big-step derivation for a real method: the effective-port computation of OkHttp's `HttpUrl.Builder`, bundled and renamed `w50.q$a.b()` in PressReader, evaluated in two concrete states and set beside its Dalvik listing.

## Context

`w50.q` was identified as OkHttp's `HttpUrl` in the PressReader investigation ([[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]]); `w50.q$a` is its `Builder`. Method `b()` returns the explicit port if one was set (`-1` means "unset"), otherwise the scheme's default. It's small, side-effect-free, and has three exits — ideal for deriving by hand. Part of [[PressReader]].

## Original path

`smali_classes2/w50/q$a.smali` → `.method public final b()I` (fields: `e:I` = port, `a:Ljava/lang/String;` = scheme).

## Snippet

```smali
.method public final b()I
    .locals 3
    iget v0, p0, Lw50/q$a;->e:I                 # port
    const/4 v1, -0x1
    if-eq v0, v1, :cond_0                       # port == -1 ?
    goto :goto_0                                #   no: return port
    :cond_0
    iget-object v0, p0, Lw50/q$a;->a:Ljava/lang/String;
    invoke-static {v0}, Lkotlin/jvm/internal/l;->c(Ljava/lang/Object;)V   # scheme!! (null check)
    const-string v2, "http"
    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :cond_1
    const/16 v0, 0x50                           # 80
    goto :goto_0
    :cond_1
    const-string v2, "https"
    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :cond_2
    const/16 v0, 0x1bb                          # 443
    goto :goto_0
    :cond_2
    move v0, v1                                 # -1
    :goto_0
    return v0
.end method
```

## Reconstructed source

```java
public final int b() {                     // OkHttp: HttpUrl.Builder.effectivePort()
    int port = this.e;
    if (port != -1) return port;
    String scheme = this.a;  Intrinsics.checkNotNull(scheme);
    if (scheme.equals("http")) return 80;
    return scheme.equals("https") ? 443 : -1;
}
```

Treating the body as the core-language expression `E = (port != -1) ? port : (s == "http" ? 80 : (s == "https" ? 443 : -1))`, with string equality as a primitive relation.

## Derivation 1 — `σ₁ = {port ↦ -1, s ↦ "https"}`

```
  ⟨port,σ₁⟩→ₑ-1  ⟨-1,σ₁⟩→ₑ-1  (-1 ≠ -1) = ff
  ─────────────────────────────────────── (rel)
        ⟨port != -1, σ₁⟩ →ₑ ff                                   ⟨s == "http", σ₁⟩ →ₑ ff   (rel)
                                                                 ⟨s == "https", σ₁⟩ →ₑ tt  (rel)   ⟨443,σ₁⟩→ₑ443
                                                                 ──────────────────────────────────────── (cond-tt)
                                                                   ⟨s == "https" ? 443 : -1, σ₁⟩ →ₑ 443
                                                                 ──────────────────────────────────────── (cond-ff)
                                                                   ⟨s == "http" ? 80 : …, σ₁⟩ →ₑ 443
  ──────────────────────────────────────────────────────────────────────────────────────────── (cond-ff)
                                     ⟨E, σ₁⟩ →ₑ 443
```

## Derivation 2 — `σ₂ = {port ↦ 8080, s ↦ "http"}`

```
  ⟨port != -1, σ₂⟩ →ₑ tt  (rel)     ⟨port, σ₂⟩ →ₑ 8080  (ide)
  ──────────────────────────────────────────────────── (cond-tt)
                 ⟨E, σ₂⟩ →ₑ 8080
```

The scheme is never examined: the `(cond-tt)` rule has no premise for the else-branch.

## Notes

- **The conditional-expression rules** used here follow the pattern of `(if-tt)`/`(if-ff)` at expression level: `(cond-tt)` needs the guard `tt` and the then-value only; `(cond-ff)` the guard `ff` and the else-value only ([[Short-Circuit-As-Nested-Conditionals]]).
- **Derivation shape = control-flow shape.** Derivation 1 goes down the else-spine three times — in the smali, the path `if-eq` fails → `:cond_0` → `if-eqz` taken → `:cond_1` → `if-eqz` not taken → `443`. Derivation 2 is the one-premise shortcut — the `goto :goto_0` right after `if-eq`.
- **Small-step vs big-step.** The listing is the small-step view: one instruction per step on registers `v0`–`v2`. The tree is the big-step view of the same evaluation ([[Small-Step-Vs-Big-Step-On-One-Expression]]).
- **A blocked case.** In `σ₃ = {port ↦ -1, s ↦ null}`, `Intrinsics.checkNotNull` throws — the Kotlin `!!` makes the `null ≠ null` side condition explicit before `equals` would fail ([[Blocked-Null-Checks-In-HttpUrl-Builder]]).
- **Equivalent shapes.** Source-level `return` inside `if` became a single shared `return v0` reached by `goto :goto_0` — an equivalent rewriting of the same conditional ([[Semantic-Equivalence-Of-Two-Fragments]]).

## See also

- [[Operational-Semantics]]
- [[Deriving-An-Arithmetic-Expression]]
- [[If-Else-And-Comparisons]] in [[Dalvik-Bytecode]]
- [[Java-Fundamentals-Reference|Reference]]
