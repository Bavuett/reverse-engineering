---
tags:
  - case-study-note
case_study: PressReader
created: 2026-09-06
---

# Discovering the core XML protocol

## Question / goal

Every finding so far in this case study traced traffic through `okhttp3`/`FirebasePerfOkHttpClient`
(`w50.q`/`w50.a0`, `svc.pressreader.com/services/...`). Running [[inspect-stacktrace.js]] again while
navigating a different part of the app (account/device management, not catalog browsing) surfaced a
new, previously unseen frame: `bp.m1.m`. Is this another caller into the same OkHttp path, or something
structurally different?

## How this was found

The stack trace pointed at `bp.m1.m`, not at anything already mapped in
[[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] or
[[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]] — a fresh class, reached by navigating a
part of the app (account/device activation) the earlier runs hadn't exercised. Following this case
study's established static-confirmation workflow
([[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]]), the next step was opening `bp.m1` in JADX
rather than guessing from the stack trace alone.

The first read is misleading in one specific way, worth narrating as a dead end rather than skipping
past it: `bp.m1`'s constructor references `Constants.BRAZE_PUSH_NOTIFICATION_DURATION_KEY` (a Braze
SDK constant) to name a `RootElement` for SAX parsing, and the class imports `com.braze.Constants`
directly — a first glance suggests `bp.m1` might be Braze-related. It isn't: the SAX root element this
constant feeds is the literal string `"nd"` (visible directly in `f()`'s XML envelope,
`<nd version='1.0'>...</nd>`), which has nothing to do with push notifications or Braze at all. The
more consistent explanation is R8's own string-pool deduplication: when a literal's value already
exists somewhere in the app as a `public static final String`, R8 can rewrite a fresh occurrence of
that literal to reference the existing field instead of embedding a second copy of the same constant
— which means an import that looks like a real dependency can actually be nothing more than the
optimizer reusing whichever class happened to declare a matching string first. Confirming this took
one check: does `"nd"` appear anywhere in `bp.m1`'s own output independent of that import? It does,
directly in `f()`'s hardcoded fallback XML template — settling that the root tag really is `"nd"`
(almost certainly short for "NewspaperDirect", PressReader's original company name), not anything
Braze-owned.

Past that dead end, the actual shape of the class became clear from three things read together: the
constructor builds a SAX (`android.sax`) parser tree for a `<nd>` document with `<command>` and
`<response>` children; `a(String)` opens a connection via plain `java.net.URL.openConnection()`,
wrapped by `FirebasePerfUrlConnection.instrument(...)` — not `okhttp3`, and not the same
`FirebasePerfOkHttpClient` wrapper documented earlier, but its `HttpURLConnection` sibling; and `f()`
hand-assembles a complete XML request envelope as a raw string, with `%s` placeholders for a command
type and body. Put together: this is a second, independent network protocol, layered directly on
`HttpURLConnection` instead of `okhttp3`, carrying hand-built XML instead of JSON.

## Relevant source

- [[m1.java]] — decompiled (JADX) source of `bp.m1`, trimmed of method bodies not relevant to the
  protocol shape (file downloads, SAX listener wiring, the full `<client-info>` field list); pulled
  from the same `base.apk` already used in
  [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]].
- [[inspect-stacktrace.js]] — the script whose forced stack trace surfaced `bp.m1.m` as a frame worth
  investigating.

## Excerpt

```java
public static HttpURLConnection a(String str) throws ProtocolException {
    HttpURLConnection httpURLConnection = (HttpURLConnection) ((URLConnection)
        FirebasePerfUrlConnection.instrument(new URL(str).openConnection()));
    httpURLConnection.setInstanceFollowRedirects(true);
    httpURLConnection.setConnectTimeout(30000);
    httpURLConnection.setReadTimeout(30000);
    httpURLConnection.setRequestMethod("GET");
    return httpURLConnection;
}

public final String f() {
    ...
    if (!this.f8642d) {
        return "<?xml version='1.0' encoding='UTF-8'?><nd version='1.0'>"
             + "<request id='0' type='%s'>%s</request></nd>";
    }
    // ...html-encoded <client-info> block (software/version/app-version/client-type/
    // system-manufacturer/system-model/system-platform/installkey1/client-locale-*/
    // application-id/default-service-name/device-token), elided...
}
```

```
/*
 * JADX WARN: ...
 * Code decompiled incorrectly, please refer to instructions dump.
 * To view partially-correct code enable 'Show inconsistent code' option in preferences
 */
public final void m(Service service, String str, int i11, int i12) throws Throwable {
    /*
        Method dump skipped, instruction units count: 1245
        To view this dump change 'Code comments level' option to 'DEBUG'
    */
    throw new UnsupportedOperationException("Method not decompiled: bp.m1.m(...)");
}
```

## Analysis

This is not a second path into the same API — it's a structurally different protocol, and the two
coexist rather than one superseding the other:

- **Transport**: `a(String)` opens a plain `HttpURLConnection` via `java.net.URL.openConnection()`,
  instrumented by `FirebasePerfUrlConnection` — a class never seen before in this case study, distinct
  from `FirebasePerfOkHttpClient` (the wrapper every earlier finding traced through). Firebase
  Performance Monitoring evidently instruments *both* of PressReader's HTTP stacks independently, one
  wrapper per underlying API, which is worth correcting against this case study's earlier framing:
  `FirebasePerfOkHttpClient` is not "the" network instrumentation point, it's the `okhttp3`-specific
  one.
- **Payload format**: `f()`'s literal template — `<?xml version='1.0' encoding='UTF-8'?>
  <nd version='1.0'><request id='0' type='%s'>%s</request></nd>` — confirms the entire request body is
  hand-built XML, not JSON; the populated variant (elided above) fills a `<client-info>` block with
  device manufacturer/model/platform, locale, application id, and a device token, all
  `TextUtils.htmlEncode`-escaped via the class's own `i(String)` helper.
- **Purpose**: the response-side SAX listeners (`<response><error-code>`, `<error-message>`,
  `<user-activations><activation activation-number=... client-number=... client-name=...
  last-active-at=... created-at=...>`) and the request-side `<authentication><user-name>
  <activation-number><client-number>` fragment built by `e(Service)` both point at **account/device
  activation and licensing** — how many devices are activated against a subscription, not catalog
  content. That's consistent with where this trace was actually captured (device-management
  navigation), and explains why it never showed up in any earlier run: none of those exercised this
  part of the app.
- **What JADX couldn't recover**: `m()` — the method actually named in the original stack trace, and
  the one that presumably assembles `f()`'s envelope, calls `a(String)`, sends it, and hands the
  response to `k()`'s SAX parser — is too large/irregular for JADX's Java reconstruction (1,245
  instruction units, "Method dump skipped"). This is the same failure mode
  [[Reading-Raw-Dalvik]]'s own opening paragraph names as the reason to fall back to raw `baksmali`
  output: a real hardened/complex method that decompiles into Java can decompile into *nothing*
  instead, and no amount of staring at the JADX output recovers what it never produced. Reading `m()`'s
  actual body — if it's ever needed — means pulling its raw `.smali`, not asking JADX to try harder.

## Generalizing the pattern

- **Don't assume one network stack per app.** This case study had already confirmed `okhttp3` as
  PressReader's networking layer ([[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]]) before this
  note found a second, entirely separate `HttpURLConnection`-based stack coexisting with it — a stack
  trace naming an unfamiliar class is reason enough to re-open the "what transport is this" question
  from scratch, not to assume it's more of the already-mapped path.
- **An unexpected third-party import can be a false lead, not a real dependency.** `Constants.
  BRAZE_PUSH_NOTIFICATION_DURATION_KEY` looked, at a glance, like evidence `bp.m1` touches Braze; it
  was actually R8's string-constant deduplication borrowing an unrelated class's field because its
  value happened to match a literal used here. The generalizable check: does the suspected dependency's
  *behavior* show up anywhere else in the class (a Braze SDK call, a Braze-shaped side effect)? If the
  import is used exactly once, purely for its constant *value*, and that value is independently
  visible elsewhere as a plain literal (as `"nd"` is here, in `f()`), the import is very likely
  decompiler/optimizer noise, not a real relationship between the two classes.
- **When JADX gives up, that's a cue to switch tools, not to guess.** "Method dump skipped" (or
  garbled/inconsistent Java) is JADX's own admission it couldn't reconstruct a method — treating its
  absence as "probably does X" is exactly the kind of unearned confidence [[Reading-Raw-Dalvik]]'s "A
  note on honesty" section warns against; the correct move is pulling raw `baksmali` for that one
  method (or hooking it dynamically) instead of inferring from its signature and neighbors alone.

## Related concepts

- [[Static-Dynamic-Integration]] — a forced stack trace (dynamic) naming a class, then JADX (static)
  revealing its real shape, is the same two-step loop this whole case study has used since
  [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]].
- [[Reading-Raw-Dalvik]] — the fallback (raw `baksmali`, read cold) for exactly the kind of method
  JADX's Java reconstruction fails on, as `bp.m1.m` does here.
- [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]] — the earlier decompiled-source confirmation
  this note's workflow (pull, open in JADX, read the real class) directly follows.

## Open questions / next steps

- [x] Pull `bp.m1.m`'s raw `.smali` (JADX's Java reconstruction failed on it) and read it cold, per
      [[Reading-Raw-Dalvik]]'s checklist, to confirm it really does assemble `f()`'s envelope and
      dispatch it via `a(String)` — confirmed in [[Confirming-The-Outgoing-XML-Write-Path]]: `m()`
      wraps the connection's `OutputStream` in a UTF-8 `OutputStreamWriter` and writes the
      `String.format(f(), {v7, e(service)})` result directly.
- [ ] Hook `bp.m1.e(Service)` and `bp.m1.f()` directly (both fully decompiled, both plain
      String-returning methods) to dump the real, populated XML request bodies — the fastest way to
      see what this protocol actually sends without needing `m()` at all.
- [ ] Identify `lr.b` (`f8634n`, chosen between `h2`/`p2` implementations by a static A/B flag) and
      what `f8636p`/`f8635o` cache — `g(Service)` reads as a session/auth-token fetch, but neither
      candidate class was imported into this case study.
- [ ] Confirm whether this XML/`HttpURLConnection` protocol and the `okhttp3`/JSON one
      ([[Deobfuscating-Call-Chains-With-Forced-Stacktraces]]) share a base host, or whether device
      activation genuinely lives on separate infrastructure from catalog content.

## See also

- [[Case-Studies]]
