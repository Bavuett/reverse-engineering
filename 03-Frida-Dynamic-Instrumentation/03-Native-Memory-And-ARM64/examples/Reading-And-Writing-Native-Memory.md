---
tags: [example]
level: 1
aliases: ["Frida Memory read write", "hexdump NativePointer"]
created: 2026-11-12
---

# Example: Reading-And-Writing-Native-Memory

> [!info] Level 1 — basics
> One idea: a `NativePointer` is an address you can do arithmetic on and read or write typed values through — the same operations as C pointer dereferences, done from JavaScript.

## Goal

Find a string inside a loaded library, inspect the bytes around it, and change it in memory. Belongs to [[Native-Memory-And-ARM64]].

## Script

```javascript
const mod = Process.getModuleByName("libencrypt.so");

// 1. Search the module for an ASCII string.
const pattern = "65 6e 63 72 79 70 74 69 6f 6e 4b 65 79";        // "encryptionKey"
const hits = Memory.scanSync(mod.base, mod.size, pattern);
console.log(`[*] ${hits.length} hit(s)`);

const p = hits[0].address;
console.log(`[*] at ${p} = ${mod.name}+0x${p.sub(mod.base).toString(16)}`);

// 2. Typed reads and a hexdump.
console.log(p.readCString());
console.log(hexdump(p.sub(16), { length: 64, ansi: false }));

// 3. Write: string data lives in a read-only segment, so unprotect first.
Memory.protect(p, 16, "rw-");
p.writeUtf8String("xncryptionKey");
console.log(`[*] now: ${p.readCString()}`);
```

## Step by step

1. **`Memory.scanSync(base, size, pattern)`** searches a range for a byte pattern (hex, `??` wildcards allowed). Restricting it to one module keeps it fast.
2. **Pointer arithmetic** uses methods, not operators: `p.add(8)`, `p.sub(mod.base)`. `p.sub(mod.base)` turns a runtime address into a module offset — the number Ghidra or a disassembler shows (minus the image base); see [[From-Ghidra-Offset-To-Interceptor-Address]].
3. **Typed reads/writes**: `readU8/readU32/readU64/readPointer/readCString/readUtf8String/readByteArray` and their `write*` counterparts. Width matters: `readU32` on an 8-byte pointer field silently drops the high half.
4. **`hexdump`** gives the classic offset/hex/ASCII view — the quickest way to see whether you're looking at a string, a pointer table, or code.
5. **Permissions.** Code and constant data are mapped read-only (`r-x`/`r--`). Writing without `Memory.protect` raises an access violation inside the target. For code, prefer `Memory.patchCode` ([[Forcing-A-Conditional-Branch-With-PatchCode]]).
6. **Bad pointers throw** a JS exception (`access violation accessing 0x…`), not a crash — wrap speculative reads in `try`.

## Compared with real code

The string searched here is real: PressReader's `libencrypt.so` contains `encryptionKey` among its `.rodata` strings, the attribute name its JNI `decrypt` looks up in an XML document ([[Encryption-Decrypt-JNI-Entry-In-Libencrypt]]). [[Reading-Datastore-Shared-Counter-Cold]] shows the same library-offset arithmetic done statically.

## See also

- [[Native-Memory-And-ARM64]]
- [[Hooking-An-Exported-Libc-Function]]
- [[NativePointer-And-Memory-API]]
- [[Memory-And-Data-Structures]] in [[ARM64-Android]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
