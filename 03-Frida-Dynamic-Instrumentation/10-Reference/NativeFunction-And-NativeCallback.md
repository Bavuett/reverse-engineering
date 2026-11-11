---
tags: [reference, reference-entry]
category: "Native API"
created: 2026-11-11
---

# NativeFunction-And-NativeCallback

## Signature / syntax

```javascript
// Wrap a native code address so JavaScript can call it directly
const fn = new NativeFunction(address, returnType, argTypes[, abiOrOptions])

// Expose a JavaScript function as a native C function pointer (NativePointer)
const cb = new NativeCallback(function (...args) {
    return result;
}, returnType, argTypes[, abi])

// Supported type strings for returnType and argTypes:
// "void", "pointer", "int", "uint", "long", "ulong", "char", "uchar",
// "size_t", "ssize_t", "float", "double",
// "int8", "uint8", "int16", "uint16", "int32", "uint32", "int64", "uint64", "bool"
// Variadic functions place "..." in argTypes between fixed and variable arguments:
// new NativeFunction(snprintfPtr, "int", ["pointer", "size_t", "pointer", "...", "int"])
```

## Description

`NativeFunction` and `NativeCallback` bridge calls across the JavaScript/native ABI boundary in opposite directions. `new NativeFunction(address, returnType, argTypes[, options])` wraps a `NativePointer` (such as an export from `module.findExportByName` or an internal function offset from Ghidra) into a callable JavaScript function that marshals JS arguments into native registers/stack slots according to [[Functions-And-Calling-Convention|AAPCS64]] (or the active `Process.arch` ABI), invokes `address`, and unmarshals the return value back to JS. Conversely, `new NativeCallback(func, returnType, argTypes)` allocates an executable native entry point whose address is itself a `NativePointer`: whenever native code jumps to or calls that pointer — most commonly when passed to `Interceptor.replace(target, cb)` or registered into a C struct/vtable — Frida marshals the incoming native registers into JS values, runs `func`, and places `func`'s return value into the ABI return register (`x0`/`w0` or `d0`).

## Example

```javascript
const lib = Process.getModuleByName("libnative-lib.so");

// 1. Call an internal native helper (char* hmac_sha256(const uint8_t* data, size_t len)) on demand
const hmacFn = new NativeFunction(lib.base.add(0x9420), "pointer", ["pointer", "size_t"]);
const payload = Memory.allocUtf8String("challenge-nonce-12345");
const digestPtr = hmacFn(payload, 21);
console.log("[*] On-demand HMAC:", digestPtr.readCString());

// 2. Replace a native integrity check while keeping a NativeFunction handle to the original
const checkAddr = lib.findExportByName("verifySignature");
const origCheck = new NativeFunction(checkAddr, "int", ["pointer", "int"]);

// Pin the NativeCallback at module scope so GC never collects it while replaced
const replacementCheck = new NativeCallback((ctxPtr, flags) => {
    const realVerdict = origCheck(ctxPtr, flags);
    console.log(`[*] verifySignature(${ctxPtr}, ${flags}) real=${realVerdict} -> forcing 1`);
    return 1;
}, "int", ["pointer", "int"]);

Interceptor.replace(checkAddr, replacementCheck);
```

## Notes

- **Garbage-collection lifetime pitfall**: a `NativeCallback` is a JavaScript-owned object whose underlying native trampoline is freed when the JS variable is garbage-collected. While `Interceptor.replace` retains the callback internally, if you pass a `NativeCallback` pointer to a native C API or write it into a function-pointer table/struct yourself, you **must** store the `NativeCallback` in a global variable (or module-level array) so V8/QuickJS never collects it while native code can still call that address.
- Calling a `NativeFunction` created at `target` from inside an `Interceptor.replace(target, ...)` callback is safe and calls the **original** unreplaced function: Frida detects that the caller is the replacement callback for `target` and routes the call through the relocated original prologue instead of recursing into the replacement.
- Pass `{ exceptions: "propagate" }` or `{ traps: "all" }` as the fourth argument to `new NativeFunction(...)` when you want Stalker/Interceptor traps inside the called function to trigger even when invoked directly from your script.
- Passing the wrong `argTypes` count or width (e.g. `"int"` instead of `"pointer"` on 64-bit ARM, or omitting the hidden `JNIEnv*` and `jobject`/`jclass` parameters on a JNI function) corrupts register mapping or crashes the target thread.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Frida-Dynamic-Instrumentation-Glossary|Glossary]]
- [[Memory-Patching-And-Code-Redirection]]
- [[Native-Memory-And-ARM64]]
- [[Interceptor-Attach-And-Replace]]
- [[Functions-And-Calling-Convention]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
