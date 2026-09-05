---
tags: [case-study]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app ('Super P'), obtained from Google Play"
version: "unknown (not yet installed on the test device — see Overview)"
obtained_via: "Google Play, package id com.posteitaliane.spim"
tools_used: "Frida, adb"
topics: ["Frida-Dynamic-Instrumentation"]
date_started: 2026-09-03
status: "in-progress"
license_note: "Personal study/research purposes only, against a device and account the investigator owns. Only import the fragments actually needed; check the app's ToS before sharing publicly."
---

# Poste-Italiane

## Overview

The **Poste Italiane** app (package `com.posteitaliane.spim`, the "SPIM" the app is referred to by
in this case study) is Poste Italiane's official Android app — bank account, PostePay, mail
tracking, and public-administration services bundled into one "Super P" client. This case study's
goal is purely **network visibility**: bypass whatever TLS/certificate pinning the app applies and
read its HTTP requests and responses in plaintext, using Frida rather than a MITM proxy's CA
certificate, so nothing about the device's trust store has to change.

The generic techniques this draws on — hooking `TrustManagerImpl`/`CertificatePinner` at the Java
layer vs. hooking `SSL_write`/`SSL_read` at the native layer — are already covered in
[[Network-Interception]]; this case study is that chapter's techniques pointed at one real,
specific app instead of the abstract pattern.

**Status as of 2026-09-04**: installed (Play Store, `arm64-v8a` split — the 32-bit-agent crash from
[[Frida-Server-Setup-On-The-Blackview]] never came up) and running under Frida on the test device.
TLS interception works end-to-end (all five bypasses in `http-pinning-bypass-and-dump.js` fire
against real checks — notably a custom app-level `SSLInterceptor` and, found only after login started
succeeding, Android's own declarative `network_security_config.xml` pinning
(`NetworkSecurityTrustManager`, independent of the `TrustManagerImpl`/`CertificatePinner` pair) on
`oneapp.poste.it`/`appup.mobile.poste.it` specifically — see
[[Embedded-OAuth2-Client-Credentials]] and [[Home-Screen-Skeleton-NetworkSecurityConfig-Pinning]]), and
root/Frida hiding in `root-and-frida-hiding.js` is confirmed effective against every locally-checkable
signal the app uses — Java-layer checks (`Superuser.apk`, `su` path scanning, `PackageManager`
lookups, `Runtime.exec("which su")`) **and** the app's own bundled RSA fraud/device-fingerprint SDK,
which reports `Compromised: 0` after hiding — see [[Login-AT01-And-Device-Trust-Signals]]. **Login now
succeeds**: the earlier failure (`AT01`/`login_required`, an OIDC "no session yet" response, not an
anti-tampering block) and the empty passkey `allowCredentials` both turned out to be symptoms of one
cause — this device/account combination had never completed Poste's identity-onboarding flow — and
resolved once that onboarding (`OnboardingCreaPosteIdActivity`) was completed. Play Integrity spoofing
was investigated and ruled out as necessary for this specific flow: live class enumeration found the
app never loads any Play Integrity API classes during login. See
[[App-Architecture-And-Login-Flow-Mapping]] and [[login-diagnostics.js]] for the live
class/method-enumeration workflow used throughout this investigation.

## Source layout

`source/` holds the instrumentation scripts, loaded together once the app is spawned:

- `http-pinning-bypass-and-dump.js` — combined SSL-pinning bypass across five independent layers
  (platform `TrustManagerImpl`, OkHttp `CertificatePinner`, this app's own `SSLInterceptor`,
  `WebViewClient.onReceivedSslError`, and Android's declarative
  `network_security_config.xml`-backed `NetworkSecurityTrustManager` — see
  [[Home-Screen-Skeleton-NetworkSecurityConfig-Pinning]] for why that fifth one was needed at all)
  plus an OkHttp request/response logger hooked on `RealInterceptorChain.proceed` (now also logging
  any exception `proceed()` throws, e.g. a pinning failure, instead of the call just going silent), a
  curl-command exporter (one atomic `[curl] ...` line per request, ready to paste into Postman or a
  shell), a hook on this app's bundled Nimbus JOSE+JWT library
  (`com.nimbusds.jose.JWEObject.encrypt`/`.decrypt`) that prints JWE plaintext directly under the
  ciphertext body it belongs to — see [[Decrypting-JWE-Request-Response-Bodies]] for why offline
  decryption isn't feasible here and this hook-the-library approach is used instead — and a
  commented-out native `SSL_write`/`SSL_read` fallback for traffic that doesn't go through OkHttp's
  Java-visible chain.
- `root-and-frida-hiding.js` — Java-layer root/Frida-detection hiding (`File`, `PackageManager`,
  `Build`, `Runtime.exec`, a frida-server port-scan block) plus a native `libc` `fgets` filter for
  `/proc/self/maps` reads. See its own header comment for the Play Integrity caveat: this only
  covers what the app's own code can check, not a hardware-backed attestation verdict.
- `login-diagnostics.js` — hooks `LoginViewModel`'s error-surfacing methods and every
  `PostePasskeyThrowable` subclass constructor, logging arguments plus a full stack trace, to
  identify exactly which login error is firing and from where — written after TLS-layer capture
  alone turned out to show only JWE ciphertext for this specific flow.

There's no decompiled app source under `source/` yet — every finding so far came from live
class/method enumeration against the running process (see
[[App-Architecture-And-Login-Flow-Mapping]]'s "How this was found" for the reusable technique),
not static analysis.

## Relevant topics & background

- [[Network-Interception]] — the Java-layer-vs-native-layer decision this script's two halves
  (OkHttp interceptor logging, commented native fallback) are built from, and why each one is
  needed.
- [[Frida-Fundamentals]] — spawn (`-f`) vs. attach (`-p`); this case study uses both, spawning fresh
  whenever a hook needs to be in place before the app's first relevant call (pinning, root checks),
  and late-attaching only for quick, disposable class-enumeration probes.
- [[Java-Layer-Hooking]] — the general pattern behind every hook across all three scripts here.
- [[Anti-Detection-And-Gadget-Mode]] — the technique catalogue `root-and-frida-hiding.js` is a
  concrete, tested instance of.

## Findings

- [[Frida-Server-Setup-On-The-Blackview]] — the frida-server/client version mismatch and a
  device-wide 32-bit Frida agent crash discovered while getting Frida working on the test device
  at all, found using Chrome as a stand-in target before the real app was even installed.
- [[Embedded-OAuth2-Client-Credentials]] — a statically embedded OAuth2 `client_credentials` secret
  found in the app's cold-start traffic, and the app's own `SSLInterceptor` class discovered via the
  telemetry error it logged about the interception attempt.
- [[App-Architecture-And-Login-Flow-Mapping]] — the live class/method-enumeration workflow used to
  map the login flow's package structure and pin down `LoginViewModel`'s actual error-handling
  methods, once TLS-layer capture turned out to show only JWE ciphertext for this flow.
- [[Splash-Screen-ANR-Under-Heavy-Instrumentation]] — a reproducible splash-screen freeze/ANR
  traced to a Google Datatransport background job timing out; four separate overhead-reduction
  attempts (native `fgets` hook removed, `File.exists` optimized, HTTP logging disabled, a real
  infinite-recursion bug in `root-and-frida-hiding.js` fixed) all failed to change where the freeze
  happens, pointing at a cause outside these scripts entirely rather than hook overhead.
- [[Login-AT01-And-Device-Trust-Signals]] — decoded the passkey-challenge and RSA-fraud-SDK
  device-fingerprint payloads live, ruled out Play Integrity as necessary for this login flow via
  class enumeration, and traced both the `AT01` error and the empty passkey `allowCredentials` to one
  cause: this device/account had never completed Poste's identity-onboarding flow. Also documents (as
  an addendum in [[Frida-Server-Setup-On-The-Blackview]]) a `frida-server` daemon wedge triggered
  after installing a Magisk module mid-session, and the force-stop-and-respawn fix.
- [[Decrypting-JWE-Request-Response-Bodies]] — identified the app's bundled Nimbus JOSE+JWT library
  live and hooked `JWEObject.encrypt`/`.decrypt` directly to read JWE plaintext, after establishing
  that the `RSA-OAEP-256` key-wrapping algorithm makes offline decryption of captured ciphertext
  infeasible without either side's private key.
- [[Home-Screen-Skeleton-NetworkSecurityConfig-Pinning]] — the infinite home-screen skeleton and
  repeated "goes back to login" behavior after a successful login both traced to a fifth,
  previously-unhooked TLS pinning layer (`NetworkSecurityTrustManager`, Android's declarative
  `network_security_config.xml` pinning) applying to two specific hosts the other four bypasses never
  needed to cover — not a device-trust or real network issue.
- [[XKey-Key-Exchange-And-Request-Flow]] — synthesizes the JWE key material and provisioning steps
  traced across [[JWE-OTP-Payload-And-Key-Investigation]] and
  [[Decrypting-JWE-Request-Response-Bodies]] into one end-to-end picture: two independent RSA
  keypairs, one generated by each side during onboarding, each protecting exactly one traffic
  direction.

## Open questions / next steps

- [x] Reached and passed login — see [[Login-AT01-And-Device-Trust-Signals]] for the full trace and
      root cause.
- [x] Login fully succeeds end-to-end (2026-09-04): a later attempt that still appeared to "go back"
      after PIN entry turned out to be a genuinely wrong PIN, decoded live via
      [[Decrypting-JWE-Request-Response-Bodies]]'s `JWEObject` hook — the decrypted
      `authorizeTransaction` request body showed the actual submitted PIN, and the (plaintext, not
      JWE) response `{"command-error-code":"PIN-ERR-3","command-error-message":"User PIN error"}`
      confirmed it server-side. A retry with the correct PIN produced `"command-success":true` and
      the login flow completed through to `customer/home` — nothing to do with root/Frida detection
      or device enrollment, both already ruled out earlier tonight.
- [x] Capture and review the authenticated session's traffic — done as part of the above; full
      request/response log (JWE-decrypted, curl-exportable) saved to `local/`.
- [ ] If `AT01`/`login_required` reappears on a future login attempt from an already-onboarded
      account, investigate it as a standalone `LoginViewModel` UX quirk rather than a device/session
      issue.

## See also

- [[Case-Studies]]
