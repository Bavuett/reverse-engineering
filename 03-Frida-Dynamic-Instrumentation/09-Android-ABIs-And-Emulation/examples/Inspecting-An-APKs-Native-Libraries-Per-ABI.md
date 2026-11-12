---
tags: [example]
level: 2
aliases: ["APK lib folders", "which ABIs does an APK ship", "extractNativeLibs"]
created: 2026-11-12
---

# Example: Inspecting-An-APKs-Native-Libraries-Per-ABI

> [!info] Level 2 — intermediate
> Combines APK layout, install-time ABI selection and hooking: what's in each `lib/<abi>/` folder decides which ABI the app runs under — and an uneven set of libraries across ABIs predicts which environments will break.

## Goal

List an APK's native libraries per ABI, predict the process ABI on a given device, and know where Frida will find the libraries at runtime. Belongs to [[Android-ABIs-And-Emulation]].

## Commands

```text
$ unzip -l app.apk 'lib/*'                       # or: apktool d, then ls lib/*/
$ unzip -p app.apk AndroidManifest.xml | ...     # binary XML: use apktool or aapt2 to read
$ aapt2 dump badging app.apk | grep native-code
native-code: 'arm64-v8a' 'armeabi-v7a' 'x86' 'x86_64'
```

## Step by step

1. **One folder per ABI**: `arm64-v8a` (64-bit ARM), `armeabi-v7a` (32-bit ARM), `x86_64`, `x86`. Each holds that ABI's build of the app's `.so` files.
2. **Install-time choice.** The package manager walks the device's ABI list (`ro.product.cpu.abilist`) in order and picks the *first ABI for which the APK has any library*. That ABI becomes `primaryCpuAbi`, and only its folder is used.
3. **Uneven folders are a trap.** If one ABI folder lacks a library that others have, the choice in step 2 still happens — and the missing library fails later, at `System.loadLibrary`, with `UnsatisfiedLinkError`.
4. **`extractNativeLibs="false"`** (in the manifest's `<application>`) means libraries stay inside the APK, stored uncompressed and page-aligned, and are mapped from there. In Frida, `Module.path` then reads `/data/app/…/base.apk!/lib/arm64-v8a/libx.so`; `getModuleByName("libx.so")` still works.
5. **Split APKs.** Play-delivered apps often move libraries into `split_config.arm64_v8a.apk`; inspect the splits (`adb shell pm path <pkg>` lists them), not just `base.apk`.
6. **For analysis, pick the ABI you'll instrument.** Disassemble the `arm64-v8a` build if the process is 64-bit ARM — the 32-bit build has different code, offsets and instruction set.

## Compared with real code

PressReader's APK ships these libraries (sizes in bytes):

| ABI | `libdatastore_shared_counter.so` | `libencrypt.so` | `libodyssey.so` |
| --- | --- | --- | --- |
| `arm64-v8a` | 7,112 | 785,448 | 4,867,208 |
| `armeabi-v7a` | 4,416 | 439,516 | 3,892,276 |
| `x86_64` | 6,224 | — | — |
| `x86` | 5,148 | — | — |

and its manifest sets `android:extractNativeLibs="false"`. Reading the table with the rules above:

- On ARM devices everything is present; a 64-bit ARM phone installs it as `arm64-v8a`.
- `libdatastore_shared_counter.so` (AndroidX DataStore, [[Reading-Datastore-Shared-Counter-Cold]]) comes from a library dependency built for all four ABIs, while PressReader's own `libencrypt.so` and `libodyssey.so` were built for ARM only.
- On an x86_64 emulator, `x86_64` is first in the ABI list and *has* a library, so the app is expected to install as `x86_64` — and then lack `libencrypt.so`, so loading it (in `Encryption`, [[Reading-A-Native-Facade-Class-Cold]]) would fail unless ARM translation is used instead. That is why ARM devices (or an ARM-translating emulator, [[Running-ARM-Apps-On-An-x86-Emulator-With-Translation]]) suit this app.
- The ARM64 offsets quoted in the vault (`Encryption_decrypt` at `0x589d0`) are for the `arm64-v8a` build only.

## See also

- [[Android-ABIs-And-Emulation]]
- [[Checking-Process-Arch-And-Pointer-Size]]
- [[Android-Native-Internals]] in [[ARM64-Android]]
- [[PressReader]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
