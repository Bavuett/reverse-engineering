---
tags: [case-study-note]
case_study: "Classeviva (Spaggiari ClasseViva student app)"
created: 2026-07-28
---

# Recognizing-Enum-Dispatch

## Question / goal

Confirm that `AbsenceLocalizations.absenceAbbreviationName`'s chain of comparisons is a `switch` over an `AbsenceType` enum (not, say, a sequence of unrelated `if`s), and recover how many cases it actually has, purely from the disassembly's branch structure.

## Relevant source

- `[[absence.dart]]` — `AbsenceLocalizations.absenceAbbreviationName`, and the top-level `::` class it's attached to (a common blutter presentation for functions Dart treats as file-level/static extension-style members rather than instance methods)

## Excerpt

```
// 0xdb281c: LoadField: r2 = r1->field_f        <- load the enum field ONCE
// 0xdb2824: r16 = Instance_AbsenceType          <- pool-load variant #1 (Obj!AbsenceType@119c391)
// 0xdb282c: cmp w2, w16 / b.ne #0xdb2954        <- not variant #1 -> try next
   ... (variant #1's body: isPartialAbsences() check, then CvvAppLocalizations lookups) ...
// 0xdb2954: r16 = Instance_AbsenceType          <- pool-load variant #2 (Obj!AbsenceType@119c371)
// 0xdb295c: cmp w2, w16 / b.ne #0xdb2a10
   ... (variant #2's body) ...
// 0xdb2a10: r16 = Instance_AbsenceType          <- pool-load variant #3 (Obj!AbsenceType@119c311)
// 0xdb2a18: cmp w2, w16 / b.ne #0xdb2acc
   ... (variant #3's body) ...
// 0xdb2acc: ... (no further comparison -- this is the default/else arm)
```

## Analysis

Four distinct code paths, three of them gated by a comparison against a **different pool-loaded `AbsenceType` singleton address** each time, the fourth reached only once all three comparisons fail — a direct match for `switch (type) { case A: ...; case B: ...; case C: ...; default: ...; }` (or an exhaustive `if/else if/else if/else` — indistinguishable from the assembly alone, and not a distinction that matters for understanding the logic).

Every case body follows the same shape: call `CvvAppLocalizations::of()` to get the current locale's string table, dispatch on its class id (compared against fixed constants `0x2129`/`0x212a` — almost certainly Italian/Spanish, with a fallback to an English literal) to pick a label string, then take a 2-character `substring` of whichever label won, presumably to get the localized abbreviation this method is named for. This is worth cross-referencing against [[ARM64-Android-Glossary|the Glossary]]'s definition of class-id-based dispatch once you're comfortable with the enum-comparison pattern itself, since both patterns co-occur constantly in this codebase.

The instance-comparison technique itself only works because Dart enum variants are singleton heap objects with stable identity within one snapshot — see [[Object-Pool-Constant-Loads]] for the same `Obj!LoginMode@...`-style pool annotation in a simpler function, which is what lets blutter (and, transitively, this note) name each variant instead of just showing a bare pointer comparison.

## Related concepts

- [[Control-Flow-Patterns]]
- [[Enum-Switch-Via-Pointer-Comparison]]
- [[Flutter-Dart-AOT]]

## Open questions / next steps

- The real variant _names_ (`AbsenceType.partial`, `.exit`, `.delay`, or whatever the source actually calls them) aren't recoverable from this dump alone — only their pool addresses and relative order. Cross-referencing against `AbsenceColors.getTypeColor` in the same file (which compares against the exact same three pool addresses, `@119c391`/`@119c371`/`@119c311`, in a different order) would at least confirm which comparisons refer to the _same_ variant across both functions.

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
