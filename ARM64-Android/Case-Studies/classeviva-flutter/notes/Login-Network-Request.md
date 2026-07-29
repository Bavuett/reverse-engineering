---
tags: [case-study-note]
case_study: "Classeviva (Spaggiari ClasseViva student app)"
created: 2026-07-28
---

# Login-Network-Request

## Question / goal

Trace the credentials-based sign-in end to end: from the login form's submit handler down to the actual HTTP request that authenticates the user against Spaggiari's backend.

## Relevant source

- `[[login_page.dart]]` — `_LoginPageState._performSignIn`
- `[[authentication_service.dart]]` — `_AuthenticationService.login`

## Excerpt

```
// login_page.dart, _performSignIn -- deciding LoginType and calling into the bloc:
// 0xc0f104: ldur            x1, [fp, #-0x10]
// 0xc0f108: r0 = validateEmail()
//     0xc0f108: bl              #0xc0d0e4  ; [package:classeviva/core/misc/validators/reg_validator.dart] RegValidator::validateEmail
// 0xc0f10c: tbnz            w0, #4, #0xc0f11c
// 0xc0f110: r5 = Instance_LoginType
//     0xc0f110: add             x5, PP, #0x36, lsl #12  ; [pp+0x36790] Obj!LoginType@11969b1
//     0xc0f114: ldr             x5, [x5, #0x790]
// 0xc0f118: b               #0xc0f124
// 0xc0f11c: r5 = Instance_LoginType
//     0xc0f11c: add             x5, PP, #0x27, lsl #12  ; [pp+0x275e8] Obj!LoginType@1196991
//     0xc0f120: ldr             x5, [x5, #0x5e8]
// 0xc0f124: str             NULL, [SP]
// 0xc0f128: ldur            x1, [fp, #-8]
// 0xc0f12c: ldur            x2, [fp, #-0x18]
// 0xc0f130: ldur            x3, [fp, #-0x28]
// 0xc0f134: ldur            x6, [fp, #-0x20]
// 0xc0f138: r4 = const [0, 0x6, 0x1, 0x5, otp, 0x5, null]
//     0xc0f138: add             x4, PP, #0x36, lsl #12  ; [pp+0x36798] List(7) [0, 0x6, 0x1, 0x5, "otp", 0x5, Null]
//     0xc0f13c: ldr             x4, [x4, #0x798]
// 0xc0f140: r0 = signIn()
//     0xc0f140: bl              #0xc0cfb8  ; [package:login_flutter/blocs/sign_in/sign_in_bloc.dart] SignInBloc::signIn

// authentication_service.dart, login -- prologue and resolving the optional `oldToken` argument:
// 0x7249bc: EnterFrame
//     0x7249bc: stp             fp, lr, [SP, #-0x10]!
//     0x7249c0: mov             fp, SP
// 0x7249c4: AllocStack(0xf8)
//     0x7249c4: sub             SP, SP, #0xf8
// 0x7249c8: SetupParameters(_AuthenticationService this /* r1 => r2, fp-0xc8 */, dynamic _ /* r2 => r1, fp-0xd0 */)
//     0x7249c8: stur            NULL, [fp, #-8]
//     0x7249cc: stur            x1, [fp, #-0xc8]
//     0x7249d0: mov             x16, x2
//     0x7249d4: mov             x2, x1
//     0x7249d8: mov             x1, x16
//     0x7249dc: stur            x1, [fp, #-0xd0]
// 0x7249e0: LoadField: r0 = r4->field_13
//     0x7249e0: ldur            w0, [x4, #0x13]
// 0x7249e4: LoadField: r3 = r4->field_1f
//     0x7249e4: ldur            w3, [x4, #0x1f]
// 0x7249e8: DecompressPointer r3
//     0x7249e8: add             x3, x3, HEAP, lsl #32
// 0x7249ec: r16 = "oldToken"
//     0x7249ec: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e0a8] "oldToken"
//     0x7249f0: ldr             x16, [x16, #0xa8]
// 0x7249f4: cmp             w3, w16
// 0x7249f8: b.ne            #0x724a18
// 0x7249fc: LoadField: r3 = r4->field_23
//     0x7249fc: ldur            w3, [x4, #0x23]
// 0x724a00: DecompressPointer r3
//     0x724a00: add             x3, x3, HEAP, lsl #32
// 0x724a04: sub             w4, w0, w3
// 0x724a08: add             x0, fp, w4, sxtw #2
// 0x724a0c: ldr             x0, [x0, #8]
// 0x724a10: mov             x3, x0
// 0x724a14: b               #0x724a1c
// 0x724a18: r3 = Null
//     0x724a18: mov             x3, NULL
// 0x724a1c: stur            x3, [fp, #-0xc0]

// authentication_service.dart, login -- the Z-Auth-Token header, only populated from an oldToken arg:
// 0x724a7c: r1 = Null
//     0x724a7c: mov             x1, NULL
// 0x724a80: r2 = 4
//     0x724a80: movz            x2, #0x4
// 0x724a84: r0 = AllocateArray()
//     0x724a84: bl              #0x10cbe44  ; AllocateArrayStub
// 0x724a88: r16 = "Z-Auth-Token"
//     0x724a88: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dc80] "Z-Auth-Token"
//     0x724a8c: ldr             x16, [x16, #0xc80]
// 0x724a90: StoreField: r0->field_f = r16
//     0x724a90: stur            w16, [x0, #0xf]
// 0x724a94: ldur            x1, [fp, #-0xc0]
// 0x724a98: StoreField: r0->field_13 = r1
//     0x724a98: stur            w1, [x0, #0x13]

// ... building the body and hitting the actual endpoint:
// 0x724ae0: r0 = _$LoginRequestJTOToJson()
//     0x724ae0: bl              #0x725870  ; [package:login_flutter/services/network/jto/login/login_request_jto.dart] ::_$LoginRequestJTOToJson
// 0x724ae4: ldur            x1, [fp, #-0xd0]
// 0x724ae8: mov             x2, x0
// 0x724aec: r0 = addAll()
//     0x724aec: bl              #0x1098f0c  ; [dart:_compact_hash] _Map::addAll
// 0x724af0: r0 = Options()
//     0x724af0: bl              #0x75b7fc  ; AllocateOptionsStub -> Options (size=0x48)
// 0x724af4: mov             x1, x0
// 0x724af8: r0 = "POST"
//     0x724af8: add             x0, PP, #0x1e, lsl #12  ; [pp+0x1e0c8] "POST"
//     0x724afc: ldr             x0, [x0, #0xc8]
// 0x724b00: StoreField: r1->field_7 = r0
//     0x724b00: stur            w0, [x1, #7]
// ...
// 0x724b3c: r3 = "rest/v1/auth/login"
//     0x724b3c: mov             x6, x16
//     0x724b40: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e0d0] "rest/v1/auth/login"
//     0x724b44: ldr             x3, [x3, #0xd0]
// 0x724b48: r4 = const [0, 0x5, 0, 0x5, null]
//     0x724b48: ldr             x4, [PP, #0x1310]  ; [pp+0x1310] List(5) [0, 0x5, 0, 0x5, Null]
// 0x724b4c: r0 = compose()
//     0x724b4c: bl              #0x752c40  ; [package:dio/src/options.dart] Options::compose

// ... the actual network call and parsing the result:
// 0x724bb4: r0 = fetch()
//     0x724bb4: bl              #0x71a7a4  ; [package:dio/src/dio/dio_for_native.dart] _DioForNative&Object&DioMixin::fetch
// 0x724bb8: mov             x1, x0
// 0x724bbc: stur            x1, [fp, #-0xc0]
// 0x724bc0: r0 = Await()
//     0x724bc0: bl              #0x7e84ac  ; AwaitStub
// 0x724bc4: stur            x0, [fp, #-0xc0]
// 0x724bc8: LoadField: r2 = r0->field_b
//     0x724bc8: ldur            w2, [x0, #0xb]
// 0x724bcc: DecompressPointer r2
//     0x724bcc: add             x2, x2, HEAP, lsl #32
// 0x724bd0: cmp             w2, NULL
// 0x724bd4: b.eq            #0x724c10
// 0x724bd8: r1 = Null
//     0x724bd8: mov             x1, NULL
// 0x724bdc: r0 = LoginJTO.fromJson()
//     0x724bdc: bl              #0x724c5c  ; [package:login_flutter/services/network/jto/login/login_jto.dart] LoginJTO::LoginJTO.fromJson
// 0x724be0: r0 = ReturnAsyncNotFuture()
//     0x724be0: b               #0x7e8334  ; ReturnAsyncNotFutureStub
// 0x724be4: sub             SP, fp, #0xf8
// 0x724be8: r0 = ReThrow()
//     0x724be8: bl              #0x10ca0a0  ; ReThrowStub
```

## Analysis

`_performSignIn` doesn't talk to the network itself — it's purely a form-to-BLoC (Business Logic Component) adapter. It reads `username`/`password` out of two `reactive_forms` `FormControl`s (each `AbstractControl.value` is statically typed `Object?`, so every read repeats the same `LinkedHashMap.from` / `UnmodifiableMapView` / `IsType_String_Stub` dance already familiar from [[Memory-And-Data-Structures]]'s discussion of runtime-checked `dynamic` values — just applied here to form input instead of JSON), runs `RegValidator.validateEmail()` to decide whether the entered identifier should be treated as an email or a plain username (materialized as one of two `Instance_LoginType` singletons — the same pool-loaded-enum-singleton mechanism as [[Enum-Switch-Via-Pointer-Comparison]]), and hands everything to `SignInBloc.signIn(...)`.

The real HTTP call lives in `_AuthenticationService.login`, and it's the cleanest real instance in this whole case study of Dart's **`async`-function compiled shape**, which is a step more elaborate than the simple `Await()`-only pattern already documented in [[Flutter-Dart-AOT#Explanation|`async`/`await` and platform channels]]:

- **`InitAsync() -> Future<LoginJTO>`** runs first, before any real work — it sets up the async state machine and the `Future<LoginJTO>` object this function will eventually complete, which is what gets handed back to whoever called `login()` the moment execution first suspends.
- The function's body then runs synchronously until the first _real_ suspension point — here, `fetch()` (the actual Dio HTTP call) followed by `Await()`. Everything before that (building the headers map, the request body via `_$LoginRequestJTOToJson()`, composing `Options`) runs eagerly, on the caller's own stack, exactly like ordinary non-async code.
- **`ReturnAsyncNotFuture()`**, not a plain `ret`, is how the function finishes successfully — it completes the `Future` created by `InitAsync()` with the value already computed in this continuation (`LoginJTO.fromJson(...)`), rather than returning that value directly to whatever is on the stack at that point (which, after a real suspension, is the event loop's dispatcher, not the original caller).
- **`ReThrow()`** is the matching exceptional exit — if `fetch()`'s future completes with an error instead of a response, control lands here and re-raises it _inside_ the async continuation, so that whatever `await`ed this `login()` call sees the exception through its own `try`/`catch`, instead of the isolate crashing.

The request itself: an empty `Map` is populated with a `"Z-Auth-Token"` header only when an `oldToken` argument was supplied (used for re-authenticating an existing session — first-time login passes nothing, so this header is simply absent, per the `removeWhere` calls stripping null entries before the map is used); the actual credentials become the JSON **body**, built by `_$LoginRequestJTOToJson()` from `[[login_request_jto.dart]]` — see [[Api-Endpoint-Strings]] for where the base URL itself comes from, and [[Login-Response-Parsing-And-Token-Storage]] for what comes back and where it ends up.

## Reading the stack frame

Applying [[Functions-And-Calling-Convention#Reading what a stack slot actually holds|the anchor-then-follow technique]] to `login()`'s own frame turns the `SetupParameters` line and everything that follows it into a concrete map — worth doing explicitly once, since this is exactly what you'd have to reconstruct by hand on a binary blutter hadn't annotated:

| Offset | First established by | Holds | Later reused as |
| --- | --- | --- | --- |
| `fp-0x8` | `stur NULL, [fp, #-8]` (before `InitAsync`) | zeroed before the async machinery starts — the kind of slot Dart's async lowering uses internally for the suspended-state bookkeeping, not a value the source code named | — |
| `fp-0xc8` | `stur x1, [fp, #-0xc8]` in `SetupParameters` | `this` — the `_AuthenticationService` instance (arrived in `X1`, per AAPCS64's instance-method convention, see [[Registers-And-Data]]) | stays `this` for the whole function |
| `fp-0xd0` | `stur x1, [fp, #-0xd0]` in `SetupParameters` | the required positional argument — the `LoginRequestJTO` payload (`uid`/`pass`/`ident`/`otp`) | **reused**: once read out into a register for `_$LoginRequestJTOToJson()`, this offset is immediately overwritten with a fresh empty `Map` that becomes the request body |
| `fp-0xc0` | `stur x3, [fp, #-0xc0]` after the `"oldToken"` check | the resolved `oldToken` value — a `String?`, `NULL` if the caller didn't pass one | **reused**: later overwritten with the `{"Z-Auth-Token": oldToken}` header map, and later still with the `fetch()` response |

Two things in that table are worth calling out on their own:

- **How `oldToken` gets resolved at all.** `login`'s second parameter is an _optional named_ argument (`{String? oldToken}` at the source level), and Dart's calling convention doesn't reserve it a fixed register the way a positional argument gets one — instead, the caller passes an **argument descriptor** (here arriving in `X4`) describing which named arguments were actually supplied and where they sit relative to the caller's own frame. `login()`'s prologue walks that descriptor by hand: load a name out of it (`field_1f`), compare against the pool-loaded literal `"oldToken"`, and — only if it matches — compute a byte offset from the descriptor (`field_13` minus `field_23`) and index directly off `fp` (`add x0, fp, w4, sxtw #2` / `ldr x0, [x0, #8]`) to fetch the actual value. If the caller omitted `oldToken` entirely, this whole lookup is skipped and `NULL` is used instead. This is the one instance in this case study where a "parameter" isn't simply "whatever showed up in a fixed register" — it's resolved by explicitly searching the call's own argument metadata, and it's worth recognizing this shape (`cmp` against a literal that reads like a parameter name, then a computed `fp`-relative load) as "this is an optional named argument being looked up," rather than assuming every parameter arrives the same way.
- **`fp-0xc0` and `fp-0xd0` each hold three genuinely different things over the function's lifetime**, not one — a direct, real instance of the slot-reuse phenomenon from [[Tracking-A-Stack-Slots-Meaning]]. Reading either offset's _first_ appearance and assuming that meaning holds for the rest of the disassembly would misdescribe roughly half of what this function does.

## Related concepts

- [[Flutter-Dart-AOT]]
- [[Memory-And-Data-Structures]]
- [[Functions-And-Calling-Convention]]
- [[Tracking-A-Stack-Slots-Meaning]]
- [[Enum-Switch-Via-Pointer-Comparison]]
- [[MethodChannel-Invoke-And-Await]] — the _other_, simpler compiled shape of an awaited call

## Open questions / next steps

- `SignInBloc.signIn` itself (in `package:login_flutter/blocs/sign_in/sign_in_bloc.dart`, ~2200 lines in the raw dump) wasn't imported here — it's the layer between the UI and `AuthenticationService.login`, and would show how `LoginType`/OTP get threaded through and how the multi-account "choices" response gets surfaced back to the UI.
- A Dio _interceptor_ almost certainly attaches the stored token to every request made **after** login (`package:login_flutter/services/interceptors/spaggiari_access_token_interceptor.dart` in the raw dump) — worth a dedicated note to see the token round-trip: saved by [[Login-Response-Parsing-And-Token-Storage]], then read back out and attached here.

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
