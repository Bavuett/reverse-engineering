---
tags: [case-study-note]
case_study: "Classeviva (Spaggiari ClasseViva student app)"
created: 2026-07-28
---

# Object-Layout-And-Write-Barriers

## Question / goal

Reconstruct `_Absence`'s field layout purely from `toString()`'s sequence of `LoadField`s and the literal labels it interpolates between them, and confirm the write-barrier shape from [[Memory-And-Data-Structures]] shows up exactly as described in a real, unmodified function.

## Relevant source

- `[[absence.dart]]` — `_Absence.toString()`

## Excerpt

```
// "Absence(id: "        followed by field_7   (an int64, boxed via BoxInt64Instr -- see below)
// ", code: "             followed by field_f
// ", date: "             followed by field_13
// ", hourPosition: "     followed by field_17 (an ArrayLoad -- an unboxed/inline field, not a heap load)
// ", isJustified: "      followed by field_1b
// ", justificationReasonCode: "        followed by field_1f
// ", justificationReasonDescription: " followed by field_23
// ", hourlyAbsences: "   followed by field_27 (wrapped in EqualUnmodifiableListView)
// ", userIdentifier: "   followed by field_2b
// ", justificationStatus: " followed by field_2f
// ")"
```

## Analysis

`toString()`'s own structure hands over a complete field map almost for free: Dart's generated `toString` (this one has the unmistakable shape of `freezed`-generated code, matching the `_$AbsenceCopyWith` etc. classes declared alongside it in the same file) interpolates every field in declaration order with its name as a label, which means **the field offsets recovered here (`field_7` through `field_2f`) can be reused directly** when reading any _other_ method that touches an `_Absence` instance without needing to re-derive them from scratch — exactly the struct-layout-by-cross-referencing technique from [[Struct-Field-Access]], except here the labels are handed to us instead of inferred.

The very first field access (`field_7`, the `id`) goes through `BoxInt64Instr` — see [[Smi-Boxing-And-Unboxing]] for the identical idiom elsewhere in this case study — confirming `id` is stored unboxed inside `_Absence` and only gets boxed into a general Dart `int` at the point `toString` needs to hand it to the string-interpolation array. Every other field shown above is already a compressed heap pointer (`DecompressPointer` immediately follows each `LoadField`), consistent with them being `String?`/`DateTime?`/enum-typed fields rather than raw numerics.

Every one of those pointer fields, once stored into the interpolation array, is followed by the full write-barrier check from [[Object-Field-Store-With-Write-Barrier]] — seven instructions, repeated verbatim (only the destination array slot's offset changes) after essentially every `ArrayStore` in this function. Once you've read it in full once, the remaining five-or-so repetitions in this same `toString()` are worth skimming past entirely, which is most of the function's raw instruction count.

## Related concepts

- [[Memory-And-Data-Structures]]
- [[Object-Field-Store-With-Write-Barrier]]
- [[Struct-Field-Access]]
- [[Smi-Boxing-And-Unboxing]]

## Open questions / next steps

- `field_17`'s access is an `ArrayLoad` (`ldur w0, [x3, #0x17]`, annotated `; List_4`) rather than a plain `LoadField` — worth understanding why blutter distinguishes the two annotations for what's still a fixed-offset read, and whether it reflects a genuine "this field is itself array-backed" distinction on the Dart side or just an artifact of which IR instruction produced the load.

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
