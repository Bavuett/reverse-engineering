---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Iget and Iput

## Signature / syntax

```
iget vA, vB, Lclass;->field:T
iput vA, vB, Lclass;->field:T
```

(plus `-wide`, `-object`, `-boolean`, `-byte`, `-char`, `-short` suffixes on both, matching `T`)

## Description

Read (`iget`) or write (`iput`) an **instance** field: `vB` holds the object reference the field lives on, `vA` is the value register (source for `iput`, destination for `iget`), and the trailing `Lclass;->field:T` names the declaring class, field name, and field type explicitly — smali never infers a field's type from context the way source-level Java does. Attempting to read/write a field on a `null` object reference throws `NullPointerException` at runtime, same as the Java it decompiles from; the verifier itself does not check for null.

## Example

```smali
iget-object p1, p0, Lnet/pluservice/tua/MainActivity;->launchUrl:Ljava/lang/String;
invoke-virtual {p0, p1}, Lnet/pluservice/tua/MainActivity;->loadUrl(Ljava/lang/String;)V
```

(from [[Reading-Raw-Dalvik]]'s worked example 2 — reading `this.launchUrl` before passing it to `loadUrl`)

## Notes

Because the declaring class is always spelled out (`Lclass;->field:T`), grepping for a specific `Lclass;->fieldName:` string finds every read and write of that field across an entire smali tree in one pass — the same technique [[Reading-Raw-Dalvik]]'s worked example 4 uses at the method level (`grep -rn "^\.method public static \w+(JJ)V"`) applies identically to fields (see [[Reading-A-Field-By-Searching-Its-Descriptor]]). See [[Sget-And-Sput]] for the static-field counterpart, which drops the object-reference register entirely, and [[Exercise-05-Kotlin-Data-Class-Reconstruction]] for how `iput-*` order in a constructor compares against `iget-*` order in `equals`/`hashCode`/`toString`.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Sget-And-Sput]]
- [[Reading-A-Field-By-Searching-Its-Descriptor]]
- [[Exercise-05-Kotlin-Data-Class-Reconstruction]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
