---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Const-String

## Signature / syntax

```
const-string vAA, string@BBBB
const-string/jumbo vAA, string@BBBBBBBB
```

## Description

Loads a reference to an interned `java.lang.String` constant into register `vAA`. The operand (`string@BBBB`) is an index into the dex file's string pool, not the string's bytes themselves — the actual UTF-8/MUTF-8 data lives once in the pool and every `const-string` referencing the same literal resolves to the same interned instance. `const-string/jumbo` is the identical instruction with a 32-bit pool index instead of 16-bit, used automatically by the assembler when a dex file's string pool grows past 65,535 entries; nothing about reading it differs.

## Example

```smali
const-string v0, "cdvStartInBackground"
const/4 v1, 0x0
invoke-virtual {p1, v0, v1}, Landroid/os/Bundle;->getBoolean(Ljava/lang/String;Z)Z
```

(from [[Reading-Raw-Dalvik]]'s worked example 2 — `Bundle.getBoolean("cdvStartInBackground", false)`)

## Notes

`const-string` is exactly what an obfuscated string decoder is built to avoid: [[Reading-Raw-Dalvik]]'s checklist item 2 identifies decoder helper methods precisely because they *never* show up as a plain `const-string` at their call site — real string literals still use this instruction normally (as in the example above), so a method reading a mysterious `[B`/`[C` argument through a `mul-int/lit8`/`rsub-int/lit8` transform chain, with no `const-string` anywhere nearby, is the signal that a literal is being reconstructed at runtime instead of loaded directly. Conversely, in R8/ProGuard-renamed code that does *not* encrypt strings, surviving `const-string` literals inside generated `toString()` methods and `Intrinsics.checkNotNullParameter` calls are the primary source for recovering original class and property names — see [[Exercise-04-Kotlin-Default-Argument-Constructor]] and [[Exercise-05-Kotlin-Data-Class-Reconstruction]]. `const-class` is the analogous instruction for a `Class` object literal (`MyClass.class`), listed alongside `const-string` in [[Dalvik-Instructions|Instructions]]'s constants table (and used to lock the class object in `static synchronized` methods — see [[Monitor-Enter-And-Monitor-Exit]]).

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Reading-Raw-Dalvik]]
- [[Exercise-04-Kotlin-Default-Argument-Constructor]]
- [[Exercise-05-Kotlin-Data-Class-Reconstruction]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
