---
tags: [case-study-note]
case_study: "Classeviva (Spaggiari ClasseViva student app)"
created: 2026-07-28
---

# Reading-A-Dart-Function-Prologue

## Question / goal

Read `GradeUtils.getAvg` end to end as a first full function, confirming that the mandatory prologue/epilogue idiom from [[Functions-And-Calling-Convention]] and [[Flutter-Dart-AOT]] really is boilerplate that can be skimmed, and that the two `[closure]` blocks following it are the lambdas passed to `fold`.

## Relevant source

- `[[grade_utils.dart]]` — the `GradeUtils.getAvg` function and its two anonymous closures

## Excerpt

```
static _ getAvg(/* No info */) {
  // 0xc20cdc: EnterFrame
  //     0xc20cdc: stp   fp, lr, [SP, #-0x10]!
  //     0xc20ce0: mov   fp, SP
  // 0xc20ce4: AllocStack(0x30)
  // 0xc20ce8: SetupParameters(dynamic _ /* r1 => r0, fp-0x8 */)
  // 0xc20cf0: CheckStackOverflow
  ...
  // 0xc20cfc: r1 = Function '<anonymous closure>': static.  (-> 0xc20eb4)
  // 0xc20d08: r0 = AllocateClosure()
  // 0xc20d0c-0xc20d40: LoadClassIdInstr + GDT[cid_x0 + 0x1490d]()   <- fold() call #1
  // 0xc20d44: r1 = Function '<anonymous closure>': static.          (-> 0xc20dd0)
  // 0xc20d54: r0 = AllocateClosure()
  // 0xc20d5c-0xc20d90: LoadClassIdInstr + GDT[cid_x0 + 0x1490d]()   <- fold() call #2
  // 0xc20d94-0xc20db8: fcmp/fdiv -- if the first fold's result is 0.0, return 0.0, else divide
  // 0xc20dbc: LeaveFrame / ret
}
```

## Analysis

`GradeUtils.getAvg` implements a weighted-average calculation on a list of grades: it calls `fold()` **twice** on the same underlying list (once via each `AllocateClosure`), through the dynamic dispatch shown by the `LoadClassIdInstr` + `GDT[cid_x0 + 0x1490d]()` pattern (the same class-id-based virtual call from [[Bitfield-Class-Id-Extraction]]) — once to sum weighted grade values, once to sum weights, then divides the two, guarding against a zero-weight division with the `fcmp`/`b.eq` check right before the final `fdiv`.

Each closure argument to `fold` shows up as its own standalone `[closure] ...` block elsewhere in the file (at `0xc20eb4` and `0xc20dd0`) — exactly the separation predicted in [[Flutter-Dart-AOT#Explanation|Closures]]. Reading the enclosing function first, _then_ following each `AnonymousClosure: static (0xADDR)` reference out to its own block, is a much more tractable reading order than trying to read the file top to bottom.

The prologue (`EnterFrame`/`AllocStack`/`SetupParameters`/`CheckStackOverflow`) and epilogue (`LeaveFrame`/`ret`) contribute nothing to understanding _what this function computes_ — skipping straight from `CheckStackOverflow` to the first real instruction after it lost no information, and is the single most time-saving habit this topic teaches.

## Related concepts

- [[Functions-And-Calling-Convention]]
- [[Flutter-Dart-AOT]]
- [[Dart-Function-Prologue-In-The-Wild]]
- [[Closure-Capture-And-Invocation]]

## Open questions / next steps

- Confirm the exact `fold()` accumulator types by reading the two closures' bodies in full (already excerpted in [[grade_utils.dart]]) against `dart:collection`'s `ListBase.fold` signature.
- `getAvgForPeriod` (further down the same file) builds an `AllocateContext` + closure combination over a captured period-index value — a good next read once [[Closure-Capture-And-Invocation]]'s hand-authored version feels familiar, to compare against a real capturing closure.

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
