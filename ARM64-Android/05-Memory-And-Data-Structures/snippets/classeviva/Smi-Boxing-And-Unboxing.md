---
tags: [snippet]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "com.spaggiari.classeviva.students, Flutter/Dart release build"
version: "unknown (APK not versioned in the imported excerpt)"
source_path: "core/misc/grade_utils.dart — blutter-annotated ARM64 disassembly of the AOT-compiled Dart code, not real Dart source"
date_added: 2026-07-28
license_note: "Personal study/research purposes only. This is a tiny excerpt of a disassembly dump kept for illustrating one instruction pattern — see the full imported files under this topic's Classeviva case study for the broader investigation. Check the app's ToS before any further redistribution."
---

# Smi-Boxing-And-Unboxing

## Context

A small helper closure inside `GradeUtils.getSubjectAveragesForPeriods` reads a `MasterGrade`'s
integer field and has to hand it back as a proper (potentially boxed) Dart `int` — a direct,
real-world instance of the Smi-vs-Mint boxing decision described in
[[Memory-And-Data-Structures#Explanation|Tagged integers]].

## Original path

`core/misc/grade_utils.dart` (blutter output mirroring `package:classeviva/core/misc/grade_utils.dart`)

## Snippet

```
[closure] static int <anonymous closure>(dynamic, MasterGrade) {
  // 0xcf7288: ldr             x2, [SP]
  // 0xcf728c: LoadField: r3 = r2->field_7
  //     0xcf728c: ldur            w3, [x2, #7]
  //     0xcf7290: DecompressPointer r3
  // 0xcf7294: LoadField: r2 = r3->field_3f
  //     0xcf7294: ldur            x2, [x3, #0x3f]      ; raw, untagged int64 field
  // 0xcf7298: r0 = BoxInt64Instr(r2)
  //     0xcf7298: sbfiz           x0, x2, #1, #0x1f     ; try tagging: x0 = x2 << 1
  //     0xcf729c: cmp             x2, x0, asr #1        ; does un-shifting recover x2 exactly?
  //     0xcf72a0: b.eq            #0xcf72bc             ; yes -> x0 is already a valid Smi, done
  //     0xcf72a4: stp             fp, lr, [SP, #-0x10]!
  //     0xcf72a8: mov             fp, SP
  //     0xcf72ac: bl              #0x10cc0cc  ; AllocateMintSharedWithoutFPURegsStub
  //     0xcf72b0: mov             SP, fp
  //     0xcf72b4: ldp             fp, lr, [SP], #0x10
  //     0xcf72b8: stur            x2, [x0, #7]          ; store the real 64-bit value into the boxed Mint
  // 0xcf72bc: ret
}
```

## Notes

- `field_3f` is loaded with a plain `ldur x2, [x3, #0x3f]` — a full 64-bit, **untagged** load, since
  this particular field is declared as a raw `int` the Dart VM already knows doesn't need
  tagging/boxing at the storage layer (a `MasterGrade.someIntField`-style field, stored unboxed
  inside its own object for performance).
- Converting that raw value back into a general-purpose Dart `int` (which callers might box,
  compare, or store into a `List<int>`) requires the tag check: `sbfiz` speculatively tags it,
  `cmp x2, x0, asr #1` verifies the round trip is lossless. This is the standard idiom regardless of
  which specific field or method triggers it — you'll see it wherever a raw machine integer needs
  to become a general Dart value.
- Notice the boxing **slow path gets its own tiny prologue/epilogue** (`stp fp, lr, ...` /
  `ldp fp, lr, ...`) around just the `bl AllocateMintSharedWithoutFPURegsStub` call — a stub call
  needs `LR` preserved like any other call, but since the fast path never reaches this code there's
  no cost paid unless boxing genuinely overflows a Smi.
- Compare this to [[Object-Field-Store-With-Write-Barrier]]'s `tbz w0, #0, ...` check, which tests
  the *opposite* direction (is a value already-tagged as a Smi) — the two idioms are mirror images
  of the same tagged-representation trick from opposite ends.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Memory-And-Data-Structures]]
- [[Classeviva-Flutter-Case-Study]]
