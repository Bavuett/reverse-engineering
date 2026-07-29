---
tags: [fundamentals]
aliases: ["Interceptor.replace", "Memory.patchCode", "NativeCallback"]
created: 2026-07-28
---

# Memory-Patching-And-Code-Redirection

## In short

Everything in [[Native-Memory-And-ARM64]] *observes* a running function without changing what it does. This chapter covers actively changing behavior: fully replacing a native function's implementation with `Interceptor.replace`/`NativeCallback`, or patching raw instruction bytes in place with `Memory.patchCode`. Both are heavier tools than a plain `Interceptor.attach` hook and worth reaching for only when observing isn't enough — you specifically need the *rest of the program* to see different behavior, not just your script.

## Explanation

### Fully replacing a function

`Interceptor.replace(address, callback)` swaps a function's entry point for a JavaScript-backed native callback — every caller, including ones you don't control (other native code, not just Java), gets the replacement:

```javascript
const target = Module.findExportByName("libnative-lib.so", "isDeviceRooted");

const original = new NativeFunction(target, "int", []);
Interceptor.replace(target, new NativeCallback(() => {
    console.log("[*] isDeviceRooted() called — forcing return 0");
    return 0; // always report "not rooted", regardless of the original logic
}, "int", []));
```

`NativeCallback(jsFunction, returnType, argTypes)` is what makes this possible — it wraps a JavaScript function as something the native ABI can call as if it were a real compiled function, with the given AAPCS64 signature (see [[Functions-And-Calling-Convention]] for what that signature must match).

`NativeFunction(address, returnType, argTypes)` is the read side of the same mechanism: wrapping an address as something *you* can call from JavaScript — useful for calling a function you found statically without waiting for something else in the app to call it first, or for calling the *original* implementation from inside an `Interceptor.replace` callback (capture it as a `NativeFunction` before replacing).

### `Interceptor.attach` vs. `Interceptor.replace`

| | `Interceptor.attach` | `Interceptor.replace` |
|---|---|---|
| Original code | Still runs | Doesn't run at all unless you call it yourself via a captured `NativeFunction` |
| Use case | Observe, or make small decisions around the original call (skip/force a return in `onLeave`) | The original logic must never execute — e.g. neutralizing a check entirely, or swapping in a different algorithm |
| Multiple hooks on the same address | Allowed (stacks) | Only one active replacement per address |

### Patching raw bytes

`Memory.patchCode(address, size, code => { ... })` gives you a writable buffer over a code region and hands you a `X86Writer`/`Arm64Writer` (Frida's own tiny assembler) to emit replacement instructions directly — the lowest-level tool in Frida's toolbox, useful for surgical changes too small to justify a full `Interceptor.replace` (patching a single conditional branch to always/never taken, NOPing out a call instruction entirely):

```javascript
const branchAddr = Module.findBaseAddress("libnative-lib.so").add(0x2f10);

Memory.patchCode(branchAddr, Process.pageSize, code => {
    const writer = new Arm64Writer(code, { pc: branchAddr });
    writer.putNop(); // overwrite whatever conditional branch was here with a no-op
    writer.flush();
});
```

This requires reading the target instruction's exact size/encoding from a disassembler first (see [[Instructions]] in [[ARM64-Android]]) — patching the wrong number of bytes corrupts whatever instruction follows.

### Memory protection

Code pages are normally read+execute, not writable — `Memory.patchCode` handles the protection flip internally, but direct writes via `Memory.writeByteArray`/`Memory.writePointer` into a code region need an explicit `Memory.protect(address, size, "rwx")` first, or they segfault the target process.

## Worked example

Neutralize a native root-check function so every caller — Java or native — sees "not rooted", using `Interceptor.replace` while still being able to log what the original would have returned, by keeping a `NativeFunction` handle to it:

```javascript
const target = Module.findExportByName("libnative-lib.so", "isDeviceRooted");
const originalFn = new NativeFunction(target, "int", []);

Interceptor.replace(target, new NativeCallback(() => {
    const realResult = originalFn();
    console.log(`[*] isDeviceRooted() real result was ${realResult}, forcing 0`);
    return 0;
}, "int", []));
```

## More examples

- [[Frida-JS-API-Cheatsheet]] in [[Frida-Dynamic-Instrumentation-Cheatsheets|Cheatsheets]].

## See also

- [[Native-Memory-And-ARM64]]
- [[Anti-Detection-And-Gadget-Mode]] — the most common real use of `Interceptor.replace`/code patching: neutralizing root/Frida-detection checks.
- [[Functions-And-Calling-Convention]] in [[ARM64-Android]] — required to get a `NativeFunction`/`NativeCallback` signature right.

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]

## Flashcards
#flashcards

When should you reach for `Interceptor.replace` instead of `Interceptor.attach`?::When the original implementation must never run at all for any caller — not just when you personally want a different return value observed in your own script — e.g. permanently neutralizing a check that other native code also depends on.

What does `NativeCallback` let you do that `NativeFunction` doesn't?::`NativeCallback` wraps a JavaScript function so native code can call it as if it were a compiled function with a given ABI signature (used to build a replacement); `NativeFunction` does the reverse — wrapping an address so your JavaScript can call it as a function.

Why is patching raw instruction bytes with `Memory.patchCode` riskier than `Interceptor.replace`?::It requires knowing the exact size/encoding of the instruction(s) being overwritten from a disassembler first — patching the wrong number of bytes corrupts whatever instruction follows, which `Interceptor.replace` (which swaps an entire function's entry point, not arbitrary mid-function bytes) doesn't risk.
