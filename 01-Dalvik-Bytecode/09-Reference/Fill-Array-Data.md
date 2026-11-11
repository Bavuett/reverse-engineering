---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Fill-Array-Data

## Signature / syntax

```
fill-array-data vAA, :array_data

:array_data
.array-data element-width
    value_1
    value_2
    ...
.end array-data
```

## Description

Populates an **already-allocated** primitive array (the reference in `vAA`, allocated by a preceding `new-array`) from a literal data block placed after the method body, rather than from individual register values the way [[Array-Length-And-New-Array|`filled-new-array`]] does. `element-width` (in bytes: `1` for `byte[]`/`boolean[]`, `2` for `short[]`/`char[]`, `4` for `int[]`/`float[]`, `8` for `long[]`/`double[]`) must match the array's real element size; each literal value is written with a lowercase type-width suffix (e.g. `t` for byte-width) matching how `baksmali` renders negative, two's-complement values.

## Example

```smali
const/4 v0, 0x3
new-array v0, v0, [B
fill-array-data v0, :array_0
...
:array_0
.array-data 1
    0x1t
    0x2t
    0x3t
.end array-data
```

(the canonical form, from [[Dalvik-Instructions|Instructions]]'s own treatment of this instruction)

## Notes

`fill-array-data` is how compile-time-constant array contents get embedded into a class — a compiler favors one data block over dozens of individual `aput` instructions whenever every element's value is already known statically, which is exactly the shape of an obfuscated string/delta table: `$$c`/`$$a`/`$$g` in [[Reading-Raw-Dalvik]]'s worked examples 3 and 6 are each one `private static final` array, populated once via `fill-array-data` inside `<clinit>`, that a decode loop elsewhere in the class then walks by index. Because the data block sits physically after the method body it belongs to (and is `.array-data`, not executable instructions), it never shows up as suspicious-looking code in a disassembly listing — only the `fill-array-data` reference to it, and whatever reads the array afterward, are worth tracing. See [[Encrypted-String-Table-Array-Data]] for a real-app instance and [[Reading-Raw-Dalvik]] for a full decode loop built on top of one.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Array-Length-And-New-Array]]
- [[Aget-And-Aput]]
- [[Encrypted-String-Table-Array-Data]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
