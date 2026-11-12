---
tags: [snippet]
level: 3
project: "TUA (net.pluservice.tua)"
source: "net.pluservice.tua — Cordova/Android hybrid app, decompiled to smali from the APK"
version: "11.26.4"
source_path: "Frida script neutralize_root_check.js (not app source) — replaces com.google.zxing.oned.UPCEANExtension2Support.onMessageChannelReady(JJ)V"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. This is a small dynamic-analysis fragment kept to illustrate one patching pattern. Check the app's ToS before any redistribution."
---

# Neutralizing-A-Hidden-Check-With-A-No-Op-Implementation

> [!info] Level 3 — real code
> A real hidden root/tamper check, disabled without understanding its internals: the method that hosts it is replaced with an empty implementation, which wins even against reflective calls — provided the hook is in place before the app's earliest startup code runs.

## Context

In the TUA app, a root/tamper check was injected into a method of an unrelated, legitimate library class — ZXing's `UPCEANExtension2Support.onMessageChannelReady(long, long)` — and invoked by reflection from `com.google.firebase.provider.FirebaseInitProvider`, a content provider that runs during `handleBindApplication`, before any `Application.onCreate()` or `Activity`. The body uses reflection, strings decrypted at runtime, and a custom exception as a `goto`. Finding *which* method hosted it is the story of [[Anti-Tampering-Pattern-Workflow]]; this snippet is the fix. Part of [[Tua-Case-Study]].

## Original path

`neutralize_root_check.js` in the TUA case-study sources (run as `frida -U -f net.pluservice.tua -l neutralize_root_check.js`). Comments translated.

## Snippet

```javascript
/*
 * No need to understand the internal logic (reflection + runtime-decrypted strings
 * + a custom exception used as a goto): overwrite the whole method with a no-op.
 * Every caller, reflection included, still lands in this implementation because
 * Frida replaces the method's slot at ART level.
 *
 * IMPORTANT: run in SPAWN mode (-f), not attach: FirebaseInitProvider.onCreate()
 * runs in handleBindApplication(), BEFORE any Application.onCreate()/Activity.
 * If the process is already running when you attach, the check has already fired.
 */
Java.perform(function () {
    const UPCEANExtension2Support = Java.use('com.google.zxing.oned.UPCEANExtension2Support');

    UPCEANExtension2Support.onMessageChannelReady.overload('long', 'long').implementation = function (a, b) {
        console.log('[*] UPCEANExtension2Support.onMessageChannelReady neutralized (args=' + a + ', ' + b + ') - root/tamper check skipped');
        // no-op: the real check (hidden root detection) never runs
    };
});
```

## Reconstructed source

What the startup path looks like before and after the hook:

```java
// FirebaseInitProvider.onCreate()  — runs before Application.onCreate()
Method m = Class.forName(decrypt("…"))                     // "com.google.zxing.oned.UPCEANExtension2Support"
                .getDeclaredMethod(decrypt("…"), long.class, long.class);
m.invoke(null, seedA, seedB);                              // before: root check, may end in System.exit
                                                           // after:  empty method, returns immediately
```

## Notes

- **Signature from smali.** The method is `onMessageChannelReady(JJ)V` in smali — `J` is `long` — hence `.overload('long', 'long')` ([[From-Smali-Signature-To-Frida-Overload]]). Writing the overload explicitly also documents exactly which method is being replaced.
- **Why reflection doesn't escape the hook.** Frida's Java bridge rewrites the method's ART entry point, so `Method.invoke`, direct `invoke-static`, and JNI calls all reach the replacement. You don't have to find or hook the reflective call site.
- **Spawn is mandatory here.** The check runs from a content provider during process bind, earlier than any code an attached script could beat. This is the clearest real case for [[Spawn-Vs-Attach-Timing]].
- **No-op is safe because the method is `void`** and its legitimate behavior (a ZXing callback) isn't needed at that call site. Disabling a method that also does real work would require reimplementing the real part ([[Reimplementing-Trapped-Methods-In-JavaScript]]).
- **It was one of fifteen.** The same `(JJ)V` host pattern turned up in fifteen classes; the batch version is [[Batch-Neutralizing-Hidden-Checks-By-Signature]].

## See also

- [[Memory-Patching-And-Code-Redirection]]
- [[Changing-A-Return-Value]]
- [[Hooking-Log-And-Runtime-Exit-To-Find-The-Culprit]] — how the culprit was located
- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
