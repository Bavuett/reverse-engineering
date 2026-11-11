---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Return and Throw

## Signature / syntax

```
return-void
return vAA
return-wide vAA
return-object vAA
throw vAA
```

## Description

`return-void` exits with no value; `return`/`return-wide`/`return-object` exit carrying a 32-bit primitive, a 64-bit primitive (register pair), or a reference respectively — which form is legal depends entirely on the method's own declared return type, checked by the verifier at assembly time. `throw vAA` raises the exception object held in `vAA` (which must already be a `Throwable` instance, verified statically) as if it had just been constructed and thrown from that point — execution transfers to the nearest enclosing `.catch` handler whose type matches, or unwinds the frame entirely if none does.

## Example

```smali
const/4 v0, 0x0
throw v0
```

(from [[Reading-Raw-Dalvik]]'s worked example 2's `onResume` — throwing a register known to hold a literal `0`/null directly, triggering `NullPointerException` without any exception object ever being constructed by name)

## Notes

A crash deliberately triggered as an anti-tampering trap rarely uses an explicit `new-instance` `Ljava/lang/SomeException;` — [[Reading-Raw-Dalvik]]'s worked example 2 catalogues three different ways obfuscated code reaches a crash without ever naming an exception type: `div-int/lit8 ..., 0x0` (`ArithmeticException`), `throw` on a register statically known to be null (`NullPointerException`), and `invoke-virtual` on that same null register (also `NullPointerException`, one instruction earlier than a redundant `throw` that follows it) — recognizing all three as equally valid "this path is meant to crash" idioms matters because a static patch or a grep looking for only one of them (say, only `div-int ..., 0x0`) misses the other two entirely, the exact gap that investigation ran into. In normal compiled code, a `.catchall` handler that runs cleanup instructions and ends in `throw vX` is the signature of either a `finally` block's exceptional-exit copy (see [[Exercise-11-Download-With-Try-Catch-Finally]]) or a `synchronized` block's synthetic monitor-release handler (see [[Monitor-Enter-And-Monitor-Exit]]).

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Methods]]
- [[Monitor-Enter-And-Monitor-Exit]]
- [[Exercise-11-Download-With-Try-Catch-Finally]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
