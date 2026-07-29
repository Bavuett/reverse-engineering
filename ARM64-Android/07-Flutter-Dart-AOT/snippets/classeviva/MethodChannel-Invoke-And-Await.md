---
tags: [snippet]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "com.spaggiari.classeviva.students, Flutter/Dart release build"
version: "unknown (APK not versioned in the imported excerpt)"
source_path: "ui/pages/account_pages/sign_in_pages/login_spid_page.dart — blutter-annotated ARM64 disassembly of the AOT-compiled Dart code, not real Dart source"
date_added: 2026-07-28
license_note: "Personal study/research purposes only. This is a tiny excerpt of a disassembly dump kept for illustrating one instruction pattern — see the full imported files under this topic's Classeviva case study for the broader investigation. Check the app's ToS before any further redistribution."
---

# MethodChannel-Invoke-And-Await

## Context

The SPID (Italian public digital-identity SSO) login page needs the surrounding Android app to open a URL in an external intent — something Dart code can't do on its own. It builds an argument map, calls into Flutter's `MethodChannel` (which crosses over into genuinely JNI/native engine code, see [[Android-Native-Internals]]), and `await`s the result. A textbook real instance of [[Flutter-Dart-AOT#Explanation|`async`/`await` and platform channels]].

## Original path

`ui/pages/account_pages/sign_in_pages/login_spid_page.dart` (blutter output mirroring `package:classeviva/ui/pages/account_pages/sign_in_pages/login_spid_page.dart`)

## Snippet

```
// 0xc10f94: r16 = Instance_MethodChannel
//     0xc10f94: add             x16, PP, #0x27, lsl #12  ; [pp+0x27c68] Obj!MethodChannel@1174d71
//     0xc10f98: ldr             x16, [x16, #0xc68]
// 0xc10f9c: stp             x16, NULL, [SP, #0x10]
// 0xc10fa0: r16 = "openUrlIntent"
//     0xc10fa0: add             x16, PP, #0x36, lsl #12  ; [pp+0x36630] "openUrlIntent"
//     0xc10fa4: ldr             x16, [x16, #0x630]
// 0xc10fa8: stp             x0, x16, [SP]
// 0xc10fac: r4 = const [0x1, 0x3, 0x3, 0x3, null]
//     0xc10fac: ldr             x4, [PP, #0x758]  ; [pp+0x758] List(5) [0x1, 0x3, 0x3, 0x3, Null]
// 0xc10fb0: r0 = invokeMethod()
//     0xc10fb0: bl              #0x1056578  ; [package:flutter/src/services/platform_channel.dart] MethodChannel::invokeMethod
// 0xc10fb4: mov             x1, x0
// 0xc10fb8: stur            x1, [fp, #-0xb0]
// 0xc10fbc: r0 = Await()
//     0xc10fbc: bl              #0x7e84ac  ; AwaitStub
// 0xc10fc0: b               #0xc11038
// 0xc10fc4: sub             SP, fp, #0xd0
// 0xc10fc8: r2 = 60
//     0xc10fc8: movz            x2, #0x3c
// 0xc10fcc: branchIfSmi(r0, 0xc10fd8)
//     0xc10fcc: tbz             w0, #0, #0xc10fd8
// 0xc10fd0: r2 = LoadClassIdInstr(r0)
//     0xc10fd0: ldur            x2, [x0, #-1]
//     0xc10fd4: ubfx            x2, x2, #0xc, #0x14
// 0xc10fd8: cmp             x2, #0xa52
// 0xc10fdc: b.ne            #0xc11050
```

## Notes

- The `MethodChannel` instance itself (`Obj!MethodChannel@1174d71`) is a **pool constant** — created once, reused for every call on this channel — see [[Object-Pool-Constant-Loads]] for the same PP-relative loading idiom in a simpler function.
- The literal `"openUrlIntent"` is the channel _method name_: on the Android side, whatever `MethodCallHandler` is registered for this channel switches on exactly this string to decide what native/platform action to run. This is a genuinely useful reversing shortcut — **grepping a Flutter binary's recovered string table for method-channel-name-looking strings is a fast way to enumerate every native capability the Dart side can invoke**, without having to first find and read every `invokeMethod` call site.
- `r0 = Await()` / `bl AwaitStub` is the suspension point — note that the very next instruction, `b #0xc11038`, is **not** where execution actually resumes after suspending. It's the resumption target for one particular path; the real control-flow graph around an `await` is reconstructed by the surrounding suspend-state machinery, not by naive linear disassembly. Treat code immediately after an `AwaitStub` call as "one possible continuation," not "the next line."
- After resuming (at `0xc10fc4`, a different label reached via the suspended-state machinery, not fallthrough), the result is checked with `branchIfSmi` + `LoadClassIdInstr` + `cmp` against a specific class id (`0xa52`) — this is the generated code checking **which concrete type** `invokeMethod`'s `dynamic` result turned out to be at runtime, since platform channels are untyped at the Dart/native boundary.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Flutter-Dart-AOT]]
- [[Android-Native-Internals]]
- [[Classeviva-Flutter-Case-Study]]
