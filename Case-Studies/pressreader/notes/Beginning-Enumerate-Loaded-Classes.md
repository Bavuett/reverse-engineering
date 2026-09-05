---
tags:
  - case-study-note
case_study: PressReader
created: 2026-09-05
---

# Enumerating Loaded Classes to begin app analysis

## Question / goal

We just landed in the codebase and we have no idea about how the app handles network requests and how it works. How can we trace the fundamental information we need to begin understanding something about the application?

## How this was found

With zero prior knowledge of PressReader's internals, the fastest way to get a foothold was to skip
static analysis entirely and ask the running process what it had already loaded. Rather than
dumping every loaded class (thousands of entries, mostly noise from the Android framework and
Kotlin stdlib), the script was written to filter `Java.enumerateLoadedClasses`'s `onMatch` callback
down to three substrings known to name the most common Android HTTP stacks: `okhttp`, `retrofit`,
`volley`. The app was spawned with `frida -U -f <package> -l inspect-loaded-classes.js` and the
script ran inside `Java.perform` immediately at spawn, before any UI interaction.

The output was a wall of matches, but every single one was rooted at `com.android.okhttp.*` — not
`com.squareup.okhttp3.*`, which is what a Gradle-declared OkHttp/Retrofit dependency would normally
produce. That naming was the actual signal here: `com.android.okhttp` is the legacy OkHttp 2.x fork
Google bundled directly into the Android platform framework since KitKat, used internally by
`java.net.HttpURLConnection`/`HttpsURLConnection` — it is not something the app chose to bundle, it
ships with the OS itself. Classes like `HttpURLConnectionImpl`, `DelegatingHttpsURLConnection`,
`OkUrlFactory`, and `AndroidShimResponseCache` only exist in that platform fork, confirming the
match wasn't a false positive from a differently-named app-level library.

Notably absent: nothing matched `retrofit` or `volley`, and nothing matched a `com.squareup.*`
namespace either. Read naively, that could mean PressReader doesn't use Retrofit/Volley at all. But
because the enumeration ran at spawn, before triggering any navigation or network call in the UI,
the more likely explanation is that those classes simply haven't been loaded by the JVM classloader
yet — Java/Kotlin classes are loaded lazily on first reference, so `enumerateLoadedClasses` is only
ever a snapshot of what's been touched *so far*, not what the app is capable of using.

That lazy-loading hypothesis was confirmed directly rather than left open: the same script was
re-run twice more from the REPL (`%reload`/re-injection) while actually navigating the app in
between runs — opening publications, letting content load — instead of only scanning at spawn. Each
successive run picked up new matches on top of the previous run's set, then stabilized:

- **Run 1** (spawn-time, documented above): ~190 `com.android.okhttp.*` classes, nothing else.
- **Run 2**: same baseline, plus a full `io.grpc.okhttp.internal.*` package (`a`, `b`, `e`, `f`, `j`,
  `j$a`/`j$b`/`j$c`/`j$e`, `k`, `l`, `m`, plus their array types) and `retrofit2.HttpException`.
- **Run 3**: run 2's set, plus `okhttp3.internal.connection.RouteException`,
  `okhttp3.internal.http2.{ConnectionShutdownException, StreamResetException}`, and
  `com.google.firebase.perf.network.FirebasePerfOkHttpClient`.
- **Run 4**: identical to run 3 — no new classes, suggesting the network-capable class surface had
  reached a steady state for the amount of app usage exercised so far (not a guarantee nothing else
  loads later, just no further movement across this pass).

This resolves the "not present vs. not yet loaded" question from the first pass: Retrofit and
`okhttp3` **are** part of PressReader's stack, they just hadn't been touched yet at spawn. It also
surfaced two things the original `okhttp`/`retrofit`/`volley` filter wasn't even looking for: gRPC
is in use, and Firebase Performance Monitoring is wrapping the OkHttp client. Both were only caught
because the filter matches on the substring `okhttp` anywhere in the class name, and
`io.grpc.okhttp.internal.*` (gRPC's own internal transport, distinct from a `grpc-java` app-level
package) and `com.google.firebase.perf.network.FirebasePerfOkHttpClient` both happen to contain it —
an accidental but welcome catch.

## Relevant source

- [[inspect-loaded-classes.js]] — the enumeration script itself: a single `Java.perform` block
  wrapping `Java.enumerateLoadedClasses`, filtering `onMatch` by a case-insensitive substring check
  against `okhttp`, `retrofit`, and `volley`.

## Excerpt

Representative slice of the console output (full log has ~190 matches, all under the same
namespace):

```
[*] Looking for notorious network packages loaded in memory.
[*] Found: com.android.okhttp.internal.huc.HttpsURLConnectionImpl
[*] Found: com.android.okhttp.Request$Builder
[*] Found: com.android.okhttp.OkHttpClient
[*] Found: com.android.okhttp.CertificatePinner
[*] Found: com.android.okhttp.internal.tls.OkHostnameVerifier
[*] Found: com.android.okhttp.internal.huc.HttpURLConnectionImpl
[*] Found: com.android.okhttp.OkUrlFactory
[*] Found: com.android.okhttp.AndroidShimResponseCache
...
[*] Done.
```

New classes that appeared only after driving the app through actual navigation (runs 2-3, diffed
against run 1's baseline):

```
[*] Found: io.grpc.okhttp.internal.j$a
[*] Found: io.grpc.okhttp.internal.a
[*] Found: io.grpc.okhttp.internal.k
[*] Found: retrofit2.HttpException
[*] Found: okhttp3.internal.connection.RouteException
[*] Found: okhttp3.internal.http2.ConnectionShutdownException
[*] Found: okhttp3.internal.http2.StreamResetException
[*] Found: com.google.firebase.perf.network.FirebasePerfOkHttpClient
```

## Analysis

Every match resolves to `com.android.okhttp.*`, the AOSP-internal OkHttp 2.x fork that backs
`HttpURLConnection`/`HttpsURLConnection` at the platform level — not a Gradle-declared
`com.squareup.okhttp3`/Retrofit dependency. This matters for where to hook next: the TLS/pinning
surface for whatever traffic is already flowing through this stack lives in
`com.android.okhttp.CertificatePinner`, `com.android.okhttp.internal.tls.{TrustRootIndex,
RealTrustRootIndex, OkHostnameVerifier}`, and the `HttpsURLConnectionImpl`/
`DelegatingHttpsURLConnection` pair — not in `okhttp3.CertificatePinner` or an
`okhttp3.Interceptor` chain, which is where a Retrofit-based app would normally be hooked (compare
[[Network-Interception]]).

The initial absence of `retrofit`/`squareup` matches was a lazy-loading artifact, not a real
absence: once the app was actually navigated (opening publications, letting content load) between
re-runs, `retrofit2.HttpException` and three `okhttp3.internal.*` classes appeared. So PressReader
runs **two** HTTP stacks side by side: the platform's `com.android.okhttp`-backed
`HttpURLConnection` (present from spawn, likely used by some framework/SDK code) and an app-level
`okhttp3`/Retrofit client (only visible once real requests start flowing) — meaning the actual
interception target for the app's own traffic is `okhttp3.OkHttpClient`/`okhttp3.Interceptor`
(compare [[Network-Interception]]), not the platform fork.

Two extra findings rode along on the same `okhttp` substring match, unrelated to the original
okhttp/retrofit/volley question: `io.grpc.okhttp.internal.*` shows PressReader also talks over gRPC
(using okhttp as its HTTP/2 transport, per grpc-java's default), a channel invisible to any hook
placed only on `okhttp3.Interceptor`/`CertificatePinner` since gRPC's request/response framing sits
above the raw HTTP/2 stream those hooks see. And `com.google.firebase.perf.network.
FirebasePerfOkHttpClient` confirms Firebase Performance Monitoring is instrumenting the app's
network calls — a wrapper layer worth being aware of if request timing looks inflated once Frida
hooks are added on top of it.

## Generalizing the pattern

To search for sibling instances of "which HTTP stack backs this traffic" in other apps or later in
this same investigation:

- Broaden the substring filter beyond `okhttp`/`retrofit`/`volley` to also catch `squareup`,
  `cronet`, `apache.http`, `urlconnection`, `ktor`, and — now confirmed relevant here — `grpc` and
  `firebase`, so those stacks are found deliberately instead of as an accidental side effect of the
  `okhttp` substring.
- Re-run enumeration **after** driving the app to the point where it actually issues a request
  (login, content fetch), not only at spawn — classes load lazily, so a spawn-time-only scan
  systematically under-reports app-level libraries. Repeating the scan across several points in the
  app's navigation (as done here, 4 runs) and watching for the match set to stabilize is a cheap way
  to build confidence that a "hasn't loaded yet" scan has caught up to reality.
- If a later scan still shows nothing beyond `com.android.okhttp`, check
  `Java.enumerateClassLoaders()` for a secondary/plugin classloader — some apps shade or dynamically
  load a networking library outside the main classloader Frida attaches to by default.

## Related concepts

- [[Network-Interception]] — the Java-layer hook targets (`CertificatePinner`, `TrustManagerImpl`
  equivalents) this enumeration is scouting for, before committing to a specific hook.
- [[Java-Layer-Hooking]] — the `Java.perform`/`Java.use` pattern this script and its eventual
  follow-up hooks are built from.
- [[Frida-Fundamentals]] — spawn (`-f`) vs. attach, and why spawn-time timing affects what
  `enumerateLoadedClasses` can see.

## Open questions / next steps

- [x] Re-run `inspect-loaded-classes.js` after logging in and opening a publication, to check
      whether `retrofit`/`squareup` classes appear once the app actually exercises its full network
      path — confirmed across runs 2-4: `retrofit2`/`okhttp3` classes load once real requests start
      flowing.
- [ ] Extend the filter with explicit `grpc`, `firebase`, `squareup`, and `cronet` substrings and
      re-run, now that gRPC and Firebase Performance Monitoring are known to be present, to catch
      the rest of each package rather than the handful of classes the `okhttp` substring happened to
      pull in.
- [ ] Set up an `okhttp3.Interceptor`/`CertificatePinner` hook (the app-level stack) as the primary
      TLS/traffic-visibility target, following [[Network-Interception]] — the platform
      `com.android.okhttp` fork is a secondary/framework-level path, not where PressReader's own
      requests go.
- [ ] Investigate the gRPC channel separately: an `okhttp3`-level hook won't decode gRPC's
      request/response framing, so this needs its own interception approach (e.g. hooking
      `io.grpc.internal.ClientCallImpl` or the generated stub methods) once a concrete gRPC-carried
      request is worth inspecting.
- [ ] Check `Java.enumerateClassLoaders()` in case a secondary classloader is hiding an app-bundled
      HTTP client not yet accounted for.

## See also

- [[Case-Studies]]
