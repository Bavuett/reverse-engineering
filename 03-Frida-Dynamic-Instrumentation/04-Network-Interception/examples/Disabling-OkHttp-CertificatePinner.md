---
tags: [example]
level: 1
aliases: ["CertificatePinner bypass", "OkHttp pinning Frida"]
created: 2026-11-12
---

# Example: Disabling-OkHttp-CertificatePinner

> [!info] Level 1 — basics
> One idea: OkHttp's certificate pinning is a single `void` method that throws on mismatch — turn it into a no-op and the pin always "passes".

## Goal

Let a MITM proxy (mitmproxy, Burp) see the traffic of an app that pins with `okhttp3.CertificatePinner`. Belongs to [[Network-Interception]].

## Script

```javascript
Java.perform(() => {
    const CertificatePinner = Java.use("okhttp3.CertificatePinner");

    CertificatePinner.check.overload("java.lang.String", "java.util.List").implementation =
        function (hostname, peerCertificates) {
            console.log(`[*] pin check skipped for ${hostname}`);
            // no call to the original, no exception: the check passes
        };
});
```

## Step by step

1. **How the pinner works.** After the TLS handshake, OkHttp calls `CertificatePinner.check(host, certs)`. If none of the server chain's public-key hashes matches the configured pins, it throws `SSLPeerUnverifiedException`; otherwise it returns normally. Returning normally without checking = bypass.
2. **Overloads differ by version.** OkHttp 3.x also has `check(String, Certificate[])`; OkHttp 4 adds a Kotlin-internal `check$okhttp(String, Function0)`. Hook all that exist, each in its own `try`, so a missing one doesn't abort the script.
3. **Pinning isn't the only gate.** The proxy's CA must still be trusted by the TLS layer: install it as a user CA *and* make sure the app trusts user CAs (its `network_security_config`), or bypass the `TrustManager` as well ([[Bypassing-Pinning-With-A-Custom-TrustManager]]).
4. **Obfuscation.** If OkHttp is renamed, find the pinner by its exception message string ("Certificate pinning failure!") in the decompiled code, then hook the renamed class.
5. **Check it worked**: the log line appears and the proxy shows decrypted traffic. If the log appears but the app still fails, another layer is rejecting the connection — see [[Stacking-Five-Independent-Pinning-Bypasses]].

## Compared with real code

The TUA investigation used exactly this hook as its first step towards mitmproxy, with the version-dependent second overload guarded:

```javascript
const CertificatePinner = Java.use('okhttp3.CertificatePinner');
CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function (hostname, peerCertificates) {
    console.log('[*] CertificatePinner.check bypassed for host: ' + hostname);
};
try {
    CertificatePinner.check.overload('java.lang.String', '[Ljava.security.cert.Certificate;').implementation = function (hostname, peerCertificates) {
        console.log('[*] CertificatePinner.check (varargs) bypassed for host: ' + hostname);
    };
} catch (e) { /* overload absent in this OkHttp version */ }
```

Note the array type written as a JVM descriptor (`[Ljava.security.cert.Certificate;`) — see [[From-Smali-Signature-To-Frida-Overload]]. Its comments also record the limit: WebView traffic doesn't go through OkHttp, so it relies on the system trust store instead ([[Tua-Case-Study]]).

## See also

- [[Network-Interception]]
- [[Changing-A-Return-Value]] — the general "void method → no-op" technique
- [[Logging-URL-Connections]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
