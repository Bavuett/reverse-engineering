---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "adb logcat output (device-side crash log), not app source"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Reading-A-Native-Crash-Backtrace-To-Diagnose-An-Agent-Failure

## Context

Before the real target app was even installed, testing Frida against Chrome as a stand-in crashed it
outright. [[Native-Memory-And-ARM64]] is normally about reading a *target app's* native code — this is
the same fault-address/backtrace-reading skill turned on Frida's own injected agent, to tell a genuine
device-architecture problem apart from a script bug.

## Original path

`` adb logcat -d output around the crash timestamp, not app source ``

## Snippet

### Example 1 — the crash itself

```
09-03 22:51:14.850 libc: Fatal signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x24 in tid 19104 (.android.chrome), pid 18912
09-03 22:51:15.497 DEBUG: #00 pc 00511a6e  /memfd:frida-agent-32.so (deleted)
```

### Example 2 — ruling out two plausible-looking fixes, using the same backtrace

Two `frida-server` flags looked like natural first things to try, given the crash — SELinux policy
enforcement and Frida's own crash-reporter integration both sounded like they *could* plausibly matter
for an agent that dies on injection:

```
frida-server --policy-softener=system   # no change: same fault addr, same crashing module
frida-server -C                         # (--ignore-crashes) no change either
```

Neither flag touched the outcome, and re-reading the *same* backtrace explains why without needing to
try a third thing: `pc 00511a6e /memfd:frida-agent-32.so` places the crash inside the agent's own
startup code, executing *before* either SELinux policy softening or the native crash-reporter hook
would ever run. A flag that changes behavior downstream of a point the code never reaches can't fix a
crash that happens upstream of it — the backtrace alone was enough to rule both out without spending
time running them, in hindsight.

## Notes

- `fault addr 0x24` is a classic near-null-pointer dereference (a small fixed offset off a null
  `this`/vtable pointer) — the same signature you'd read out of an app's own native crash, except the
  crashing module here (`/memfd:frida-agent-32.so`) is Frida's injected agent itself, not app code.
  `/memfd:` names an anonymous memory-backed file, exactly how Frida injects its agent without writing
  a `.so` to disk.
- The `-32` in the module name was the actual diagnostic payload: it meant the **32-bit** Frida agent
  was being injected, into a process (`.android.chrome`) running as 32-bit despite the device
  supporting `arm64-v8a` — see [[Android-ABIs-And-Emulation]]'s ABI-per-process model.
  Frida-server itself stayed 64-bit and healthy the whole time; only the agent injected into this one
  32-bit target process crashed.
- This ruled a whole category of fixes out immediately: `--policy-softener=system` and
  `-C`/`--ignore-crashes` on `frida-server` (SELinux/crash-reporter flags) were tried first and changed
  nothing, because the crash happens inside the agent's own startup, before either of those would ever
  come into play — reading the fault address and module name up front would have ruled both out without
  spending time on them at all.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Native-Memory-And-ARM64]]
- [[Frida-Server-Setup-On-The-Blackview]] and [[Poste-Italiane]] in [[Case-Studies]]
