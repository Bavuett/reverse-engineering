---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "adb/frida-server shell commands (device-side), not app source"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Diagnosing-A-Wedged-Frida-Server

## Context

Mid-session, both `frida -U -f com.posteitaliane.spim ...` (spawn) and `frida -U -p <pid> ...` (attach
to a process confirmed alive via `adb shell ps`) started failing — spawn with `Failed to spawn:
java.lang.NullPointerException: ... PackageManager.queryIntentActivities(...)`, attach by hanging
indefinitely instead of erroring. This is the [[Frida-Fundamentals]] client/server model failing at
the *server* layer, not anything about the target app — the fix is entirely on the device side, not in
any script.

## Original path

`` adb/frida-server shell commands, run against the Blackview BV5200 Pro test device ``

## Snippet

### Example 1 — the fix

```
# 1. Confirm frida-server is actually running (it was) before assuming it needs a fresh start
adb shell "su -c 'ps -A | grep frida-server'"

# 2. Kill it — pkill alone left a stale entry in the process table once
adb shell "su -c 'pkill -f frida-server'"
adb shell "su -c 'kill -9 <pid>'"

# 3. Restart clean
adb shell "su -c '/data/adb/frida/frida-server &'"

# 4. Verify enumeration works again before trying to attach to anything
frida-ps -Uai
```

If a `-p <pid>` attach to a process that was previously (successfully) attached-to still hangs *after*
the restart above, the target process itself likely still has a half-injected agent from the killed
session — `adb shell am force-stop <package>` and a fresh `-f` spawn is what actually produces a clean
session at that point, not another restart of the daemon alone.

### Example 2 — the earliest symptom, before it was understood as a wedge at all

The very first sign of trouble, well before any hang, was `frida-ps` itself failing on a simple
enumeration call — no attach attempted yet, no target process involved:

```
$ frida-ps -Uai
Failed to enumerate applications: java.lang.NullPointerException: Attempt to invoke virtual method
'java.util.List android.content.pm.PackageManager.queryIntentActivities(android.content.Intent, int)'
on a null object reference
```

Read in isolation this looks like an app-enumeration bug specific to this device (and had, in a
previous session, actually been that — a genuinely harmless quirk of this ROM's `frida-helper`, see
[[Frida-Server-Setup-On-The-Blackview]]'s original note). The diagnostic mistake here would have been
trusting that precedent and moving on; retrying a `-p <pid>` attach immediately after is what upgraded
this from "known harmless" to "the daemon is actually wedged this time" — the same error string doesn't
always mean the same root cause twice.

## Notes

- The give-away that this was a `frida-server`-side problem rather than an app-side one: a completely
  unrelated one-shot command, `frida -U -p <pid> -e "console.log('ping')"`, also hung *before even
  printing `ping`* — that rules out anything in the target script or the target app's own state, since
  nothing app-specific had run yet.
- `frida-ps -U`/`-Uai` throwing the `PackageManager.queryIntentActivities` `NullPointerException`
  turned out to be the same underlying wedge, not a separate, harmless issue (see
  [[Frida-Server-Setup-On-The-Blackview]]'s original note on this device, where the same message had
  been seen once before and shrugged off as harmless — this session shows it can in fact block real
  work).
- No confirmed root cause for *why* the daemon wedged this specific time — the leading candidate is
  two back-to-back failed spawn attempts leaving server-side bookkeeping in a bad state, though
  installing the Shamiko Magisk module minutes earlier is also plausible and wasn't ruled out.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Frida-Fundamentals]]
- [[Frida-Server-Setup-On-The-Blackview]] and [[Poste-Italiane]] in [[Case-Studies]]
