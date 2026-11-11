---
tags: [reference, reference-entry]
category: "directive"
created: 2026-09-07
---

# Annotations

## Signature / syntax

```smali
# class-level, right after .class/.super/.implements
.annotation <visibility> Lannotation/Type;
    <field> = <value>
    ...
.end annotation

# field-level or method-level, nested inside .field/.method
.field <flags> <name>:<type>
    .annotation <visibility> Lannotation/Type;
        ...
    .end annotation
.end field
```

`<visibility>` is one of `build`, `runtime`, `system`.

## Description

The dex format needs to carry metadata that has no representation in bytecode itself — a generic signature erased at the instruction level, an inner/member-class relationship, or (for Kotlin) an entire compiler-internal description of the original source shape. `.annotation`/`.end annotation` is the one mechanism dex uses for all of it: both real source-level `@Annotation` usages and compiler-internal bookkeeping travel the same way, attached to a class, a field, or a method.

The visibility keyword controls what survives past compilation:

| Visibility | Meaning |
| --- | --- |
| `build` | compile-time only, discarded before the `.dex` is produced — never shows up in `baksmali` output at all |
| `runtime` | kept in the `.dex` and queryable via reflection (`Class.getAnnotations()`, etc.) — what any real `@Retention(RetentionPolicy.RUNTIME)` annotation compiles down to, including Kotlin's own `@Metadata` |
| `system` | compiler/runtime-internal, under `Ldalvik/annotation/*` — doesn't correspond to a source-level `@Annotation` at all; it's how dex represents things the JVM class-file format gives a dedicated attribute to instead (generic signatures, member classes, thrown exceptions) |

## Example

Two real visibilities, same app (PressReader):

```smali
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lbp/m1$a;
    }
.end annotation
```

```smali
.field public static final o:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field
```

(both from [[m1.smali|`bp.m1`'s own class header]] — see [[PressReader]] and [[Exercise-06-Static-Monitors-And-Iterators]]; `Signature` is how dex recovers the generic type argument a `HashMap` field's raw type descriptor alone can't express)

```smali
.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u0068\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n..."
    }
    d2 = {
        "Lcom/newspaperdirect/pressreader/android/core/Service;",
        "Landroid/os/Parcelable;",
        "<init>",
        "()V",
        "id",
        "getId",
        "accountNumber",
        "activationType",
        "Lcom/newspaperdirect/pressreader/android/core/Service$ActivationTypes;",
        ...,
        "ActivationTypes",
        "Companion",
        "core_release"
    }
    k = 0x1
    mv = {
        0x2,
        0x2,
        0x0
    }
    xi = 0x30
.end annotation
```

(from PressReader's `Service` class — `com.newspaperdirect.pressreader.android.core.Service`, the account/service model type threaded through [[Discovering-The-Core-XML-Protocol]]'s `bp.m1` API; `d1`/`d2` trimmed here since the real arrays run to dozens of entries)

## Notes

`kotlin.Metadata` is worth walking through field by field, since it's the densest real annotation most Kotlin apps ship:

- **`k`** — declaration kind: `1` = class, `2` = file, `3` = synthetic class.
- **`mv`** — metadata format version, in practice the Kotlin compiler version that produced it (`2.2.0` above).
- **`d1`** — the actual payload: a Protobuf-encoded description of the class's *Kotlin-level* shape (properties vs. bare fields+accessors, nullability, visibility, `suspend`, ...), packed into a string array purely because a single class-file constant string has a length limit.
- **`d2`** — a string table referenced by index from inside `d1`'s protobuf bytes. This is why real names (`getId`, `accountNumber`, `ActivationTypes`, `Companion`, `core_release`) are readable directly in `d2` even when the surrounding class has otherwise been renamed by R8 — the annotation carries its own separate name table, independent of the class's own constant pool entries.
- **`xi`** — extra flag bits (e.g. whether strict Java-interop null-checks are enabled for the module).

Why this matters for reverse engineering, not just trivia: Kotlin reflection needs this annotation intact at runtime, so most apps' ProGuard/R8 config explicitly keeps `RuntimeVisibleAnnotations`/`kotlin.Metadata` rather than stripping it — which means `d1`/`d2` routinely **survive obfuscation that renames everything else**. This is exactly what lets JADX reconstruct Kotlin-shaped source (`val`/`var`, nullable types, `data class`) instead of a bare field-plus-getter-plus-setter triplet, and it's worth checking directly — via `.annotation runtime Lkotlin/Metadata;` in raw smali, or the equivalent `@Metadata(...)` in JADX's Java view — whenever a class's own identifiers have been renamed but its methods still look suspiciously Kotlin-shaped (or when `@Metadata` has been stripped and you must recover the Kotlin `data class` from generated methods instead, as in [[Exercise-05-Kotlin-Data-Class-Reconstruction]]).

## See also

- [[Classes]] — where `.annotation` attaches (class header, `.field`, `.method`)
- [[Methods]]
- [[Registers]] — a different decompiler-artifact pitfall (JADX renaming a *field*, not annotation data)
- [[Exercise-05-Kotlin-Data-Class-Reconstruction]]
- [[Exercise-06-Static-Monitors-And-Iterators]]
- [[Dalvik-Bytecode-Reference|Reference]]
- [[PressReader]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
