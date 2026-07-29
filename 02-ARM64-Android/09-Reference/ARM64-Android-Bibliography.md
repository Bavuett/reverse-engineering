---
tags: [reference]
aliases: ["ARM64-Android Bibliography"]
---

# ARM64-Android · Bibliography

Official sources, tools, and further reading used throughout this topic. Every chapter note and template links back here under "References" — add the source when you first cite it.

## Primary sources

- [Arm Architecture Reference Manual for A-profile architecture](https://developer.arm.com/documentation/ddi0487/latest) — the authoritative instruction-set reference.
- [Procedure Call Standard for the Arm 64-bit Architecture (AAPCS64)](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst) — the calling convention every non-Dart native function on Android follows.
- [Android NDK documentation](https://developer.android.com/ndk) — native development on Android: build system, ABIs, JNI headers.
- [JNI Specification](https://docs.oracle.com/en/java/javase/21/docs/specs/jni/index.html) — the Java Native Interface, unchanged in the parts Android's ART implements.
- [Executable and Linkable Format (ELF) specification](https://refspecs.linuxfoundation.org/elf/elf.pdf) — binary layout of Android's `.so` files.
- [Dart VM source — `runtime/vm/compiler/backend/il.cc`, `runtime/vm/constants_arm64.h`](https://github.com/dart-lang/sdk/tree/main/runtime/vm) — ground truth for every Dart-AOT-specific register role, stub, and calling convention detail in [[Flutter-Dart-AOT]].

## Tools

- [blutter](https://github.com/worawit/blutter) — extracts and disassembles Dart AOT snapshots from Flutter `libapp.so`, annotating raw ARM64 with class/field/function names recovered from the snapshot metadata. Its `.dart`-named output files are annotated disassembly, not real Dart source — see [[Blutter]].
- [reFlutter](https://github.com/Impact-I/reFlutter) — patches a Flutter APK to re-enable JIT/observatory access for dynamic analysis, complementary to blutter's static approach.
- [Ghidra](https://ghidra-sre.org/) — free disassembler/decompiler, ARM64 processor module included.
- [radare2](https://rada.re/n/radare2.html) / [Cutter](https://cutter.re/) — open-source disassembler/debugger with strong scripting support.
- [Frida](https://frida.re/) — dynamic instrumentation, useful for confirming static findings at runtime.
- [objdump](https://sourceware.org/binutils/docs/binutils/objdump.html) / [readelf](https://sourceware.org/binutils/docs/binutils/readelf.html) (from the Android NDK's `llvm-*` toolchain) — quick ELF/disassembly inspection without a full GUI tool.

## Further reading

- Android's [ABI Management](https://developer.android.com/ndk/guides/abis) guide — which ABI (`arm64-v8a`) maps to which instruction set, and why it's the one that matters for modern devices.
- Dart's [AOT compilation](https://github.com/dart-lang/sdk/blob/main/docs/compiler/aot/START.md) documentation.

## See also

- [[ARM64-Android-Reference|Reference]]
