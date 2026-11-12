---
tags: [snippet]
level: 3
project: "TUA (net.pluservice.tua)"
source: "net.pluservice.tua — Cordova/Android hybrid app, decompiled to smali from the APK"
version: "11.26.4"
source_path: "Frida script combined.js, sections 0 and 1 (not app source) — Runtime.exit/halt + Process.killProcess suppression, and a list of fifteen (JJ)V host methods"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. This is a small dynamic-analysis fragment kept to illustrate one anti-detection pattern. Check the app's ToS before any redistribution."
---

# Batch-Neutralizing-Hidden-Checks-By-Signature

> [!info] Level 3 — real code
> Two real layers of defense against a hidden-check scheme: block the *termination mechanism* every check ends in, then disable every *host method* found by its shared signature — fifteen of them, across unrelated classes.

## Context

After neutralizing one hidden root check ([[Neutralizing-A-Hidden-Check-With-A-No-Op-Implementation]]), the TUA investigation found the pattern repeated: `FirebaseInitProvider` reflectively invokes several `static void x(long, long)` methods hidden inside legitimate classes of ZXing, Gson, Firebase, Google Play services and obfuscated `o.*` classes. Instead of analysing each, the combined script (1) makes the checks' final step harmless and (2) disables every method with that shape. Part of [[Tua-Case-Study]]; how the list was built is in [[Anti-Tampering-Pattern-Workflow]].

## Original path

`combined.js`, sections 0 and 1, in the TUA case-study sources. Comments translated.

## Snippet

```javascript
// --- 0) Block the termination mechanism itself: any hidden check (root,
//     debuggable, who knows how many others) ends in System.exit(status).
//     Neutralized here, the check may still log its message but the process
//     stays alive, without chasing every reflective call one by one. ---
const Runtime = Java.use('java.lang.Runtime');
Runtime.exit.implementation = function (status) {
    console.log('[*] Runtime.exit(' + status + ') suppressed');
};
Runtime.halt.implementation = function (status) {
    console.log('[*] Runtime.halt(' + status + ') suppressed');
};
const Process = Java.use('android.os.Process');
Process.killProcess.implementation = function (pid) {
    console.log('[*] Process.killProcess(' + pid + ') suppressed');
};

// --- 1) Neutralize ALL (JJ)V hiding places found across the smali tree
//     (same pattern FirebaseInitProvider uses everywhere to invoke hidden
//     checks by reflection, inside totally unrelated classes) ---
const HIDDEN_CHECKS = [
    ['android.support.v4.media.MediaBrowserCompatApi26', 'extraCallbackWithResult'],
    ['net.pluservice.plusnetworking.R$anim', 'onNavigationEvent'],
    ['com.google.zxing.RGBLuminanceSource', 'extraCallbackWithResult'],
    ['com.google.zxing.pdf417.decoder.ec.ModulusPoly', 'ICustomTabsCallback'],
    ['com.google.zxing.oned.UPCEANExtension2Support', 'onMessageChannelReady'],
    ['com.google.firebase.R$drawable', 'extraCallbackWithResult'],
    ['com.google.gson.internal.UnsafeAllocator$2', 'extraCallbackWithResult'],
    ['com.google.zxing.client.android.encode.VCardContactEncoder', 'ICustomTabsCallback'],
    ['com.google.android.gms.measurement.internal.zzep', 'extraCallback'],
    ['com.google.android.gms.dynamite.DynamiteModule$LoadingException', 'extraCallbackWithResult'],
    ['com.google.android.gms.common.api.internal.ApiKey', 'onNavigationEvent'],
    ['com.google.android.gms.common.api.internal.zaf', 'ICustomTabsCallback'],
    ['o.setButtonDrawable', 'ICustomTabsCallback'],
    ['o.setImeOptions', 'onNavigationEvent'],
    ['o.setOnSearchClickListener', 'onMessageChannelReady'],
];

let installed = 0;
HIDDEN_CHECKS.forEach(function (entry) {
    const className = entry[0], methodName = entry[1];
    try {
        Java.use(className)[methodName].overload('long', 'long').implementation = function (a, b) {
            console.log('[*] ' + className + '.' + methodName + ' neutralized (args=' + a + ', ' + b + ')');
        };
        installed++;
    } catch (e) {
        console.log('[!] cannot hook ' + className + '.' + methodName + ': ' + e);
    }
});
console.log('[*] ' + installed + '/' + HIDDEN_CHECKS.length + ' (JJ)V hiding places neutralized');
```

## Reconstructed source

The shape every host shares, as found in smali and as the app's loader uses it:

```java
// in an unrelated library class, e.g. com.google.gson.internal.UnsafeAllocator$2
static void extraCallbackWithResult(long a, long b) {   // smali: (JJ)V
    /* injected check: reflection + runtime-decrypted strings; on failure -> System.exit(…) */
}

// FirebaseInitProvider (runs before Application.onCreate)
for (each hidden host) hostMethod.invoke(null, seedA, seedB);
```

## Notes

- **Defense in depth, in the right order.** Section 0 is the safety net: even a check missing from the list can't kill the process through `Runtime.exit`/`halt`/`Process.killProcess`. Section 1 stops the checks from running at all — needed because a check can also *misbehave* rather than exit (set flags, corrupt state, throw).
- **Signature as a search key.** Method names are borrowed from legitimate APIs (`onNavigationEvent`, `extraCallbackWithResult` — names from Custom Tabs callbacks), so names don't distinguish the hosts; the unusual descriptor `(JJ)V` on a static method in the wrong class does. The list came from grepping the smali tree for that descriptor and confirming each hit ([[From-Smali-Signature-To-Frida-Overload]]).
- **Each hook in its own `try`**, with a count printed at the end: a missing or renamed class (another app version) costs one line of log, not the whole script, and `installed/15` tells you immediately whether the list still matches.
- **Spawn only.** As with the single-method version, everything here must be in place before `FirebaseInitProvider` runs.
- **Exit suppression has side effects.** Legitimate code paths that call `System.exit` (rare on Android) are also blocked; and a check that expects `exit` to never return may continue into undefined state. That's why section 0 is a net, not the fix.
- **Compare with Poste Italiane**, whose detection was signal-based rather than hidden-method-based and needed hooks on the signals themselves: [[Hiding-Root-Artifacts-With-One-Compiled-Regex]], [[Blocking-The-Frida-Control-Port-Scan]].

## See also

- [[Anti-Detection-And-Gadget-Mode]]
- [[Hooking-Log-And-Runtime-Exit-To-Find-The-Culprit]]
- [[Reflection-and-Runtime-Internals]] in [[Dalvik-Bytecode]]
- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
