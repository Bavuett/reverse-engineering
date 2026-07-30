---
tags: [snippet]
project: "ClasseViva (eu.spaggiari.classevivastudente)"
source: "eu.spaggiari.classevivastudente — Flutter (Dart AOT) Android app"
version: "unknown (not recorded alongside the imported files)"
source_path: "Frida hook on BoringSSL SSL_write, statically linked inside libflutter.so"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. Small fragment kept to illustrate one hooking pattern. Check the app's ToS before any redistribution."
---

# SSL-Write-Dump-In-Libflutter

## Context

ClasseViva is a Flutter app: its login POST to `rest/v1/auth/login` never goes through Android's Java `HttpsURLConnection`/OkHttp stack, so there is **no Java-layer networking to hook** (exactly the case [[Network-Interception]] and [[Flutter-Dart-AOT]] warn about). The TLS lives in a BoringSSL statically linked into `libflutter.so`, and the plaintext is readable by hooking `SSL_write` — regardless of the app's certificate pinning, since the hook reads the buffer *before* encryption. This is the native-layer half that complements hooking `login()` directly (see [[Attaching-At-A-Dart-AOT-Entry-Offset]]): one shows the structured request object, the other shows the exact bytes on the wire.

## Original path

`` (no app source path — SSL_write is an exported symbol inside the bundled libflutter.so) ``

## Snippet

```javascript
// Flutter bundles BoringSSL inside libflutter.so (sometimes libapp.so) rather than using libssl.so.
const flutter = Process.findModuleByName("libflutter.so");
const sslWrite = Module.findExportByName(flutter.name, "SSL_write");

Interceptor.attach(sslWrite, {
    onEnter(args) {
        const len = args[2].toInt32();
        if (len <= 0) return;
        const text = args[1].readUtf8String(len);
        // Only surface the interesting request; TLS also carries framing/keepalives.
        if (text && text.includes("auth/login")) {
            console.log("[*] SSL_write -> " + text);
        }
    }
});
```

## Notes

- `SSL_write` is still an **exported symbol** even inside `libflutter.so`, so `Module.findExportByName` finds it without any static offset hunting — the easy case, unlike the Dart AOT function in [[Attaching-At-A-Dart-AOT-Entry-Offset]] which needed a bare offset.
- Reading in `onEnter` is correct for `SSL_write` (plaintext is already in the buffer on entry); the mirror hook `SSL_read` must read in `onLeave` because its buffer is filled *during* the call — the distinction spelled out in [[Network-Interception]].
- This works **with pinning fully intact**: nothing here touches the TLS handshake or certificate validation, so there's no CA to install and no pin to defeat — the whole reason native `SSL_write`/`SSL_read` hooking is the default approach for Flutter targets.
- Pairing this with the `login()` argument hook gives two independent views of the same request — a good cross-check that the fields decoded from the Dart object (`uid`/`pass`/`ident`/`otp`) really are what gets serialized and sent.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Network-Interception]]
- [[Flutter-Dart-AOT]] in [[ARM64-Android]]
- [[ClasseViva-Case-Study]] in [[Case-Studies]]
