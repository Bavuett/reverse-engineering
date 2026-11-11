---
tags: [reference, reference-entry]
category: "Native API"
created: 2026-11-11
---

# Module-And-Process-API

## Signature / syntax

```javascript
// Process-level queries
Process.id / Process.arch / Process.platform / Process.pageSize / Process.pointerSize
Process.getCurrentThreadId()
Process.enumerateThreads()
Process.enumerateModules()
Process.getModuleByName(name)    // throws if not loaded
Process.findModuleByName(name)   // returns Module or null
Process.findModuleByAddress(address)
Process.enumerateRanges(protectionOrSpec) // e.g. "r-x" or { protection: "rw-", coalesce: true }
Process.findRangeByAddress(address)

// Module instance properties and methods (preferred in Frida 16+/17+)
mod.name / mod.base / mod.size / mod.path
mod.findExportByName(exportName) / mod.getExportByName(exportName)
mod.enumerateExports()   // [{ type: "function"|"variable", name, address }, ...]
mod.enumerateImports()   // [{ type, name, module, address, slot }, ...]
mod.enumerateSymbols()   // [{ isGlobal, type, section, name, address, size }, ...]
mod.enumerateRanges(protection)

// Native stack unwinding and symbolication
Thread.backtrace([this.context, Backtracer.ACCURATE | Backtracer.FUZZY])
DebugSymbol.fromAddress(address) / DebugSymbol.fromName(name)
```

## Description

The `Process` and `Module` APIs inspect the target process's virtual address space, loaded shared libraries (`.so` ELF modules on Android), threads, and symbol tables, while `Thread.backtrace` and `DebugSymbol` turn raw code addresses back into human-readable call stacks and `module!offset` labels. `Process.findModuleByName(name)` returns a `Module` object (or `null` if the library has not been loaded via `dlopen`/`System.loadLibrary` yet; `Process.getModuleByName(name)` throws instead), exposing `mod.base` (a `NativePointer` to the runtime load bias, which you add to static file offsets from Ghidra/objdump), `mod.size`, `mod.path`, and per-module symbol lookup methods (`mod.findExportByName`, `mod.enumerateExports`, `mod.enumerateImports`, `mod.enumerateSymbols`). Inside any `Interceptor.attach` callback, `Thread.backtrace(this.context, Backtracer.ACCURATE)` unwinds the native call stack and returns an array of `NativePointer` return addresses that `.map(DebugSymbol.fromAddress)` formats as `libfoo.so!symbol+0xoffset` (or `libfoo.so!0xoffset` for stripped binaries).

## Example

```javascript
const mod = Process.findModuleByName("libflutter.so");
if (mod === null) {
    console.log("[!] libflutter.so not loaded yet");
} else {
    console.log(`[*] ${mod.name} @ ${mod.base} (${mod.size} bytes, arch=${Process.arch})`);

    const sslWrite = mod.findExportByName("SSL_write");
    if (sslWrite !== null) {
        Interceptor.attach(sslWrite, {
            onEnter(args) {
                const trace = Thread.backtrace(this.context, Backtracer.ACCURATE)
                    .map(addr => {
                        const sym = DebugSymbol.fromAddress(addr);
                        const m = Process.findModuleByAddress(addr);
                        const rel = m ? `${m.name}+0x${addr.sub(m.base).toString(16)}` : addr.toString();
                        return `${rel} (${sym.name || "stripped"})`;
                    })
                    .join("\n    ");
                console.log(`[*] SSL_write (${args[2].toInt32()} bytes) native backtrace:\n    ${trace}`);
            }
        });
    }
}
```

## Notes

- **Modern Frida API change**: prefer calling `mod.findExportByName("fgets")` on a `Module` instance obtained from `Process.getModuleByName("libc.so")` or `Process.findModuleByName("libc.so")` rather than the legacy static `Module.findExportByName("libc.so", "fgets")` — on newer Frida versions, static methods on the `Module` constructor (`Module.findExportByName`, `Module.findBaseAddress`) have been deprecated/removed in favor of `Process.findModuleByName(name).findExportByName(...)` and `Process.findModuleByName(name).base` (see [[Filtering-Proc-Self-Maps-Through-A-Libc-Fgets-Hook]]).
- `mod.enumerateExports()` reads the dynamic symbol table (`.dynsym`), which is always present in a shared library so the dynamic linker can resolve exports, whereas `mod.enumerateSymbols()` reads the regular symbol table (`.symtab`), which is usually stripped in release Android `.so` binaries.
- `Backtracer.ACCURATE` relies on DWARF unwind tables (`.eh_frame`) or frame pointers (`x29`/`fp`), which can stop after a single frame inside stripped code or non-standard runtimes like Dart AOT; fall back to `Backtracer.FUZZY` (which scans the stack for code-segment pointers) when `ACCURATE` truncates the trace.
- To hook a native library that is loaded lazily at runtime rather than at startup, hook `android_dlopen_ext` (or `dlopen`) in `libdl.so`, check the library path in `onEnter`, and install your `mod.base.add(offset)` hooks in `onLeave` once the library is mapped into memory.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Frida-Dynamic-Instrumentation-Glossary|Glossary]]
- [[Native-Memory-And-ARM64]]
- [[Static-Dynamic-Integration]]
- [[Android-ABIs-And-Emulation]]
- [[Filtering-Proc-Self-Maps-Through-A-Libc-Fgets-Hook]]
- [[Matching-Frida-Server-To-The-Target-ABI]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
