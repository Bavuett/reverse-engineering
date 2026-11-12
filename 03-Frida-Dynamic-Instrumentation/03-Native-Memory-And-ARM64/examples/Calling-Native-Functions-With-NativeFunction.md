---
tags: [example]
level: 2
aliases: ["NativeFunction", "call native from Frida"]
created: 2026-11-12
---

# Example: Calling-Native-Functions-With-NativeFunction

> [!info] Level 2 — intermediate
> Combines a prototype, memory allocation, and lifetime: to *call* a native function you must declare its C signature, build its arguments in target memory, and keep those buffers alive while the call runs.

## Goal

Call native code on demand — a libc function, then an internal (non-exported) function at a known offset — and decode the result. Belongs to [[Native-Memory-And-ARM64]].

## Script

```javascript
// 1. An exported function: size_t strlen(const char *s)
const strlen = new NativeFunction(
    Process.getModuleByName("libc.so").getExportByName("strlen"),
    "size_t", ["pointer"]);

const s = Memory.allocUtf8String("hello, frida");
console.log(`strlen = ${strlen(s)}`);                       // UInt64: 12

// 2. An internal function found in a disassembler:
//    int decode(const uint8_t *in, int len, uint8_t *out)   at module offset 0x1a2b0
const mod = Process.getModuleByName("libtarget.so");
const decode = new NativeFunction(mod.base.add(0x1a2b0), "int", ["pointer", "int", "pointer"]);

const input = Memory.alloc(32);
input.writeByteArray([0x13, 0x37, 0x42, 0x00]);
const out = Memory.alloc(256);                              // keep a JS reference!

const n = decode(input, 4, out);
console.log(`decode -> ${n}`);
console.log(hexdump(out, { length: Math.max(n, 16), ansi: false }));
```

## Step by step

1. **The prototype is your claim, not checked.** `new NativeFunction(addr, ret, [args])` uses the types to place arguments in `x0`–`x7` and read `x0` back. A wrong prototype doesn't error — the callee simply reads garbage. Derive it from the disassembly ([[Naming-Arguments-From-Their-Uses]]).
2. **Type names**: `"pointer"`, `"int"`, `"uint"`, `"int64"`, `"size_t"`, `"double"`, `"void"`, … 64-bit returns come back as `Int64`/`UInt64` objects.
3. **`Memory.alloc` returns memory owned by a JS object.** When the JS value is garbage-collected, the memory is freed. Keep a variable referencing every buffer the callee will use — passing `Memory.alloc(256)` inline and storing nothing is a use-after-free waiting to happen.
4. **Internal functions** are addressed as `module.base + offset`. Offsets come from the disassembler minus its image base (for PIE `.so` files usually 0, Ghidra often shows `0x100000`) — see [[From-Ghidra-Offset-To-Interceptor-Address]].
5. **Thread and state.** The call runs on the JS thread, not an app thread. Functions that need a `JNIEnv*`, thread-local state, or locks the app holds may misbehave; call them from inside a hook on the right thread if so.
6. **`NativeCallback`** is the reverse: a JS function exposed as a C function pointer, used for callbacks and with `Interceptor.replace` ([[Replacing-A-Native-Function-With-Interceptor-Replace]]).

## Compared with real code

PressReader's `libencrypt.so` exports `DecryptData` and `base64_decode`, which its JNI `decrypt` calls in sequence ([[Encryption-Decrypt-JNI-Entry-In-Libencrypt]]). Recovering their prototypes from the call sites (which registers are set up before each `bl`) is exactly the information a `NativeFunction` declaration needs. Related real material: [[Attaching-At-A-Dart-AOT-Entry-Offset]] uses the same `base.add(offset)` addressing.

## See also

- [[Native-Memory-And-ARM64]]
- [[Reading-Struct-Args-With-A-Reconstructed-Layout]]
- [[NativeFunction-And-NativeCallback]]
- [[Functions-And-Calling-Convention]] in [[ARM64-Android]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
