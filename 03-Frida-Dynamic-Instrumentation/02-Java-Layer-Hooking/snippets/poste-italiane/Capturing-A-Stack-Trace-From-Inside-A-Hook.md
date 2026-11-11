---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "login-diagnostics.js (Frida instrumentation script, not app source)"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Capturing-A-Stack-Trace-From-Inside-A-Hook

## Context

Once TLS-layer capture showed only JWE ciphertext for the login flow (see [[Decrypting-JWE-Request-Response-Bodies]]), the question shifted from "what's in the request" to "which Java method decided to show this error, and who called it." A hooked method knows its own arguments, but not, by default, its Java-level caller chain — `Log.getStackTraceString(new Exception())` is the standard way to get that from inside a `.implementation` replacement without actually throwing anything.

## Original path

`` Case-Studies/poste-italiane/source/login-diagnostics.js ``

## Snippet

```javascript
const Log = Java.use("android.util.Log");
const Exception = Java.use("java.lang.Exception");
const stack = () => Log.getStackTraceString(Exception.$new());

LoginViewModel.checkErrorCode.implementation = function (code, msg, tag, subject) {
    console.log(`[login-diag] LoginViewModel.checkErrorCode(code="${code}", msg="${msg}", tag="${tag}", subject=${subject})`);
    console.log(stack());
    return this.checkErrorCode(code, msg, tag, subject);
};
```

### Example 1 — tracing an OIDC error code back to its Kotlin coroutine caller

Real output this produced, tracing the `AT01`/`login_required` error (see [[Login-AT01-And-Device-Trust-Signals]]) all the way back through the Kotlin coroutine machinery that called it:

```
[login-diag] LoginViewModel.checkErrorCode(code="AT01", msg="login_required", tag="login", subject=POSTEIT)
java.lang.Exception
	at it.posteitaliane.df_sessionmanager.LoginViewModel.checkErrorCode(Native Method)
	at it.posteitaliane.df_sessionmanager.LoginViewModel.handleNetworkResponse(SourceFile:153)
	at it.posteitaliane.df_sessionmanager.LoginViewModel$onAccediClicked$1$1.emit(SourceFile:2)
	at it.posteitaliane.mvvmtoolkit.network.BaseRepository$makeCall$5.invokeSuspend(SourceFile:290)
	...
```

### Example 2 — the same hook installed on the next method down the call chain, confirming the link

`checkErrorCode` calls `showLoginFailedError` internally (visible directly in the trace this second hook produced) — hooking *both* and comparing their traces confirmed the two methods really were on the same call path, rather than two independent things that happened to fire close together in time:

```
[login-diag] LoginViewModel.showLoginFailedError("AT01", "login_required")
java.lang.Exception
	at it.posteitaliane.df_sessionmanager.LoginViewModel.showLoginFailedError(Native Method)
	at it.posteitaliane.df_sessionmanager.LoginViewModel.checkErrorCode(SourceFile:465)
	at it.posteitaliane.df_sessionmanager.LoginViewModel.checkErrorCode(Native Method)
	at it.posteitaliane.df_sessionmanager.LoginViewModel.checkErrorCode$default(SourceFile:19)
	at it.posteitaliane.df_sessionmanager.LoginViewModel.handleNetworkResponse(SourceFile:153)
	...
```

Note the extra `checkErrorCode$default(SourceFile:19)` frame — Kotlin's compiler-generated overload for a method with default parameter values, one more layer of the synthetic-method noise [[Dumping-Real-Method-Signatures-Before-Hooking]] filters out when *listing* a class's methods, but which still shows up honestly in a live call stack since it's a real frame that really executed.

## Notes

- The `Exception` object here is never thrown — `$new()` constructs it (which populates its stack trace as a side effect of construction, standard JVM behavior) purely to hand it to `Log.getStackTraceString`, which formats it as a string. This is safe to call from any hook without disturbing control flow.
- Even with Kotlin's `SourceFile:N` line-number-only frames (no real source available, since this is live against a compiled release build, not a decompiled tree), the *class and method names* in the trace were enough to identify `onAccediClicked` as the login button's handler and `BaseRepository.makeCall` as the shared network-call wrapper every repository method funnels through — real architectural facts recovered with zero static analysis.
- Same helper (`stack()`) was reused verbatim to log every `PostePasskeyThrowable` subclass constructor's caller — see [[Hooking-A-Lazily-Loaded-Class-With-A-Retry-Loop]] for why those needed a different enumeration strategy than the `LoginViewModel` methods above.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Java-Layer-Hooking]]
- [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] in [[PressReader]]
- [[Login-AT01-And-Device-Trust-Signals]], [[App-Architecture-And-Login-Flow-Mapping]], and [[Poste-Italiane]] in [[Case-Studies]]
