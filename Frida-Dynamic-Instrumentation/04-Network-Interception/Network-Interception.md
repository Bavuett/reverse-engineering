---
tags: [fundamentals]
aliases: ["SSL Pinning Bypass", "TLS Interception"]
created: 2026-07-28
---

# Network-Interception

## In short

There are two layers at which to intercept an app's network traffic: the **Java layer** (OkHttp interceptors, `HttpsURLConnection`, `TrustManager`) — easy to hook by class/method name, but only exists if the app actually uses those Java-visible APIs — and the **native TLS layer** (BoringSSL's `SSL_write`/`SSL_read`, statically linked into the app or the platform) — always present, harder to find without static analysis first, and the only option when there's no Java networking code to hook at all, which is the normal case for a Flutter app (see [[Flutter-Dart-AOT]]).

## Explanation

### Java layer: hooking the framework you can see

Most non-Flutter Android apps that do TLS pinning implement it as a custom `X509TrustManager` (or an OkHttp `CertificatePinner`). Hooking the verification method directly is the most common pinning bypass:

```javascript
Java.perform(() => {
    const TrustManagerImpl = Java.use("com.android.org.conscrypt.TrustManagerImpl");
    TrustManagerImpl.verifyChain.implementation = function (untrustedChain, trustAnchorChain, host, clientAuth, ocspData, tlsSctData) {
        console.log(`[*] Bypassing pin check for host: ${host}`);
        return untrustedChain; // pretend every chain is trusted
    };
});
```

The exact class/method to hook varies by Android version and networking stack (Conscrypt's `TrustManagerImpl`, OkHttp's `CertificatePinner.check`, a custom app-level `TrustManager`) — this is the point where static analysis of the app's smali (see [[Dalvik-Bytecode]]) pays off: grep the decompiled sources for `TrustManager`, `CertificatePinner`, or `checkServerTrusted` to find the actual class in *this* app before guessing.

Once pinning is bypassed at this layer, request/response bodies are readable in plain Java by hooking OkHttp's `Interceptor` chain or `RequestBody`/`ResponseBody`, as shown in [[Java-Layer-Hooking]]'s worked example.

### Native layer: hooking BoringSSL directly

Modern Android (and every Flutter app, which bundles its own BoringSSL inside `libflutter.so`/`libapp.so` rather than using the platform's Java TLS stack at all) does the actual encrypt/decrypt in native code, through `SSL_write`/`SSL_read`. Hooking these two functions reads plaintext **regardless of which Java networking library — if any — the app uses**, and regardless of certificate pinning, since you're reading the data after it's already been decrypted (`SSL_read`) or before it's been encrypted (`SSL_write`), not touching the TLS handshake at all:

```javascript
const libssl = Process.findModuleByName("libssl.so"); // or libflutter.so for a Flutter app

if (libssl !== null) {
    const sslWrite = Module.findExportByName(libssl.name, "SSL_write");
    const sslRead = Module.findExportByName(libssl.name, "SSL_read");

    Interceptor.attach(sslWrite, {
        onEnter(args) {
            const buf = args[1];
            const len = args[2].toInt32();
            console.log("[*] SSL_write (" + len + " bytes):");
            console.log(hexdump(buf, { length: len, ansi: false }));
        }
    });

    Interceptor.attach(sslRead, {
        onEnter(args) {
            this.buf = args[1]; // populated by the function; read it in onLeave
        },
        onLeave(retval) {
            const len = retval.toInt32();
            if (len > 0) {
                console.log("[*] SSL_read (" + len + " bytes):");
                console.log(hexdump(this.buf, { length: len, ansi: false }));
            }
        }
    });
}
```

Note `SSL_read`'s buffer is only valid to read in `onLeave` (the actual bytes are written into it during the call), while `SSL_write`'s buffer already holds the plaintext on entry.

### Which one does a given app need?

| App type | Where the TLS stack lives | Approach |
| --- | --- | --- |
| Plain Java/Kotlin app using `HttpsURLConnection`/OkHttp | `com.android.org.conscrypt`, app/OkHttp classes | Java-layer hook (`TrustManager`, `CertificatePinner`, OkHttp interceptor) |
| Flutter app (Dart networking via `dart:io`/`package:http`) | BoringSSL statically linked into `libflutter.so` (or `libapp.so` depending on build) | Native `SSL_write`/`SSL_read` hook — there is no Java networking code to hook at all |
| App with custom native pinning logic | App's own `.so` | Static analysis first (find the cert comparison routine per [[Reading-Raw-Disassembly]]), then a targeted `Interceptor.attach` on that specific function, as in [[Native-Memory-And-ARM64]] |

### Combining with a proxy

Reading plaintext via `SSL_write`/`SSL_read` hooks gives you the data without needing a working MITM proxy at all — no CA certificate to install, no pinning to actually defeat for interception to work, since you're not touching the network path. Pair it with `mitmproxy`/Burp only when you need to *modify* traffic in flight or want a friendlier UI than raw `hexdump` output in a terminal.

## Worked example

See the `SSL_write`/`SSL_read` hook above — it's already a complete, runnable script (`frida -U -f <package> -l ssl-dump.js --no-pause`) requiring no prior static analysis, since `SSL_write`/`SSL_read` are always exported symbols in `libssl.so`/`libflutter.so`.

## More examples

- [[Frida-JS-API-Cheatsheet]] in [[Frida-Dynamic-Instrumentation-Cheatsheets|Cheatsheets]].

## See also

- [[Java-Layer-Hooking]]
- [[Native-Memory-And-ARM64]]
- [[Flutter-Dart-AOT]] in [[ARM64-Android]] — why Flutter apps have no Java networking layer to hook at all.

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]

## Flashcards
#flashcards

Why does hooking `SSL_write`/`SSL_read` work regardless of certificate pinning?::Because it reads the data after decryption (`SSL_read`) or before encryption (`SSL_write`) — the TLS handshake and certificate validation are never touched, so pinning being intact or bypassed makes no difference to what the hook sees.

Why can't a Flutter app's network traffic usually be intercepted at the Java layer?::Flutter apps do networking through Dart code calling into a statically-linked BoringSSL inside libflutter.so/libapp.so, not through Android's Java `HttpsURLConnection`/OkHttp stack — there's no Java-visible networking code to hook.

In the `SSL_read` hook, why must the buffer be read in `onLeave` rather than `onEnter`?::`SSL_read`'s buffer argument is an out-parameter — it only gets filled with the decrypted bytes during the call, so it's empty/stale at `onEnter` and only valid to read once the call returns.
