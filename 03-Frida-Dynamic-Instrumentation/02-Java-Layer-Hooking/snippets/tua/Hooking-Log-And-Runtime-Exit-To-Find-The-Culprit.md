---
tags: [snippet]
project: "TUA (net.pluservice.tua)"
source: "net.pluservice.tua — Cordova/Android hybrid app, decompiled to smali from the APK"
version: "11.26.4"
source_path: "Frida triage script (not app source) — hooks android.util.Log + java.lang.Runtime.exit to attribute the anti-tamper crash to a Java stack"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. This is a small dynamic-triage fragment kept to illustrate one hooking pattern. Check the app's ToS before any redistribution."
---

# Hooking-Log-And-Runtime-Exit-To-Find-The-Culprit

## Context

TUA's anti-tampering layer crashes the app on a rooted/instrumented device without any obvious message — the culprit is a reflection-hidden check that ultimately calls `Runtime.exit` (or throws), disguised as unrelated Android API calls. Blind static grepping for `"su"`/`"root"` found nothing useful (the strings are encrypted). The move that actually located it, documented in [[Anti-Tampering-Pattern-Workflow]], was to hook the *exit path itself* and print the Java stack trace at the moment it fired — letting the app tell you where its own check lives. This is the [[Java-Layer-Hooking]] technique applied as triage rather than as a bypass.

## Original path

`` Frida triage script attached to net.pluservice.tua — not part of the decompiled smali tree ``

## Snippet

```javascript
Java.perform(() => {
    const Log = Java.use("android.util.Log");
    const Exception = Java.use("java.lang.Exception");

    function stack() { return Log.getStackTraceString(Exception.$new()); }

    // 1. Whoever kills the process: print who called it, then swallow the call.
    const Runtime = Java.use("java.lang.Runtime");
    Runtime.exit.implementation = function (code) {
        console.log(`[!] Runtime.exit(${code}) called from:\n` + stack());
        // (during triage, comment the next line back in to let it die and confirm this is THE path)
        // return this.exit(code);
    };
    const System = Java.use("java.lang.System");
    System.exit.implementation = function (code) {
        console.log(`[!] System.exit(${code}) from:\n` + stack());
    };

    // 2. Many hardened apps log a coded reason right before bailing — capture it.
    Log.e.overload("java.lang.String", "java.lang.String").implementation = function (tag, msg) {
        console.log(`[Log.e] ${tag}: ${msg}`);
        return this.e(tag, msg);
    };
});
```

## Notes

- The key idea is **attribution, not bypass**: you're not yet trying to defeat the check, only to make the app reveal the fully-qualified class+method that terminates it. `Log.getStackTraceString(new Exception())` (see [[Hooking-A-Constructor-And-Casting-Arguments]] for the `$new` mechanics) captures the live call stack without throwing.
- The stack that came back pointed into a method whose name looked like a normal Android lifecycle/utility call — the **name-reuse camouflage** [[Anti-Tampering-Pattern-Workflow]] describes, where the check is disguised as something innocuous. That stack frame was the entry point for all the static work that followed.
- Swallowing `Runtime.exit`/`System.exit` (returning without calling through) is a blunt first bypass that often keeps the app alive long enough to see the *next* check fire — TUA had more than one layer, including checks inside an in-memory-loaded dex (see [[In-Memory-Dex-Loading]]) that this Java-layer hook alone never reaches.
- This is the concrete form of the "hooking `android.util.Log`/`Runtime.exit` and reading a Java stack trace from a hook" note in [[Tua-Case-Study]]'s background list.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Layer-Hooking]]
- [[Anti-Detection-And-Gadget-Mode]]
- [[Tua-Case-Study]] and [[Anti-Tampering-Pattern-Workflow]] in [[Case-Studies]]
