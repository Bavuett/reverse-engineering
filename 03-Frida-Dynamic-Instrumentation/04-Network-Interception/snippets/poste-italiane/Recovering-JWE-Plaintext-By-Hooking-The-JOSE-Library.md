---
tags: [snippet]
level: 3
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "http-pinning-bypass-and-dump.js (Frida instrumentation script, not app source)"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Recovering-JWE-Plaintext-By-Hooking-The-JOSE-Library

## Context

Defeating TLS pinning per [[Network-Interception]] only gets you the app's *transport-layer* traffic — several of this app's request/response bodies turned out to be JWE (JSON Web Encryption)-wrapped on top of already-decrypted TLS, using `alg: RSA-OAEP-256` asymmetric key wrapping that makes offline decryption of captured ciphertext infeasible (neither side's private key is ever observable from a capture). The fix is the same principle as `SSL_write`/`SSL_read` hooking one layer up the stack: hook the point in the app's own code where the plaintext exists, rather than trying to break the cryptography.

## Original path

`` Case-Studies/poste-italiane/source/http-pinning-bypass-and-dump.js ``

## Snippet

```javascript
const JWEObject = Java.use("com.nimbusds.jose.JWEObject");

JWEObject.encrypt.overload("com.nimbusds.jose.JWEEncrypter").implementation = function (encrypter) {
    let plaintext = null;
    try { plaintext = this.getPayload().toString(); } catch (e) {}
    this.encrypt(encrypter); // void — nothing to return
    if (plaintext !== null) requestJwe.notePlaintext(plaintext);
};

JWEObject.decrypt.overload("com.nimbusds.jose.JWEDecrypter").implementation = function (decrypter) {
    this.decrypt(decrypter); // populates the Payload as a side effect
    try { responseJwe.notePlaintext(this.getPayload().toString()); } catch (e) {}
};
```

`requestJwe`/`responseJwe` are small FIFO-matching queues (not shown here) that pair this plaintext back up with the ciphertext body already logged by [[Hooking-The-OkHttp-Interceptor-Chain-Exactly-Once]]'s request/response logger, keyed by request URL — necessary because `encrypt()` always runs *before* the request is sent (plaintext available immediately), while `decrypt()` runs *after* the response's ciphertext was already logged (plaintext available only later).

### Example — a single request body carrying two independent JWE tokens

`openid-az`'s request body wasn't one JWE token but two, in different form fields — a `request=` parameter and a separate `credentials=` parameter, each independently encrypted:

```
request=eyJjdHkiOiJKV0Ui...&response_type=token&credentials=eyJraWQiOiJBMDZFQkVEMzM0RDkwRTM0Q0Y5...
```

A body-level "is this JWE?" regex has to match *every* JWE-shaped substring in the body, not just check the body as a whole — and the matching queue on the plaintext side has to expect two `notePlaintext()` calls (one per `encrypt()` call the app makes while building this one request) for a single logged request, dequeuing both under the same URL rather than assuming a strict 1:1 request-to-token ratio:

```javascript
const matches = bodyText.match(/[A-Za-z0-9_-]{16,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*/g);
// matches.length === 2 here — one push into the queue per match, both eventually
// paired with their own encrypt() call's plaintext
for (const _ of matches) pendingCiphertext.push({ url });
```

Decrypted, the two fields turned out to be a device/geolocation fingerprint payload (`request=`, matching the `x-rsa` header's own device-fingerprint shape) and the actual `signed_challenge` from the PIN+OTP transaction-signing step (`credentials=`) — two logically distinct pieces of the login submission, encrypted separately even though they travel in the same HTTP request.

## Notes

- The library (Nimbus JOSE+JWT, `com.nimbusds.jose.*`) was identified live, not assumed — see [[Enumerating-Loaded-Classes-By-Keyword]] — and its exact `encrypt`/`decrypt` signatures were confirmed with `getDeclaredMethods()` before writing this hook — see [[Dumping-Real-Method-Signatures-Before-Hooking]]. Both are `void`, which is why the hook reads `getPayload()` off `this` rather than a return value.
- Reused, real-world confirmation that this general pattern works: `RealInterceptorChain.proceed` (transport layer) and `JWEObject.encrypt`/`.decrypt` (application layer) are architecturally identical hooks — one class deep inside a networking library, mutating/exposing plaintext as a side effect of a call this app makes on its own, unconditionally, regardless of any pinning or encryption configuration.
- A real login-flow request captured this way (`sh2-web.poste.it/.../authorizeTransaction`) turned out to carry the user's own transaction PIN in the decrypted body, alongside a server response that named the exact rejection reason (`PIN-ERR-3`, "User PIN error") in plaintext, non-JWE JSON — the combined visibility (encrypted request decrypted, plain-JSON response) is what actually pinpointed a typo'd PIN as the true cause of a "login keeps failing" symptom, see [[Login-AT01-And-Device-Trust-Signals]].

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Network-Interception]]
- [[Java-Layer-Hooking]]
- [[Decrypting-JWE-Request-Response-Bodies]] and [[Poste-Italiane]] in [[Case-Studies]]
