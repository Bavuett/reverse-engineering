---
tags: [snippet]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "eu.spaggiari.classevivastudente — libapp.so, Dart AOT, disassembled with Blutter"
version: "unknown (APK not versioned in the imported excerpt)"
source_path: "libapp.so — blutter-annotated ARM64 for a small Dart instance getter (illustrative of the standard Dart AOT getter shape)"
date_added: 2026-07-30
license_note: "Personal study/research purposes only. Small excerpt kept to illustrate one disassembly-reading pattern. Check the app's ToS before any redistribution."
---

# Reading-A-Dart-AOT-Getter-Cold

## Context

Reading raw ARM64 in a Dart AOT `libapp.so` is [[Reading-Raw-Disassembly]] with three extra conventions layered on top that will trip you up if you read it as plain AAPCS64: reserved registers (`x28`=HEAP, `x27`=PP object-pool, `x26`=THR), **compressed pointers** (a `LoadField` reads a 32-bit half-pointer, then a `DecompressPointer` reconstructs the full 64-bit address), and a `CheckStackOverflow` prologue instead of a normal frame guard. This is the same binary and register model the [[Attaching-At-A-Dart-AOT-Entry-Offset]] Frida hook targets — reading it cold here is what tells that hook which offsets to read.

## Original path

`` libapp.so — a `MasterGrade` instance getter, blutter disassembly ``

## Snippet

```
[get] MasterGrade.subjectId {
    // 0x2b41c0: EnterFrame
    //     0x2b41c0: stp   fp, lr, [SP, #-0x10]!
    //     0x2b41c4: mov   fp, SP
    // 0x2b41c8: CheckStackOverflow
    //     0x2b41c8: ldr   x16, [THR, #0x38]        ; THR = x26, stack-limit slot
    //     0x2b41cc: cmp   SP, x16
    //     0x2b41d0: b.ls  #0x2b41ec                ; overflow -> call the stub
    // 0x2b41d4: ldr   x1, [SP]                     ; x1 = this (the MasterGrade)
    // 0x2b41d8: LoadField: r0 = r1->field_13
    //     0x2b41d8: ldur  w0, [x1, #0x13]          ; 32-bit COMPRESSED pointer load
    //     0x2b41dc: DecompressPointer r0
    //     0x2b41dc: add   x0, x0, HEAP, lsl #32    ; HEAP = x28; rebuild full 64-bit pointer
    // 0x2b41e0: LeaveFrame
    //     0x2b41e0: ldp   fp, lr, [SP], #0x10
    // 0x2b41e4: ret
}
```

## Notes

- `ldr x16,[THR,#0x38]` / `cmp SP,x16` / `b.ls stub` is the **`CheckStackOverflow`** prologue every non-leaf Dart function opens with — `THR` (`x26`) points at the current thread's structure, and `#0x38` is its stack-limit field. Read as plain ARM64 this looks like a mysterious bounds check; knowing the convention, it's boilerplate you skip past.
- The getter's actual work is two instructions: `ldur w0,[x1,#0x13]` loads a **32-bit** value (note `w0`, not `x0`) from `this + 0x13`, then `add x0,x0,HEAP,lsl #32` reconstructs the full pointer by OR-ing the heap base into the top 32 bits — this is Dart's **compressed-pointer** scheme. A field access is *always* this load+decompress pair, never a single `ldr x`.
- The field offset `0x13` is a **tagged** offset (the object's base pointer is `real+1`); the untagged offset is `0x12`. This is exactly the +1 correction the [[Attaching-At-A-Dart-AOT-Entry-Offset]] snippet applies when reading `_LoginRequestJTO`'s fields from Frida.
- `ldr x1,[SP]` picking up `this` off the stack (rather than from `x0`) is the Dart calling convention, not AAPCS64 — another reason [[Flutter-Dart-AOT]] insists you can't read `libapp.so` with the same reflexes as an NDK `.so`.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Reading-Raw-Disassembly]]
- [[Flutter-Dart-AOT]]
- [[Dart-AOT-Stub-Cheatsheet]] in [[Cheatsheets]] — reserved-register roles and stub names.
- [[Attaching-At-A-Dart-AOT-Entry-Offset]] in [[Frida-Dynamic-Instrumentation]] — the runtime hook that reads these same offsets.
- [[ClasseViva-Case-Study]] in [[Case-Studies]]
