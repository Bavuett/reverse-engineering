---
tags: [snippet]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "eu.spaggiari.classevivastudente — libflutter.so, arm64-v8a (Flutter engine native library)"
version: "unknown (Flutter engine version not recorded in the imported excerpt)"
source_path: "libflutter.so — JNI_OnLoad / RegisterNatives boilerplate, objdump-annotated ARM64 (illustrative reconstruction of the standard Flutter-engine shape)"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. Small excerpt kept to illustrate one ELF/JNI pattern. Check the app's license and ToS before any redistribution."
---

# JNI-OnLoad-And-RegisterNatives-In-Libflutter

## Context

Flutter's engine library `libflutter.so` doesn't expose its native methods under the `Java_<pkg>_<Class>_<method>` naming scheme — it registers them dynamically in `JNI_OnLoad` via `RegisterNatives`, which is exactly the "unless registered manually, the name can be anything" case [[Android-Native-Internals]] flags. That's why grepping a Flutter APK's `.so` for `Java_` finds almost nothing useful: the real entry points are installed at load time from a table of `{name, signature, fnPtr}` structs. Recognizing this shape tells you *where* the hookable native methods actually come from in a Flutter target (relevant background for [[Network-Interception]]'s "there's no Java networking to hook" conclusion).

## Original path

`` libflutter.so — exported JNI_OnLoad, arm64-v8a ``

## Snippet

```asm
JNI_OnLoad:
    stp     x29, x30, [sp, #-0x20]!
    mov     x29, sp
    ; JavaVM* in x0 -> get a JNIEnv*
    add     x1, sp, #0xc                 ; &env (out-param)
    mov     w2, #0x10006                 ; JNI_VERSION_1_6
    ldr     x8, [x0]                     ; x8 = *JavaVM (the JNIInvokeInterface vtable)
    ldr     x8, [x8, #0x30]              ; x8 = vtable->GetEnv (slot 6)
    blr     x8                           ; env = JavaVM->GetEnv(&env, 1.6)
    ...
    ; env->RegisterNatives(clazz, gMethods, count)
    adrp    x1, gFlutterJNIMethods       ; table of {const char* name, const char* sig, void* fn}
    add     x1, x1, :lo12:gFlutterJNIMethods
    mov     w2, #0x2b                    ; 43 methods
    ldr     x8, [x0]                     ; JNIEnv vtable
    ldr     x8, [x8, #0x6b8]             ; vtable->RegisterNatives (slot 215)
    blr     x8
```

## Notes

- The whole point of `JNI_OnLoad` here is the `RegisterNatives` call: it binds a table of native function pointers to Java method names at load time, so the `.so` needs no `Java_*` exports at all. The methods (`nativeAttach`, `nativeInit`, message-channel plumbing, ...) are named only inside the `gMethods` table's string pointers.
- Every JNI call is an **indirect call through the interface vtable**: `ldr x8,[x0]` gets the `JNIEnv`'s function table, `ldr x8,[x8,#off]` selects a slot by fixed offset (`GetEnv` and `RegisterNatives` sit at well-known offsets), then `blr x8`. Reading these offsets against the JNI function-table layout is how you name an otherwise-opaque `blr x8` in native Android code — the same indirect-call reading skill as [[PLT-Stub-And-Indirect-Call]].
- To actually enumerate the registered methods at runtime, hook `RegisterNatives` with Frida and dump the `gMethods` table (`name`, `sig`, `fnPtr` per entry) — the dynamic counterpart that turns this static shape into a concrete list of hookable addresses.
- `mov w2, #0x10006` = `JNI_VERSION_1_6`; recognizing that constant is a quick confirmation you're looking at a `GetEnv`/`GetJavaVM` handshake rather than unrelated code.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Android-Native-Internals]]
- [[PLT-Stub-And-Indirect-Call]] and [[JNI-Native-Method-Signature]] — the sibling examples on indirect calls and JNI signatures.
- [[Flutter-Dart-AOT]] — why a Flutter app's real logic is in `libapp.so`, not these engine bindings.
- [[ClasseViva-Case-Study]] in [[Case-Studies]]
