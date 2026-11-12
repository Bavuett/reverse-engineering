---
tags: [example]
level: 1
aliases: ["smali descriptor to Frida", "overload string from smali"]
created: 2026-11-12
---

# Example: From-Smali-Signature-To-Frida-Overload

> [!info] Level 1 — basics
> One idea: every Frida Java hook target is a smali method reference translated mechanically — class descriptor → dotted name, parameter descriptors → `.overload(...)` strings.

## Goal

Turn a method signature read in smali (or jadx) into the exact `Java.use(...).method.overload(...)` call, including arrays, inner classes and constructors. Belongs to [[Static-Dynamic-Integration]].

## Translation table

| Smali | Meaning | `Java.use` / `.overload` string |
| --- | --- | --- |
| `Lcom/example/net/Api;` | class | `"com.example.net.Api"` |
| `Lcom/example/Outer$Inner;` | inner class | `"com.example.Outer$Inner"` |
| `I` `J` `Z` `B` `S` `C` `F` `D` | primitives | `"int"` `"long"` `"boolean"` `"byte"` `"short"` `"char"` `"float"` `"double"` |
| `Ljava/lang/String;` | object | `"java.lang.String"` |
| `[B` | `byte[]` | `"[B"` |
| `[Ljava/lang/String;` | `String[]` | `"[Ljava.lang.String;"` |
| `<init>` | constructor | `$init` |
| `<clinit>` | static initializer | not hookable after it has run |

## Worked translation

```smali
.class public final Lcom/example/net/Api;
.method public static sign([BJLjava/lang/String;)Ljava/lang/String;
.method public constructor <init>(Landroid/content/Context;Z)V
```

```javascript
Java.perform(() => {
    const Api = Java.use("com.example.net.Api");

    Api.sign.overload("[B", "long", "java.lang.String").implementation = function (data, ts, key) {
        const out = this.sign(data, ts, key);           // static: `this` is the class wrapper
        console.log(`sign(${data.length} bytes, ${ts}, ${key}) -> ${out}`);
        return out;
    };

    Api.$init.overload("android.content.Context", "boolean").implementation = function (ctx, flag) {
        console.log(`new Api(ctx, ${flag})`);
        return this.$init(ctx, flag);
    };
});
```

## Step by step

1. **Class**: drop `L` and `;`, replace `/` with `.`; keep `$` for inner classes.
2. **Parameters**: read the descriptor between the parentheses left to right — `[B` `J` `Ljava/lang/String;` — and translate each. The return type (after `)`) is never part of `.overload`.
3. **Primitives become Java keywords**, objects become dotted names, **arrays stay in descriptor form** with dots: `[B`, `[Ljava.lang.String;`. This asymmetry is the most common source of "no overload matching" errors.
4. **Constructors** are `$init`; to *create* an instance from JS use `$new(...)`.
5. **Static vs instance** changes nothing in the overload string; it changes what `this` is inside the implementation.
6. **When in doubt, ask Frida**: an incorrect `.overload(...)` throws an error listing all real overloads — or print them first ([[Dumping-Real-Method-Signatures-Before-Hooking]]).

## Compared with real code

- [[Neutralizing-A-Hidden-Check-With-A-No-Op-Implementation]] — smali `onMessageChannelReady(JJ)V` → `.overload('long', 'long')`.
- [[Disabling-OkHttp-CertificatePinner]] — a real array parameter: `[Ljava.security.cert.Certificate;`.
- [[Primitive-And-Reference-Descriptors]] in [[Dalvik-Bytecode]] — the descriptor grammar itself.

## See also

- [[Static-Dynamic-Integration]]
- [[From-Ghidra-Offset-To-Interceptor-Address]] — the native-code counterpart
- [[Types]] and [[Methods]] in [[Dalvik-Bytecode]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
