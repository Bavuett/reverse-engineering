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

**Classeviva** (by Spaggiari, an Italian school-management vendor) is a real, widely-installed Flutter app used by students/parents to check grades, absences, homework, and school communications. Its release build ships a Dart AOT snapshot (`libapp.so`) — no Dalvik bytecode representation of the app's own logic exists to fall back on, making it a genuine, unmodified real-world instance of exactly the reversing problem [[Flutter-Dart-AOT]] exists to solve, rather than a synthetic example built to be easy.

This case study exists to **ground every idiom in [[Flutter-Dart-AOT]] and [[Memory-And-Data-Structures]] in real, unedited disassembly** — object pool loads, dispatch-table calls, closures, tagged-integer boxing, write barriers, and the `async`/platform-channel boundary all appear naturally within a handful of small, genuinely useful functions from the app (grade averaging, absence-type localization, login-mode selection, an SPID SSO login flow), rather than in hand-constructed toy examples.

## Source layout

`source/` mirrors two Dart packages: the app's own `package:classeviva/` and Spaggiari's shared, closed-source `package:login_flutter/` (the login/auth library reused across their other apps) — hence the two top-level folders below:

```
source/
├── core/misc/
│   ├── grade_utils.dart              <- weighted grade averaging (closures, fold, Smi/Mint boxing)
│   ├── login_utils.dart               <- login-mode selection (object pool, enum singletons)
│   ├── identity_utils.dart            <- school-pass code generation (bitfields, string indexing)
│   └── constants/
│       ├── servers.dart                <- per-nation server hostnames, string interpolation
│       └── const_link.dart             <- login/SPID URL assembly, ServerNation as a Map key
├── domains/absence/models/
│   └── absence.dart                     <- Absence model: enum-pointer switch dispatch, object layout,
│                                            array-store write barrier, freezed-generated class hierarchy
└── ui/pages/account_pages/sign_in_pages/
    ├── login_spid_page.dart              <- SPID SSO login: MethodChannel + await, platform-channel boundary
    └── login_page.dart                    <- credentials-form sign-in: _performSignIn only

login_flutter/services/
├── network/authentication/authentication_service.dart  <- the actual POST rest/v1/auth/login call
├── network/jto/login/
│   ├── login_request_jto.dart                            <- request body: uid/pass/ident/otp
│   └── login_response_jto.dart                            <- response: token/tokenAP/expire/...
└── keychain_service.dart                                  <- FlutterSecureStorage-backed token storage
```

Every file above is trimmed from a larger original dump — each keeps its own header comment explaining exactly what was cut and why (mostly repetitive freezed-generated equality/copyWith boilerplate, and, for the two page/service files, the surrounding UI/other-methods code not relevant to the specific note it feeds). None of this is real Dart source: it's blutter's annotated ARM64 disassembly, saved with a `.dart` extension because blutter mirrors the snapshot's own package-path metadata into its output file names.

## How the disassembly refers to packages and calls

Every excerpt in this case study's notes is thick with lines like `bl #0x752c40 ; [package:dio/src/options.dart] Options::compose` — worth understanding mechanically, since this exact annotation is what makes the whole case study readable at all.

At the actual hardware level a `bl`/`blr` only ever encodes a bare target address (or, for `blr`, "whatever's in this register") — a stripped release binary has no symbol table entry saying "this address is `Options.compose`." What makes blutter's output show that name anyway is the same mechanism that makes crash-reporting stack traces readable in production Flutter apps: Dart AOT snapshots retain a class/function table mapping every compiled function's entry address back to its declaring library, class, and method name, specifically so a crash report isn't just a wall of hex addresses. blutter reads that table directly out of the snapshot and prints the match as a `;`-comment after every call it can resolve — it isn't inferring or guessing, it's reading the same metadata the Dart VM itself would use. Three shapes recur constantly, worth telling apart on sight:

- **`; [package:dio/src/options.dart] Options::compose`** — a call into a specific package's specific class and method. The bracketed path _is_ the package name: `package:dio/...` is the third-party HTTP client, `package:login_flutter/...` is Spaggiari's own shared login library (a separate package from `package:classeviva/` itself, see [[Login-Network-Request]]), `package:classeviva/...` is the app's own first-party code, `package:reactive_forms/...` / `package:provider/...` are other third-party dependencies. Reading just this one bracketed path is usually enough to decide, before reading a single instruction of the callee, whether you're looking at "app logic worth following into" or "a well-known library doing its own thing underneath."
- **`; [dart:core] DateTime::parse`, `; [dart:collection] ...`, `; [dart:convert] ::jsonEncode`** — a call into the Dart SDK itself: no `package:` prefix, just the built-in library name (`dart:core`, `dart:collection`, `dart:convert`, `dart:_compact_hash`, ...).
- **A bare name with no bracketed path at all**, e.g. `; AllocateArrayStub`, `; AwaitStub`, `; IsType_String_Stub` — one of the Dart VM's own hand-written stubs (see [[Flutter-Dart-AOT#Explanation|Stubs]]), not compiled from _any_ Dart source, first- or third-party. These are the ones worth recognizing by name and skipping past rather than trying to "find the package" for.

The same recovered-metadata mechanism is _also_ what lets every `Obj!ServerNation@1196871`, `Instance_LoginType`, and field/class name throughout this vault's excerpts show up as a name instead of a bare address — it's one consistent capability (reading the snapshot's own class/function tables), applied to both call targets and data references.

### How a package/class reference actually gets loaded into a register

The annotation on a `bl` line tells you _what_ is being called; separately, most excerpts also show _how a specific value gets into a register_ before it's used — this is the object-pool mechanism from [[Flutter-Dart-AOT#Explanation|the object pool]], and it's worth reading as a fixed two-instruction idiom rather than two unrelated lines:

```
add   x16, PP, #0x1d, lsl #12   ; PP + a page-sized offset -> the address of one pool SLOT
ldr   x16, [x16, #0xc88]        ; the actual value living in that slot -- here, Obj!ServerNation@1196871
```

The `;` comment on the second line (`[pp+0x1dc88] Obj!ServerNation@1196871`) is blutter telling you what it resolved _that specific pool slot's contents_ to be — again read out of the snapshot's own object graph, not guessed from context. Whether the slot holds a string literal, a `TypeArguments` object, an enum singleton, or (for a call) a `Code` object's entry point makes no difference to the instruction pair itself; only the comment tells you which. A direct `bl #0xADDRESS` (as opposed to an indirect call through a pool-loaded value) skips this entirely and jumps straight to a statically-known address — blutter annotates that address the same way, just without needing a pool load first.

### From source construct to compiled shape

A quick index of the specific idioms this case study's notes decode, and where each is explained:

| Dart source shape | Compiled shape you'll see | Explained in |
| --- | --- | --- |
| a string/object literal | pool load: `add x16, PP, #page, lsl #12` / `ldr x16, [x16, #off]` | [[Flutter-Dart-AOT]] |
| `"$a.$b"`-style interpolation | `AllocateArray()` + per-piece `StoreField`/`ArrayStore` + `_StringBase::_interpolate()` | [[Api-Endpoint-Strings]] |
| `a + b` string concatenation | a single `_StringBase::+()` call | [[Api-Endpoint-Strings]] |
| `jsonMap[key]` on a `Map<String, dynamic>` | `GDT[cid + offset]()` virtual call, then `IsType_<Type>_Stub` | [[Login-Response-Parsing-And-Token-Storage]] |
| an `enum` value compared or used as a Map key | a pool-loaded `Obj!EnumType@addr` singleton, compared by identity or hashed as a key | [[Enum-Switch-Via-Pointer-Comparison]], [[Api-Endpoint-Strings]] |
| `DateTime.parse(s)` | a direct `bl` to `[dart:core] DateTime::parse` | [[Login-Response-Parsing-And-Token-Storage]] |
| `await someFuture` | the call producing the future, then `bl AwaitStub` | [[Login-Network-Request]], [[MethodChannel-Invoke-And-Await]] |
| an entire `async` function | `InitAsync()` … `ReturnAsyncNotFuture()` / `ReThrow()` wrapping the body | [[Login-Network-Request]] |

## Findings

- [[Reading-A-Dart-Function-Prologue]] — `GradeUtils.getAvg`'s prologue/epilogue and its two closures, read end to end
- [[Recognizing-Enum-Dispatch]] — `AbsenceLocalizations.absenceAbbreviationName`'s cascading enum-pointer comparisons
- [[Async-Await-And-Platform-Channels]] — the SPID login page's `MethodChannel.invokeMethod` + `await` boundary into native/Java code
- [[Object-Layout-And-Write-Barriers]] — `_Absence.toString()`'s array-store write barrier and what it reveals about the object's field layout
- [[Tagged-Integers-And-Boxing]] — Smi-vs-Mint boxing decisions across `grade_utils.dart` and `identity_utils.dart`
- [[Login-Network-Request]] — the credentials-form sign-in path: form → `SignInBloc` → the real `rest/v1/auth/login` POST, and the fuller `InitAsync`/`ReturnAsyncNotFuture` async compiled shape
- [[Login-Response-Parsing-And-Token-Storage]] — the login response's fields and where the session token ends up on-device
- [[Api-Endpoint-Strings]] — where the server hostnames/paths live, and the two unrelated login mechanisms (REST vs. WebView) they belong to

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
- [[Flutter-Dart-AOT]]
