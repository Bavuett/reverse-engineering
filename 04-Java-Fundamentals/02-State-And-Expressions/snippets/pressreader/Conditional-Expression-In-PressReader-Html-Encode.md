---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/bp/m1.smali, method i(Ljava/lang/String;)Ljava/lang/String; (decompiled: Case-Studies/pressreader/source/java/bp/m1.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Conditional-Expression-In-PressReader-Html-Encode

> [!info] Level 3 — real code
> The smallest real conditional expression: PressReader's `m1.i(String)` returns its argument unchanged when empty and HTML-encoded otherwise — one guard, two branches, and a register reused for the result.

## Context

`bp.m1` is PressReader's XML request/response client ([[Discovering-The-Core-XML-Protocol]]). Before inserting user-controlled strings (service name, user name) into the XML request, `e(Service)` passes them through `i(...)`, which escapes `<`, `>`, `&`, quotes. Part of [[PressReader]].

## Original path

`smali_classes2/bp/m1.smali` → `.method public static i(Ljava/lang/String;)Ljava/lang/String;`

## Snippet

```smali
.method public static i(Ljava/lang/String;)Ljava/lang/String;
    .locals 1
    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z
    move-result v0
    if-eqz v0, :cond_0                    # guard ff -> encode
    goto :goto_0                          # guard tt -> return p0 as is
    :cond_0
    invoke-static {p0}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;
    move-result-object p0                 # result overwrites the parameter register
    :goto_0
    return-object p0
.end method
```

## Reconstructed source

```java
public static String i(String str) {
    return TextUtils.isEmpty(str) ? str : TextUtils.htmlEncode(str);
}
```

## Derivations

Treating `isEmpty` and `htmlEncode` as primitive operations:

```
σ₁ = {str ↦ ""}:
  ⟨isEmpty(str), σ₁⟩ →ₑ tt     ⟨str, σ₁⟩ →ₑ ""
  ──────────────────────────────────────────── (cond-tt)
   ⟨isEmpty(str) ? str : htmlEncode(str), σ₁⟩ →ₑ ""

σ₂ = {str ↦ "Tom & Jerry"}:
  ⟨isEmpty(str), σ₂⟩ →ₑ ff     ⟨htmlEncode(str), σ₂⟩ →ₑ "Tom &amp; Jerry"
  ─────────────────────────────────────────────────────────────────── (cond-ff)
   ⟨isEmpty(str) ? str : htmlEncode(str), σ₂⟩ →ₑ "Tom &amp; Jerry"
```

## Notes

- **One guard, one branch evaluated** — `(cond-tt)` never mentions `htmlEncode` ([[Short-Circuit-As-Nested-Conditionals]]). Here that's an optimization, not a safety requirement: `htmlEncode("")` would also return `""`.
- **`null` is "empty" too.** `TextUtils.isEmpty(null)` is `true`, so `i(null)` returns `null` without calling `htmlEncode`. The guard thus also protects against the blocked configuration `htmlEncode(null)` would produce.
- **Register reuse.** The result is written back into `p0`, the parameter register; both branches converge on `return-object p0`. In the semantics, the *value* of the conditional is what matters — the bytecode just picks one location to hold it on both paths.
- **The `goto` right after `if-eqz`.** R8 laid out the then-branch as an immediate jump to the shared exit. jadx turns this back into the one-line `?:`; an `if`/`return` version would be equivalent ([[Semantic-Equivalence-Of-Two-Fragments]]).
- **Why it matters for analysis.** This is where user input meets the XML protocol; knowing it's escaped (and that empty/null pass through) is relevant when crafting requests in [[Hooking-The-Core-XML-API-Methods-Directly]].

## See also

- [[State-And-Expressions]]
- [[Evaluating-Expressions-In-A-State]]
- [[Java-Fundamentals-Reference|Reference]]
