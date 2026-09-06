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

Both compile a Java `switch (int)`. `packed-switch` tests `vAA` against a single **contiguous** range
of case keys, starting at `first_key` and incrementing by one per payload entry — the payload lists
only branch targets, since each one's key is implied by its position. `sparse-switch` is the sibling
for keys with gaps between them: its payload lists explicit `key -> label` pairs instead, since the
keys can't be inferred by counting. Either way, falling through the `packed-switch`/`sparse-switch`
instruction itself (matching no key) is the `default:` case — the payload block, placed after the
method's normal instruction stream, holds only the table, never any case bodies.

## Example

See [[Packed-Switch-Multi-Way-Branch]] for a full worked walkthrough, including how to read the
payload's implicit key numbering back into case values.

## Notes

A compiler picks `packed-switch` over `sparse-switch` purely based on key density — how much wasted
table space a contiguous range would cost versus an explicit key list — never based on anything about
the case bodies themselves, so the choice carries no information about what the switch does. Reading a
`.packed-switch`/`.sparse-switch` payload cold is mechanical once its shape is recognized: the payload
itself is data, not instructions, and never needs "deducing" the way an obfuscated arithmetic chain
does — the two things worth checking are simply which key maps to which label, and whether the
fall-through (default) path is itself live or dead in context.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Packed-Switch-Multi-Way-Branch]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
