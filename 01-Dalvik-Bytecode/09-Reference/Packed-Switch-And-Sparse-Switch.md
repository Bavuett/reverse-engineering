---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Packed-Switch and Sparse-Switch

## Signature / syntax

```
packed-switch vAA, :pswitch_data
sparse-switch vAA, :sswitch_data

:pswitch_data
.packed-switch first_key
    :label_1
    :label_2
    ...
.end packed-switch

:sswitch_data
.sparse-switch
    key_1 -> :label_1
    key_2 -> :label_2
    ...
.end sparse-switch
```

## Description

Both compile a Java `switch (int)` (or a Kotlin `when`). `packed-switch` tests `vAA` against a single **contiguous** range of case keys, starting at `first_key` and incrementing by one per payload entry — the payload lists only branch targets, since each one's key is implied by its position. `sparse-switch` is the sibling for keys with gaps between them: its payload lists explicit `key -> label` pairs instead, since the keys can't be inferred by counting. Either way, falling through the `packed-switch`/`sparse-switch` instruction itself (matching no key) is the `default:` case — the payload block, placed after the method's normal instruction stream, holds only the table, never any case bodies.

## Example

See [[Packed-Switch-Multi-Way-Branch]] for a full worked walkthrough of `packed-switch`, and [[Exercise-09-Sparse-Switch-On-String-Hash]] for a real-app `sparse-switch` compiling a Kotlin `when (String)` via `String.hashCode()` followed by per-branch `String.equals()` collision checks.

## Notes

A compiler picks `packed-switch` over `sparse-switch` purely based on key density — how much wasted table space a contiguous range would cost versus an explicit key list — never based on anything about the case bodies themselves, so the choice carries no information about what the switch does. A `switch`/`when` over `String` values always compiles to a `sparse-switch` on `s.hashCode()` where each `:sswitch_N` target loads its candidate string constant and calls `String.equals(Object)` to confirm (jumping to the default label on a hash collision) — which means you can read the string cases directly off the `:sswitch_N` blocks without ever computing a single hash code by hand (see [[Exercise-09-Sparse-Switch-On-String-Hash]]).

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Packed-Switch-Multi-Way-Branch]]
- [[Exercise-09-Sparse-Switch-On-String-Hash]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
