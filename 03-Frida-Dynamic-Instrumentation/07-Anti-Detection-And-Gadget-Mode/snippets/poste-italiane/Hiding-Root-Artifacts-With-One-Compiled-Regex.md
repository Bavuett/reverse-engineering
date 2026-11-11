---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "root-and-frida-hiding.js (Frida instrumentation script, not app source)"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Hiding-Root-Artifacts-With-One-Compiled-Regex

## Context

[[Anti-Detection-And-Gadget-Mode]]'s worked example hides `File.exists`/`PackageManager`/`Build.TAGS` checks with simple `.includes()` string matching. Against this real app, `File.exists()` turned out to be called at a high enough volume (every file check in the whole process crosses the Frida Java bridge, not just root-related ones) that a slow per-call implementation was a real suspect during an ANR investigation — this snippet is the optimized version that came out of that, plus the regex regression that optimizing it introduced and had to be fixed.

## Original path

`` Case-Studies/poste-italiane/source/root-and-frida-hiding.js ``

## Snippet

```javascript
// A single compiled regex, checked once per call, instead of Array.some() +
// .toLowerCase() + .includes() over six separate path fragments — and only
// File.exists() is hooked, not canExecute() too, roughly halving how many of
// the app's (very numerous, mostly unrelated) file checks cross the bridge.
const SUSPICIOUS_PATH_RE = /(^|\/)su(\/|$)|magisk|busybox|supersu|superuser|\/xbin|\/data\/adb/i;

File.exists.implementation = function () {
    const path = this.getAbsolutePath();
    if (SUSPICIOUS_PATH_RE.test(path)) {
        console.log(`[root-hide] File.exists(${path}) -> false`);
        return false;
    }
    return this.exists();
};
```

### Example — the two other primitives hidden alongside `File.exists`, in full

`File.exists` alone doesn't cover every way an app can look for root — this script hides three more primitives, each needing a different response shape to convincingly say "not rooted":

```javascript
// Build properties: a rooted-with-Magisk device can still legitimately report
// test-keys on a custom/vendor ROM — force the values a "clean" device reports.
const Build = Java.use("android.os.Build");
Build.TAGS.value = "release-keys"; // a field write, not a method hook
Build.TYPE.value = "user";

// Single-package lookup: throw the SAME exception a real "not installed" lookup throws
ApplicationPackageManager.getPackageInfo.overload("java.lang.String", "int").implementation = function (pkg, flags) {
    if (ROOT_PACKAGES.includes(pkg)) {
        const NameNotFoundException = Java.use("android.content.pm.PackageManager$NameNotFoundException");
        throw NameNotFoundException.$new(pkg);
    }
    return this.getPackageInfo(pkg, flags);
};

// Whole-list lookup: filter the REAL list rather than faking one from scratch —
// preserves every other legitimately-installed package's real data
ApplicationPackageManager.getInstalledPackages.overload("int").implementation = function (flags) {
    const result = this.getInstalledPackages(flags);
    const filtered = result.toArray().filter((entry) => !ROOT_PACKAGES.includes(entry.packageName.value));
    const ArrayList = Java.use("java.util.ArrayList");
    const filteredList = ArrayList.$new();
    filtered.forEach((e) => filteredList.add(e));
    return filteredList;
};
```

Note the two `PackageManager` shapes are genuinely different techniques, not the same one applied twice: a single-package lookup that doesn't find what it's looking for is expected to *throw*, while a whole-list lookup is expected to *return a shorter, still-valid list* — returning `null` or an empty list from the single-lookup case, or throwing from the list case, would both be wrong in ways that could themselves look suspicious to a careful check.

## Notes

- The first optimization attempt (`/\/su(\/|$)|magisk|.../ `, no `/i` flag) stopped matching `/system/app/Superuser.apk` entirely — case-sensitive matching missed the capitalized filename, and `\/su` without the `(^|\/)` anchor never matched a path segment that IS just `su` at the very start. Fixed by adding the `/i` flag, an explicit `superuser` alternative, and `(^|\/)su(\/|$)` for correct segment-boundary matching instead of a bare substring check. A regex "optimization" that silently stops matching a real case is worse than the slow version it replaced — this one shipped once, was caught by re-testing against the app's real checks (not just believing the regex compiled), and fixed before it mattered.
- `Runtime.exec`'s companion check reuses the *same* compiled regex against each argument string, avoiding a second, separately-maintained pattern that could drift out of sync with the first: `cmd.some((s) => SUSPICIOUS_PATH_RE.test(String(s)) || String(s) === "su")`.
- Confirmed firing against every real check this app performs — `Superuser.apk`, `/system/xbin/su`, ~25 more `su`/`magisk` path variants, `getPackageInfo`/`getInstalledPackages` lookups for `com.topjohnwu.magisk` and eight other root-manager packages, and `Runtime.exec("which su")` — not hypothetical coverage, all observed in the live capture log.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Anti-Detection-And-Gadget-Mode]]
- [[Java-Layer-Hooking]]
- [[Splash-Screen-ANR-Under-Heavy-Instrumentation]] and [[Poste-Italiane]] in [[Case-Studies]]
