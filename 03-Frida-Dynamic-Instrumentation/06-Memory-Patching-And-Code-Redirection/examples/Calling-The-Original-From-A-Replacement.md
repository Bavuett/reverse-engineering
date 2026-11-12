---
tags: [example]
level: 2
aliases: ["Interceptor.replace call original", "wrap native function"]
created: 2026-11-12
---

# Example: Calling-The-Original-From-A-Replacement

> [!info] Level 2 — intermediate
> Combines replacement with the original: inside an `Interceptor.replace` callback, call the original through a `NativeFunction` on the same address — Frida routes it past your replacement — so you can change arguments *before* and results *after*.

## Goal

Wrap libc's `read` so that bytes read from one specific file descriptor are rewritten, while every other call behaves normally. Belongs to [[Memory-Patching-And-Code-Redirection]].

## Script

```javascript
const readPtr = Process.getModuleByName("libc.so").getExportByName("read");
const readOrig = new NativeFunction(readPtr, "long", ["int", "pointer", "ulong"]);

const watched = new Set();          // fds we care about (filled by an open() hook, not shown)

Interceptor.replace(readPtr, new NativeCallback(function (fd, buf, count) {
    const n = readOrig(fd, buf, count);                   // the real read(), not recursion
    if (n > 0 && watched.has(fd)) {
        const text = buf.readUtf8String(Number(n));
        const patched = text.replace(/TracerPid:\s*\d+/, "TracerPid:\t0");
        if (patched !== text) {
            buf.writeUtf8String(patched);
            return patched.length;                        // same or shorter: fits in buf
        }
    }
    return n;
}, "long", ["int", "pointer", "ulong"]));
```

## Step by step

1. **Calling `readPtr` from inside its own replacement doesn't recurse.** Frida keeps a relocated copy of the original prologue; a `NativeFunction` on the replaced address invoked from within the replacement on the same thread goes to that copy. (Calling it from *another* thread would hit the replacement.)
2. **Wrap, don't reimplement.** The real `read` does the work; you only post-process. This is the safe default — reimplementing a libc function correctly is much harder than editing its output.
3. **Keep the contract.** `read` returns a byte count; the buffer holds at most `count` bytes. A rewrite must not grow past `count`, and the returned length must match what's in the buffer.
4. **Filter cheaply.** `read` is one of the hottest functions in any process. A `Set` lookup before touching memory keeps the overhead small; decode strings only for watched descriptors.
5. **`Interceptor.attach` could do this too** (`onLeave` with `this.buf` saved in `onEnter`). `replace` is preferable when you may need to *skip* the original for some calls, or change arguments before it runs.
6. **The example's target is real-world**: `TracerPid` in `/proc/self/status` is a classic debugger/instrumentation check ([[Faking-Proc-Reads-For-Frida-Detection]]).

## Compared with real code

- [[Filtering-Proc-Self-Maps-Through-A-Libc-Fgets-Hook]] — the Poste Italiane investigation did exactly this kind of output rewriting on `fgets` to hide Frida's mappings from `/proc/self/maps`.
- [[Reimplementing-Trapped-Methods-In-JavaScript]] — the Java-layer version of "call the real code, skip the trap", in the TUA app.

## See also

- [[Memory-Patching-And-Code-Redirection]]
- [[Replacing-A-Native-Function-With-Interceptor-Replace]]
- [[Interceptor-Attach-And-Replace]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
