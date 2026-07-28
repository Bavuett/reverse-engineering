---
tags: [snippet]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "com.spaggiari.classeviva.students, Flutter/Dart release build"
version: "unknown (APK not versioned in the imported excerpt)"
source_path: "core/misc/grade_utils.dart — blutter-annotated ARM64 disassembly of the AOT-compiled Dart code, not real Dart source"
date_added: 2026-07-28
license_note: "Personal study/research purposes only. This is a tiny excerpt of a disassembly dump kept for illustrating one instruction pattern — see the full imported files under this topic's Classeviva case study for the broader investigation. Check the app's ToS before any further redistribution."
---

# Bitfield-Class-Id-Extraction

## Context

Every dynamic (virtual) call in Dart-compiled ARM64 code starts by pulling the receiver's runtime
class id out of its object header, so it can index the [[Flutter-Dart-AOT|global dispatch
table]]. This excerpt is that exact idiom, taken straight from `GradeUtils.getAvg`'s disassembly.

## Original path

`core/misc/grade_utils.dart` (blutter output mirroring `package:classeviva/core/misc/grade_utils.dart`)

## Snippet

```
// 0xc20d0c: ldur            x1, [fp, #-8]
// 0xc20d10: r2 = LoadClassIdInstr(r1)
//     0xc20d10: ldur            x2, [x1, #-1]
//     0xc20d14: ubfx            x2, x2, #0xc, #0x14
```

## Notes

- `ldur x2, [x1, #-1]` reads the object **header word**, which sits one byte *before* the object's
  tagged pointer — a classic "the useful metadata lives just behind the pointer you were handed"
  layout, also seen in other managed runtimes.
- `ubfx x2, x2, #0xc, #0x14` then extracts a 20-bit (`0x14` = 20) field starting at bit 12
  (`0xc`) — the class id lives packed inside the header alongside other bits (GC/size info) the
  disassembler doesn't bother naming here.
- The result, `x2`, is exactly what a following `GDT[cid_x0 + <offset>]()` computed call (see
  [[Flutter-Dart-AOT]]) uses to find the right method for whatever runtime type `x1` actually is —
  this is Dart's answer to a C++ vtable lookup, done via a flat table indexed by class id instead
  of one vtable pointer per object.
- Recognize this pair — `ldur Xd, [Xn, #-1]` then `ubfx Xd, Xd, #0xc, #0x14` — on sight; it appears before nearly every non-trivially-typed call in AOT-compiled Dart and is otherwise easy to mistake for "reading some unrelated field at a negative offset."

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Flutter-Dart-AOT]]
- [[Classeviva-Flutter-Case-Study]]
