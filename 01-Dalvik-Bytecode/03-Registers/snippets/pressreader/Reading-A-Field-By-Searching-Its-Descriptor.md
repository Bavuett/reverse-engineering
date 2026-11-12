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

# Reading-A-Field-By-Searching-Its-Descriptor

## Context

`bp.m1.m()` (see [[Discovering-The-Core-XML-Protocol]]) is a ~3,000-instruction method with no decompiled Java to fall back on — exactly the case where [[Registers]]'s "search by field, not by eye" technique matters most. Its very first real instruction after the parameter setup is `iget-object v7, v1, Lbp/m1;->a:Ljava/lang/String;`: searching the raw smali for the literal string `Lbp/m1;->a:` is what actually finds this line, rather than reading a few thousand instructions hoping to spot it.

## Original path

`smali/bp/m1.smali` (see [[PressReader]]; full file under `Case-Studies/pressreader/source/smali/`)

## Snippet

```smali
.method public final m(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;II)V
    .registers 26

    .line 1
    move-object/from16 v1, p0

    .line 2
    .line 3
    move-object/from16 v2, p1

    .line 4
    .line 5
    const-string v3, "wc"

    .line 6
    .line 7
    const-string v4, " (wc:"

    .line 8
    .line 9
    const-string v5, "@"

    .line 10
    .line 11
    const-string v6, "HttpRequestHelper"

    .line 12
    .line 13
    iget-object v7, v1, Lbp/m1;->a:Ljava/lang/String;

    .line 14
    .line 15
    const/4 v8, 0x1

    .line 16
    invoke-static {v8}, Landroid/net/TrafficStats;->setThreadStatsTag(I)V
```

## Notes

Two things worth pulling apart here. First, the mechanical one: `v1` is set to `p0` (`this`) one instruction earlier via `move-object/from16`, so `iget-object v7, v1, Lbp/m1;->a:...` is reading `this.a`, and from this line on `v7` holds that field's value — exactly [[Registers]]'s two-step recipe (search the field descriptor, then follow the destination register) applied to the very first field access in an otherwise opaque method.

Second, the more consequential one: **this field is `f8639a` in JADX's Java reconstruction of the same class ([[m1.java]]), not `a`**. JADX's own comment there — `/* JADX INFO: renamed from: a, reason: collision with root package name */` — explains why: JADX had to rename it to avoid a Java-level identifier collision that doesn't exist in the bytecode itself. Grepping raw smali for `f8639a` finds nothing at all; the field only ever existed as `a` in the actual `.dex`. Any workflow that reads a JADX-decompiled class first and only later needs to search the raw smali (as this case study's own [[Discovering-The-Core-XML-Protocol]] did, once JADX gave up on `m()` entirely) has to translate a decompiler-renamed identifier back to its real name first — checking for exactly this kind of "renamed from" comment — or the search silently comes back empty and looks like proof the field is never touched, when the opposite is true.

The four `const-string` literals just before the `iget-object` (`"wc"`, `" (wc:"`, `"@"`, `"HttpRequestHelper"`) and the `TrafficStats.setThreadStatsTag(1)` call right after are both consistent with `m()` starting off by building a debug log line and tagging the outgoing network traffic for Android's per-thread traffic-stats accounting (compare the identical `TrafficStats.setThreadStatsTag(1)` at the top of `nr.b.call()` in [[Exercise-12-The-DQ-Request-Callable]]).

## See also

- [[Registers]]
- [[Iget-And-Iput]]
- [[Discovering-The-Core-XML-Protocol]]
- [[Exercise-12-The-DQ-Request-Callable]]
- [[Dalvik-Bytecode-Reference|Reference]]
