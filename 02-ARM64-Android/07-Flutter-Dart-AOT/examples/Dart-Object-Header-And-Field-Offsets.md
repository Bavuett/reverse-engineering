---
tags: [example]
level: 1
aliases: ["Dart field offsets", "Dart object layout"]
created: 2026-11-12
---

# Example: Dart-Object-Header-And-Field-Offsets

> [!info] Level 1 — basics
> One idea: in Dart AOT with compressed pointers, field *n* of an object lives at byte `8 + 4n`, and because object pointers are tagged (+1), the instruction offset is always one less: `#7`, `#0xb`, `#0xf`, `#0x13`, …

## Goal

Predict the `ldur`/`stur` offsets a Dart class's fields compile to, and do the reverse: turn a list of offsets back into a field list. Belongs to [[Flutter-Dart-AOT]].

## Dart source

```dart
class User {
  final String name;        // field 0
  final String email;       // field 1
  final List<String> roles; // field 2
  const User(this.name, this.email, this.roles);
}

String describe(User u) => '${u.name} <${u.email}>';
```

## Layout

```
 byte offset (untagged)    what                    instruction offset (tagged ptr = addr + 1)
 0x00 .. 0x07              header word (class id, size, GC bits)      [x, #-1]  (header byte)
 0x08 .. 0x0b              name   (compressed pointer, 4 bytes)       [x, #0x7]
 0x0c .. 0x0f              email  (compressed pointer)                [x, #0xb]
 0x10 .. 0x13              roles  (compressed pointer)                [x, #0xf]
```

## Compiled (Blutter-style annotation)

```
[get] User.email {
    // EnterFrame / CheckStackOverflow ...
    // ldr   x1, [SP]                   ; x1 = this (tagged pointer to a User)
    // LoadField: r0 = r1->field_b
    //     ldur  w0, [x1, #0xb]         ; 4-byte compressed pointer
    // DecompressPointer r0
    //     add   x0, x0, HEAP, lsl #32  ; rebuild the full 64-bit pointer
    // LeaveFrame / ret
}
```

## Step by step

1. **Header first.** Every Dart object starts with an 8-byte header word holding the class id and size bits. Fields start right after it, at untagged offset `0x8`.
2. **Compressed pointers are 4 bytes.** With pointer compression (standard in Flutter's 64-bit Android builds), each reference field takes 4 bytes, so fields sit at `0x8`, `0xc`, `0x10`, `0x14`, … in declaration order (superclass fields first).
3. **Tagging subtracts one.** Heap pointers carry a `1` in their low bit, so the code addresses a field at `untagged offset − 1`: `0x8 → #7`, `0xc → #0xb`, `0x10 → #0xf`. Blutter's `field_X` names use the *instruction* offset: `field_b` means `[x, #0xb]`, i.e. untagged offset `0xc`. Memorize the sequence `7, b, f, 13, 17, 1b, …`: each step is `+4`.
4. **Reverse direction.** Seeing loads at `#7`, `#0xb`, `#0xf` on the same receiver means three consecutive fields, indices 0, 1, 2. The width (`w` = compressed pointer, or an unboxed value stored inline as `x`) tells you whether each field is a reference.
5. **Every reference load is followed by `DecompressPointer`** (`add xN, xN, HEAP, lsl #32`); that pair is the Dart equivalent of a plain `ldr x` in C code. See [[Compressed-Pointer-Decompression-Step-By-Step]].
6. **Unboxed fields break the +4 rhythm.** A non-nullable `double` or `int` field may be stored unboxed as 8 raw bytes, shifting later offsets by 8 instead of 4. If the rhythm jumps, look for an `ldur x`/`ldur d` at the odd offset.

## Compared with real code

ClasseViva's `_LoginRequestJTO` (four `String` fields: username, password, ident, otp) is read in its real `toString()` at exactly the predicted offsets — `#7`, `#0xb`, `#0xf`, `#0x13` — and Blutter reports `size: 0x18` (8-byte header + 4 × 4 bytes):

```
// class id: 7911, size: 0x18, field offset: 0x8
class _LoginRequestJTO extends LoginRequestJTO {
  _ toString() {
    // r16 = "LoginRequestJTO(username: "
    //     ldur  w2, [x1, #7]          ; username
    // r16 = ", password: "
    //     ldur  w2, [x1, #0xb]        ; password
    // r16 = ", ident: "
    //     ldur  w2, [x1, #0xf]        ; ident
    // r16 = ", otp: "
    //     ldur  w2, [x1, #0x13]       ; otp
  }
}
```

The string literals interleaved with the loads name each field — the reason `toString()` is the first method to read in any Dart model class. Source: `login_request_jto.dart` in [[ClasseViva-Case-Study]]; the same offsets drive the Frida hook in [[Attaching-At-A-Dart-AOT-Entry-Offset]].

## See also

- [[Flutter-Dart-AOT]]
- [[Memory-And-Data-Structures]] — Dart object header vs C structs
- [[Struct-Field-Access]] — the untagged, uncompressed C equivalent
- [[Dart-AOT-Stub-Cheatsheet]]
- [[Blutter]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
