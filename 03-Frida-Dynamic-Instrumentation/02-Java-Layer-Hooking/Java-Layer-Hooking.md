---
tags: [fundamentals]
aliases: ["Java.perform", "Java.use"]
created: 2026-07-28
---

# Java-Layer-Hooking

## In short

`Java.use("fully.qualified.ClassName")` gets you a JavaScript wrapper around an ART class; reassigning one of its methods' `.implementation` replaces that method's body for every future call, letting you log arguments, change the return value, or call the original (`this.methodName(...)`) from inside your replacement. This is the highest-leverage entry point into an app that isn't a Flutter/Dart-AOT one — no address hunting, no disassembly required, just the class and method names visible in [[Dalvik-Bytecode|smali]].

## Explanation

### Getting a class handle

```javascript
Java.perform(() => {
    const TargetClass = Java.use("com.example.app.LoginManager");
});
```

`Java.use` resolves the class through the app's own class loader. If the class lives in a non-default class loader (common in apps with dynamic feature modules or heavy obfuscation frameworks), plain `Java.use` fails with a `ClassNotFoundException` even though the class is loaded — `Java.enumerateClassLoaders()` plus `Java.classFactory.loader = <the right loader>` fixes that.

### Hooking a method, including overloads

A Java method name alone isn't enough when it's overloaded — Frida requires `.overload(...)` with the exact parameter type strings:

```javascript
Java.perform(() => {
    const LoginManager = Java.use("com.example.app.LoginManager");

    LoginManager.login.overload("java.lang.String", "java.lang.String").implementation = function (username, password) {
        console.log(`[*] login("${username}", "${password}")`);
        const result = this.login(username, password); // call the original implementation
        console.log(`[*] login returned: ${result}`);
        return result;
    };
});
```

Omitting `.overload(...)` only works when the method isn't overloaded; with `n` overloads Frida has no way to know which one you mean.

### Observing vs. replacing

The example above still calls through to the real implementation (`this.login(...)`) — it's a pure observer. Dropping that call and returning a value directly replaces the method's behavior entirely, which is how you patch out a check rather than just watch it:

```javascript
CertificateChecker.isValid.implementation = function (cert) {
    console.log("[*] Bypassing certificate check");
    return true; // never even runs the original logic
};
```

### Enumerating what's actually loaded

Static analysis from [[Dalvik-Bytecode]] tells you what classes *exist* in the APK; it doesn't tell you which ones are *actually instantiated* at a given moment, or what a dynamically-loaded/obfuscated class is really called at runtime. `Java.enumerateLoadedClasses({ onMatch, onComplete })` and `Java.choose("some.Class", { onMatch, onComplete })` (the latter walks the live heap for existing *instances*, not just the class definition) close that gap.

### Constructors and instance methods

`Java.use(...)` also exposes constructors as callable overloads (`TargetClass.$init.overload(...)`), and `Java.cast(anObjectPointer, TargetClass)` wraps an arbitrary object reference (e.g. one captured as a method argument) so you can call its methods or read its fields directly from the script. When static decompilation leaves parameter or return types obscured by ProGuard/R8, logging `arg.getClass().getName()` or `String(arg)` at runtime (see [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]]) and printing a forced Java stack trace via `Log.getStackTraceString(Exception.$new())` (see [[Capturing-A-Stack-Trace-From-Inside-A-Hook]] and [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]]) quickly recovers the real types and caller chain; once you have a set of target methods across several classes, driving the hooks from a declarative target table (`[{ className, methods }]`) keeps the script modular (see [[Modularizing-Hook-Targets-With-An-Array-Structure]]).

## Worked example

Log every HTTP request path going through an app's OkHttp `Interceptor` chain — the Java-layer half of what [[Network-Interception]] covers in full:

```javascript
Java.perform(() => {
    const Request = Java.use("okhttp3.Request");
    const HttpUrl = Java.use("okhttp3.HttpUrl");

    Request.url.overload().implementation = function () {
        const url = this.url();
        console.log("[*] okhttp3.Request.url() -> " + url.toString());
        return url;
    };
});
```

## More examples

Ordered from simplest to most complex, two per level: **Level 1** isolates one idea on minimal hand-written code, **Level 2** combines ideas or shows a compiler idiom, **Level 3** is real code from an analysed app, compared against its source or reconstruction.

### Level 1 — basics

- [[Logging-Arguments-And-Return-Values]] — `Java.perform`, `Java.use`, `.implementation`, and calling the original
- [[Changing-A-Return-Value]] — replacing a result outright versus calling the original and overriding it

### Level 2 — intermediate

- [[Hooking-A-Constructor-And-Casting-Arguments]] — hooking `$init` and using `Java.cast` on opaque argument/return references
- [[Finding-Live-Instances-With-Java-Choose]] — heap scans, field `.value` access, and the `_field` prefix for field/method name collisions

### Level 3 — real code

- [[Hooking-Log-And-Runtime-Exit-To-Find-The-Culprit]] — attributing a real anti-tamper crash to a Java stack in [[Tua-Case-Study]]
- [[Calling-Through-An-Overload-Without-Recursing]] — selecting one real overload and calling the original from inside it, from [[Poste-Italiane]]

### Further practice

- [[Enumerating-Loaded-Classes-By-Keyword]], [[Dumping-Real-Method-Signatures-Before-Hooking]], [[Capturing-A-Stack-Trace-From-Inside-A-Hook]], and [[Hooking-A-Lazily-Loaded-Class-With-A-Retry-Loop]] — more real snippets from [[Poste-Italiane]]
- [[Beginning-Enumerate-Loaded-Classes]], [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]], [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]], and [[Modularizing-Hook-Targets-With-An-Array-Structure]] in [[PressReader]] — class enumeration, forced stack traces, runtime argument dumping, and table-driven hooks against an obfuscated production app
- [[Frida-JS-API-Cheatsheet]] in [[Cheatsheets]] — the full `Java.*` API at a glance

## See also

- [[Java-Perform-And-Java-Use]] — complete API reference entry for `Java.perform`, `Java.use`, `.overload`, `$init`/`$new`, `Java.choose`, and `Java.cast`.
- [[Frida-Fundamentals]]
- [[Network-Interception]]
- [[Classes]] and [[Methods]] in [[Dalvik-Bytecode]] — where the class/method names and signatures you pass to `Java.use`/`.overload` actually come from.
- [[Java-Fundamentals]] — the Java class/object, `this` dispatch, and reflection mental model underlying `Java.use` and `Java.choose`.

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]

## Flashcards
#flashcards

Why does hooking an overloaded Java method require `.overload(...)`?::Frida needs the exact parameter type signature to know which of the several methods sharing that name you mean to hook; without it there's no way to disambiguate.

What's the difference between `Java.enumerateLoadedClasses` and `Java.choose`?::`enumerateLoadedClasses` lists class *definitions* the class loader knows about; `Java.choose` walks the live ART heap for actual *instances* of a given class that currently exist.

How do you fully replace a method's behavior instead of just observing it?::Assign `.implementation` to a function that never calls `this.originalMethod(...)` — just return whatever value you want the caller to see instead.
