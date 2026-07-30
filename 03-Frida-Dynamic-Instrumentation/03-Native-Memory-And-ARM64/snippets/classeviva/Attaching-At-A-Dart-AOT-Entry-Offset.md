---
tags: [snippet]
project: "ClasseViva (eu.spaggiari.classevivastudente)"
source: "eu.spaggiari.classevivastudente — Flutter (Dart AOT) Android app, libapp.so disassembled with Blutter"
version: "unknown (not recorded alongside the imported files)"
source_path: "Frida hook targeting libapp.so + 0x7249bc (_AuthenticationService.login), derived from Blutter disassembly"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. Small fragment kept to illustrate one hooking pattern. Check the app's ToS before any redistribution."
---

# Attaching-At-A-Dart-AOT-Entry-Offset

## Context

A Dart-AOT function in ClasseViva's `libapp.so` has **no exported symbol** to hand `Module.findExportByName` — only a bare numeric offset from Blutter. This snippet is the reusable core of that attach: resolve the runtime address from the static offset, and read arguments out of the *raw context registers* rather than `args[i]`, because Dart AOT doesn't follow AAPCS64's `x0..x7` argument convention. It's the minimal, single-call-site version of the full write-up in [[Hooking-Dart-AOT-Login-With-Frida]], illustrating the [[Native-Memory-And-ARM64]] "static offset → live hook" and "registers are the ground truth" ideas.

## Original path

`` core/auth/authentication_service.dart — Blutter-annotated ARM64 for _AuthenticationService.login(), libapp.so + 0x7249bc ``

## Snippet

```javascript
// Dart AOT: no export, so resolve base + static offset (see Native-Memory-And-ARM64).
const base = Module.findBaseAddress("libapp.so");
const login = base.add(0x7249bc);            // _AuthenticationService.login entry (EnterFrame)

// Build-specific heap-base register, taken from Blutter's generated blutter_frida.js for THIS binary.
const HEAP_REG = "x28";

function decompress(ctx, reg) {
    // A Dart compressed pointer: heapBase(upper 32) | field(lower 32). Idempotent for full pointers.
    const heapBase = ctx[HEAP_REG].shr(32).shl(32);
    return heapBase.add(ctx[reg].toInt32() >>> 0);
}

Interceptor.attach(login, {
    onEnter() {
        // At the literal entry, EnterFrame hasn't run yet, so x1/x2 still hold the caller's args:
        //   x1 = this (_AuthenticationService), x2 = the _LoginRequestJTO argument.
        const arg = decompress(this.context, "x2");
        // _LoginRequestJTO fields (from its own toJson/toString): 0x8 uid, 0xc pass, 0x10 ident, 0x14 otp
        console.log("[*] login() uid   = " + readDartString(decompress2(arg, 0x8)));
        console.log("[*] login() pass  = " + readDartString(decompress2(arg, 0xc)));
    }
});
```

## Notes

- The two Dart-AOT specifics that make this *not* a normal native hook: (1) attaching at the **exact entry offset** so `x1`/`x2` still hold the caller's `this`/argument (confirmed because `EnterFrame` touches neither), and (2) **pointer decompression** — a Dart heap pointer stores only the low 32 bits inline, reconstructed against the heap base kept in `x28` for this build. Both are explained at length in [[Hooking-Dart-AOT-Login-With-Frida]].
- `this.context.x2` (not `args[2]`) is the key departure from the JNI case in [[Native-Memory-And-ARM64]]: there's no C calling convention here, so you read the raw register the Dart register-allocator chose, which you learn from the function's own `SetupParameters` disassembly comment — never assume "x1 is always this".
- The `HEAP_REG = "x28"` constant is **build-specific**; on a different Dart SDK it may be another register. Re-derive it from a fresh Blutter `blutter_frida.js` rather than hardcoding it across app updates — the same caveat [[Dart-AOT-Stub-Cheatsheet]] flags for reserved registers.
- `readDartString`/`decompress2` are the small helpers from `hook_login.js` (Dart `String`: length as a Smi at `+0x8`, UTF-8 data at `+0x10`); elided here to keep the snippet focused on the attach + decompress core.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Native-Memory-And-ARM64]]
- [[Flutter-Dart-AOT]] in [[ARM64-Android]]
- [[ClasseViva-Case-Study]] and [[Hooking-Dart-AOT-Login-With-Frida]] in [[Case-Studies]]
