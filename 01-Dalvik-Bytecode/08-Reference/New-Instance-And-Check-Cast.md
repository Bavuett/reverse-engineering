---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# New-Instance and Check-Cast

## Signature / syntax

```
new-instance vAA, type
check-cast vAA, type
```

## Description

`new-instance` allocates memory for an object of `type` and stores the (still-uninitialized) reference
in `vAA` — it does **not** run a constructor. The object is unusable for anything except being passed
to an `invoke-direct` call on its own `<init>` method; the verifier tracks "uninitialized-this" as a
distinct type state and rejects any other use (a field read, a method call, even moving it to another
register) before initialization completes. `check-cast` verifies that the reference in `vAA` is an
instance of `type` (or `null`), narrowing its static type for the verifier's benefit; if it isn't, it
throws `ClassCastException` at that instruction. Unlike `check-cast`, `instance-of` (see
[[Dalvik-Instructions|Instructions]]) performs the same test but returns a `boolean` instead of
throwing.

## Example

```smali
new-instance p0, Ljava/lang/String;
invoke-direct {p0, v0, v2}, Ljava/lang/String;-><init>([BI)V
return-object p0
```

(from [[Reading-Raw-Dalvik]]'s worked example 3 — allocating a `String` from a decoded `byte[]`, then
immediately initializing it)

## Notes

The allocate-then-initialize split is exactly what [[Reading-Raw-Dalvik]]'s verifier-constraints table
calls "object construction order": a `new-instance` result is uninitialized until passed to its
`<init>`, and the verifier enforces this even across branches, which is part of why hand-patching in a
replacement object (rather than reusing/redirecting an existing one) requires care. `check-cast` shows
up constantly right after a reflective `Field`/`Method`/`Constructor` resolve
([[Reading-Raw-Dalvik]]'s checklist item 3 and worked example 5): the cast to
`Ljava/lang/reflect/Field;` (or `Method`/`Constructor`) is often the *only* static clue to what kind of
member a reflection-indirection call site ultimately reaches, since the real target is never named as
a plain `invoke-*` anywhere in such a method.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Invoke-Direct-Static-Virtual-Interface]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
