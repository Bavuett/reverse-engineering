---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Move-Result

## Signature / syntax

```
move-result vAA
move-result-wide vAA
move-result-object vAA
```

## Description

Captures the return value the immediately preceding `invoke-*` instruction just produced, and stores
it into `vAA` (or the register pair `vAA`/`vAA+1` for `-wide`). Dalvik doesn't return a value directly
into a register the way most physical ISAs use a fixed return register — instead an `invoke-*` leaves
the result in an implicit, invisible slot that only a `move-result*` reads, and only once. If the
callee's return type is `void`, no `move-result*` follows at all; the caller simply discards it.

## Example

```smali
invoke-static {}, Landroid/os/Process;->getElapsedCpuTime()J
move-result-wide v0
long-to-int v0, v0
```

(from [[Reading-Raw-Dalvik]]'s worked example 1 — capturing a 64-bit `long` result into the `v0`/`v1`
pair, then narrowing it)

## Notes

The Dalvik verifier enforces a strict adjacency rule, listed in [[Reading-Raw-Dalvik]]'s "What the
Dalvik verifier will and won't let you get away with" table: a `move-result*` must be the very next
instruction after the `invoke-*` it captures, with nothing else in between (not even a `nop`) — this
makes a `move-result*` a reliable anchor when reading unfamiliar smali cold, since it always tells you
both "the call just above returned something" and, from its own suffix (plain/`-wide`/`-object`),
roughly what shape that something is, even before you've worked out the callee's exact signature.
Omitting the `move-result*` after a non-`void` call (because the caller doesn't need the value) is
legal and common — see [[Reading-Raw-Dalvik]]'s patch 3 for an inserted `invoke-static` whose `int`
result is deliberately left uncaptured.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Invoke-Direct-Static-Virtual-Interface]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
