---
tags: [reference, reference-entry]
category: "Native API"
created: 2026-11-11
---

# NativePointer-And-Memory-API

## Signature / syntax

```javascript
// Constructing and arithmetic on NativePointer
const p = ptr("0x7b40001000") // or new NativePointer(value), NULL for ptr(0)
p.isNull()
p.add(offset) / p.sub(offset) / p.and(mask) / p.or(bits) / p.xor(bits) / p.shr(n) / p.shl(n)
p.equals(other) / p.compare(other)
p.toInt32() / p.toUInt32() / p.toString([radix]) / p.toMatchPattern()

// Typed reads & writes directly on a NativePointer
p.readPointer()          / p.writePointer(ptrVal)
p.readU8() / p.readS8()  / p.writeU8(v) / p.writeS8(v)
p.readU16() / p.readS16() / p.writeU16(v) / p.writeS16(v)
p.readU32() / p.readS32() / p.writeU32(v) / p.writeS32(v)
p.readU64() / p.readS64() / p.writeU64(v) / p.writeS64(v)
p.readFloat() / p.readDouble() / p.writeFloat(v) / p.writeDouble(v)
p.readCString([size]) / p.readUtf8String([size]) / p.readUtf16String([length])
p.writeUtf8String(str) / p.writeUtf16String(str)
p.readByteArray(length) / p.writeByteArray(bytes)

// Inspection, allocation, protection, scanning, and code patching
hexdump(target, { offset: 0, length: 64, header: true, ansi: false })
Memory.alloc(size)
Memory.allocUtf8String(str)
Memory.protect(address, size, protection) // e.g. "rwx", "r-x", "rw-"
Memory.patchCode(address, size, code => { ... })
Memory.scan(address, size, pattern, { onMatch(address, size) {}, onError(reason) {}, onComplete() {} })
Memory.scanSync(address, size, pattern)
```

## Description

`NativePointer` (created via the `ptr(value)` shorthand or returned by Frida APIs such as `Module.findBaseAddress`, `args[i]`, and `this.context.x0`) represents a 64-bit or 32-bit native virtual address in the target process. Because JavaScript's standard `Number` loses integer precision above $2^{53} - 1$, all address math must use `NativePointer`'s immutable arithmetic methods (`.add`, `.sub`, `.and`, `.or`, `.shr`, `.shl`), each returning a new `NativePointer`. In modern Frida (12.6+), typed memory reads and writes are methods directly on `NativePointer` (`p.readU32()`, `p.readPointer()`, `p.readUtf8String()`, `p.writeByteArray(...)`) rather than the legacy `Memory.read*`/`Memory.write*` namespace functions. The `Memory` object remains responsible for heap allocations (`Memory.alloc`, `Memory.allocUtf8String`), page-permission changes (`Memory.protect`), byte-pattern searches (`Memory.scan` / `Memory.scanSync`), and safe instruction-stream modification (`Memory.patchCode`, which temporarily makes a code page writable, invokes your callback with a writable pointer, flushes the CPU instruction cache, and restores executable permissions).

## Example

```javascript
const base = Process.getModuleByName("libnative-lib.so").base;
const sessionStructPtr = base.add(0x14080).readPointer(); // load global struct Session*

if (!sessionStructPtr.isNull()) {
    // Inspect raw struct bytes before decoding fields
    console.log(hexdump(sessionStructPtr, { length: 0x20, header: true, ansi: false }));

    // Read fields at reconstructed struct offsets (see Reading-Struct-Args-With-A-Reconstructed-Layout)
    const state = sessionStructPtr.add(0x00).readS32();
    const tokenPtr = sessionStructPtr.add(0x08).readPointer();
    const token = tokenPtr.isNull() ? "<null>" : tokenPtr.readUtf8String();
    console.log(`[*] Session state=${state}, token="${token}"`);

    // Patch a 4-byte AArch64 conditional branch at base + 0x3f28 into a NOP
    const branchAddr = base.add(0x3f28);
    Memory.patchCode(branchAddr, 4, code => {
        const writer = new Arm64Writer(code, { pc: branchAddr });
        writer.putNop();
        writer.flush();
    });
}
```

## Notes

- Memory buffers returned by `Memory.alloc(size)` and `Memory.allocUtf8String(str)` are **garbage-collected** as soon as the returned `NativePointer` JavaScript wrapper becomes unreachable; if you pass an allocated pointer to native code that stores it beyond the current callback, pin the `NativePointer` in a global variable or on `this` so it is not freed prematurely.
- `p.readU64()` and `p.readS64()` return Frida `UInt64` / `Int64` wrapper objects (not JS numbers) for the same 53-bit precision reason as `NativePointer`.
- On ARM64 Android 10+ devices, top-byte-ignore (TBI) tagged heap pointers (where bits 56–63 hold a tag byte such as `0xb400...`) are valid when dereferenced by the CPU, and `Memory.scan` patterns on pointers may need `p.toMatchPattern()` or masking depending on whether tags are stored in memory.
- Calling `p.write*` directly on a `.text` or `.rodata` address without first calling `Memory.protect(pageBase, Process.pageSize, "rw-")` (or using `Memory.patchCode` for instructions) raises `SIGSEGV` (`SEGV_ACCERR`).

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Frida-Dynamic-Instrumentation-Glossary|Glossary]]
- [[Native-Memory-And-ARM64]]
- [[Memory-Patching-And-Code-Redirection]]
- [[Static-Dynamic-Integration]]
- [[Reading-Struct-Args-With-A-Reconstructed-Layout]]
- [[Forcing-A-Conditional-Branch-With-PatchCode]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
