---
tags: [tool]
tool_name: "objdump / readelf (NDK llvm toolchain)"
homepage: "https://developer.android.com/ndk"
version: ""
created: 2026-07-28
---

# Objdump-And-Readelf

## Purpose

The Android NDK ships `llvm-objdump`/`llvm-readelf` (under
`<ndk>/toolchains/llvm/prebuilt/<host>/bin/`), which understand Android's ELF quirks (`RELR`
relocations, etc.) better than a generic distro `binutils` build might. Fastest path to a quick
disassembly listing or ELF header/section dump without opening a full GUI tool — see
[[Android-Native-Internals]] for what to look for in the output.

## Installation

```
# comes with the Android NDK; add to PATH, or invoke with the full toolchain path
export PATH="$ANDROID_NDK/toolchains/llvm/prebuilt/<host-tag>/bin:$PATH"
```

## Common commands / workflows

| Command | Effect |
|---|---|
| `llvm-objdump -d libnative.so` | Full disassembly listing |
| `llvm-objdump -d --no-show-raw-insn -C libnative.so` | Disassembly with C++ symbol demangling, no raw bytes cluttering output |
| `llvm-readelf -d libnative.so` | Dynamic section — `DT_NEEDED` dependencies, `DT_RELR`/`DT_RELA` relocation type |
| `llvm-readelf --dyn-syms libnative.so` | Exported/imported dynamic symbols |
| `llvm-readelf -h libnative.so` | ELF header — confirms ABI (`EM_AARCH64`), entry point, PIE flag |
| `llvm-nm -D libnative.so` | Just the dynamic symbol names, quickest first look for JNI-exported (`Java_...`) functions |

## Tips & gotchas

- `llvm-nm -D | grep '^Java_'` is a one-liner to enumerate every JNI-exported function name in a
  `.so` before opening a heavier tool — most native libraries won't have every internal symbol
  stripped, but JNI exports specifically have to survive for the JVM to find them by name.
- `llvm-readelf -d` showing `RELR` rather than `RELA` is expected on modern Android — not a sign of
  anything unusual, see [[Android-Native-Internals#Explanation|the ELF section]].
- These are read-only inspection tools — nothing here patches or runs anything, safe to use on
  arbitrary extracted binaries.

## See also

- [[ARM64-Android]]
- [[Android-Native-Internals]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
