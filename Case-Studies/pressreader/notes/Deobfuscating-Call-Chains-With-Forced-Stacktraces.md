---
tags:
  - case-study-note
case_study: PressReader
created: 2026-09-05
---

# Deobfuscating call chains with forced stack traces

## Question / goal

PressReader's own code is obfuscated (ProGuard/R8-style: classes and methods renamed to short,
meaningless identifiers like `w50.q.i`, `kh.g.b`, `a60.e$a`). [[Beginning-Enumerate-Loaded-Classes]]
already found that a non-obfuscated third-party class, `com.google.firebase.perf.network.
FirebasePerfOkHttpClient`, sits somewhere in the app's network path — but its own method names are
also obfuscated (`.a`), so knowing the class exists doesn't yet say which obfuscated app classes
call it, or what they do. How do you map out an obfuscated call chain around a known anchor point
without decompiling the app first?

## How this was found

`FirebasePerfOkHttpClient.a` looked like the obvious hook target at first — it's the one method name
we can actually read off the earlier enumeration. But hooking it directly has a problem: without
decompiling, its overload signature and parameter types are unknown, so writing a correct
`Interceptor.attach`/`.implementation` for it means guessing. A more reliable anchor is a method
that's never renamed because it belongs to the Android platform itself and every reflective/dynamic
caller still has to invoke it by its real name: `java.net.URL`'s constructor. Any code path in the
app that eventually turns a URL string into a real HTTP request — regardless of how many obfuscated
wrapper layers sit above it — has to construct one somewhere, so hooking `URL.$init(String)` is
guaranteed to catch it.

The problem then becomes: hooking the constructor only tells you a URL was created and its string
value — the immediate call stack frame at that point is inside `java.net.URL` itself, which says
nothing about *who* called it. What's actually needed is the full call stack at the moment of
construction. Frida doesn't expose a one-line Java call-stack walker, but there's a well-known
trick: constructing a `java.lang.Exception` captures its stack trace at construction time (the JVM
records it when the `Throwable` is built, not when/if it's thrown), so `Exception.$new()` can be
used purely to harvest a trace without ever throwing anything. Converting that captured trace to
readable text reuses `android.util.Log.getStackTraceString()` — the same internal Android formatting
routine `logcat` uses for real uncaught exceptions — so the printed output looks exactly like a
crash report, though nothing crashed.

One more issue self-corrected during testing: hooking every `URL` construction unfiltered produced
heavy spam from classloader/resource-loading activity (`jar:`/`file:`-scheme URLs from the app
reading its own resources). Filtering those two prefixes out of `printStackTrace()` left only
genuine network-bound URLs.

Running the script while opening PressReader's "Games" section produced a batch of stack traces; one
of them anchors directly through `FirebasePerfOkHttpClient.a`, which is the one worth keeping here.

## Relevant source

- [[inspect-stacktrace.js]] — hooks `java.net.URL.$init(String)`, and on each real network URL
  (`jar:`/`file:` filtered out) fabricates a throwaway `java.lang.Exception` purely to read its
  stack trace via `Log.getStackTraceString()`, printing it framed between separator lines.

## Excerpt

```
[?] Someone prepared this URL:
https://svc.pressreader.com/services/games/v1/titles/40013/issues?accessToken=psyoKqCRdEpcFQARL629Csvm1rS35lZbMbc4lf1
s8UG4lw0tNMf5h81fuz6eOTenXWO8hMno4RDPgAonn3RUgpMmxKxXePNyRyrgYRaGf9w%21&limit=1
java.lang.Exception
    at java.net.URL.<init>(Native Method)
    at w50.q.i(SourceFile:5)
    at com.google.firebase.perf.network.FirebasePerfOkHttpClient.a(SourceFile:8)
    at kh.g.b(SourceFile:12)
    at a60.e$a.run(SourceFile:104)
    at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
    at java.lang.Thread.run(Thread.java:1571)
```

## Analysis

A Java stack trace lists frames innermost-first, so reading top to bottom walks *outward* from the
hook point to whoever ultimately triggered it. `FirebasePerfOkHttpClient` is the one class in this
trace we can actually name — every frame around it is obfuscated, but its known, undisguised
position in the chain lets us reason about what each anonymous neighbor is probably doing, without a
decompiler:

- **`w50.q.i(SourceFile:5)`** calls `URL.<init>` directly and does nothing else visible (a
  five-line source file). The only well-known OkHttp method that does exactly this — take an
  already-built URL object and produce a `java.net.URL` from it — is `okhttp3.HttpUrl.url()`
  (`return new URL(toString())` in the real library source). `w50.q` is a strong candidate for
  `okhttp3.HttpUrl`, and `.i` for its `url()` method.
- **`FirebasePerfOkHttpClient.a(SourceFile:8)`** calls `w50.q.i`. This matches
  `FirebasePerfOkHttpClient`'s real, known behavior: it wraps `Call.execute()`/`enqueue()` and
  internally reads `request.url()` to populate its `NetworkRequestMetricBuilder` before delegating
  to the real OkHttp call — `.a` is consistent with being that wrapped `execute()`/`enqueue()` entry
  point.
- **`kh.g.b(SourceFile:12)`** calls into the Firebase-wrapped OkHttp client. This is most likely
  PressReader's own (obfuscated) network-service layer — the app-level code that decided to call
  `titles/{id}/issues` with an `accessToken` — but nothing in this single trace pins down more than
  "some app-level caller".
- **`a60.e$a.run(SourceFile:104)`** is an inner/anonymous class (`$a`) whose `run()` calls `kh.g.b`,
  and is what the `ThreadPoolExecutor` frames below it actually execute. That shape —
  a `Runnable` inner class queued onto an executor, wrapping a network call — matches OkHttp's own
  dispatch pattern (`RealCall`'s internal async-call `Runnable`, submitted to
  `Dispatcher`'s `ExecutorService`), suggesting `a60.e` corresponds to OkHttp's own call/dispatch
  machinery rather than more app code.

None of these class identities are confirmed by decompilation — they're hypotheses built purely from
position in the call chain plus knowledge of what OkHttp/Firebase Perf's real source does at each
step. That's the actual value of the technique: it turns "everything is named `a`, `b`, `i`" into "a
short list of plausible real identities, ranked by how well their behavior matches a known library",
which is a much smaller problem than reading the whole obfuscated codebase.

## Generalizing the pattern

The reusable technique here isn't specific to `URL` or to Firebase — it's "hook a name that
obfuscation can't touch, and let a synthetic stack trace expose everyone standing on top of it":

- Any always-present platform API works as the anchor: `java.net.URL.<init>`, `okhttp3.Request$Builder.build`
  (if `okhttp3` symbols survive, as seen in [[Beginning-Enumerate-Loaded-Classes]]),
  `SQLiteDatabase.execSQL`, `SharedPreferences.Editor.putString`, or any Google/AndroidX SDK class
  kept intact by default ProGuard/R8 keep-rules (Firebase, Play Services, WorkManager, ...) — these
  are usually the easiest anchors because their own method names, not just the class name, are often
  also preserved.
- The `Exception.$new()` + `Log.getStackTraceString()` combo generalizes directly to any hook: wrap
  it in the same `printStackTrace(message)` helper and call it from inside any
  `Interceptor.attach`/`.implementation`, whenever the goal is "who called this" rather than "what
  arguments did it get".
- Once one obfuscated identity is inferred this way, hooking that specific obfuscated method
  directly (now with a plausible guess at its real behavior to test against) is the natural next
  step — e.g. hooking `w50.q.i` and confirming its `this` object stringifies like an `HttpUrl` would
  validate the `HttpUrl.url()` hypothesis above.

## Related concepts

- [[Static-Dynamic-Integration]] — this technique is exactly that chapter's theme: using a dynamic
  probe (a forced stack trace) to shortcut what would otherwise require decompiling and reading
  obfuscated bytecode by hand.
- [[Java-Layer-Hooking]] — the `Java.use`/`.implementation` and constructor-overload hooking pattern
  this script is built from.
- [[Network-Interception]] — once the real OkHttp call site is deobfuscated, this is the chapter for
  turning that into full request/response capture.

## Open questions / next steps

- [x] Confirm/deny the `w50.q` = `okhttp3.HttpUrl` hypothesis — settled by decompiling the APK
      instead of hooking `w50.q.i` directly, see
      [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]].
- [ ] Capture a few more traces through different app screens to see whether `kh.g.b` is a single
      shared network-service entry point or one of several per-feature callers.
- [ ] Cross-reference `a60.e$a` against [[Beginning-Enumerate-Loaded-Classes]]'s confirmed
      `okhttp3` classes (e.g. `okhttp3.internal.connection.RouteException` already seen loaded) to
      see if OkHttp's real internal class names for the async-call/dispatcher pattern are still
      present anywhere unobfuscated.

## See also

- [[Case-Studies]]
