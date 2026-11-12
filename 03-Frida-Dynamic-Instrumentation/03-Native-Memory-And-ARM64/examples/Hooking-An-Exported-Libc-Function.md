---
tags: [example]
level: 1
aliases: ["Interceptor.attach open", "hook libc open"]
created: 2026-11-12
---

# Example: Hooking-An-Exported-Libc-Function

> [!info] Level 1 — basics
> One idea: `Interceptor.attach` runs your code at a native function's entry and exit, with the arguments as raw ARM64 registers (`args[0]` = `x0`, …) and the return value as `x0`.

## Goal

Log every file the app opens, by hooking libc's `open`. Belongs to [[Native-Memory-And-ARM64]].

## Script

```javascript
const openPtr = Process.getModuleByName("libc.so").getExportByName("open");

Interceptor.attach(openPtr, {
    onEnter(args) {
        this.path = args[0].readUtf8String();       // const char *pathname  (x0)
        this.flags = args[1].toInt32();             // int flags             (w1)
    },
    onLeave(retval) {
        const fd = retval.toInt32();                // int return            (w0)
        if (this.path.startsWith("/data/") || fd < 0)
            console.log(`open("${this.path}", 0x${this.flags.toString(16)}) = ${fd}`);
    }
});
```

## Step by step

1. **Resolve the address.** Exports are found by name in their module; the result is a `NativePointer` to the first instruction of `open`. Libraries loaded later need resolving *after* they load ([[Spawn-Vs-Attach-Timing]]).
2. **`args[i]` are `NativePointer`s holding the raw register values** `x0`–`x7` under AAPCS64 ([[Functions-And-Calling-Convention]]). Frida doesn't know the C prototype; you interpret them: `readUtf8String()` dereferences a `char*`, `toInt32()` takes the low 32 bits for an `int`.
3. **`this` is per-call storage.** Values saved in `onEnter` (`this.path`) are available in `onLeave` for the *same* invocation, even with many threads calling `open` at once.
4. **`retval`** is `x0` at return. You can replace it with `retval.replace(ptr(-1))` — e.g. to make a file appear missing.
5. **Filter in the hook**, not afterwards: `open` is called thousands of times; logging all of them floods the channel and slows the app.
6. **Wrappers matter.** Bionic routes some calls through `__open_2` (fortified builds) or `openat`; if a known access doesn't show up, hook those too. See [[Interceptor-Attach-And-Replace]].

## Compared with real code

- [[Filtering-Proc-Self-Maps-Through-A-Libc-Fgets-Hook]] — a real libc hook (`fgets`) in the Poste Italiane investigation, which *rewrites* the data instead of only logging it.
- [[Reading-Struct-Args-With-A-Reconstructed-Layout]] — the next step: arguments that are pointers to structs.

## See also

- [[Native-Memory-And-ARM64]]
- [[Reading-And-Writing-Native-Memory]]
- [[Interceptor-Attach-And-Replace]]
- [[Passing-Arguments-And-Return-Values]] in [[ARM64-Android]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
