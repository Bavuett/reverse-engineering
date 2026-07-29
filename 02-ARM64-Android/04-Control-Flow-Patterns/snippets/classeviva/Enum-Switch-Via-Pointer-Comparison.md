---
tags: [snippet]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "com.spaggiari.classeviva.students, Flutter/Dart release build"
version: "unknown (APK not versioned in the imported excerpt)"
source_path: "domains/absence/models/absence.dart — blutter-annotated ARM64 disassembly of the AOT-compiled Dart code, not real Dart source"
date_added: 2026-07-28
license_note: "Personal study/research purposes only. This is a tiny excerpt of a disassembly dump kept for illustrating one instruction pattern. Check the app's ToS before any further redistribution."
---

# Enum-Switch-Via-Pointer-Comparison

## Context

`AbsenceLocalizations.absenceAbbreviationName` picks a localized label depending on which variant of an `AbsenceType` enum it's given — source-level, almost certainly a `switch (type) { case AbsenceType.x: ...; case AbsenceType.y: ...; }`. Its disassembly is a clean real-world instance of the cascading-compare `switch` shape from [[Control-Flow-Patterns]].

## Original path

`domains/absence/models/absence.dart` (blutter output mirroring `package:classeviva/domains/absence/models/absence.dart`)

## Snippet

```
// 0xdb281c: LoadField: r2 = r1->field_f
//     0xdb281c: ldur            w2, [x1, #0xf]
//     0xdb2820: DecompressPointer r2
// 0xdb2824: r16 = Instance_AbsenceType
//     0xdb2824: add             x16, PP, #9, lsl #12  ; [pp+0x96a0] Obj!AbsenceType@119c391
//     0xdb2828: ldr             x16, [x16, #0x6a0]
// 0xdb282c: cmp             w2, w16
// 0xdb2830: b.ne            #0xdb2954          ; not this variant -> try the next one
    ...
// 0xdb2954: r16 = Instance_AbsenceType
//     0xdb2954: add             x16, PP, #9, lsl #12  ; [pp+0x96b0] Obj!AbsenceType@119c371
//     0xdb2958: ldr             x16, [x16, #0x6b0]
// 0xdb295c: cmp             w2, w16
// 0xdb2960: b.ne            #0xdb2a10          ; not this variant either -> try the next
    ...
// 0xdb2a10: r16 = Instance_AbsenceType
//     0xdb2a10: add             x16, PP, #9, lsl #12  ; [pp+0x96e0] Obj!AbsenceType@119c311
//     0xdb2a18: cmp             w2, w16
// 0xdb2a1c: b.ne            #0xdb2acc          ; last explicit case; falls through to a default
```

## Notes

- The enum field is loaded **once** (`LoadField: r2 = r1->field_f`, then `DecompressPointer`) and reused across every comparison — the compiler doesn't reload it per `case`.
- Each `case` loads a _different_ enum singleton's address from the object pool (`Obj!AbsenceType@<address>` — the `@...` is the blutter-recovered heap address of that particular canonical instance) and compares by pointer/reference equality, not by an integer index — see [[Control-Flow-Patterns#Explanation|why this can't be a jump table]].
- The `b.ne <next-case-address>` chain means: to find how many `case`s exist, just keep following the `b.ne` targets until you land somewhere that stops looking like "load a singleton, compare, branch" — that final fall-through is the `default`/`else` arm (or, in a real `switch` with no `default` and exhaustive enum coverage, code the compiler proved unreachable but still had to emit for soundness).
- Each surviving branch (`b.eq`, implicit — i.e. _not_ taking the `b.ne`) leads into a block that calls `CvvAppLocalizations::of()` and does per-locale string selection — worth reading fully once this dispatch shape itself is comfortable; see this chapter's parent for the full picture.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Control-Flow-Patterns]]
