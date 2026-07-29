---
tags: [snippet]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "com.spaggiari.classeviva.students, Flutter/Dart release build"
version: "unknown (APK not versioned in the imported excerpt)"
source_path: "core/misc/grade_utils.dart — blutter-annotated ARM64 disassembly of the AOT-compiled Dart code, not real Dart source"
date_added: 2026-07-28
license_note: "Personal study/research purposes only. This is a tiny excerpt of a disassembly dump kept for illustrating one instruction pattern. Check the app's ToS before any further redistribution."
---

# Dart-Function-Prologue-In-The-Wild

## Context

`GradeUtils.getAvg` is a small static method (computes a weighted grade average). Its disassembly opens with the textbook four-part Dart-AOT prologue described in [[Functions-And-Calling-Convention]] — a good first real example precisely because the method itself is simple enough that the prologue isn't competing with a complicated body for attention.

## Original path

`core/misc/grade_utils.dart` (blutter output mirroring `package:classeviva/core/misc/grade_utils.dart`)

## Snippet

```
static _ getAvg(/* No info */) {
  // ** addr: 0xc20cdc, size: 0xf4
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
  ...
  // 0xc20dbc: LeaveFrame
  //     0xc20dbc: mov             SP, fp
  //     0xc20dc0: ldp             fp, lr, [SP], #0x10
  // 0xc20dc4: ret
  //     0xc20dc4: ret
  // 0xc20dc8: r0 = StackOverflowSharedWithoutFPURegs()
  //     0xc20dc8: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
  // 0xc20dcc: b               #0xc20cfc
}
```

## Notes

- `b.ls #0xc20dc8` targets a call to `StackOverflowSharedWithoutFPURegsStub` — note the naming: "WithoutFPURegs" vs. "WithFPURegs" stub variants exist so the slow path only saves/restores the floating-point register file when the function actually uses it, avoiding needless overhead on the (extremely hot, checked on every call) common path. After the stub returns, control jumps _back_ to just after the original stack-overflow check (`b #0xc20cfc`, one instruction past the `ldr x16, [THR, #0x38]`) to retry.
- The function's real logic sits entirely between `CheckStackOverflow` and `LeaveFrame` — once you've internalized the shape of both ends, only that middle section needs actual reading. Here it computes a numeric average using two folds over a list — the full body is a good next read for [[Memory-And-Data-Structures]] (boxed doubles) once this chapter's pattern is second nature.
- `LeaveFrame` mirrors `EnterFrame` exactly: `mov SP, fp` then `ldp fp, lr, [SP], #0x10` then `ret` — no surprises, which is the point.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Functions-And-Calling-Convention]]
