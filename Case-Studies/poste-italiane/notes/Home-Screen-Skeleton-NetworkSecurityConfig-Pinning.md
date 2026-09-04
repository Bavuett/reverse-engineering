---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-04
---

# Home-Screen-Skeleton-NetworkSecurityConfig-Pinning

## Question / goal

With login fully succeeding (see [[Login-AT01-And-Device-Trust-Signals]]) and the app landing on its
home screen, the balance/financial-products section stayed on an infinite loading skeleton, and the
app periodically appeared to "go back" to a fresh login/PIN prompt entirely on its own. Was this
another root/Frida-detection symptom, or something else?

## How this was found

The captured traffic log (`local/frida-session-2026-09-04-jwe-decrypted.log`, JWE-decrypting and
curl-exporting per [[Decrypting-JWE-Request-Response-Bodies]]) showed the app repeating its *entire*
PIN+OTP re-authentication cycle (`securetool/v1/challenge` → `sh2-web.poste.it/.../authorizeTransaction`
→ `openid-az` → `customer/home`) six times in a single capture — without the user re-typing a PIN six
times. Grepping the log for every `customer/home` request/response pair showed the actual pattern
directly: **every single `GET .../customer/home` request had zero matching `[<<<]` response line** —
not a single one, across six attempts — while sibling calls to the exact same host
(`oneapp.poste.it/remote-logger/v1/logs`) succeeded normally, moments apart, in the same capture. This
ruled out a general connectivity/DNS/TLS problem with the host itself.

The app's own telemetry (`remote-logger` POSTs, matching `pt_act_name: "getHomeVOne"`) confirmed the
call was failing client-side rather than being rejected by the server: `"Network_error"`,
`pt_http_code: "-1"` — an HTTP code of `-1` means no HTTP response was ever received at all, consistent
with a connection failing before or during the TLS handshake rather than a normal 4xx/5xx.

The actual cause was invisible until [[http-pinning-bypass-and-dump.js]]'s `RealInterceptorChain.proceed`
hook was changed to catch and log whatever `proceed()` throws (previously an uncaught exception there
just left a request logged with no response and no error at all — see the script's own comment on this
change). Re-attaching with that fix immediately surfaced the real signal:

```
[xxx] GET https://oneapp.poste.it/oneapp/home-service/api/v2/customer/home — proceed() threw: Error: javax.net.ssl.SSLHandshakeException: Trusted chain does not end in a TrustAnchor
```

The same exception also fired for `appup.mobile.poste.it`'s `verifyUserStatus`. Since no MITM proxy was
involved anywhere in this session — Frida's TLS hooks accept the platform trust manager's own verdict
in-process, without substituting a proxy certificate — a genuine trust-anchor failure for the app's
*real* certificate, on a host other similarly-configured calls succeed against, pointed at a **second,
independent pinning layer** rather than a real network fault. Dumping
`com.android.org.conscrypt.TrustManagerImpl`'s own declared methods live confirmed there was only the
one `verifyChain` overload already hooked (ruling out a missed overload there); checking for
`android.security.net.config.NetworkSecurityTrustManager` — Android's platform class for declarative
`network_security_config.xml` `<pin-set>` pinning — found it present and loaded, with its own,
completely separate `checkServerTrusted(...)` methods never touched by any of the four bypasses already
in place.

## Relevant source

- [[http-pinning-bypass-and-dump.js]]

## Excerpt

```
[xxx] POST https://appup.mobile.poste.it/jod-mobile-server/json/services/sca/v1/common/verifyUserStatus — proceed() threw: Error: javax.net.ssl.SSLHandshakeException: Trusted chain does not end in a TrustAnchor
[xxx] GET https://oneapp.poste.it/oneapp/home-service/api/v2/customer/home — proceed() threw: Error: javax.net.ssl.SSLHandshakeException: Trusted chain does not end in a TrustAnchor
```

The fifth bypass added to [[http-pinning-bypass-and-dump.js]]:

```js
const NetworkSecurityTrustManager = Java.use("android.security.net.config.NetworkSecurityTrustManager");
const Arrays = Java.use("java.util.Arrays");

NetworkSecurityTrustManager.checkServerTrusted.overloads.forEach((ov) => {
    ov.implementation = function (...args) {
        console.log("[pin-bypass] NetworkSecurityTrustManager.checkServerTrusted() — bypassing Network Security Config pinning");
        if (ov.returnType.className === "java.util.List") {
            return Arrays.asList(args[0]); // the input X509Certificate[], "trusted" as-is
        }
        // void overloads: not calling the original is the pass.
    };
});
```

## Analysis

Two things resolved at once here, and it's worth being precise about which is which:

1. **The infinite-skeleton "torna indietro" symptom was TLS pinning, not a real device-trust or
   network issue.** `oneapp.poste.it`'s `customer/home` and `appup.mobile.poste.it`'s
   `verifyUserStatus` sit behind Android's declarative Network Security Config pinning specifically —
   a mechanism this app apparently applies more narrowly than the rest of its traffic (every other
   host worked fine with just the platform `TrustManagerImpl` hook), which is why this wasn't caught
   until traffic actually reached these two specific endpoints post-login. The app's own behavior on a
   client-side network failure at the home screen — quietly restarting the full PIN+OTP re-auth cycle
   rather than showing an explicit network error — is what produced the "keeps going back" symptom;
   the skeleton loader simply never got data to render.
2. **This is a real gap worth remembering for any future Android app**, not specific to Poste: Frida
   pinning-bypass scripts that only hook `TrustManagerImpl`/`CertificatePinner` (the two most commonly
   documented layers) can still fail silently on specific hosts if the app also uses XML-declared
   `network_security_config.xml` pinning for them — `NetworkSecurityTrustManager` is the platform class
   to check for whenever a bypass appears to work for *most* traffic but a specific host or two keeps
   failing with a trust-anchor error despite the usual two hooks being active.

## Generalizing the pattern

When TLS pinning bypass works for most of an app's traffic but a specific host or endpoint keeps
failing:

1. Don't assume it's a real network problem just because the failure looks host-specific — check
   whether *every* call to that exact endpoint fails while sibling calls to the *same host* succeed
   (as grepping this session's log for `customer/home` showed cleanly): a same-host split like that
   points at per-endpoint pinning configuration, not connectivity.
2. Make sure the interceptor-chain hook actually surfaces exceptions from `proceed()` — a pinning
   failure thrown there is otherwise indistinguishable, from the Frida console, from a request that
   simply never got a response for any other reason. This cost real time here before the hook itself
   was fixed to log it.
3. Once the exception names `SSLHandshakeException: Trusted chain does not end in a TrustAnchor` (or
   similar) on a host that other hosts don't trip on, check for
   `android.security.net.config.NetworkSecurityTrustManager` specifically — it's the platform class
   behind `network_security_config.xml`'s `<pin-set>`, and it's easy to miss because most
   TrustManagerImpl/CertificatePinner-only bypass scripts (including this one, until now) never
   mention it at all.

## Related concepts

- [[Anti-Detection-And-Gadget-Mode]] / [[Network-Interception]] — the broader TLS-pinning-bypass
  technique catalogue this fifth layer extends.

## Open questions / next steps

- [x] Confirmed the fix: after adding the `NetworkSecurityTrustManager` hook, `customer/home` returned
      `200` on every subsequent attempt, with no further `[xxx]` exceptions logged.
- [ ] None of the other four existing bypasses needed to change — worth keeping in mind that a future
      new host under test could still turn out to be pinned via yet another mechanism not covered by
      any of these five.

## See also

- [[Case-Studies]]
