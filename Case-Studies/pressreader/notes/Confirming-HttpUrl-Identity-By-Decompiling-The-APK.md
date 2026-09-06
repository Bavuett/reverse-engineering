---
tags:
  - case-study-note
case_study: PressReader
created: 2026-09-06
---

# Confirming HttpUrl's identity by decompiling the APK

## Question / goal

[[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] ranked `w50.q` as a plausible match for
`okhttp3.HttpUrl`, but only from *behavioral* reasoning: its position in a forced stack trace
(`w50.q.i(SourceFile:5)`, called by `FirebasePerfOkHttpClient.a`) plus the fact that it's a five-line
method that does nothing but construct a `java.net.URL`. That's a strong hint, not a confirmation —
nothing about it was checked against the class's actual source. Can pulling the real APK off the
device and decompiling it settle the hypothesis for good, instead of continuing to probe it only
through Frida hooks?

## How this was found

The obvious next move after a hook-based hypothesis is to go get the ground truth: the APK itself.
The package name was already known from the very first enumeration run
([[Beginning-Enumerate-Loaded-Classes]]): `com.newspaperdirect.pressreader.android`.

**Step 1 — locate the installed APK's path on the device.**

```
adb shell pm path com.newspaperdirect.pressreader.android
```

This returns one `package:` line per split. A single `base.apk` line means a monolithic APK; several
lines (`base.apk`, `split_config.arm64_v8a.apk`, `split_config.xxhdpi.apk`, ...) mean the app was
installed as an Android App Bundle with per-ABI/per-density splits — PressReader turned out to be the
latter.

**Step 2 — pull it.** For a split install, pulling only `base.apk` risks missing resources the
decompiled Java code references, so the whole install directory was pulled instead of a single file:

```
adb pull /data/app/~~<hash>==/com.newspaperdirect.pressreader.android-<hash>==/ .
```

**Step 3 — decompile with JADX.** Dragging `base.apk` into JADX-GUI turns the DEX bytecode back into
readable (if still ProGuard/R8-renamed) Java source, browsable by package/class name rather than by
hex offsets — which is exactly what's needed to jump straight to package `w50`, class `q`, the two
identifiers named in the stack trace.

**What the decompiled source actually showed.** The class `q` in package `w50` has:

- A field layout that maps one-to-one onto `okhttp3.HttpUrl`'s real fields: `f46907a` (scheme),
  `f46908b`/`f46909c` (username/password), `f46910d` (host), `f46911e` (port), `f46912f`
  (path segments), `f46913g` (query names/values), `f46915i` (the full URL as a string).
- A nested `public static final class a` that is structurally `HttpUrl.Builder`: it accumulates the
  same fields, has a `b()` defaulting the port from the scheme (`"http"` → 80, `"https"` → 443,
  matching `TournamentShareDialogURIBuilder.scheme` being PressReader's own obfuscated alias for the
  literal string `"https"`), and a `c(q, String)` method that is HttpUrl's URL-parsing state machine
  (the giant method with all the `i11`/`iG`/`bCharAt` locals — not reproduced in full in
  [[q.java|the imported source]], since none of that parsing logic was needed to answer this
  question).
- The method actually named in the stack trace, `i()`:

  ```java
  public final URL i() {
      try {
          return new URL(this.f46915i);
      } catch (MalformedURLException e3) {
          throw new RuntimeException(e3);
      }
  }
  ```

  This is, line for line, `okhttp3.HttpUrl.url()`'s real implementation
  (`return new URL(toString())` in the actual OkHttp source, where `toString()` here also just
  returns `f46915i`). The five-line `SourceFile:5` frame from the forced stack trace and this
  three-statement method match exactly.

That combination — matching field layout, a matching nested Builder, and byte-for-byte matching
method body — moves this from "plausible guess" to "confirmed": `w50.q` **is** `okhttp3.HttpUrl`, and
`.i` **is** `.url()`.

## Relevant source

- [[q.java]] — the decompiled `w50.q` class (trimmed of the large, irrelevant URL-parsing/encoding
  method bodies not needed for this identification), pulled from PressReader's `base.apk` via JADX.
- [[inspect-stacktrace.js]] — the script whose forced stack trace originally named `w50.q.i` as the
  frame to investigate.

## Excerpt

```java
public final class q {
    public final String f46907a;  // scheme
    public final String f46908b;  // username
    public final String f46909c;  // password
    public final String f46910d;  // host
    public final int f46911e;     // port
    public final List<String> f46912f;  // pathSegments
    public final List<String> f46913g;  // queryNamesAndValues
    public final String f46914h;        // fragment
    public final String f46915i;        // the full URL, as a string
    public final boolean f46916j;       // isHttps

    public final URL i() {
        try {
            return new URL(this.f46915i);
        } catch (MalformedURLException e3) {
            throw new RuntimeException(e3);
        }
    }
}
```

## Analysis

This confirms, rather than merely supports, the earlier hypothesis, and it does so by a completely
independent method: [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] reasoned from *where* the
call happened at runtime (call-chain position); this note reasons from *what the code actually is*
(decompiled structure). The two methods agreeing is much stronger evidence than either alone — a
coincidental stack-trace position could in principle be misleading, but a byte-for-byte matching
method body cannot.

It also directly answers this case study's earlier open question ("hook `w50.q.i` directly and
inspect `this` to confirm/deny the hypothesis") without needing another Frida run at all: static
analysis settled it faster than another dynamic probe would have. The practical payoff is immediate —
since `f46915i` holds the fully-formed URL as plain text, any object of type `w50.q` (i.e. any
`okhttp3.HttpUrl`) encountered anywhere in this app, in any future Frida script, can be read directly
via that field (`obj.f46907a.value` from JS, since Frida exposes Java fields as `.value`-wrapped
accessors) instead of needing to reconstruct the URL from a stack trace side-channel.

## Generalizing the pattern

- The general move is: use a forced-stack-trace hook (or any other dynamic technique) to get a
  *ranked hypothesis* cheaply, then pull the APK and decompile once to *confirm* it — dynamic
  analysis is fast and good at narrowing the search space; static analysis is what actually settles
  identity questions with certainty.
- Three independent signals are what make a decompiled-class match convincing, and are worth checking
  in this order for any future obfuscated-class hypothesis: (1) field layout/count matches the real
  library type, (2) any nested/inner classes match the real type's own nested structure (here,
  `Builder`), (3) at least one method body is either identical to, or unmistakably a renamed
  transliteration of, the real library's known source.
- To find further well-known OkHttp/library types among PressReader's other `w50.*` (and sibling
  `x50.*`, seen imported by `w50.q` above) obfuscated classes, the same JADX package browse can be
  repeated: OkHttp's field-count/nested-class "fingerprint" for `Request`, `Response` (already
  confirmed separately as `w50.a0` — see
  [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]]), `HttpUrl.Builder`, `Headers`, and
  `RealCall` are all distinctive enough to spot by eye once you know the real source's shape.

## Related concepts

- [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] — the dynamic-analysis hypothesis this note
  confirms via decompiled source.
- [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]] — the sibling technique that confirmed
  `w50.a0` as `okhttp3.Response` dynamically, via `toString()` matching, instead of statically.
- [[Static-Dynamic-Integration]] — this note is the static half of the loop that chapter is about:
  dynamic analysis narrows down a target, static analysis (decompiling) confirms it with certainty.

## Open questions / next steps

- [ ] Repeat this JADX-based confirmation for `kh.g` (hypothesized as PressReader's own app-level
      network-service layer) and `a60.e$a` (hypothesized as OkHttp's internal async-call `Runnable`)
      from [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] — neither has been checked against
      decompiled source yet.
- [ ] Now that `w50.q`'s field `f46915i` is known to hold the plaintext URL directly, rewrite
      [[inspect-obfuscated-methods.js]] (or a new script) to hook `w50.q.i` directly and read that
      field instead of relying on the stack-trace side-channel — should be both simpler and cheaper
      per call.

## See also

- [[Case-Studies]]
