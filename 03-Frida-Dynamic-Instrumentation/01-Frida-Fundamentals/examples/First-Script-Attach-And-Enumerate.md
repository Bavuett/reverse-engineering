---
tags: [example]
level: 1
aliases: ["Frida hello world", "first Frida script"]
created: 2026-11-12
---

# Example: First-Script-Attach-And-Enumerate

> [!info] Level 1 — basics
> One idea: a Frida script is ordinary JavaScript running *inside* the target process — so the first thing to do is ask the process about itself.

## Goal

Attach to a running app, print what process you're in, which architecture it runs, and which native libraries are loaded — the orientation step before any hooking. Belongs to [[Frida-Fundamentals]].

## Script (`hello.js`)

```javascript
console.log(`[*] pid=${Process.id} arch=${Process.arch} pointerSize=${Process.pointerSize}`);

const interesting = Process.enumerateModules()
    .filter(m => m.path.includes("/data/app/"))          // the app's own .so files
    .map(m => `${m.name.padEnd(36)} ${m.base}  ${(m.size / 1024).toFixed(0)} KiB`);

console.log("[*] app libraries:\n    " + interesting.join("\n    "));

const libc = Process.getModuleByName("libc.so");
console.log(`[*] libc open() at ${libc.getExportByName("open")}`);
```

## Running it

```text
$ frida -U -n "PressReader" -l hello.js        # attach by process name
$ frida -U -p 12345 -l hello.js                # ...or by pid (frida-ps -Ua lists both)
[*] pid=12345 arch=arm64 pointerSize=8
[*] app libraries:
    libencrypt.so                        0x7a1c200000  ... KiB
    libodyssey.so                        0x7a1b800000  ... KiB
[*] libc open() at 0x7c3e8a1b40
```

(Illustrative output: addresses vary per run because of ASLR, and libraries appear only once the app has loaded them.)

## Step by step

1. **`-U`** selects the USB/ADB device, **`-n`/`-p`** pick the process, **`-l`** loads the script. The script runs immediately inside the target and the CLI stays open as a REPL connected to it.
2. **`Process`** describes the current process: `id`, `arch` (`arm64`, `arm`, `x64`, `ia32`), `pointerSize` (8 or 4). `arch` is the *process's* architecture, which can differ from the device's — see [[Android-ABIs-And-Emulation]].
3. **`Process.enumerateModules()`** lists every loaded shared object with `name`, `base` (load address), `size`, and `path`. Filtering on `/data/app/` keeps the app's bundled libraries and hides the hundreds of system ones.
4. **`getModuleByName(...).getExportByName(...)`** resolves a symbol to a live address — the starting point for every native hook ([[Native-Memory-And-ARM64]]). `getModuleByName` throws if the library isn't loaded; `findModuleByName` returns `null` instead.
5. **`console.log` output travels to the host** over Frida's message channel; it isn't written to logcat.
6. **Nothing was modified.** Enumeration is read-only, so it's safe to run against any app first — and it tells you whether the library you plan to hook is even loaded yet.

## Compared with real code

- [[Reattaching-Without-Losing-Session-State]] — attaching by `-p <pid>` mid-session in a real investigation.
- [[Diagnosing-A-Wedged-Frida-Server]] — what to do when even this script can't attach.

## See also

- [[Frida-Fundamentals]]
- [[Spawn-Vs-Attach-Timing]]
- [[Module-And-Process-API]]
- [[Frida]] and [[Frida-Server-Setup]] in [[Tools]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
