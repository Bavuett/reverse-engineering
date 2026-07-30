---
tags: [case-study]
project: "ClasseViva (eu.spaggiari.classevivastudente)"
source: "eu.spaggiari.classevivastudente — Flutter (Dart AOT) Android app, libapp.so disassembled with Blutter"
version: "unknown (not recorded alongside the imported files)"
obtained_via: "APK's libapp.so disassembled with Blutter into per-Dart-file ARM64 pseudo-source+asm (blutter_out_arm64/asm/); Frida targeted the exact offset found there for the hook in this write-up."
tools_used: "Blutter, Frida"
topics: ["Frida-Dynamic-Instrumentation", "ARM64-Android"]
date_started: 2026-07-30
status: "in-progress"
license_note: "Personal study/research purposes only. Only import the fragments you actually need, keeping their original file/module structure; check the app's license and ToS before sharing publicly."
---

# ClasseViva-Case-Study

## Overview

**ClasseViva** (`eu.spaggiari.classevivastudente`) is a real Flutter app (the Italian school register/grades client) whose release build ships its Dart code AOT-compiled straight into `libapp.so` — there's no Dalvik bytecode layer for the login flow at all, only ARM64 following Dart's own calling convention. This case study is a genuine instance of the problem [[Flutter-Dart-AOT]] and [[Native-Memory-And-ARM64]] describe in the abstract: given only a Blutter-disassembled function at a bare numeric offset (no exported symbol, no JNI signature to `Module.findExportByName`), how do you actually place a working `Interceptor.attach` and read out its arguments correctly.

This project exists to document the **general workflow** for hooking a Dart-AOT instance method whose argument type is statically known, not just the one script that came out of it — see [[Hooking-Dart-AOT-Login-With-Frida]] for the full write-up, including the dead end (reusing Blutter's own generic, whole-app hook template) and the disassembly detail that made a much smaller script possible instead.

## Source layout

`source/` holds the fragments this investigation actually needed, not a full copy of Blutter's output:

- `authentication_service.dart` — trimmed Blutter disassembly of `_AuthenticationService.login()`, the hooked function (`libapp.so + 0x7249bc`).
- `login_request_jto.dart` — trimmed Blutter disassembly of `_LoginRequestJTO` (`_$LoginRequestJTOToJson`, `toString`), the argument type whose field layout the hook depends on.
- `blutter_frida_register_constants.js` — the register-mapping preamble and decompression helpers excerpted from Blutter's own auto-generated, whole-app `blutter_frida.js` — kept here as the source the simplified script's constants (`HeapAddressReg = 'x28'`) were checked against, not reused wholesale.
- `hook_login.js` — the validated, minimal Frida script this investigation produced: hooks `login()` at its exact entry address and logs its four plaintext credential fields before they're serialized and POSTed to `rest/v1/auth/login`.

## Relevant topics & background

What to review before diving into `notes/`:

- [[Flutter-Dart-AOT]] — Dart AOT's reserved registers (`HEAP`, `PP`, `THR`), compressed pointers, and why `login`'s `async` keyword (`InitAsync`/`AwaitStub`) caps what a hook on this address can observe.
- [[Native-Memory-And-ARM64]] — `Interceptor.attach` on a static-offset address (`Module.findBaseAddress(...).add(offset)`) instead of an exported symbol, and reading memory once you have a pointer.
- [[Dart-AOT-Stub-Cheatsheet]] — quick lookup for the reserved-register roles and stub names (`InitAsync`, `AwaitStub`, `CheckStackOverflow`) that show up throughout the disassembly excerpts here.

## Findings

- [[Hooking-Dart-AOT-Login-With-Frida]] — how Blutter had already generated a fully generic, whole-app `blutter_frida.js` for this exact binary, why reusing its generic argument-reading machinery for a single statically-typed call site was more than necessary, how the function's own `SetupParameters` disassembly comment gave a simpler and directly verifiable register mapping instead, and how `_LoginRequestJTO`'s field offsets were read off its own generated `toJson`/`toString` rather than guessed.

## See also

- [[Case-Studies]]
