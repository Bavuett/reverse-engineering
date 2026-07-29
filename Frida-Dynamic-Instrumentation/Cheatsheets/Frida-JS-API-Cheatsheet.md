---
tags: [cheatsheet]
subject: "Frida JavaScript API"
created: 2026-07-28
---

# Frida-JS-API-Cheatsheet

Quick lookup — not a full explanation. See [[Frida-Fundamentals]], [[Java-Layer-Hooking]], [[Native-Memory-And-ARM64]], and [[Network-Interception]] for the "why".

## CLI

| Command / syntax | Does |
|---|---|
| `frida-ps -U` | List processes on a USB-connected device |
| `frida-ps -Uai` | List processes, including not-yet-running installed apps (`-a` all, `-i` installed) |
| `frida -U -n "App Name" -l script.js` | Attach to an already-running process by name |
| `frida -U com.package -l script.js` | Attach to an already-running process by package name |
| `frida -U -f com.package -l script.js` | Spawn the app suspended, inject, then resume immediately (the `frida` CLI's own `-f` already auto-resumes — unlike `frida-trace`/`objection`, there's no separate `--no-pause` flag here; manual control is `%resume` in the REPL) |
| `frida-trace -U -i "SSL_*" com.package` | Auto-generate and run per-function trace stubs for every export matching a glob |
| `adb forward tcp:27042 tcp:27042` | Forward frida-server's control port when using `-H` instead of `-U`/USB |

## ADB (getting to the point of attaching)

| Command / syntax | Does |
|---|---|
| `adb devices` | Confirm the emulator/device is visible and in `device` (not `offline`) state |
| `adb root` | Restart `adbd` as root — needed before pushing/running `frida-server` (see [[Frida-Server-Setup]]) |
| `adb shell pm list packages \| grep <fragment>` | Find an installed app's exact package name from a partial name |
| `adb shell "nohup /data/local/tmp/frida-server >/data/local/tmp/frida-server.log 2>&1 &"` | Start `frida-server` on the device, detached and backgrounded |
| `adb shell "ps -A \| grep frida-server"` | Confirm `frida-server` is actually running before trying to attach |

## `Java.*`

| Command / syntax | Does |
|---|---|
| `Java.perform(fn)` | Run `fn` once the ART runtime is attached to the current thread — required before any other `Java.*` call |
| `Java.use("pkg.Class")` | Get a wrapper around an ART class |
| `SomeClass.method.overload("java.lang.String").implementation = function(a) {...}` | Replace/observe a specific overload |
| `this.originalMethod(...)` (inside an `.implementation` fn) | Call through to the original implementation |
| `Java.enumerateLoadedClasses({ onMatch, onComplete })` | List class definitions the class loader knows about |
| `Java.choose("pkg.Class", { onMatch, onComplete })` | Walk the live heap for existing *instances* |
| `Java.cast(ptr, SomeClass)` | Wrap an arbitrary object reference as a typed handle |
| `Java.classFactory.loader = someLoader` | Target a non-default class loader (dynamic modules, obfuscators) |

## `Interceptor.*` / `Module.*` / `Process.*`

| Command / syntax | Does |
|---|---|
| `Module.findExportByName("lib.so", "symbol")` | Resolve an exported symbol's address |
| `Module.findBaseAddress("lib.so")` | Get a loaded module's runtime base address |
| `Module.enumerateExports("lib.so")` | List every exported symbol in a module |
| `Process.enumerateModules()` | List every loaded module in the process |
| `Process.findModuleByName("lib.so")` | Get a module handle, or `null` if not yet loaded |
| `Interceptor.attach(addr, { onEnter(args) {}, onLeave(retval) {} })` | Hook a native function |
| `Interceptor.replace(addr, new NativeCallback(...))` | Fully replace a native function's implementation |

## `Memory.*`

| Command / syntax | Does |
|---|---|
| `Memory.readUtf8String(ptr, [len])` | Read a UTF-8 string |
| `Memory.readCString(ptr, [len])` | Read a null-terminated C string |
| `Memory.readByteArray(ptr, len)` | Read raw bytes as an `ArrayBuffer` |
| `Memory.readPointer(ptr)` | Follow one level of pointer indirection |
| `Memory.scan(addr, size, "AA BB ?? DD", { onMatch, onComplete })` | Search memory for a byte pattern (`??` = wildcard byte) |
| `hexdump(ptr, { length, header: true, ansi: false })` | Formatted hex+ASCII dump |

## Messaging

| Command / syntax | Does |
|---|---|
| `send(payload)` (in script) + `session.on("message", cb)` (host) | Push data from the injected script to your host script |
| `rpc.exports = { myFunc(...) {...} }` | Expose a function the host script can call synchronously |

## Common pitfalls

- Calling `Java.use` before `Java.perform`'s callback has run — throws immediately.
- Forgetting `.overload(...)` on a method that has more than one signature.
- Reading `SSL_read`'s output buffer in `onEnter` instead of `onLeave` — it's an out-parameter, empty until the call returns.
- Attaching instead of spawning when the thing you want to observe happens at process startup.
- Assuming `args[0]`/`args[1]` are the "real" first Java parameters of a JNI function — they're `JNIEnv*` and `jobject`/`jclass`; real parameters start at `args[2]`.
- On Windows, running the ADB commands above from **Git Bash** can silently mangle a Unix-style remote path into a Windows one (MSYS path conversion) — prefix with `MSYS_NO_PATHCONV=1`, or just use PowerShell/cmd. See [[Frida-Server-Setup]] for the full explanation.
- **Never name a script `frida.js`** (or `frida-trace.js`, etc.) in the directory you run the `frida` CLI from, on Windows. `.JS` is in the default Windows `PATHEXT`, and cmd/PowerShell resolve an unqualified command name against the **current directory before PATH** — so typing `frida` while a `frida.js` sits right there resolves to that script (handed off to Windows Script Host, surfacing as a "How do you want to open this file?" prompt for `.js`) instead of the real `frida.exe` from PATH. Name injected scripts something else (`script.js`, `hook.js`, `root-bypass.js`, ...).

## See also

- [[Frida-Dynamic-Instrumentation]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
