---
tags: [case-study]
project: "PressReader"
source: "PressReader Android app"
version: "unknown"
obtained_via: "Google Play"
tools_used: "Frida, adb"
topics: ["Frida-Dynamic-Instrumentation"]
date_started: 2026-09-05
status: "in-progress"
license_note: "Personal study/research purposes only, against a device and account the investigator owns. Only import the fragments actually needed; check the app's ToS before sharing publicly."
---

# PressReader

## Overview

The **PressReader** app case study.

## Source layout

`source/` holds the instrumentation scripts, loaded together once the app is spawned:

- `inspect-loaded-classes.js` — a `Java.enumerateLoadedClasses` scan filtering for
  `okhttp`/`retrofit`/`volley` substrings, used as the very first probe against the running app
  before any static analysis. See [[Beginning-Enumerate-Loaded-Classes]].
- `inspect-stacktrace.js` — hooks `java.net.URL.$init` and prints a synthetic (never-thrown)
  exception's stack trace for each real network URL constructed, to map obfuscated call chains
  around known library anchors without decompiling. See
  [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]].

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

## Open questions / next steps

- [x] Initial installation and setup.
- [ ] Set up an `okhttp3.Interceptor`/`CertificatePinner` hook as the primary traffic-visibility
      target — see [[Beginning-Enumerate-Loaded-Classes]]'s open questions.
- [ ] Investigate the gRPC channel separately, since it isn't visible through an `okhttp3`-level
      hook alone.
- [ ] Confirm or refute the obfuscated-class hypotheses from
      [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] by hooking `w50.q.i` directly.

## See also

- [[Case-Studies]]
