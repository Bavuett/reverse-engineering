---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-05
---

# RSA-Adaptive-Auth-Onboarding-Verdict

## Question / goal

Hypothesis raised after [[XKey-Root-Detection-Check]]: does the `rooted` value that
`org.jod.mobile.android.xkey`'s `XKeyDeviceData` computes get used by the app when it registers
the device and assigns it a trust score? Verify against the actual decompiled source rather than
assume — [[XKey-Root-Detection-Check]] already found no client-side reader of that specific flag,
but that was checked only within the `xkey` package.

## How this was found

Widened the search past `org.jod.mobile.android.xkey` this time: grepped the whole decompiled tree
for `trust`/`score`/`risk` case-insensitively. Every hit inside `xkey` turned out to be
`javax.net.ssl.TrustManager`/`X509TrustManager` (TLS setup, unrelated). No numeric "score"
identifier exists anywhere in the app.

That looked like a dead end until broadening to `RSA_ApplicationKey`/`Compromised` — the fields
already known from the `x-rsa` header in [[Login-AT01-And-Device-Trust-Signals]] — which pointed at
`com.rsa.mobilesdk` and Poste's own wrapper, `it.posteitaliane.df_utils.rsa.RsaHelper`. Reading that
class's method list was the actual breakthrough: `handleOnboardingRSAControls` and
`handleSuspendOnboardingRSAControls` are named almost exactly like what the hypothesis described,
and a private `checkOnboardingRSADeny(resultCode, resultMessage)` helper contains real branching
logic (not just logging) — worth reading in full rather than skimming past it as another SDK-glue
method.

Two things confirmed this is real gating and not dead code:

1. `UtilsConstants$RsaState` — a proper 3-value enum (`RSA_ALLOW` / `RSA_CHALLENGE` / `RSA_DENY`),
   each carrying separate `onboarding`/`payments` string constants. This is the standard verdict
   vocabulary of RSA's actual Adaptive Authentication product (Allow/Challenge/Deny is RSA's real
   terminology, not something invented for this app), which was the confirming detail — an enum
   with exactly these three names, from a class also holding fields literally named `RSA_ApplicationKey`
   elsewhere, is not a coincidence.
2. Grepped for the two methods' actual callers instead of assuming they're invoked: `yf0/m.smali`
   calls `handleOnboardingRSAControls`, `yq/o.smali` calls `handleSuspendOnboardingRSAControls` —
   both outside `df_utils`, i.e. genuinely wired into some other flow, not unused library surface.

## Relevant source

(No files imported into `source/` for this note — analysis is entirely of the extracted APK's
decompiled smali, referenced by class name below.)

## Excerpt

`it.posteitaliane.df_utils.rsa.RsaHelper.checkOnboardingRSADeny` (decompiled logic):

```kotlin
private fun checkOnboardingRSADeny(resultCode: String, resultMessage: String) {
    if (resultCode == "4-00053" || resultMessage == UtilsConstants.RsaState.RSA_DENY.onboarding) {
        throw Exception(resultMessage)
    }
}
```

`UtilsConstants$RsaState` enum values (`onboarding` / `payments` string pairs):

| Enum constant | `onboarding` | `payments` |
|---|---|---|
| `RSA_DENY` | `"DENY"` | `"RSA_DENY"` |
| `RSA_ALLOW` | `"ALLOW"` | `"RSA_ALLOW"` |
| `RSA_CHALLENGE` | `"CHALLENGE"` | `"RSA_CHALLENGE"` |

Callers (both outside the `df_utils` module itself, confirming this is live-wired):

```
yf0/m.smali   -> RsaHelper.handleOnboardingRSAControls(...)
yq/o.smali    -> RsaHelper.handleSuspendOnboardingRSAControls(...)
```

## Analysis

There is a real device-trust verdict gating onboarding — the hypothesis was right that one exists —
but it's produced by a different, independent subsystem than the one that prompted the question:

- **What computes it**: RSA Adaptive Authentication (`com.rsa.mobilesdk`), the same SDK behind the
  plaintext `x-rsa` device-fingerprint header documented in
  [[Login-AT01-And-Device-Trust-Signals]] (`Compromised`, `Emulator` fields). The actual risk
  scoring happens **server-side**; the client only ever receives a coarse verdict back.
- **What that verdict looks like**: not a numeric score at all on the client — a 3-way enum,
  `ALLOW`/`CHALLENGE`/`DENY`, matching RSA's own real-world Adaptive Authentication vocabulary.
  `checkOnboardingRSADeny` only special-cases the deny path: a hardcoded backend result code
  `"4-00053"`, or a result message matching the `RSA_DENY` sentinel string, throws an exception
  that `handleOnboardingRSAControls`'s `onFailure` callback turns into a failed onboarding step.
  Anything else (including presumably `CHALLENGE`, handled elsewhere/not by this specific check)
  falls through to `onSuccess`.
- **What does *not* feed it**: `org.jod.mobile.android.xkey`'s `rooted` boolean. That flag is
  written only to `XKeySecHolderSL1`'s local `SharedPreferences` and folded into the `xdevice`
  string sent to XKey's own INIT/REGISTER/REGISTER-UPDATE endpoints (see
  [[XKey-Root-Detection-Check]]) — a completely separate backend surface from whatever endpoint
  `RsaHelper` talks to. No code path was found reading `XKeyDeviceData`/`isRooted` from anywhere in
  `RsaHelper`, `UtilsConstants`, or either of the two onboarding call sites (`yf0/m`, `yq/o`).

So: two independent device-trust subsystems live in this app, each doing its own device
fingerprinting and each talking to its own backend, with no client-side code connecting them. The
one that actually gates onboarding with an observable ALLOW/CHALLENGE/DENY-style decision is RSA
Adaptive Authentication, not XKey. It remains possible the *backend* correlates signals from both
subsystems (they'd both plausibly land on data tied to the same account/session), but that's
outside what static analysis of the client can show.

## Generalizing the pattern

To find every other RSA-verdict check point beyond onboarding/payments already found here:

```
grep -rl "RsaState\|checkOnboardingRSADeny\|checkPaymentsRSADeny\|handle.*RSAControls" smali_classes*/
```

And, more generally, when a hypothesis about "does X feed into Y" can't be confirmed inside the
package where X lives: widen the grep to the vocabulary Y would plausibly use (`trust`, `score`,
`risk`, `deny`, `allow`, `challenge`) across the *whole* decompiled tree before concluding X has no
effect — the actual mechanism here was found in a completely different top-level package
(`it.posteitaliane.df_utils.rsa`) than the one the original question was about.

## Related concepts

- [[Anti-Detection-And-Gadget-Mode]]

## Open questions / next steps

- [ ] Find where `RSA_CHALLENGE` is actually handled (a step-up/MFA prompt?) — `checkOnboardingRSADeny`
      only special-cases `DENY`, so `CHALLENGE` must be read somewhere else, either in `yf0/m`/`yq/o`
      directly or in a caller further up.
- [ ] Confirm what backend endpoint `RsaHelper`'s `resultCode`/`resultMessage` actually come from —
      not yet captured live in an HTTP log; would need a fresh onboarding attempt with
      [[http-pinning-bypass-and-dump.js]] attached and a body-search for `"4-00053"` or `"RSA_DENY"`.
- [ ] Check `checkPaymentsRSADeny`/`handlePaymentsRSAControls` (the payments-flow sibling of this
      exact mechanism, already visible in `RsaHelper` but not analyzed here) for the same
      ALLOW/CHALLENGE/DENY pattern gating a payment instead of onboarding.

## See also

- [[XKey-Root-Detection-Check]]
- [[Login-AT01-And-Device-Trust-Signals]]
- [[Case-Studies]]
