---
tags: [example]
level: 1
aliases: ["Ghidra image base offset", "static address to runtime address"]
created: 2026-11-12
---

# Example: From-Ghidra-Offset-To-Interceptor-Address

> [!info] Level 1 — basics
> One idea: a disassembler shows addresses relative to *its* chosen image base; the running library sits at a random base. Runtime address = module base + (static address − static image base).

## Goal

Hook an internal, non-exported function found in Ghidra, and convert addresses in both directions. Belongs to [[Static-Dynamic-Integration]].

## The arithmetic

```text
Ghidra shows FUN_0015a2b0, image base 0x00100000
  -> offset in the library = 0x15a2b0 - 0x100000 = 0x5a2b0
At runtime libtarget.so is loaded at 0x7a1c200000
  -> live address = 0x7a1c200000 + 0x5a2b0 = 0x7a1c25a2b0
```

## Script

```javascript
const GHIDRA_BASE = ptr("0x100000");             // Window → Memory Map → image base
const mod = Process.getModuleByName("libtarget.so");

const fromGhidra = a => mod.base.add(ptr(a).sub(GHIDRA_BASE));
const toGhidra = p => ptr(p).sub(mod.base).add(GHIDRA_BASE);

const target = fromGhidra("0x15a2b0");
console.log(`[*] FUN_0015a2b0 is live at ${target}`);
console.log(Instruction.parse(target).toString());     // sanity check: the first instruction

Interceptor.attach(target, {
    onEnter(args) {
        console.log(`[*] called from ${toGhidra(this.returnAddress)} (Ghidra address of the caller)`);
    }
});
```

## Step by step

1. **Find the static image base.** Ghidra loads ARM64 `.so` files at `0x100000` by default; objdump, radare2 and Blutter use 0. Use whatever the tool you read the address in uses.
2. **Subtract it to get the offset**, then add the module's runtime `base`. The offset is the stable number: write it in notes and scripts, not the runtime address, which changes with every launch (ASLR).
3. **Sanity check before hooking.** `Instruction.parse(addr)` disassembles the live bytes; they should match the first instruction Ghidra shows (often `stp x29, x30, …` or `sub sp, sp, …`). A mismatch means a wrong base, a different library version, or a packed library.
4. **Convert back for analysis.** Return addresses, crash PCs and Stalker events are runtime addresses; `toGhidra` turns them into addresses you can jump to in the disassembler (`G` in Ghidra).
5. **Version-specific.** Offsets are valid only for that exact build of the library. Record the APK version, or locate the function by a byte pattern (`Memory.scanSync`) so the script survives updates.

## Compared with real code

- [[Attaching-At-A-Dart-AOT-Entry-Offset]] — a real offset (`libapp.so + 0x7249bc`) from Blutter, which uses base 0, so no subtraction was needed.
- [[Reading-A-Native-Crash-Backtrace-To-Diagnose-An-Agent-Failure]] — the reverse direction: runtime crash PCs mapped back to library offsets.
- [[Encryption-Decrypt-JNI-Entry-In-Libencrypt]] — addresses quoted as base-0 offsets (`0x589d0`) in the vault's own disassembly notes.

## See also

- [[Static-Dynamic-Integration]]
- [[From-Smali-Signature-To-Frida-Overload]]
- [[Module-And-Process-API]]
- [[Finding-Function-Boundaries-And-Calls]] in [[ARM64-Android]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
