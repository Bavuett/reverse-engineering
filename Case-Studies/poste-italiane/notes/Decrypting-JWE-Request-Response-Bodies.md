---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-04
---

# Decrypting-JWE-Request-Response-Bodies

## Question / goal

Most of the interesting request/response bodies captured by [[http-pinning-bypass-and-dump.js]] —
the passkey challenge exchange, the `openid-az` login submission, `datapushpending` — aren't plain
JSON: they're JWE (JSON Web Encryption) compact-serialized tokens, opaque even with TLS pinning fully
defeated. How do you actually get the plaintext behind these?

## How this was found

The short answer is: **you don't decrypt the captured ciphertext offline — you hook the app's own
decryption call instead**, and the "how" below is why that's not a workaround but the only
practically available option here.

Every JWE body observed so far shares the same compact-serialization shape, `<header>.<encrypted
key>.<iv>.<ciphertext>.<tag>` (five base64url segments), with a header (itself base64url JSON, always
readable without any key — see the decode in [[Login-AT01-And-Device-Trust-Signals]]) of the form:

```json
{ "cty": "JWE", "typ": "JWT", "enc": "A256CBC-HS512", "alg": "RSA-OAEP-256" }
```

`alg: RSA-OAEP-256` is the load-bearing detail: it means the AES content-encryption key (the thing
that actually protects the body) is itself wrapped with **asymmetric** RSA-OAEP encryption. Unwrapping
it requires the RSA **private** key belonging to whichever side receives that particular message —
Poste's backend for anything the app sends (`openid-az`, `datapushpending`), and this specific
device's own key material for anything the backend sends back encrypted to it. Neither key is
observable from a network capture, no matter how thorough — this is the entire point of using
asymmetric wrapping instead of a shared symmetric key. A `.pcap`/Frida traffic log alone is
structurally insufficient here, unlike, say, a weak or misconfigured symmetric scheme.

This is exactly the same shape of problem [[http-pinning-bypass-and-dump.js]] already solves for TLS
itself: rather than trying to break the cryptography, hook the point in the app's own code where the
plaintext exists on one side of the crypto boundary. For TLS that's `TrustManagerImpl`/OkHttp's
interceptor chain; for this app-layer JWE it's whatever JOSE library implementation the app links
against.

Live class enumeration (`Java.enumerateLoadedClasses`, keywords `"jose"`, `"jwe"`, `"nimbus"` — the
same technique documented in [[App-Architecture-And-Login-Flow-Mapping]]) found the answer directly
instead of guessing: this app bundles **Nimbus JOSE+JWT** (`com.nimbusds.jose.*`), a well-known,
open-source Java JOSE implementation — not a hand-rolled or obfuscated crypto layer. Its central class,
`com.nimbusds.jose.JWEObject`, exposes exactly two relevant methods, and their real signatures were
confirmed with `getDeclaredMethods()` rather than assumed from the library's public API docs:

```
public synchronized void com.nimbusds.jose.JWEObject.encrypt(com.nimbusds.jose.JWEEncrypter) throws com.nimbusds.jose.JOSEException
public synchronized void com.nimbusds.jose.JWEObject.decrypt(com.nimbusds.jose.JWEDecrypter) throws com.nimbusds.jose.JOSEException
public com.nimbusds.jose.Payload com.nimbusds.jose.JOSEObject.getPayload()
```

`encrypt()`/`decrypt()` are both `void` — Nimbus's API mutates the `JWEObject`'s internal state and
sets its `Payload` as a side effect, rather than returning the plaintext/ciphertext directly. That
shapes the hook: for `encrypt()`, the plaintext `Payload` is already set *before* the call (it's what
the app is about to encrypt) — read it via `this.getPayload()` before calling through. For
`decrypt()`, the `Payload` only becomes readable *after* the call completes (decryption is what
populates it) — call through first, then read it back.

## Relevant source

- [[http-pinning-bypass-and-dump.js]] — the `JWEObject` hook lives directly in this script now
  (originally prototyped as a standalone `jwe-payload-dump.js`, merged in once the plaintext needed
  to line up with the request/response log it belongs to — see Analysis below), alongside the same
  "hook the crypto call, not the ciphertext" principle already applied there to TLS.

## Excerpt

The hook itself, simplified (the real version in [[http-pinning-bypass-and-dump.js]] feeds the
plaintext into the `requestJwe`/`responseJwe` matching queues described in Analysis, rather than
`console.log`-ing it directly here):

```js
const JWEObject = Java.use("com.nimbusds.jose.JWEObject");

JWEObject.encrypt.overload("com.nimbusds.jose.JWEEncrypter").implementation = function (encrypter) {
    const plaintext = this.getPayload().toString(); // read BEFORE calling through — it's the input
    this.encrypt(encrypter); // void — nothing to return
    requestJwe.notePlaintext(plaintext);
};

JWEObject.decrypt.overload("com.nimbusds.jose.JWEDecrypter").implementation = function (decrypter) {
    this.decrypt(decrypter); // populates the Payload as a side effect
    responseJwe.notePlaintext(this.getPayload().toString()); // read AFTER
};
```

## Analysis

Hooking installed cleanly against the real, running app (`[+] Hooked
com.nimbusds.jose.JWEObject.encrypt/decrypt`, no exception), confirming the class and both method
signatures are exactly right for this app's bundled Nimbus version. A live firing with real plaintext
hasn't been captured yet — the test window only covered the app sitting idle after login, with no
JWE-carrying request in flight — so the next actual login/session-refresh/passkey action taken with
[[http-pinning-bypass-and-dump.js]] attached should be the first real capture. `Payload.toString()` is
Nimbus's own stringification and works directly for the JSON payloads seen so far; if a future payload
turns out to be binary rather than JSON/text, switch to `payload.toBytes()` and dump/hexdump that
instead.

**Why this is merged into `http-pinning-bypass-and-dump.js` rather than a standalone script**: reading
the plaintext in isolation isn't very useful without knowing which request/response it belongs to, and
correlating the two turned out to be asymmetric. `JWEObject.encrypt()` always runs *before* the app
hands the resulting ciphertext to OkHttp, so by the time `logRequest()`'s hook fires, the plaintext is
already available — request-body plaintext prints synchronously, right under the ciphertext, every
time. `JWEObject.decrypt()`, however, is called by the app's own business-logic layer *after*
`RealInterceptorChain.proceed()` has already returned the raw `Response` to `logResponse()` — the
ciphertext gets logged before the plaintext exists at all. The two hooks solve this with a small
FIFO-matching queue per direction (`requestJwe`/`responseJwe` in the script): whichever side — the
logger noting a JWE-shaped token, or the Nimbus hook noting a freshly encrypted/decrypted payload —
arrives *second* immediately triggers a `[jwe-decrypted ...]` print, tagged with the request's URL.
Request-body plaintext appears immediately; response-body plaintext appears slightly later in the
console output, as soon as the app itself gets around to decrypting it, but still clearly labeled with
which response it belongs to.

One caveat worth remembering when reading captured plaintext later: `JWEObject.decrypt()` throws
`JOSEException` on a bad/mismatched key rather than returning quietly, so a thrown exception at this
hook (visible as an unhandled error in the Frida console) is itself a meaningful signal — it means the
app tried to decrypt something it couldn't, which is worth investigating on its own rather than just
suppressing. Also worth remembering: the FIFO queue assumes requests/responses of the same kind
resolve in the order they were logged — true in the sequential common case, but a burst of concurrent
JWE-carrying calls (like the cold-start `appregistry` checks seen in
[[App-Architecture-And-Login-Flow-Mapping]]) could in principle pair a plaintext with the wrong URL.
The URL tag on every printed line makes a mismatch easy to spot by eye if the timing/content look off.

## Generalizing the pattern

When a captured request/response body turns out to be encrypted rather than plaintext JSON:

1. **Decode the outer structure first, key-free.** JWE/JWS headers are base64url JSON with no key
   needed to read them — `alg`/`enc` tell you immediately whether this is even theoretically
   decryptable offline (a symmetric `alg` like `dir` or `A256KW` might be, if the shared key is
   somehow recoverable; an asymmetric one like `RSA-OAEP-256`, as here, tells you not to bother).
2. **Identify the actual crypto library**, live, via `Java.enumerateLoadedClasses` with keywords drawn
   from the header format itself (`jose`/`jwe`/`jws` are strong signals; so is a `cty`/`typ`/`enc`/`alg`
   key ordering that matches a specific library's serializer) — don't assume a hand-rolled
   implementation until a keyword search comes up empty.
3. **Hook the library's own encrypt/decrypt entry point**, reading back whatever internal
   plaintext-holding field/method the library exposes (`getPayload()` for Nimbus) rather than trying to
   reimplement the crypto — this generalizes to `com.google.crypto.tink.*`, platform `javax.crypto.Cipher`,
   or any other library the same way.

## Related concepts

- [[Java-Layer-Hooking]] — the `.implementation =` hooking mechanics this relies on.
- [[Network-Interception]] — the TLS-layer version of "hook the crypto call, not the bytes."

## Open questions / next steps

- [ ] Capture a real `[jwe-encrypt]`/`[jwe-decrypt]` firing during an actual login or session-refresh
      action (the idle-app test window confirmed the hook installs correctly but caught no traffic).
- [ ] Cross-reference a decrypted plaintext against its matching ciphertext already logged by
      [[http-pinning-bypass-and-dump.js]] (same request, same timestamp) to confirm end-to-end
      correctness once a real firing is captured.

## See also

- [[XKey-Key-Exchange-And-Request-Flow]] — the end-to-end key-exchange picture this note's
  "which side's private key" reasoning feeds into
- [[Case-Studies]]
