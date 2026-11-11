---
tags: [reference, reference-entry]
category: "Java API"
created: 2026-11-11
---

# Java-Perform-And-Java-Use

## Signature / syntax

```javascript
Java.perform(fn)
Java.performNow(fn)

const Cls = Java.use(className)
Cls.methodName.implementation = function (...args) { ... }
Cls.methodName.overload(type1, type2, ...).implementation = function (...args) { ... }
Cls.methodName.overloads.forEach(ov => { ov.implementation = function (...args) { ... }; })

Cls.$init.overload(...).implementation = function (...args) { ... }
const instance = Cls.$new(...args)
const wrapped = Java.cast(handle, Cls)

Java.choose(className, { onMatch(instance) {}, onComplete() {} })
Java.enumerateLoadedClasses({ onMatch(name, handle) {}, onComplete() {} })
Java.enumerateClassLoaders({ onMatch(loader) {}, onComplete() {} })
```

## Description

`Java.perform(fn)` ensures the current native thread is attached to the Android Runtime (ART) VM and defers `fn` until the runtime is initialized and ready, whereas `Java.performNow(fn)` runs `fn` immediately once the thread is attached without waiting for full app classloader initialization. Inside that callback, `Java.use(className)` returns a JavaScript **class wrapper** for the named Java/Kotlin class using the active `Java.classFactory.loader`, exposing static fields, static methods, constructors (`$init` to hook, `$new` to allocate and construct), and instance method dispatchers. When an instance method's `.implementation` runs, `this` is bound to an **instance wrapper** representing the live receiver object (`jobject`), not the class wrapper: calling `this.methodName(...args)` from inside `.implementation` invokes the original unhooked method on that receiver, whereas calling `ov.apply(this, args)` on the hooked overload object itself re-enters the replacement and causes infinite recursion (see [[Calling-Through-An-Overload-Without-Recursing]]). Both static and instance fields are accessed through a `.value` property (`Cls.STATIC_FIELD.value` or `this.instanceField.value`) so Frida can distinguish a field named `foo` from a method named `foo()` on the same class. `Java.choose(className, callbacks)` scans the live ART heap for already-allocated instances of `className`, and `Java.cast(handle, Cls)` re-wraps an untyped or interface-typed object reference as `Cls` so subclass-specific fields and methods become accessible.

## Example

```javascript
Java.perform(() => {
    const LoginManager = Java.use("com.example.app.auth.LoginManager");
    const Token = Java.use("com.example.app.auth.Token");

    // Hook a specific overloaded method and read/write an instance field via .value
    LoginManager.authenticate
        .overload("java.lang.String", "java.lang.String")
        .implementation = function (user, pass) {
            console.log(`[*] authenticate("${user}", "${pass}"), retries=${this.retryCount.value}`);
            const rawToken = this.authenticate(user, pass); // call original implementation on `this`
            if (rawToken !== null) {
                const tokenObj = Java.cast(rawToken, Token);
                console.log(`[*] issued JWT: ${tokenObj.jwtString.value}`);
            }
            return rawToken;
        };

    // Walk the live heap for existing instances of LoginManager
    Java.choose("com.example.app.auth.LoginManager", {
        onMatch(instance) {
            console.log(`[*] Live LoginManager instance on heap: ${instance}`);
        },
        onComplete() {}
    });
});
```

## Notes

- When a method has multiple overloads, assigning `Cls.methodName.implementation` directly throws an ambiguity error listing all available signatures; always specify `.overload(type1, ...)` using JNI/Java canonical type strings (`"int"`, `"boolean"`, `"[B"` for `byte[]`, `"[Ljava.lang.String;"` for `String[]`, `"fully.qualified.ClassName"` for objects) or iterate over `Cls.methodName.overloads`.
- Inside `.implementation`, `this.$className` gives the runtime class name of the receiver, and `arg.getClass().getName()` reveals the concrete runtime class of any `java.lang.Object` or interface parameter before you pass it to `Java.cast` (see [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]]).
- If `Java.use` throws `ClassNotFoundException` for a class that is loaded by a secondary or dynamic DEX loader (such as `InMemoryDexClassLoader`), enumerate loaders with `Java.enumerateClassLoaders` or `Java.enumerateClassLoadersSync()`, find the loader where `loader.findClass(name)` succeeds, and bind it via `Java.classFactory.loader = loader` (or `Java.ClassFactory.get(loader).use(name)`).
- To capture a Java call stack from inside any hook without disturbing execution, instantiate `java.lang.Exception.$new()` and pass it to `android.util.Log.getStackTraceString(...)` (see [[Capturing-A-Stack-Trace-From-Inside-A-Hook]] and [[Deobfuscating-Call-Chains-With-Forced-Stacktraces]]).

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Frida-Dynamic-Instrumentation-Glossary|Glossary]]
- [[Frida-Fundamentals]]
- [[Java-Layer-Hooking]]
- [[Hooking-A-Constructor-And-Casting-Arguments]]
- [[Calling-Through-An-Overload-Without-Recursing]]
- [[Dumping-Real-Method-Signatures-Before-Hooking]]
- [[Enumerating-Loaded-Classes-By-Keyword]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
