---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "adb shell commands, not app source"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Forcing-A-64-Bit-Split-Install-To-Dodge-The-32-Bit-Agent-Bug

## Context

[[Android-ABIs-And-Emulation]] is written around emulator/AVD ABI mismatches; this is the same ABI model applying to a **physical** device instead. Testing Frida against Chrome (as a stand-in, before the real target app was installed — see [[Reading-A-Native-Crash-Backtrace-To-Diagnose-An-Agent-Failure]]) crashed because Chrome ran as a 32-bit process on this low-RAM MediaTek device despite the device's own `ro.product.cpu.abilist` including `arm64-v8a` — Play can deliver a 32-bit-preferring split to a device like this to save memory, independent of what the device is capable of running.

## Original path

`` adb shell commands, not app source ``

## Snippet

```
# Check what ABI(s) a device actually supports before assuming a crash is Frida's fault
adb shell getprop ro.product.cpu.abilist

# Force the 64-bit native-library split specifically, rather than letting Play
# pick automatically — the fix for a target app installed 32-bit despite 64-bit
# device support
adb install --abi arm64-v8a target.apk

# For an app already installed via Play (not always supported by pm, worth
# trying first since it avoids a full reinstall):
adb shell pm install-existing --abi arm64-v8a com.posteitaliane.spim
```

### Example — confirming which split actually landed, after install, without guessing

Rather than trusting that `adb install --abi arm64-v8a` (or Play's own automatic choice) did what it claims, checking the *running process's* actual bitness closes the loop:

```
adb shell "su -c 'cat /proc/$(pidof com.posteitaliane.spim)/status | grep -i abi'"
# or, more directly:
adb shell "su -c 'file /proc/$(pidof com.posteitaliane.spim)/exe'"
# ELF 64-bit LSB pie executable, ARM aarch64, ...  <- confirms 64-bit, matching arm64-v8a
```

This is the check that, run early, would have predicted the Chrome crash in [[Reading-A-Native-Crash-Backtrace-To-Diagnose-An-Agent-Failure]] before it happened — and the same check, run against `com.posteitaliane.spim` after install, is what confirmed the workaround genuinely wasn't needed for the real target, rather than assuming so from Play's install behavior alone.

## Notes

- Frida's control server (`frida-server`) is itself always 64-bit on a 64-bit device — this bug is specifically about the **injected agent** matching the **target process's** bitness, not about `frida-server`'s own architecture. A 64-bit `frida-server` still correctly detects a 32-bit target process and injects `frida-agent-32.so` for it, which is precisely the module that crashed.
- Documented as a real, tested workaround but ultimately **not needed** for the actual case study target: `com.posteitaliane.spim` installed as `arm64-v8a` naturally from Play, without ever triggering the bug that Chrome had. Worth keeping the workaround on hand regardless — the same device behavior (Play delivering a 32-bit split to save memory) is a per-app decision, not a fixed device property, so a *different* target app on this same device could still need it.
- The generalized detection pattern from [[Android-ABIs-And-Emulation]]'s own chapter — checking whether a process runs 32- or 64-bit before attaching anything to it — is the check that would have predicted this crash ahead of time rather than discovering it via a SIGSEGV.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Module-And-Process-API]]
- [[Android-ABIs-And-Emulation]]
- [[Reading-A-Native-Crash-Backtrace-To-Diagnose-An-Agent-Failure]] and [[Poste-Italiane]] in [[Case-Studies]]
