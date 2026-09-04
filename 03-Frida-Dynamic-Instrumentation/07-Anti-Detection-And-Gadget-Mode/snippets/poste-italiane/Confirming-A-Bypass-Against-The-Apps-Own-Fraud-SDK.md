---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "decoded x-rsa HTTP header, captured via http-pinning-bypass-and-dump.js (not app source)"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns. Real device identifiers redacted."
---

# Confirming-A-Bypass-Against-The-Apps-Own-Fraud-SDK

## Context

[[Anti-Detection-And-Gadget-Mode]] treats "does the bypass actually work" as something you generally
have to infer indirectly (the app stops refusing to run, a feature that was blocked now works). Here,
the app's own bundled fraud/device-fingerprinting SDK made the answer directly observable: it sends its
own compromise verdict, in plaintext, in a header on every request to `idp-poste.poste.it` — reading it
back is a rare, direct confirmation that a Java-layer hiding strategy fooled a real third-party
detection SDK, not just the app's own hand-rolled checks.

## Original path

`` x-rsa header value, base64-decoded from a captured request (see [[Network-Interception]]'s request
logger) ``

## Snippet

```json
{
  "DeviceModel": "BV5200 Pro",
  "DeviceSystemName": "Android",
  "SDK_VERSION": "4.2.0",
  "Compromised": 0,
  "Emulator": 0,
  "appVersion": "6.0.38"
}
```

### Example — the same header, decoded again much later, still reporting clean

The header is sent fresh on every request, not cached once at login — decoding it again from a request
captured well after login, mid-authenticated-session, is what actually confirms the bypass holds up
over time rather than just at one lucky moment:

```javascript
// Node, run against a locally saved base64 x-rsa header value from a later request
const b64 = "eyJUSU1FU1RBTVAiOiIyMDI2LTA5LTA0VDEyOjAwOjU4WiIsIlRpbWVab25lIjoiMi4wIi...";
console.log(JSON.parse(Buffer.from(b64, "base64").toString()));
// -> { ..., "Compromised": 0, "Emulator": 0, ... }  — unchanged
```

Between the two captures, the app had gone through a full login cycle (multiple app process restarts,
one force-stop) and a Magisk module install (Shamiko) mid-session — any of those would be a plausible
point for a device-trust signal to flip if the hiding were fragile or session-scoped. It didn't.

## Notes

- `RSA_ApplicationKey` and `SDK_VERSION` strongly identify this as an RSA (the security division)
  Adaptive Authentication–style mobile risk SDK — commonly bundled into Italian banking/PA apps for
  device-trust scoring, independent of and in addition to Google Play Integrity.
- `"Compromised": 0` on a device that is, factually, rooted with Magisk, running Frida, and had Shamiko
  installed mid-session is the concrete pass/fail signal for
  [[Hiding-Root-Artifacts-With-One-Compiled-Regex]]'s and [[Blocking-The-Frida-Control-Port-Scan]]'s
  combined effect — this SDK's own local device checks (whatever they are internally; the SDK is
  closed-source) evidently route through the same `File`/`PackageManager`/`Build`/`Socket` APIs already
  hooked, rather than an independent native-level check those hooks miss.
- This is *not* the same thing as confirming Play Integrity would also report clean — that's a
  separate, hardware-attested signal this SDK's own header has nothing to do with. See
  [[Ruling-Out-Play-Integrity-Before-Reaching-For-It]] for how that separate question was answered.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Anti-Detection-And-Gadget-Mode]]
- [[Network-Interception]]
- [[Login-AT01-And-Device-Trust-Signals]] and [[Poste-Italiane]] in [[Case-Studies]]
