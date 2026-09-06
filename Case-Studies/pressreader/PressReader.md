---
tags: [case-study]
project: "PressReader"
source: "PressReader Android app"
version: "unknown"
obtained_via: "Google Play"
tools_used: "Frida, adb, JADX"
topics: ["Frida-Dynamic-Instrumentation"]
date_started: 2026-09-05
status: "in-progress"
license_note: "Personal study/research purposes only, against a device and account the investigator owns. Only import the fragments actually needed; check the app's ToS before sharing publicly."
---

# PressReader

## Overview

The **PressReader** app case study.

## Source layout

`source/` holds the instrumentation scripts, loaded together once the app is spawned. As of
2026-09-06, active script development happens in the private `rev-eng-art/pressreader/source/`
artifacts repo (full, uncurated copies plus real captures); this folder keeps the minimal fragments
each published note actually needs, synced over as they stabilize — see
[[Modularizing-Hook-Targets-With-An-Array-Structure]] for a script currently ahead of what's synced
here.

- `inspect-loaded-classes.js` — a `Java.enumerateLoadedClasses` scan filtering for
  `okhttp`/`retrofit`/`volley` substrings, used as the very first probe against the running app
  before any static analysis. See [[Beginning-Enumerate-Loaded-Classes]].
- `inspect-stacktrace.js` — hooks `java.net.URL.$init` and prints a synthetic (never-thrown)
  exception's stack trace for each real network URL constructed, to map obfuscated call chains
  around known library anchors without decompiling. See
  [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]].
- `inspect-obfuscated-methods.js` — hooks every overload of `FirebasePerfOkHttpClient.a` and dumps
  each argument's real runtime class and `toString()` value, to confirm (rather than just infer)
  what obfuscated types flow through it. See
  [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]].
- `java/w50/q.java` — decompiled (JADX) source of the obfuscated `w50.q` class, pulled from the app's
  `base.apk` to confirm a hypothesis formed purely from dynamic analysis. See
  [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]].
- `java/bp/m1.java` — decompiled (JADX) source of `bp.m1`, a second, independent network protocol
  manager (hand-built XML over plain `HttpURLConnection`, not `okhttp3`) found via a fresh stack
  trace while navigating account/device management. See [[Discovering-The-Core-XML-Protocol]].
- `inspect-api.ts` — hooks `bp.m1.e`, `bp.m1.f`, and `bp.m1.m` directly (each has a single overload,
  so no `.overloads` indirection is needed), logging the XML payloads `e`/`f` build and `m`'s call
  arguments/stack trace even though JADX never decompiled its body. See
  [[Hooking-The-Core-XML-API-Methods-Directly]].
- `smali/bp/m1.smali` — raw `baksmali` output for `bp.m1`, pulled specifically because JADX couldn't
  decompile `m()`; also the source for [[Final-Instance-Methods-Still-Dispatch-Virtually]], a
  [[Methods]] snippet on `final` methods and `invoke-virtual`, in `01-Dalvik-Bytecode`.

## Relevant topics & background

- [[Network-Interception]]
- [[Frida-Fundamentals]]
- [[Java-Layer-Hooking]]
- [[Static-Dynamic-Integration]]

## Findings

- [[Beginning-Enumerate-Loaded-Classes]] — a class-enumeration script filtering for
  `okhttp`/`retrofit`/`volley` first found only the platform's bundled `com.android.okhttp` fork
  (behind `HttpURLConnection`) at spawn; re-running it while navigating the app confirmed a second,
  app-level `okhttp3`/Retrofit stack loads lazily once real requests fire, and incidentally revealed
  a gRPC channel (`io.grpc.okhttp.internal.*`) and Firebase Performance Monitoring instrumentation
  (`FirebasePerfOkHttpClient`) neither the script nor the investigation was originally looking for.
- [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] — used `FirebasePerfOkHttpClient` (the one
  named class from the previous finding) as an anchor, hooked `java.net.URL`'s constructor, and
  forced a stack trace via a never-thrown `java.lang.Exception` to map the fully-obfuscated call
  chain around it — surfacing a real `titles/{id}/issues?accessToken=...` request and a ranked set
  of hypotheses for what each obfuscated class (`w50.q`, `kh.g`, `a60.e$a`) actually is.
- [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]] — dumped `FirebasePerfOkHttpClient.a`'s
  real argument classes/values, confirming `w50.a0` is `okhttp3.Response` (matched via its
  distinctive `toString()` format) and finding a second, always-hooked-wrong bug along the way: the
  call-through to the original implementation needs `this.a.apply(...)`, not the pre-hook `overload`
  reference. A parallel stack-trace run also surfaced Braze SDK traffic
  (`sdk.iad-0{1,6}.braze.com`, via `bo.app.*`) and a `dq.pressreader.com` beacon endpoint, neither
  previously accounted for.
- [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]] — pulled PressReader's `base.apk` off the
  device (`adb shell pm path` + `adb pull`) and decompiled it with JADX to check the
  `w50.q` = `okhttp3.HttpUrl` hypothesis against real source instead of just runtime behavior:
  matching field layout, a matching nested `Builder`, and a byte-for-byte matching `i()`/`url()`
  method body confirmed it outright.
- [[Modularizing-Hook-Targets-With-An-Array-Structure]] — reviewed the TypeScript rewrite of the
  argument-dumping script (`inspector.ts`, now developed in `rev-eng-art`), which added a
  reflection-based scan for fields of a confirmed obfuscated type inside any hooked method's
  arguments; documented turning its single hardcoded `Target` into an array of targets so the same
  hook-install logic can cover `kh.g`/`a60.e$a` without duplicating code.
- [[Discovering-The-Core-XML-Protocol]] — a fresh stack trace (captured while navigating account/device
  management, not catalog browsing) named an unfamiliar class, `bp.m1`. Decompiling it revealed a
  *second*, independent network protocol coexisting with the already-confirmed `okhttp3` one: hand-built
  XML (`<nd version='1.0'>...</nd>`, assembled by `bp.m1.f()`/`bp.m1.e()`) sent over a plain
  `HttpURLConnection` (`bp.m1.a()`), instrumented by `FirebasePerfUrlConnection` — a sibling of
  `FirebasePerfOkHttpClient`, confirming Firebase Perf wraps both of PressReader's HTTP stacks
  independently, not just the `okhttp3` one. The SAX response fields it parses
  (`user-activations`/`activation-number`/`client-number`) point at device activation/licensing, not
  catalog content — so this doesn't replace the earlier `okhttp3` findings, it's a separate protocol for
  a separate purpose. `bp.m1.m()`, the method actually named in the stack trace, is too large for JADX
  to decompile at all ("Method dump skipped"); reading it needs raw `.smali` instead, per
  [[Reading-Raw-Dalvik]].
- [[Hooking-The-Core-XML-API-Methods-Directly]] — reviewed a script hooking `bp.m1.e`/`f`/`m` directly:
  correctly reuses the `this.<methodName>(...)` call-through idiom, and hooks `m` purely for its call
  arguments and stack context since Frida can hook bytecode even where JADX couldn't decompile it.
  Design-only so far — not yet run against the app for real output.

## Open questions / next steps

- [x] Initial installation and setup.
- [ ] Set up an `okhttp3.Interceptor`/`CertificatePinner` hook as the primary traffic-visibility
      target — see [[Beginning-Enumerate-Loaded-Classes]]'s open questions.
- [ ] Investigate the gRPC channel separately, since it isn't visible through an `okhttp3`-level
      hook alone.
- [x] Confirm or refute the `w50.q` = `okhttp3.HttpUrl` hypothesis from
      [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] — confirmed via decompiled source in
      [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]].
- [ ] Repeat the same JADX-based confirmation for `kh.g` and `a60.e$a`, still only hypotheses.
- [ ] Identify what `ih.b` actually is (Firebase Perf's internal metric/timer object, per
      [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]]) and what `dq.pressreader.com`
      and the Braze SDK traffic are used for.
- [ ] Run [[inspect-api.ts]] against the app and capture real console output (hooks are written, per
      [[Hooking-The-Core-XML-API-Methods-Directly]], but not yet exercised).
- [ ] `bp.m1.m()`'s raw `.smali` is now imported (`smali/bp/m1.smali`) but its ~3,000-instruction body
      hasn't been read cold yet — a candidate for a future [[Reading-Raw-Dalvik]]-style worked example
      once there's a concrete reason to fully trace it, rather than relying on [[inspect-api.ts]]'s
      argument/stack-trace hook alone.
- [ ] Confirm whether the XML/`HttpURLConnection` protocol and the `okhttp3`/JSON one share a base
      host, or run on separate infrastructure entirely.

## See also

- [[Case-Studies]]
