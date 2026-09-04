---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "root-and-frida-hiding.js (Frida instrumentation script, not app source)"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Calling-Through-An-Overload-Without-Recursing

## Context

A real, self-inflicted bug that caused a genuine ANR (Application Not Responding), initially
misdiagnosed as anti-tampering overhead before the actual cause was found: two hooks in
`root-and-frida-hiding.js` called back into "the original implementation" via `ov.apply(this, args)`,
where `ov` was the *same overload object whose `.implementation` had just been replaced*. That doesn't
call the original — it calls the hook again, recursively, forever, freezing whatever thread invoked
`getInstalledPackages`/`getInstalledApplications` or `Runtime.exec`. [[Java-Layer-Hooking]]'s own
worked example uses the correct pattern (`this.login(...)`) without dwelling on why the alternative is
wrong; this is a concrete case where getting it wrong had a real, hard-to-diagnose cost.

## Original path

`` Case-Studies/poste-italiane/source/root-and-frida-hiding.js ``

## Snippet

```javascript
// WRONG — ov is the already-replaced overload; calling it re-enters this same
// implementation, recursing until the stack (or the app) dies.
ApplicationPackageManager[name].overloads.forEach((ov) => {
    ov.implementation = function (...args) {
        const result = ov.apply(this, args); // <- infinite recursion
        // ...
    };
});

// RIGHT — call through the instance. Frida routes this.methodName(...) to the
// ORIGINAL implementation from inside a replacement, specifically so this pattern
// works regardless of which overload object triggered the call.
ApplicationPackageManager[name].overloads.forEach((ov) => {
    ov.implementation = function (...args) {
        const result = this[name](...args); // dynamic dispatch to the real method
        // ...
    };
});
```

The same fix applied to `Runtime.exec`'s hook: `this.exec(cmdArg, ...rest)` instead of
`ov.apply(this, [cmdArg, ...rest])`.

### Example 2 — the same pattern used correctly, on a single (non-looped) overload

Where only one overload is being hooked directly by name (not via a `.forEach` over `.overloads`), the
correct form is even more direct — no computed `this[name](...)` needed, just the literal method name:

```javascript
Socket.connect.overload("java.net.SocketAddress", "int").implementation = function (addr, timeout) {
    if (isSuspicious(addr)) throw ConnectException.$new("Connection refused");
    return this.connect(addr, timeout); // literal name — same instance method, unambiguous
};
```

### Example 3 — deliberately *not* calling through at all, and why that's a different, also-correct pattern

Several other hooks in this same script never call the original implementation, on purpose — a full
replacement rather than a conditional pass-through:

```javascript
TrustManagerImpl.verifyChain.implementation = function (untrustedChain, trustAnchorChain, host) {
    return untrustedChain; // the ENTIRE point is to never run the real validation logic
};
```

Worth stating explicitly since it looks superficially similar to the recursion bug: the difference
isn't whether `this.originalMethod(...)` appears in the function body, it's whether the intent is
"sometimes defer to the real behavior" (needs the correct call-through) versus "always replace the
behavior" (calling through at all — correctly or not — would defeat the hook's whole purpose). The
recursion bug specifically only bites the first category.

## Notes

- The bug hid for a while because its symptom — an ANR — looked identical to a completely different,
  unrelated cause (see [[Splash-Screen-ANR-Under-Heavy-Instrumentation]]'s three other dead-end
  overhead theories, tried first). It was only found by re-reading the hook code itself after ruling
  out everything else, not by any dynamic diagnostic — a reminder that "call the original" bugs are a
  static-review class of bug, not something a stack trace will point at (the hang has no distinguishing
  stack; it's just the same frame recursing).
- `this[name](...)` (computed member access, `name` being the method name as a string) works exactly
  the same as `this.methodName(...)` — used here because the hook is installed generically inside a
  `.forEach` over both `getInstalledPackages` and `getInstalledApplications` at once, so the literal
  method name isn't known until the loop iteration.
- Worth checking for specifically whenever a hook is written by adapting boilerplate that captures the
  overload object into a variable (`const ov = SomeClass.someMethod.overload(...)`) and then reuses
  that same variable both to *set* `.implementation` and to try to *call through* — the two uses look
  parallel but aren't.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Layer-Hooking]]
- [[Splash-Screen-ANR-Under-Heavy-Instrumentation]] and [[Poste-Italiane]] in [[Case-Studies]]
