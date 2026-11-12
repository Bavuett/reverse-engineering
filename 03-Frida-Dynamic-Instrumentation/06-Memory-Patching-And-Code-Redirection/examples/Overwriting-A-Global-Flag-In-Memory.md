---
tags: [example]
level: 1
aliases: ["patch global variable", "flip debug flag Frida"]
created: 2026-11-12
---

# Example: Overwriting-A-Global-Flag-In-Memory

> [!info] Level 1 — basics
> One idea: many behaviors hinge on one global variable in a library's `.data`/`.bss`; find its address once and write a new value — no code is changed at all.

## Goal

Turn on a native library's hidden debug logging by setting its global `g_debug` flag. Belongs to [[Memory-Patching-And-Code-Redirection]].

## Disassembly (the code that reads the flag)

```asm
log_event:
    adrp    x8, 0x41000
    ldr     w8, [x8, #0x7a0]        ; w8 = g_debug   (address 0x417a0 in the file)
    cbz     w8, .Lskip              ; if (!g_debug) return
    ...                             ; __android_log_print(...)
.Lskip:
    ret
```

## Script

```javascript
const mod = Process.getModuleByName("libtarget.so");
const gDebug = mod.base.add(0x417a0);            // ADRP page + LDR offset, from the listing

console.log(`[*] g_debug before: ${gDebug.readU32()}`);
gDebug.writeU32(1);                              // .data/.bss is already writable: no protect needed
console.log(`[*] g_debug after:  ${gDebug.readU32()}`);
```

## Step by step

1. **Find the address statically.** An `adrp` + `ldr [x8, #off]` pair loads a global: page + offset = its address relative to the module base ([[Loading-Addresses-With-ADRP-And-ADD]]). Exported globals can also be found by name with `getExportByName`.
2. **Match the width.** `ldr w8` reads 32 bits → `readU32`/`writeU32`. `ldrb` would mean a byte (`writeU8`), `ldr x8` a pointer or 64-bit value.
3. **Writable already.** Globals live in `.data` or `.bss`, mapped `rw-`, so — unlike patching code or `.rodata` — no `Memory.protect` is needed.
4. **Timing.** The write must happen after the library is loaded and after any initializer that sets the flag; if the library resets it in its constructor, write after that runs (hook the library load, or the first function that uses the flag).
5. **`const` globals are different.** A value declared `const` may be folded into the code as an immediate (`mov w8, #0`) — there's no variable to write, and you're back to patching instructions.
6. **This is the least invasive patch.** No code is modified, so code-integrity checks (hashing `.text`) won't notice it.

## Compared with real code

- [[Reading-Datastore-Shared-Counter-Cold]] in [[ARM64-Android]] — a real library whose state lives in memory shared through `mmap` rather than in a global, read statically.
- [[Mmap-Call-Arguments-In-Datastore]] — reading real `adrp`/`ldr` address arithmetic and call arguments.

## See also

- [[Memory-Patching-And-Code-Redirection]]
- [[Reading-And-Writing-Native-Memory]]
- [[NativePointer-And-Memory-API]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
