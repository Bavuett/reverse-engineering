---
tags: [tool]
tool_name: "frida-server"
homepage: "https://frida.re/"
version: "17.2.16"
created: 2026-07-28
---

# Frida-Server-Setup

## Purpose

`frida-server` is the on-device half of Frida (see [[Frida-Fundamentals]]) — a privileged daemon that must be running on the target before any client-side script can attach or spawn. On a real, already-rooted device this is a five-minute push-and-run. On an emulator it depends entirely on the AVD's architecture and build type lining up correctly, which is what this note actually walks through — the failure modes here are almost all architecture/root mismatches, not Frida itself.

## Installation

The two AVD properties that matter, and why:

| Requirement | Why |
|---|---|
| **Non-Play-Store system image** (`google_apis`, not `google_apis_playstore`) | Play Store images are production (`user`) builds — no `adb root` without patching. `google_apis` images are `userdebug` — `adb root` just works. |
| **Architecture matching the host CPU**, with ARM translation (`libndk_translation`) present | The Android Emulator's QEMU2 backend refuses to run a guest system image whose CPU architecture doesn't match the host (an `arm64-v8a` AVD hard-fails on an x86_64 host with "Avd's CPU Architecture 'arm64' is not supported"). An x86_64 `google_apis` image with `libndk_translation` present (check via `adb shell find /system -iname '*ndk_translation*'`) can still run `arm64-v8a`/`armeabi-v7a` **app** native code through binary translation, even though the OS itself is x86_64 — which matters directly whenever the target APK ships only an `arm64_v8a` native split (a common case for Play-distributed apps, since Play only serves the ABI matching the device it thinks it's installing to). |

Concretely, on an x86_64 Windows host:

```
sdkmanager "system-images;android-30;google_apis;x86_64"
avdmanager create avd -n MyAVD -k "system-images;android-30;google_apis;x86_64" -d pixel_6
emulator -avd MyAVD -no-window -writable-system
```

`frida-server`'s version **must match** the installed client (`frida`/`frida-tools` on the host — check with `frida --version`). Download the matching release asset from the [Frida GitHub releases](https://github.com/frida/frida/releases) — `frida-server-<version>-android-x86_64.xz` for an x86_64 AVD (not `-arm64`, even if the app being targeted is arm64 — `frida-server` itself runs as a native process on the real, physical CPU, which is x86_64; only the app's own code goes through ARM translation):

```
adb root
adb push frida-server-<version>-android-x86_64 /data/local/tmp/frida-server
adb shell chmod 755 /data/local/tmp/frida-server
adb forward tcp:27042 tcp:27042
adb shell "nohup /data/local/tmp/frida-server >/data/local/tmp/frida-server.log 2>&1 &"
```

Verify with `frida-ps -U` from the host — a full process listing confirms the client/server handshake worked.

## Common commands / workflows

| Command | Effect |
|---|---|
| `adb devices` | Confirm the emulator/device is visible and in `device` (not `offline`) state |
| `adb root` | Restart `adbd` as root — required before pushing to `/data/local/tmp` with execute permissions and before running `frida-server` itself |
| `adb shell whoami` | Should print `root` if `adb root` succeeded |
| `adb shell getprop ro.build.type` | `userdebug` = rootable; `user` = production build, `adb root` will fail |
| `adb shell ps -A \| grep frida-server` | Confirm the daemon is actually running |
| `frida-ps -U` | End-to-end verification: lists the device's process table through the running `frida-server` |

## Tips & gotchas

- `frida-server` does **not** survive an emulator restart or a `cold boot` — it has to be relaunched (the four `adb`/`nohup` commands above) every session.
- On Windows, running `adb push`/`adb shell` with an absolute Unix-style remote path (`/data/local/tmp/...`) from **Git Bash** can get silently mangled into a Windows path by MSYS's automatic path conversion, producing a confusing `secure_mkdirs failed: No such file or directory`. Either run the command from PowerShell/cmd instead, or prefix the whole invocation with `MSYS_NO_PATHCONV=1` — but then any *local* Unix-style source path in the same command also stops being auto-converted, so it's usually simpler to just switch to PowerShell for `adb push`.
- If the client and `frida-server` versions don't match exactly (major.minor.patch), the client refuses to connect with a version-mismatch error — re-download the matching `frida-server` release asset rather than assuming a close version is fine.
- A `google_apis_playstore` image (needed if the app itself requires real Play Services at runtime) trades away easy root — getting Frida working there means patching the boot image (Magisk-style) instead of a plain `adb root`, which is out of scope for this note.

## See also

- [[Frida-Dynamic-Instrumentation]]
- [[Frida]] — the ARM64-Android topic's tool note, for Frida usage once it's already running.

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
