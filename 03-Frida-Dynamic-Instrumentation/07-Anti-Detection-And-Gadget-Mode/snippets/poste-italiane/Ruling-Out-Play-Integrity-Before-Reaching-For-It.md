---
tags: [snippet]
level: 3
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "one-shot Frida enumeration script, not app source"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Ruling-Out-Play-Integrity-Before-Reaching-For-It

## Context

[[Anti-Detection-And-Gadget-Mode]] doesn't cover Play Integrity directly, but the temptation to reach for it is common: "root/Frida detection is passing every local check, so it must be a hardware-attested signal instead" is a plausible-sounding but unverified escalation. Play Integrity requires Magisk Zygisk + DenyList + Shamiko + a Play Integrity Fix module with a valid keybox to spoof — real effort, worth confirming is actually needed *before* investing in it, not after.

## Original path

`` one-shot enumeration script, run via frida -U -p <pid> -l script.js -q -t <N> ``

## Snippet

```javascript
Java.perform(function () {
    Java.enumerateLoadedClasses({
        onMatch: function (name) {
            const lower = name.toLowerCase();
            if (lower.indexOf("integrity") !== -1 || lower.indexOf("attestation") !== -1 || lower.indexOf("safetynet") !== -1) {
                console.log("[class] " + name);
            }
        },
        onComplete: function () { console.log("[done]"); }
    });
});
```

Run against this app mid-login, every result was a stock OS class (`android.content.integrity.AppIntegrityManager`, `android.security.keystore.AttestationUtils`, ...) — Android's own APK-signature/install-integrity framework, present in *every* app regardless of whether it calls Play Integrity. Not one `com.google.android.play.core.integrity.*` or `com.google.android.gms.*integrity*`/`*safetynet*` class appeared.

### Example — the full negative-result list, worth reading in full once

Every single match this run produced, in full, is what makes the negative result trustworthy rather than just "I didn't see anything obviously named Play Integrity":

```
android.security.keymaster.KeyAttestationPackageInfo$1
android.content.integrity.IntegrityUtils
android.security.FileIntegrityManager
android.content.integrity.AppIntegrityManager
android.security.keystore.DeviceIdAttestationException
android.content.integrity.IntegrityFormula
android.security.keymaster.IKeyAttestationApplicationIdProvider
android.content.integrity.AtomicFormula
android.security.keystore.AttestationUtils
... (30 total, every one android.* or android.security.*)
```

Every result shares the `android.`/`android.security.` prefix — the platform's own `PackageManager`-level app-integrity and hardware `KeyStore` attestation framework, present in every Android app whether or not it's used. Confirming the pattern ("all results share this one prefix, none carry `com.google.android.play` or `com.google.android.gms`") is what turns a long, easy-to-skim class list into an actual answer, rather than eyeballing thirty unfamiliar names and hoping nothing relevant was missed.

## Notes

- A genuinely correct-credentials login still failed with a generic error at this point in the investigation — exactly the situation that invites blaming device-trust attestation. This enumeration answered the question directly instead: the app hadn't loaded a single Play Integrity API class through the *entire* login flow, so spoofing a signal it never requests in the first place couldn't have been the fix.
- The actual cause turned out to be unrelated to any anti-tampering signal at all — a genuinely wrong PIN, found later via [[Recovering-JWE-Plaintext-By-Hooking-The-JOSE-Library]] — reinforcing the same lesson from a different angle: check the cheap, directly-observable signals (this enumeration; the app's own RSA fraud SDK header in [[Confirming-A-Bypass-Against-The-Apps-Own-Fraud-SDK]]) before assuming the expensive, hard-to-verify explanation.
- Doesn't prove Play Integrity is *never* relevant to this app — only that it wasn't loaded during this specific flow, at this specific point. A different flow (e.g. enrolling a brand-new passkey) could in principle trigger it; the enumeration would need re-running at that point to know.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Anti-Detection-And-Gadget-Mode]]
- [[Enumerating-Loaded-Classes-By-Keyword]]
- [[Login-AT01-And-Device-Trust-Signals]] and [[Poste-Italiane]] in [[Case-Studies]]
