---
tags: [snippet]
level: 3
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "http-pinning-bypass-and-dump.js (Frida instrumentation script, not app source)"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Stacking-Five-Independent-Pinning-Bypasses

## Context

[[Network-Interception]] frames the Java-layer bypass as a single hook on `TrustManagerImpl` or `CertificatePinner`. In practice this app used **five** independent, non-overlapping validation paths at once — a single bypass covered most traffic but left two specific hosts failing, discovered only after the app got far enough into an authenticated session to reach them.

## Original path

`` Case-Studies/poste-italiane/source/http-pinning-bypass-and-dump.js ``

## Snippet

The five layers, in the order they were actually found necessary (not the order they run in):

```javascript
// 1. Platform trust manager — covers HttpsURLConnection and most OkHttp traffic
Java.use("com.android.org.conscrypt.TrustManagerImpl").verifyChain.implementation =
    function (untrusted, anchor, host) { return untrusted; };

// 2. OkHttp's own certificate pinner, independent of #1
["check", "check$okhttp"].forEach((name) => {
    // check$okhttp is OkHttp 5.x's Kotlin-compiled name for the same method
    Java.use("okhttp3.CertificatePinner")[name]?.overloads.forEach((ov) => { ov.implementation = function () {}; });
});

// 3. This app's own custom OkHttp Interceptor doing manual, independent validation
Java.use("it.posteitaliane.df_utils.network.SSLInterceptor").intercept.implementation =
    function (chain) { return chain.proceed(chain.request()); };

// 4. In-app WebView screens have their own separate error surface
Java.use("android.webkit.WebViewClient").onReceivedSslError.implementation =
    function (view, handler, error) { handler.proceed(); };

// 5. Android's DECLARATIVE network_security_config.xml pinning — a platform class
// entirely separate from #1, found only when two specific hosts kept throwing
// "Trusted chain does not end in a TrustAnchor" with 1-4 all already active.
Java.use("android.security.net.config.NetworkSecurityTrustManager").checkServerTrusted
    .overloads.forEach((ov) => { ov.implementation = function (...args) {
        return ov.returnType.className === "java.util.List" ? Java.use("java.util.Arrays").asList(args[0]) : undefined;
    }; });
```

### What each layer actually fires against, in the app's own console output

Not hypothetical coverage — each of the five produced its own distinct, real log line the moment it intercepted a genuine check:

```
[pin-bypass] TrustManagerImpl.verifyChain() — accepting chain for host: appregistry.mobile.poste.it
[pin-bypass] CertificatePinner.check$okhttp() — skipping pin check for host: idp-poste.poste.it
[pin-bypass] SSLInterceptor.intercept() — passthrough to chain.proceed()
[pin-bypass] WebViewClient.onReceivedSslError() — proceeding anyway
[pin-bypass] NetworkSecurityTrustManager.checkServerTrusted() — bypassing Network Security Config pinning
```

The `CertificatePinner` line specifically reads `check$okhttp` rather than `check` — OkHttp 5.x's Kotlin compiler renames the method, one more reason `["check", "check$okhttp"].forEach(...)` hooks both names rather than assuming which one a given OkHttp version actually uses.

### The exact failure #5 was found from, before the fix existed

```
[xxx] GET https://oneapp.poste.it/oneapp/home-service/api/v2/customer/home — proceed() threw: Error: javax.net.ssl.SSLHandshakeException: Trusted chain does not end in a TrustAnchor
[xxx] POST https://appup.mobile.poste.it/jod-mobile-server/json/services/sca/v1/common/verifyUserStatus — proceed() threw: Error: javax.net.ssl.SSLHandshakeException: Trusted chain does not end in a TrustAnchor
```

Only visible at all because of [[Hooking-The-OkHttp-Interceptor-Chain-Exactly-Once]]'s exception-catching addition — without it, both of these calls would have just vanished from the log with #1-#4 already active, indistinguishable from a generic network failure.

## Notes

- Bypasses #1-#4 were all needed from the very first working capture — every one of them fired against a real check this app actually performs, confirmed by their own console output during live traffic (see [[Poste-Italiane]]'s Findings). #5 only surfaced once login succeeded and traffic reached `oneapp.poste.it`/`appup.mobile.poste.it` specifically — a reminder that "the bypass works" after early testing doesn't mean every host is covered, only every host reached *so far*.
- #5's discovery method matters as much as the fix: dumping `TrustManagerImpl`'s own `getDeclaredMethods()` first ruled out "a missed overload of the hook already in place" before looking for a *different* class entirely — see [[Dumping-Real-Method-Signatures-Before-Hooking]].
- Each bypass is independently `try`/`catch`-wrapped in the real script (not shown here for brevity) — a class that doesn't exist in a given app version (e.g. no custom `SSLInterceptor` at all) shouldn't abort every other, unrelated bypass from installing.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Network-Interception]]
- [[Home-Screen-Skeleton-NetworkSecurityConfig-Pinning]] and [[Poste-Italiane]] in [[Case-Studies]]
