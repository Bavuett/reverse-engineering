---
tags: [example]
level: 2
aliases: ["Java.choose", "read fields Frida", "field method name collision"]
created: 2026-11-12
---

# Example: Finding-Live-Instances-With-Java-Choose

> [!info] Level 2 — intermediate
> Instead of waiting for a method to be called, scan the heap for objects that already exist, then read and write their fields — including the case where a field and a method share a name, which obfuscated apps produce constantly.

## Goal

Use `Java.choose` to find live instances, read/write fields with `.value`, and disambiguate field-vs-method name collisions with the `_` prefix. Belongs to [[Java-Layer-Hooking]].

## Target (Java, in the app — as seen after R8)

```java
public final class c {          // a session holder, renamed
    public String a;            // auth token
    public long b;              // expiry (ms)
    public String a() { return a; }   // R8 gave the getter the same name as the field
}
```

## Script

```javascript
Java.perform(() => {
    Java.choose("com.example.session.c", {
        onMatch(instance) {
            // field 'a' collides with method 'a()': prefix the field with '_'
            const token = instance._a.value;
            const expiry = instance.b.value;                 // no collision: plain name works
            console.log(`[*] session @${instance.$h}: token=${token} expires=${new Date(expiry.valueOf())}`);

            instance.b.value = Date.now() + 365 * 24 * 3600 * 1000;   // write a field
            console.log(`[*] via method a(): ${instance.a()}`);
        },
        onComplete() {
            console.log("[*] heap scan done");
        }
    });
});
```

## Step by step

1. **`Java.choose(className, { onMatch, onComplete })`** walks the Java heap and calls `onMatch` once per live instance of that exact class. It finds objects created *before* your script was loaded — something a hook can never do.
2. **Fields are wrappers with `.value`.** `instance.b` is a field accessor; `instance.b.value` reads it and assigning `.value` writes it. Without `.value` you get the accessor object, not the data — the most common first mistake.
3. **Name collisions.** When a class has a field and a method with the same name (normal in R8 output: field `a`, method `a()`), `instance.a` resolves to the *method*. Prefix the field with an underscore: `instance._a.value`. Methods are still called normally: `instance.a()`.
4. **`long` values** come back as an Int64-like object; use `.valueOf()` (or `Number(...)`) before arithmetic with JS numbers, and remember precision is lost above 2⁵³.
5. **Cost.** A heap scan is slow and touches every object; run it once, on demand (from the REPL or an `rpc.exports` function), not in a hot hook.
6. **Choose vs hook.** `Java.choose` answers "what's the state *now*?"; a hook answers "what happens *when*…?". Investigations usually need both: choose to inspect a session object once, hook its setter to see who changes it.

## Compared with real code

PressReader's `bp.m1.m(...)` receives a renamed `Service` object whose field `j` (the user name) collides with a method `j()`. The real TypeScript agent reads both kinds of member side by side:

```typescript
if (service !== null) {
  console.log(`   f() (service name):   ${service.f()}`);   // method call
  // Both a `j` field and a `j` method exist, so we check the field using the underscore before its name.
  console.log(`   j   (user name):      ${service._j.value}`);
  // Same approach with the `k` field.
  console.log(`   k   (activation):     ${service._k.value}`);
}
```

Here the object arrives as a hook argument rather than through `Java.choose`, but the field-access rules are identical. Related real snippets: [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]], [[Enumerating-Loaded-Classes-By-Keyword]].

## See also

- [[Java-Layer-Hooking]]
- [[Hooking-A-Constructor-And-Casting-Arguments]] — `Java.cast` for objects of unknown static type
- [[Java-Perform-And-Java-Use]]
- [[Reading-A-Getter-And-Setter-Cold]] in [[Dalvik-Bytecode]] — why R8 produces field/method name pairs

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
