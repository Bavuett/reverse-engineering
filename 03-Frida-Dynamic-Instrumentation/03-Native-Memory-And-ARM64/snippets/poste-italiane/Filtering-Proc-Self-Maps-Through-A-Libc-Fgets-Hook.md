---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "root-and-frida-hiding.js (Frida instrumentation script, not app source)"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Filtering-Proc-Self-Maps-Through-A-Libc-Fgets-Hook

## Context

Frida-detection code that reads `/proc/self/maps` looking for `frida`/`gum-js-loop`/`linjector`
strings does its file I/O in **native** code (or through a Java `FileReader` that eventually calls
into libc regardless), so a Java-layer `File.exists`-style hook can't intercept the read itself — only
a native hook on the libc function actually doing line-based reads reaches it. This is
[[Native-Memory-And-ARM64]]'s `Interceptor.attach` on a native export, applied specifically to filter
a buffer's *content* on the way out, not just observe it.

## Original path

`` Case-Studies/poste-italiane/source/root-and-frida-hiding.js ``

## Snippet

### Example 1 — the working hook

```javascript
const FRIDA_MAP_MARKERS = ["frida", "gum-js-loop", "gmain", "linjector"];
const libc = Process.findModuleByName("libc.so");
if (libc !== null) {
    const fgetsPtr = libc.findExportByName("fgets");
    if (fgetsPtr !== null) {
        Interceptor.attach(fgetsPtr, {
            onEnter(args) {
                this.buf = args[0]; // char *buf — fgets' out-parameter
            },
            onLeave(retval) {
                if (retval.isNull()) return;
                const line = this.buf.readCString();
                if (line !== null && FRIDA_MAP_MARKERS.some((m) => line.includes(m))) {
                    this.buf.writeUtf8String("\n"); // blank line instead of the real, telling one
                }
            }
        });
    }
}
```

### Example 2 — the API mistake this replaced, and why it errored

```javascript
// Throws TypeError: not a function on modern Frida — Module.findExportByName
// used to take (moduleNameOrNull, exportName); the per-module method below is
// the current equivalent and doesn't need a name lookup at all once you
// already have the Module object.
const fgetsPtr = Module.findExportByName(libc.name, "fgets"); // <- fails

// Fixed:
const fgetsPtr = libc.findExportByName("fgets"); // libc is already a Module object
```

The fix here is a one-word change (`Module.findExportByName(libc.name, ...)` →
`libc.findExportByName(...)`), but finding it meant recognizing the error as an API-surface drift
across Frida versions rather than a logic bug — the *shape* of the call (module + export name in, a
`NativePointer` or `null` out) is identical; only which object the method lives on changed.

## Notes

- `libc.findExportByName(...)` (the modern per-module method) was needed instead of the older
  `Module.findExportByName(libc.name, "fgets")` — the latter threw a `TypeError: not a function` on
  this Frida version, one of a handful of small API-surface changes across Frida releases worth
  checking for when a documented-looking call errors unexpectedly.
- `fgets`' buffer argument (`args[0]`) is an **out-parameter** — like `SSL_read`'s buffer in
  [[Network-Interception]]'s own worked example, it's only meaningful in `onLeave`, once the real call
  has actually written a line into it.
- Disabled by default in the final script (`ENABLE_NATIVE_MAPS_FILTER = false`) after being the first
  suspect during an ANR investigation — it intercepts **every** `fgets()` call process-wide, not just
  reads of `/proc/self/maps`, making it the broadest and most invasive hook in the whole toolkit. It
  was ultimately cleared of causing that specific ANR (see
  [[Splash-Screen-ANR-Under-Heavy-Instrumentation]]), but stayed off since re-enabling it wasn't
  re-tested afterward — a case of a hook being technically correct but left disabled purely out of
  caution once a cheaper, already-sufficient Java-layer bypass covered the same detection goal.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Native-Memory-And-ARM64]]
- [[Anti-Detection-And-Gadget-Mode]]
- [[Splash-Screen-ANR-Under-Heavy-Instrumentation]] and [[Poste-Italiane]] in [[Case-Studies]]
