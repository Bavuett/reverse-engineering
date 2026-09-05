---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-05
---

# XKey-Root-Detection-Check

## Question / goal

Given the JWE-wrapping mechanism traced in [[JWE-OTP-Payload-And-Key-Investigation]] all lives
inside the same `org.jod.mobile.android.xkey` library, and that library's `XKeyDeviceData` clearly
reports a `rooted` flag as part of every registration call — what exactly does it check, what
happens to the result, and does it actually change anything if the answer is "yes, rooted"?

## How this was found

Came up mid-conversation while discussing the original JWE capture: instead of re-deriving it from
scratch, the exact method was already visible from the earlier decompilation pass —
`org.jod.mobile.android.xkey.store.b.a(Landroid/content/Context;)Lorg/jod/mobile/android/xkey/values/XKeyDeviceData;`
(see `xkey/a.smali`'s calls to it during INIT/REGISTER/REGISTER-UPDATE in
[[JWE-OTP-Payload-And-Key-Investigation]]). Reading the method itself rather than just its call
sites answered "what does it check"; the more interesting question — "does it matter" — needed two
more steps:

1. Grepped the rest of `spim_apktool` for other readers of `isRooted`/`ROOTED` to check for any
   client-side branch that behaves differently once the flag is true (blocking registration,
   skipping a feature, etc.). None found — the only writer is this method, the only other consumer
   is `XKeySecHolderSL1` persisting it to `SharedPreferences` and folding it into the `xdevice`
   string sent to the backend.
2. Since this device (the Blackview used for all the live captures in this case study) is actually
   rooted via Magisk, and [[root-and-frida-hiding.js]] is already loaded during every capture
   session, the natural next question was whether that script happens to defeat *this specific*
   check too. Rather than assume, matched all 9 hardcoded path strings in this method against the
   hiding script's `SUSPICIOUS_PATH_RE` regex by hand — all 9 matched (see Analysis below), so on
   this exact setup the method has been reporting a false negative the whole time without anyone
   verifying it.

## Relevant source

- [[root-and-frida-hiding.js]]

## Excerpt

`org.jod.mobile.android.xkey.store.b.a(Landroid/content/Context;)Lorg/jod/mobile/android/xkey/values/XKeyDeviceData;`
(smali, lines abridged to the two checks that matter):

```smali
sget-object p0, Landroid/os/Build;->TAGS:Ljava/lang/String;
if-eqz p0, :cond_37
const-string v2, "test-keys"
invoke-virtual {p0, v2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
move-result p0
if-eqz p0, :cond_37
goto :goto_5f          ; TAGS contains "test-keys" -> rooted = true

:cond_37
const-string v9, "/system/bin/failsafe/su"
const-string v10, "/data/local/su"
const-string v2, "/system/app/Superuser.apk"
const-string v3, "/sbin/su"
const-string v4, "/system/bin/su"
const-string v5, "/system/xbin/su"
const-string v6, "/data/local/xbin/su"
const-string v7, "/data/local/bin/su"
const-string v8, "/system/sd/xbin/su"
filled-new-array/range {v2 .. v10}, [Ljava/lang/String;
; ... loops the 9 paths, calling new File(path).exists() on each
:goto_5f
const/4 v0, 0x1          ; rooted = true if TAGS matched OR any path exists
:cond_64
:goto_64
invoke-virtual {v1, v0}, Lorg/jod/mobile/android/xkey/values/XKeyDeviceData;->setRooted(Z)V
```

The hiding script's matcher, from [[root-and-frida-hiding.js]]:

```js
const SUSPICIOUS_PATH_RE = /(^|\/)su(\/|$)|magisk|busybox|supersu|superuser|\/xbin|\/data\/adb/i;
```

## Analysis

Two independent signals, both weak, both purely local — no native checks, no SELinux/mount
inspection, no Zygisk-awareness:

1. **`Build.TAGS` contains `"test-keys"`** — only true on a custom-signed ROM build. A stock
   vendor ROM with Magisk root (this device's actual setup) still reports `release-keys`, so this
   branch alone would already miss it even with no hiding active.
2. **`File(path).exists()`** on 9 hardcoded classic su-binary locations — if any one exists,
   `rooted = true`.

Checked each of the 9 paths against `SUSPICIOUS_PATH_RE` by hand — every single one matches:

| Path | Matches via |
|---|---|
| `/system/bin/failsafe/su` | trailing `/su` |
| `/data/local/su` | trailing `/su` |
| `/system/app/Superuser.apk` | `superuser` |
| `/sbin/su` | trailing `/su` |
| `/system/bin/su` | trailing `/su` |
| `/system/xbin/su` | `/xbin` (and trailing `/su`) |
| `/data/local/xbin/su` | `/xbin` |
| `/data/local/bin/su` | trailing `/su` |
| `/system/sd/xbin/su` | `/xbin` |

Combined with the script's separate `Build.TAGS.value = "release-keys"` / `Build.TYPE.value =
"user"` override, both signals this method reads are neutralized. **On this exact test setup, this
method has been returning `rooted = false` on every capture in this case study, regardless of the
device's real state** — nobody had to reach for Magisk DenyList, Zygisk, or Shamiko for this
particular check; a single generic `java.io.File.exists()` hook already installed for unrelated
reasons was enough.

The more interesting finding is what happens to the flag once computed: it's written to
`SharedPreferences("XAPI_HOLDER")` under key `ROOTED` and folded into the `xdevice` string
(`deviceID + "::" + XKeyDeviceData.toString()`) sent to the backend on every INIT/REGISTER/
REGISTER-UPDATE call — pure telemetry. Nothing in `org.jod.mobile.android.xkey` reads it back to
change client-side behavior (no refused registration, no disabled feature, no altered JWE/OTP
flow). Whatever consequence a `rooted: true` value has — if any — is a server-side decision this
case study has no visibility into.

This lines up with, and adds a second concrete instance to, the finding in
[[Login-AT01-And-Device-Trust-Signals]]: that note found the app's much more sophisticated RSA
Adaptive Authentication fraud SDK *also* reported `"Compromised": 0` on this same instrumented
device. Between the two, every locally-observable trust signal in this app currently reads "clean"
under Frida — the one signal that note flagged as out of reach either way is Play Integrity's
hardware-backed attestation, which no amount of Java-layer hooking touches.

## Generalizing the pattern

To find every other spot in this APK doing the same "hardcoded su-path enumeration" root check
(there is often more than one, written independently by different SDKs bundled into the same app):

```
grep -rl "system/bin/su\|system/xbin/su\|Superuser.apk" spim_apktool/smali_classes*/
```

And to sanity-check a hiding script's path regex against a *newly found* check's literal path list
before assuming it's covered (exactly the manual verification done above, worth automating if this
comes up again):

```js
const paths = ["/system/bin/failsafe/su", "/data/local/su", /* ... */];
paths.forEach(p => console.log(p, SUSPICIOUS_PATH_RE.test(p)));
```

## Related concepts

- [[Anti-Detection-And-Gadget-Mode]]

## Open questions / next steps

- [ ] Find where (if anywhere) the backend actually reacts to `xdevice`'s `ROOTED` value — not
      observable client-side; would need a controlled A/B (same account, same device, toggling
      only whether the hiding script is attached) to see if server behavior differs at all.
- [ ] Check whether `org.jod.mobile.android.openid` (the separate OpenID module, see
      `jod_openid_property.json`) has its own, independent root check with a different path list —
      `DeviceData`/`DeviceDataWithLibVersion` in that package look structurally similar but weren't
      compared line-by-line against this one yet.

## See also

- [[JWE-OTP-Payload-And-Key-Investigation]]
- [[Login-AT01-And-Device-Trust-Signals]]
- [[RSA-Adaptive-Auth-Onboarding-Verdict]] — the actual device-trust verdict gating onboarding
  (a separate SDK from this one)
- [[Case-Studies]]
