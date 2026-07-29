---
tags: [case-study]
project: "TUA (net.pluservice.tua)"
source: "net.pluservice.tua — Cordova/Android hybrid app, decompiled to smali from the APK"
version: "unknown (not recorded alongside the imported script)"
obtained_via: "APK decompiled to smali (apktool-style) for static analysis; Frida attached to the running app for dynamic triage of the anti-tampering/root-detection layer."
tools_used: "Frida, adb logcat, grep/ripgrep, apktool (smali decompilation)"
topics: ["Dalvik-Bytecode", "Frida-Dynamic-Instrumentation"]
date_started: 2026-07-28
status: "in-progress"
license_note: "Personal study/research purposes only. Only import the fragments you actually need, keeping their original file/module structure; check the app's license and ToS before sharing publicly."
---

# Tua-Case-Study

## Overview

**TUA** (`net.pluservice.tua`) is a real, hardened Cordova/Android hybrid app whose release build ships several layers of anti-tampering and anti-debugging defenses: encrypted string literals, reflection-hidden root/debuggable checks disguised as unrelated Android API methods, and `div/0` traps injected mechanically into both first-party and third-party code at build time. It's a genuine, unmodified real-world instance of the obfuscation/hardening patterns discussed in [[Dalvik-Bytecode]] and the dynamic-triage workflow in [[Frida-Dynamic-Instrumentation]] — not a synthetic example built to be easy.

This project exists to document the **general workflow** used to find these patterns (not just the specific findings for this one app) — see [[Anti-Tampering-Pattern-Workflow]] for the full write-up, including the investigative dead ends and how each dynamic finding was generalized into a static grep pattern.

## Source layout

`source/` holds the validated Frida script produced by this investigation:

- `investigate.js` — neutralizes the `MainActivity.onPause`/`onResume` div/0 trap (by delegating to `CordovaActivity`'s real implementation) and instruments `EncryptionProvider.encrypt`/`decrypt`/`decryptRecovery`/`decryptDataWithKey` to log plaintext/ciphertext in and out.

Only the fragments actually needed were imported — no full smali tree is checked in here. If specific smali excerpts (e.g. the `(JJ)V`-signature hideout methods, or a `div-int/lit8 ..., 0x0` trap) are worth preserving verbatim for later reference, add them under `source/smali/`, mirroring their original path inside the decompiled APK (e.g. `source/smali/net/pluservice/tua/MainActivity.smali`).

## Relevant topics & background

What to review before diving into `notes/`:

- [[Dalvik-Bytecode]] — smali syntax, reading `.method`/`.field` declarations and instruction shapes, needed to recognize the div/0 and reflection-hiding patterns by eye once you know what to look for.
- [[Frida-Dynamic-Instrumentation]] — specifically hooking `android.util.Log`/`Runtime.exit` and reading a Java stack trace from a hook, which is how the real culprits were found here instead of by blind static search.

## Findings

- [[Anti-Tampering-Pattern-Workflow]] — the full investigative workflow: how blind keyword grepping failed, how dynamic triage (Frida + logcat) found the actual root-detection/debuggable-detection/`div-by-zero` traps, how each finding was generalized into a static grep pattern to find sibling instances across the whole smali tree, and the name-reuse camouflage technique the obfuscator uses throughout this app.

## See also

- [[Case-Studies]]
