---
tags: [tool]
tool_name: "Ghidra"
homepage: "https://ghidra-sre.org/"
version: ""
created: 2026-07-28
---

# Ghidra

## Purpose

Free disassembler/decompiler with a solid AArch64 processor module — the default choice in this topic for plain NDK-compiled Android `.so` files (see [[Android-Native-Internals]]), where its decompiler's pseudo-C output is genuinely load-bearing. Less useful as-is on a Dart AOT `libapp.so` — see [[Blutter]] for that case, since Ghidra doesn't know Dart's calling convention or object model out of the box.

## Installation

```
# download a release from ghidra-sre.org, requires a JDK
./ghidraRun
```

## Common commands / workflows

| Command | Effect |
| --- | --- |
| `File -> Import File`, pick a `.so` | Auto-analyzes with the ARM64 language module |
| `Window -> Defined Strings` | Fast enumeration of string literals — useful for finding `MethodChannel` method names, JNI method names, URLs |
| `Window -> Symbol Table` | Exported/imported symbols — a starting map before diving into disassembly |
| Decompiler window (right pane) | Pseudo-C reconstruction — best-effort, always cross-check against the raw listing for anything load-bearing |

## Tips & gotchas

- On a Dart AOT `libapp.so`, Ghidra's decompiler will misinterpret the reserved registers (`THR`, `PP`, ...) as ordinary variables — expect it to actively mislead rather than just be unhelpful; prefer the raw disassembly view and this topic's manual patterns over trusting the decompiler here.
- Auto-analysis can take a while on a large `.so` (Flutter's `libflutter.so` engine binary especially) — let it finish before navigating, half-analyzed cross-references are misleading.
- The Symbol Table + Defined Strings combo is usually a faster orientation step than jumping straight into `main`/`JNI_OnLoad`.

## See also

- [[ARM64-Android]]
- [[Android-Native-Internals]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
