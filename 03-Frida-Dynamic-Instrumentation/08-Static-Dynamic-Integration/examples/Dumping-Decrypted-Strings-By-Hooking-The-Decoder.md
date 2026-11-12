---
tags: [example]
level: 2
aliases: ["string decryption hook", "dump obfuscated strings Frida"]
created: 2026-11-12
---

# Example: Dumping-Decrypted-Strings-By-Hooking-The-Decoder

> [!info] Level 2 — intermediate
> Combines static recognition with a dynamic shortcut: identify the string-decoder method in smali by its shape, then hook it and let the app decrypt its own strings — each result logged with the call site that asked for it.

## Goal

Recover the plaintext of strings an obfuscator encrypted, without reimplementing its algorithm. Belongs to [[Static-Dynamic-Integration]].

## Recognizing a decoder statically

String obfuscators replace each `const-string` with a call to a small static method that rebuilds the string from a byte/char array and some integer arguments. Signs in smali:

- a `private static` method returning `Ljava/lang/String;`, taking only primitives (`(ISB)`, `(III)`, `(I)`);
- reading a static array field (`sget-object vX, …->$$c:[B`);
- arithmetic on the parameters before an array loop, ending in `new String(…)` / `String.intern()`;
- **many call sites**, each preceded by constant setup of its arguments.

## Script

```javascript
Java.perform(() => {
    const Host = Java.use("com.example.app.MainActivity");
    const Thread = Java.use("java.lang.Thread");
    const seen = new Set();

    Host["$$i"].implementation = function (a, b, c) {      // bracket syntax: see step 5
        const s = this["$$i"](a, b, c);
        const key = `${a},${b},${c}`;
        if (!seen.has(key)) {
            seen.add(key);
            const caller = Thread.currentThread().getStackTrace()[3];   // [0..2] = VM + this method
            console.log(`[str] (${key}) -> ${JSON.stringify(s)}   at ${caller}`);
        }
        return s;
    };
});
```

## Step by step

1. **Let the app do the work.** Reimplementing a decoder means porting its arithmetic exactly — and redoing it on every app update. Hooking returns the right answer for free.
2. **Deduplicate by arguments.** Decoders are deterministic: the same arguments yield the same string. Logging each argument tuple once keeps output readable even when a string is decrypted in a loop.
3. **Attach the call site.** A plaintext string is useful only next to the code that uses it. `Thread.getStackTrace()` gives the caller's class, method and (if present) line number; map that back to the smali.
4. **Coverage is limited to executed code.** Only strings decrypted during *your* run appear. To dump all of them, call the decoder yourself for every argument tuple found statically (grep the call sites for the constants loaded before `invoke-static … $$i`), e.g. `Host["$$i"](13, 7, 4)`.
5. **Names with `$`** are valid JS identifiers, but bracket syntax (`Host["$$i"]`) avoids confusion with Frida's own `$`-prefixed wrapper members (`$init`, `$new`, `$className`).
6. **Native decoders** work the same way with `Interceptor.attach` on the decoder function, reading the output buffer in `onLeave` ([[Hooking-An-Exported-Libc-Function]]).

## Compared with real code

The TUA app's `MainActivity` contains exactly such a decoder — `private static $$i(ISB)Ljava/lang/String;` — which starts by scaling its three parameters and reading the static byte array `$$c`:

```smali
.method private static $$i(ISB)Ljava/lang/String;
    .locals 6
    mul-int/lit8 p1, p1, 0x2
    rsub-int/lit8 v0, p1, 0x1
    mul-int/lit8 p2, p2, 0x2
    add-int/lit8 p2, p2, 0x7a
    mul-int/lit8 p0, p0, 0x3
    rsub-int/lit8 p0, p0, 0x3
    sget-object v1, Lnet/pluservice/tua/MainActivity;->$$c:[B
    new-array v0, v0, [B
    ...
```

Its call sites compute the three arguments with `int-to-byte`/`int-to-short` conversions just before `invoke-static {v13, v12, v9}, …->$$i(ISB)Ljava/lang/String;`. The hidden checks described in [[Neutralizing-A-Hidden-Check-With-A-No-Op-Implementation]] used runtime-decrypted strings of this kind for their class and method names — which is why they never appeared in a plain `grep` of the smali. See [[Anti-Tampering-Pattern-Workflow]].

## See also

- [[Static-Dynamic-Integration]]
- [[Capturing-A-Stack-Trace-From-Inside-A-Hook]]
- [[Reading-Raw-Dalvik]] in [[Dalvik-Bytecode]]
- [[Dalvik-Instructions]] — `mul-int/lit8`, `rsub-int/lit8`, `int-to-byte`

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
