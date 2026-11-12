---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "lib/arm64-v8a/libencrypt.so, function Java_com_newspaperdirect_pressreader_android_core_mylibrary_Encryption_decrypt (0x589d0)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Encryption-Decrypt-JNI-Entry-In-Libencrypt

> [!info] Level 3 — real code
> A real statically-bound JNI function read against its Java declaration: the descriptor `(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)[B` mapped onto `x0`–`x5`, three `GetStringUTFChars`, a heap buffer, and a `byte[]` built with `NewByteArray` + `SetByteArrayRegion`.

## Context

PressReader's `Encryption` class declares `public static synchronized native byte[] decrypt(String, int, String, String)` and loads `libencrypt.so` ([[Reading-A-Native-Facade-Class-Cold]]). Because the binding is static, the C function is exported under its mangled JNI name and can be found by symbol. The library is a mix of PressReader's own code (`DecryptData`, `GetXmlAtribute`, `base64_decode`, `CryptoAlgorithm`, `Encryptor`/`Decryptor`) and a statically linked OpenSSL (`ERR_*`, `CRYPTO_*`, `EVP_*`).

## Original path

`lib/arm64-v8a/libencrypt.so` → `Java_com_newspaperdirect_pressreader_android_core_mylibrary_Encryption_decrypt`, address `0x589d0`, 676 bytes.

## Snippet — entry and argument conversion

```asm
589d0:  sub     sp, sp, #0x110
589d4:  stp     x29, x30, [sp, #0xb0]
589d8:  stp     x28, x27, [sp, #0xc0]       ; all ten callee-saved registers:
589dc:  stp     x26, x25, [sp, #0xd0]       ; lots of values live across calls
589e0:  stp     x24, x23, [sp, #0xe0]
589e4:  stp     x22, x21, [sp, #0xf0]
589e8:  stp     x20, x19, [sp, #0x100]
589ec:  add     x29, sp, #0xb0
589f0:  mrs     x23, tpidr_el0              ; stack canary setup
589f4:  mov     x22, x2                     ; jstring a   (Java arg 1)
589f8:  mov     x1, x2
589fc:  ldr     x8, [x23, #0x28]
58a00:  mov     x2, xzr                     ; isCopy = NULL
58a04:  mov     x20, x5                     ; jstring d   (Java arg 4, may be null)
58a08:  mov     x21, x4                     ; jstring c   (Java arg 3)
58a0c:  mov     w26, w3                     ; jint    b   (Java arg 2)
58a10:  mov     x19, x0                     ; JNIEnv*
58a14:  stur    x8, [x29, #-0x10]
58a18:  ldr     x8, [x0]
58a1c:  ldr     x8, [x8, #0x548]            ; GetStringUTFChars(env, a, NULL)
58a20:  blr     x8
58a24:  ldr     x8, [x19]
58a28:  mov     x25, x0                     ; s_a
58a2c:  mov     x0, x19
58a30:  mov     x1, x21
58a34:  mov     x2, xzr
58a38:  ldr     x8, [x8, #0x548]            ; GetStringUTFChars(env, c, NULL)
58a3c:  blr     x8
58a40:  str     x0, [sp, #8]                ; s_c (spilled: ran out of callee-saved regs)
58a44:  cbz     x20, 0x58a68                ; d == null ?
58a48:  ldr     x8, [x19]
58a4c:  mov     x0, x19
58a50:  mov     x1, x20
58a54:  mov     x2, xzr
58a58:  ldr     x8, [x8, #0x548]            ; GetStringUTFChars(env, d, NULL)
58a5c:  blr     x8
58a60:  mov     x24, x0                     ; s_d
58a64:  b       0x58a6c
58a68:  mov     x24, xzr                    ; s_d = NULL
58a6c:  mov     x0, x25
58a70:  str     xzr, [sp, #0x20]
58a74:  bl      strlen                      ; n = strlen(s_a)
58a78:  sxtw    x28, w0
58a7c:  mov     x0, x28
58a80:  bl      malloc                      ; buf = malloc(n)
58a84:  mov     x27, x0
58a88:  str     x0, [sp, #0x18]
58a8c:  add     x1, x25, x28                ; s_a + n
58a90:  add     x3, sp, #0x14               ; &buf_len
58a94:  mov     x0, x25
58a98:  mov     x2, x27
58a9c:  bl      base64_decode<const char*, char*>
```

## Snippet — building the `byte[]` result

```asm
58ba8:  cmp     w26, #1                     ; w26 now holds result_len
58bac:  b.lt    0x58bec
58bb0:  ldr     x8, [x19]
58bb4:  mov     x0, x19
58bb8:  mov     w1, w26
58bbc:  ldr     x8, [x8, #0x580]            ; arr = NewByteArray(env, len)
58bc0:  blr     x8
58bc4:  ldr     x8, [x19]
58bc8:  mov     x20, x0
58bcc:  add     x4, sp, #0x20               ; result buffer (on the stack)
58bd0:  mov     x0, x19
58bd4:  mov     x1, x20
58bd8:  mov     w2, wzr                     ; start = 0
58bdc:  ldr     x8, [x8, #0x680]            ; SetByteArrayRegion(env, arr, 0, len, buf)
58be0:  mov     w3, w26
58be4:  blr     x8
58be8:  b       0x58bf0
58bec:  mov     x20, xzr                    ; return NULL
58bf0:  ...                                 ; canary check; x0 = x20; epilogue; ret
```

## Reconstructed source (outline)

```cpp
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_newspaperdirect_pressreader_android_core_mylibrary_Encryption_decrypt(
        JNIEnv* env, jclass, jstring a, jint b, jstring c, jstring d) {
    const char* s_a = env->GetStringUTFChars(a, nullptr);
    const char* s_c = env->GetStringUTFChars(c, nullptr);
    const char* s_d = d ? env->GetStringUTFChars(d, nullptr) : nullptr;

    int   n   = strlen(s_a);
    char* buf = (char*) malloc(n);
    int   buf_len;
    char  result[...];  int result_len = 0;
    // base64_decode(s_a) -> DecryptData(&buf, buf_len, b, NULL|s_c, s_d)
    //   -> GetXmlAtribute(buf, "encryptionKey", ...) -> base64_decode -> result
    // (control flow analysed in Conditional-Cleanup-Chain-In-Libencrypt)

    /* release the three strings */
    if (result_len < 1) return nullptr;
    jbyteArray arr = env->NewByteArray(result_len);
    env->SetByteArrayRegion(arr, 0, result_len, (jbyte*) result);
    return arr;
}
```

## Notes

- **Descriptor → registers.** For a `static native` method: `x0` = `JNIEnv*`, `x1` = `jclass` (never used here, so never saved), then the Java parameters in order: `x2` = `String a`, `w3` = `int b`, `x4` = `String c`, `x5` = `String d`. The prologue's `mov`s into `x19`–`x26` are the parameter-naming step done for you. Compare [[JNI-Native-Method-Signature]], which shows the same mapping on a hand-written example.
- **Callee-saved pressure.** All of `x19`–`x28` are saved, and one string pointer still has to be spilled to `[sp, #8]`. That's a function juggling many values across many calls; expect stack slots to carry meaning ([[Tracking-A-Stack-Slots-Meaning]]).
- **Nullable parameter.** Only the fourth string is null-checked before `GetStringUTFChars` (`cbz x20`), so the Java caller may pass `null` for `d` but not for `a`/`c` — a contract recovered from code.
- **Strings in, bytes out.** `GetStringUTFChars` (`0x548`) / `ReleaseStringUTFChars` (`0x550`) bracket the work; the result is returned as a Java `byte[]` via `NewByteArray` (`0x580`) + `SetByteArrayRegion` (`0x680`). Offsets decoded with [[JNIEnv-Function-Table-Offsets]].
- **What the strings say.** `.rodata` references in this function include the log tag `"Panda"`, error messages about a base64 certificate and a licence file, and the XML attribute name `"encryptionKey"`. So `decrypt` takes a base64 licence/certificate blob, decrypts it, and returns the decoded `encryptionKey` attribute — the key material is *produced at runtime*, which is why the easier way to observe it is dynamic: hook `Encryption.decrypt` at the Java layer and dump the returned `byte[]` ([[Java-Layer-Hooking]]), rather than emulating the native code.
- **Compared with the basic examples.** [[JNIEnv-Function-Table-Offsets]] showed a single Get/New/Release triple; this function is three Gets, one New + SetRegion, and three Releases, wrapped around real work — the same pattern at production scale.

## See also

- [[Android-Native-Internals]]
- [[Conditional-Cleanup-Chain-In-Libencrypt]] — this function's control flow
- [[Stack-Protector-And-Tail-Call-In-Datastore-JNI]] — the canary mechanism used here
- [[PressReader]]
- [[ARM64-Android-Reference|Reference]]
