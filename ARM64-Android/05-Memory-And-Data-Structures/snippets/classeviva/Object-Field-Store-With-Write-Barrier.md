---
tags: [snippet]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "com.spaggiari.classeviva.students, Flutter/Dart release build"
version: "unknown (APK not versioned in the imported excerpt)"
source_path: "domains/absence/models/absence.dart — blutter-annotated ARM64 disassembly of the AOT-compiled Dart code, not real Dart source"
date_added: 2026-07-28
license_note: "Personal study/research purposes only. This is a tiny excerpt of a disassembly dump kept for illustrating one instruction pattern — see the full imported files under this topic's Classeviva case study for the broader investigation. Check the app's ToS before any further redistribution."
---

# Object-Field-Store-With-Write-Barrier

## Context

`_Absence.toString()` builds its debug string by writing every field into a fixed-size array (for Dart's string interpolation machinery), one `ArrayStore` per field. Each store of a _non-Smi_ value is immediately followed by a write-barrier check — a real, in-the-wild instance of the pattern in [[Memory-And-Data-Structures#Explanation|Write barriers]].

## Original path

`domains/absence/models/absence.dart` (blutter output mirroring `package:classeviva/domains/absence/models/absence.dart`)

## Snippet

```
// 0xe3d008: ArrayStore: r1[1] = r0  ; List_4
//     0xe3d008: add             x25, x1, #0x13
//     0xe3d00c: str             w0, [x25]
//     0xe3d010: tbz             w0, #0, #0xe3d02c   ; stored value is a Smi -> no barrier needed
//     0xe3d014: ldurb           w16, [x1, #-1]       ; destination array's header byte
//     0xe3d018: ldurb           w17, [x0, #-1]       ; stored VALUE's header byte
//     0xe3d01c: and             x16, x17, x16, lsr #2
//     0xe3d020: tst             x16, HEAP, lsr #32
//     0xe3d024: b.eq            #0xe3d02c
//     0xe3d028: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
// 0xe3d02c: r16 = ", code: "
```

## Notes

- `add x25, x1, #0x13` computes the destination slot's address into `x25` specifically — a register otherwise not seen holding a "normal" value in this function; the Dart compiler reserves it as the address operand for this store-barrier macro expansion, which is why it appears out of nowhere here and nowhere else in the surrounding code.
- `tbz w0, #0, #0xe3d02c` is the cheapest possible skip: if the value just stored is a tagged Smi (tag bit clear), it can never be a new-generation heap pointer, so the entire rest of the barrier check is unnecessary and control jumps straight past it.
- When the stored value _isn't_ a Smi, the header bytes of both the destination and the value are combined and tested against generation/marking bits (`HEAP, lsr #32` here supplies a mask, a different use of the `HEAP` register than the pointer-decompression role in [[Memory-And-Data-Structures]] — same reserved register, different constant it's paired with) — only if that test indicates it's actually necessary does the code fall through to a real call.
- This exact five-to-seven-instruction tail (`tbz` low-bit check, two `ldurb` header reads, `and`, `tst`, conditional `bl`) is worth pattern-matching as a single unit named "write barrier" in your head — it appears after essentially every pointer store into a heap object throughout this disassembly and carries no application-specific meaning of its own.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Memory-And-Data-Structures]]
- [[Classeviva-Flutter-Case-Study]]
