---
tags: [example]
level: 1
aliases: ["Process.arch", "is the app 32 or 64 bit"]
created: 2026-11-12
---

# Example: Checking-Process-Arch-And-Pointer-Size

> [!info] Level 1 — basics
> One idea: the device's ABI and the *process's* ABI are different questions. Ask both before writing native hooks, because offsets, register names and pointer widths all depend on the process.

## Goal

Determine, from the host and from inside the process, which ABI an app actually runs under. Belongs to [[Android-ABIs-And-Emulation]].

## From the host

```text
$ adb shell getprop ro.product.cpu.abilist
arm64-v8a,armeabi-v7a,armeabi              # device supports 64- and 32-bit ARM
$ adb shell pidof com.example.app
12345
$ adb shell cat /proc/12345/maps | grep -m1 -E "app_process|linker"
... /system/bin/linker64                   # 64-bit process (a 32-bit one maps /system/bin/linker)
$ adb shell pm dump com.example.app | grep -i primaryCpuAbi
    primaryCpuAbi=arm64-v8a
```

## From inside (Frida)

```javascript
console.log(`arch=${Process.arch} pointerSize=${Process.pointerSize}`);

const mod = Process.findModuleByName("libtarget.so");
if (mod !== null) console.log(`libtarget.so from ${mod.path}`);   // which lib/<abi>/ folder it came from

// Write width-independent code where it matters:
const readPtrField = (obj, off) => obj.add(off).readPointer();       // 4 or 8 bytes, as appropriate
```

## Step by step

1. **`ro.product.cpu.abilist`** lists what the device *can* run, in preference order. A 64-bit ARM device usually also runs 32-bit ARM; newer ones (Pixel 7 onwards, many 2024+ devices) are 64-bit only.
2. **The process ABI is chosen at install time** (`primaryCpuAbi`), from the ABIs the APK ships libraries for. An app with only `armeabi-v7a` libraries runs as a 32-bit process even on a 64-bit device.
3. **`Process.arch`** (`arm64`, `arm`, `x64`, `ia32`) and **`Process.pointerSize`** (8 or 4) are the authoritative answer from inside. Hooks written for `arm64` (`x0`, `ldr x8`, 8-byte pointers) are wrong in an `arm` process (`r0`, 4-byte pointers, Thumb code).
4. **The module path** shows which library variant was loaded: `.../lib/arm64/libtarget.so` when extracted, or `base.apk!/lib/arm64-v8a/libtarget.so` when loaded straight from the APK (`extractNativeLibs="false"`).
5. **Frida must match too.** A 32-bit process needs Frida's 32-bit agent; a mismatched or buggy agent shows up as attach failures or crashes ([[Matching-Frida-Server-To-The-Target-ABI]]).

## Compared with real code

- [[Forcing-A-64-Bit-Split-Install-To-Dodge-The-32-Bit-Agent-Bug]] — a real case where the app's process ABI, not the device's, decided whether Frida worked.
- [[Inspecting-An-APKs-Native-Libraries-Per-ABI]] — reading which ABIs a real APK ships, which determines `primaryCpuAbi`.

## See also

- [[Android-ABIs-And-Emulation]]
- [[First-Script-Attach-And-Enumerate]]
- [[Module-And-Process-API]]
- [[Registers-And-Data]] in [[ARM64-Android]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
