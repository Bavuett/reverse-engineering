---
tags: [case-study-note]
case_study: "Classeviva (Spaggiari ClasseViva student app)"
created: 2026-07-28
---

# Api-Endpoint-Strings

## Question / goal

Where do the literal API host/path strings actually live in the compiled app, and what does building a URL out of them look like once compiled?

## Relevant source

- `[[servers.dart]]` — `Servers.italyPreviousYear` / `Servers.argentinaPreviousYear` / `Servers.sanMarinoPreviousYear`
- `[[const_link.dart]]` — `ConstLink.getLoginWebUrl` / `ConstLink.getSpidUrl`

## Excerpt

```
// servers.dart, italyPreviousYear -- building "https://web<year>.spaggiari.eu/" via _interpolate:
// 0x10dedf4: r0 = AllocateArray()
//     0x10dedf4: bl              #0x10cbe44  ; AllocateArrayStub
// 0x10dedf8: r16 = "https://web"
//     0x10dedf8: add             x16, PP, #9, lsl #12  ; [pp+0x9d38] "https://web"
//     0x10dedfc: ldr             x16, [x16, #0xd38]
// 0x10dee00: StoreField: r0->field_f = r16
//     0x10dee00: stur            w16, [x0, #0xf]
// 0x10dee04: ldur            x1, [fp, #-8]
// 0x10dee08: StoreField: r0->field_13 = r1        ; the `year` argument, dropped in between the fragments
//     0x10dee08: stur            w1, [x0, #0x13]
// 0x10dee0c: r16 = "."
//     0x10dee0c: ldr             x16, [PP, #0xf70]  ; [pp+0xf70] "."
// 0x10dee10: ArrayStore: r0[0] = r16  ; List_4
//     0x10dee10: stur            w16, [x0, #0x17]
// 0x10dee14: r16 = "spaggiari"
//     0x10dee14: add             x16, PP, #9, lsl #12  ; [pp+0x9d40] "spaggiari"
//     0x10dee18: ldr             x16, [x16, #0xd40]
// 0x10dee1c: StoreField: r0->field_1b = r16
//     0x10dee1c: stur            w16, [x0, #0x1b]
// 0x10dee20: r16 = ".eu/"
//     0x10dee20: add             x16, PP, #9, lsl #12  ; [pp+0x9d58] ".eu/"
//     0x10dee24: ldr             x16, [x16, #0xd58]
// 0x10dee28: StoreField: r0->field_1f = r16
//     0x10dee28: stur            w16, [x0, #0x1f]
// 0x10dee2c: str             x0, [SP]
// 0x10dee30: r0 = _interpolate()
//     0x10dee30: bl              #0x6e42b0  ; [dart:core] _StringBase::_interpolate

// const_link.dart, getLoginWebUrl -- ServerNation as a Map key, then the login.php path appended:
// 0xc02ac4: r16 = Instance_ServerNation
//     0xc02ac4: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dc88] Obj!ServerNation@1196871
//     0xc02ac8: ldr             x16, [x16, #0xc88]
// 0xc02acc: StoreField: r0->field_f = r16
//     0xc02acc: stur            w16, [x0, #0xf]
// 0xc02ad0: r16 = "https://web.spaggiari.eu/"
//     0xc02ad0: add             x16, PP, #8, lsl #12  ; [pp+0x8380] "https://web.spaggiari.eu/"
//     0xc02ad4: ldr             x16, [x16, #0x380]
// 0xc02ad8: StoreField: r0->field_13 = r16
//     0xc02ad8: stur            w16, [x0, #0x13]
// 0xc02adc: r16 = Instance_ServerNation
//     0xc02adc: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dc98] Obj!ServerNation@1196831
//     0xc02ae0: ldr             x16, [x16, #0xc98]
// 0xc02ae4: ArrayStore: r0[0] = r16  ; List_4
//     0xc02ae4: stur            w16, [x0, #0x17]
// 0xc02ae8: r16 = "https://ar.spaggiari.eu/"
//     0xc02ae8: add             x16, PP, #8, lsl #12  ; [pp+0x8388] "https://ar.spaggiari.eu/"
//     0xc02aec: ldr             x16, [x16, #0x388]
// 0xc02af0: StoreField: r0->field_1b = r16
//     0xc02af0: stur            w16, [x0, #0x1b]
// 0xc02af4: r16 = Instance_ServerNation
//     0xc02af4: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dc90] Obj!ServerNation@1196851
//     0xc02af8: ldr             x16, [x16, #0xc90]
// 0xc02afc: StoreField: r0->field_1f = r16
//     0xc02afc: stur            w16, [x0, #0x1f]
// 0xc02b00: r16 = "https://web.spaggiari.sm/"
//     0xc02b00: add             x16, PP, #8, lsl #12  ; [pp+0x8390] "https://web.spaggiari.sm/"
//     0xc02b04: ldr             x16, [x16, #0x390]
// 0xc02b08: StoreField: r0->field_23 = r16
//     0xc02b08: stur            w16, [x0, #0x23]
// 0xc02b0c: r16 = <ServerNation, String>
//     0xc02b0c: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dfc0] TypeArguments: <ServerNation, String>
//     0xc02b10: ldr             x16, [x16, #0xfc0]
// 0xc02b14: stp             x0, x16, [SP]
// 0xc02b18: r0 = Map._fromLiteral()
//     0xc02b18: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
// 0xc02b1c: mov             x1, x0
// 0xc02b20: r2 = Instance_ServerNation
//     0xc02b20: add             x2, PP, #0x1d, lsl #12  ; [pp+0x1dc88] Obj!ServerNation@1196871
//     0xc02b24: ldr             x2, [x2, #0xc88]
// 0xc02b28: stur            x0, [fp, #-8]
// 0xc02b2c: r0 = _getValueOrData()
//     0xc02b2c: bl              #0x10c499c  ; [dart:_compact_hash] __Map&_HashVMBase&MapMixin&_HashBase&_OperatorEqualsAndHashCode&_LinkedHashMapMixin::_getValueOrData
// ...
// 0xc02b60: r16 = "home/app/default/login.php\?target=&mode="
//     0xc02b60: add             x16, PP, #0x36, lsl #12  ; [pp+0x36a28] "home/app/default/login.php\?target=&mode="
//     0xc02b64: ldr             x16, [x16, #0xa28]
// 0xc02b68: stp             x16, x0, [SP]
// 0xc02b6c: r0 = +()
//     0xc02b6c: bl              #0x6e45ac  ; [dart:core] _StringBase::+
```

## Analysis

Spaggiari runs parallel server clusters per country — Italy and San Marino share the `spaggiari.eu`/`spaggiari.sm` naming scheme, Argentina gets its own `ar.spaggiari.eu` — and the app picks the right one via a small `ServerNation` enum with (at least) three singleton instances. This is a second, genuinely different use of the enum-singleton pattern already seen in [[Enum-Switch-Via-Pointer-Comparison]]: there, an enum value was **compared** across a cascade of `cmp`/`b.ne`; here it's used as a **hash map key** (`Map._fromLiteral` + `_getValueOrData`, a real hashed lookup rather than a linear scan) — same underlying object-identity mechanism, two different compiled shapes depending on whether the source wrote a `switch`/`if` chain or indexed into a `Map<ServerNation, ...>`.

Two distinct ways a string gets built up from pool-loaded fragments, both already introduced elsewhere in this topic but worth telling apart on sight:

- **`_interpolate()`** (`[[Object-Pool-Constant-Loads|Reference]]`-style, seen throughout this vault) takes an _array_ of pieces — literal fragments and one embedded value (`year`, in `Servers.*PreviousYear`) — and joins all of them in one call. This is what a source-level `"https://web$year.spaggiari.eu/"` string template compiles to.
- **`_StringBase::+`** (seen here for the first time in this case study) is plain two-operand concatenation — `baseUrl + "home/app/default/login.php?target=&mode="` — what a source-level `baseUrl + "..."` expression compiles to instead. Functionally almost the same result as a two-piece interpolation, but a different call, because it's a different source-level operator.

The literal `\?` inside `"home/app/default/login.php\?target=&mode="` is **blutter's own escaping** of the annotation format, not something Dart's string syntax requires — the real string just contains a plain `?`; don't read backslash-escaped question marks as evidence of anything unusual in the source.

Both `getLoginWebUrl()` and `getSpidUrl()` build a URL that ends in a **`.php`** page (`login.php`, `login_spid.php`) — meaning ClasseViva's login, at the protocol level, actually comes in two unrelated shapes reversed independently in this case study: a classic **REST/JSON** call (`rest/v1/auth/login`, username+password, see [[Login-Network-Request]]) for the credentials form, and a **WebView-loaded HTML login page** (`login.php`/`login_spid.php`, see [[Async-Await-And-Platform-Channels]] for the SPID variant's `MethodChannel` plumbing) for SSO-style flows — not two implementations of the same thing, but genuinely two different authentication mechanisms living side by side in the same app.

## Related concepts

- [[Flutter-Dart-AOT]]
- [[Object-Pool-Constant-Loads]]
- [[Enum-Switch-Via-Pointer-Comparison]]
- [[Login-Network-Request]]
- [[Async-Await-And-Platform-Channels]]

## Open questions / next steps

- Confirm which login path (`rest/v1/auth/login` vs. the SPID WebView) is the default/primary one presented to a new user, by reading more of `login_page.dart`'s `build()` (not imported here — 4989 lines, mostly widget tree).
- The three `Obj!ServerNation@...` addresses recur across both `servers.dart` and `const_link.dart` — cross-referencing them confirms (without needing the enum's declared member names) that both files agree on the same three server regions.

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
