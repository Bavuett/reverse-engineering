---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "login-diagnostics.js (Frida instrumentation script, not app source)"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Hooking-A-Lazily-Loaded-Class-With-A-Retry-Loop

## Context

`Java.use("some.Class")` throws a `ClassNotFoundException` if that class hasn't been loaded by the app's class loader yet — a real problem for Kotlin sealed-class hierarchies like `PostePasskeyThrowable`'s subclasses (`PasskeyCredentialNotFound`, `PasskeyUnauthorized`, ...), which only get loaded once the passkey ceremony actually starts throwing them, not at app cold-start when the rest of `login-diagnostics.js`'s hooks are installed. Hooking these needed both an enumeration step ([[Enumerating-Loaded-Classes-By-Keyword]]) *and* patience: the hook installer had to keep retrying until the classes actually appeared.

## Original path

`` Case-Studies/poste-italiane/source/login-diagnostics.js ``

## Snippet

```javascript
const hookedPasskeyThrowables = new Set();

const hookPasskeyThrowables = () => {
    Java.enumerateLoadedClasses({
        onMatch(name) {
            if (name.indexOf("PostePasskeyThrowable$") === -1) return;
            if (hookedPasskeyThrowables.has(name)) return;
            hookedPasskeyThrowables.add(name);

            const Cls = Java.use(name);
            Cls.$init.overload("java.lang.String", "java.lang.String").implementation = function (errorCode, errorMessage) {
                console.log(`[login-diag] new ${name}(errorCode="${errorCode}", errorMessage="${errorMessage}")`);
                console.log(stack());
                return this.$init(errorCode, errorMessage);
            };
        },
        onComplete() {},
    });
};

hookPasskeyThrowables(); // catches any subclasses already loaded (unlikely this early)
for (let i = 1; i <= 10; i++) {
    setTimeout(hookPasskeyThrowables, i * 3000); // retry every 3s for 30s
}
```

### Example — knowing when the retry loop is unnecessary at all

Not every class needed this treatment, and telling the two cases apart mattered for keeping the script simple. A one-shot enumeration run right after spawn already found one `PostePasskeyThrowable` subclass loaded before any user interaction at all:

```
[+] Hooked it.posteitaliane.df_sessionmanager.passkey.model.PostePasskeyThrowable$PasskeyJWASRSA1 constructor
```

— `PasskeyJWASRSA1` (a JWA/RSA-signature-related error variant) apparently gets touched during app bootstrap, independent of any login attempt, while the others (`PasskeyCredentialNotFound`, `PasskeyUnauthorized`, ...) only load once the passkey ceremony actually runs. The retry loop is what catches that second group; a plain one-shot `Java.use` at script-load time would have hooked `PasskeyJWASRSA1` fine and then silently missed every other subclass, with no error to signal the gap — `ClassNotFoundException`s from classes that load *later* don't retroactively announce themselves.

## Notes

- `hookedPasskeyThrowables` (a `Set` of already-hooked class names) makes every retry idempotent — re-running `enumerateLoadedClasses` and re-hooking a class already hooked would otherwise silently stack duplicate `.implementation` replacements on top of each other.
- The 10-retries-over-30-seconds shape is a pragmatic choice, not a principled one: there's no Frida API to be notified the instant a specific class loads (short of hooking the class loader itself, a heavier and more invasive approach not needed here) — polling on a timer is the simple version that worked for a UI flow with a human-scale delay between app launch and a login attempt.
- This is the direct answer to a gap in [[Java-Layer-Hooking]]'s own explanation section (which covers `Java.enumerateLoadedClasses` for the "what's actually loaded right now" case) for the specific case of a class that *isn't* loaded yet but will be soon, and that you need to be hooked from the moment it does load rather than caught after the fact.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Java-Layer-Hooking]]
- [[Capturing-A-Stack-Trace-From-Inside-A-Hook]], [[App-Architecture-And-Login-Flow-Mapping]], and [[Poste-Italiane]] in [[Case-Studies]]
