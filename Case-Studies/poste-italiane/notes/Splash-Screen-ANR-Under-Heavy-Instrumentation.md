---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-03
---

# Splash-Screen-ANR-Under-Heavy-Instrumentation

## Question / goal

With [[root-and-frida-hiding.js]] loaded alongside the pinning bypass and login diagnostics, the
app started reproducibly freezing on its splash screen and getting killed by Android with an ANR
(Application Not Responding), every single spawn. Was this the app's own anti-tampering logic
deliberately stalling once it detected root/Frida (a real, if unusual, defensive pattern), or
something in the instrumentation itself?

## How this was found

The freeze was completely silent from Frida's side: the console showed exactly the same four
`File.exists` log lines every time (`/system/app/Superuser.apk`, `/system/xbin/su`, each checked
twice) and then nothing — no further hook fired, not even ones covering totally unrelated APIs
(`Socket.connect`, `TrustManagerImpl.verifyChain`, `getInstalledPackages`). That silence was itself
the first real clue: if the app's own code were still running and making calls, *something* hooked
would have logged, even if it were a completely different code path than the one that hung. Nothing
firing at all pointed at either a native-code stall (outside anything Java-layer hooks can see) or
a wait on something entirely external, like a blocked I/O or Binder call.

Two dead ends were tried first, based on the reasonable but wrong assumption that our own hooks
were adding too much overhead:

1. **Assumed the native `fgets` hook (`root-and-frida-hiding.js`'s `/proc/self/maps` filter) was
   too broad** — it intercepts every `fgets()` call process-wide, not just reads of that one file.
   Disabled it entirely (`ENABLE_NATIVE_MAPS_FILTER = false`, still the default in the script).
   The ANR reproduced identically without it — ruled out.
2. **Found and fixed a real bug** in the `getInstalledPackages`/`getInstalledApplications` and
   `Runtime.exec` hooks: they called back into the original implementation via `ov.apply(this,
   args)`, where `ov` was the *already-replaced* overload object — an infinite recursion bug that
   would hang whatever thread called either method. Genuinely worth fixing (documented in the
   script's own comments now), but the ANR reproduced identically after the fix too — meaning
   neither hooked method was even being called yet when the freeze happened, which the log
   confirms (no `[root-hide] getInstalledPackages` or `Runtime.exec` line ever appears before the
   hang).
3. **Optimized `File.exists()`'s hot path** (single compiled regex instead of
   `Array.some()`+`.includes()` over six fragments, dropped the `canExecute()` hook entirely to
   roughly halve call volume). Same exact hang, same four log lines, every time — this is what
   finally ruled out "our hook is just too slow under heavy call volume" as the explanation, since
   a real volume problem would at least shift *when* the freeze happens, not reproduce an identical
   four-line stopping point regardless of per-call cost.

With all three variations producing an identical, deterministic hang, the cause had to be
*downstream* of those four file checks, not the checks themselves. `adb logcat -d` around the ANR
timestamp gave the actual answer directly, instead of more guessing from the Frida side:

```
09-03 23:39:05.531 ActivityManager: Timeout executing service: ServiceRecord{...
    com.posteitaliane.spim/com.google.android.datatransport.runtime.scheduling.jobscheduling.JobInfoSchedulerService}
09-03 23:39:05.576 AnrManager: App crashed on incremental package com.posteitaliane.spim which is 100% loaded.
```

`TracerPid` on the app's own `/proc/<pid>/status` also read `0` at the time — ruling out the theory
that Frida's Java-layer hooking leaves a `ptrace`-visible trace this app's own code might be
checking for and reacting to.

## Relevant source

- [[root-and-frida-hiding.js]]

## Excerpt

```
Timeout executing service: ServiceRecord{u0 com.posteitaliane.spim/com.google.android.datatransport.runtime.scheduling.jobscheduling.JobInfoSchedulerService}
AnrManager: App crashed on incremental package com.posteitaliane.spim which is 100% loaded.
```

## Analysis

`com.google.android.datatransport.runtime.scheduling.jobscheduling.JobInfoSchedulerService` is not
app code at all — it's part of Google's `transport-runtime` library (the batching/upload layer
underneath Firebase Analytics/Crashlytics-style telemetry, present in a huge fraction of Android
apps). A `JobScheduler`-backed `JobService`'s `onStartJob`/`onStopJob` callbacks run on the app's
main thread and are contractually required to return quickly (offloading real work to a background
thread) — if they block, Android's own ANR watchdog for that *service* fires, independent of
whether the rest of the app's UI is responsive. That's a different, more specific mechanism than a
generic "main thread frozen" ANR, and it points at this one background job, not at the splash
screen's own visible logic.

The most likely mechanism, in order of how the pieces fit: this job almost certainly tries to flush
a batch of queued analytics events over HTTPS. Every one of those connections passes through the
*exact same* `TrustManagerImpl`/`CertificatePinner`/`SSLInterceptor`/`RealInterceptorChain` hooks
installed for the login flow — [[http-pinning-bypass-and-dump.js]] intercepts pinning
process-wide, not scoped to any particular request. If any single one of those hooks adds enough
latency, or if the specific analytics endpoint's connection stalls for a reason unrelated to our
hooks entirely (this device's Wi-Fi network, `Barretta Wi-Fi`, was already seen behaving oddly with
an airplane-mode toggle in [[Frida-Server-Setup-On-The-Blackview]]), a background job with a short,
non-negotiable timeout is exactly the kind of thing that would be first to trip — well before the
splash screen's own, presumably more generously-timed, network calls would.

This reframes the earlier "device trust score" hypothesis from the session that led to
[[root-and-frida-hiding.js]] existing at all: **not every failure on this rooted, heavily
instrumented test device is anti-fraud detection.** Some of it is ordinary infrastructure friction
— a background telemetry job with a tight deadline, running on a device where every HTTPS
connection now has extra hooks in its path — that happens to look identical, from the outside, to a
deliberate stall.

## Generalizing the pattern

When an app freezes or ANRs under heavy Frida instrumentation and the cause isn't obvious:

1. Check whether *any* hooked method fires between the last confirmed activity and the freeze — if
   nothing does, the stall is native, in a completely different code path, or blocked on I/O/Binder,
   not in whatever you were looking at.
2. Read `adb logcat -d` around the exact ANR timestamp before assuming it's your own hooks — Android
   usually names the specific blocked component (a `Service`, a `BroadcastReceiver`, an input
   event) rather than just "the app froze," and that name often rules out entire theories instantly.
3. Only after logcat points at something *specific and reproducible* is it worth going back to
   optimizing or disabling individual hooks — doing that first, based on a guess, cost three
   iterations here before logcat gave the direct answer in one read.

## Related concepts

- [[Java-Layer-Hooking]] — why `.implementation =` replacement adds real per-call overhead, the
  starting (wrong) theory here.
- [[Anti-Detection-And-Gadget-Mode]] — the root/Frida-detection techniques
  [[root-and-frida-hiding.js]] hides, which this note's finding shows were never actually the cause
  of this particular freeze.

## Open questions / next steps

Both follow-ups below were tried and **ruled out** — the freeze is not caused by anything in these
three scripts:

- [x] Retried the login flow cold, twice more. The freeze reproduced at the exact same point
      (identical four `File.exists` log lines, then silence) every single time — not transient or
      racy, contradicting the "coincidental network blip" half of the original theory.
- [x] Disabled `http-pinning-bypass-and-dump.js`'s request/response logger entirely
      (`ENABLE_HTTP_LOGGING = false`, added specifically for this test — keeps the four pinning
      bypasses active, removes the `RealInterceptorChain.proceed` hook that does the most per-call
      work: reading full headers and bodies, including `peekBody()` on every response). Identical
      freeze, same exact point. This rules out request/response *logging* overhead specifically.

Combined with the earlier `File.exists` optimization and `fgets` hook removal (both also inconclusive
— see above), **every hook-overhead theory tested so far has failed to change the outcome**, run
after run, all four variations landing on the identical four-line stopping point. That consistency
is itself evidence: a real overhead problem should shift *where* the freeze happens as the hooked
code gets cheaper or disappears entirely; instead the stopping point never moved even once. The
`JobInfoSchedulerService` timeout is very likely a genuine, independent issue — a real network/DNS
problem reaching Google's Datatransport ingestion endpoint from this specific Wi-Fi network, or a
native-level stall entirely outside what these Java-layer scripts can see or affect — rather than
something these three scripts are causing.

- [ ] Test from mobile data instead of `Barretta Wi-Fi` (already flagged as behaving oddly — the
      airplane-mode toggle in [[Frida-Server-Setup-On-The-Blackview]]) to isolate whether this is
      network-specific.
- [ ] If it reproduces on mobile data too: this is very likely outside what Frida instrumentation
      can diagnose further without native-level tooling (e.g. `strace`/native stack sampling on the
      frozen process) — treat continuing to chase it as a new, separate investigation rather than a
      blocker on this case study's other findings, which stand on their own regardless.

## See also

- [[Case-Studies]]
