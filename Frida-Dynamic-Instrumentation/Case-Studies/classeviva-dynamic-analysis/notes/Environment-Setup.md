---
tags: [case-study-note]
case_study: "Classeviva-Dynamic-Analysis"
created: 2026-07-28
---

# Environment-Setup

## Question / goal

Get a rooted, Frida-instrumented Android environment capable of running ClasseViva Studenti 5.9.1 for dynamic analysis, on an x86_64 Windows host with no ARM64 hardware available.

## Relevant source

N/A — this note documents environment setup, not source analysis. See [[ARM64-Android-Case-Studies|ARM64-Android's classeviva-flutter case study]] for the imported Dart-AOT disassembly this environment will eventually be used against.

## Excerpt

The distributed package (`ClasseViva+Studenti_5.9.1_APKPure.xapk`) turned out to ship only an `arm64_v8a` native split — no `x86_64` split at all:

```
eu.spaggiari.classevivastudente.apk   (base)
config.arm64_v8a.apk                  (native libs — arm64 only)
config.en.apk / config.mdpi.apk / config.zh.apk  (density/locale splits)
```

Final verification, after install:

```
$ adb shell pm list packages | grep spaggiari
package:eu.spaggiari.classevivastudente
$ adb shell dumpsys package eu.spaggiari.classevivastudente | grep versionName
    versionName=5.9.1
```

## Analysis

Two constraints had to be satisfied simultaneously, and the "obvious" choices for each one turned out to be mutually exclusive:

1. **Root**, for `frida-server` to run at all → requires a `google_apis` (non-Play-Store) system image, since those are `userdebug` builds that support `adb root` directly.
2. **Ability to run the app's `arm64_v8a`-only native split**, given the host CPU is x86_64 → the Android Emulator's QEMU2 backend outright refuses an `arm64-v8a` AVD on an x86_64 host ("Avd's CPU Architecture 'arm64' is not supported by the QEMU2 emulator on x86_64 host"), so a real arm64 AVD was never an option here at all.

The image actually used — `system-images;android-30;google_apis;x86_64` — satisfies both: it's `userdebug` (confirmed via `adb shell getprop ro.build.type` → `userdebug`, and `adb root` + `adb shell whoami` → `root`), and it bundles `libndk_translation` (confirmed via `adb shell find /system -iname '*ndk_translation*'`, which listed `libndk_translation.so` plus per-API translation proxies in both `lib/` and `lib64/`) — Google's ARM-code translation layer, letting an x86_64-OS emulator still execute `arm64-v8a` app native code, which is exactly what this app's `arm64_v8a`-only split needs.

`frida-server` itself is a **native x86_64 binary** (`frida-server-17.2.16-android-x86_64`), matching the actual host OS architecture — not the app's arm64 code. It runs as root from `/data/local/tmp`, with TCP port 27042 forwarded, and `frida-ps -U` from the host confirmed a working client/server handshake against the full process list.

See [[Frida-Server-Setup]] for the general, reusable version of this setup (any app, any host).

## Related concepts

- [[Frida-Fundamentals]]
- [[Flutter-Dart-AOT]] in [[ARM64-Android]] — why this specific app's native split matters at all (Dart AOT compiles to a `libapp.so`, not to portable bytecode).

## Open questions / next steps

- Confirm whether ClasseViva's networking goes through Dart's own BoringSSL (expected for a Flutter app — see [[Network-Interception]]) by checking which native library exports `SSL_write`/`SSL_read` (`libflutter.so` vs. `libapp.so`) before writing a traffic-dumping hook.
- Try hooking whatever string-construction/decoding routines are already identified in the static Dart-AOT disassembly (see [[Native-Memory-And-ARM64]]) to confirm their runtime output against the static hypothesis, rather than re-deriving it by hand.
- Check for any root/tamper detection on app launch — install failed silently is not the same as detection at runtime, and this hasn't been tested yet.

## See also

- [[Frida-Dynamic-Instrumentation-Case-Studies|Case Studies]]
