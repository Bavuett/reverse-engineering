---
tags: [example]
level: 2
aliases: ["GetMethodID CallVoidMethod ARM64", "JNI upcall"]
created: 2026-11-12
---

# Example: Calling-Back-Into-Java-From-JNI

> [!info] Level 2 — intermediate
> Native code calling a Java method: `GetObjectClass` → `GetMethodID` with a name and a descriptor string → a variadic `Call…Method`. The two strings tell you exactly which Java method native code reaches, even in a stripped library.

## Goal

Follow a native → Java upcall in disassembly and recover the target Java method from the strings passed to `GetMethodID`. Belongs to [[Android-Native-Internals]].

## Source

```c
JNIEXPORT void JNICALL
Java_com_example_Native_notify(JNIEnv *env, jobject thiz, jint code) {
    jclass cls = (*env)->GetObjectClass(env, thiz);
    jmethodID mid = (*env)->GetMethodID(env, cls, "onResult", "(ILjava/lang/String;)V");
    if (mid == NULL) return;                       // NoSuchMethodError pending
    jstring msg = (*env)->NewStringUTF(env, "done");
    (*env)->CallVoidMethod(env, thiz, mid, code, msg);
    (*env)->DeleteLocalRef(env, msg);
}
```

## Compiled (clang -O2, AArch64)

```asm
Java_com_example_Native_notify:
    stp     x29, x30, [sp, #-0x40]!
    stp     x24, x23, [sp, #0x10]
    stp     x22, x21, [sp, #0x20]
    stp     x20, x19, [sp, #0x30]
    mov     x29, sp
    ldr     x8, [x0]
    mov     x19, x0                     ; env
    mov     x20, x1                     ; thiz
    mov     w21, w2                     ; code
    ldr     x8, [x8, #0xf8]             ; GetObjectClass(env, thiz)
    blr     x8
    ldr     x8, [x19]
    mov     x1, x0                      ; cls
    adrp    x2, .Lname
    add     x2, x2, :lo12:.Lname        ; "onResult"
    adrp    x3, .Lsig
    add     x3, x3, :lo12:.Lsig         ; "(ILjava/lang/String;)V"
    mov     x0, x19
    ldr     x8, [x8, #0x108]            ; GetMethodID(env, cls, name, sig)
    blr     x8
    cbz     x0, .Lret                   ; method not found
    ldr     x8, [x19]
    mov     x22, x0                     ; mid
    adrp    x1, .Ldone
    add     x1, x1, :lo12:.Ldone        ; "done"
    mov     x0, x19
    ldr     x8, [x8, #0x538]            ; NewStringUTF(env, "done")
    blr     x8
    ldr     x8, [x19]
    mov     x23, x0                     ; msg
    mov     x0, x19                     ; env
    mov     x1, x20                     ; thiz
    mov     x2, x22                     ; mid
    mov     w3, w21                     ; code      (variadic arg 1)
    mov     x4, x23                     ; msg       (variadic arg 2)
    ldr     x8, [x8, #0x1e8]            ; CallVoidMethod
    blr     x8
    ldr     x8, [x19]
    mov     x0, x19
    mov     x1, x23
    ldr     x8, [x8, #0xb8]             ; DeleteLocalRef(env, msg)
    blr     x8
.Lret:
    ldp     x20, x19, [sp, #0x30]
    ldp     x22, x21, [sp, #0x20]
    ldp     x24, x23, [sp, #0x10]
    ldp     x29, x30, [sp], #0x40
    ret
```

## Step by step

1. **Name every `blr`** with the offset table from [[JNIEnv-Function-Table-Offsets]]: `0xf8` `GetObjectClass`, `0x108` `GetMethodID`, `0x538` `NewStringUTF`, `0x1e8` `CallVoidMethod`, `0xb8` `DeleteLocalRef`.
2. **Resolve the two strings** passed to `GetMethodID` in `x2`/`x3` (via `adrp`/`add`, see [[Loading-Addresses-With-ADRP-And-ADD]]): name `"onResult"`, descriptor `"(ILjava/lang/String;)V"`. Together with the class (here: the class of `thiz`) they identify the Java method precisely — `void onResult(int, String)`. The descriptor syntax is the same as in smali ([[Primitive-And-Reference-Descriptors]]).
3. **Which `Call…Method`** tells you the return type and dispatch: `CallVoidMethod` (virtual, returns `void`), `CallObjectMethod`, `CallIntMethod`, …; `CallStatic…` for static methods (then `x1` is a `jclass` and the ID came from `GetStaticMethodID`); `CallNonvirtual…` for `super`-style calls.
4. **Variadic arguments in registers.** On Android/Linux AArch64, the `...` arguments of `CallVoidMethod` are passed exactly like normal arguments: `w3` = `code`, `x4` = `msg`. (Apple platforms differ; Android doesn't.) The descriptor tells you how many to expect and their types.
5. **The `cbz` after `GetMethodID`** handles a missing method — the JVM has a `NoSuchMethodError` pending and the native code must return. Null checks after `FindClass`/`GetMethodID` are boilerplate, not logic.
6. **Local reference hygiene.** `DeleteLocalRef(msg)` frees the local reference; long-running native loops that forget this leak references. It also confirms which register held the `jstring`.

## Frida angle

To see which Java methods a native library calls back, hook `GetMethodID` itself through the `JNIEnv` table and log `args[2]`/`args[3]` with `readCString()`. That reveals every upcall target at runtime even if the strings are decrypted just before use ([[Native-Memory-And-ARM64]]).

## Compared with real code

- [[JNI-OnLoad-And-RegisterNatives-In-Libflutter]] — the opposite direction: real native code telling the VM which C functions implement Java `native` methods, using name/descriptor strings the same way.
- [[Encryption-Decrypt-JNI-Entry-In-Libencrypt]] — a real JNI function that only converts arguments and results, with no upcalls.

## See also

- [[Android-Native-Internals]]
- [[JNI-Native-Method-Signature]]
- [[JNIEnv-Function-Table-Offsets]]
- [[Methods]] in [[Dalvik-Bytecode]] — the method descriptor format

## References

- [[ARM64-Android-Bibliography|Bibliography]]
