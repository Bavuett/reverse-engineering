---
tags: [reference, reference-entry]
category: "Native API"
created: 2026-11-11
---

# Interceptor-Attach-And-Replace

## Signature / syntax

```javascript
// Function-boundary hook (entry + return)
const listener = Interceptor.attach(targetAddress, {
    onEnter(args) {
        // args[0..n]: NativePointer array mapped to ABI argument registers/stack
        // this.context: CpuContext (pc, sp, fp, lr, x0..x28 on arm64)
        // this.returnAddress: NativePointer
        // this.threadId: number
        // this.errno / this.lastError: number
    },
    onLeave(retval) {
        // retval: InvocationReturnValue (subclass of NativePointer)
        // retval.replace(ptr(newValue))
    }
});

// Instruction-level probe (mid-function offset)
Interceptor.attach(instructionAddress, function () {
    // this.context holds the live register state right before instructionAddress executes
});

// Full replacement and teardown
Interceptor.replace(targetAddress, replacementCallback)
Interceptor.revert(targetAddress)
Interceptor.detachAll()
Interceptor.flush()
listener.detach()
```

## Description

`Interceptor.attach(target, callbacks)` installs an inline trampoline at `target` (a `NativePointer` pointing to a native function entry or mid-function instruction). When passed an object with `onEnter(args)` and/or `onLeave(retval)`, Frida treats `target` as a function boundary: `onEnter` runs on entry with `args` exposing the integer/pointer parameters according to the platform ABI (on `arm64-v8a`, `args[0]` through `args[7]` correspond to `x0` through `x7`, then stack arguments), and `onLeave` runs just before the function returns to its caller with `retval` holding the `x0` return value, which can be overwritten in place via `retval.replace(val)`. Each invocation gets its own fresh `this` object shared between `onEnter` and `onLeave` for that specific call on that thread, making `this.buf = args[1]` in `onEnter` the thread-safe way to preserve out-parameter pointers until `onLeave` (unlike module-global variables, which race when multiple threads call the hooked function concurrently). When passed a single function `Interceptor.attach(addr, function () { ... })` instead of `{ onEnter, onLeave }`, Frida installs a lightweight instruction-level probe that fires right before the instruction at `addr` executes and exposes `this.context` (`pc`, `sp`, `x0`–`x28`, `lr`, `fp`) without redirecting the return address. `Interceptor.replace(target, nativeCallback)` replaces the function at `target` altogether with a `NativeCallback` (or another native function pointer), and `Interceptor.flush()` commits any pending inline hook writes and instruction-cache flushes immediately rather than waiting for the current JS turn to end.

## Example

```javascript
const libc = Process.getModuleByName("libc.so");
const openPtr = libc.findExportByName("open");

// 1. Function-boundary hook preserving per-call state on `this`
const openHook = Interceptor.attach(openPtr, {
    onEnter(args) {
        this.path = args[0].readUtf8String();
        this.flags = args[1].toInt32();
    },
    onLeave(retval) {
        const fd = retval.toInt32();
        if (this.path && this.path.includes("/proc/self/maps")) {
            console.log(`[tid=${this.threadId}] open("${this.path}", 0x${this.flags.toString(16)}) -> fd=${fd}`);
            // Force a failed open (-1 / EACCES) if desired:
            // retval.replace(ptr(-1));
        }
    }
});

// 2. Instruction-level probe at a mid-function offset in libapp.so
const libapp = Process.findModuleByName("libapp.so");
if (libapp !== null) {
    Interceptor.attach(libapp.base.add(0x7249bc), function () {
        console.log(`[*] Reached 0x7249bc with x1=${this.context.x1}, x2=${this.context.x2}`);
    });
}
```

## Notes

- On ARM64, inline trampolines overwrite the first 16 bytes (4 instructions) at `target` and relocate the displaced instructions into a trampoline island; hooking a tiny function shorter than 16 bytes or jumping into the middle of a multi-instruction PC-relative sequence can fail if adjacent code branches into the displaced bytes.
- `args[i]` in `onEnter` can also be **assigned** (`args[0] = Memory.allocUtf8String("/dev/null")`) to redirect an input argument before the real function executes; keep the allocated buffer referenced on `this` (e.g. `this.fakePath = ...`) so GumJS's garbage collector does not free it before the native function finishes reading it.
- Floating-point and SIMD arguments (`d0`–`d7` / `v0`–`v7` under [[Functions-And-Calling-Convention|AAPCS64]]) are not indexed by `args[i]`; read or modify them via `this.context.d0`–`this.context.d7` (or `this.context.q0`–`this.context.q31`).
- Non-AAPCS64 runtimes such as Dart AOT pass arguments in custom registers (`x1`, `x2`, ... with compressed heap pointers anchored to `x28`) and keep their own stack pointer in `x15`; use an instruction-level probe or `this.context` directly instead of `args[i]` (see [[Attaching-At-A-Dart-AOT-Entry-Offset]]).

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Frida-Dynamic-Instrumentation-Glossary|Glossary]]
- [[Native-Memory-And-ARM64]]
- [[Memory-Patching-And-Code-Redirection]]
- [[NativePointer-And-Memory-API]]
- [[NativeFunction-And-NativeCallback]]
- [[Filtering-Proc-Self-Maps-Through-A-Libc-Fgets-Hook]]
- [[Attaching-At-A-Dart-AOT-Entry-Offset]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
