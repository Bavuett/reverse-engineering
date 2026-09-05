---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-04
---

# Login-AT01-And-Device-Trust-Signals

## Question / goal

With root/Frida hiding confirmed effective (see [[Splash-Screen-ANR-Under-Heavy-Instrumentation]]'s
resolution) and real account credentials entered, login still failed with a generic error. Two
questions needed answering: **what error code is the app actually acting on**, and **is Google Play
Integrity spoofing required** to get past it — the heavier fallback flagged as an open caveat in
[[root-and-frida-hiding.js]]'s header comment, requiring a Zygisk/DenyList/Shamiko/Play-Integrity-Fix
stack well beyond what Frida hooking alone provides.

## How this was found

With [[http-pinning-bypass-and-dump.js]] and [[login-diagnostics.js]] attached (after resolving a
`frida-server` hang — see the addendum in [[Frida-Server-Setup-On-The-Blackview]]) and the app
force-stopped and freshly spawned, a real login attempt with genuine credentials produced this
sequence, in order:

1. `POST oidc-proxy.mobile.poste.it/.../az-req` (`grant_type=password&acr_values=.../L1`) — an OIDC
   authorization request carrying the JWE-encrypted credentials.
2. `POST idp-poste.poste.it/.../openid-az` → `{"error":"login_required"}`.
3. `[login-diag] LoginViewModel.checkErrorCode(code="AT01", msg="login_required", ...)` →
   `showLoginFailedError("AT01", "login_required")` fired immediately after, confirming this generic
   OIDC error is exactly what the app surfaces to the user as a login failure.
4. Immediately after, `POST idp-poste.poste.it/.../getPassKeyChallenge` (a **second**, independent
   passkey-challenge request, distinct from the app-cold-start one already documented in
   [[App-Architecture-And-Login-Flow-Mapping]]) — its response, decoded, carried `"allowCredentials":
   []` again, and `"user": ""` in the nested inner challenge token.

Two things were checked directly rather than assumed, before concluding anything about Play
Integrity:

- **Whether the RSA fraud/device-fingerprint SDK sees this device as compromised.** Poste's login
  requests carry an `x-rsa` header — a plain base64 (not encrypted) JSON blob from a bundled RSA
  Adaptive Authentication–style risk SDK (`SDK_VERSION: 4.2.0`, `RSA_ApplicationKey`), independent of
  Play Integrity. Decoded, it reported `"Compromised": 0, "Emulator": 0` — i.e. the SDK's own,
  non-Google device-trust signal considers this rooted/Frida'd/Shamiko'd device clean.
- **Whether the app even calls the Play Integrity API at all.** Using the same live
  class-enumeration technique as [[App-Architecture-And-Login-Flow-Mapping]] (`keyword: "integrity"`,
  `"attestation"`, `"safetynet"`), every match returned was a stock `android.content.integrity.*` /
  `android.security.*` class — the OS's own APK-signature/install-integrity framework, present in
  every app — not a single `com.google.android.play.core.integrity.*` or `com.google.android.gms.*`
  class. Play Integrity's classes had not been loaded by the app at any point through this entire
  login attempt.

The actual resolution came from something outside any of this: **force-stopping and relaunching the
app fresh made login succeed**, landing on
`it.posteitaliane.df_onboarding.creaposteid.OnboardingCreaPosteIdActivity` (confirmed via `adb
logcat -d` showing that Activity's window taking focus) rather than looping back to login as it first
appeared — the "torna indietro" the user reported after accepting ToS/privacy was this onboarding
Activity opening, not a failure.

## Relevant source

- [[login-diagnostics.js]]
- [[http-pinning-bypass-and-dump.js]]
- [[root-and-frida-hiding.js]]

## Excerpt

Decoded `getPassKeyChallenge` response body (RS256-signed JWS, not encrypted — readable directly):

```json
{
  "code": 200,
  "data": {
    "userVerification": "required",
    "rpId": "securelogin.poste.it",
    "timeout": 60000,
    "allowCredentials": [],
    "tid": "<redacted>"
  }
}
```

Nested inner challenge token (base64 inside `data.challenge` above):

```json
{
  "td": "{\"ctype\":\"oidc-v2-access-passkey-loa3-app\"}",
  "type": "auth",
  "user": "",
  "rp": "securelogin.poste.it"
}
```

Decoded `x-rsa` device-fingerprint header (plain base64 JSON, sent on every `idp-poste.poste.it`
request):

```json
{
  "DeviceModel": "BV5200 Pro",
  "DeviceSystemName": "Android",
  "DeviceSystemVersion": "31",
  "RSA_ApplicationKey": "<redacted>",
  "SDK_VERSION": "4.2.0",
  "Compromised": 0,
  "Emulator": 0,
  "appVersion": "6.0.38",
  "appName": "app-up"
}
```

`HardwareID`, `AdvertiserId`, and the real `RSA_ApplicationKey`/`tid` values are redacted here — see
[[Embedded-OAuth2-Client-Credentials]] for the reasoning on why raw device/session identifiers from
this real account stay out of the tracked vault; a full unredacted capture of tonight's session
(login attempt through successful authentication) is saved to `local/` (gitignored, never committed)
as `frida-session-2026-09-04-login-success.log`.

## Analysis

`AT01`/`login_required` turned out to be a red herring as far as root/Frida detection goes: it's the
standard OIDC response for "no valid session, interactive login required" — exactly what a
never-before-seen device requesting silent/background auth (`az-req` → `openid-az`) should get back,
regardless of whether the credentials that follow are correct. The app treats it as a user-facing
"login failed" error anyway, which is what actually produced the `credenziali non riconosciute`-style
message the user first reported — a UX choice (or bug) in how `LoginViewModel` surfaces this
particular OIDC error code, unrelated to device trust.

Both device-trust signals available to inspect — the app's own RSA fraud SDK fingerprint, and
whether the app invokes Play Integrity at all — came back clean or absent. This makes Play Integrity
spoofing very unlikely to be the fix for anything seen so far: there's no evidence the app calls it in
this flow, and the cheaper, already-installed Java-layer hiding plus Shamiko is already enough to make
every locally-observable signal report "not compromised." The caveat in
[[root-and-frida-hiding.js]]'s header comment (Play Integrity as a hardware-backed signal Frida can't
spoof) remains true in general, but isn't the blocker in this specific case — the actual blocker was
simply that this device had never completed Poste's identity-enrollment flow
(`OnboardingCreaPosteIdActivity`) at all, which explains *both* the empty `allowCredentials` (no
passkey enrolled) *and* the generic `login_required` (no established session) with one single root
cause, more parsimoniously than any anti-tampering theory.

## Generalizing the pattern

When a banking/PA app's login fails on a rooted test device and the instinct is to blame
root/Frida/Play-Integrity detection, check the *cheap* signals first, before reaching for a much more
expensive fix (Play Integrity Fix + a valid keybox):

1. Does the app expose its own device-fingerprint payload in a request header or body (many
   fraud-SDK integrations do, in plaintext or simple base64, not full JWE)? If so, decode it — it
   often states outright whether the SDK considers the device compromised.
2. Enumerate loaded classes for `integrity`/`attestation`/`safetynet` — if the app hasn't loaded any
   `com.google.android.play.core.integrity.*` or `com.google.android.gms.*integrity*` classes by the
   point the failure happens, it isn't using Play Integrity for that specific flow yet, and spoofing
   it wouldn't do anything.
3. Only after both come back clean/absent and the failure still reproduces is it worth suspecting a
   *server-side* verdict from a signal Frida genuinely cannot see or fake (Play Integrity's actual
   token verification, which happens between Google's servers and the app's backend, never visible
   client-side).

## Related concepts

- [[Anti-Detection-And-Gadget-Mode]] — the technique catalogue this note's Play Integrity caveat
  extends.
- [[App-Architecture-And-Login-Flow-Mapping]] — the live-enumeration methodology reused here for the
  Play Integrity check.

## Open questions / next steps

- [x] Confirmed real credentials were used (not a typo) before pursuing device-trust theories.
- [x] Checked whether Play Integrity is invoked at all — it isn't, at least not through this login
      path.
- [x] Login now succeeds after a fresh app relaunch; the ToS/privacy screen was followed by legitimate
      onboarding (`OnboardingCreaPosteIdActivity`), not a failure loop.
- [ ] Capture and review the authenticated session's traffic (now unblocked) — see
      [[Poste-Italiane]]'s Open questions.
- [ ] If `AT01`/`login_required` reappears on a *subsequent* login attempt from an account that has
      already completed onboarding, that would isolate it as a real, reproducible UX quirk in how
      `LoginViewModel` surfaces this OIDC code, worth a closer look independent of this device's
      enrollment status.

## See also

- [[RSA-Adaptive-Auth-Onboarding-Verdict]] — traces the `x-rsa` SDK's actual ALLOW/CHALLENGE/DENY
  verdict logic gating onboarding, one layer deeper than the `Compromised`/`Emulator` fields noted
  here
- [[Case-Studies]]
