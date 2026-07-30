---
tags: [cheatsheet]
subject: "Android command-line tooling: adb, avdmanager, emulator"
topics: ["Dalvik-Bytecode", "ARM64-Android", "Frida-Dynamic-Instrumentation"]
created: 2026-07-30
---

# ADB-AVD-Cheatsheet

Quick lookup — not a full explanation. See [[Dalvik-Bytecode]], [[ARM64-Android]], and [[Frida-Dynamic-Instrumentation]] for the "why" behind installing/attaching to an app in the first place; see [[Frida-Server-Setup]] for pushing and running `frida-server` specifically.

## Devices and connections

| Command / syntax | Does |
|---|---|
| `adb devices` | List connected devices/emulators and their state (`device`, `offline`, `unauthorized`) |
| `adb devices -l` | Same, with model/product details |
| `adb -s <serial> <command>` | Target one specific device/emulator when more than one is connected (serials look like `emulator-5554` or a hardware device's ID) |
| `adb connect <ip>:<port>` | Connect to a device/emulator over TCP/IP instead of USB |
| `adb disconnect <ip>:<port>` | Drop a TCP/IP connection |
| `adb kill-server` / `adb start-server` | Restart the `adb` host daemon (fixes most "device not found"/stuck states) |
| `adb root` / `adb unroot` | Restart `adbd` on the device as root — works on emulators and `userdebug`/`eng` builds, not on a stock production-signed device |
| `adb remount` | Remount `/system` (and `/vendor`) read-write — needs `adb root` first, and (on an emulator) `-writable-system` at boot |
| `adb reboot` / `adb reboot bootloader` / `adb reboot recovery` | Reboot into normal/bootloader/recovery mode |
| `adb shell getprop ro.build.version.release` | Read the device's Android version |
| `adb shell getprop ro.product.cpu.abi` | Read the device's CPU ABI (`x86_64`, `arm64-v8a`, ...) — matters when picking a native `.so` to push |
| `adb emu kill` | Kill the currently targeted emulator instance from the host side |

## AVD management (`avdmanager`, `sdkmanager`)

| Command / syntax | Does |
|---|---|
| `avdmanager list avd` | List AVDs already created on this machine |
| `avdmanager list target` | List installed platform targets |
| `avdmanager list device` | List built-in device profiles (Pixel 5, Nexus 5X, ...) usable with `-d` |
| `sdkmanager --list` | List installable/updatable SDK packages, including system images |
| `sdkmanager "system-images;android-34;google_apis;x86_64"` | Install a specific system image (Google APIs, no Play Store — needed for a rootable/writable-system image) |
| `avdmanager create avd -n <name> -k "system-images;android-34;google_apis;x86_64" -d pixel_5` | Create a new AVD from an installed system image and device profile |
| `avdmanager delete avd -n <name>` | Delete an AVD |

> [!tip] Which system image to pick for reversing work
> Prefer a `google_apis` (not `google_apis_playstore`) image when the goal is rooting/instrumenting the emulator — Play Store images ship a locked-down, non-rootable `/system`. This is also the image type that supports `-writable-system`, needed before `adb remount` or a persistent `frida-server` install.

## Launching emulators (`emulator`)

| Command / syntax | Does |
|---|---|
| `emulator -list-avds` | List AVDs (equivalent to `avdmanager list avd`, callable from the `emulator` binary itself) |
| `emulator -avd <name>` | Start an emulator instance for that AVD |
| `emulator -avd <name> -port 5556` | Start it bound to a specific console port — needed to run several emulators at once (each takes 2 consecutive ports; `adb` then shows it as `emulator-5556`) |
| `emulator -avd <name> -writable-system` | Boot with `/system` mountable read-write (prerequisite for `adb remount`) |
| `emulator -avd <name> -no-snapshot-load` | Cold boot instead of resuming a saved snapshot |
| `emulator -avd <name> -wipe-data` | Reset the AVD to a factory-clean state before booting |
| `emulator -avd <name> -no-window` | Headless boot (no GUI window) — useful for CI or scripted multi-instance runs |
| `emulator -avd <name> -netdelay none -netspeed full` | Disable the emulator's default simulated network latency/throttling |
| `emulator -avd <name1> -port 5554 & emulator -avd <name2> -port 5556 &` | Start two independent emulator instances in parallel (background jobs in a POSIX shell) |

## Installing / uninstalling APKs

| Command / syntax | Does |
|---|---|
| `adb install app.apk` | Install an APK from the host machine |
| `adb install -r app.apk` | Reinstall, keeping the app's existing data |
| `adb install -g app.apk` | Grant all runtime permissions automatically at install time |
| `adb install -t app.apk` | Allow installing a test-only (`android:testOnly="true"`) APK |
| `adb install-multiple base.apk split1.apk split2.apk` | Install an app shipped as multiple split APKs (from an Android App Bundle) |
| `adb push app.apk /data/local/tmp/ && adb shell pm install /data/local/tmp/app.apk` | Install from a path already on the device — a fallback when `adb install` itself fails on a large file or a locked-down host policy |
| `adb uninstall com.package` | Uninstall an app entirely |
| `adb shell pm uninstall -k --user 0 com.package` | Uninstall for the current user only, keeping data/cache around |
| `adb shell pm clear com.package` | Wipe an installed app's data/cache without uninstalling it |

## Package search and inspection

| Command / syntax | Does |
|---|---|
| `adb shell pm list packages` | List every installed package's name |
| `adb shell pm list packages \| grep <fragment>` | Find a package's exact name from a partial guess (the visible app label and the package name are often unrelated) |
| `adb shell pm list packages -3` | Third-party (user-installed) packages only |
| `adb shell pm list packages -s` | System packages only |
| `adb shell pm list packages -e` / `-d` | Enabled-only / disabled-only packages |
| `adb shell pm path com.package` | Print the on-device path(s) of an installed app's APK(s) — the first step to pulling it back off the device |
| `adb pull $(adb shell pm path com.package \| cut -d: -f2) ./app.apk` | Pull an already-installed APK back to the host for static analysis |
| `adb shell dumpsys package com.package` | Full package dump: version, permissions, declared activities/services/receivers |
| `adb shell dumpsys package com.package \| grep -A5 "requested permissions"` | Just the permissions a package requests |

## Launching apps and activities

| Command / syntax | Does |
|---|---|
| `adb shell monkey -p com.package -c android.intent.category.LAUNCHER 1` | Launch an app by package name alone, without knowing its main activity's class name |
| `adb shell am start -n com.package/.MainActivity` | Launch a specific, named activity |
| `adb shell am start -a android.intent.action.VIEW -d "https://example.com/path"` | Launch via an implicit intent — e.g. to trigger a deep link handler |
| `adb shell am start-activity -W -n com.package/.MainActivity` | Same as `am start`, but wait and print launch timing/result |
| `adb shell am force-stop com.package` | Force-stop an app (all its processes) |
| `adb shell am kill com.package` | Kill an app's background process only, if the OS considers it killable (weaker than `force-stop`) |

### Running the same app on several emulators/devices at once

Android has no built-in "multiple instances of one app in one running system" (that's an OEM-specific "app cloning" feature, not a stock `adb`/AVD capability) — but nothing stops the same APK from running simultaneously on **several separate emulator instances**, each with its own serial:

```bash
for serial in $(adb devices | awk 'NR>1 && $2=="device" {print $1}'); do
  adb -s "$serial" install -r app.apk
  adb -s "$serial" shell am start -n com.package/.MainActivity
done
```

For separate profiles on the *same* device/emulator instead (work profile, secondary user), add `--user <id>` to `pm install`/`am start` — list user IDs first with `adb shell pm list users`.

## Files and logs

| Command / syntax | Does |
|---|---|
| `adb push <local> <remote>` | Copy a file from host to device |
| `adb pull <remote> <local>` | Copy a file from device to host |
| `adb logcat` | Stream the full device log |
| `adb logcat -s TAG` | Filter by a single log tag |
| `adb logcat *:E` | Only `ERROR`-level (and above) lines, any tag |
| `adb logcat -c` | Clear the log buffer (useful right before reproducing a specific crash, see [[Anti-Tampering-Pattern-Workflow]]) |
| `adb shell screenrecord /sdcard/demo.mp4` | Record the device screen to a file, then `adb pull` it off |

## Common pitfalls

- Forgetting `-s <serial>` with more than one device/emulator connected — `adb` refuses with "more than one device/emulator" instead of guessing.
- `adb root` silently doing nothing on a production-signed device/build — it only works on emulators and `userdebug`/`eng` builds, not on a stock retail device without a separate root exploit.
- Confusing the app's visible label ("WhatsApp") with its package name (`com.whatsapp`) — `pm list packages | grep` on a guessed fragment, not the label, is what actually works.
- Trying `adb install` on a Play Store–distributed app shipped as split APKs — plain `install` only takes one file; `install-multiple` is required for split installs.
- Picking a `google_apis_playstore` system image for an AVD meant to be rooted/instrumented — it doesn't support `-writable-system`, unlike a plain `google_apis` image of the same API level.
- On Windows, running these commands from **Git Bash** can silently mangle a Unix-style remote path (`/data/local/tmp/...`) into a Windows one via MSYS path conversion — prefix with `MSYS_NO_PATHCONV=1`, or use PowerShell/cmd instead. See [[Frida-Server-Setup]] for the full explanation (same root cause as the equivalent note in [[Frida-JS-API-Cheatsheet]]).

## See also

- [[Dalvik-Bytecode]]
- [[ARM64-Android]]
- [[Frida-Dynamic-Instrumentation]]
- [[Frida-Server-Setup]]
- [[Frida-JS-API-Cheatsheet]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
