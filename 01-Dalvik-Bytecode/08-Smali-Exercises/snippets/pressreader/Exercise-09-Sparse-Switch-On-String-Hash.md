---
tags: [snippet, exercise]
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/nr/c.smali, smali_classes2/nr/a$a.smali"
difficulty: "★★★"
skills: "when on strings, sparse-switch, shared case targets"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-09-Sparse-Switch-On-String-Hash

## Context

A DQ server response can carry a `<command name='…'><data>…</data></command>` element telling the app to show an alert, reload the catalog, or run an action. `nr.c.a` turns it into an `nr.a`, which has two fields: `a`, the command type (enum `nr.a$a`), and `b`, a `String?` payload.

`dx.b` is a small XML tree node, verified from its own smali:

- field `b` is the node's text;
- field `c` is `true` until a child element is added;
- `c(String)` returns an attribute value;
- `d(String)` returns a child, or a fresh empty node if there is none.

The enum's header is included so you can see its constants.

## Original path

`smali_classes2/nr/c.smali` and `smali_classes2/nr/a$a.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.class public final enum Lnr/a$a;
.super Ljava/lang/Enum;
.source "SourceFile"

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lnr/a;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "a"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lnr/a$a$a;
    }
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lnr/a$a;",
        ">;"
    }
.end annotation

# static fields
.field private static final synthetic $ENTRIES:Lu10/a;

.field private static final synthetic $VALUES:[Lnr/a$a;

.field public static final enum Action:Lnr/a$a;

.field public static final enum Alert:Lnr/a$a;

.field public static final Companion:Lnr/a$a$a;

.field public static final enum ReloadCatalog:Lnr/a$a;

.method public static a(Ldx/b;)Lnr/a;
    .locals 3

    const-string v0, "command"

    invoke-virtual {p0, v0}, Ldx/b;->d(Ljava/lang/String;)Ldx/b;

    move-result-object p0

    iget-boolean v0, p0, Ldx/b;->c:Z

    const/4 v1, 0x0

    if-eqz v0, :cond_0

    return-object v1

    :cond_0
    sget-object v0, Lnr/a$a;->Companion:Lnr/a$a$a;

    const-string v2, "name"

    invoke-virtual {p0, v2}, Ldx/b;->c(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    if-eqz v2, :cond_1

    sget-object v0, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v2, v0}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v0

    const-string v2, "toLowerCase(...)"

    invoke-static {v0, v2}, Lkotlin/jvm/internal/l;->e(Ljava/lang/Object;Ljava/lang/String;)V

    goto :goto_0

    :cond_1
    move-object v0, v1

    :goto_0
    if-eqz v0, :cond_5

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v2

    sparse-switch v2, :sswitch_data_0

    goto :goto_1

    :sswitch_0
    const-string v2, "alert"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2

    goto :goto_1

    :cond_2
    sget-object v0, Lnr/a$a;->Alert:Lnr/a$a;

    goto :goto_2

    :sswitch_1
    const-string v2, "reloadcatalog"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4

    goto :goto_1

    :sswitch_2
    const-string v2, "action"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_3

    goto :goto_1

    :cond_3
    sget-object v0, Lnr/a$a;->Action:Lnr/a$a;

    goto :goto_2

    :sswitch_3
    const-string v2, "reload_catalog"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4

    goto :goto_1

    :cond_4
    sget-object v0, Lnr/a$a;->ReloadCatalog:Lnr/a$a;

    goto :goto_2

    :cond_5
    :goto_1
    sget-object v0, Lnr/a$a;->Action:Lnr/a$a;

    :goto_2
    const-string v2, "data"

    invoke-virtual {p0, v2}, Ldx/b;->d(Ljava/lang/String;)Ldx/b;

    move-result-object p0

    iget-object p0, p0, Ldx/b;->b:Ljava/lang/String;

    if-eqz p0, :cond_6

    invoke-static {p0}, Lx40/s;->j0(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p0

    if-eqz p0, :cond_6

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v2

    if-lez v2, :cond_6

    move-object v1, p0

    :cond_6
    new-instance p0, Lnr/a;

    const-string v2, "type"

    invoke-static {v0, v2}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object v0, p0, Lnr/a;->a:Lnr/a$a;

    iput-object v1, p0, Lnr/a;->b:Ljava/lang/String;

    return-object p0

    nop

    :sswitch_data_0
    .sparse-switch
        -0x5b31208d -> :sswitch_3
        -0x54d081ca -> :sswitch_2
        -0x213a6fa0 -> :sswitch_1
        0x589895c -> :sswitch_0
    .end sparse-switch
.end method
```

## Task

Write the Kotlin function, and the enum companion helper it inlines.

## Check your reading

1. Match each `sparse-switch` key to its string using only the labels — no hashing.
2. Two cases end up at `:cond_4`. What does that mean in source?
3. What happens when `name` is present but matches none of the strings? When it's absent?
4. `invoke-virtual {v0}, Ljava/lang/Object;->getClass()` is called on the enum's `Companion`, and its result is discarded. What is it for?
5. `data` is tested with `if-eqz p0` twice. Is the second test needed?

> [!tip]- Hints
> - `when (s) { "a" -> …; "b" -> … }` on strings compiles to `hashCode()`, then a switch, then an `equals()` to confirm, because different strings can share a hash.
> - `Lx40/s;->j0` is `trim()`.

> [!success]- Solution
> ```kotlin
> enum class DqCommandType {
>     Alert, ReloadCatalog, Action;
>
>     companion object {
>         fun from(name: String?): DqCommandType =
>             when (name?.lowercase(Locale.ROOT)) {
>                 "alert" -> Alert
>                 "reloadcatalog", "reload_catalog" -> ReloadCatalog
>                 "action" -> Action
>                 else -> Action
>             }
>     }
> }
>
> fun parseCommand(root: XmlNode): DqCommand? {
>     val command = root.child("command")
>     if (command.hasNoChildren) return null
>     val type = DqCommandType.from(command.attribute("name"))
>     val data = command.child("data").text?.trim()?.takeIf { it.isNotEmpty() }
>     return DqCommand(type, data)
> }
> ```
>
> **Answers**
>
> 1. Each target loads the string it confirms: `:sswitch_0` → `"alert"`, `:sswitch_1` → `"reloadcatalog"`, `:sswitch_2` → `"action"`, `:sswitch_3` → `"reload_catalog"`. The keys are exactly Java's `String.hashCode()` of those strings: `0x589895c`, `-0x213a6fa0`, `-0x54d081ca`, `-0x5b31208d`.
> 2. Both strings map to the same branch: `"reloadcatalog", "reload_catalog" -> ReloadCatalog`.
> 3. Both reach `:goto_1` and produce `Action`. A missing name leaves `v0 = null`, which skips the switch via `if-eqz v0, :cond_5`; `:cond_5` and `:goto_1` label the same instruction.
> 4. It's the null check R8 leaves for the receiver of an inlined member call. `Companion.from(name)` was inlined, and `getClass()` is the cheapest instruction that throws `NullPointerException` on a null receiver.
> 5. No. `toString()` never returns `null`; the check is left over from the `?.` chain.

## See also

- [[Smali-Exercises]]
- [[Packed-Switch-And-Sparse-Switch]]
- [[Packed-Switch-Multi-Way-Branch]]
- [[Dalvik-Bytecode-Reference|Reference]]
