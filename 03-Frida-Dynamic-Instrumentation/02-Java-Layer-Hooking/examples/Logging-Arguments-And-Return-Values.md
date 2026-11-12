---
tags: [example]
level: 1
aliases: ["Frida Java hook basics", "log arguments Frida"]
created: 2026-11-12
---

# Example: Logging-Arguments-And-Return-Values

> [!info] Level 1 — basics
> One idea: a Java hook replaces a method with a JavaScript function that calls the original and logs what went in and what came out — the "observe without changing" hook.

## Goal

Write the smallest useful Java-layer hook, and understand each of its four parts: `Java.perform`, `Java.use`, `.implementation`, and calling the original. Belongs to [[Java-Layer-Hooking]].

## Target (Java, in the app)

```java
package com.example.auth;

public class TokenStore {
    public String buildHeader(String user, int ttlSeconds) {
        return "Bearer " + sign(user, ttlSeconds);
    }
    private native String sign(String user, int ttl);
}
```

## Script

```javascript
Java.perform(() => {
    const TokenStore = Java.use("com.example.auth.TokenStore");

    TokenStore.buildHeader.implementation = function (user, ttlSeconds) {
        console.log(`[>] buildHeader(user=${user}, ttl=${ttlSeconds})`);
        const result = this.buildHeader(user, ttlSeconds);   // call the original
        console.log(`[<] buildHeader -> ${result}`);
        return result;
    };
});
```

## Step by step

1. **`Java.perform(fn)`** runs `fn` once the script is attached to the Java VM on a thread that can use it. Every Java-layer API call goes inside it.
2. **`Java.use("…")`** returns a wrapper for the class, by its **dotted** binary name (`com.example.auth.TokenStore`; inner classes with `$`: `Outer$Inner`). It's the smali descriptor `Lcom/example/auth/TokenStore;` written differently ([[From-Smali-Signature-To-Frida-Overload]]).
3. **`.implementation = function (...)`** replaces the method for *every* caller — direct calls, virtual dispatch, reflection. Arguments arrive already converted: Java `String` → JS string, `int` → number, objects → wrappers.
4. **`this.buildHeader(...)` calls the original**, not the hook: inside an implementation, calling the method on `this` goes to the original code. Forgetting to call it (or to return its value) silently changes app behavior — fine when intended, a bug when you only meant to watch.
5. **Use `function`, not an arrow function**, so Frida can bind `this` to the Java instance.
6. **One overload only.** If the method were overloaded, `.implementation` on the bare name throws "has more than one overload"; pick one with `.overload("java.lang.String", "int")` (types written as Java source names, primitives lower-case). See [[Calling-Through-An-Overload-Without-Recursing]].

## Compared with real code

- [[Hooking-Log-And-Runtime-Exit-To-Find-The-Culprit]] — the TUA investigation's real logging hooks on `android.util.Log`, with per-overload `.overload(...)` and stack-trace dumps.
- [[Dumping-Real-Method-Signatures-Before-Hooking]] — listing a real class's overloads before writing `.overload(...)` strings.

## See also

- [[Java-Layer-Hooking]]
- [[Changing-A-Return-Value]]
- [[Java-Perform-And-Java-Use]]
- [[Methods]] in [[Dalvik-Bytecode]] — what an overload is at bytecode level

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
