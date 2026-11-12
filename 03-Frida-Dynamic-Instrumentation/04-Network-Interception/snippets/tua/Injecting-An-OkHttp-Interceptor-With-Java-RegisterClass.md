---
tags: [snippet]
level: 3
project: "TUA (net.pluservice.tua)"
source: "net.pluservice.tua — Cordova/Android hybrid app, decompiled to smali from the APK"
version: "11.26.4"
source_path: "Frida script combined.js, section 4 (not app source) — hooks okhttp3.OkHttpClient$Builder.build"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. This is a small dynamic-analysis fragment kept to illustrate one hooking pattern. Check the app's ToS before any redistribution."
---

# Injecting-An-OkHttp-Interceptor-With-Java-RegisterClass

> [!info] Level 3 — real code
> A real in-process HTTP logger: a Java class created at runtime that implements `okhttp3.Interceptor`, added to every `OkHttpClient` the app builds, plus an explicit proxy forced onto the same builder.

## Context

The TUA app's native networking module (`net.pluservice.plusnetworking.PlusNetworking`) builds its own `OkHttpClient`. Instead of a network MITM, the investigation injected an *application interceptor* into the client: it sees each request and response inside the process, after the app built them and before/after the network — so certificate pinning is irrelevant to what it logs. Part of [[Tua-Case-Study]].

## Original path

`combined.js`, section 4 of the TUA analysis script (loaded with `frida -U -f net.pluservice.tua -l combined.js`). Comments translated.

## Snippet

```javascript
const OkHttpInterceptor = Java.use('okhttp3.Interceptor');
const OkHttpClientBuilder = Java.use('okhttp3.OkHttpClient$Builder');
const Buffer = Java.use('okio.Buffer');

const LoggingInterceptor = Java.registerClass({
    name: 'net.pluservice.tua.FridaLoggingInterceptor',
    implements: [OkHttpInterceptor],
    methods: {
        intercept: function (chain) {
            const request = chain.request();
            const url = request.url().toString();
            console.log('\n>>> [HTTP REQUEST] ' + request.method() + ' ' + url);
            const reqHeaders = request.headers();
            for (let i = 0; i < reqHeaders.size(); i++)
                console.log('    ' + reqHeaders.name(i) + ': ' + reqHeaders.value(i));
            try {
                const body = request.body();
                if (body !== null) {
                    const buffer = Buffer.$new();
                    body.writeTo(buffer);
                    console.log('    body: ' + buffer.readUtf8());
                }
            } catch (e) { console.log('    [request body unreadable: ' + e + ']'); }

            const response = chain.proceed(request);

            console.log('<<< [HTTP RESPONSE] ' + response.code() + ' ' + url);
            try {
                // peekBody reads a copy without consuming the real body,
                // which the app must still be able to read after us.
                const peeked = response.peekBody(1024 * 1024);
                console.log('    body: ' + peeked.string());
            } catch (e) { console.log('    [response body unreadable: ' + e + ']'); }
            return response;
        }
    }
});

const Proxy = Java.use('java.net.Proxy');
const ProxyType = Java.use('java.net.Proxy$Type');
const InetSocketAddress = Java.use('java.net.InetSocketAddress');

OkHttpClientBuilder.build.implementation = function () {
    this.addInterceptor(LoggingInterceptor.$new());
    // Force the proxy on the client: the system setting
    // (settings put global http_proxy) isn't honoured by every stack.
    const proxyAddr = InetSocketAddress.$new('10.0.2.2', 8080);
    this.proxy(Proxy.$new(ProxyType.HTTP.value, proxyAddr));
    return this.build();   // the original implementation, not recursion
};
```

## Reconstructed source

What the hook makes the app's code behave like, written as plain OkHttp:

```java
class FridaLoggingInterceptor implements okhttp3.Interceptor {
    @Override public Response intercept(Chain chain) throws IOException {
        Request request = chain.request();
        log(request);                                  // method, url, headers, body via okio.Buffer
        Response response = chain.proceed(request);    // continue down the chain
        log(response.code(), response.peekBody(1 << 20).string());
        return response;
    }
}

// every `new OkHttpClient.Builder()...build()` in the app effectively becomes:
builder.addInterceptor(new FridaLoggingInterceptor())
       .proxy(new Proxy(Proxy.Type.HTTP, new InetSocketAddress("10.0.2.2", 8080)))
       .build();
```

## Notes

- **`Java.registerClass` with `implements`** produces a genuine class the app's OkHttp can call through the `Interceptor` interface — no reflection tricks. Compare the permissive `X509TrustManager` built the same way in [[Bypassing-Pinning-With-A-Custom-TrustManager]].
- **The chain contract.** An interceptor must call `chain.proceed(request)` exactly once and return a `Response`; forgetting either breaks every request. The script follows it exactly.
- **Consuming bodies.** A request body is serialized into a separate `okio.Buffer` (`writeTo`), and the response is read with `peekBody(limit)`, a copy capped at 1 MiB. Calling `response.body().string()` instead would consume the stream and leave the app with an empty body.
- **Hooking `Builder.build()` rather than `OkHttpClient` constructors** catches every client at the moment its configuration is frozen; `this.build()` inside the implementation calls the original ([[Calling-Through-An-Overload-Without-Recursing]]).
- **Forcing a proxy** with `Builder.proxy(...)` sidesteps the unreliable system-wide `http_proxy` setting. `10.0.2.2` is the emulator's alias for the host machine, where mitmproxy listens on port 8080.
- **Limit.** The same script's next sections record that Cordova's WebView traffic goes through Chromium's network stack, not OkHttp, so none of it appears here — it was handled by separate hooks (`WebViewClient.shouldInterceptRequest`, and injecting `--proxy-server` into Chromium's `CommandLine`).
- Compare a different approach to the same goal in another app: [[Hooking-The-OkHttp-Interceptor-Chain-Exactly-Once]].

## See also

- [[Network-Interception]]
- [[Logging-URL-Connections]]
- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
