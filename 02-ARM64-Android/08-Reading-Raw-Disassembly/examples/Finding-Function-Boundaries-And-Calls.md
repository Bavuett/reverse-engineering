---
tags: [example]
level: 1
aliases: ["ARM64 function boundaries", "splitting a raw dump into functions"]
created: 2026-11-12
---

# Example: Finding-Function-Boundaries-And-Calls

> [!info] Level 1 — basics
> One idea: before reading *what* code does, split a raw instruction dump into functions — starts are prologues or `bl` targets, ends are `ret` or a tail-call `b`, and leaf functions have neither prologue nor `bl`.

## Goal

Take an unlabeled run of instructions and mark where each function begins and ends and which calls which — the first pass of every cold read. Belongs to [[Reading-Raw-Disassembly]].

## The dump (no symbols)

```asm
1000:  stp     x29, x30, [sp, #-0x10]!
1004:  mov     x29, sp
1008:  bl      0x1024
100c:  add     w0, w0, #1
1010:  ldp     x29, x30, [sp], #0x10
1014:  ret
1018:  mov     w0, #0x2a
101c:  b       0x1030
1020:  nop
1024:  ldr     w8, [x0]
1028:  lsl     w0, w8, #1
102c:  ret
1030:  cmp     w0, #0
1034:  cneg    w0, w0, mi
1038:  ret
```

## Step by step

1. **Mark every `ret`.** `0x1014`, `0x102c`, `0x1038` — each ends a function (or one exit of a function; a function may have several `ret`s, but code right after a `ret` that nothing branches to is a new function).
2. **Mark every `bl` target as a function start.** `bl 0x1024` → `0x1024` begins a function.
3. **Mark prologues.** `stp x29, x30, [sp, #-N]!` (often preceded by `paciasp` or `bti c` in hardened builds) starts a non-leaf function: `0x1000`.
4. **Handle what's left.** `0x1018` follows a `ret` and isn't inside any branch range → a function start with no prologue. It ends in `b 0x1030`, a branch to code that also ends in `ret` and that nothing else in `0x1018`'s body jumps around — a **tail call** to a function at `0x1030`.
5. **Padding.** The `nop` at `0x1020` sits between a tail call and the next function start: alignment padding, belongs to nothing.
6. **Leaf vs non-leaf.** `0x1024` and `0x1030` have no prologue and no `bl` → leaf functions that never touch the stack. `0x1000` saves `x30` *because* it contains a `bl` (which overwrites `x30`).
7. **Result:**

   | start | end | kind | calls |
   | --- | --- | --- | --- |
   | `0x1000` | `0x1014` | non-leaf | `0x1024` |
   | `0x1018` | `0x101c` | tail-calling stub | → `0x1030` (tail) |
   | `0x1024` | `0x102c` | leaf | — |
   | `0x1030` | `0x1038` | leaf | — |

   Then name them by behavior: `0x1024` returns `*p * 2`, `0x1030` returns `abs(x)` (`cneg … mi` negates when negative), `0x1018` returns `abs(42)`, `0x1000` returns `twice(p) + 1`.

## Compared with real code

- [[Reading-Datastore-Shared-Counter-Cold]] — the same pass over a real library, where `.dynsym` gives some boundaries for free, PLT stubs mark the imported calls, and one unnamed helper must be found purely by its `bl` callers.
- [[Stack-Protector-And-Tail-Call-In-Datastore-JNI]] — a real tail call through a register (`br x3`), the variant step 4 can't see from a direct target.

## See also

- [[Reading-Raw-Disassembly]]
- [[Leaf-Function-Prologue-Epilogue]]
- [[Passing-Arguments-And-Return-Values]] — the `b` tail call explained
- [[Naming-Arguments-From-Their-Uses]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
