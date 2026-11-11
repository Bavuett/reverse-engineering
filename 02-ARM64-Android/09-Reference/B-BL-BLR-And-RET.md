---
tags: [reference, reference-entry]
category: "instruction"
created: 2026-11-11
---

# B-BL-BLR-And-RET

## Signature / syntax

```asm
; Direct PC-relative branches and calls:
b       label         ; unconditional jump: PC = label (+/- 128 MiB range, LR untouched)
b.cond  label         ; conditional jump:   if (cond(NZCV)) PC = label (+/- 1 MiB range)
bl      label         ; direct call:        X30 (LR) = PC + 4, then PC = label (+/- 128 MiB range)

; Indirect register-targeted branches, calls, and returns:
br      Xn            ; indirect jump:      PC = Xn (LR untouched — switch tables, PLT stubs, tail calls)
blr     Xn            ; indirect call:      X30 (LR) = PC + 4, then PC = Xn (vtables, JNI, Dart GDT)
ret     {Xn}          ; subroutine return:  PC = Xn (defaults to X30/LR when Xn is omitted)
```

## Description

The `b` / `bl` / `br` / `blr` / `ret` family implements all unconditional jumps, `NZCV`-based conditional jumps, subroutine calls, and returns in AArch64. None of these instructions touch the stack pointer (`SP`) — unlike x86's `call`/`ret`, which push and pop the return address on the hardware stack, AArch64 stores the return address in the dedicated **Link Register (`X30`, aliased as `LR`)** and leaves stack management entirely to explicit `stp`/`ldp` instructions in the callee's prologue and epilogue (see [[STP-And-LDP]]).

| Instruction | Writes `X30` (`LR`)? | Target source | Range | Primary role in compiled Android code |
| --- | --- | --- | --- | --- |
| `b label` | No | PC-relative `imm26 << 2` | $\pm 128\text{ MiB}$ | Unconditional goto, loop back-edge, `else`-skip, or **tail call** to another function |
| `b.<cond> label` | No | PC-relative `imm19 << 2` | $\pm 1\text{ MiB}$ | Conditional branch testing `PSTATE.NZCV` (`eq`, `ne`, `lt`, `le`, `gt`, `ge`, `lo`/`cc`, `ls`, `hi`, `hs`/`cs`, `mi`, `pl`, `vs`, `vc`) |
| `bl label` | Yes (`PC + 4`) | PC-relative `imm26 << 2` | $\pm 128\text{ MiB}$ | Direct function call (`foo()`, PLT stub `malloc@plt`, or Dart AOT stub/static call) |
| `br Xn` | No | Register `Xn` | Full 64-bit address space | Switch jump-table dispatch (`br x1`), PLT-to-GOT tail jump (`br x17`), indirect tail call |
| `blr Xn` | Yes (`PC + 4`) | Register `Xn` | Full 64-bit address space | Indirect/virtual function call: C++ vtable, JNI `(*env)->...`, function pointer, or Dart Global Dispatch Table (`blr lr`) |
| `ret {Xn}` | No | Register `Xn` (default `X30`) | Full 64-bit address space | Function return (architecturally identical to `br X30`, plus a hardware branch-predictor hint to pop the return-address stack) |

## Example

```asm
; 1. Direct call (`bl`) vs. tail call (`b` after restoring the caller's frame):
caller_with_tail_call:
    stp   x29, x30, [sp, #-0x10]!
    mov   x29, sp
    bl    helper_step_one            ; normal call: LR = address of the next instruction (`ldp`)
    ldp   x29, x30, [sp], #0x10      ; restore ORIGINAL caller's FP and LR before the final call
    b     helper_step_two            ; tail call: jump with `b` (NOT `bl`), so helper_step_two's `ret`
                                     ; returns directly to caller_with_tail_call's caller!

; 2. PLT stub indirect jump (`adrp` + `ldr` + `br x17`, from PLT-Stub-And-Indirect-Call):
malloc@plt:
    adrp  x16, #page_of_got_entry
    ldr   x17, [x16, #got_entry_offset]
    br    x17                        ; `br` (not `blr`) preserves the LR set by the caller's `bl malloc@plt`

; 3. JNI vtable indirect call (`blr`, from JNI-Native-Method-Signature):
    ldr   x1, [x19]                  ; x1 = *env (JNINativeInterface function-pointer table)
    ldr   x2, [x1, #0x298]           ; x2 = env->GetStringUTFChars
    blr   x2                         ; indirect call into ART's JNI implementation

; 4. Dart AOT Global Dispatch Table (GDT) virtual call (`blr lr`, from Bitfield-Class-Id-Extraction):
    ldur  x2, [x1, #-1]
    ubfx  x2, x2, #0xc, #0x14        ; x2 = receiver's 20-bit class ID (cid)
    movz  x17, #0x490d
    movk  x17, #0x1, lsl #16         ; x17 = per-selector GDT offset (0x1490d)
    add   lr, x2, x17
    ldr   lr, [x21, lr, lsl #3]      ; lr = GDT[cid + 0x1490d] (x21 is the GDT base register)
    blr   lr                         ; call the resolved method; blr overwrites lr with PC + 4
```

## Notes

- **Why a non-leaf function must save `X30` (`LR`) on the stack**: Because `bl` and `blr` unconditionally overwrite `X30` with `PC + 4`, a function that executes even a single nested `bl` or `blr` would lose its own return address if it didn't first save `X30` into its stack frame (`stp x29, x30, [sp, #-N]!`) and reload it before `ret` (`ldp x29, x30, [sp], #N`). Conversely, a true leaf function (one containing no `bl` or `blr`) can execute `ret` directly using the `X30` value its caller placed there.
- **Recognizing tail-call optimization (`b` where you expected `bl` + `ret`)**: When the very last action of a function `f` is `return g(a, b);`, optimizing compilers tear down `f`'s stack frame first (`ldp x29, x30, [sp], #N`) and then emit `b g` (or `br xN` for an indirect tail call) instead of `bl g` followed by `ret`. Because `X30` already holds the return address back to `f`'s caller and `b` leaves `X30` untouched, `g`'s own final `ret` returns directly to `f`'s caller. Watch out for two static-analysis traps here:
  1. An unconditional `b` pointing **outside** the current function's address bounds (after an `ldp x29, x30` epilogue) is a tail call to another function, not an intra-function goto.
  2. In Dart AOT async functions, `b #0x7e8334` (`InitAsync` / async-return stub at the end of [[Reading-Raw-Disassembly#Worked example 4 (expert): continuing into an async network request, assembled field by field|Worked example 4 in Reading-Raw-Disassembly]]) uses this exact tail-jump pattern to hand control to a runtime stub.
- **Why Dart AOT GDT calls use `lr` (`x30`) as the scratch register for `blr lr`**: In Dart AOT virtual dispatch (`ldr lr, [x21, lr, lsl #3]` followed by `blr lr`), the compiler uses `lr` (`x30`) to hold the loaded target address right before calling it. This is completely safe because the CPU reads the target address from `lr` **before** writing `PC + 4` back into `lr`, and avoids clobbering an extra scratch register.
- **Resolving indirect calls (`blr xN` / `br xN`) when static analysis stops**: Whenever a target is computed at runtime — a C++ vtable call, a JNI table call with a dynamic offset, a `switch` jump table (`br x1`), or an unannotated Dart GDT call (`blr lr`) — a static disassembler cannot draw a cross-reference edge automatically. Combine static offset calculation (e.g. matching JNI table offsets against `jni.h` or computing `table_base + offset` in [[Switch-As-Jump-Table]]) with dynamic tracing via Frida Stalker (`[[Resolving-An-Indirect-Call-With-Stalker]]` in [[Frida-Dynamic-Instrumentation]]) when you need concrete runtime targets.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Instructions]]
- [[Functions-And-Calling-Convention]]
- [[Control-Flow-Patterns]]
- [[Android-Native-Internals]]
- [[Flutter-Dart-AOT]]
- [[PLT-Stub-And-Indirect-Call]]
- [[JNI-Native-Method-Signature]]
- [[Switch-As-Jump-Table]]
- [[STP-And-LDP]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
