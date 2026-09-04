---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-03
---

# App-Architecture-And-Login-Flow-Mapping

## Question / goal

With TLS interception working (see [[Frida-Server-Setup-On-The-Blackview]]) but the login flow
still failing, and its request/response bodies turning out to be application-layer encrypted (JWE)
on top of TLS — so `http-pinning-bypass-and-dump.js` alone shows opaque ciphertext, not the actual
error — the next question was: **which Java class and method actually decides what error the user
sees, and why?** This note documents the class/method-enumeration workflow used to answer that
without any static decompilation, purely by asking the running process.

## How this was found

The general technique — pointed at a specific problem each time — was always the same three-step
loop, run live against the already-instrumented process rather than a static APK:

1. **Enumerate loaded classes matching a keyword**, to go from "I don't know the class name" to
   "here's the exact fully-qualified name":

   ```js
   Java.perform(function () {
       Java.enumerateLoadedClasses({
           onMatch: function (name) {
               if (name.toLowerCase().indexOf("keyword") !== -1) console.log("[class] " + name);
           },
           onComplete: function () { console.log("[done]"); }
       });
   });
   ```

   Run as a one-shot `frida -U -p <pid> -e '...' -q -t 20` against the already-running,
   already-hooked process — no need to touch the main instrumentation session for this.

2. **Dump a specific class's declared constructors/methods**, once its name is known, to get real
   signatures instead of guessing:

   ```js
   var C = Java.use("fully.qualified.ClassName");
   C.class.getDeclaredConstructors().forEach(function (c) { console.log(c.toString()); });
   C.class.getDeclaredMethods().forEach(function (m) { console.log(m.toString()); });
   ```

   Kotlin-compiled classes add a lot of noise here — synthetic lambda/continuation classes named
   `Outer$methodName$N` for every `suspend`/inline lambda. Filtering `.toString()` for lines
   *without* a `$` in the method name (`s.indexOf("$") === -1`) cuts straight to the class's own
   real, directly-declared methods.

3. **Hook whatever the previous step's signature says, print a stack trace at call time**:

   ```js
   const Log = Java.use("android.util.Log");
   const Exception = Java.use("java.lang.Exception");
   const stack = () => Log.getStackTraceString(Exception.$new());
   ```

   `Log.getStackTraceString(new Exception())` is the standard way to capture "what called me, all
   the way up" from inside a hook without actually throwing — the `Exception` object is only ever
   used for its stack, never thrown.

This loop found, in order: [[Embedded-OAuth2-Client-Credentials]]'s `SSLInterceptor` (step 1 only,
since its single `intercept(Chain)` method needed no further narrowing), then — for the
`password non corretta` / `credenziali non riconosciute` question — the full method surface of
`it.posteitaliane.df_sessionmanager.LoginViewModel` (step 2), which is where
[[login-diagnostics.js]] borrows its hook list from.

## Relevant source

- [[login-diagnostics.js]]
- [[root-and-frida-hiding.js]]
- [[http-pinning-bypass-and-dump.js]]

## Excerpt

The package map this enumeration revealed (all under `it.posteitaliane.*` unless noted), useful as
a standing reference for any further work on this app:

```
it.posteitaliane.df_sessionmanager
├── LoginViewModel                          — login UI state, error surfacing (showLoginFailedError,
│                                              checkErrorCode, showBlockedAccessPopup,
│                                              postAntiFraudLockedEvent, postPosteIdLockedEvent)
├── SessionManagerRepository                — network calls behind login (loginPasskey, loginCustom,
│                                              challengePosteId, getJwtToken, ssoOnBrowser)
├── ISessionManagerRepository               — interface for the above
├── LoginFragment                           — the actual login screen (Fragment, not Compose here)
├── init.LibraryHelper                      — app bootstrap: initXKey, appCheck, checkConfiguration
│                                              (the class behind the splash-screen "SSL1"/AT01
│                                              telemetry from Embedded-OAuth2-Client-Credentials)
├── passkey.domain.PassKeyHelper            — FIDO2 orchestration: authWitchCredentials [sic],
│                                              getAuthChallenge, getRegisterChallenge, findCredentials
├── passkey.CreatePassKeyFragment/ViewModel — passkey enrollment UI
├── passkey.model.PostePasskeyThrowable     — sealed error hierarchy: PasskeyCredentialNotFound,
│                                              PasskeyUnauthorized, PasskeyServiceError,
│                                              PasskeyGeneric, PasskeyDeviceToOld,
│                                              PasskeyRequestNotValid, PasskeyCredentialAlreadyExist,
│                                              PasskeyJWASRSA1, Unknown — each (errorCode, errorMessage)
├── datasource.login.repository.PassKeyRepository — HTTP-facing: authenticationChallengePassKey,
│                                              completeAuthenticationPassKey, challengeRegisterPassKey,
│                                              completeRegistrationPasskey, getListCredentials,
│                                              deleteCredential
├── datasource.login.services.PassKeyWebAuthApiService — Retrofit/OkHttp service interface
├── datasource.login.model.passkey.*        — request/response DTOs (WebAuthnRequest,
│                                              AuthChallengeRequest/Response, CreatePasskeyRequestData)
└── analytics.constants.AnalyticsPasskey    — telemetry event name constants (Creata, Utilizzata,
                                               KoAccessoNonRiuscito, NonValida, ErroreGenerico, ...)

it.posteitaliane.df_utils.network.SSLInterceptor  — custom OkHttp Interceptor, manual trust check
                                                      (see Embedded-OAuth2-Client-Credentials)

com.google.android.gms.fido.fido2.*         — Google Play Services FIDO2 API (not app code): the
                                               actual platform-level passkey ceremony this app drives
```

## Analysis

Two structural facts fell out of this mapping that reframe the earlier "does it fail because of
root detection?" question:

1. **The login flow is FIDO2/WebAuthn (passkey-based), not a plain password form.** Every relevant
   class (`PassKeyRepository`, `PassKeyHelper`, `PostePasskeyThrowable`, the
   `com.google.android.gms.fido.fido2.api.common.*` DTOs) exists specifically for that. A "wrong
   password" report from the user is therefore more precisely either (a) a first-factor PIN/password
   step distinct from the passkey ceremony, or (b) exactly what `PasskeyCredentialNotFound` would
   produce if this Blackview has no passkey enrolled for this Poste account — which, for a device
   that has never logged into this account before, is the expected, correct outcome, not a bug in
   the instrumentation. [[login-diagnostics.js]]'s hooks on the `PostePasskeyThrowable` subclasses
   exist specifically to tell these apart by printing which concrete error class fires.
2. **`init.LibraryHelper` is the class behind `checkConfiguration`**, matching the
   `pt_class_name: LibraryHelper_splash` / `pt_act_name: checkConfiguration` telemetry seen during
   the splash-screen investigation in [[Embedded-OAuth2-Client-Credentials]] — confirming that
   thread was about app bootstrap/config, a separate concern from the passkey login errors this
   note is about.

## Generalizing the pattern

The three-step loop above (enumerate by keyword → dump real signatures, filtering Kotlin synthetic
`$N` classes → hook with a stack-trace logger) generalizes to *any* "why did this app do X" question
on a Kotlin-heavy target, without touching static analysis at all: pick the keyword from whatever
error string/telemetry tag is visible (as `SSLInterceptor` came from the `pt_class_name` telemetry
field, and `LoginViewModel`/`PassKeyRepository` came from the enumeration list itself), then narrow
down from "which class" to "which exact overload" to "who calls it and with what."

## Related concepts

- [[Java-Layer-Hooking]] — the hooking primitives (`Java.use`, `.implementation =`, overload
  resolution) all three steps above are built from.
- [[Network-Interception]] — why TLS-layer capture alone was insufficient here (app-layer JWE on
  top of already-decrypted TLS).

## Open questions / next steps

- [ ] Confirm via [[login-diagnostics.js]]'s hooks which concrete `PostePasskeyThrowable` subclass
      (or `LoginViewModel` error method) fires on the next login attempt.
- [ ] If it's `PasskeyCredentialNotFound`, the fix isn't more Frida instrumentation — it's enrolling
      a passkey for this account first (via `CreatePassKeyFragment`'s flow), or checking whether the
      account has a non-passkey (password/PosteID PIN) login path at all.

## See also

- [[Case-Studies]]
