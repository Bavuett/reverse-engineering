---
tags: [snippet, exercise]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/nr/d.smali"
difficulty: "★★★"
skills: "register shuffling, filled-new-array, companion statics"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-08-Server-Mode-Map-Constructor

## Context

`nr.d` is the Kotlin replacement for `bp.m1`'s static `o`/`p` pair from [[Exercise-07-Wait-Loop-Under-A-Monitor]]: it maps server-mode names to base URLs and restores a debug override from `SharedPreferences`. `Ln10/i;` is `kotlin.Pair`, `Lo10/d0;->p` is `mapOf`, and `Lbo/app/g8;->d` is `edit().putString().apply()` (see [[Smali-Exercises]]).

## Original path

`smali_classes2/nr/d.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.class public final Lnr/d;
.super Ljava/lang/Object;
.source "SourceFile"

# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lnr/d$a;
    }
.end annotation

# static fields
.field public static final d:Lnr/d$a;

.field public static volatile e:Lnr/d;

# instance fields
.field public final a:Landroid/content/SharedPreferences;

.field public b:Ljava/lang/String;

.field public final c:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Lnr/d$a;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Lnr/d;->d:Lnr/d$a;

    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/content/SharedPreferences;)V
    .locals 3

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p6, p0, Lnr/d;->a:Landroid/content/SharedPreferences;

    const-string v0, "Productive"

    iput-object v0, p0, Lnr/d;->b:Ljava/lang/String;

    new-instance v1, Ln10/i;

    invoke-direct {v1, v0, p1}, Ln10/i;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    new-instance p1, Ln10/i;

    const-string v2, "test/dq"

    invoke-direct {p1, v2, p2}, Ln10/i;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    new-instance p2, Ln10/i;

    const-string v2, "test/andriip"

    invoke-direct {p2, v2, p4}, Ln10/i;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    new-instance p4, Ln10/i;

    const-string v2, "test/saeed"

    invoke-direct {p4, v2, p5}, Ln10/i;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    new-instance p5, Ln10/i;

    const-string v2, "test/qa"

    invoke-direct {p5, v2, p3}, Ln10/i;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    filled-new-array {v1, p1, p2, p4, p5}, [Ln10/i;

    move-result-object p1

    invoke-static {p1}, Lo10/d0;->p([Ln10/i;)Ljava/util/Map;

    move-result-object p1

    iput-object p1, p0, Lnr/d;->c:Ljava/util/Map;

    const-string p1, "debug_mode"

    const/4 p2, 0x0

    invoke-interface {p6, p1, p2}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z

    move-result p1

    if-eqz p1, :cond_0

    const-string p1, "debug_mode.server_mode"

    invoke-interface {p6, p1, v0}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p2

    if-eqz p2, :cond_0

    iput-object p2, p0, Lnr/d;->b:Ljava/lang/String;

    invoke-static {p6, p1, p2}, Lbo/app/g8;->d(Landroid/content/SharedPreferences;Ljava/lang/String;Ljava/lang/String;)V

    :cond_0
    return-void
.end method
```

## Task

Write the Kotlin class, including its companion object's static fields. Name the five URL parameters after the map key each one ends up under.

## Check your reading

1. `p1`, `p2`, `p4` and `p5` are overwritten with `Pair`s before the array is built. For each `Pair`, which *original* parameter is its second element?
2. In what order do the five entries appear in the map?
3. `p2` also holds two values unrelated to URLs later on. What are they?
4. What is `Lnr/d;->e`, given `static volatile`?

> [!tip]- Hints
> - Read `invoke-direct {X, K, V}, Ln10/i;-><init>` as `X = Pair(K, V)`, then check whether `V` had already been overwritten at that point.
> - `nr/d$a` is created with `Object.<init>` directly: it has no constructor of its own left.

> [!success]- Solution
> ```kotlin
> class ServerConfig(
>     productionUrl: String,                   // p1
>     dqTestUrl: String,                       // p2
>     qaUrl: String,                           // p3
>     andriipUrl: String,                      // p4
>     saeedUrl: String,                        // p5
>     private val prefs: SharedPreferences,    // a
> ) {
>     var mode: String = PRODUCTIVE            // b
>     val servers: Map<String, String> = mapOf(  // c
>         PRODUCTIVE to productionUrl,
>         "test/dq" to dqTestUrl,
>         "test/andriip" to andriipUrl,
>         "test/saeed" to saeedUrl,
>         "test/qa" to qaUrl,
>     )
>
>     init {
>         if (prefs.getBoolean("debug_mode", false)) {
>             val saved = prefs.getString("debug_mode.server_mode", PRODUCTIVE)
>             if (saved != null) {
>                 mode = saved
>                 prefs.edit().putString("debug_mode.server_mode", saved).apply()
>             }
>         }
>     }
>
>     companion object {                       // d: nr.d$a
>         const val PRODUCTIVE = "Productive"
>
>         @Volatile
>         var instance: ServerConfig? = null   // e
>     }
> }
> ```
>
> The single `const-string v0, "Productive"` feeds the field, the first map key and the `getString` default; whether the source used a constant or three identical literals can't be told from bytecode.
>
> **Answers**
>
> 1. `Pair("Productive", p1)` goes into `v1`; `Pair("test/dq", p2)` into `p1`; `Pair("test/andriip", p4)` into `p2`; `Pair("test/saeed", p5)` into `p4`; `Pair("test/qa", p3)` into `p5`. Each register is overwritten only after its original value was consumed.
> 2. `Productive`, `test/dq`, `test/andriip`, `test/saeed`, `test/qa` — the `filled-new-array {v1, p1, p2, p4, p5}` order, not parameter order. `mapOf` with several pairs builds a `LinkedHashMap`, so that order is preserved.
> 3. The `boolean` default `false` (`const/4 p2, 0x0`) passed to `getBoolean`, then the `String` returned by `getString`.
> 4. A `@Volatile` singleton instance, the holder half of a double-checked-locking `getInstance()`. The accessor isn't in this file: the only `sget-object`/`sput-object` of `Lnr/d;->e:Lnr/d;` in the whole dump are in `smali_classes2/jq/i.smali`, where R8 inlined it into its caller.

## See also

- [[Smali-Exercises]]
- [[Registers]]
- [[Array-Length-And-New-Array]]
- [[Sget-And-Sput]]
- [[Dalvik-Bytecode-Reference|Reference]]
