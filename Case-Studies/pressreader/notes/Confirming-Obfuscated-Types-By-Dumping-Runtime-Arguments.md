---
tags:
  - case-study-note
case_study: PressReader
created: 2026-09-06
---

# Confirming obfuscated types by dumping runtime arguments

## Question / goal

[[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] produced *hypotheses* about what a few
obfuscated classes around `FirebasePerfOkHttpClient.a` really are (e.g. `w50.q` guessed as
`okhttp3.HttpUrl`), inferred purely from call-chain position — never confirmed against a live
object. Can we go one step further and ask the running JVM directly: for a real call to
`FirebasePerfOkHttpClient.a`, what are the actual runtime classes of its arguments?

## How this was found

The starting script (`inspect-obfuscated-methods.js`) had two rounds of real bugs, both only
surfaced by actually running it — worth narrating in full since each one is a generic Frida gotcha,
not a PressReader-specific quirk.

**Round 1 — the script never ran at all.** As handed over, the script had: a typo in the class name
(`FireBasePerfOkHttpClient` instead of `FirebasePerfOkHttpClient`), a `forEach` over
`FirebaseClient.a.overloads` that only logged static setup messages instead of ever assigning
`.implementation` (so nothing was actually hooked), references to undefined `arg`/`arguments`
variables outside any function scope, and mismatched braces from a `try`/`catch` that didn't
actually wrap the logic it was supposed to guard. None of this could run — it was fixed by (1)
correcting the class name, (2) moving the argument-inspection logic inside a real
`overload.implementation = function () {...}` assigned per overload, (3) reading arguments off the
real `arguments` object inside that function, and (4) rebalancing the `try`/`catch` around the setup
code.

**Round 2 — it ran, but crashed on the call-through.** With round 1's fixes in place, running the
script against PressReader actually intercepted a real call: it printed both arguments' runtime
classes and values correctly, and only then crashed with `TypeError: not a function`. Since the
crash happened *after* both arguments printed successfully, it wasn't in the argument-dumping loop
— it was the very next line, the call-through to the original implementation:
`return overload.apply(this, arguments);`. The `overload` variable here is the element read out of
`FirebaseClient.a.overloads` *before* any `.implementation` was assigned to it — once you hook that
overload, that captured reference is no longer a usable call-through handle (attempting to
`.apply()` it directly throws, rather than delegating to the original Java implementation). The
working idiom — matching Frida's own documented pattern for calling an original implementation from
inside a replacement (e.g. `this.onResume()` inside an `onResume` hook) — is to call through via the
class-level dispatcher accessed fresh off `this`: `this.a.apply(this, arguments)`. Frida resolves
that JS-side call back to the original Java implementation rather than re-entering the JS hook,
which is exactly what a bare reference to the pre-hook `overload` object apparently doesn't do here.

With both fixes applied, the script ran end to end: it printed argument types/values for every real
call to `a()` without breaking the app's own networking (confirmed by the app continuing to load
content normally afterward).

## Relevant source

- [[inspect-obfuscated-methods.js]] — hooks every overload of `FirebasePerfOkHttpClient.a`, dumps
  each argument's real runtime class (`arg.getClass().getName()`) and `toString()` value, then calls
  through to the original implementation via `this.a.apply(this, arguments)`.

## Excerpt

```
[!] Intercepted call to FirebasePerfOkHttpClient.a()
   [+] Argument 0 is of type w50.a0
   [+] Value: Response{protocol=h2, code=200, message=, url=https://svc.pressreader.com/services/track/pageview?accessToken=...}
   [+] Argument 1 is of type ih.b
   [+] Value: ih.b@d970eb9
```

(from the pre-fix run, immediately followed by the `TypeError: not a function` crash described
above, on what was then the call-through line)

## Analysis

`w50.a0`'s dumped value — `Response{protocol=h2, code=200, message=, url=...}` — is not a generic
`toString()`, it's the *exact*, distinctive format `okhttp3.Response.toString()` produces
(`"Response{protocol=" + protocol + ", code=" + code + ", message=" + message + ", url=" + url +
"}"` in the real OkHttp source). That's a confirmation, not a guess: `w50.a0` **is**
`okhttp3.Response`, reached here as the first argument `FirebasePerfOkHttpClient.a` receives — fully
consistent with [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]]'s finding that this method
wraps the real OkHttp call and needs the response to record its metric.

`ih.b`'s value — `ih.b@d970eb9`, the default `Object.toString()` format (`getClass().getName() + "@"
+ Integer.toHexString(hashCode())`) — means this class does **not** override `toString()`. That's
itself a signal: a class with no custom `toString()` is usually an internal state/builder object
rather than something meant to be logged or displayed, consistent with it being Firebase Perf's own
`NetworkRequestMetricBuilder`-equivalent (an accumulator object passed alongside the response to
record timing/size metrics) rather than anything from OkHttp itself.

## Generalizing the pattern

- Argument dumping (`getClass().getName()` + `toString()`) is a fast way to *confirm* a hypothesis
  formed from a stack trace alone (as in
  [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]]) — a distinctive `toString()` format (like
  OkHttp's `Response{...}`) can positively identify a class even fully renamed, without decompiling.
  A class whose `toString()` is the default `Object` format is itself informative: it signals "not a
  library type meant to be inspected", narrowing the search to internal accumulator/builder-shaped
  types.
- The call-through bug generalizes beyond this script: **whenever hooking one specific overload out
  of `Class.method.overloads`, call through via `this.<methodName>.apply(this, arguments)` (or
  `this.<methodName>(...)` if arity/types disambiguate cleanly), never via the `overload` reference
  captured before `.implementation` was assigned** — that reference isn't a valid original-call
  handle once hooked.
- To find sibling instances of the "typo'd/mis-wired hook that looks plausible but silently does
  nothing (or crashes on first real call)" failure mode elsewhere in this project's other scripts:
  grep for every `.implementation = function` in `source/` and confirm each one (a) is assigned
  inside the correct scope, and (b) ends with an explicit call-through matching this class-level
  dispatcher pattern rather than reusing a pre-hook method reference.

## Related concepts

- [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] — the hypotheses this note confirms against
  live runtime objects instead of call-chain position alone.
- [[Java-Layer-Hooking]] — overloaded-method hooking and the call-through idiom this bugfix is
  built from.
- [[Static-Dynamic-Integration]] — using a dynamic probe (argument dumping) to validate what would
  otherwise require decompiling obfuscated bytecode.

## Open questions / next steps

- [ ] Trigger and capture an overload of `a()` with a different argument count/types (the crash
      suggests other overloads exist — worth deliberately exercising them, e.g. by triggering an
      error response, to see the full overload surface).
- [ ] A parallel run of [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]]'s stack-trace script
      alongside this one surfaced two signals worth a dedicated look later: a `dq.pressreader.com`
      analytics/beacon endpoint reached via a `ScheduledThreadPoolExecutor` chain (`bp.m1`/`gt.t`/
      `a10.p`/`l00.w`), and Braze SDK traffic (`sdk.iad-0{1,6}.braze.com`, via the unobfuscated
      `bo.app.*`/`com.braze.*` packages) — a push-notification/engagement SDK not previously
      accounted for in [[Beginning-Enumerate-Loaded-Classes]]'s network-stack survey.

## See also

- [[Case-Studies]]
