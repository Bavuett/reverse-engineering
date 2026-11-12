---
tags: [example]
level: 1
aliases: ["root check bypass File.exists", "hide su binary"]
created: 2026-11-12
---

# Example: Bypassing-A-Simple-Java-Root-Check

> [!info] Level 1 — basics
> One idea: most naïve root checks ask the filesystem whether `su` exists. Hook the question (`File.exists`), not each check, and every check that relies on it is answered at once.

## Goal

Defeat a root check that looks for well-known root files, by lying about their existence. Belongs to [[Anti-Detection-And-Gadget-Mode]].

## Target (Java, in the app)

```java
static boolean isRooted() {
    String[] paths = { "/system/xbin/su", "/system/bin/su", "/sbin/su",
                       "/data/adb/magisk", "/system/app/Superuser.apk" };
    for (String p : paths)
        if (new File(p).exists()) return true;
    return false;
}
```

## Script

```javascript
Java.perform(() => {
    const File = Java.use("java.io.File");
    const hidden = /(^|\/)(su|magisk|Superuser\.apk|busybox)$|\/data\/adb\//;

    File.exists.implementation = function () {
        const path = this.getAbsolutePath();
        if (hidden.test(path)) {
            console.log(`[*] File.exists(${path}) -> false`);
            return false;
        }
        return this.exists();
    };
});
```

## Step by step

1. **Hook the primitive, not the check.** The app may have one `isRooted()` or twenty copies inlined by R8. They all end in `File.exists()`, so hooking it covers every copy — without finding any of them.
2. **Filter precisely.** Return `false` only for root artifacts; every other `exists()` call (the app's own files, caches) must behave normally, or the app breaks in unrelated ways.
3. **Alternative: hook `isRooted()` directly** and return `false` ([[Changing-A-Return-Value]]). Simpler when there's exactly one, easy-to-find check; fragile when obfuscated or duplicated.
4. **This only covers one API.** The same paths can be probed through `Runtime.exec("which su")`, `ProcessBuilder`, `PackageManager` (Magisk app installed?), `Build.TAGS` (`test-keys`), system properties, or native `access()`/`stat()` — out of reach of a Java `File` hook. Native checks need libc hooks ([[Hooking-An-Exported-Libc-Function]]).
5. **Verify by effect**: the log lines show which paths were probed — itself useful evidence of how the check is built.

## Compared with real code

- [[Hiding-Root-Artifacts-With-One-Compiled-Regex]] — the Poste Italiane investigation generalized this idea: one regex applied across several Java and native file APIs.
- [[Batch-Neutralizing-Hidden-Checks-By-Signature]] — the TUA app's checks were too well hidden for this approach; the real fix was to disable their host methods.

## See also

- [[Anti-Detection-And-Gadget-Mode]]
- [[Faking-Build-Properties]]
- [[XKey-Root-Detection-Check]] in [[Case-Studies]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
