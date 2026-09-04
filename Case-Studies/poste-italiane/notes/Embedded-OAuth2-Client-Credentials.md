---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-03
---

# Embedded-OAuth2-Client-Credentials

## Question / goal

Once [[http-pinning-bypass-and-dump.js]] was actually attaching and dumping traffic (see
[[Frida-Server-Setup-On-The-Blackview]]), what does the app's very first burst of network activity
— before any login, before any user interaction at all — actually contain?

## How this was found

Spawned the app with `frida -U -f com.posteitaliane.spim -l http-pinning-bypass-and-dump.js -q -t
inf` and let it run through its splash screen unattended. The first two requests
(`appregistry.mobile.poste.it/.../appcheck` and `.../appconfig`) were unremarkable app-config
fetches. The next request, though, was a `POST` straight to
`login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token` with `grant_type=client_credentials` and
a `client_id`/`client_secret` pair in the URL-encoded body — a machine-to-machine OAuth2 flow,
not a user login (there's no username/password anywhere in it, and it happened before the splash
screen had even finished). The response was a normal 200 with a bearer access token, which the app
then attached as an `Authorization: Bearer …` header on its very next call, to
`oneapp.poste.it/remote-logger/v1/logs`.

The interesting part surfaced inside that logs payload itself: the app's own telemetry included two
`ERROR`-severity log records, `"Trusted chain does not end in a TrustAnchor"` (`pt_class_name:
SSLInterceptor`, `pt_err_code: SSL1`) and a generic `"Network_error"` (`pt_class_name:
LibraryHelper_splash`, `pt_act_name: checkConfiguration`) — both timestamped a few seconds *before*
this capture's own hooks had finished attaching. Read together, this looks like the app tried an
even earlier connection (probably the very first `appcheck`/`appconfig` calls, or a dedicated
pinned health-check connection) that failed TLS validation against the Frida-injected trust
override, self-reported that failure through its own telemetry pipeline, and then — once
`TrustManagerImpl`/`CertificatePinner` were fully hooked — the rest of the session's traffic went
through cleanly instead of the app hard-stopping. That's a real gap worth treating as a lead, not a
success: something in this app validates trust before (or independently of) the hooks in
[[http-pinning-bypass-and-dump.js]], and it happens early enough in process startup that it may be
a native-layer check rather than one of the three Java-layer hooks that script installs — see Open
questions below.

## Relevant source

- [[http-pinning-bypass-and-dump.js]]
- Raw request/response and the actual client_secret/access_token values are **not** included in
  this note or anywhere else in the vault — see the note in Analysis below.

## Excerpt

```
POST https://login.microsoftonline.com/<AZURE_AD_TENANT_ID>/oauth2/v2.0/token
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
User-Agent: ktor-client

grant_type=client_credentials&client_id=<CLIENT_ID>&client_secret=<REDACTED>&scope=<CLIENT_ID>%2F.default

200 OK
{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"<REDACTED_JWT>"}
```

```
"severity_text":"ERROR","body":{"stringValue":"Trusted chain does not end in a TrustAnchor"},
"attributes":[{"key":"Name","value":{"stringValue":"service_error"}},
{"key":"pt_class_name","value":{"stringValue":"SSLInterceptor"}},
{"key":"pt_err_code","value":{"stringValue":"SSL1"}},
{"key":"pt_act_name","value":{"stringValue":"intercept"}}]
```

## Analysis

The `client_id`, `client_secret`, and resulting bearer token are real, live credentials for
Poste Italiane's backend — capturing them required no login, no valid customer account, nothing
beyond installing the public app and starting it once under Frida. They are deliberately **not**
reproduced here or anywhere else in this (public) vault; the actual values are saved locally only,
outside of git (`Case-Studies/poste-italiane/local/`, covered by the repo's `**/local/`
`.gitignore` rule), for potential responsible disclosure to Poste Italiane.

The finding itself, independent of the specific secret value, is: **a statically embedded
`client_credentials` OAuth2 secret, extractable from the app binary/process with no authentication
step of its own**, used to obtain a bearer token for at least the app's remote-logging/telemetry
API. This is the same class of issue [[TUA]] documented for a different app's root-detection
bypass (`Case-Studies/tua/`) — an app-level trust assumption ("only my own APK will ever run this
code path") that Frida makes trivial to violate.

The `SSL1` telemetry error is a separate, still-open lead: it implies at least one more trust
validation point in this app that this capture's three hooks didn't (yet) cover, likely evaluated
earlier in process startup than `Java.perform()` in a spawned-and-resumed process can reliably
guarantee. Worth checking specifically for a native pinning check (`SSL_CTX_set_verify` or a
custom callback in a bundled `.so`, per [[Network-Interception]]'s native-layer section) or a
second, non-`TrustManagerImpl`/non-`CertificatePinner` Java class doing its own chain validation
very early — a static string search for `SSLInterceptor` in the decompiled app would narrow this
down quickly once static analysis of the APK is added to this case study's `source/`.

## Generalizing the pattern

To find other statically embedded secrets the same way: grep this and future captures' request
bodies for `client_secret=`, `api[_-]?key`, `Authorization: Basic ` (base64-encoded
`user:secret`), or any `grant_type=client_credentials` request — all machine-to-machine auth
patterns that, by definition, cannot depend on anything the end user typed, so the credential has
to live somewhere in the app itself.

## Related concepts

- [[Network-Interception]] — Java-layer vs. native-layer pinning, directly relevant to the open
  `SSL1` lead above.
- [[Java-Layer-Hooking]] — the hooking pattern behind all three bypasses in
  [[http-pinning-bypass-and-dump.js]].

## Open questions / next steps

- [ ] Identify what triggers the `SSLInterceptor` / `SSL1` telemetry error specifically — which
      connection, and whether it's a native or a not-yet-hooked Java trust check.
- [ ] Decompile the APK (Jadx/apktool) far enough to search for `SSLInterceptor` and confirm
      whether it's Java or JNI-backed.
- [ ] Decide on responsible disclosure for the embedded OAuth2 secret (see
      `local/oauth-client-credentials-raw.md`, not tracked by git).

## See also

- [[Case-Studies]]
