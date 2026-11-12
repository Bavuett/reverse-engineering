---
tags: [example]
level: 1
aliases: ["hook java.net.URL", "log HTTP endpoints Frida"]
created: 2026-11-12
---

# Example: Logging-URL-Connections

> [!info] Level 1 — basics
> One idea: before decrypting anything, find out *which endpoints* the app talks to, by hooking the lowest common Java entry point every HTTP stack eventually touches.

## Goal

Print every URL the app opens through the platform networking classes, and see which calls bypass them. Belongs to [[Network-Interception]].

## Script

```javascript
Java.perform(() => {
    const URL = Java.use("java.net.URL");

    URL.openConnection.overload().implementation = function () {
        console.log(`[URL] openConnection ${this.toString()}`);
        return this.openConnection();
    };

    // OkHttp never calls URL.openConnection; catch it at request construction instead.
    try {
        const Builder = Java.use("okhttp3.Request$Builder");
        Builder.build.implementation = function () {
            const req = this.build();
            console.log(`[OkHttp] ${req.method()} ${req.url()}`);
            return req;
        };
    } catch (e) {
        console.log("[*] okhttp3 not present (or obfuscated)");
    }
});
```

## Step by step

1. **`URL.openConnection()`** is the gateway of `HttpURLConnection`, used by older code, many SDKs, and some WebView helpers. `this.toString()` gives the full URL.
2. **OkHttp is its own stack.** It opens sockets directly, so a `URL` hook misses all OkHttp traffic. `Request$Builder.build()` is called once per request with the final method and URL, which makes it a good, low-noise observation point.
3. **Obfuscated OkHttp.** In R8 builds `okhttp3.*` is often renamed; `Java.use` then throws. Find the renamed class by its shape or strings ([[Enumerating-Loaded-Classes-By-Keyword]]) — or go one level lower, to TLS, where no renaming applies ([[Correlating-SSL-Write-With-A-Java-Stack]]).
4. **Not every byte goes through Java.** WebView (Chromium) and Flutter do their networking in native code; they show up neither here nor in OkHttp hooks. For those, hook native TLS ([[SSL-Write-Dump-In-Libflutter]]).
5. **This is observation, not interception**: you see URLs, not bodies. Bodies need either a proxy (with a pinning bypass) or in-process hooks on the HTTP library.

## Compared with real code

- [[Injecting-An-OkHttp-Interceptor-With-Java-RegisterClass]] — the TUA investigation goes from logging to full request/response capture inside OkHttp.
- [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]] — in PressReader the "URL" class turned out to be an obfuscated OkHttp `HttpUrl`, confirmed by decompiling.

## See also

- [[Network-Interception]]
- [[Disabling-OkHttp-CertificatePinner]]
- [[Logging-Arguments-And-Return-Values]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
