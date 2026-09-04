---
tags: [case-study-note]
case_study: "Poste-Italiane"
created: 2026-09-03
---

# Frida-Server-Setup-On-The-Blackview

## Question / goal

Get `frida -U` actually attaching to a process on the physical test device (a rooted Blackview
BV5200 Pro, Android 12, MediaTek, `arm64-v8a,armeabi-v7a,armeabi`) before pointing
[[http-pinning-bypass-and-dump.js]] at the real target. This device had never been used for Frida
before, so the environment itself needed shaking out first.

## How this was found

`frida-ps -U` failed immediately with `Failed to enumerate processes:
java.lang.NullPointerException: ... PackageManager.queryIntentActivities(...) on a null object
reference`. That looked like an application-enumeration bug, so the first check was whether
attaching to a known PID worked at all, bypassing enumeration entirely — it didn't:
`frida -U -p <pid>` on `com.android.chrome` returned `Failed to attach: agent connection closed
unexpectedly`.

`adb shell "su -c 'ps -A | grep frida'"` showed a `frida-server` already running (auto-started at
boot by a Magisk late-start module, `/data/adb/frida/frida.sh` → `/data/adb/frida/frida-server -D`).
Checking its version directly (`/data/adb/frida/frida-server --version`) returned `17.17.0`, while
the host's `frida` Python package was still `17.2.16` — a large protocol version gap, and the
prime suspect for both failures. `pip install -U frida frida-tools` brought the host to `17.17.0`
to match. This did **not** fix the enumeration NullPointerException (still present after matching
versions — it turned out to be an unrelated, harmless issue with this ROM's `frida-helper`
application-enumeration path, not something blocking actual instrumentation), but it changed the
attach failure's signature enough to keep investigating rather than assume version skew was the
whole story.

The attach still failed the same way after the version match, so the next step was reading
`dmesg`/`logcat` around the exact moment of a fresh attach attempt instead of guessing further.
That surfaced the real cause:

```
09-03 22:51:14.850 libc: Fatal signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x24 in tid 19104 (.android.chrome), pid 18912
09-03 22:51:15.497 DEBUG: #00 pc 00511a6e  /memfd:frida-agent-32.so (deleted)
```

`frida-agent-32.so` — the **32-bit** agent — crashing with a near-null fault address inside the
injected agent itself, not inside Chrome's own code. `com.android.chrome` was running as a 32-bit
process on this device despite the device supporting `arm64-v8a`
(`ro.product.cpu.abilist=arm64-v8a,armeabi-v7a,armeabi`), most likely because Play delivers a
32-bit-preferring APK split to this low-RAM MediaTek device to save memory. So this isn't a
Poste-Italiane-specific problem: it's a device-wide issue that will hit **any** app the device
happens to run as 32-bit, which — until proven otherwise for `com.posteitaliane.spim` specifically
— has to be assumed possible for the real target too.

Two dead ends worth recording so they aren't retried blindly next time:

- `--policy-softener=system` and `-C`/`--ignore-crashes` on `frida-server` — neither changed the
  crash signature. The crash is inside the 32-bit agent's own startup, before the parts these
  flags affect (SELinux policy softening, native crash-reporter integration) would matter.
- Redirecting `frida-server`'s stdout/stderr to a file on-device via `nohup ... > log 2>&1 &`
  produced an empty log even with `-v`. Not investigated further (output is presumably
  fully-buffered when stdout isn't a tty) — `logcat`/`dmesg` around the attach attempt was the
  signal that actually worked, not the server's own log file.

## Relevant source

- [[http-pinning-bypass-and-dump.js]]

## Excerpt

```
09-03 22:51:14.850 19108 19104 F libc    : Fatal signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x24 in tid 19104 (.android.chrome), pid 18912 (.android.chrome)
09-03 22:51:15.497 19108 19108 F DEBUG   : signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x24
09-03 22:51:15.497 19108 19108 F DEBUG   :       #00 pc 00511a6e  /memfd:frida-agent-32.so (deleted)
```

## Analysis

`fault addr 0x24` is a classic near-null pointer dereference (a small fixed offset off a null
`this`/vtable pointer), happening inside the agent's own startup rather than in application code —
consistent with a known class of Frida issues where the 32-bit agent fails to initialize on some
Android 12+ / vendor-patched-kernel combinations, while the 64-bit agent on the same device works
fine. Since `frida-server` itself is 64-bit (`arm64-v8a`) and only injects a 32-bit agent when the
**target process** is 32-bit, the fix is not to patch Frida but to make sure the target process
runs as 64-bit in the first place.

Android's package installer lets you force which native-library ABI a multi-arch APK gets
installed for:

```
adb install --abi arm64-v8a <apk>
# or, for an app already installed:
adb shell pm install-existing --abi arm64-v8a com.posteitaliane.spim   # not always supported by pm
```

For an app installed normally through Play Store (the realistic path for `com.posteitaliane.spim`
on this device), the reliable way to force the 64-bit split is to uninstall and reinstall the APK
directly with `adb install --abi arm64-v8a` rather than letting Play pick the ABI automatically.

## Generalizing the pattern

Before attaching Frida to *any* app on a device that supports both 32-bit and 64-bit ABIs, check
which one the target process actually runs as first:

```
adb shell "su -c 'cat /proc/$(pidof <package>)/cmdline'"     # confirms the process exists
adb shell "su -c 'grep -c 32 /proc/$(pidof <package>)/maps'" # rough signal, or just:
adb shell "su -c 'file /proc/$(pidof <package>)/exe'" 2>/dev/null || \
adb shell "su -c 'cat /proc/$(pidof <package>)/status | grep -i abi'"
```

A cleaner one-liner: `frida-ps -Uai` normally lists the identifier and PID; when it's usable, a
crash in `frida-agent-32.so` immediately after a successful `frida -U -f <package>` spawn is the
signature to watch for and is what triggers the reinstall-with-`--abi arm64-v8a` workaround.

## Related concepts

- [[Frida-Fundamentals]] — spawn vs. attach, and what `frida-server` actually does on-device.

## Open questions / next steps

- [x] `com.posteitaliane.spim` installed as 64-bit (`arm64-v8a` split) directly from Play — the
      32-bit-agent crash never reproduced against the real target.
- [x] Revisit the `frida-ps -U` NullPointerException if it ever turns out to matter — it did, once,
      on 2026-09-04; see the addendum below.

## Addendum: `frida-server` wedging after a Magisk module change (2026-09-04)

The previously-"harmless" `PackageManager.queryIntentActivities` NullPointerException came back, but
this time it blocked real work: `frida -U -f com.posteitaliane.spim` failed to spawn with the exact
same NPE, and `frida -U -p <pid>` against the already-running app process (confirmed alive via
`adb shell "su -c 'ps -A | grep posteitaliane'"`) hung indefinitely instead of erroring. A completely
independent one-shot `frida -U -p <pid> -e "console.log('ping')"` also hung, before even printing
`ping` — ruling out anything specific to the login-diagnostics script and pointing at `frida-server`
itself being wedged, not the target app or any one script.

This session had just installed the Shamiko Magisk module (per the user's own device-trust
troubleshooting, alongside `root-and-frida-hiding.js`) shortly before the hang appeared, though a
direct causal link was not confirmed — it's equally possible this was triggered by the two spawn
attempts that failed with the NPE moments earlier, leaving `frida-server`-side bookkeeping in a bad
state.

**Fix**: kill and restart `frida-server` cleanly, rather than trying to reuse the existing daemon:

```
adb shell "su -c 'pkill -f frida-server'"
adb shell "su -c 'kill -9 <pid>'"   # pkill alone left the process in the process table once
adb shell "su -c '/data/adb/frida/frida-server &'"
```

After the restart, `frida-ps -Uai` enumerated normally again and a fresh `-p <pid>` attach to the
*same, still-running, never-restarted* `com.posteitaliane.spim` process completed in a few seconds,
proving the target app process itself was never the problem. One extra wrinkle: the very next
`-p <pid>` attach attempt (before the app itself was force-stopped) hung again the same way — an
agent from the killed session was likely still injected in the target process, so `frida-server`
restarting alone wasn't enough; `adb shell "am force-stop com.posteitaliane.spim"` followed by a
fresh `-f` spawn was what actually produced a clean, responsive session.

**Generalizing**: if `frida-ps -U`/`-Uai` throws this specific `PackageManager` NPE and a direct
`-p <pid>` attach also hangs (not just errors) — even against a process confirmed alive via `adb
shell ps` — suspect a wedged `frida-server` daemon before suspecting the target app or any Frida
script. Restart the daemon first; if that alone doesn't fix a hang on a process that was already
attached to once before, force-stop and relaunch the target app too, since a half-injected agent can
outlive the daemon that injected it.

## See also

- [[Case-Studies]]
