---
tags: [project]
repo: ""
status: "active"
started: 2026-07-28
---

# Classeviva-Static-Analysis-Practice

## Goal

Use the real, unmodified excerpts imported into [[Classeviva-Flutter-Case-Study]] as open-ended practice material: pick a function neither this topic's chapters nor its case-study notes have already fully annotated, and read it cold using only the patterns from [[Registers-And-Data]] through [[Flutter-Dart-AOT]] — then compare notes against what's already written up. Everything under `source/` in that case study is fair game, plus anything else pulled from `assets/temp/` that hasn't been imported into a case study yet (the `dio` HTTP client and `login_flutter` projects are both still untouched, for instance).

## Decisions

- Practicing against a real app's disassembly rather than only textbook examples, since the goal is reading real, unpolished Dart-AOT-compiled code with no debug info — exactly what a genuine reversing task looks like, per [[Flutter-Dart-AOT]]'s framing.
- Keeping this log separate from the case study's own `notes/` — this project is about _practicing the skill_, not about producing the case study's canonical findings.

## Log

- **2026-07-28** — Topic and case study scaffolded; `grade_utils.dart`, `login_utils.dart`, `identity_utils.dart`, a trimmed `absence.dart`, and a trimmed `login_spid_page.dart` excerpt imported and annotated across the chapters/case-study notes.

## Next steps

- Read `GradeUtils.getAvgForPeriod` in full (already partially excerpted in [[Reading-A-Dart-Function-Prologue]]'s "next steps") — it captures a variable into a closure context, a pattern only shown hand-authored so far in [[Closure-Capture-And-Invocation]].
- Pull a small excerpt from `assets/temp/dio` (untouched so far) to see whether a popular, widely-used package's Dart-AOT shape looks any different from `classeviva`'s own first-party code.
- Once comfortable with everything here, try the same exercise against a real NDK `.so` (a plain JNI library, not Flutter) to contrast against [[Android-Native-Internals]] directly, rather than only reading about the difference.

## See also

- [[ARM64-Android]]
