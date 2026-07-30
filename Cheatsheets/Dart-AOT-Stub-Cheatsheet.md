---
tags: [cheatsheet]
subject: "Dart AOT reserved registers and common stubs"
topics: ["ARM64-Android"]
created: 2026-07-28
---

# Dart-AOT-Stub-Cheatsheet

Quick lookup — not a full explanation. See [[Flutter-Dart-AOT]] for the "why".

## Quick reference

| Symbol | Meaning |
| --- | --- |
| `THR` | Current `Thread*` — `+0x38` stack limit, `+0x50` bump-alloc top/end, `+0x68` static field table |
| `PP` | Current object pool — constants loaded via `add x, PP, #page, lsl #12` / `ldr x, [x, #off]` |
| `x21` (GDT) | Global dispatch table base — virtual calls via `ldr lr, [x21, idx, lsl #3]` / `blr lr` |
| `NULL` | Canonical `null`; `NULL+0x20` = `true`, `NULL+0x30` = `false` (offsets as seen in practice, not a formal spec) |
| `HEAP` | Heap base for pointer decompression (`add x, x, HEAP, lsl #32`) and write-barrier masking |
| `EnterFrame`/`LeaveFrame` | `stp fp,lr,[SP,#-0x10]!`/`mov fp,SP` ... `mov SP,fp`/`ldp fp,lr,[SP],#0x10`/`ret` |
| `CheckStackOverflow` | `ldr x16,[THR,#0x38]` / `cmp SP,x16` / `b.ls <slow>` — present in nearly every function |
| `AllocateClosureStub` | Bundle a code pointer + captured context into a closure object |
| `AllocateContextStub` | Heap-allocate a closure's captured-variable context |
| `AllocateArrayStub`/`AllocateGrowableArrayStub` | Allocate a fixed/growable `List` |
| `AllocateDoubleStub`/`AllocateMintSharedWith[out]FPURegsStub` | Slow-path boxing (double / overflowed Smi) |
| `StackOverflowSharedWith[out]FPURegsStub` | Slow path for a failed `CheckStackOverflow` |
| `NullErrorSharedWithoutFPURegsStub` | Implicit null-check failure |
| `ArrayWriteBarrierStub` | GC write-barrier slow path after a pointer store |
| `AwaitStub` | Suspend at an `await`; see [[Flutter-Dart-AOT]] |
| `InitAsyncStub` | Entry-side counterpart of `AwaitStub` — sets up an `async` function's `Future` right after its first `CheckStackOverflow`, before any suspend point |
| `Sentinel` (a `PP`-loaded pool constant, not `NULL`) | Marks a Dart `late` field as not-yet-initialized; a field read `cmp`'d against it (not against `NULL`) is a guarded/lazy field access, per [[Reading-Raw-Disassembly]] |
| `LateInitializationErrorSharedWith[out]FPURegsStub` | Thrown when a `late` field is read while still holding `Sentinel` |
| `NullCastErrorSharedWith[out]FPURegsStub` | Implicit non-null cast failure (e.g. `expr!`), distinct from `NullErrorSharedWithoutFPURegsStub`'s implicit null-check |
| `ReThrowStub` | Propagates an in-flight exception out of the current frame (`sub SP, fp, #N` then `bl ReThrowStub`, often followed by `brk #0`) |
| `ReturnAsyncNotFutureStub` | Completes an `async` function's `Future` with a plain value, in place of an ordinary `ret` |
| `sbfiz x, x, #1, #0x1f` + round-trip `cmp` | Smi tagging attempt (boxing) |
| `sbfx x, x, #1, #0x1f` | Smi untagging |
| `ubfx x, x, #0xc, #0x14` after `ldur x, [x, #-1]` | Class-id extraction from an object header |

## Common pitfalls

- `CheckStackOverflow` and `EnterFrame`/`LeaveFrame` are boilerplate on **every** function — don't spend time on them; jump straight to what's between `CheckStackOverflow` and `LeaveFrame`.
- A stub call is not application logic — recognize the name and move on, per [[Flutter-Dart-AOT#Explanation|Stubs]].
- Two different `Obj!SomeEnum@<address>` annotations are two different **instances** (variants), not the same value shown twice — see [[Enum-Switch-Via-Pointer-Comparison]].
- Don't conflate a `late`-field guard with an ordinary null check: both are a `cmp` + `b.eq` to a call-only tail, but the guard compares against `Sentinel` (a specific `PP` constant), while a real null check compares against the `NULL` register — see [[Reading-Raw-Disassembly]]'s worked example 4.

## See also

- [[Flutter-Dart-AOT]]
- [[Reading-Raw-Disassembly]]
- [[ARM64-Android]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
