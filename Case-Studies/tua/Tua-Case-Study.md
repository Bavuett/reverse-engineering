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

`source/` holds the validated Frida script produced by this investigation, plus the smali excerpts worth preserving verbatim:

- `investigate.js` — neutralizes the `MainActivity.onPause`/`onResume` div/0 trap (by delegating to `CordovaActivity`'s real implementation) and instruments `EncryptionProvider.encrypt`/`decrypt`/`decryptRecovery`/`decryptDataWithKey` to log plaintext/ciphertext in and out.
- `smali/net/pluservice/tua/MainActivity.smali` — the full class: the `onPause`/`onResume`/`onStart` lifecycle traps (opaque-predicate-gated `div-int/lit8 ..., 0x0` and `throw`), the three string-decoder helpers (`$$i`, `a`, `b`, `c`), and `attachBaseContext`, the most heavily reflection-obfuscated method found in this app.
- `smali/net/pluservice/plugins/DeviceInformation/DeviceIdProvider.smali` — mostly plain, unobfuscated smali (device-ID/SHA1 helpers), useful as a baseline for what *un*-obfuscated code in this same app looks like; its one interesting method, `onMessageChannelReady()`, is a modulus-gated lazy-init cache, not a security check — see [[Reading-Raw-Dalvik]] for why that distinction matters.
- `smali/net/pluservice/plusnetworking/PlusNetworking.smali` — the networking layer: string decoding (`j`, `k`, `$$c`) feeding HTTP header names and a request-signing call (`a.a()`), in `post()`.

Only the fragments actually needed were imported, not a wholesale dump of the decompiled tree — but each file above is kept in full (not trimmed to a single method) since [[Reading-Raw-Dalvik]] walks several different methods out of each one, and trimming would have hidden how the obfuscated helpers, the static state-machine fields, and the lifecycle overrides all relate to each other within one class.

## Relevant topics & background

What to review before diving into `notes/`:

- [[Dalvik-Bytecode]] — smali syntax, reading `.method`/`.field` declarations and instruction shapes, needed to recognize the div/0 and reflection-hiding patterns by eye once you know what to look for.
- [[Reading-Raw-Dalvik]] — reads several of this app's own methods cold, with no annotations, to derive the same shapes (opaque predicates, string decoders, reflection indirection) the dynamic investigation below eventually confirmed; also covers how to hand-patch a `.smali` method once you've recognized what it does.
- [[Reflection-and-Runtime-Internals]] — why reflection hides a call from static analysis in the first place (the target becomes a runtime string instead of a bytecode operand), and the runtime internals (JVM/ART class loading, method dispatch, `Method.invoke`) behind it — the general concept this app's reflection-hidden checks are one concrete, real-world instance of.
- [[Frida-Dynamic-Instrumentation]] — specifically hooking `android.util.Log`/`Runtime.exit` and reading a Java stack trace from a hook, which is how the real culprits were found here instead of by blind static search.

## Findings

- [[Anti-Tampering-Pattern-Workflow]] — the full investigative workflow: how blind keyword grepping failed, how dynamic triage (Frida + logcat) found the actual root-detection/debuggable-detection/`div-by-zero` traps, how each finding was generalized into a static grep pattern to find sibling instances across the whole smali tree, and the name-reuse camouflage technique the obfuscator uses throughout this app.

## See also

- [[Case-Studies]]
