---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/com/newspaperdirect/pressreader/android/core/mylibrary/Encryption.smali"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Reading-A-Native-Facade-Class-Cold

> [!info] Level 3 — real code
> A real class with no bytecode logic at all: a `<clinit>` that loads `libencrypt.so` and two `native` method declarations. Reading it is about knowing what *isn't* there and where to go next.

## Context

`Encryption` in PressReader's `mylibrary` package is the Java side of the app's native decryption library. It kept its real name (JNI requires the class and method names to match the exported C symbols, so R8 can't rename them), which makes it one of the few completely readable classes in the app — and the bridge from smali into ARM64.

## Original path

`smali_classes2/com/newspaperdirect/pressreader/android/core/mylibrary/Encryption.smali`

## Snippet

```smali
.class public Lcom/newspaperdirect/pressreader/android/core/mylibrary/Encryption;
.super Ljava/lang/Object;
.source "SourceFile"

.method static constructor <clinit>()V
    .locals 1
    :try_start_0
    const-string v0, "encrypt"
    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0
    goto :goto_0
    :catchall_0
    move-exception v0
    invoke-static {v0}, Lj70/a;->a(Ljava/lang/Throwable;)V
    :goto_0
    return-void
.end method

.method public static synchronized native decrypt(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)[B
.end method

.method public static synchronized native password(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)[B
.end method
```

(`.line` directives removed.)

## Reconstructed source

```java
public class Encryption {
    static {
        try {
            System.loadLibrary("encrypt");          // -> lib/arm64-v8a/libencrypt.so
        } catch (Throwable t) {
            j70.a.a(t);                              // log/report, don't crash
        }
    }

    public static synchronized native byte[] decrypt(String a, int b, String c, String d);
    public static synchronized native byte[] password(String a, int b, String c, String d, String e);
}
```

## Notes

- **Empty `native` methods.** A `.method … native` has no body and no `.locals` — the implementation is in a shared library. `static native` means the C function receives `(JNIEnv*, jclass, …)`; an instance `native` would receive `(JNIEnv*, jobject this, …)` (see [[JNI-Native-Method-Signature]]).
- **Finding the library.** `System.loadLibrary("encrypt")` maps to `lib<name>.so`, i.e. `lib/arm64-v8a/libencrypt.so` in the APK. The `<clinit>` placement means the library loads the first time anything touches `Encryption`.
- **Finding the function.** With static JNI binding, the symbol is `Java_` + class path with `/` → `_` + `_` + method name: `Java_com_newspaperdirect_pressreader_android_core_mylibrary_Encryption_decrypt`. That exact symbol is exported by `libencrypt.so`; its ARM64 body is read in [[Encryption-Decrypt-JNI-Entry-In-Libencrypt]]. If the symbol weren't exported, the binding would be dynamic via `RegisterNatives` in `JNI_OnLoad` ([[JNI-OnLoad-And-RegisterNatives-In-Libflutter]]).
- **Register mapping across the boundary.** The descriptor `(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)[B` becomes, on ARM64: `x0` = `JNIEnv*`, `x1` = `jclass`, `x2` = first `String`, `w3` = the `int`, `x4`/`x5` = the last two `String`s, return in `x0` as a `jbyteArray`. The native disassembly confirms exactly this.
- **`synchronized` on a static native method** locks the `Encryption.class` object around every call — so calls are serialized, which hints the native side keeps global state it doesn't protect itself.
- **The swallowed failure.** `.catchall` + report + continue: if the library fails to load, the app keeps running and the first call to `decrypt` throws `UnsatisfiedLinkError` instead. A Frida script that hooks `decrypt` therefore must attach after `<clinit>` has run ([[Hooking-A-Lazily-Loaded-Class-With-A-Retry-Loop]]).
- **Compared with the textbook class.** Every element of [[Classes]] and [[Methods]] is present — header, `<clinit>`, try/catch-all, method declarations — but the instructions that matter are zero. Cold reading here means recognizing the facade and switching tools.

## See also

- [[Reading-Raw-Dalvik]]
- [[Static-Fields-And-Class-Initializer]] — `<clinit>`
- [[Exception-Handling]] — `.catchall`
- [[Android-Native-Internals]] in [[ARM64-Android]]
- [[PressReader]]
- [[Dalvik-Bytecode-Reference|Reference]]
