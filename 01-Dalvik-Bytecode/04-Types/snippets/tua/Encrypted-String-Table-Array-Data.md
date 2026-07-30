---
tags: [snippet]
project: "TUA (net.pluservice.tua)"
source: net.pluservice.tua
version: "unknown"
source_path: "smali/net/pluservice/tua/MainActivity.smali"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Encrypted-String-Table-Array-Data

## Context

`MainActivity`'s `<clinit>` populates a `private static final [B` field from a literal `.array-data` block — the `[B` array-type descriptor from [[Types]] and the `fill-array-data`/`.array-data` instruction pair (only mentioned in passing in [[Dalvik-Instructions|Instructions]]) shown together, doing exactly what they're for: baking a constant byte table into the class file. This specific table is the key/delta array the `$$i` string decoder walks — see [[Reading-Raw-Dalvik]] for the full decoder.

## Original path

`smali/net/pluservice/tua/MainActivity.smali` (see [[Tua-Case-Study]]; full file under `Case-Studies/tua/source/smali/`)

## Snippet

```smali
.field private static final $$c:[B     # array-of-byte descriptor: one leading '[' + 'B', per [[Types]]

.method static constructor <clinit>()V
    .locals 3

    const/4 v0, 0x4
    new-array v0, v0, [B                # allocate a 4-element byte[]
    fill-array-data v0, :array_0        # populate it from the literal table below
    sput-object v0, Lnet/pluservice/tua/MainActivity;->$$c:[B
    # ... more fields set up the same way, elided ...
    return-void

    :array_0
    .array-data 1                       # element width in BYTES: 1 -> this table is a byte[]
        0xbt
        0x54t
        -0x60t
        0x2ft
    .end array-data
.end method
```

## Notes

`.array-data <width>` declares the element size in bytes (`1` for `byte[]`, `2` for `short[]`/`char[]` — see the `char[]` decoder tables in the same file for the `2`-width form), and each literal value is suffixed with a lowercase type-width letter (`t` here, for `byte`) matching how `baksmali` renders negative bytes in two's-complement (`-0x60t` is `0xa0` as an unsigned byte). `fill-array-data` is the only instruction that reads an `.array-data` block; the label (`:array_0`) is purely local to this method, resolved the same way `:cond_*`/`:goto_*` labels are. This is the same `[B` descriptor [[Types]] introduces in the abstract, here backing one of three near-identical key tables (`$$c`, `$$g`, `$$a`) that this class's three decoder helpers each read from — see [[Reading-Raw-Dalvik]] for what the decoding loop built on top of this table actually does.

## See also

- [[Types]]
- [[Dalvik-Instructions|Instructions]] — `fill-array-data`/`new-array`
- [[Reading-Raw-Dalvik]] — the decoder that consumes this table
- [[Dalvik-Bytecode-Reference|Reference]]
