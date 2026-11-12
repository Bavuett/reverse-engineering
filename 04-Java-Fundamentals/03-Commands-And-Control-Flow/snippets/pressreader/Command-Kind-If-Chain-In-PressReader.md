---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/bp/m1$a.smali, method a(Ljava/lang/String;)V (decompiled: Case-Studies/pressreader/source/java/bp/m1.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Command-Kind-If-Chain-In-PressReader

> [!info] Level 3 — real code
> A real `if`/`else if` chain with a guard clause and an `||`: PressReader maps a server command name to an enum, and every path through the derivation corresponds to one path through the smali's branch chain.

## Context

PressReader's XML protocol can carry server-pushed commands (`<command name="…">`), parsed into `bp.m1$a` objects ([[Discovering-The-Core-XML-Protocol]]). Method `a(String)` sets the command's kind from its name; field `a` defaults to `Action`. Part of [[PressReader]].

## Original path

`smali_classes2/bp/m1$a.smali` → `.method public final a(Ljava/lang/String;)V` (field `a:Lbp/m1$a$a;` = kind; `m1$a$a` = the enum `Alert`/`ReloadCatalog`/`Action`).

## Snippet

```smali
.method public final a(Ljava/lang/String;)V
    .locals 1
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :cond_3                                    # empty -> return (guard clause)
    const-string v0, "Alert"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :cond_0
    sget-object p1, Lbp/m1$a$a;->Alert:Lbp/m1$a$a;
    iput-object p1, p0, Lbp/m1$a;->a:Lbp/m1$a$a;           # kind = Alert
    goto :goto_0
    :cond_0
    const-string v0, "Action"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :cond_1
    sget-object p1, Lbp/m1$a$a;->Action:Lbp/m1$a$a;
    iput-object p1, p0, Lbp/m1$a;->a:Lbp/m1$a$a;           # kind = Action
    goto :goto_0
    :cond_1
    const-string v0, "reload_catalog"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v0
    if-nez v0, :cond_2                                    # || : first operand tt -> then-branch
    const-string v0, "ReloadCatalog"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result p1
    if-eqz p1, :cond_3                                    # both ff -> nothing to do
    :cond_2
    sget-object p1, Lbp/m1$a$a;->ReloadCatalog:Lbp/m1$a$a;
    iput-object p1, p0, Lbp/m1$a;->a:Lbp/m1$a$a;           # kind = ReloadCatalog
    :cond_3
    :goto_0
    return-void
.end method
```

## Reconstructed source

```java
public final void a(String str) {
    if (TextUtils.isEmpty(str)) return;
    if ("Alert".equalsIgnoreCase(str)) { this.kind = Kind.Alert; return; }
    if ("Action".equalsIgnoreCase(str)) {
        this.kind = Kind.Action;
    } else if ("reload_catalog".equalsIgnoreCase(str) || "ReloadCatalog".equalsIgnoreCase(str)) {
        this.kind = Kind.ReloadCatalog;
    }
}
```

## Derivation paths

Writing `eq(s)` for `s.equalsIgnoreCase(str)` and treating the enum constants as values:

| `str` | Guards evaluated (in order) | Rules | Final `kind` |
| --- | --- | --- | --- |
| `""` | `isEmpty` → tt | `(if-tt)`, return | unchanged (`Action`) |
| `"ALERT"` | isEmpty ff, eq("Alert") tt | `(if-ff)`, `(if-tt)` + `(field-write)` | `Alert` |
| `"reload_catalog"` | …, eq("Action") ff, eq("reload_catalog") tt | `(if-ff)`×3, `(or-tt)`, `(if-tt)` | `ReloadCatalog` |
| `"ReloadCatalog"` | …, eq("reload_catalog") ff, eq("ReloadCatalog") tt | `(or-ff)`, `(if-tt)` | `ReloadCatalog` |
| `"Refresh"` | all ff | `(or-ff)` → ff, `(if-ff)` + `(skip)` | unchanged |

## Notes

- **Guard clause = outer `if`.** The first test jumps straight to `return-void` (`:cond_3`), so the rest is its else-branch ([[Early-Return-As-Nested-Else]]).
- **`||` as two branches to one target.** `if-nez v0, :cond_2` jumps into the then-branch as soon as the first operand is true — `(or-tt)`; only otherwise is the second string compared — `(or-ff)` ([[Short-Circuit-As-Nested-Conditionals]]).
- **Shared exit.** `:cond_3` and `:goto_0` label the same `return-void`: the "do nothing" else-branch and the "done" exit coincide.
- **Constant-first comparison.** `"Alert".equalsIgnoreCase(str)` (receiver `v0` = the literal) can't block on a `null` receiver; combined with the `isEmpty` guard (true for `null`), the method never throws.
- **Field writes are commands on the heap.** Each assignment to `kind` is `(field-write)` on the object `this` points to ([[Object-And-Method-Semantics-Rules]]); the stack is untouched. Unmatched names leave the default from the field initializer (`Action`).
- Sibling real example of the same compilation pattern: [[String-Equals-Chain-In-PressReader]] in [[Dalvik-Bytecode]].

## See also

- [[Commands-And-Control-Flow]]
- [[Deriving-An-If-Then-Else]]
- [[Java-Fundamentals-Reference|Reference]]
