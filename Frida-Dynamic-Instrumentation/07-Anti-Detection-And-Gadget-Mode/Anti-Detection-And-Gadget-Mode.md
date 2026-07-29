---
tags: [fundamentals]
aliases: ["Root Detection Bypass", "Frida Gadget", "Anti-Frida"]
created: 2026-07-28
---

# Anti-Detection-And-Gadget-Mode

## In short

Two separate problems tend to get conflated: the app noticing the **device** is rooted/an emulator, and the app noticing **Frida itself** is attached. Both are just more code to hook — root/emulator checks with the techniques from [[Java-Layer-Hooking]] and [[Memory-Patching-And-Code-Redirection]], Frida-detection checks the same way, once you've found where they live. This chapter also covers **Frida Gadget**, the alternative to `frida-server` + root for when the target device genuinely can't be rooted.

## Explanation

### What root/emulator detection usually checks

| Check | What it looks for |
|---|---|
| `su` binary presence | `/system/bin/su`, `/system/xbin/su`, or `which su` succeeding |
| Root-management app packages | `com.topjohnwu.magisk`, `eu.chainfire.supersu`, etc. via `PackageManager` |
| Writable system partitions | `/system` mounted read-write instead of read-only |
| Build properties | `ro.build.tags` containing `test-keys` instead of `release-keys`, `ro.debuggable` set |
| Emulator-specific properties | `ro.kernel.qemu`, `ro.hardware` containing `goldfish`/`ranchu`, `ro.product.model` containing `sdk`/`emulator` |
| Native-level checks | The same signals above, re-implemented in a `.so` instead of Java, specifically to dodge Java-layer detection bypasses |

Each of these is a concrete function/property lookup — the fix is always the same shape as the `isDeviceRooted` example in [[Memory-Patching-And-Code-Redirection]]: find it (via [[Java-Layer-Hooking]]'s class enumeration, or [[Native-Memory-And-ARM64]]/static grepping for suspicious strings like `"su"`, `"magisk"`, `"test-keys"`), then hook or replace it to return the "clean" answer.

### What Frida-detection specifically checks

This is a distinct problem from root detection, and worth treating separately since an app can be fully rooted-device-tolerant and still refuse to run with Frida attached:

| Check | What it looks for |
|---|---|
| Port scanning | `frida-server`'s default control port (27042) or its D-Bus-based port range, open on `localhost` |
| `/proc/net/tcp` / `/proc/<pid>/maps` inspection | Frida's own libraries (`frida-agent`, `linjector`) mapped into the process's memory |
| Named pipe/thread enumeration | Threads named `gum-js-loop`, `gmain`, or similar Frida-internal thread names |
| Environment/library checks | `LD_PRELOAD` artifacts, or `ptrace(PTRACE_TRACEME)` on itself — if it fails (already traced by something, or already ptrace-attached by Frida's own injection method), that's a signal |

Every one of these is, again, just a function call somewhere that this chapter's tools can hook — `Interceptor.attach` on `open`/`fopen` to fake `/proc` file reads, hooking `strstr`/`strcmp` calls that look for `"frida"` in a string, or replacing the port-scan's connect logic. The genuinely hard part is never the hooking mechanics — it's *finding* which specific check is running, which is exactly where [[Static-Dynamic-Integration]]'s workflow (search static strings, confirm dynamically, patch) earns its keep.

### Frida Gadget: when you can't root the target at all

Everything else in this topic assumes `frida-server` running as root on the device. **Frida Gadget** is a shared library (`libgadget.so`) you build directly into an APK — repackage the target APK with the gadget added as a native library and loaded via `System.loadLibrary`/an injected smali call, resign it, and reinstall. The app now carries its own embedded Frida agent and can be scripted the same way, without root or a separate `frida-server` process — the standard workaround for real, non-rooted devices, or for apps whose native anti-tampering specifically detects a foreign process attaching via `ptrace` (Gadget avoids that class of detection since it's loaded by the app's own process, not injected from outside).

The tradeoff: repackaging changes the APK's signature, which some apps detect independently as tampering (signature verification, a separate check from root/Frida detection) — see [[Static-Dynamic-Integration]] for how to locate and neutralize that check too, once Gadget mode itself is working.

## Worked example

Hook the three most common Java-layer root-detection primitives at once — file existence checks, package lookups, and build tags — as a starting bypass template before narrowing down to the app's actual specific check:

```javascript
Java.perform(() => {
    // 1. Fake "file doesn't exist" for common su paths
    const File = Java.use("java.io.File");
    File.exists.implementation = function () {
        const path = this.getAbsolutePath();
        if (path.includes("/su") || path.includes("magisk")) {
            console.log(`[*] Faking File.exists() = false for ${path}`);
            return false;
        }
        return this.exists();
    };

    // 2. Fake "package not found" for root-manager apps
    const PackageManager = Java.use("android.app.ApplicationPackageManager");
    PackageManager.getPackageInfo.overload("java.lang.String", "int").implementation = function (pkg, flags) {
        if (pkg.includes("magisk") || pkg.includes("supersu")) {
            console.log(`[*] Faking PackageManager: ${pkg} not found`);
            const NameNotFoundException = Java.use("android.content.pm.PackageManager$NameNotFoundException");
            throw NameNotFoundException.$new("not found");
        }
        return this.getPackageInfo(pkg, flags);
    };

    // 3. Fake release build tags
    const Build = Java.use("android.os.Build");
    Build.TAGS.value = "release-keys";
});
```

## More examples

- [[Frida-JS-API-Cheatsheet]] in [[Frida-Dynamic-Instrumentation-Cheatsheets|Cheatsheets]].

## See also

- [[Java-Layer-Hooking]]
- [[Memory-Patching-And-Code-Redirection]]
- [[Static-Dynamic-Integration]] — the workflow for actually *locating* a specific app's detection logic before hooking it.

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]

## Flashcards
#flashcards

What's the difference between root detection and Frida detection, and why does it matter that they're separate?::Root detection looks for signs the device/OS has been modified (su binary, root-manager packages, build tags); Frida detection looks for signs the instrumentation tool itself is attached (open control ports, injected libraries in memory maps, characteristic thread names) — an app can bypass one check and still be caught by the other, so both need to be found and handled independently.

When would you reach for Frida Gadget instead of frida-server?::When the target device can't be rooted at all (a real, locked-down device rather than an emulator/lab device you control) — Gadget embeds the Frida agent directly into a repackaged APK, avoiding the need for a root-privileged frida-server process entirely.

What's the tradeoff of using Frida Gadget via APK repackaging?::Repackaging and resigning the APK changes its signature, which some apps independently verify and treat as a tampering signal — a separate check from root/Frida detection that may also need to be located and bypassed.
