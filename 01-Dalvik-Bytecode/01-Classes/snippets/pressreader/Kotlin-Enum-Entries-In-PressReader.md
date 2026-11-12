---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/com/newspaperdirect/pressreader/android/core/Service$a.smali"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Kotlin-Enum-Entries-In-PressReader

> [!info] Level 3 — real code
> A complete Kotlin `enum class` as it ships: one `static final enum` field per constant, a synthetic `$VALUES` array, Kotlin 1.9's `$ENTRIES`, and the `<clinit>` that builds them all.

## Context

`Service$a` is a two-constant enum nested inside PressReader's `Service` class. R8 renamed the enum class itself to `a`, but **enum constant names can't be renamed** without breaking `valueOf(String)` and serialization, so `RegisteredUser` and `DeviceAccount` survive verbatim. That makes enums one of the most reliable sources of real names in an obfuscated app.

## Original path

`smali_classes2/com/newspaperdirect/pressreader/android/core/Service$a.smali`

## Snippet

```smali
.class public final enum Lcom/newspaperdirect/pressreader/android/core/Service$a;
.super Ljava/lang/Enum;

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "a"
.end annotation

.field private static final synthetic $ENTRIES:Lu10/a;
.field private static final synthetic $VALUES:[L...Service$a;
.field public static final enum DeviceAccount:L...Service$a;
.field public static final enum RegisteredUser:L...Service$a;

.method static constructor <clinit>()V
    .locals 3
    new-instance v0, L...Service$a;
    const-string v1, "RegisteredUser"
    const/4 v2, 0x0
    invoke-direct {v0, v1, v2}, L...Service$a;-><init>(Ljava/lang/String;I)V
    sput-object v0, L...Service$a;->RegisteredUser:L...Service$a;

    new-instance v0, L...Service$a;
    const-string v1, "DeviceAccount"
    const/4 v2, 0x1
    invoke-direct {v0, v1, v2}, L...Service$a;-><init>(Ljava/lang/String;I)V
    sput-object v0, L...Service$a;->DeviceAccount:L...Service$a;

    invoke-static {}, L...Service$a;->$values()[L...Service$a;
    move-result-object v0
    sput-object v0, L...Service$a;->$VALUES:[L...Service$a;
    invoke-static {v0}, Lba/l;->h([Ljava/lang/Enum;)Lu10/b;
    move-result-object v0
    sput-object v0, L...Service$a;->$ENTRIES:Lu10/a;
    return-void
.end method

.method private static final synthetic $values()[L...Service$a;
    .locals 2
    sget-object v0, L...Service$a;->RegisteredUser:L...Service$a;
    sget-object v1, L...Service$a;->DeviceAccount:L...Service$a;
    filled-new-array {v0, v1}, [L...Service$a;
    move-result-object v0
    return-object v0
.end method

.method public static values()[L...Service$a;
    .locals 1
    sget-object v0, L...Service$a;->$VALUES:[L...Service$a;
    invoke-virtual {v0}, Ljava/lang/Object;->clone()Ljava/lang/Object;
    move-result-object v0
    check-cast v0, [L...Service$a;
    return-object v0
.end method
```

(`L...` abbreviates `Lcom/newspaperdirect/pressreader/android/core/`; `.line` directives, `valueOf`, `getEntries`, and the private constructor trimmed.)

## Reconstructed source

```kotlin
class Service /* ... */ {
    enum class a {          // original name lost to R8
        RegisteredUser,
        DeviceAccount
    }
}
```

## Notes

- **Ordinal order comes from `<clinit>`, not from the field list.** baksmali sorts fields alphabetically (`DeviceAccount` before `RegisteredUser`), but the `const/4 v2, 0x0` / `0x1` passed to `<init>(String, int)` are the ordinals, and the `$values()` array order confirms them. Always reconstruct enum order from these, never from `.field` order.
- **`accessFlags = 0x4019`** decodes to `ACC_ENUM (0x4000) | ACC_FINAL (0x10) | ACC_STATIC (0x8) | ACC_PUBLIC (0x1)` — a public nested enum (nested enums are implicitly `static`).
- **Kotlin vs Java.** A Java enum has the same `$VALUES` + `values()`-clones-it shape. The `$ENTRIES` field and `getEntries()` are Kotlin 1.9+'s `entries` property. `Lba/l;->h([Ljava/lang/Enum;)` is the obfuscated `kotlin.enums.EnumEntriesKt.enumEntries` — recognizable from its shape alone: static, takes `Enum[]`, result stored in `$ENTRIES`.
- **Why `values()` clones.** Arrays are mutable, so handing out `$VALUES` directly would let callers corrupt the enum; `clone()` + `check-cast` returns a fresh copy every call.
- **Compared with the basic case.** This is [[Static-Fields-And-Class-Initializer]]'s "computed at runtime" category applied to every field: no enum constant can be a DEX static value, so all of them are built in `<clinit>`.

## See also

- [[Classes]]
- [[Static-Fields-And-Class-Initializer]]
- [[New-Instance-And-Check-Cast]] — `new-instance` and `check-cast`
- [[Array-Length-And-New-Array]] — `filled-new-array`
- [[Exercise-09-Sparse-Switch-On-String-Hash]] — enums and string switches from the same app
- [[PressReader]]
- [[Dalvik-Bytecode-Reference|Reference]]
