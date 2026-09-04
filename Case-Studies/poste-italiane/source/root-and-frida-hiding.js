/*
 * Poste Italiane (com.posteitaliane.spim) — root/Frida-detection hiding.
 *
 * Load alongside http-pinning-bypass-and-dump.js:
 *   frida -U -f com.posteitaliane.spim -l root-and-frida-hiding.js -l http-pinning-bypass-and-dump.js -q -t inf
 *
 * Why this exists: even with TLS pinning fully bypassed, the login flow on a rooted
 * test device can still fail — not because of anything wrong with the network
 * capture, but because the app's own risk/fraud engine lowers a server-side
 * "device trust score" when it detects root (Magisk, su binaries, root-manager
 * packages, non-release build tags) and/or Frida itself. This script hides the
 * Java-layer signals covered in [[Anti-Detection-And-Gadget-Mode]]; see that
 * chapter for the full technique catalogue this is a concrete instance of.
 *
 * IMPORTANT CAVEAT: a bank-grade app's trust score most plausibly rests on
 * Google's Play Integrity API rather than (or in addition to) these local Java
 * checks. Play Integrity's verdict is a hardware-backed attestation signed by
 * Google — it reflects the actual bootloader/verified-boot state and cannot be
 * spoofed by hooking this app's own code, no matter how thorough. If the score
 * doesn't improve after this script, that's the likely reason: fixing it would
 * require Magisk Zygisk + DenyList + a hiding module (Shamiko) + a Play
 * Integrity Fix module providing a valid keybox, none of which is something
 * Frida scripting alone can provide — see the case study's Open questions.
 */

Java.perform(() => {
    // ---------------------------------------------------------------------
    // Root artifact paths this device's rooting method (Magisk) actually uses,
    // plus the generic ones any su-based root exposes.
    // ---------------------------------------------------------------------
    // A single compiled regex, tested without a .toLowerCase() allocation
    // (Android paths are already lowercase in every real case here) — cheaper
    // per-call than the previous Array.some()+String.includes() loop over six
    // fragments, and only java.io.File.exists() is hooked, not canExecute()
    // too, to roughly halve how many of the app's (very numerous, mostly
    // unrelated) file checks cross the Frida Java bridge at all. See the
    // header comment: File.exists() being hooked at all is still broad enough
    // (every file check in the whole process, not just root-related ones) to
    // risk an ANR under a heavy enough scan — this only lowers the per-call
    // cost, it doesn't change what's intercepted.
    const SUSPICIOUS_PATH_RE = /(^|\/)su(\/|$)|magisk|busybox|supersu|superuser|\/xbin|\/data\/adb/i;

    // 1. File.exists() — the most common first-pass root check.
    try {
        const File = Java.use("java.io.File");
        File.exists.implementation = function () {
            const path = this.getAbsolutePath();
            if (SUSPICIOUS_PATH_RE.test(path)) {
                console.log(`[root-hide] File.exists(${path}) -> false`);
                return false;
            }
            return this.exists();
        };
        console.log("[+] Hooked java.io.File.exists");
    } catch (e) {
        console.log(`[!] File hook not applied: ${e.message}`);
    }

    // 2. PackageManager — hide root-manager and Xposed/LSPosed apps from every
    // lookup path an app might use (single-package lookup, or listing all
    // installed packages/applications).
    const ROOT_PACKAGES = [
        "com.topjohnwu.magisk", "eu.chainfire.supersu", "com.noshufou.android.su",
        "com.koushikdutta.superuser", "com.zachspong.temprootremovejb",
        "com.ramdroid.appquarantine", "de.robv.android.xposed.installer",
        "org.lsposed.manager", "com.saurik.substrate",
    ];

    try {
        const ApplicationPackageManager = Java.use("android.app.ApplicationPackageManager");

        ApplicationPackageManager.getPackageInfo.overload("java.lang.String", "int").implementation = function (pkg, flags) {
            if (ROOT_PACKAGES.includes(pkg)) {
                console.log(`[root-hide] getPackageInfo(${pkg}) -> NameNotFoundException`);
                const NameNotFoundException = Java.use("android.content.pm.PackageManager$NameNotFoundException");
                throw NameNotFoundException.$new(pkg);
            }
            return this.getPackageInfo(pkg, flags);
        };

        ["getInstalledPackages", "getInstalledApplications"].forEach((name) => {
            if (ApplicationPackageManager[name] === undefined) return;
            ApplicationPackageManager[name].overloads.forEach((ov) => {
                ov.implementation = function (...args) {
                    // Call through the instance, not the captured overload object — Frida
                    // routes this.methodName(...) to the ORIGINAL implementation from inside
                    // a replacement; calling ov(...)/ov.apply(...) here would call this same
                    // replacement again (infinite recursion, freezing whatever thread calls
                    // getInstalledPackages/getInstalledApplications — this caused a real ANR).
                    const result = this[name](...args);
                    const list = result.toArray();
                    const filtered = list.filter((entry) => {
                        const pkgName = entry.packageName ? entry.packageName.value : entry.$className;
                        return !ROOT_PACKAGES.includes(pkgName);
                    });
                    console.log(`[root-hide] ${name}() -> filtered ${list.length - filtered.length} root-manager package(s)`);
                    const ArrayList = Java.use("java.util.ArrayList");
                    const filteredList = ArrayList.$new();
                    filtered.forEach((e) => filteredList.add(e));
                    return filteredList;
                };
            });
        });
        console.log("[+] Hooked android.app.ApplicationPackageManager (getPackageInfo/getInstalledPackages/getInstalledApplications)");
    } catch (e) {
        console.log(`[!] PackageManager hook not applied: ${e.message}`);
    }

    // 3. Build properties — a rooted-with-Magisk device on a custom/vendor ROM
    // can still legitimately report test-keys; force the "clean" values.
    try {
        const Build = Java.use("android.os.Build");
        Build.TAGS.value = "release-keys";
        Build.TYPE.value = "user";
        console.log("[+] Hooked android.os.Build.TAGS/TYPE");
    } catch (e) {
        console.log(`[!] Build hook not applied: ${e.message}`);
    }

    // 4. Runtime.exec()/ProcessBuilder — many root checks shell out to `which su`,
    // `su -c id`, or probe for busybox directly instead of (or in addition to)
    // File-based checks.
    try {
        const Runtime = Java.use("java.lang.Runtime");
        const isSuspiciousCmd = (cmd) => cmd.some((s) => SUSPICIOUS_PATH_RE.test(String(s)) || String(s) === "su");

        Runtime.exec.overloads.forEach((ov) => {
            if (ov.argumentTypes.length === 0) return;
            const firstArgType = ov.argumentTypes[0].className;
            if (firstArgType !== "java.lang.String" && firstArgType !== "[Ljava.lang.String;") return;

            ov.implementation = function (cmdArg, ...rest) {
                const cmd = Array.isArray(cmdArg) ? cmdArg : [cmdArg];
                if (isSuspiciousCmd(cmd)) {
                    console.log(`[root-hide] Runtime.exec(${cmd.join(" ")}) -> IOException`);
                    const IOException = Java.use("java.io.IOException");
                    throw IOException.$new("No such file or directory");
                }
                // See the getInstalledPackages/getInstalledApplications hook above for why
                // this must be this.exec(...), not ov.apply(...) (infinite recursion).
                return this.exec(cmdArg, ...rest);
            };
        });
        console.log("[+] Hooked java.lang.Runtime.exec");
    } catch (e) {
        console.log(`[!] Runtime.exec hook not applied: ${e.message}`);
    }
});

// ---------------------------------------------------------------------
// 5. Frida-detection hiding.
// ---------------------------------------------------------------------
Java.perform(() => {
    // 5a. Block a self-scan of frida-server's default control port.
    try {
        const Socket = Java.use("java.net.Socket");
        Socket.connect.overload("java.net.SocketAddress", "int").implementation = function (addr, timeout) {
            const addrStr = addr.toString();
            if (addrStr.includes("27042") || addrStr.includes("27043")) {
                console.log(`[frida-hide] Socket.connect(${addrStr}) -> ConnectException`);
                const ConnectException = Java.use("java.net.ConnectException");
                throw ConnectException.$new("Connection refused");
            }
            return this.connect(addr, timeout);
        };
        console.log("[+] Hooked java.net.Socket.connect (blocking frida-server port scan)");
    } catch (e) {
        console.log(`[!] Socket hook not applied: ${e.message}`);
    }
});

// 5b. Filter frida's own footprint out of /proc/self/maps reads — done at the
// native libc level (fgets), not Java, since apps typically read this file with
// a plain FileReader/BufferedReader or directly via native code, and this one
// hook covers both.
//
// CAUTION: this intercepts every fgets() call in the ENTIRE process, not just
// reads of /proc/self/maps — there's no cheap way to know which open FILE* a
// given call is reading from without also tracking fopen()/fdopen() by fd.
// Disabled by default after an ANR was observed on the login screen with this
// hook active (com.posteitaliane.spim's main thread froze for several
// seconds while attempting a WebAuthn/FIDO2 ceremony) — not confirmed as the
// cause, but it's the most invasive hook in this file and the first suspect.
// Flip to true only if root/Frida detection is still succeeding after
// confirming the Java-layer hooks above aren't enough on their own.
const ENABLE_NATIVE_MAPS_FILTER = false;
const FRIDA_MAP_MARKERS = ["frida", "gum-js-loop", "gmain", "linjector"];
const libc = ENABLE_NATIVE_MAPS_FILTER ? Process.findModuleByName("libc.so") : null;
if (libc !== null) {
    const fgetsPtr = libc.findExportByName("fgets");
    if (fgetsPtr !== null) {
        Interceptor.attach(fgetsPtr, {
            onEnter(args) {
                this.buf = args[0];
            },
            onLeave(retval) {
                if (retval.isNull()) return;
                const line = this.buf.readCString();
                if (line !== null && FRIDA_MAP_MARKERS.some((m) => line.includes(m))) {
                    // Overwrite with a single newline so the caller sees an
                    // (effectively) blank line instead of the real, telling one.
                    this.buf.writeUtf8String("\n");
                }
            }
        });
        console.log("[+] Hooked libc fgets (filtering frida markers from line-based file reads)");
    }
}
