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

# Hooking-The-OkHttp-Interceptor-Chain-Exactly-Once

## Context

[[Network-Interception]]'s Java-layer section shows how to bypass pinning; reading the actual request/response bodies needs one more hook. `okhttp3.internal.http.RealInterceptorChain.proceed` is called once per interceptor in the chain (every interceptor calls `chain.proceed()` to hand off to the next one), so a naive hook there fires many times per logical HTTP call — the `index` field (`RealInterceptorChain`'s own position counter) is what lets you log each request/response pair exactly once, at the outermost layer, before the app's own interceptors (pinning checks included) run at all.

## Original path

`` Case-Studies/poste-italiane/source/http-pinning-bypass-and-dump.js ``

## Snippet

```javascript
const RealInterceptorChain = Java.use("okhttp3.internal.http.RealInterceptorChain");

RealInterceptorChain.proceed.overload("okhttp3.Request").implementation = function (request) {
    const isOutermost = this.index.value === 0;

    if (isOutermost) logRequest(request);

    let response;
    try {
        response = this.proceed(request);
    } catch (e) {
        // Without this catch, proceed() throwing (timeout, TLS pinning rejection,
        // host resolution failure...) silently swallows the whole call from Frida's
        // side — the request gets logged, then nothing, no matter which of those
        // it actually was.
        if (isOutermost) console.log(`[xxx] ${request.method()} ${request.url()} — proceed() threw: ${e.message}`);
        throw e; // still propagate — the app must see its own real failure
    }

    if (isOutermost) logResponse(response);
    return response;
};
```

### Example — turning the same hook point into a portable curl command

Once request/response logging works, the same captured `Request` object is enough to build a ready-to-replay `curl` command — useful for handing a single captured call to Postman or a teammate without needing Frida running at all:

```javascript
function shQuote(value) {
    return `'${String(value).replace(/'/g, `'\\''`)}'`;
}

let curl = `curl -X ${request.method()} ${shQuote(request.url().toString())}`;
for (const [name, value] of headerPairs) {
    if (/^(content-length|host)$/i.test(name)) continue; // curl sets these itself
    curl += ` \\\n  -H ${shQuote(`${name}: ${value}`)}`;
}
if (bodyText !== null) curl += ` \\\n  --data-raw ${shQuote(bodyText)}`;
console.log(`[curl] ${curl}`);
```

Built and logged as **one** string in **one** `console.log` call, deliberately — the plain request/response logger above prints several separate lines per call (method+URL, then each header, then the body), which is fine for a human reading the console but would corrupt a multi-line shell command if two concurrent requests' individual lines interleaved in the output. A handful of near-simultaneous cold-start calls (parallel `app-registry` checks) did exactly that in this app's own logs; wrapping the whole curl command in a single call sidesteps the problem entirely, since Frida ships each `console.log` as one message over its control channel rather than as a raw, interleavable stdout byte stream.

## Notes

- Hooked on `RealInterceptorChain` rather than `RealCall`'s `execute()`/`enqueue()` specifically because `RealCall`'s package has moved across OkHttp versions (`okhttp3.RealCall` → `okhttp3.internal.connection.RealCall`), while `RealInterceptorChain` has stayed in the same place since OkHttp 3.x — a more version-stable hook target for a class you can't confirm the app's exact OkHttp version of ahead of time.
- The exception-catching addition (second half of the snippet) was added *after* a bug: a real TLS pinning failure on two specific hosts (`SSLHandshakeException: Trusted chain does not end in a TrustAnchor`, from a fifth pinning layer this script hadn't hooked yet — see [[Home-Screen-Skeleton-NetworkSecurityConfig-Pinning]]) was invisible for a while, because an uncaught exception from `this.proceed(request)` just unwound through the hook with zero logging. Catching, logging, and re-throwing turns a silent failure into a labeled one without changing the app's own behavior at all.
- `this.index.value` reads a Kotlin/Java `int` field through Frida's field-access wrapper (`.value`), not a method call — a common enough pattern worth remembering distinctly from method hooking.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Network-Interception]]
- [[Java-Layer-Hooking]]
- [[Home-Screen-Skeleton-NetworkSecurityConfig-Pinning]] and [[Poste-Italiane]] in [[Case-Studies]]
