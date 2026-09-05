---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-05
---

# JWE-OTP-Payload-And-Key-Investigation

## Question / goal

During the live session on 2026-09-05, the extended `JWEObject.encrypt()` hook (see
[[http-pinning-bypass-and-dump.js]]) captured a JWE payload containing OTP data —
exposing the OTP generation mechanism and the metadata of the JWE key used.
Goal: understand where the HOTP secret and moving factor come from, and whether the public
RSA key used to wrap the **CEK** is statically available in the **APK**.

## Glossary

This note leans on JOSE/cryptography and Android-tooling jargon throughout — collected here
once instead of re-explaining inline every time a term recurs.

| Term | Meaning |
|---|---|
| **JWE** | JSON Web Encryption (RFC 7516) — the standard format for an encrypted JSON token; what this whole investigation is about. |
| **JWT** | JSON Web Token (RFC 7519) — the general signed/encrypted token format; a JWE is one specific kind of JWT (the header even says `"typ":"JWT"`, despite being encrypted rather than just signed). |
| **JOSE** | JSON Object Signing and Encryption — the umbrella IETF spec family covering JWS (signing), JWE (encryption), and the JWT container format; "Nimbus JOSE+JWT" is the Java library implementing all of it. |
| **CEK** | Content Encryption Key — the random symmetric key that actually encrypts a JWE's payload. It's generated fresh for every message, then itself encrypted ("wrapped") using whatever algorithm the JWE header's `alg` field names — here, the recipient's RSA public key. |
| **`alg` / `enc`** | Standard JWE header fields: `alg` names the algorithm used to *wrap the CEK* (here `RSA-OAEP-256`); `enc` names the algorithm used to encrypt the *payload* with the CEK (here `A256CBC-HS512`). |
| **`kid`** | "Key ID" — a standard JOSE header field meant to name which key was used. Central twist of this investigation: here it turns out to hold the app's own registration UUID instead of an actual key identifier — see "`kid` is not a key identifier" below. |
| **RSA** | Rivest–Shamir–Adleman — the asymmetric (public/private key pair) encryption algorithm used to wrap the CEK. |
| **OAEP** | Optimal Asymmetric Encryption Padding — the padding scheme RSA needs on top of the raw modular-exponentiation math to be secure; `RSA-OAEP-256` means OAEP using SHA-256 as its internal hash. |
| **AES** | Advanced Encryption Standard — the symmetric cipher used for the actual payload encryption (`A256CBC` = AES with a 256-bit key). |
| **CBC** | Cipher Block Chaining — the block-cipher mode AES runs in here. |
| **HMAC** | Hash-based Message Authentication Code — authenticates data using a shared secret plus a hash function; used both inside `A256CBC-HS512` (payload integrity) and inside HOTP (generating the OTP itself). |
| **SHA-1 / SHA-256 / SHA-512** | Members of the Secure Hash Algorithm family, used as the underlying hash inside the HMAC/OAEP constructions above. |
| **OTP** | One-Time Password — the general term for the short numeric code the app generates (`"otp":"92666982"` in the capture). |
| **HOTP** | HMAC-based One-Time Password (RFC 4226) — an OTP scheme computed as `Truncate(HMAC(secret, counter))`. The capture's `"type":"HMAC-SHA1"` labels it this way, though the investigation later finds the "counter" isn't a real persistent counter — see "HOTP secret — resolved". |
| **TOTP** | Time-based One-Time Password (RFC 6238) — HOTP's sibling scheme, where the counter is derived from the current time instead of being stored; ruled out early on because `movingFactor` doesn't match `floor(iat/30)`. |
| **UUID** | Universally Unique Identifier — a 128-bit id formatted like `9738aa38-205e-4386-b6dd-25ceabf3918c`; turns out to be exactly what `kid` holds in this app. |
| **X.509** | The standard defining the structure of a public-key certificate (issuer, subject, public key, extensions, signature). |
| **SubjectPublicKeyInfo (SPKI)** | The standard ASN.1 structure — inside an X.509 certificate, or standalone — holding an algorithm identifier plus the raw public-key bytes; what `KeyFactory.generatePublic()` expects as input. |
| **ASN.1** | Abstract Syntax Notation One — the schema language X.509 certificates (and most crypto data structures) are described in. |
| **DER** | Distinguished Encoding Rules — the specific compact binary encoding of ASN.1 data that X.509 certificates actually use on disk. |
| **PEM** | Privacy-Enhanced Mail — despite the name, now just a convention for wrapping DER bytes as base64 text between `-----BEGIN ...-----`/`-----END ...-----` lines; what `keytool -exportcert -rfc` and `openssl`'s default output both produce. |
| **APK** | Android Package — the installable/distributable file format for an Android app; also used loosely here for "the extracted contents of that file". |
| **DEX** | Dalvik Executable — the bytecode format Android apps ship their compiled Java/Kotlin code in; **smali** is the human-readable disassembly of DEX that reverse engineers actually read and grep through. |
| **SDK** | Software Development Kit — "JOD mobile SDK" is the vendor library `org.jod.mobile.android.xkey` ships as part of. |
| **UBER** | Not an acronym — BouncyCastle's own name for its proprietary Java `KeyStore` file format (what `XAPI_HOLDER.ubr` is). |
| **BC** | Shorthand used later in this note for BouncyCastle, the cryptography library (SpongyCastle, which this Android app actually bundles, is an Android-repackaged fork of an old BouncyCastle release). |
| **ADB** | Android Debug Bridge — the command-line tool (`adb`) used to talk to a connected device or emulator: pull files, run shell commands, etc. |
| **MSYS** | The POSIX-compatibility layer Git Bash for Windows is built on — responsible for the path-mangling snag hit in "Live verification" Step 3. |

## What was captured

The hook logged (raw payload in [[local/otp-payload-2026-09-05.md]]):

```
header:    {"kid":"9738aa38-205e-4386-b6dd-25ceabf3918c","cty":"JWE","typ":"JWT",
             "enc":"A256CBC-HS512","alg":"RSA-OAEP-256"}
encrypter: com.nimbusds.jose.crypto.RSAEncrypter
payload:   {"sub":" ","nbf":1788629821,"data":{},
             "otp-specs":{"movingFactor":747596914,"otp":"92666982","type":"HMAC-SHA1"},
             "iss":"app-up","kid-sha256":"hMdmxG9cpzY56TGjxtqHDVZkDr5ZGYJlg1l0PyYGj34=",
             "exp":1788629881,"iat":1788629821,"jti":"1c2c747a-0784-46ce-847d-a791663d78b5"}
```

## OTP mechanism

`type: HMAC-SHA1` with `movingFactor` is **HOTP** (RFC 4226):

```
otp = Truncate(HMAC-SHA1(secret, movingFactor))
```

- `movingFactor: 747596914` — incrementing counter (does not match `floor(iat/30)`,
  thus not a standard TOTP). Likely a persistent counter incremented on each use.
- `otp: 92666982` — 8-digit output, standard HOTP truncation.
- The HOTP **secret** is the missing piece: provisioned at enrollment, saved on the device
  (Android Keystore or encrypted SharedPreferences). Not visible in this capture.

### How to find the secret / counter origin

1. Enumerate HOTP classes at runtime:
   ```js
   Java.enumerateLoadedClasses({
       onMatch(name) {
           if (/hotp|totp|otp|hmac|moving.?factor/i.test(name)) console.log(name);
       },
       onComplete() {}
   });
   ```
2. Hook the method generating the OTP — look for a method taking `byte[] secret` and
   `long counter` and returning `int`/`String`. Capture secret + counter at call time.
3. Static: search smali/jadx for `movingFactor`, `HMAC-SHA1`, `HmacOTP`.

## JWE key metadata

| Field | Value |
|---|---|
| `alg` | `RSA-OAEP-256` — CEK wrapped with RSA-OAEP + SHA-256 |
| `enc` | `A256CBC-HS512` — payload: AES-256-CBC + HMAC-SHA-512 |
| `kid` | `9738aa38-205e-4386-b6dd-25ceabf3918c` |
| `kid-sha256` | `hMdmxG9cpzY56TGjxtqHDVZkDr5ZGYJlg1l0PyYGj34=` |
| encrypter | `com.nimbusds.jose.crypto.RSAEncrypter` (Nimbus JOSE+JWT) |

`RSA-OAEP-256`: the CEK is wrapped with the **server's RSA public key** — the app encrypts
towards the backend, the private key (to unwrap) resides only server-side. Offline decryption
of the bodies sent by the app is not feasible. Encrypted responses to the device use the
device's own key pair provisioned at enrollment.

## Key search: bundled certificates

Scanned all X.509 certificates in `assets/cert/` and `assets/certificate/` (18 + 6 files)
computing `SHA-256(SubjectPublicKeyInfo DER)` for each and comparing against `kid-sha256`.
**No match.** The JWE RSA key is not in any bundled certificate.

Public key fingerprints found:

| File | SHA-256(pubkey) |
|---|---|
| azure.cer | `Nx9EiJXB7MlUbCgjbZ2Qzx7AtQeeJBqzkQj1tjobTTM=` |
| certificato_padre_poste_it_g3.cer | `86fLIetopQLDNxFZ0uMI66Xpl1pFgLlHHn9v6kT0i4I=` |
| certificato_r1.cer | `K87oWBWM9UZfyddvDfoxL+8lpNyoUB2ptGtn0fv6G2Q=` |
| certificato_r3.cer | `cGuxAXyFXFkWm61cF4HPWX8S0srS9j0aSqN0k4AP+4A=` |
| gsorganization_sha2_g2.cer | `IQBnNBEiFuhj+8x6X8XLgh01V9Ic5/V3IRQLNFFc7v4=` |
| idp-poste.poste.it.leaf.cer | `bwRGTIaUTkvkbJw3nrhd0FLjw06JPZgVpXTRfdIvRRk=` |
| idp_foglia.crt | `hzAd3jOOoJr/KO2NYGLPl6ij8uRoYhOw9J4WHl54tMY=` |
| idp_int_cert.crt | `hETpgVvaLC0bvcGG3t0cuqiHvr4XyP2MTwCiqhgRWwU=` |
| idp_int_old_cert.crt | `IQBnNBEiFuhj+8x6X8XLgh01V9Ic5/V3IRQLNFFc7v4=` |
| idp_intermedio.crt | `IQBnNBEiFuhj+8x6X8XLgh01V9Ic5/V3IRQLNFFc7v4=` |
| idp_leaf_cert.crt | `7Ni2gKC3LKoZpyfHhWoTI144UY0lnysR9xKKjh/8ZT4=` |
| idp_leaf_old_cert.crt | `8ohhwgffXvCj7bBewURwhIaVYm/wmTtQKketIM5wkxY=` |
| pagamenti_poste_it.cer | `U1sGx+kGiPtEErEVC2Hdg+uhp9EROFC7+Lk3DCWcCKo=` |
| poste_it_intermediate.cer | `hETpgVvaLC0bvcGG3t0cuqiHvr4XyP2MTwCiqhgRWwU=` |
| poste_it_leaf.cer | `OnWX9iNOXkZpnr4bY/lYJEfCW/Ru4D+rmB1vAt3IMLI=` |
| postedeliveryweb_poste_it.cer | `HrhyjV+IQJhwIBW1fPq+76Aogk3FpOGUadJoOPsrUf4=` |
| upload_poste_it.cer | `I9iMwR7Ni53GlOnPuGxnZRwKqf1ADm9Th8efmMvcGa0=` |
| appregistry.mobile.poste.it.2024.leaf.der | `hpX8q5KKmaN1FlJj3WLKbTP107SveUUqh0k+SWxKMF0=` |
| appregistry.mobile.poste.it.2025.leaf.der | `Or/rS+/ejRMJJdlyRPu+ZckHambQ+YS7Nmj/+0eg8IQ=` |
| appregistry.mobile.poste.it.2026.leaf.der | `tTWE2sxVGoTlty9l7fgMggMA8/cP87LZ2+6PM0ePklI=` |
| appregistrymobileposteit.cer | `75fazpwBlzJmrZksDpAHSmg4yg/wWa3FjcV4sujhjp8=` |
| caov2018.cer | `hETpgVvaLC0bvcGG3t0cuqiHvr4XyP2MTwCiqhgRWwU=` |

## Script improvements in this session (2026-09-05)

Modifications to [[http-pinning-bypass-and-dump.js]]:

### Interleaving fix — atomic blocks

`logRequest` and `logResponse` were issuing a `console.log` for each header — with concurrent
OkHttp dispatcher threads, lines from two parallel requests would interleave in the output.
Fixed by accumulating the entire block (headers + body + curl) into a single string and
emitting it with a single `console.log`, which Frida guarantees to be atomic over the
control channel.

### curl in the request block

The `[curl]` command was a separate `console.log` after the `[>>>]` block, allowing
concurrent requests to displace it. It is now part of the same `out` buffer, so it is
always immediately below its request and cannot be separated.

### JWE block format

`tryFlush` in `makeJweMatcher` uses the same single-call pattern:
`[jwe-decrypted <label> — <url>]` at column 0 (greppable), payload uniformly indented
with `\n` → `\n      ` replacement to keep multi-line JSON visually grouped.

### Extended encrypt hook

Added to `JWEObject.encrypt()`:
- `this.getHeader().toString()` — logs `alg`, `enc`, `kid` from the JWE header
- `encrypter.$className` — identifies the concrete Nimbus class (note: use Frida's
  `$className` property, NOT `.getClass().getName()` — the latter is not exposed on
  Java interface wrappers and throws `TypeError: not a function`)
- `Java.use("android.util.Log").getStackTraceString(...)` — stack trace to locate
  the calling code path

## Where the RSA key actually lives (2026-09-05, follow-up)

The `kid`/JWKS hypothesis above was wrong — corrected here after decompiling
`org.jod.mobile.android.xkey` (`spim_apktool/smali_classes5/org/jod/mobile/android/xkey/`)
with apktool. The library ships with the app under the name **XKey** (part of the "JOD"
mobile SDK also used by `jod_sca_property.json` / `jod_openid_property.json`).

### How this was found

The crash stack trace pinpoints the exact call:

```
org.jod.mobile.android.xkey.store.b.a(SourceFile:160)   <- builds+encrypts the JWEObject
org.jod.mobile.android.xkey.a.a(SourceFile:233)          <- caller, owns the key material
org.jod.mobile.android.xkey.XKeyFacade.getJWTfromPayload(SourceFile:3)
```

Smali `.line NNN` directives preserve the original Java source line numbers, so grepping
each class for the literal marker `.line 233` (in `xkey/a.smali`) and `.line 160` (in
`xkey/store/b.smali`) lands exactly on the two call sites — no guessing needed:

- `store/b.smali` line 160: `RSAEncrypter` is constructed from a raw `X509EncodedKeySpec`
  passed in as a `byte[]` parameter — confirming the key is **not a field of this class**,
  just data handed to it.
- `xkey/a.smali` line 233 (inside `a(String, Map)String`, the method `getJWTfromPayload`
  actually calls): the `byte[]` key comes from
  `store.a.h()` — an interface method on `org.jod.mobile.android.xkey.store.a`.

The only class implementing that interface is `XKeySecHolderSL1`
(via the singleton factory `store/c.a()`). Reading it end to end explains everything:

- It wraps a **Java `KeyStore` of type `"UBER"`** (the BouncyCastle/SpongyCastle proprietary
  keystore format — this app bundles `org.spongycastle`, confirmed by the `insertProviderAt`
  call in `store/b`'s `<clinit>`).
- The keystore file is `<app-private-files-dir>/XAPI_HOLDER.ubr` (constants in
  `store/XKeyConst.smali`: `XKEY_PREFS = "XAPI_HOLDER"`, `XKEY_STORE = "XAPI_HOLDER.ubr"`).
- `l()` (the private loader): if that file doesn't exist yet in the app's files dir, it
  **falls back to a seed copy bundled in the APK's assets**, opened with a **null** password;
  once the app registers with the backend, the populated keystore is written back to the
  files dir protected with the **hardcoded password `"XAPI_HOLDER"`** (the same string used
  as the prefs/file name, passed through `toCharArray()`).
- Real key material is stored as **fake self-signed X.509 certificates**, with the actual
  secret bytes stuffed into the certificate's `subjectKeyIdentifier` extension (a common
  trick to store arbitrary blobs in a keystore that otherwise only accepts certs/keys) —
  see `a([B)[B`-style helpers stripping the ASN.1 OCTET STRING header (`sub-int/2addr ... 0x4`)
  before returning the raw bytes. Aliases in use: `SK` (HOTP secret), `UUID` (app instance
  id), `APP_PUBKEY` / `APP_PRIVKEY` (the app's own device keypair, generated locally by
  `store/b.b()`), `SERVER_PUBKEY` (**the RSA public key that wraps the JWE CEK**).

Checked whether the bundled seed keystore already contains a usable `SERVER_PUBKEY`:

```
<extracted-apk>/assets/XAPI_HOLDER.ubr   -> 64 bytes
<extracted-apk>/assets/SCA_HOLDER.ubr    -> 64 bytes
<extracted-apk>/assets/OPENID_HOLDER.ubr -> 64 bytes
```

(not imported into `source/` here — these are asset files in the working extracted-APK
tree, checked in place; only a scan result is recorded)

64 bytes is an essentially empty UBER keystore (header only, no entries) — **confirmed: no
key is statically present in the APK.** This matches the original hypothesis's conclusion,
just via a different, now fully traced mechanism instead of a JWKS fetch.

### The actual provisioning flow

`xkey/a.smali` has three lifecycle methods, all calling the backend through
`org.jod.mobile.android.xkey.c.e` (`XKeyRequest`/`init`, `register`, `registerUpdate`):

1. **INIT** (`a([B)...`, private method ~line 78 onward): POSTs, gets back a base64 field
   `e` in the response — this is `Landroid/util/Base64;->decode` → `store.a.a([B)Z` on
   `XKeySecHolderSL1`, which wraps it as `SERVER_PUBKEY`. **This is the RSA public key seen
   in the JWE header (`alg: RSA-OAEP-256`)** — provisioned per-device by the backend at
   first run, never shipped in the APK.
2. **REGISTER** (`a([B, Activity)`): generates a local RSA-2048 app keypair
   (`store/b.b()`), base64-sends the public half to the server as `pubAppKey`, and the
   server responds with `otpSecretKey` + `app-uuid` (JSON, itself unwrapped from a JWE using
   the just-generated app private key) — stored as aliases `SK` and `UUID`.
3. **REGISTER UPDATE** (`b([B, Activity)`): re-syncs the same data, and this is also where
   the OTP payload seen in the original capture is built (`otp-specs` / `movingFactor` /
   `HMAC-SHA1`), confirming this is the same code path as `getJWTfromPayload`.

### `kid` is not a key identifier — it's the app instance UUID

`getJWTfromPayload` (the method containing the exact `.line 233` crash site) sets:

```
kid              = store.a.e()                       // the "UUID" alias, i.e. app-uuid from REGISTER
kid-sha256       = base64(SHA-256(kid.getBytes()))
```

Verified directly — `SHA-256("9738aa38-205e-4386-b6dd-25ceabf3918c")` base64-encodes to
`hMdmxG9cpzY56TGjxtqHDVZkDr5ZGYJlg1l0PyYGj34=`, an exact match to the captured
`kid-sha256` claim. So `kid` identifies **this device's registration**, not the RSA key —
the earlier assumption that it pointed at a JWKS entry was the wrong framing entirely.

### HOTP secret — resolved

Also answers the still-open question from the first pass: `otpSecretKey` returned by the
server during REGISTER is exactly the HOTP secret, persisted under keystore alias `SK`,
read back via `store.a.d()` and fed together with a random `movingFactor` counter into
`org.jod.mobile.android.xkey.a.a.c.a(Ljava/lang/String;JIZI)Ljava/lang/String;` (params:
secret, counter, digit count `8`, zero-pad `false`, radix `16`) to produce the OTP string.
The counter is a fresh `Random().nextInt()` generated **per call**, not a persistent
incrementing counter — so it isn't RFC 4226 HOTP at all despite the `"type":"HMAC-SHA1"`
label; it behaves more like a random-challenge HMAC than a moving-factor OTP.

### How to actually recover the live key material

The RSA private key never leaves the server, so response bodies still can't be decrypted
offline. But `SERVER_PUBKEY`/`SK`/`UUID` are all sitting in `XAPI_HOLDER.ubr` on any
**already-registered** device/emulator, and that file uses a hardcoded, known password:

```
adb root && adb pull /data/data/it.posteitaliane.PosteApp/files/XAPI_HOLDER.ubr .
keytool -list -v -keystore XAPI_HOLDER.ubr -storetype UBER -storepass XAPI_HOLDER \
    -providerclass org.bouncycastle.jce.provider.BouncyCastleProvider \
    -providerpath /path/to/bcprov.jar
```

(needs a BouncyCastle/SpongyCastle provider jar on the classpath since `UBER` isn't a
JDK-native keystore type; SpongyCastle is Android-specific so the plain upstream
`bcprov-jdk18on` jar should still read the same UBER format).

## Live verification (2026-09-05, same day): pulling the real keystore off the Blackview

Everything above was derived purely from static analysis — smali reading, no device
involved. The device used for the original Frida capture (see
[[Frida-Server-Setup-On-The-Blackview]]) was still available and registered, so every
prediction from the static analysis could actually be tested against it instead of staying
theoretical. This section is the "we predicted X, now let's see if X is really there" pass.

### Why this was worth doing

Static analysis had already produced four *specific, falsifiable* predictions:

1. The keystore file is at `<files-dir>/XAPI_HOLDER.ubr`.
2. Its type is `UBER` and its password is the literal string `"XAPI_HOLDER"`.
3. It contains exactly five aliases: `APP_PRIVKEY`, `APP_PUBKEY`, `SERVER_PUBKEY`, `SK`, `UUID`.
4. The real payload of each entry is hidden in the `subjectKeyIdentifier` X.509v3 extension
   of an otherwise-throwaway self-signed certificate, with a fixed number of header bytes
   to strip (2 for `SK`/`UUID`, 4 for the RSA keys).

A prediction this specific is exactly the kind worth checking live — if even one part were
wrong (wrong path, wrong password, wrong format), that would mean the smali reading missed
something, and static-only conclusions from earlier in this note (the OTP mechanism, the
`kid` semantics) would need re-examining too. Every one of the four turned out correct.

### Step 1 — confirm the file exists where predicted

```
adb shell "su -c 'find /data/data/com.posteitaliane.spim/files -iname \"*HOLDER*\"'"
-> /data/data/com.posteitaliane.spim/files/XAPI_HOLDER.ubr
-> /data/data/com.posteitaliane.spim/files/SCA_HOLDER.ubr
```

Exact match on prediction #1 (note: the real package id is `com.posteitaliane.spim`, not
`it.posteitaliane.PosteApp` guessed from internal class names in the stack trace — internal
Java package names and the Android application id are unrelated and shouldn't have been
conflated).

### Step 2 — first pull attempt: silently corrupted, caught by a size check

First attempt used the obvious one-liner:

```
adb shell "su -c 'cat /data/data/com.posteitaliane.spim/files/XAPI_HOLDER.ubr'" > XAPI_HOLDER.ubr
```

This "worked" in the sense that a file appeared — 5670 bytes — but `keytool` rejected it
with a low-level ASN.1 parsing error (`long form definite-length more than 31 bits`), the
kind of error you get from feeding a parser structurally-garbled bytes, not from a wrong
password (a wrong password on a UBER store would fail its own HMAC check first, with a
clearer error). The intuition at that point was "maybe it's a BouncyCastle vs. SpongyCastle
version mismatch" (Android's SpongyCastle is a very old BC fork, ~1.47-era, repackaged
under `org.spongycastle` to avoid colliding with Android's built-in BC). That was a
reasonable first guess, so it was tested: reran `keytool` against BC 1.67 (closer vintage)
and BC 1.77. **Each version failed with a *different* ASN.1 error at a different offset**
— and that's the tell that the version-mismatch theory was wrong. A genuine format
incompatibility produces a *consistent* failure across parser versions (same field
misinterpreted every time); truly random-looking, different corruption per attempt (there
was no different attempt yet — same file, same three failures) meant the input bytes
themselves were the problem, not the parser.

That pointed at the transfer, not the crypto. A quick sanity check confirmed it:

```
adb shell "su -c 'wc -c /data/data/com.posteitaliane.spim/files/XAPI_HOLDER.ubr'"
-> 5648
```

5648 on-device vs. 5670 pulled — **22 bytes too many**. That specific kind of size
inflation (not truncation, not random noise) is the signature of `\n` → `\r\n` line-ending
translation: Git Bash's redirection (`>`) on Windows can open the destination in text mode,
and every `0x0A` byte inside the binary keystore was silently promoted to `0x0D 0x0A`.
Counting embedded `0x0A` bytes in the corrupted file would have to equal exactly 22 to fully
confirm it, but the diagnosis was strong enough to just fix the transfer method rather than
prove the mechanism further.

### Step 3 — binary-safe transfer, plus an unrelated path-mangling snag

Fix: stage the file somewhere world-readable and use `adb pull`, which is binary-safe
(it doesn't go through a shell text pipe on either end):

```
adb shell "su -c 'cp /data/data/com.posteitaliane.spim/files/XAPI_HOLDER.ubr /data/local/tmp/XAPI_HOLDER.ubr && chmod 666 /data/local/tmp/XAPI_HOLDER.ubr'"
adb pull /data/local/tmp/XAPI_HOLDER.ubr .
```

This hit a second, unrelated environment quirk: Git Bash's MSYS layer auto-rewrites any
argument that *looks* like a POSIX absolute path (`/data/local/tmp/...`) into a Windows path
before the child process (`adb.exe`, a native Windows binary) ever sees it — so `adb` was
handed `C:/Program Files/Git/data/local/tmp/...` and failed with "No such file or
directory". Exporting `MSYS_NO_PATHCONV=1` fixes that but breaks the *destination* argument
in the same command (which needs the same treatment in reverse — a real Windows path).
Cleanest fix: double the leading slash (`//data/local/tmp/...`) only on the device-side
argument — a well-known Git-Bash-specific escape that MSYS's heuristic doesn't rewrite,
while leaving local paths untouched.

With both fixed, the re-pull matched exactly:

```
adb pull //data/local/tmp/XAPI_HOLDER.ubr .
-> 5648 bytes
```

5648 == 5648. Binary-clean.

### Step 4 — opening it: exactly the five aliases predicted

```
keytool -list -v -keystore XAPI_HOLDER.ubr -storetype UBER -storepass XAPI_HOLDER \
    -providerclass org.bouncycastle.jce.provider.BouncyCastleProvider \
    -providerpath bcprov-jdk18on-1.77.jar
```

Opened cleanly on the first try with the correctly-transferred file — confirming the
"version mismatch" theory from Step 2 had been a red herring all along; a stock upstream
BC 1.77 jar reads Android SpongyCastle's UBER format just fine. **Five entries, exactly the
five aliases predicted from `XKeySecHolderSL1`'s string constants**:
`APP_PRIVKEY`, `APP_PUBKEY`, `SERVER_PUBKEY`, `SK`, `UUID` — each a self-signed
`CN=<xxxName>` certificate (`servPubkName`, `skName`, `uidName`, ...) valid from
2026-09-03, i.e. created **two days before** the JWE capture at the top of this note — a
timeline that's consistent with (not contradicting) this being the same registered session.

`keytool -v`'s normal output only shows the *wrapper* certificate's own dummy 2048-bit RSA
key (freshly generated purely so the certificate is structurally valid) and prints no
"Extensions" section at all for these certs — confirming, from the *tooling's* perspective
this time, that the real payload is tucked away somewhere keytool doesn't surface by
default, exactly as the smali predicted.

### Step 5 — reading the actual hidden payload with `openssl asn1parse`

Exported each cert (`keytool -exportcert -rfc`) and asked `openssl asn1parse` to walk the
DER structure directly instead of relying on keytool's summary:

```
openssl x509 -in SERVER_PUBKEY.pem -outform DER -out SERVER_PUBKEY.der
openssl asn1parse -in SERVER_PUBKEY.der -inform DER
```

This *does* show the `X509v3 Subject Key Identifier` extension, with a `[HEX DUMP]` of its
raw content — and for `SERVER_PUBKEY` that content is unmistakably another DER structure in
its own right: it starts `3082...300D06092A864886F70D010101...`, i.e.
`SEQUENCE { SEQUENCE { OID rsaEncryption, NULL }, BIT STRING {...} }` — a standard
X.509 `SubjectPublicKeyInfo`. Exactly the structure `store/b.smali` expects when it later
does `new X509EncodedKeySpec(bytes)` → `KeyFactory.generatePublic(...)` — this is the RSA
public key.

Wrapping that hex blob back into a normal PEM key confirms it decodes as a valid 2048-bit
RSA public key:

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmhZOb8AW098jcHOTkp3n
dn5aGrS5xgo0WGuznhJQq0aC+AfKGnP2xMbq8vmvB98j7abwCEAY2ZrvUF7tkyhc
mOK+xIcOlctKG9qeUi9LoRVasP4WQoZWpCvV4PFsU+v4BzeDtcVKp/qyTGAF1pSH
4xLd76pqqmVE7+ncXBGx4cuzXFCeg5Cyksf+c4OvU4PjPqb7ohrcBYsgFYgwh5VR
okws4Czjb5zYXM5OEwinNDolIhxUppDl9ypqjfNL4hwFo8h2kgI/cl+SBl2t1LGN
cmCbPANHved5kEHhqXj0U+Y9idlH3Dd2A1owKVx97Uc3rVuMbRwkRexE6M0PUrVN
IwIDAQAB
-----END PUBLIC KEY-----
```

**This is the RSA public key that wraps the JWE CEK for this device's registration** —
the object the whole investigation set out to find, extracted from live storage exactly
where and how the static analysis said it would be. (This is a public key, safe to record
in full — it grants no ability to decrypt anything, only to encrypt towards the server,
same as the app itself does.)

### Step 6 — the closing-the-loop moment: `UUID` matches the original capture's `kid`

Ran the same `asn1parse` against the `UUID` alias. Unlike `SERVER_PUBKEY`, its extension
content isn't further DER — `openssl` decodes it directly as printable text:

```
OCTET STRING :9738aa38-205e-4386-b6dd-25ceabf3918c
```

That is character-for-character the `kid` from the JWE header captured at the very top of
this note, back at the start of the investigation. This is the strongest possible
confirmation available without the original ciphertext itself: it independently verifies,
on the live device, both (a) that `kid` really is the app-registration UUID rather than a
key identifier (the hypothesis derived purely from reading `xkey/a.smali`'s
`getJWTfromPayload`), and (b) that this specific keystore, pulled two days after that
registration was created, really is the one that produced the original capture — not just
"a" registration that happens to have the same shape.

`SK` (the HOTP secret alias) was extracted the same way and decoded to a real ~60-character
lowercase alphanumeric string, confirming the mechanism from the "HOTP secret — resolved"
section above end-to-end.

> [!warning] Live secret material — not reproduced in full here
> `SK` is a real, currently-valid OTP secret for this Poste Italiane account/device
> registration, not a fabricated or expired example. Since this vault is public, its value
> is intentionally **not** included in this note (only its format/length, which carries no
> risk). The technique to re-derive it is fully documented above — anyone repeating this
> against their own device recovers their own value the same way.

### What static analysis alone bought before touching the device

Worth stating plainly, since it's the point of doing the static pass first at all: by the
time the device was touched, the exact file path, exact password, exact keystore format,
exact number and names of aliases, and the exact byte-stripping trick for extracting the
hidden payload were all already known from smali alone. The live session with the device
did zero exploration — it was pure confirmation, plus the two purely-environmental hiccups
in Steps 2–3 (Windows/Git-Bash transfer quirks, nothing to do with the target app). That is
the payoff of chasing `.line NNN` markers back to exact source lines instead of guessing
from surrounding context: every downstream step became "verify this specific claim" instead
of "explore and see what's there."

## Open questions / next steps

- [x] Search for UUID `9738aa38-205e-4386-b6dd-25ceabf3918c` and raw RSA key in the app's
      DEX/smali — confirmed genuinely absent from the static APK (JWKS hypothesis was
      wrong; see "Where the RSA key actually lives" above for the real mechanism).
- [x] Find the HOTP secret and its origin — `otpSecretKey` from the REGISTER response,
      stored as keystore alias `SK` in `XAPI_HOLDER.ubr`; see above.
- [x] Correlate `movingFactor` with session state — it's `Random().nextInt()` per call, not
      a persistent counter; not real HOTP despite the label.
- [x] Pull `XAPI_HOLDER.ubr` from a registered device and open it with `keytool`/BouncyCastle
      — done live in "Live verification" above; `SERVER_PUBKEY` recovered in full, and `UUID`
      confirmed to exactly match the originally captured `kid`, closing the loop.
- [ ] Decompile `org.jod.mobile.android.xkey.a.a.c` to confirm the exact OTP-from-secret
      algorithm (HMAC-SHA1 truncation details, radix-16 formatting).
- [ ] Re-check whether `SERVER_PUBKEY` is ever rotated server-side (would turn `kid`'s
      role back into something closer to a real key-selection mechanism after all, just
      indirected through the per-registration keystore rather than a JWKS endpoint).

## See also

- [[Decrypting-JWE-Request-Response-Bodies]]
- [[Login-AT01-And-Device-Trust-Signals]]
- [[http-pinning-bypass-and-dump.js]]
