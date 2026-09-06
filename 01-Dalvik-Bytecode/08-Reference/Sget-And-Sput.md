---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Sget and Sput

## Signature / syntax

```
sget vAA, Lclass;->field:T
sput vAA, Lclass;->field:T
```

(plus `-wide`, `-object`, `-boolean`, `-byte`, `-char`, `-short` suffixes on both, matching `T`)

## Description

Read (`sget`) or write (`sput`) a **static** field: unlike [[Iget-And-Iput]], there's no object
reference register at all, since a static field belongs to the class itself, not to any instance.
Referencing a class's static field for the first time (from `sget`, `sput`, a static method call, or a
`new-instance`) triggers class initialization if it hasn't already happened — Dalvik runs the class's
`<clinit>` method to completion before any other code observes its static fields, which is the
guarantee [[Reading-Raw-Dalvik]]'s checklist item 4 relies on.

## Example

```smali
sget v0, Lnet/pluservice/plugins/DeviceInformation/DeviceIdProvider;->onNavigationEvent:I
add-int/lit8 v0, v0, 0x1
sput v0, Lnet/pluservice/plugins/DeviceInformation/DeviceIdProvider;->onNavigationEvent:I
```

(from [[Reading-Raw-Dalvik]]'s worked example 1 — an increment-and-store on a static call counter)

## Notes

A `private static final` field written exactly once, inside `<clinit>`, is guaranteed non-null by the
time any other static method on the class becomes reachable — [[Reading-Raw-Dalvik]]'s checklist item
4 treats an `if-nez`/`if-eqz` guard on such a field as dead code by construction, no register tracing
needed, since `<clinit>` has already run before the guard can be reached. The `sget`/`sput` pair is also
the mechanism behind [[Reading-Raw-Dalvik]]'s recurring "mod-128 opaque-predicate counter" idiom
(worked examples 2 and 7): a static `int` field incremented and re-stored on every call, whose stale
name (often borrowed from an unrelated real Android API, per worked example 6) gives no hint of its
role — only tracing whether the `sget`/`sput` pair's result register is read anywhere downstream
distinguishes a live gate from dead bookkeeping.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Iget-And-Iput]]
- [[Reading-Raw-Dalvik]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
