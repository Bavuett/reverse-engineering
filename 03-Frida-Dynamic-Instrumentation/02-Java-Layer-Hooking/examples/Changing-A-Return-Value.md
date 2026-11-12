---
tags: [example]
level: 1
aliases: ["Frida force return true", "override return value"]
created: 2026-11-12
---

# Example: Changing-A-Return-Value

> [!info] Level 1 — basics
> One idea: a hook that returns its own value instead of the original's changes the app's decision — the basis of most "bypass" scripts.

## Goal

Force a boolean check to pass, two ways — skipping the original entirely, and calling it but overriding the result — and know which to choose. Belongs to [[Java-Layer-Hooking]].

## Target (Java, in the app)

```java
public class LicenseChecker {
    public boolean isPremium(String accountId) {
        // network call + signature verification ...
    }
    public int remainingTrialDays() { /* ... */ }
}
```

## Script

```javascript
Java.perform(() => {
    const LicenseChecker = Java.use("com.example.billing.LicenseChecker");

    // (a) Replace outright: the original never runs.
    LicenseChecker.isPremium.implementation = function (accountId) {
        console.log(`[*] isPremium(${accountId}) -> forcing true`);
        return true;
    };

    // (b) Run the original, then override: side effects still happen.
    LicenseChecker.remainingTrialDays.implementation = function () {
        const real = this.remainingTrialDays();
        console.log(`[*] remainingTrialDays: real=${real}, returning 30`);
        return 30;
    };
});
```

## Step by step

1. **Return a JS value of the Java return type.** `boolean` ← `true`/`false`, `int`/`long` ← number, `String` ← JS string, object types ← a wrapper (`SomeClass.$new(...)`) or `null`. A wrong type raises an error inside the target at call time.
2. **(a) Replace outright** when the original is harmful or slow — it may crash, hit the network, or perform the check you're bypassing. The method body never executes, so neither do its side effects.
3. **(b) Call then override** when the original has side effects the app needs (initializing fields, caching, registering listeners) and only the *result* is the problem. It also lets you log the real value, which is useful evidence.
4. **Bypassing the decision vs the check.** Forcing `isPremium` affects every caller. If several features call it but you only want to unlock one, hook the *caller* instead, or decide inside the hook based on `Thread`'s stack trace ([[Capturing-A-Stack-Trace-From-Inside-A-Hook]]).
5. **`void` methods** become no-ops by simply not calling the original and returning nothing — the most drastic override, used to disable a check entirely.

## Compared with real code

- [[Neutralizing-A-Hidden-Check-With-A-No-Op-Implementation]] — the TUA case study's real `void`-method no-op that disables a hidden root check.
- [[Stacking-Five-Independent-Pinning-Bypasses]] — real return-value and no-op overrides applied to five different pinning layers in the Poste Italiane app.

## See also

- [[Java-Layer-Hooking]]
- [[Logging-Arguments-And-Return-Values]]
- [[Anti-Detection-And-Gadget-Mode]]
- [[Memory-Patching-And-Code-Redirection]] — the native-code equivalent

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
