---
tags: [case-study-note]
case_study: "Classeviva (Spaggiari ClasseViva student app)"
created: 2026-07-28
---

# Tagged-Integers-And-Boxing

## Question / goal

Collect every distinct Smi/Mint boxing-and-unboxing shape that actually appears across this case study's source files, to confirm [[Memory-And-Data-Structures#Explanation|Tagged integers]]' description covers real variation, not just one idealized example.

## Relevant source

- `[[grade_utils.dart]]` — the `BoxInt64Instr` idiom inside the `fold` closure at `0xcf7288`, and again inside `_Absence.toString` (imported separately as `[[absence.dart]]`)
- `[[identity_utils.dart]]` — `IdentityUtils.generateSchoolPass`'s `BoxInt64Instr` on a loop-index field, and `IdentityUtils.isParent`'s `LoadInt32Instr` (the inverse, untagging direction)

## Excerpt

```
; grade_utils.dart, boxing a raw int64 field for general use (see Smi-Boxing-And-Unboxing)
sbfiz x0, x2, #1, #0x1f
cmp   x2, x0, asr #1
b.eq  <done: x0 is a Smi>
bl    AllocateMintSharedWithoutFPURegsStub   ; overflow -> box on the heap instead

; identity_utils.dart, isParent: the INVERSE direction, untagging an already-boxed field
ldur  w0, [x1, #7]
sbfx  x2, x0, #1, #0x1f      ; untag: recover the signed int from a Smi-tagged field
```

## Analysis

Boxing (`sbfiz` + round-trip `cmp` + conditional `AllocateMintSharedWithoutFPURegsStub` fallback) and unboxing (a plain `sbfx`) are mirror-image operations, and this case study's source files happen to contain a clean instance of each: `grade_utils.dart`/`identity_utils.dart`'s `generateSchoolPass` need to hand a raw stored value _out_ as a general `int` (boxing), while `identity_utils.dart`'s `isParent` needs to read an already-tagged field's _actual_ value back in to do arithmetic/comparison on it (unboxing).

Both idioms are cheap in the overwhelmingly common case — a single `sbfiz`/`sbfx` — and only pay for a real heap allocation (`AllocateMintSharedWithoutFPURegsStub`) on the rare path where a value doesn't fit 31 significant bits. Seeing the stub call at all in one of these functions would be a signal that the field in question can genuinely hold large integer values in practice (e.g. a 64-bit ID), not just small counters — useful triage information even before reading what the value represents.

`generateSchoolPass` additionally shows the boxing idiom feeding directly into a `cmp w0, #6` immediately after — i.e., the box is created _purely_ so a following comparison can treat the value uniformly, then immediately discarded. This is worth noting as a case where "why was this boxed at all" has an unglamorous answer: the compiler didn't special-case a Smi-only comparison path here, not because anything interesting depends on the value being a full boxed object.

## Related concepts

- [[Memory-And-Data-Structures]]
- [[Smi-Boxing-And-Unboxing]]
- [[Register-Width-And-Sign-Extension]]

## Open questions / next steps

- `generateSchoolPass`'s surrounding logic (picking between literal strings `"5"`/`"6"`/`"7"`/`"1"` based on a small integer, then concatenating via `finalSchoolPass`) reads like an Italian fiscal-code/tax-code-style checksum or class-identifier scheme — worth a dedicated follow-up note if the school-pass format itself becomes interesting to reconstruct fully.

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
