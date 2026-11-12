---
tags: [example]
level: 1
aliases: ["Interceptor.replace", "replace native function"]
created: 2026-11-12
---

# Example: Replacing-A-Native-Function-With-Interceptor-Replace

> [!info] Level 1 — basics
> One idea: `Interceptor.replace` swaps a native function's entire body for a `NativeCallback` — the original never runs unless you call it yourself.

## Goal

Make a native integrity check always report success, by replacing the function rather than patching its instructions. Belongs to [[Memory-Patching-And-Code-Redirection]].

## Target (C, in the app's library)

```c
// exported from libguard.so
int verify_signature(const char *apk_path) {
    /* hashes the APK, compares with an embedded digest; returns 1 if OK, 0 if tampered */
}
```

## Script

```javascript
const target = Process.getModuleByName("libguard.so").getExportByName("verify_signature");

Interceptor.replace(target, new NativeCallback(function (apkPath) {
    console.log(`[*] verify_signature("${apkPath.readUtf8String()}") -> 1`);
    return 1;
}, "int", ["pointer"]));
```

## Step by step

1. **`NativeCallback(fn, ret, args)`** compiles a small native trampoline that calls your JS function with C-typed arguments — the same prototype notation as `NativeFunction` ([[Calling-Native-Functions-With-NativeFunction]]).
2. **`Interceptor.replace(target, callback)`** overwrites the start of `target` with a jump to the callback. Every caller — direct `bl`, PLT, function pointer — now lands in your code.
3. **The prototype must match the caller's expectation.** Returning `int` where the caller expects a pointer, or declaring too few arguments, corrupts the caller's state. Derive it from the call sites ([[Passing-Arguments-And-Return-Values]]).
4. **Replace vs attach.** `Interceptor.attach` + `retval.replace(1)` also forces the result, but the original still runs — with its side effects, its time cost, and any crash it might trigger on a tampered APK. `replace` skips it entirely.
5. **Undo** with `Interceptor.revert(target)`.
6. **Inlining defeats it.** If the compiler inlined `verify_signature` into its callers, there's nothing to replace at the call sites; you then patch the inlined check itself ([[Forcing-A-Conditional-Branch-With-PatchCode]]).

## Compared with real code

- [[Filtering-Proc-Self-Maps-Through-A-Libc-Fgets-Hook]] — a real native hook where *calling* the original (`fgets`) and editing its output was safer than replacing it.
- [[Neutralizing-A-Hidden-Check-With-A-No-Op-Implementation]] — the Java-layer equivalent of a full replacement, on a real hidden check.

## See also

- [[Memory-Patching-And-Code-Redirection]]
- [[Calling-The-Original-From-A-Replacement]]
- [[Interceptor-Attach-And-Replace]]
- [[NativeFunction-And-NativeCallback]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
