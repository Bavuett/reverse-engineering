---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Aget and Aput

## Signature / syntax

```
aget vAA, vBB, vCC
aput vAA, vBB, vCC
```

(plus `-wide`, `-object`, `-boolean`, `-byte`, `-char`, `-short` suffixes on both)

## Description

Read (`aget`) or write (`aput`) one element of an array: `vBB` holds the array reference, `vCC` the integer index, and `vAA` is the value register (destination for `aget`, source for `aput`). Unlike [[Iget-And-Iput]]/[[Sget-And-Sput]], the element's type is never spelled out in the instruction itself — the suffix (or its absence, for plain 32-bit primitives/`I`) is all that's given, so reading `aget` cold requires already knowing the array's declared element type from wherever it was allocated (`new-array ..., [T`) or received as a parameter. An out-of-bounds index throws `ArrayIndexOutOfBoundsException`; a `null` array reference throws `NullPointerException` — neither is checked by the verifier, both are runtime behavior.

## Example

```smali
aget-object v7, v1, v6
iget-object v8, v7, Lnet/pluservice/plusnetworking/CertificatePinningRule;->a:Ljava/lang/String;
```

(from [[Reading-Raw-Dalvik]]'s worked example 7 — pulling one `CertificatePinningRule` out of an array by loop index, then reading a field off it)

## Notes

`aget`/`aput` pair naturally with `array-length` (get an array's element count) and `new-array` (allocate one) — see [[Array-Length-And-New-Array]], [[Fill-Array-Data]], and [[Dalvik-Instructions|Instructions]]'s array-access table for the full family, or [[Exercise-06-Static-Monitors-And-Iterators]] for a post-increment `aput-object` loop (`keys[i++] = key`) in real code. Register-swap-heavy loops that walk an array by index (checklist item 6 in [[Reading-Raw-Dalvik]]) are usually built around a repeating `aget`/arithmetic/`aput` shape — recognizing where the index register advances (a plain `add-int/lit8` by a fixed stride, as in [[Reading-Raw-Dalvik]]'s worked example 3) is the fastest way to confirm a loop is a simple linear array walk rather than something more complex.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Array-Length-And-New-Array]]
- [[Fill-Array-Data]]
- [[Iget-And-Iput]]
- [[Exercise-06-Static-Monitors-And-Iterators]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
