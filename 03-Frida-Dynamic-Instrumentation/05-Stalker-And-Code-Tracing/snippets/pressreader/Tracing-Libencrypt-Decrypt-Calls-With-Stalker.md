---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "lib/arm64-v8a/libencrypt.so, function Java_com_newspaperdirect_pressreader_android_core_mylibrary_Encryption_decrypt (0x589d0); call targets resolved through the PLT"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Tracing-Libencrypt-Decrypt-Calls-With-Stalker

> [!info] Level 3 — real code
> A Stalker trace designed against a real JNI function: the static call list of PressReader's `Encryption.decrypt` (read from its `bl`/`blr` instructions) becomes the expected sequence, and a scoped call trace tells you which branches one real invocation actually took.

> [!warning] Static expectation, not a captured run
> The call sequence below comes from the disassembly of `libencrypt.so`; it's what the trace *should* show on the success path. Use it as the reference to compare a real run against, not as recorded output.

## Context

`Encryption.decrypt(String, int, String, String)` is a static native method whose C side ([[Encryption-Decrypt-JNI-Entry-In-Libencrypt]]) decodes a base64 blob, decrypts it, extracts an XML attribute and decodes it again, with several error exits ([[Conditional-Cleanup-Chain-In-Libencrypt]]). Reading it statically gives the *possible* paths; a Stalker trace of one call gives the *taken* path — which error exit fired, whether the second `DecryptData` ran, whether the result was empty. Part of [[PressReader]].

## Original path

`lib/arm64-v8a/libencrypt.so` → `Java_…_Encryption_decrypt` at `0x589d0` (676 bytes). Its direct calls go through PLT stubs; resolving each stub's GOT relocation gives the callee names:

| Call site | PLT stub | Callee |
| --- | --- | --- |
| `0x58a1c`/`0x58a38`/`0x58a58` | `blr [JNIEnv+0x548]` | `GetStringUTFChars` (×3, third only if `d != null`) |
| `0x58a74` | `0xa9750` | `strlen` |
| `0x58a80` | `0xa9730` | `malloc` |
| `0x58a9c` | `0xa9940` | `base64_decode<const char*, char*>` |
| `0x58ab8`, `0x58ad4` | `0xa9740` | `DecryptData(char*&, int, int, const char*, const char*)` (two call sites) |
| `0x58b00` | `0xa9900` | `GetXmlAtribute(const char*, const char*, char*)` → `cbz w0` = not found |
| `0x58b10` | `0xa9950` | `__strlen_chk` |
| `0x58b28` | `0xa9960` | `base64_decode<char*, char*>` |
| `0x58b44`, `0x58c38`, `0x58c64` | `0xa97a0` | `__android_log_print` (tag `"Panda"`) |
| `0x58b4c`, `0x58c40` | `0xa97d0` | `free` |
| `0x58b6c`/`0x58b88`/`0x58ba4` | `blr [JNIEnv+0x550]` | `ReleaseStringUTFChars` (each guarded by `cbz`) |
| `0x58bc0`, `0x58be4` | `blr [JNIEnv+0x580]`, `[+0x680]` | `NewByteArray`, `SetByteArrayRegion` (only if length ≥ 1) |
| `0x58c70` | `0xa97e0` | `__stack_chk_fail` |

The C++ prototypes come for free from the mangled names (`_Z11DecryptDataRPciiPKcS2_` = `DecryptData(char*&, int, int, char const*, char const*)`).

## Snippet

```javascript
import Java from "frida-java-bridge";

const mod = Process.getModuleByName("libencrypt.so");
const entry = mod.getExportByName(
    "Java_com_newspaperdirect_pressreader_android_core_mylibrary_Encryption_decrypt");

const names = new Map([                         // PLT stub offset -> name, from the table above
    [0xa9750, "strlen"], [0xa9730, "malloc"], [0xa9940, "base64_decode<const char*>"],
    [0xa9740, "DecryptData"], [0xa9900, "GetXmlAtribute"], [0xa9950, "__strlen_chk"],
    [0xa9960, "base64_decode<char*>"], [0xa97a0, "__android_log_print"], [0xa97d0, "free"],
]);

Interceptor.attach(entry, {
    onEnter() {
        this.tid = Process.getCurrentThreadId();
        const seq = this.seq = [];
        Stalker.follow(this.tid, {
            events: { call: true },
            onReceive(ev) {
                for (const [, from, to, depth] of Stalker.parse(ev)) {
                    if (depth !== 1) continue;                       // direct callees only
                    const off = ptr(to).sub(mod.base).toUInt32();
                    seq.push(names.get(off) ?? DebugSymbol.fromAddress(ptr(to)).toString());
                }
            }
        });
    },
    onLeave(retval) {
        Stalker.unfollow(this.tid);
        Stalker.flush();
        setTimeout(() => console.log(`[decrypt] ${retval.isNull() ? "NULL" : "byte[]"} via: ${this.seq.join(" -> ")}`), 100);
    }
});
```

## Reconstructed source

Expected success path, read off the table (the JNIEnv calls are indirect `blr`s, so they appear as `libart.so` addresses):

```text
GetStringUTFChars x2-3 -> strlen -> malloc -> base64_decode<const char*>
  -> DecryptData [-> DecryptData] -> GetXmlAtribute -> __strlen_chk -> base64_decode<char*>
  -> free -> ReleaseStringUTFChars x2-3 -> NewByteArray -> SetByteArrayRegion
```

An attribute-not-found run would instead diverge after `GetXmlAtribute` (`cbz w0, 0x58c24`) into `__android_log_print` → `free` and return `NULL` without ever reaching `NewByteArray`.

## Notes

- **Static list first, trace second.** The table is the hypothesis; the trace checks it. Any callee in the trace that isn't in the table is an indirect call worth investigating; any table entry that never appears is a branch not taken on that input.
- **`depth`** in parsed call events is the call depth relative to where following started — filtering to `1` hides everything `DecryptData` and OpenSSL do internally. Remove the filter to descend into `DecryptData`.
- **Two `DecryptData` call sites** (`0x58ab8`, `0x58ad4`): which one runs is a branch the trace settles instantly, where statically you'd have to evaluate the condition by hand.
- **Why not just hook the callees?** `Interceptor.attach` on `DecryptData` would work too, but each hook answers only "was it called". The Stalker trace preserves *order* and covers everything — including JNIEnv calls and libc helpers — with a single hook.
- **The Java side is simpler for the *data*.** To see the decrypted bytes, hook `Encryption.decrypt` in Java and dump the returned `byte[]`; Stalker is for understanding the *control flow*.

## See also

- [[Stalker-And-Code-Tracing]]
- [[Stalker-Follow-And-Unfollow-Around-A-Call]]
- [[Finding-Function-Boundaries-And-Calls]] in [[ARM64-Android]]
- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
