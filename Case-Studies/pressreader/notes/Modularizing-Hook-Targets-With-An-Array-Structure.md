---
tags:
  - case-study-note
case_study: PressReader
created: 2026-09-06
---

# Modularizing hook targets with an array structure

## Question / goal

`inspector.ts` (the TypeScript rewrite of [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]]'s
argument-dumping technique, now living in the private `rev-eng-art` artifacts repo) hardcodes a single
hook target — one `className`, one `methodName` — plus a hardcoded field-type signature (`"w50.q"`) it
searches for inside whatever it hooks. The case study's own open questions already call for repeating
this exact technique against `kh.g` and `a60.e$a`
([[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]]), and possibly further candidates later. Does
the script's current one-target shape scale to that, or does it need restructuring first?

## How this was found

Reading `inspector.ts` end to end shows it already went through one round of cleanup from the plain-JS
version it replaces: the target class/method are pulled out into a `Target` object

```ts
const Target = {
  className: `com.google.firebase.perf.network.FirebasePerfOkHttpClient`,
  methodName: `a`
}
```

instead of being inlined as string literals the way the original `inspect-obfuscated-methods.js` did —
so every log line and the `Java.use(...)` call reads `Target.className`/`Target.methodName` rather than
repeating the literal. That's real progress, but it only removes duplication *within* one hook
installation; adding a second target still means copy-pasting the entire `Java.use` /
`.overloads.forEach` / `.implementation` block a second time, verbatim, with only the two `Target`
fields differing. The script also grew a second capability beyond argument dumping since the last
version reviewed in this case study: after printing an argument's class and `toString()`, it now reads
that class's own declared fields via reflection (`ArgClassWrapper.class.getDeclaredFields()`) and flags
any field whose *declared type* is `w50.q` — automating exactly the manual step
[[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]] did by hand (reading JADX output to find which
field of `w50.a0`/`Response`-shaped objects holds the URL). That signature (`"w50.q"`) is just as
hardcoded as `Target` was before the `Target` object existed.

Both hardcoded values — which method to hook, and which field type is interesting once hooked — are
the same *kind* of problem: single values standing in for what should be a list, because the script was
written to answer one specific question (`FirebasePerfOkHttpClient.a`'s arguments) before the
investigation had more than one open target.

## Relevant source

- `inspector.ts` — lives in the private `rev-eng-art/pressreader/source/` artifacts repo (not the
  public vault's `Case-Studies/pressreader/source/`, which still has an earlier, Italian-language
  version of the same idea); reviewed here in its current state, not modified by this note.

## Excerpt

```ts
Java.perform(() => {
  const Target = {
    className: `com.google.firebase.perf.network.FirebasePerfOkHttpClient`,
    methodName: `a`
  }

  console.log(`[*] Starting Dynamic Inspection to ${Target.className}.${Target.methodName}()`);

  const TargetClass = Java.use(Target.className);

  TargetClass[Target.methodName].overloads.forEach((overload: any) => {
    overload.implementation = function(this: any) {
      // ...argument dump + reflection-based field-type search, unchanged by this note...
      return overload.apply(this, arguments as any);
    };
  });
});
```

## Analysis

Turning `Target` from a single object into an array of targets, and looping the existing hook-install
logic over it, generalizes the script without changing what each individual hook does:

```ts
const Targets = [
  { className: `com.google.firebase.perf.network.FirebasePerfOkHttpClient`, methodName: `a` },
  { className: `kh.g`, methodName: `b` },
  { className: `a60.e$a`, methodName: `run` },
];

Java.perform(() => {
  Targets.forEach((Target) => {
    console.log(`[*] Starting Dynamic Inspection of ${Target.className}.${Target.methodName}()`);
    const TargetClass = Java.use(Target.className);

    TargetClass[Target.methodName].overloads.forEach((overload: any) => {
      overload.implementation = function (this: any) {
        // identical body: argument dump + reflection-based field-type search
        return overload.apply(this, arguments as any);
      };
    });
  });
});
```

This is the direct payoff for this case study's still-open hypotheses: `kh.g.b` and `a60.e$a.run` are
exactly the two classes [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]] named but never confirmed
(unlike `w50.q`, settled statically in
[[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]]) — adding them to `Targets` costs two lines,
where copy-pasting the current single-target script would cost the whole hook-install block per class,
and would silently drift (a bug fixed in one copy, forgotten in the others — precisely the kind of
divergence [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]]'s round-3 firebase-file merge
had to reconcile by hand for this exact script's ancestor).

The same generalization applies one level down, to the hardcoded `"w50.q"` field-type signature inside
the hook body: once more than one obfuscated type has been statically confirmed (as further
`Confirming-*-Identity` notes accumulate), that single string should become an array too —
`KnownTypes = ["w50.q", ...]` — so the reflection-based field scan reports a match against *any*
confirmed type passing through a hooked method's arguments, not only the one type known when this
version of the script was written. The two generalizations are independent and additive: the outer
array decides *which methods* to hook, the inner array decides *what to flag* once hooked.

## Generalizing the pattern

- Any Frida script whose body is "the same hook-install logic, once per class/method pair" is a
  candidate for this exact array-of-targets restructuring — `Case-Studies/tua/source/combined.js`'s
  `HIDDEN_CHECKS.forEach(...)` (documented in
  [[Reading-Raw-Dalvik]]'s patch 5) already uses precisely this shape for a *different* case study's
  batch root-check neutralization, which is independent confirmation this is a reusable idiom in this
  vault's own scripts, not a one-off idea specific to PressReader.
- The general test for "should this be an array": does the script currently answer one instance of a
  question this investigation has already asked more than once (one hook target, one type signature),
  where every other instance would require copy-pasting rather than reusing code? If yes, the hardcoded
  value belongs in a list the script iterates, not inline in the hook body.
- The known call-through bug from
  [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]] (`overload.apply(...)` throwing
  `TypeError: not a function`; the fix is `this[Target.methodName].apply(this, arguments)`) is still
  present in this script's current call-through line (`return overload.apply(this, arguments as any);`)
  — worth fixing whenever this script is next touched for a functional reason, alongside the
  array restructuring, though this note only documents the restructuring possibility, not the fix
  itself.

## Related concepts

- [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]] — the single-target argument-dumping
  technique this script's `Target` object already builds on, including the call-through bug still
  present here.
- [[Confirming-HttpUrl-Identity-By-Decompiling-The-APK]] — the manual field-hunting process this
  script's reflection-based `getDeclaredFields()` scan automates for `w50.q`, and the source of the two
  concrete next targets (`kh.g`, `a60.e$a`) this note's array proposal is meant to unblock.
- [[Java-Layer-Hooking]] — the `Java.use`/`.overloads`/`.implementation` pattern every entry in a
  `Targets` array would still individually rely on.

## Open questions / next steps

- [ ] Actually implement the `Targets` array in `rev-eng-art`'s `inspector.ts` (this note documents the
      shape as a possibility; the script itself is unchanged) and add `kh.g.b` / `a60.e$a.run` as the
      next two entries.
- [ ] Decide whether the inner "known type signatures to flag" list should be confirmed-only (`w50.q`
      alone, today) or also carry unconfirmed hypotheses worth watching for, clearly distinguished from
      the confirmed ones in the log output.

## See also

- [[Case-Studies]]
