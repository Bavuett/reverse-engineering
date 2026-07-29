---
tags: [reference]
aliases: ["Frida Dynamic Instrumentation Glossary"]
---

# Frida-Dynamic-Instrumentation · Glossary

Terminology used across this topic, in alphabetical order. Add a term as soon as you introduce it
in a chapter note, rather than assuming it's obvious.

| Term | Meaning |
|---|---|
| Attach | Injecting a Frida script into a process that's already running — see [[Frida-Fundamentals]]. Anything that happened before attaching is unobservable. |
| BoringSSL | Google's fork of OpenSSL, statically linked into Android's platform TLS stack and into `libflutter.so`/`libapp.so` for Flutter apps — see [[Network-Interception]]. |
| GumJS | The JavaScript runtime Frida injects into a target process (V8 or QuickJS-based), exposing `Java`, `Interceptor`, `Memory`, `Module`, etc. — see [[Frida-Fundamentals]]. |
| Gadget | Frida's embeddable shared library form (`frida-gadget`), loaded directly by an app (e.g. via a repackaged APK) instead of requiring `frida-server` + root — the option for targets that can't be rooted — see [[Anti-Detection-And-Gadget-Mode]]. |
| `Interceptor.attach` | The core native-hooking API: attaches `onEnter`/`onLeave` callbacks to a function at a given address, observing without changing behavior — see [[Native-Memory-And-ARM64]]. |
| `Interceptor.replace` | Fully replaces a native function's implementation for every caller, rather than just observing around it — see [[Memory-Patching-And-Code-Redirection]]. |
| `Java.perform` | Runs a callback once the ART runtime is attached to the current native thread — required before any `Java.use` call — see [[Frida-Fundamentals]]. |
| `Java.use` | Returns a JavaScript wrapper around an ART class, letting you read/hook its methods and fields — see [[Java-Layer-Hooking]]. |
| `Memory.patchCode` | Lowest-level code-modification API: hands you a writable buffer over a code region and an assembler (`Arm64Writer`) to emit replacement instructions directly — see [[Memory-Patching-And-Code-Redirection]]. |
| `NativeCallback` / `NativeFunction` | `NativeCallback` wraps a JavaScript function so native code can call it as a real function with a given ABI signature (used to build replacements); `NativeFunction` wraps an address so your script can call it directly — see [[Memory-Patching-And-Code-Redirection]]. |
| RPC exports (`rpc.exports`) | A way to expose functions from an injected script that the host-side Python/Node script can call synchronously, instead of relying only on `send`/`recv` messaging — see [[Frida-Fundamentals]]. |
| Spawn | Launching a process suspended, injecting the script, then resuming it — the only way to observe events at/near process startup — see [[Frida-Fundamentals]]. |
| Stalker | Frida's code-tracing engine: follows a thread through every executed instruction/call/block, recompiling on the fly to emit events — the tool for finding what to hook rather than just observing something you already found — see [[Stalker-And-Code-Tracing]]. |
| `TrustManager` | The Java interface responsible for certificate chain validation on Android; hooking its `checkServerTrusted`/`verifyChain` is the standard Java-layer pinning bypass — see [[Network-Interception]]. |

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
