---
tags: [fundamentals]
aliases: [JNI, NDK, Android ELF]
created: 2026-07-28
---

# Android-Native-Internals

## In short

Most native code you'll find in an Android APK is a `.so` for the `arm64-v8a` ABI, built with the
NDK, following plain AAPCS64 with one addition: a JNI-specific calling convention at the boundary
where Java/Kotlin (running on ART) calls into it and back. This chapter covers that boundary and
the ELF shape the `.so` itself takes — the generic Android-native counterpart to
[[Flutter-Dart-AOT]], which covers the very different situation you're in when the "native code" is
actually AOT-compiled Dart instead.

## Explanation

### Where native code lives in an APK

```
app.apk
├── classes.dex, classes2.dex, ...     <- Dalvik bytecode, ART-managed
├── lib/
│   ├── arm64-v8a/
│   │   ├── libnative.so                <- your NDK code (JNI-callable)
│   │   └── libapp.so                    <- if this is a Flutter app: the Dart AOT snapshot
│   ├── armeabi-v7a/  (32-bit ARM, legacy devices)
│   └── x86_64/        (emulators)
└── ...
```

`arm64-v8a` is what matters on essentially every real device today; the other ABI folders exist for
compatibility/emulation and usually mirror the same logic compiled differently.

### The ELF shape of an Android `.so`

Android `.so` files are standard ELF shared objects with a few platform quirks worth knowing before
you go looking for something that isn't actually missing:

- **`DT_NEEDED`/dynamic symbol table**: which other shared objects this one depends on, and what
  symbols it imports/exports — start here (`readelf -d`, `readelf --dyn-syms`) to get a map before
  diving into disassembly.
- **PLT/GOT indirection**: a call to an external function doesn't jump there directly; it jumps to
  a small stub in the **Procedure Linkage Table (PLT)**, which loads the real address from the
  **Global Offset Table (GOT)** — resolved once (lazily, on first call, or eagerly at load time) by
  the dynamic linker. Seeing a `bl` land in a tiny few-instruction stub that then does an indirect
  `br`/`ldr`+`br` through a table is this mechanism, not a bug in your disassembler.
- **`RELR` relocations**: Android's compact relative-relocation format (`DT_RELR`), used to shrink
  relocation tables for the very common case of "this pointer just needs the load bias added" —
  expect to see it instead of the more verbose classic `DT_RELA` on modern Android binaries.
- **PIE (Position-Independent Executable/library) addressing**: every address is computed
  relative to wherever the loader actually placed the library (ASLR), so code references its own
  data/functions via `adrp`+`add`/`ldr` (page address + page-internal offset) rather than absolute
  constants — see [[Instructions#Explanation|`adrp`/`add` in the instructions chapter]].
- **Symbol stripping**: release `.so`s are frequently stripped of non-exported symbols. JNI-exported
  functions (see below) still need to be findable by name, so `JNIEXPORT`/the JNI naming convention
  usually survives even in an otherwise stripped binary — a reliable starting point for orientation.

### JNI: calling from Java/Kotlin into native code

A method declared `native` in Java/Kotlin resolves, at the ABI level, to a C function whose name
follows a fixed mangling scheme (unless registered manually via `RegisterNatives`, in which case
the name can be anything):

```java
package com.example.app;
class Foo {
    native int compute(int x);
}
```

```c
// JNI naming: Java_<package_with_underscores>_<Class>_<method>
JNIEXPORT jint JNICALL
Java_com_example_app_Foo_compute(JNIEnv *env, jobject thiz, jint x);
```

At the calling convention level, this is still plain AAPCS64 — but with two **always-present,
implicit leading arguments** you won't find in the Java signature:

| Register | Argument | Notes |
|---|---|---|
| `X0` | `JNIEnv *env` | Per-thread interface pointer — a pointer to a pointer to a giant function-pointer table (`(*env)->NewStringUTF(env, ...)` etc.) |
| `X1` | `jobject thiz` (instance methods) or `jclass clazz` (static methods) | The receiver, boxed as a JNI reference |
| `X2` onward | The method's actual declared parameters | Shifted two slots later than you'd expect from the Java signature alone |

Recognizing this shift is the single most useful JNI-specific fact: if a native function's first
real argument (`X2`) looks like it's being immediately dereferenced through a huge table of
function pointers loaded from `X0`, you're looking at a JNI entry point calling back into the JVM
(`(**env).SomeJniFunction(env, ...)` — a double-dereference through `X0`, then an indirect `blr`).

### Native code calling back into Java (the reverse direction)

The same `JNIEnv*` table provides functions like `CallObjectMethod`, `CallIntMethod`,
`GetFieldID`/`GetObjectField`, `NewStringUTF`, etc. — all invoked the same way: load a function
pointer out of the table `*env` points to, at a fixed offset (stable across Android versions for a
given NDK API level), then `blr` through it, with `env` and the relevant `jobject`/`jmethodID`
passed as the first real arguments. Seeing a chain of loads through two levels of pointer
indirection followed by an indirect call, repeated with different fixed offsets, is a strong signal
of "this is walking the `JNINativeInterface` vtable" even before you've matched offsets to specific
JNI function names.

### Where Flutter fits

A Flutter APK's `libapp.so` is **not** JNI-callable native code in this sense — it's a Dart AOT
snapshot, with its own calling convention entirely (see [[Flutter-Dart-AOT]]). The two do coexist
in the same APK: Flutter's engine (itself a `.so`, `libflutter.so`) is genuine NDK/JNI-callable
native code that *hosts* the Dart VM, and platform-channel calls (`MethodChannel`, see
[[Flutter-Dart-AOT#Explanation|`AwaitStub`/`MethodChannel::invokeMethod`]]) are how Dart code asks
the engine to do JNI-level work on its behalf. Telling these two layers apart by their disassembly
shape (mandatory `EnterFrame`/`CheckStackOverflow` boilerplate and `THR`/`PP`-relative addressing
vs. plain AAPCS64 with JNI's `env`-table indirection) is the entire point of splitting this
chapter and the next one.

## Worked example

See [[JNI-Native-Method-Signature]] for a full annotated JNI entry point, and
[[PLT-Stub-And-Indirect-Call]] for the PLT/GOT indirection shape.

## More examples

- [[JNI-Native-Method-Signature]]
- [[PLT-Stub-And-Indirect-Call]]

## See also

- [[Functions-And-Calling-Convention]]
- [[Flutter-Dart-AOT]]
- [[Memory-And-Data-Structures]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]

## Flashcards
#flashcards

What are the two implicit leading arguments of every JNI native method, and which registers hold them?::`JNIEnv *env` in `X0`, and `jobject`/`jclass` (the receiver or class) in `X1` — the method's own declared parameters start from `X2`.
<!--SR:!2026-07-28,0,230-->
What does a `bl` landing in a tiny stub that then does an indirect load-and-branch through a table usually indicate?::PLT/GOT indirection — a call to a function in another shared object, resolved through the Global Offset Table by the dynamic linker.
Why does PIE code reference its own data via `adrp`+`add` instead of an absolute address?::Because ASLR places the library at a runtime-chosen base address, so every internal reference has to be computed relative to the current program counter/page rather than baked in as an absolute constant.
Why is `libapp.so` in a Flutter APK not "JNI-callable native code" in the usual sense?::Because it's a Dart AOT snapshot following the Dart VM's own calling convention (mandatory frame/stack-overflow-check boilerplate, THR/PP-relative addressing), not plain AAPCS64 with the JNI env-table convention.
