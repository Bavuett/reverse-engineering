---
tags: [tool]
tool_name: "blutter"
homepage: "https://github.com/worawit/blutter"
version: ""
created: 2026-07-28
---

# Blutter

## Purpose

Extracts a Flutter app's Dart AOT snapshot from `libapp.so` and disassembles it to ARM64, annotated with class/field/function names recovered from the snapshot's own metadata (object pool contents, class table, function symbols where present). This is the tool behind every real excerpt in [[Classeviva-Flutter-Case-Study]] — without it, `libapp.so` is just a stripped ELF full of ARM64 with no names attached at all.

## Installation

```
git clone https://github.com/worawit/blutter
# follow the repo's own setup instructions (Python + a matching Dart SDK checkout for the
# target app's Dart/Flutter version are required — blutter needs to match VM internals per version)
```

## Common commands / workflows

| Command | Effect |
| --- | --- |
| Point blutter at an extracted APK's `lib/arm64-v8a/` directory | Locates `libapp.so` (and `libflutter.so` for engine version detection) |
| Run blutter's main analysis script | Produces one output file per original Dart package/file path, containing annotated disassembly |
| Inspect the recovered object pool / class list output | Useful on its own for enumerating every class/string in the app before reading any function bodies |

## Tips & gotchas

- Output files are named and organized like Dart source (`package:foo/bar.dart` → `foo/bar.dart`) but contain **disassembly, not real source** — don't mistake blutter's output for a decompiled Dart source recovery tool; it recovers _names_, not source-level control flow or variable names beyond what the snapshot's metadata already carries.
- Getting the Dart/Flutter engine version wrong when configuring blutter is the most common failure mode — reserved-register offsets (`THR::stack_limit` at `+0x38`, etc.) and stub addresses are version-dependent internals, not a stable public ABI.
- Pair with [[Frida]] for dynamic confirmation when a static reading is ambiguous (e.g. confirming what a `MethodChannel` call site's argument map actually contains at runtime).

## See also

- [[ARM64-Android]]
- [[Flutter-Dart-AOT]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
