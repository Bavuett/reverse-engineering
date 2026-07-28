---
tags: [case-study]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "com.spaggiari.classeviva.students — Flutter/Dart release build"
version: "unknown (not recorded alongside the imported dump)"
obtained_via: "The APK's libapp.so (Dart AOT snapshot) was extracted and disassembled/annotated with blutter (see Tools), which recovers class/field/function names from the snapshot's own metadata and emits one pseudo-Dart-source file per original package path, containing annotated ARM64 disassembly rather than real source."
tools_used: "blutter"
date_started: 2026-07-28
status: "in-progress"
license_note: "Personal study/research purposes only. Only the fragments actually needed for this topic's teaching examples are imported, trimmed where the full dump ran to hundreds/thousands of lines of near-identical boilerplate (freezed codegen, full-widget build() methods) — see each source file's own header comment for what was cut. Check ClasseViva's/Spaggiari's ToS before any further redistribution of the app or its disassembly."
---

# Classeviva-Flutter-Case-Study

## Overview

**Classeviva** (by Spaggiari, an Italian school-management vendor) is a real, widely-installed
Flutter app used by students/parents to check grades, absences, homework, and school
communications. Its release build ships a Dart AOT snapshot (`libapp.so`) — no Dalvik bytecode
representation of the app's own logic exists to fall back on, making it a genuine, unmodified
real-world instance of exactly the reversing problem [[Flutter-Dart-AOT]] exists to solve, rather
than a synthetic example built to be easy.

This case study exists to **ground every idiom in [[Flutter-Dart-AOT]] and
[[Memory-And-Data-Structures]] in real, unedited disassembly** — object pool loads, dispatch-table
calls, closures, tagged-integer boxing, write barriers, and the `async`/platform-channel boundary
all appear naturally within a handful of small, genuinely useful functions from the app (grade
averaging, absence-type localization, login-mode selection, an SPID SSO login flow), rather than in
hand-constructed toy examples.

## Source layout

`source/` mirrors the app's own package layout under `package:classeviva/`:

```
source/
├── core/misc/
│   ├── grade_utils.dart       <- weighted grade averaging (closures, fold, Smi/Mint boxing)
│   ├── login_utils.dart        <- login-mode selection (object pool, enum singletons)
│   └── identity_utils.dart     <- school-pass code generation (bitfields, string indexing)
├── domains/absence/models/
│   └── absence.dart             <- Absence model: enum-pointer switch dispatch, object layout,
│                                    array-store write barrier, freezed-generated class hierarchy
└── ui/pages/account_pages/sign_in_pages/
    └── login_spid_page.dart      <- SPID SSO login: MethodChannel + await, platform-channel boundary
```

Every file above is trimmed from a larger original dump — each keeps its own header comment
explaining exactly what was cut and why (mostly repetitive freezed-generated equality/copyWith
boilerplate, and, for `login_spid_page.dart`, the surrounding `build()` method's unrelated UI
logic). None of this is real Dart source: it's blutter's annotated ARM64 disassembly, saved with a
`.dart` extension because blutter mirrors the snapshot's own package-path metadata into its output
file names.

## Findings

- [[Reading-A-Dart-Function-Prologue]] — `GradeUtils.getAvg`'s prologue/epilogue and its two
  closures, read end to end
- [[Recognizing-Enum-Dispatch]] — `AbsenceLocalizations.absenceAbbreviationName`'s cascading
  enum-pointer comparisons
- [[Async-Await-And-Platform-Channels]] — the SPID login page's `MethodChannel.invokeMethod` +
  `await` boundary into native/Java code
- [[Object-Layout-And-Write-Barriers]] — `_Absence.toString()`'s array-store write barrier and what
  it reveals about the object's field layout
- [[Tagged-Integers-And-Boxing]] — Smi-vs-Mint boxing decisions across `grade_utils.dart` and
  `identity_utils.dart`

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
- [[Flutter-Dart-AOT]]
