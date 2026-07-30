---
tags: [snippet]
project: "TUA (net.pluservice.tua)"
source: "net.pluservice.tua — Cordova/Android hybrid app, hardened with a second check layer loaded via InMemoryDexClassLoader"
version: "11.26.4"
source_path: "Frida hook on dalvik.system.InMemoryDexClassLoader.$init to dump the decrypted .dex ByteBuffer"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. Small fragment kept to illustrate one hooking pattern. Check the app's ToS before any redistribution."
---

# Dumping-An-InMemoryDex-Payload

## Context

After TUA's 15 known static anti-tamper stubs were neutralized the app *still* crashed — because a second copy of the same reflection-hidden checks lives inside a `.dex` decrypted at runtime and loaded via `InMemoryDexClassLoader`, never present on disk in cleartext (the full story is [[In-Memory-Dex-Loading]]). The way to see that hidden code is to hook the loader's constructor and dump the decrypted `ByteBuffer` it's handed straight out of memory — a live-memory dump feeding static re-analysis, i.e. the [[Static-Dynamic-Integration]] loop, applied to defeat the anti-detection layer [[Anti-Detection-And-Gadget-Mode]] describes.

## Original path

`` Frida hook attached to net.pluservice.tua — targets a runtime class loader, not a file in the smali tree ``

## Snippet

```javascript
Java.perform(() => {
    const InMemoryDexClassLoader = Java.use("dalvik.system.InMemoryDexClassLoader");

    // ctor(ByteBuffer dexData, ClassLoader parent) — dexData is the DECRYPTED dex, in memory only.
    InMemoryDexClassLoader.$init.overload("java.nio.ByteBuffer", "java.lang.ClassLoader")
        .implementation = function (buf, parent) {
            const remaining = buf.remaining();
            console.log(`[!] InMemoryDexClassLoader loading a ${remaining}-byte dex`);

            // Copy the ByteBuffer's bytes out and ship them to the host to write as classesN.dex.
            const Arr = Java.use("[B");
            const bytes = Arr.$new(remaining);
            buf.get(bytes);                 // drains into our byte[] (advances position; dup first if reused)
            send({ type: "dex", size: remaining }, Java.array("byte", bytes));

            return this.$init(buf, parent); // let the real load proceed
        };
});
```

## Notes

- The payload only exists as plaintext at the instant it's passed to the loader — hooking the **constructor** (not a later `loadClass`) catches it at the one moment the decrypted bytes are in a readable `ByteBuffer`. The same "catch it at construction" reasoning as [[Hooking-A-Constructor-And-Casting-Arguments]].
- `buf.get(bytes)` advances the buffer's position; in TUA the app then uses the same buffer, so a robust script `.duplicate()`s it first (elided here) to avoid disturbing the real load — the kind of detail that turns a triage one-liner into a script safe to leave running.
- The dumped bytes are a real `.dex`: written to disk and opened in a decompiler (or `dexdump`), they reveal the second, dynamically-loaded set of reflection-hidden decoy checks — which is how [[In-Memory-Dex-Loading]] finally traced the surviving crash to a shared resolver-cache class reused across the app.
- This is a concrete instance of dumping code that *doesn't exist on disk* — the highest-value move in [[Static-Dynamic-Integration]] — but aimed at an anti-tamper payload rather than a packer, which is why it also belongs to [[Anti-Detection-And-Gadget-Mode]].

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Anti-Detection-And-Gadget-Mode]]
- [[Static-Dynamic-Integration]]
- [[Reflection-and-Runtime-Internals]] in [[Dalvik-Bytecode]] — the dynamic-class-loading concept this exploits.
- [[Tua-Case-Study]] and [[In-Memory-Dex-Loading]] in [[Case-Studies]]
