---
tags: [case-study]
project: "ClasseViva Studenti"
source: "eu.spaggiari.classevivastudente"
version: "5.9.1"
obtained_via: "APKPure xapk (ClasseViva+Studenti_5.9.1_APKPure.xapk)"
tools_used: "Frida 17.2.16, frida-server, adb, Android Studio AVD Manager"
date_started: 2026-07-28
status: "in-progress"
license_note: "Personal study/research purposes only. Only import the fragments you actually need, keeping their original file/module structure; check the project's license and ToS before sharing publicly."
---

# Classeviva-Dynamic-Analysis

## Overview

Applying this topic's dynamic-instrumentation techniques to ClasseViva Studenti, the same Flutter/Dart-AOT app already under static investigation in [[ARM64-Android-Case-Studies|ARM64-Android's classeviva-flutter case study]] and [[Classeviva-Static-Analysis-Practice]]. The goal is to confirm, at runtime, what the static Dart-AOT disassembly there only lets you hypothesize about — in particular how the app talks to its backend (see [[Network-Interception]]) and whether any values worth reading (session tokens, decoded API responses) are only ever assembled in memory rather than sitting anywhere as static constants (see [[Native-Memory-And-ARM64]]).

This case study is scoped to **environment setup and hooking**, not source disassembly — for the static Dart-AOT reading of this same app (object pool, string layout, decompiled logic), see the ARM64-Android case study linked above instead of duplicating it here.

## Source layout

No source files are imported into this case study's `source/` yet — unlike the ARM64-Android case study, this one is about *runtime* behavior, not static disassembly. Frida scripts developed against this app will be added under `source/scripts/` as they're written and validated.

## Findings

- [[Environment-Setup]] — getting a rooted, Frida-instrumented emulator able to run this app's `arm64_v8a`-only native split, and installing the target version.

## See also

- [[Frida-Dynamic-Instrumentation-Case-Studies|Case Studies]]
- [[ARM64-Android-Case-Studies|ARM64-Android's Case Studies]] — the static counterpart to this investigation.
- [[Classeviva-Static-Analysis-Practice]]
