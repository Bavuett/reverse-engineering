---
tags: [case-study-note]
case_study: "Classeviva (Spaggiari ClasseViva student app)"
created: 2026-07-28
---

# Login-Response-Parsing-And-Token-Storage

## Question / goal

Once [[Login-Network-Request]]'s POST to `rest/v1/auth/login` succeeds, what does the JSON response actually contain, and where does the app keep the parts it needs to stay signed in?

## Relevant source

- `[[login_response_jto.dart]]` — `_$LoginResponseJTOFromJson` / `_$LoginResponseJTOToJson`
- `[[keychain_service.dart]]` — `KeychainService.save` / `KeychainService.key`

## Excerpt

```
// login_response_jto.dart, _$LoginResponseJTOFromJson -- the "token" field (required, non-null):
// 0x724fa4: ldur            x3, [fp, #-8]
// 0x724fa8: r0 = LoadClassIdInstr(r3)
//     0x724fa8: ldur            x0, [x3, #-1]
//     0x724fac: ubfx            x0, x0, #0xc, #0x14
// 0x724fb0: mov             x1, x3
// 0x724fb4: r2 = "token"
//     0x724fb4: add             x2, PP, #0xb, lsl #12  ; [pp+0xb290] "token"
//     0x724fb8: ldr             x2, [x2, #0x290]
// 0x724fbc: r0 = GDT[cid_x0 + -0xd73]()
//     0x724fbc: sub             lr, x0, #0xd73
//     0x724fc0: ldr             lr, [x21, lr, lsl #3]
//     0x724fc4: blr             lr
// 0x724fc8: mov             x3, x0
// ...                                     ; (branchIfSmi / LoadClassIdInstr dance, see the file)
// 0x724ff4: r8 = String
//     0x724ff4: ldr             x8, [PP, #0x928]  ; [pp+0x928] Type: String
// 0x725000: r0 = String()
//     0x725000: bl              #0x10f70dc  ; IsType_String_Stub   ; token must be a non-null String

// ... the "tokenAP" field (optional, defaults to ""):
// 0x725014: r2 = "tokenAP"
//     0x725014: add             x2, PP, #0x1e, lsl #12  ; [pp+0x1e1b8] "tokenAP"
// 0x725060: r0 = String?()
//     0x725060: bl              #0x6d76ac  ; IsType_String?_Stub
// 0x725064: ldur            x0, [fp, #-0x30]
// 0x725068: cmp             w0, NULL
// 0x72506c: b.ne            #0x725078
// 0x725070: r8 = ""
//     0x725070: ldr             x8, [PP, #0x8b0]  ; [pp+0x8b0] ""
// 0x725074: b               #0x72507c
// 0x725078: mov             x8, x0

// ... "release"/"expire", both ISO-8601 strings turned into real DateTimes:
// 0x7250f0: ldur            x1, [fp, #-0x38]
// 0x7250f4: r0 = parse()
//     0x7250f4: bl              #0x7226d0  ; [dart:core] DateTime::parse
// 0x725160: ldur            x1, [fp, #-0x40]
// 0x725164: r0 = parse()
//     0x725164: bl              #0x7226d0  ; [dart:core] DateTime::parse

// keychain_service.dart, save (trimmed to the serialize-and-persist tail):
// 0x720414: mov             x1, x0
// 0x720418: r0 = _$UserToJson()
//     0x720418: bl              #0x71e004  ; [package:login_flutter/models/user.dart] ::_$UserToJson
// 0x72041c: mov             x1, x0
// 0x720420: r4 = const [0, 0x1, 0, 0x1, null]
//     0x720420: ldr             x4, [PP, #0xa0]  ; [pp+0xa0] List(5) [0, 0x1, 0, 0x1, Null]
// 0x720424: r0 = jsonEncode()
//     0x720424: bl              #0x723408  ; [dart:convert] ::jsonEncode
// 0x720428: mov             x3, x0
// 0x72042c: ldur            x0, [fp, #-0x18]
// 0x720430: stur            x3, [fp, #-0x20]
// 0x720434: LoadField: r1 = r0->field_7
//     0x720434: ldur            w1, [x0, #7]
// 0x720438: DecompressPointer r1
//     0x720438: add             x1, x1, HEAP, lsl #32
// 0x72043c: cmp             w1, NULL
// 0x720440: b.eq            #0x72045c
// 0x720444: ldur            x1, [fp, #-0x10]
// 0x720448: mov             x2, x0
// 0x72044c: r0 = delete()
//     0x72044c: bl              #0x721150  ; [package:login_flutter/services/keychain_service.dart] KeychainService::delete
// 0x720450: mov             x1, x0
// 0x720454: stur            x1, [fp, #-0x28]
// 0x720458: r0 = Await()
//     0x720458: bl              #0x7e84ac  ; AwaitStub
// 0x72045c: ldur            x0, [fp, #-0x10]
// 0x720460: LoadField: r1 = r0->field_7
//     0x720460: ldur            w1, [x0, #7]
// 0x720464: DecompressPointer r1
//     0x720464: add             x1, x1, HEAP, lsl #32
// 0x720468: ldur            x2, [fp, #-0x58]
// 0x72046c: ldur            x3, [fp, #-0x20]
// 0x720470: r0 = write()
//     0x720470: bl              #0x720490  ; [package:flutter_secure_storage/flutter_secure_storage.dart] FlutterSecureStorage::write
// 0x720474: mov             x1, x0
// 0x720478: stur            x1, [fp, #-0x10]
// 0x72047c: r0 = Await()
//     0x72047c: bl              #0x7e84ac  ; AwaitStub

// keychain_service.dart, key:
// 0x7213b8: r1 = Null
//     0x7213b8: mov             x1, NULL
// 0x7213bc: r2 = 4
//     0x7213bc: movz            x2, #0x4
// 0x7213c0: r0 = AllocateArray()
//     0x7213c0: bl              #0x10cbe44  ; AllocateArrayStub
// 0x7213c4: r16 = "KEYCHAIN_USER_ITEM_"
//     0x7213c4: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1de98] "KEYCHAIN_USER_ITEM_"
//     0x7213c8: ldr             x16, [x16, #0xe98]
// 0x7213cc: StoreField: r0->field_f = r16
//     0x7213cc: stur            w16, [x0, #0xf]
// 0x7213d0: ldur            x1, [fp, #-8]
// 0x7213d4: StoreField: r0->field_13 = r1
//     0x7213d4: stur            w1, [x0, #0x13]
// 0x7213d8: str             x0, [SP]
// 0x7213dc: r0 = _interpolate()
//     0x7213dc: bl              #0x6e42b0  ; [dart:core] _StringBase::_interpolate
```

## Analysis

`_$LoginResponseJTOFromJson` is a textbook compiled `json_serializable` deserializer: every field is one virtual `Map<String, dynamic>.[]` call (`GDT[cid_x0 + -0xd73]()` — same dispatch-table mechanism as every other dynamic call in this topic, see [[Flutter-Dart-AOT]]) followed by an `IsType_<Type>_Stub` runtime check, since the map's values arrive as untyped `dynamic` from JSON — there is no reflection happening, just a straight-line sequence of "look up this key, assert it's the type the model declares." This is the JSON-response mirror of the argument-type checks already seen on the way _in_ in [[Login-Network-Request]] (`reactive_forms` values) — the same idiom shows up on both sides of a network boundary because both start from an untyped `dynamic`/`Object?`.

The fields that matter for staying logged in: **`token`** (required, non-null — the session credential itself), **`tokenAP`** (optional, defaults to the empty string if the server omits it — a second, apparently auxiliary token; "AP" most plausibly abbreviates a related "Access Point"/portal token, though the name alone doesn't prove that), and **`expire`**/**`release`**, both delivered as ISO-8601 strings and immediately turned into real `DateTime`s via `DateTime.parse()` rather than kept as raw strings — the session's validity window, computed once at parse time instead of re-parsed every time it's checked.

`KeychainService.save()` doesn't persist the raw JSON — it first rebuilds a `_User` model from the individual fields, `jsonEncode()`s _that_, and only then calls `FlutterSecureStorage::write()`: a plugin backed by the Android Keystore-encrypted `EncryptedSharedPreferences` (iOS Keychain on the other platform) rather than plain `SharedPreferences` — a deliberate choice to keep the token out of a world-readable-by-root plain XML file. Before writing, it conditionally calls `delete()` on whatever was previously stored, consistent with clearing an old account's saved session before writing a new one. The storage **key** itself is `"KEYCHAIN_USER_ITEM_" + ident` — `ident` (the same field read first out of the response) is what lets the device hold more than one saved login side by side, one secure-storage entry per account, which is exactly what backs the app's multi-account switcher.

## Reading the stack frame

`KeychainService.save()`'s own prologue (not shown in the excerpt above, but present in `[[keychain_service.dart]]`) is `SetupParameters(KeychainService this /* r1 => r1, fp-0x10 */, dynamic _ /* r2 => r2, fp-0x18 */)` — two anchors, per the technique in [[Functions-And-Calling-Convention#Reading what a stack slot actually holds|Functions-And-Calling-Convention]]:

| Offset | Holds | Reused? |
| --- | --- | --- |
| `fp-0x10` | `this` — the `KeychainService` instance | No — still `this` at `0x72045c`, right before the final `write()` call near the end of the function |
| `fp-0x18` | the incoming argument (the freshly-logged-in identity's data) | No — read repeatedly (`field_b`, `field_f`, `field_13`, ...) to populate a new `_User`, but never itself overwritten |
| `fp-0x20` | the _last_ field read out of the `fp-0x18` argument (`field_27`) | **Yes** — once that field's been copied into the newly-allocated `_User` object, `0x720430: stur x3, [fp, #-0x20]` overwrites it with the result of `jsonEncode()` instead; every later reference to `fp-0x20` (the `write()` call at the bottom) means the encoded JSON string, not the original field |

The practical payoff of tracking this explicitly: without it, `ldur x3, [fp, #-0x20]` right before `FlutterSecureStorage::write()` reads exactly like it might still be "that one field from the argument" — it's only by having followed the slot from its first `stur` that you can say with confidence it's actually the JSON-encoded `_User` being handed to `write()`, which is the detail the whole note hinges on.

## Related concepts

- [[Flutter-Dart-AOT]]
- [[Memory-And-Data-Structures]]
- [[Login-Network-Request]]
- [[Functions-And-Calling-Convention]]
- [[Tracking-A-Stack-Slots-Meaning]]
- [[Bitfield-Class-Id-Extraction]] — the same `GDT[cid + offset]()` dispatch shape, different offset

## Open questions / next steps

- Confirm what `tokenAP` is actually used for by finding where it's read back out (likely a header on a _different_ family of endpoints than the main REST API, given the separate name).
- `login_shared_preferences_service.dart` (seen alongside `keychain_service.dart` in the raw dump, not imported here) presumably stores the _non-sensitive_ half of the session state — worth a compare-and-contrast note on what deliberately does **not** go into secure storage.

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
