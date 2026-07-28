---
tags: [tool]
tool_name: "Frida"
homepage: "https://frida.re/"
version: ""
created: 2026-07-28
---

# Frida

## Purpose

Dynamic instrumentation toolkit — scriptable hooking of both JNI-callable native functions and, via
its Java bridge, ART-managed methods, on a running (rooted/emulated, or otherwise instrumentable)
device. This topic is about *static* analysis, but Frida is the natural next step whenever a static
reading is ambiguous or you want to confirm a hypothesis at runtime instead of reasoning it out from
disassembly alone — e.g. logging the actual argument map passed to a `MethodChannel.invokeMethod`
call from [[MethodChannel-Invoke-And-Await]], or confirming which concrete `AbsenceType` singleton
a value from [[Enum-Switch-Via-Pointer-Comparison]] really is at a given point.

## Installation

```
pip install frida-tools
# plus a matching frida-server binary pushed to and running on the target device/emulator
adb push frida-server /data/local/tmp/ && adb shell "chmod +x /data/local/tmp/frida-server"
```

## Common commands / workflows

| Command | Effect |
|---|---|
| `frida-ps -U` | List processes on a USB-connected device |
| `frida -U -f com.example.app -l script.js --no-pause` | Spawn the app with an instrumentation script attached from the start |
| `Interceptor.attach(ptr(...), {...})` (in a script) | Hook a native function at a known address/offset — the direct use case for an address recovered from static analysis |
| `Java.perform(() => { ... })` | Hook ART-managed (Java/Kotlin) methods by class/method name |

## Tips & gotchas

- Hooking a Dart-AOT function directly by address works (it's still just native code at a fixed
  offset), but there's no equivalent of `Java.perform`'s by-name resolution for Dart methods —
  you still need the address from static analysis (or a tool like [[Blutter]]) first.
- Anti-tampering/root-detection in a real app may need bypassing before Frida attaches cleanly —
  out of scope for this topic, but worth knowing before assuming a failed attach means a mistake in
  your script.
- Prefer confirming a *specific, already-formed* hypothesis dynamically over using Frida as a
  substitute for reading the static disassembly in the first place — the two are complementary,
  not alternatives.

## See also

- [[ARM64-Android]]
- [[Flutter-Dart-AOT]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
