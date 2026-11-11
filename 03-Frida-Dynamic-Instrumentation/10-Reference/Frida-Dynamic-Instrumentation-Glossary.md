---
tags: [reference]
aliases: ["Frida Dynamic Instrumentation Glossary"]
---

# Frida-Dynamic-Instrumentation · Glossary

Terminology used across this topic, in alphabetical order. Add a term as soon as you introduce it in a chapter note, rather than assuming it's obvious.

| Term | Meaning |
|---|---|
| Attach | Injecting a Frida script into a process that's already running — see [[Frida-Fundamentals]]. Anything that happened before attaching is unobservable. |
| BoringSSL | Google's fork of OpenSSL, statically linked into Android's platform TLS stack and into `libflutter.so`/`libapp.so` for Flutter apps — see [[Network-Interception]]. |
| GumJS | The JavaScript runtime Frida injects into a target process (V8 or QuickJS-based), exposing `Java`, `Interceptor`, `Memory`, `Module`, `Process`, etc. — see [[Frida-Fundamentals]]. |
| Gadget | Frida's embeddable shared library form (`frida-gadget`), loaded directly by an app (e.g. via a repackaged APK) instead of requiring `frida-server` + root — the option for targets that can't be rooted — see [[Anti-Detection-And-Gadget-Mode]]. |
| `Interceptor.attach` | The core native-hooking API: attaches `onEnter`/`onLeave` callbacks (or an instruction-level probe function) to a native code address, observing or tweaking args/return values without replacing the function body — see [[Native-Memory-And-ARM64]] and [[Interceptor-Attach-And-Replace]]. |
| `Interceptor.replace` | Fully replaces a native function's implementation for every caller using a `NativeCallback`, rather than just observing around it — see [[Memory-Patching-And-Code-Redirection]] and [[Interceptor-Attach-And-Replace]]. |
| `Java.choose` / `Java.cast` | `Java.choose` scans the live ART heap for existing instances of a class; `Java.cast` re-wraps an object pointer with a concrete class wrapper so its fields and methods can be accessed — see [[Java-Layer-Hooking]] and [[Java-Perform-And-Java-Use]]. |
| `Java.perform` | Runs a callback once the ART runtime is attached to the current native thread — required before any `Java.use` call — see [[Frida-Fundamentals]] and [[Java-Perform-And-Java-Use]]. |
| `Java.use` | Returns a JavaScript wrapper around an ART class, letting you read/hook its methods (`.implementation`), overloads (`.overload(...)`), constructors (`$init`/`$new`), and fields (`.value`) — see [[Java-Layer-Hooking]] and [[Java-Perform-And-Java-Use]]. |
| `Memory.patchCode` | Lowest-level code-modification API: hands you a writable buffer over a code region and an assembler (`Arm64Writer`) to emit replacement instructions directly while managing page permissions and icache flushing — see [[Memory-Patching-And-Code-Redirection]] and [[NativePointer-And-Memory-API]]. |
| `Module` / `Process` | APIs for inspecting loaded shared libraries (`Process.findModuleByName`, `mod.base`, `mod.findExportByName`), memory ranges (`Process.enumerateRanges`), and threads (`Thread.backtrace`) — see [[Native-Memory-And-ARM64]] and [[Module-And-Process-API]]. |
| `NativeCallback` / `NativeFunction` | `NativeCallback` wraps a JavaScript function so native code can call it as a real function with a given ABI signature (used to build replacements); `NativeFunction` wraps an address so your script can call it directly — see [[Memory-Patching-And-Code-Redirection]] and [[NativeFunction-And-NativeCallback]]. |
| `NativePointer` (`ptr`) | Frida's 64-bit-safe wrapper for a native virtual address, providing pointer arithmetic (`.add`, `.sub`, `.and`, `.shr`, `.shl`) and typed memory reads/writes (`.readPointer`, `.readU32`, `.readUtf8String`, `.readByteArray`) — see [[Native-Memory-And-ARM64]] and [[NativePointer-And-Memory-API]]. |
| RPC exports (`rpc.exports`) | A way to expose functions from an injected script that the host-side Python/Node script can call synchronously, instead of relying only on `send`/`recv` messaging — see [[Frida-Fundamentals]] and [[RPC-Exports-And-Host-Messaging]]. |
| Spawn | Launching a process suspended, injecting the script, then resuming it — the only way to observe events at/near process startup — see [[Frida-Fundamentals]]. |
| Stalker | Frida's dynamic binary translation and code-tracing engine: follows a thread through every executed instruction/call/block (`events`) or transforms basic blocks with custom callouts (`transform`), recompiling on the fly — see [[Stalker-And-Code-Tracing]] and [[Stalker-Follow-And-Transform]]. |
| `TrustManager` | The Java interface responsible for certificate chain validation on Android; hooking its `checkServerTrusted`/`verifyChain` is the standard Java-layer pinning bypass — see [[Network-Interception]]. |

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Java-Perform-And-Java-Use]]
- [[Interceptor-Attach-And-Replace]]
- [[NativePointer-And-Memory-API]]
- [[NativeFunction-And-NativeCallback]]
- [[Module-And-Process-API]]
- [[Stalker-Follow-And-Transform]]
