---
tags: [fundamentals]
aliases: [AAPCS64, Calling Convention]
created: 2026-07-28
---

# Functions-And-Calling-Convention

## In short

AAPCS64 is the standard ABI every plain NDK-compiled Android `.so` follows: fixed argument
registers, a fixed frame shape, fixed callee-saved registers. The Dart VM's AOT compiler follows
its *own* convention layered on top of the same physical register file — same `X0`-`X30`, same
`SP`, but a different, extremely regular prologue that a `.so` compiled straight from C/C++ would
never emit. Knowing both, and telling them apart on sight, is the single most load-bearing skill in
this whole topic: it's how you instantly know "I'm looking at native NDK code" vs. "I'm looking at
compiled Dart" before reading a single field access.

## Explanation

### AAPCS64: parameter passing

| Registers | Hold |
|---|---|
| `X0`–`X7` | Up to 8 integer/pointer arguments, in order. A 9th+ argument goes on the stack |
| `V0`–`V7` | Up to 8 floating-point/SIMD arguments, independently of the integer ones |
| `X8` | Hidden pointer to caller-allocated space, when the return value is a large struct that doesn't fit in registers |
| `X0` (`X0`/`X1` for 128-bit) | Return value |
| `X19`–`X28`, `SP`, `FP` (`X29`) | Callee-saved: a called function that clobbers these must restore them before returning |
| `X9`–`X15`, `X16`/`X17` | Caller-saved: assume they're garbage after any call |

### AAPCS64: a standard prologue/epilogue

```asm
my_function:
    stp     x29, x30, [sp, #-0x20]!   ; save FP/LR, allocate frame, in one instruction
    mov     x29, sp                    ; FP now points at the base of this frame
    stp     x19, x20, [sp, #0x10]      ; spill whichever callee-saved regs this function uses
    ; ... body ...
    ldp     x19, x20, [sp, #0x10]
    ldp     x29, x30, [sp], #0x20      ; restore FP/LR, deallocate frame
    ret
```

A **leaf function** (calls nothing else) is free to skip all of this if it needs no stack space and
clobbers no callee-saved register — see [[Registers-And-Data#Worked example|the leaf example]] in
the previous chapter. The stack pointer must be 16-byte aligned at every public function boundary;
frame sizes are rounded up accordingly.

### The Dart AOT convention: a different, more rigid prologue

Nearly every function the Dart AOT compiler emits opens with the *same four-part sequence*,
regardless of what the function actually does — this consistency is itself a huge static-analysis
shortcut, and it's the first thing to learn to skip past mentally so the interesting body stands
out:

```
EnterFrame
    stp   fp, lr, [SP, #-0x10]!
    mov   fp, SP
AllocStack(0xNN)
    sub   SP, SP, #0xNN
SetupParameters(...)
    ; move incoming argument registers into their working locations / spill to the frame
CheckStackOverflow
    ldr   x16, [THR, #0x38]     ; THR::stack_limit
    cmp   SP, x16
    b.ls  <slow path: StackOverflowSharedWith[out]FPURegsStub, then retry>
```

Four things are worth internalizing here:

1. **`EnterFrame`/`LeaveFrame` always looks identical** — `stp fp, lr, [SP, #-0x10]!` / `mov fp,
   SP` and, at the end, `mov SP, fp` / `ldp fp, lr, [SP], #0x10` / `ret`. Every Dart function has a
   frame, even ones a hand-written AAPCS64 leaf function wouldn't bother with — the VM needs a
   walkable frame for every function for stack-map-based GC and stack traces.
2. **`CheckStackOverflow` is not optional and not your code's logic** — it's boilerplate the
   compiler inserts into *every* function to cooperate with Dart's (comparatively small,
   growable-via-slow-path) stack. Seeing it is a strong signal you're looking at Dart-AOT output,
   not NDK C/C++.
3. **Parameter passing still uses `X0`-onward**, but "`SetupParameters`" often immediately spills
   arguments into the frame (`stur x1, [fp, #-8]`) rather than keeping them live in registers,
   because Dart's register allocator runs per-function against its own IR, not against a
   source-level notion of "this variable lives in a register for its whole scope."
4. The **return convention still matches AAPCS64** (`X0`/`V0`) — Dart's compiler reuses the
   physical calling convention for arguments/return values, it just adds mandatory bookkeeping
   around it. See [[Flutter-Dart-AOT]] for the reserved registers (`THR`, `PP`, ...) this prologue
   leans on.

## Worked example

A real prologue from this topic's [[Classeviva-Flutter-Case-Study|Classeviva case study]]
(`GradeUtils.getAvg`, see the full excerpt in this chapter's
[[Dart-Function-Prologue-In-The-Wild|snippets]]):

```
// 0xc20cdc: EnterFrame
//     0xc20cdc: stp             fp, lr, [SP, #-0x10]!
//     0xc20ce0: mov             fp, SP
// 0xc20ce4: AllocStack(0x30)
//     0xc20ce4: sub             SP, SP, #0x30
// 0xc20ce8: SetupParameters(dynamic _ /* r1 => r0, fp-0x8 */)
//     0xc20ce8: mov             x0, x1
//     0xc20cec: stur            x1, [fp, #-8]
// 0xc20cf0: CheckStackOverflow
//     0xc20cf0: ldr             x16, [THR, #0x38]  ; THR::stack_limit
//     0xc20cf4: cmp             SP, x16
//     0xc20cf8: b.ls            #0xc20dc8
```

Reading this cold: `EnterFrame` and `CheckStackOverflow` are pure boilerplate — skip them.
`AllocStack(0x30)` says "this function needs 0x30 bytes of locals," which is a useful *size* signal
(bigger stack frame ⇒ more locals/temporaries ⇒ probably a longer/more complex function) even before
reading the body. `SetupParameters` tells you the one incoming argument (`r1`, since this is a
static method with an implicit nothing-in-`r0`... actually here `r1` holds the sole real argument)
gets copied to `x0` *and* spilled to `[fp, #-8]` — it's used both immediately and later.

## More examples

- [[Leaf-Function-Prologue-Epilogue]] — the AAPCS64 side: when a prologue is skipped entirely
- [[Stack-Frame-With-Locals]] — a non-leaf AAPCS64 function spilling callee-saved registers

## See also

- [[Registers-And-Data]]
- [[Instructions]]
- [[Flutter-Dart-AOT]]
- [[Android-Native-Internals]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]

## Flashcards
#flashcards

Why doesn't a leaf AAPCS64 function need a `stp fp, lr` prologue?::Because it calls nothing else, so `LR` never needs to survive a nested call, and if it needs no stack space or callee-saved registers there's nothing to save.
What does seeing `CheckStackOverflow` (a `THR`-relative load, compare against `SP`, `b.ls`) at the top of a function tell you about its origin?::It's Dart-AOT-compiled code, not plain NDK C/C++ — this check is VM-inserted boilerplate present in essentially every Dart function.
What does `AllocStack(0x30)` followed by `sub SP, SP, #0x30` tell you before you've read the function body?::The function needs 0x30 bytes of local/temporary storage — a rough proxy for how much is going on inside it.
In AAPCS64, which register holds the return address on entry to a function?::`X30` / `LR`, the link register.
