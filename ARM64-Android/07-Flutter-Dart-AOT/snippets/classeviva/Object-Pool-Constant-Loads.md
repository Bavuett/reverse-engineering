---
tags: [snippet]
project: "Classeviva (Spaggiari ClasseViva student app)"
source: "com.spaggiari.classeviva.students, Flutter/Dart release build"
version: "unknown (APK not versioned in the imported excerpt)"
source_path: "core/misc/login_utils.dart — blutter-annotated ARM64 disassembly of the AOT-compiled Dart code, not real Dart source"
date_added: 2026-07-28
license_note: "Personal study/research purposes only. This is a tiny excerpt of a disassembly dump kept for illustrating one instruction pattern — see the full imported files under this topic's Classeviva case study for the broader investigation. Check the app's ToS before any further redistribution."
---

# Object-Pool-Constant-Loads

## Context

`LoginUtils.getLoginMode` reads a static configuration field (which app "flavor"/build variant is
running) and returns a different fixed `List<LoginMode>` depending on its value — a small, easy
first read of [[Flutter-Dart-AOT#Explanation|the object pool]] in isolation, since nearly every
non-trivial value it touches (the static field itself, both enum singletons, the `TypeArguments`
for the list) is pool-loaded.

## Original path

`core/misc/login_utils.dart` (blutter output mirroring `package:classeviva/core/misc/login_utils.dart`)

## Snippet

```
static _ getLoginMode(/* No info */) {
  // 0x10f1af4: r0 = LoadStaticField(0x1214)
  //     0x10f1af4: ldr   x0, [THR, #0x68]  ; THR::field_table_values
  //     0x10f1af8: ldr   x0, [x0, #0x2428]
  //     0x10f1afc: ldr   x16, [PP, #0x6fe0]  ; [pp+0x6fe0] Obj!Flavor@119c2f1
  // 0x10f1b00: cmp   w0, w16
  // 0x10f1b04: b.ne  #0x10f1b64
  ...
  // 0x10f1b1c: r16 = Instance_LoginMode
  //     0x10f1b1c: add   x16, PP, #0xb, lsl #12  ; [pp+0xbc40] Obj!LoginMode@1196951
  //     0x10f1b20: ldr   x16, [x16, #0xc40]
  // 0x10f1b24: StoreField: r0->field_f = r16
  ...
  // 0x10f1b28: r16 = Instance_LoginMode
  //     0x10f1b28: add   x16, PP, #0xb, lsl #12  ; [pp+0xbc48] Obj!LoginMode@1196931
  //     0x10f1b2c: ldr   x16, [x16, #0xc48]
  // 0x10f1b30: StoreField: r0->field_13 = r16
  // 0x10f1b34: r1 = <LoginMode>
  //     0x10f1b34: add   x1, PP, #0xb, lsl #12  ; [pp+0xbc50] TypeArguments: <LoginMode>
  //     0x10f1b38: ldr   x1, [x1, #0xc50]
  // 0x10f1b3c: r0 = AllocateGrowableArray()
  //     0x10f1b3c: bl    #0x10cad78  ; AllocateGrowableArrayStub
}
```

## Notes

- `LoadStaticField` doesn't read a global at a fixed address the way plain C would — it goes
  through `THR::field_table_values` (a per-isolate table of static-field slots, offset `0x68` from
  `THR`) at a fixed slot index (`0x2428`), then compares the result against a *pool-loaded* enum
  singleton (`Obj!Flavor@119c2f1`). Static/global state in Dart is always mediated through this
  per-isolate table, not a fixed memory address — relevant if you're hunting for "where is this
  configuration flag stored," since the answer is "at a stable *slot index*, not a stable address."
- Every enum singleton (`Obj!LoginMode@...`) and the `TypeArguments: <LoginMode>` needed to allocate
  a properly-typed `List<LoginMode>` are separate pool entries, each fetched with the same
  `add x16, PP, #page, lsl #12` / `ldr x16, [x16, #offset]` two-instruction idiom from
  [[Flutter-Dart-AOT#Explanation|the object pool]] — four pool loads in one small function is
  typical, not exceptional.
- Two *different* `Obj!LoginMode@...` addresses (`@1196951` and `@1196931`) confirm these are two
  distinct enum **instances** (variants), each independently allocated once in the snapshot and
  referenced by pointer identity thereafter — exactly the representation
  [[Enum-Switch-Via-Pointer-Comparison]] relies on for `switch`-over-enum dispatch elsewhere in the
  same app.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Flutter-Dart-AOT]]
- [[Enum-Switch-Via-Pointer-Comparison]]
- [[Classeviva-Flutter-Case-Study]]
