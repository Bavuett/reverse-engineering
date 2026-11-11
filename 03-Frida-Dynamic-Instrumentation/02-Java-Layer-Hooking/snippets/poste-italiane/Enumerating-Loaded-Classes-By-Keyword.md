---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "one-shot Frida enumeration scripts, not app source"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Enumerating-Loaded-Classes-By-Keyword

## Context

This case study never touched a decompiler. Every class hooked — an app-custom TLS interceptor, a sealed error hierarchy, a bundled third-party crypto library — was found the same way: run a one-shot `Java.enumerateLoadedClasses` scan against the already-instrumented, running process with a keyword guessed from context (an error string, a telemetry field, a JWE header value), then narrow from there. [[Java-Layer-Hooking]] introduces `Java.enumerateLoadedClasses`/`Java.choose` as the way to see what's *actually* loaded versus what static analysis says merely exists — this is that idea used systematically, as the very first step of an investigation rather than a fallback.

## Original path

`` one-shot enumeration scripts, run via frida -U -p <pid> -l script.js -q -t <N> ``

## Snippet

```javascript
Java.perform(function () {
    Java.enumerateLoadedClasses({
        onMatch: function (name) {
            if (name.toLowerCase().indexOf("keyword") !== -1) console.log("[class] " + name);
        },
        onComplete: function () { console.log("[done]"); }
    });
});
```

Four real keywords this exact pattern resolved, each from a different kind of lead:

| Keyword | Where the lead came from | What it found |
| --- | --- | --- |
| `"SSLInterceptor"` | The app's own telemetry logging a `pt_class_name: SSLInterceptor` field alongside an SSL error | `it.posteitaliane.df_utils.network.SSLInterceptor` — a custom OkHttp `Interceptor` doing manual, independent trust validation |
| `"jose"` / `"jwe"` / `"nimbus"` | The `alg`/`enc`/`cty` key names in a captured JWE header, a strong fingerprint for a specific library's serializer | `com.nimbusds.jose.*` — confirmed the app bundles Nimbus JOSE+JWT, not a hand-rolled encryption layer |
| `"integrity"` / `"attestation"` / `"safetynet"` | A hypothesis to check ("does this app even call Play Integrity?") rather than an observed lead | Only stock `android.content.integrity.*`/`android.security.*` framework classes — **no** `com.google.android.play.core.integrity.*`, ruling the hypothesis out directly |
| `"PostePasskeyThrowable$"` | The class name already known from a package-structure enumeration pass over `it.posteitaliane.df_sessionmanager.*` (a broader sweep than a single keyword — see Example 2 below) | Every sealed-subclass name at once: `PasskeyCredentialNotFound`, `PasskeyUnauthorized`, `PasskeyServiceError`, `PasskeyDeviceToOld`, `PasskeyJWASRSA1`, ... — fed directly into [[Hooking-A-Lazily-Loaded-Class-With-A-Retry-Loop]] |

A second, coarser use of the exact same primitive: instead of one narrow keyword, matching a whole package prefix to map an unfamiliar app's architecture from scratch, with no prior lead at all:

```javascript
Java.perform(function () {
    Java.enumerateLoadedClasses({
        onMatch: function (name) {
            if (name.indexOf("it.posteitaliane.df_sessionmanager") === 0) console.log("[class] " + name);
        },
        onComplete: function () { console.log("[done]"); }
    });
});
```

This one pass surfaced the entire login-related package tree in one shot — `LoginViewModel`, `SessionManagerRepository`, `init.LibraryHelper`, `passkey.domain.PassKeyHelper`, `passkey.model.PostePasskeyThrowable`, `datasource.login.repository.PassKeyRepository`, and a dozen more — the raw material [[App-Architecture-And-Login-Flow-Mapping]] turned into a package map, entirely before any static decompilation.

## Notes

- Run as an independent one-shot session (`-p <pid> -q -t <seconds>`) against the *already-running, already-hooked* process, not folded into the main long-running instrumentation script — cheap and disposable, exactly matching [[Frida-Fundamentals]]'s attach mode for "something that already exists, I just need to look at it once."
- The negative result (`"integrity"` finding nothing from Google Play Services) is as valuable as a positive one: it directly answered "would spoofing Play Integrity fix this?" without guessing — see [[Login-AT01-And-Device-Trust-Signals]] for the full reasoning this fed into.
- This is step 1 of a three-step loop that recurs throughout this case study: enumerate by keyword → [[Dumping-Real-Method-Signatures-Before-Hooking]] → hook with [[Capturing-A-Stack-Trace-From-Inside-A-Hook]]. See [[App-Architecture-And-Login-Flow-Mapping]] for the generalized write-up of the full loop.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Java-Layer-Hooking]]
- [[Beginning-Enumerate-Loaded-Classes]] in [[PressReader]]
- [[App-Architecture-And-Login-Flow-Mapping]] and [[Poste-Italiane]] in [[Case-Studies]]
