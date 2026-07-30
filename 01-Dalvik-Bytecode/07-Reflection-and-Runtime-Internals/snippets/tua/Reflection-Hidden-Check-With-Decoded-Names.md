---
tags: [snippet]
project: "TUA (net.pluservice.tua)"
source: "net.pluservice.tua — Cordova/Android hybrid app, decompiled to smali from the APK"
version: "11.26.4"
source_path: "smali/net/pluservice/tua/MainActivity.smali — a reflective call site in attachBaseContext (~line 1394-1436)"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. Small verbatim excerpt kept to illustrate one obfuscation pattern. Check the app's ToS before any redistribution."
---

# Reflection-Hidden-Check-With-Decoded-Names

## Context

This is a **real, unmodified** reflective call from TUA's `MainActivity`, and it's the concrete form of everything [[Reflection-and-Runtime-Internals]] describes: the class name and method name handed to `Class.forName`/`getDeclaredMethod` are not `const-string` literals — they're produced at runtime by the app's own string decoder `b(I[C[Ljava/lang/Object;)V`, reading from encrypted `[C` tables via `fill-array-data`. So even a `strings`/grep pass over the APK finds nothing; the target only exists after the decoder runs. Compare the clean, plaintext-string version in [[Reflective-Hidden-Method-Call]] to see exactly what the encryption adds on top.

## Original path

`` smali/net/pluservice/tua/MainActivity.smali `` (excerpt from `attachBaseContext`, the most reflection-heavy method in the class)

## Snippet

```smali
    new-array v11, v12, [C
    fill-array-data v11, :array_0                       # encrypted char table for the CLASS name
    new-array v12, v7, [Ljava/lang/Object;
    invoke-static {v9, v11, v12}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V
    aget-object v9, v12, v8
    check-cast v9, Ljava/lang/String;                   # v9 = decoded class name, e.g. "android.os.Debug"
    invoke-static {v9}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v9

    invoke-static {v8, v8}, Landroid/view/View;->getDefaultSize(II)I   # junk call to compute a decoder seed
    move-result v11
    add-int/lit8 v11, v11, 0xf
    new-array v12, v5, [C
    fill-array-data v12, :array_1                       # encrypted char table for the METHOD name
    new-array v10, v7, [Ljava/lang/Object;
    invoke-static {v11, v12, v10}, Lnet/pluservice/tua/MainActivity;->b(I[C[Ljava/lang/Object;)V
    aget-object v10, v10, v8
    check-cast v10, Ljava/lang/String;                  # v10 = decoded method name

    new-array v11, v8, [Ljava/lang/Class;               # empty param-types -> no-arg overload
    invoke-virtual {v9, v10, v11}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;
    move-result-object v9
    new-array v10, v8, [Ljava/lang/Object;
    invoke-virtual {v9, v6, v10}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v9
    check-cast v9, Ljava/lang/Long;                     # result cast to Long -> a timing/uptime-style check
```

## Notes

- Two `b(...)` decoder calls each turn an encrypted `[C` table (`:array_0`, `:array_1`) into a `String` — the class name and the method name — so the only fixed text in the bytecode is the *decoder's* signature, never its output. This is the string-encryption layer stacked on top of the plain reflection in [[Reflective-Hidden-Method-Call]].
- The decoder's first argument is a **seed** the surrounding code computes with deliberately pointless-looking calls (`View.getDefaultSize(0,0)` then `+ 0xf`) — the seed both decrypts the table and camouflages the site as unrelated UI code. Recognizing "an Android API call whose result is only used to seed a decoder" is a reliable tell.
- `check-cast v9, Ljava/lang/Long;` on the invoke result reveals the *shape* of the hidden call without its name: a method returning a `Long` with no arguments, dispatched reflectively — consistent with an uptime/`SystemClock`-style timing check used for debugger/emulator detection.
- This exact call site is one of the instances the set-difference hunt in [[Anti-Tampering-Pattern-Workflow]] surfaces: the reflectively-invoked method is never an explicit `invoke-*` target anywhere in the tree, so it appears in the "declared but never directly called" set.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Reflection-and-Runtime-Internals]]
- [[Reflective-Hidden-Method-Call]] — the plaintext-string version, for contrast.
- [[Reading-Raw-Dalvik]] — reading the `b(...)` decoder and its `.array-data` tables.
- [[Tua-Case-Study]] and [[Anti-Tampering-Pattern-Workflow]] in [[Case-Studies]]
