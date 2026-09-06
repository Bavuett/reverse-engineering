---
tags:
  - case-study-note
case_study: PressReader
created: 2026-09-06
---

# Hooking the core XML API methods directly

## Question / goal

[[Discovering-The-Core-XML-Protocol]] left two concrete open items: hook `bp.m1.e(Service)`/
`bp.m1.f()` to see real, populated XML request bodies instead of the literal template alone, and find
some way to observe `bp.m1.m()` — the method that actually sends them — even though JADX couldn't
decompile its body at all. Does hooking work on `m()` despite that, and what does hooking all three
methods together look like?

## How this was found

Frida hooks compiled Dalvik bytecode directly, through `Java.use(...)`/`.implementation`, never through
JADX's Java reconstruction — so `m()`'s "Method dump skipped" failure (documented in
[[Discovering-The-Core-XML-Protocol]]) only blocks *reading* the method statically, not *hooking* it
dynamically. `inspect-api.ts` acts on exactly that distinction: it hooks all three methods identified
statically in the previous note — `e`, `f`, `m` — treating `e`/`f` as fully known (log the return
value, since both are already read as XML-string builders) and `m` as a black box worth instrumenting
purely for its call arguments and calling context, since its body can't be read any other way.

The script's own header comment restates the findings from [[Discovering-The-Core-XML-Protocol]]
directly (PressReader's core API goes through `bp.m1` via `HttpURLConnection`, not `okhttp3`; `e`/`f`
build XML; `m` is the unrecovered "engine" of the request) — worth noting because it shows the design
carrying forward correctly from the static-analysis note into the dynamic-hooking script, rather than
each investigative step starting from scratch.

## Relevant source

- [[inspect-api.ts]] — developed in the private `rev-eng-art/pressreader/source/` artifacts repo, now
  synced into this case study's own `source/`; hooks `bp.m1.e`, `bp.m1.f`, and `bp.m1.m`.
- [[m1.java]] — the decompiled `bp.m1` class this script targets; see
  [[Discovering-The-Core-XML-Protocol]] for how it was found and read.

## Excerpt

```ts
const Target = {
  className: `bp`,
  methodName: `m1`
}

var CoreApi = Java.use(`${Target.className}.${Target.methodName}`);

CoreApi.f.implementation = function () {
  var XmlPayload = this.f();
  printStackTrace(`[+] Payload generated from method f...\n${XmlPayload}`);
  return XmlPayload;
};

CoreApi.e.implementation = function (serviceObj: any) {
  var xmlPayload = this.e(serviceObj);
  printStackTrace(`[+] Payload generated from method e...\n${xmlPayload}`);
  return xmlPayload;
}

CoreApi.m.implementation = function (serviceObj: any, stringParam: any, int1: any, int2: any) {
  var message = `[+] Calling API (Method m).
      [*] Parameter (URL or data): ${stringParam}
      [*] Parameter (int1): ${int1}
      [*] Parameter (int2): ${int2}`
  printStackTrace(message);
  return this.m(serviceObj, stringParam, int1, int2);
}
```

## Analysis

Three design choices worth calling out, two of them correct and reused deliberately, one worth a small
fix later:

- **Call-through is done right.** Every hook here calls through via `this.<methodName>(...)` — `this.f()`,
  `this.e(serviceObj)`, `this.m(serviceObj, stringParam, int1, int2)` — never through a pre-hook
  reference the way the original, buggy `inspect-obfuscated-methods.js` did. This is exactly the fix
  [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]] had to discover the hard way (a real
  `TypeError: not a function` crash); seeing it applied correctly from the start here is a sign the
  fix generalized past the one script it was found in.
- **Direct `.implementation` assignment, no `.overloads.forEach`.** Unlike every earlier hooking script
  in this case study, `CoreApi.f`/`.e`/`.m` are assigned an `.implementation` directly, with no
  `.overloads` indirection at all. This is valid Frida usage specifically *because* [[m1.java]] shows
  each of `e`, `f`, and `m` has exactly one overload in `bp.m1` — Frida only requires the
  `.overloads`/`.overload(...)` disambiguation when a method name is ambiguous. It's a real
  simplification over [[Modularizing-Hook-Targets-With-An-Array-Structure]]'s `Targets` array proposal,
  not an oversight — but it does mean this particular shortcut wouldn't survive being folded into that
  array unchanged, since a general-purpose "hook every target in this list" loop can't assume every
  target has exactly one overload without checking first.
- **`m()` is hooked purely for arguments and call context, not for its return value or any decoded
  internals.** Since JADX never recovered a body for `m()`, there's nothing to *decode* about what it
  does internally — the hook logs its four parameters (the `Service`, a `String` that's "likely the
  URL or the XML payload" per the script's own comment, and two `int`s) and a forced stack trace, which
  is exactly the ceiling of what's knowable about an undecompiled method without reading its raw
  `.smali` directly, per [[Reading-Raw-Dalvik]].

One naming inconsistency worth flagging, purely cosmetic: `Target.methodName` here actually holds `m1`,
the nested class's simple name, not a method name — a different use of the same field name than
[[Modularizing-Hook-Targets-With-An-Array-Structure]]'s `inspector.ts`, where `Target.methodName` really
is a method. Harmless in an isolated script, but worth reconciling if `inspect-api.ts`'s targets are
ever merged into that note's proposed `Targets` array alongside `inspector.ts`'s.

## Generalizing the pattern

Hooking an undecompiled method purely for its call signature and stack context — no attempt to read or
guess its internals — is the general answer to "JADX gave up on this method" whenever the method is at
least reachable and instrumentable at runtime: static reading recovers *what a method's shape suggests
it does*, while a bare argument-and-caller hook recovers *when it's called and with what*, which is
sometimes enough on its own (e.g. confirming *that* `m()` fires once per XML request, and correlating
its `stringParam` argument with the payload just built by `e`/`f`) without ever needing the body at all.

## Related concepts

- [[Discovering-The-Core-XML-Protocol]] — the static analysis this script's own header comment and
  target selection are built directly from.
- [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]] — origin of the call-through idiom this
  script correctly reuses.
- [[Reading-Raw-Dalvik]] — the static fallback (raw `.smali`) for whatever this dynamic hook alone
  can't recover about `m()`'s internals.

## Open questions / next steps

- [ ] Actually run `inspect-api.ts` against the app and capture real console output — this note
      documents the script's design, not yet any observed result, since no real run has been captured
      for it.
- [ ] Once real output exists, check whether `bp.m1.m`'s `stringParam` argument is the full XML request
      body (from `e`/`f`) or something else (e.g. only the URL, with the body passed differently) —
      the script's own comment already flags this as unconfirmed ("likely the URL or the XML payload").
## See also

- [[Case-Studies]]
