---
tags: [example]
level: 1
aliases: ["JNI function table offsets", "JNINativeInterface offsets"]
created: 2026-11-12
---

# Example: JNIEnv-Function-Table-Offsets

> [!info] Level 1 — basics
> One idea: every `env->Something(...)` call compiles to "load the table pointer from `[env]`, load an entry at a fixed offset, `blr` to it" — and offset ÷ 8 is the entry's index in `jni.h`.

## Goal

Turn the anonymous `ldr x8, [x8, #0x548]` / `blr x8` pairs that fill every JNI function back into named calls, using a short offset table. Belongs to [[Android-Native-Internals]].

## Source

```c
#include <jni.h>

jstring echo(JNIEnv *env, jclass cls, jstring in) {
    const char *s = (*env)->GetStringUTFChars(env, in, NULL);
    jstring out = (*env)->NewStringUTF(env, s);
    (*env)->ReleaseStringUTFChars(env, in, s);
    return out;
}
```

## Compiled (clang -O2, AArch64)

```asm
echo:
    stp     x29, x30, [sp, #-0x30]!
    stp     x22, x21, [sp, #0x10]
    stp     x20, x19, [sp, #0x20]
    mov     x29, sp
    ldr     x8, [x0]                ; x8 = env->functions  (JNINativeInterface*)
    mov     x19, x0                 ; env
    mov     x20, x2                 ; in
    mov     x1, x2
    mov     x2, xzr                 ; isCopy = NULL
    ldr     x8, [x8, #0x548]        ; [169] GetStringUTFChars
    blr     x8
    ldr     x8, [x19]
    mov     x21, x0                 ; s
    mov     x0, x19
    mov     x1, x21
    ldr     x8, [x8, #0x538]        ; [167] NewStringUTF
    blr     x8
    ldr     x8, [x19]
    mov     x22, x0                 ; out
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    ldr     x8, [x8, #0x550]        ; [170] ReleaseStringUTFChars
    blr     x8
    mov     x0, x22
    ldp     x20, x19, [sp, #0x20]
    ldp     x22, x21, [sp, #0x10]
    ldp     x29, x30, [sp], #0x30
    ret
```

## Step by step

1. **Two loads, one indirect call.** `JNIEnv*` points to a pointer to the function table, so each call is `ldr x8, [env]` → `ldr x8, [x8, #off]` → `blr x8`. `x0` is always `env` again at the call (every JNI function takes `env` first).
2. **Offset ÷ 8 = index.** `0x548 / 8 = 169` → the 170th entry of `JNINativeInterface` in `jni.h` (counting the four reserved slots from 0) = `GetStringUTFChars`.
3. **The offsets worth memorizing** (identical on every 64-bit Android):

   | offset | index | function | offset | index | function |
   | --- | --- | --- | --- | --- | --- |
   | `0x30` | 6 | `FindClass` | `0x538` | 167 | `NewStringUTF` |
   | `0x70` | 14 | `ThrowNew` | `0x548` | 169 | `GetStringUTFChars` |
   | `0xa8` | 21 | `NewGlobalRef` | `0x550` | 170 | `ReleaseStringUTFChars` |
   | `0xb8` | 23 | `DeleteLocalRef` | `0x558` | 171 | `GetArrayLength` |
   | `0xf8` | 31 | `GetObjectClass` | `0x580` | 176 | `NewByteArray` |
   | `0x108` | 33 | `GetMethodID` | `0x5c0` | 184 | `GetByteArrayElements` |
   | `0x110` | 34 | `CallObjectMethod` | `0x600` | 192 | `ReleaseByteArrayElements` |
   | `0x1e8` | 61 | `CallVoidMethod` | `0x640` | 200 | `GetByteArrayRegion` |
   | `0x2f0` | 94 | `GetFieldID` | `0x680` | 208 | `SetByteArrayRegion` |
   | `0x388` | 113 | `GetStaticMethodID` | `0x6b8` | 215 | `RegisterNatives` |
   | `0x468` | 141 | `CallStaticVoidMethod` | `0x720` | 228 | `ExceptionCheck` |

   For `JavaVM*` (a different table, `JNIInvokeInterface`): `0x20` = `AttachCurrentThread`, `0x30` = `GetEnv`.
4. **Arguments follow the C prototype after `env`.** `GetStringUTFChars(env, jstring, jboolean* isCopy)` → `x0`, `x1`, `x2`; the `mov x2, xzr` is the `NULL` `isCopy`. Once a call is named, its prototype names its arguments.
5. **Pairing.** `Get…` calls are usually matched by `Release…` calls with the same `jstring`/array and the pointer returned by the `Get` — here `x20`/`x21` are kept in callee-saved registers precisely so they can be passed to `ReleaseStringUTFChars` at the end.
6. Tools like Ghidra and IDA can apply a `JNIEnv` structure type to `x0` and show names directly; the table above is for when you're reading raw disassembly (or checking the tool's guess).

## Compared with real code

- [[Return-Value-Widening-In-Datastore-JNI]] — real `[x8, #0x30]` (`FindClass`) and `[x8, #0x70]` (`ThrowNew`).
- [[Encryption-Decrypt-JNI-Entry-In-Libencrypt]] — real `0x548`/`0x550`/`0x580`/`0x680` calls in PressReader's decryption library, exactly the pattern above, three strings at a time.

## See also

- [[Android-Native-Internals]]
- [[JNI-Native-Method-Signature]]
- [[Calling-Back-Into-Java-From-JNI]]
- [[B-BL-BLR-And-RET]] — `blr`

## References

- [[ARM64-Android-Bibliography|Bibliography]]
