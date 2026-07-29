---
tags: [fundamentals]
aliases: ["Frida Architecture", "Spawn vs Attach"]
created: 2026-07-28
---

# Frida-Fundamentals

## In short

Frida is a **client/server** dynamic instrumentation toolkit: `frida-server` runs *on* the target device (usually as root) and exposes a control channel over TCP (default port 27042); a client on your host (the `frida` CLI, `frida-tools`, or the Python/Node bindings) connects to it, injects a small runtime called **GumJS** into the target process, and pushes a JavaScript file into that runtime. The script runs *inside* the target process's address space — every API it calls (`Java.use`, `Interceptor.attach`, `Memory.readByteArray`, ...) executes with the same memory access and privileges as the app itself, not from outside as a debugger would.

## Explanation

### Spawn vs. attach

There are two ways to get a script into a process, and the choice matters for what you can observe:

| Mode | Command | When to use |
| --- | --- | --- |
| **Attach** | `frida -U <process name or PID>` | The app is already running and you want to hook something that happens *after* you attach (a button tap, a periodic sync). Anything that already ran before attaching (app startup, an early `SSL_write`, a class being loaded) is invisible to you. |
| **Spawn** | `frida -U -f <package.name> -l script.js --no-pause` | You need to hook something that happens at or near process start (e.g. `System.loadLibrary`, the first native library initialization, an app-startup network call). Frida launches the process suspended, injects the script, then resumes it (`--no-pause` resumes immediately; without it you resume manually with `%resume` in the REPL). |

### The injected runtime

Once attached, the script runs inside a `RUNTIME=V8` (or QuickJS, depending on the Frida build) JavaScript context with Frida's own global APIs available — there's no DOM, no Node.js `require`, just the objects Frida injects: `Java`, `ObjC` (iOS only), `Interceptor`, `Memory`, `Module`, `Process`, `Thread`, `NativeFunction`/`NativePointer`, and the `send`/`recv`/`rpc.exports` messaging bridge back to your host script.

### The shape of a basic script

Every Frida script that touches the ART (Java/Kotlin) layer starts by waiting for the runtime to be attached to the current thread with `Java.perform` — calling `Java.use` before that throws:

```javascript
Java.perform(() => {
    console.log("[*] Java runtime ready, PID = " + Process.getCurrentThreadId());
});
```

Native-only work (`Interceptor.attach`, `Memory.*`, `Module.*`) doesn't need `Java.perform` at all — it works on any process, Java or not, since it operates below the ART layer.

### Getting your script talking to your host

`console.log` inside a script shows up directly in the `frida`/`frida-trace` terminal — enough for most exploratory work. For anything more structured (collecting data across many hook hits, building a small dataset), use `send(payload)` in the script and an `onMessage` handler in a Python/Node host script, or expose functions with `rpc.exports` and call them from the host via `session.get_script().exports_sync`.

## Worked example

Attach to an already-running ClasseViva process and confirm the Java runtime is reachable, as a smoke test before writing any real hooks:

```javascript
// smoke-test.js
Java.perform(() => {
    const ActivityThread = Java.use("android.app.ActivityThread");
    const app = ActivityThread.currentApplication();
    console.log("[*] Attached. Application object: " + app);
    console.log("[*] Package: " + app.getPackageName());
});
```

```
frida -U -n "ClasseViva Studenti" -l smoke-test.js
```

## More examples

- [[Frida-Server-Setup]] in [[Frida-Dynamic-Instrumentation-Tools|Tools]] walks through getting `frida-server` running on an x86_64 emulator with root — required before any script here can attach to anything.

## See also

- [[Java-Layer-Hooking]]
- [[Native-Memory-And-ARM64]]
- [[Frida]] — the ARM64-Android topic's own tool note on Frida, focused on confirming static-analysis hypotheses dynamically rather than on the mechanics covered here.

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]

## Flashcards
#flashcards

What's the key difference between spawning and attaching, in terms of what you can observe?::Spawning launches the process suspended before injecting the script, so you can hook things that happen at/near startup; attaching only sees events that happen after the script is already injected into an already-running process.

Why does `Java.use` throw if called outside `Java.perform`?::`Java.use` needs the ART runtime to be attached to the current native thread first; `Java.perform(callback)` does that attachment and then invokes the callback once it's ready.

What does `frida-server` need on the device to work?::Root access — it needs to run as a privileged process to attach to and inject code into arbitrary target processes.
