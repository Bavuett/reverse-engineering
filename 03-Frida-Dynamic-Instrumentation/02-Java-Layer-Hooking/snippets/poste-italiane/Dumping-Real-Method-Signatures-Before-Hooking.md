---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "one-shot Frida enumeration scripts, not app source"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Dumping-Real-Method-Signatures-Before-Hooking

## Context

[[Java-Layer-Hooking]] notes that `.overload(...)` needs the exact parameter type strings — this snippet is how those exact strings were actually obtained, every time, rather than guessed from a library's public docs or assumed from a similar app. Two hooks in this case study (the platform `android.security.net.config.NetworkSecurityTrustManager` and the bundled `com.nimbusds.jose.JWEObject`) were written *after* confirming their real signatures this way — both turned out to matter: `NetworkSecurityTrustManager.checkServerTrusted` has both `void`- and `List`-returning overloads that need different return-value handling, and `JWEObject.encrypt`/`.decrypt` are both `void`, mutating the object's state as a side effect rather than returning anything — not obvious from the class name alone.

## Original path

`` one-shot enumeration scripts, run via frida -U -p <pid> -l script.js -q -t <N> ``

## Snippet

```javascript
Java.perform(function () {
    const C = Java.use("fully.qualified.ClassName");
    C.class.getDeclaredConstructors().forEach(function (c) { console.log(c.toString()); });
    C.class.getDeclaredMethods().forEach(function (m) {
        const s = m.toString();
        if (s.indexOf("methodNameFragment") !== -1) console.log(s);
    });
});
```

### Example 1 — `com.nimbusds.jose.JWEObject`

```
public synchronized void com.nimbusds.jose.JWEObject.decrypt(com.nimbusds.jose.JWEDecrypter) throws com.nimbusds.jose.JOSEException
public synchronized void com.nimbusds.jose.JWEObject.encrypt(com.nimbusds.jose.JWEEncrypter) throws com.nimbusds.jose.JOSEException
```

Both `void` — meaning the hook has to read the plaintext `Payload` off `this` (via the separately confirmed `com.nimbusds.jose.JOSEObject.getPayload()`) rather than from a return value, and *when* to read it differs by direction: before calling through for `encrypt()` (the payload is the input), after for `decrypt()` (decryption is what populates it). See [[Decrypting-JWE-Request-Response-Bodies]] for the full hook this fed into.

### Example 2 — `android.security.net.config.NetworkSecurityTrustManager`

```
public java.util.List checkServerTrusted(X509Certificate[], String, String)
public void checkServerTrusted(X509Certificate[], String)
public void checkServerTrusted(X509Certificate[], String, Socket)
public void checkServerTrusted(X509Certificate[], String, SSLEngine)
```

Four overloads, split between `void` and `List`-returning — a mixed case `.overload(...)`-per-signature would handle correctly one at a time, but `.overloads.forEach(...)` handles all at once, checking each one's own `returnType.className` inside the shared implementation (see [[Stacking-Five-Independent-Pinning-Bypasses]] for the actual hook built from this dump). Without this dump first, a hook written against just the single-`String`-arg `void` overload (the most commonly documented one in write-ups of this class) would have silently left the other three call sites unpatched.

### Example 3 — `com.android.org.conscrypt.TrustManagerImpl` (a negative result, ruling something out)

```
private java.util.List verifyChain(java.util.List, java.util.List, java.lang.String, boolean, byte[], byte[])
```

Exactly one overload — dumping this *confirmed* the existing single-overload hook on `verifyChain` already covered everything this class exposes, which mattered because two specific hosts were still failing TLS validation at the time this was run: it ruled out "a missed `TrustManagerImpl` overload" as the explanation before looking elsewhere, which is what led to Example 2 above and the discovery of a second, independent trust-manager class entirely.

## Notes

- Kotlin-compiled classes add heavy noise here: every `suspend`/inline lambda generates a synthetic class named `Outer$methodName$N`. Filtering `.toString()` for entries *without* a `$` in the method name cuts straight to a class's own directly-declared methods — used when dumping `it.posteitaliane.df_sessionmanager.LoginViewModel`'s real error-handling surface for [[login-diagnostics.js]].
- `getDeclaredMethods()` (not `getMethods()`) is the right call specifically because it includes `private`/package-private methods too — several of the interesting ones here (Nimbus's internal crypto provider methods, in particular) aren't `public`.
- This step exists precisely to avoid the class of bug in [[Calling-Through-An-Overload-Without-Recursing]]: knowing a method is `void` before writing the hook is what tells you *not* to `return this.originalMethod(...)`.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Java-Layer-Hooking]]
- [[Confirming-Obfuscated-Types-By-Dumping-Runtime-Arguments]] in [[PressReader]]
- [[Decrypting-JWE-Request-Response-Bodies]], [[App-Architecture-And-Login-Flow-Mapping]], and [[Poste-Italiane]] in [[Case-Studies]]
