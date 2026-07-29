---
tags: [snippet, placeholder]
project: "Demo App (placeholder, not real)"
source: com.example.demo
version: "1.0.0"
source_path: "smali/com/example/demo/ExampleClass.smali"
date_added: 2026-07-28
license_note: "Placeholder note created only to show the expected format — does not contain code extracted from a real app."
---

# Demo · ExampleClass (placeholder)

> [!info] This is a demonstration note
>
> It doesn't come from a real app: it only shows **the recommended format** for when you eventually want to add a smali snippet actually extracted from an APK, related to this chapter's concept (classes/fields). To create a new one, use the [[New-Snippet]] template instead of copying this file.

## Context

Describe here, in a couple of sentences, what the class/method does and why it's interesting (e.g. "handles license validation", "implements a string-obfuscation routine", ...).

## Original path

`smali/com/example/demo/ExampleClass.smali` (after decompiling with `apktool d app-name.apk`, see [[Dalvik-Bytecode-Bibliography|Bibliography]])

## Snippet

```smali
.class public Lcom/example/demo/ExampleClass;
.super Ljava/lang/Object;

.method public static getGreeting()Ljava/lang/String;
    .locals 1
    const-string v0, "this is just a placeholder"
    return-object v0
.end method
```

## Notes

Record any recognized patterns here (e.g. "matches the [[Methods|static method]] pattern", "name obfuscation typical of R8/ProGuard", etc.).

## See also

- [[Classes]]
