---
tags: [case-study-note]
case_study: "ClasseViva (eu.spaggiari.classevivastudente)"
created: 2026-07-30
---

# Hooking a Dart-AOT login() with Frida, without Blutter's generic decoder

## Question / goal

Given Blutter's disassembly of `_AuthenticationService.login()` (an `async` instance method that POSTs to `rest/v1/auth/login`), how do you actually hook it with Frida — attach at the right address, and read `this`/its argument correctly, given Dart AOT doesn't follow the plain AAPCS64 `args[0..7]` convention a JNI function would?

## How this was found

**1. Reading the target function's own disassembly first.** `authentication_service.dart`'s `login()` gave the address (`libapp.so + 0x7249bc`, size `0x258`) and, more importantly, its `SetupParameters` comment:

```
// 0x7249c8: SetupParameters(_AuthenticationService this /* r1 => r2, fp-0xc8 */, dynamic _ /* r2 => r1, fp-0xd0 */)
```

Read literally, this says: at the point this comment describes, the incoming `this` has moved from `x1` into `x2`, and the incoming argument has moved from `x2` into `x1` — a register shuffle the compiler inserted. That's *not yet* the entry-point mapping; it only becomes useful once combined with the next observation.

**2. Checking whether the project already had tooling for this instead of guessing from memory.** Dart AOT's register conventions (`HEAP`, `PP`, `THR`, compressed pointers) are a build-specific detail — which physical register plays which role can differ across Dart SDK versions. Rather than assume numbers from general knowledge, `blutter_out_arm64/` was checked for anything Blutter itself had already produced for this exact binary, and it had: a `blutter_frida.js`, auto-generated alongside the disassembly, containing a complete `Classes[]` table for every Dart class in the app and a generic object decoder. Its preamble gave the concrete, verified register roles for this build (see `source/blutter_frida_register_constants.js`):

```javascript
const HeapAddressReg = 'x28';
const NullReg = 'x22';
const StackReg = 'x15';
```

**3. The first plan (abandoned): reuse the generic template as-is.** Blutter's own `onLibappLoaded` template hooks a target address and reads its first argument via `getArg(context, 0)`, which reads `context[StackReg].add(8 * idx).readPointer()` — i.e., it assumes arguments are sitting in a stack-like argument array at the moment of the hook, and decodes whatever it finds through the full generic `getObjectValue` dispatch (which needs the entire `Classes[]` table to know every class's field layout). This would have worked, but it pulls in machinery built to decode *any* Dart object of *any* class — overkill for a hook whose one argument's exact type is already known from the Dart source (`_LoginRequestJTO`), and the resulting script would carry hundreds of KB of unrelated class metadata for a single call site.

**4. The pivot: the function's own `SetupParameters` comment is a simpler, directly-verifiable source of truth than the generic stack-reading path.** `Interceptor.attach` at the *literal* entry address (`0x7249bc`, the `EnterFrame` instruction itself) fires before any instruction of the function has executed. `EnterFrame`'s own two instructions (`stp fp,lr,[SP,#-0x10]!` / `mov fp,SP`) don't touch `x1`/`x2` at all — so at that exact address, `x1`/`x2` still hold whatever the *caller* put there, which the `SetupParameters` comment already documents: `x1 = this`, `x2 = the dynamic argument`. No stack-argument reading, no generic decoder, no `Classes[]` table needed — just `this.context.x2` in Frida's `onEnter`.

**5. Getting the argument's field layout from its own generated code, not by inspection of a class declaration (there isn't one — it's data-class boilerplate).** `_LoginRequestJTO` (class id `7911`, size `0x18` = 24 bytes: 8-byte header + four 4-byte compressed-pointer fields) has no hand-written field list to read; its layout was recovered from `_$LoginRequestJTOToJson` and `toString`, both of which touch every field and label it:

```
field_7  (untagged offset 0x8)  -> "uid"   (toJson) / "username" (toString)
field_b  (untagged offset 0xc)  -> "pass"  (toJson) / "password" (toString)
field_f  (untagged offset 0x10) -> "ident" (toJson) / "ident"    (toString)
field_13 (untagged offset 0x14) -> "otp"   (toJson) / "otp"      (toString)
```

(The `field_N` comments are offsets relative to the *tagged* pointer, which is `real_address + 1`; adding 1 back gives the untagged offsets used in `hook_login.js`. This matches the class's own `field offset: 0x8` header, i.e. the first field starts right after the 8-byte object header.)

**6. Cross-checking against Blutter's own class table instead of trusting the read by eye alone.** `blutter_frida.js`'s `Classes[]` array independently confirms `{id:7911, name:"_LoginRequestJTO", ..., size:24}` and `{id:94, name:"String", lenOffset:8, dataOffset:16}` (the Dart `String` layout used to decode each field once decompressed) — the same numbers derived from the disassembly by hand, not new information, but a useful check against a misread offset.

**7. What was deliberately left out of scope.** `login()` is `async` — its entry runs `InitAsync()` and returns a suspended `Future` immediately; the real `LoginJTO` response is only produced later by a compiler-generated continuation, not by this function's own return. An `onLeave` on this exact address would show only the pending `Future`, not the server's response. Capturing that would need a second hook on a synchronous point downstream (e.g. wherever `LoginJTO.fromJson` runs, visible in the disassembly at `0x724c5c`) — deliberately not pursued here, since the goal was the request side.

## Relevant source

- [[authentication_service]] — `login()`'s disassembly, in particular the `SetupParameters` comment used in step 4.
- [[login_request_jto]] — `_$LoginRequestJTOToJson`/`toString`, used in step 5 to recover the field layout.
- [[blutter_frida_register_constants]] — the excerpt from Blutter's generated script used in step 2/6.
- [[hook_login]] — the resulting minimal script.

## Excerpt

```
// 0x7249c8: SetupParameters(_AuthenticationService this /* r1 => r2, fp-0xc8 */, dynamic _ /* r2 => r1, fp-0xd0 */)
//     0x7249c8: stur            NULL, [fp, #-8]
//     0x7249cc: stur            x1, [fp, #-0xc8]
//     0x7249d0: mov             x16, x2
//     0x7249d4: mov             x2, x1
//     0x7249d8: mov             x1, x16
//     0x7249dc: stur            x1, [fp, #-0xd0]
```

## Analysis

The final script (`hook_login.js`) reduces to three ideas, each independently verified rather than assumed:

1. Attach at the exact entry offset so `x1`/`x2` still hold the caller's arguments unchanged (confirmed: `EnterFrame` doesn't touch either register).
2. Decompress a heap pointer with `heapBase.add(ptr.toInt32() >>> 0)`, where `heapBase = context.x28.shl(32)` — copied from Blutter's own `decompressPointer`, and correct for both a genuinely compressed 32-bit field *and* an already-full 64-bit register value, since every heap pointer's upper 32 bits equal `heapBase`'s by construction of Dart's compressed-pointer heap layout (a full pointer's low 32 bits, added back to `heapBase`, reconstruct the same pointer — the operation is idempotent).
3. Read each of the four known string fields at its fixed offset (`0x8`/`0xc`/`0x10`/`0x14`) using the Dart `String` layout (`lenOffset:8, dataOffset:16`, length stored as a Smi so shifted right by 1) — no generic per-class dispatch required, since the argument's exact class is statically guaranteed by Dart's type system (every call to this `login()` passes a `_LoginRequestJTO`, never anything else).

## Generalizing the pattern

The same recipe applies to hooking any Dart-AOT instance method whose argument type is statically known (i.e., not a hook on a generic/polymorphic entry point):

1. Get the function's address from Blutter's disassembly.
2. Read its `SetupParameters` comment for the *exact* incoming-register mapping for that function — don't assume a fixed convention (e.g. "`x1` is always `this`") holds for every function; it's whatever the register allocator picked for that one.
3. `Interceptor.attach` at the function's literal entry address (the first byte, i.e. its `EnterFrame` instruction), not one instruction later — confirm from the disassembly that the prologue instructions between the entry and the `SetupParameters` comment don't clobber the registers you need.
4. For the argument's field layout, find any method on that class that touches every field and already labels it — a compiler-generated `toJson`/`toString`/`==` is usually the easiest to read, since it visits every field in sequence with a descriptive string right next to each `LoadField`.
5. Borrow only the build-specific constant (the heap-base register) from Blutter's auto-generated `blutter_frida.js` for this exact binary, rather than assuming a Dart-SDK-wide register number — but skip pulling in its generic `Classes[]`/`getObjectValue` machinery when the argument type is already known statically.

## Related concepts

- [[Flutter-Dart-AOT]]
- [[Native-Memory-And-ARM64]]
- [[Dart-AOT-Stub-Cheatsheet]]

## Open questions / next steps

- Capturing the server's response (`LoginJTO`) would need a second hook on `LoginJTO.fromJson` (`0x724c5c`) or on `Dio`'s response path — not pursued here, request side only.
- The register roles (`x28`/`x22`/`x15`) are specific to this exact build; they should be re-derived from a fresh `blutter_frida.js` (or from the target function's own `SetupParameters` comment) rather than assumed to hold across a Dart SDK upgrade or app update.

## See also

- [[ClasseViva-Case-Study]]
- [[Case-Studies]]
