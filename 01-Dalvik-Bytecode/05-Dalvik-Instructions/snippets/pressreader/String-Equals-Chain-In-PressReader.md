---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/bp/m1$a.smali (decompiled counterpart: Case-Studies/pressreader/source/java/bp/m1.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# String-Equals-Chain-In-PressReader

> [!info] Level 3 — real code
> A real `if`/`else if` chain on strings, read side by side with jadx's decompilation: early returns become `goto` to a shared exit, and an `||` collapses into two tests sharing one label.

## Context

`bp.m1` is the class at the heart of PressReader's XML protocol ([[PressReader]]). Its nested class `m1$a` represents one command from a server response, and `a(String)` maps the command's type attribute onto the enum `m1$a$a` (`Alert`, `Action`, `ReloadCatalog`). It's a small, real method with every basic branch shape in it.

## Original path

`smali_classes2/bp/m1$a.smali`, method `a(Ljava/lang/String;)V`

## Snippet

```smali
.method public final a(Ljava/lang/String;)V
    .locals 1
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :cond_3                       # empty -> straight to return
    const-string v0, "Alert"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :cond_0
    sget-object p1, Lbp/m1$a$a;->Alert:Lbp/m1$a$a;
    iput-object p1, p0, Lbp/m1$a;->a:Lbp/m1$a$a;
    goto :goto_0
    :cond_0
    const-string v0, "Action"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :cond_1
    sget-object p1, Lbp/m1$a$a;->Action:Lbp/m1$a$a;
    iput-object p1, p0, Lbp/m1$a;->a:Lbp/m1$a$a;
    goto :goto_0
    :cond_1
    const-string v0, "reload_catalog"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v0
    if-nez v0, :cond_2                       # first half of ||: true -> assign
    const-string v0, "ReloadCatalog"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result p1
    if-eqz p1, :cond_3                       # second half of ||: false -> skip
    :cond_2
    sget-object p1, Lbp/m1$a$a;->ReloadCatalog:Lbp/m1$a$a;
    iput-object p1, p0, Lbp/m1$a;->a:Lbp/m1$a$a;
    :cond_3
    :goto_0
    return-void
.end method
```

## Decompiled (jadx)

```java
public final void a(String str) {
    if (TextUtils.isEmpty(str)) {
        return;
    }
    if ("Alert".equalsIgnoreCase(str)) {
        this.f8651a = EnumC0116a.Alert;
        return;
    }
    if ("Action".equalsIgnoreCase(str)) {
        this.f8651a = EnumC0116a.Action;
    } else if ("reload_catalog".equalsIgnoreCase(str) || "ReloadCatalog".equalsIgnoreCase(str)) {
        this.f8651a = EnumC0116a.ReloadCatalog;
    }
}
```

## Notes

- **One exit, many `return`s.** jadx prints two early `return;` statements, but the bytecode has a single `return-void`, reached through `goto :goto_0` or by falling into `:cond_3`. Both `:cond_3` and `:goto_0` label the same instruction. D8 merges identical exits; jadx splits them back out heuristically, which is why the decompiled `return`s don't line up with the `else if` of the second test. Neither form is "the original" — they're equivalent.
- **The `||` shape.** Compare with [[If-Else-And-Comparisons]]'s `&&`, where both tests jumped to the *false* label. Here the first test jumps on success (`if-nez v0, :cond_2`) straight to the assignment, and the second jumps on failure (`if-eqz p1, :cond_3`) past it. "First test jumps forward on true, last test jumps on false, both around the same block" is how `a || b` looks in every compiler.
- **Constant first.** `"Alert".equalsIgnoreCase(str)` puts the literal in the receiver register (`{v0, p1}`) — the null-safe idiom. Reading the braces in order tells you which side was the receiver.
- **Last-use register reuse.** In the final test the result goes to `move-result p1`, overwriting the input string, because `str` is never read again. Then `p1` is reused once more for the enum constant.
- **Why not a `switch`?** A Java `switch` on a `String` compiles to `hashCode()` + `sparse-switch` + `equals` (see [[Exercise-09-Sparse-Switch-On-String-Hash]]). Case-insensitive matching can't use hash codes, so it must be an `if` chain — the presence of `equalsIgnoreCase` tells you the source was written this way, not optimized into it.
- Field names: the smali's `m1$a->a` is jadx's `f8651a` (jadx renames short obfuscated names to avoid collisions); the enum is `m1$a$a` / `EnumC0116a`. Mapping jadx's names back to smali descriptors is a routine step when moving from jadx to Frida ([[From-Smali-Signature-To-Frida-Overload]]).

## See also

- [[Dalvik-Instructions]]
- [[Conditional-Branches]]
- [[If-Else-And-Comparisons]]
- [[Discovering-The-Core-XML-Protocol]] — what `bp.m1` does in the protocol
- [[Dalvik-Bytecode-Reference|Reference]]
