---
tags: [example]
level: 1
aliases: ["Register annotation technique"]
created: 2026-11-12
---

# Example: Annotating-A-Short-Method-Line-By-Line

> [!info] Level 1 — basics
> One idea: keep a running "what's in each register" table and update it after every instruction; the source falls out of the table.

## Goal

Demonstrate the mechanical technique behind all cold reading — annotating register contents after each instruction — on a short method where every step is easy, so the habit is in place before it's needed on hard code. Belongs to [[Reading-Raw-Dalvik]].

## The smali (no source available)

```smali
.method public static a(Ljava/lang/String;I)Ljava/lang/String;
    .locals 2
    new-instance v0, Ljava/lang/StringBuilder;
    const-string v1, "https://api.example.com/v1/items/"
    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string p0, "?page="
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object p0
    return-object p0
.end method
```

## Step by step

Start from the method line: `static`, descriptor `(Ljava/lang/String;I)`, `.locals 2` → `v0`, `v1` are scratch, `p0` = a `String`, `p1` = an `int` ([[Counting-Locals-And-Parameters]]). Then one row per instruction:

| # | instruction | v0 | v1 | p0 | p1 |
| --- | --- | --- | --- | --- | --- |
| 0 | (entry) | — | — | `id: String` | `page: int` |
| 1 | `new-instance v0` | `sb` (uninit) | — | `id` | `page` |
| 2 | `const-string v1` | `sb` (uninit) | `"https://…/items/"` | `id` | `page` |
| 3 | `invoke-direct <init>(String)` | `sb = "https://…/items/"` | (dead) | `id` | `page` |
| 4 | `append(p0)` | `sb += id` | | `id` (last use) | `page` |
| 5 | `const-string p0` | | | `"?page="` | `page` |
| 6 | `append(p0)` | `sb += "?page="` | | (dead) | `page` |
| 7 | `append(I)` | `sb += page` | | | (dead) |
| 8 | `toString` → `move-result-object p0` | | | `result` | |

Reading the table bottom-up gives the source directly:

```java
static String itemUrl(String id, int page) {
    return "https://api.example.com/v1/items/" + id + "?page=" + page;
}
```

Things the table makes explicit that a quick skim gets wrong:

1. **`p0` changes meaning twice** (row 5 and row 8). A skim that keeps reading `p0` as "the id" would conclude the method appends the id twice.
2. **Names come from usage, not registers.** `id` and `page` are names chosen from what the values are concatenated into — the URL path and the `page=` query parameter. Write the evidence next to each name.
3. **`append(I)` vs `append(String)`**: the overload chosen at row 7 confirms `p1` is an `int`, matching the descriptor. When a descriptor is unavailable (e.g. you're reading a caller), overloads like this are how types are recovered.
4. **"(dead)" is as important as "live"**: once a register is marked dead, the compiler is free to reuse it, and you should expect it to.

## Compared with real code

- [[Exercise-01-Outlined-StringBuilder-Helpers]] — real R8-outlined `StringBuilder` helpers where the same annotation table untangles the parameter reuse.
- [[Exercise-12-The-DQ-Request-Callable]] — the technique at full scale: a 300-instruction real method.

## See also

- [[Reading-Raw-Dalvik]] — "The checklist"
- [[Registers]]
- [[Reading-A-Getter-And-Setter-Cold]]
- [[Tracking-A-Stack-Slots-Meaning]] in [[ARM64-Android]] — the same discipline for stack slots in native code

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
