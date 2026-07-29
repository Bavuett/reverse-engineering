// lib: , url: package:login_flutter/services/network/authentication/authentication_service.dart
//
// NOTE: trimmed for this case study. The original dump also has `refreshSpid()` and
// `spidLogin()` (SPID-SSO variants of the same idea, called after the WebView-based SPID flow
// hands back a token) and a private `_setStreamType<Y0>()` helper `login()` calls before
// `fetch()` — cut here, kept is the full `login()` method: the credentials-based POST that
// actually authenticates a user.

// class id: 1050893, size: 0x8
class :: {
}

// class id: 1093, size: 0x14, field offset: 0x8
class _AuthenticationService extends Object
    implements AuthenticationService {

  _ login(/* No info */) async {
    // ** addr: 0x7249bc, size: 0x258
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
    // 0x724a20: CheckStackOverflow
    //     0x724a20: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x724a24: cmp             SP, x16
    //     0x724a28: b.ls            #0x724bf0
    // 0x724a2c: InitAsync() -> Future<LoginJTO>
    //     0x724a2c: add             x0, PP, #0x1e, lsl #12  ; [pp+0x1e0b0] TypeArguments: <LoginJTO>
    //     0x724a30: ldr             x0, [x0, #0xb0]
    //     0x724a34: bl              #0x7e86ec  ; InitAsyncStub
    // 0x724a38: r16 = <String, dynamic>
    //     0x724a38: ldr             x16, [PP, #0x2050]  ; [pp+0x2050] TypeArguments: <String, dynamic>
    // 0x724a3c: ldr             lr, [THR, #0x90]  ; THR::empty_array
    // 0x724a40: stp             lr, x16, [SP]
    // 0x724a44: r0 = Map._fromLiteral()
    //     0x724a44: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
    // 0x724a48: stur            x0, [fp, #-0xd8]
    // 0x724a4c: r16 = <String, dynamic>
    //     0x724a4c: ldr             x16, [PP, #0x2050]  ; [pp+0x2050] TypeArguments: <String, dynamic>
    // 0x724a50: ldr             lr, [THR, #0x90]  ; THR::empty_array
    // 0x724a54: stp             lr, x16, [SP]
    // 0x724a58: r0 = Map._fromLiteral()
    //     0x724a58: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
    // 0x724a5c: r1 = Function '<anonymous closure>':.
    //     0x724a5c: add             x1, PP, #0x1e, lsl #12  ; [pp+0x1e0b8] AnonymousClosure: (0x725bcc), in [package:login_flutter/services/network/authentication/authentication_service.dart] _AuthenticationService::login (0x7249bc)
    //     0x724a60: ldr             x1, [x1, #0xb8]
    // 0x724a64: r2 = Null
    //     0x724a64: mov             x2, NULL
    // 0x724a68: stur            x0, [fp, #-0xe0]
    // 0x724a6c: r0 = AllocateClosure()
    //     0x724a6c: bl              #0x10cb178  ; AllocateClosureStub
    // 0x724a70: ldur            x1, [fp, #-0xe0]
    // 0x724a74: mov             x2, x0
    // 0x724a78: r0 = removeWhere()
    //     0x724a78: bl              #0x725920  ; [dart:_compact_hash] __Map&_HashVMBase&MapMixin::removeWhere
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
    // 0x724a9c: r16 = <String, dynamic>
    //     0x724a9c: ldr             x16, [PP, #0x2050]  ; [pp+0x2050] TypeArguments: <String, dynamic>
    // 0x724aa0: stp             x0, x16, [SP]
    // 0x724aa4: r0 = Map._fromLiteral()
    //     0x724aa4: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
    // 0x724aa8: r1 = Function '<anonymous closure>':.
    //     0x724aa8: add             x1, PP, #0x1e, lsl #12  ; [pp+0x1e0c0] AnonymousClosure: (0x725bcc), in [package:login_flutter/services/network/authentication/authentication_service.dart] _AuthenticationService::login (0x7249bc)
    //     0x724aac: ldr             x1, [x1, #0xc0]
    // 0x724ab0: r2 = Null
    //     0x724ab0: mov             x2, NULL
    // 0x724ab4: stur            x0, [fp, #-0xc0]
    // 0x724ab8: r0 = AllocateClosure()
    //     0x724ab8: bl              #0x10cb178  ; AllocateClosureStub
    // 0x724abc: ldur            x1, [fp, #-0xc0]
    // 0x724ac0: mov             x2, x0
    // 0x724ac4: r0 = removeWhere()
    //     0x724ac4: bl              #0x725920  ; [dart:_compact_hash] __Map&_HashVMBase&MapMixin::removeWhere
    // 0x724ac8: r16 = <String, dynamic>
    //     0x724ac8: ldr             x16, [PP, #0x2050]  ; [pp+0x2050] TypeArguments: <String, dynamic>
    // 0x724acc: ldr             lr, [THR, #0x90]  ; THR::empty_array
    // 0x724ad0: stp             lr, x16, [SP]
    // 0x724ad4: r0 = Map._fromLiteral()
    //     0x724ad4: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
    // 0x724ad8: ldur            x1, [fp, #-0xd0]
    // 0x724adc: stur            x0, [fp, #-0xd0]
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
    // 0x724b04: ldur            x0, [fp, #-0xd8]
    // 0x724b08: StoreField: r1->field_2b = r0
    //     0x724b08: stur            w0, [x1, #0x2b]
    // 0x724b0c: ldur            x0, [fp, #-0xc0]
    // 0x724b10: StoreField: r1->field_b = r0
    //     0x724b10: stur            w0, [x1, #0xb]
    // 0x724b14: ldur            x0, [fp, #-0xc8]
    // 0x724b18: LoadField: r4 = r0->field_7
    //     0x724b18: ldur            w4, [x0, #7]
    // 0x724b1c: DecompressPointer r4
    //     0x724b1c: add             x4, x4, HEAP, lsl #32
    // 0x724b20: stur            x4, [fp, #-0xc0]
    // 0x724b24: LoadField: r2 = r4->field_7
    //     0x724b24: ldur            w2, [x4, #7]
    // 0x724b28: DecompressPointer r2
    //     0x724b28: add             x2, x2, HEAP, lsl #32
    // 0x724b2c: r16 = Sentinel
    //     0x724b2c: ldr             x16, [PP, #0x40]  ; [pp+0x40] Sentinel
    // 0x724b30: cmp             w2, w16
    // 0x724b34: b.eq            #0x724bf8
    // 0x724b38: ldur            x5, [fp, #-0xd0]
    // 0x724b3c: ldur            x6, [fp, #-0xe0]
    // 0x724b40: r3 = "rest/v1/auth/login"
    //     0x724b40: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e0d0] "rest/v1/auth/login"
    //     0x724b44: ldr             x3, [x3, #0xd0]
    // 0x724b48: r4 = const [0, 0x5, 0, 0x5, null]
    //     0x724b48: ldr             x4, [PP, #0x1310]  ; [pp+0x1310] List(5) [0, 0x5, 0, 0x5, Null]
    // 0x724b4c: r0 = compose()
    //     0x724b4c: bl              #0x752c40  ; [package:dio/src/options.dart] Options::compose
    // 0x724b50: mov             x1, x0
    // 0x724b54: ldur            x0, [fp, #-0xc0]
    // 0x724b58: LoadField: r2 = r0->field_7
    //     0x724b58: ldur            w2, [x0, #7]
    // 0x724b5c: DecompressPointer r2
    //     0x724b5c: add             x2, x2, HEAP, lsl #32
    // 0x724b60: LoadField: r3 = r2->field_47
    //     0x724b60: ldur            w3, [x2, #0x47]
    // 0x724b64: DecompressPointer r3
    //     0x724b64: add             x3, x3, HEAP, lsl #32
    // 0x724b68: r16 = Sentinel
    //     0x724b68: ldr             x16, [PP, #0x40]  ; [pp+0x40] Sentinel
    // 0x724b6c: cmp             w3, w16
    // 0x724b70: b.eq            #0x724c04
    // 0x724b74: str             x3, [SP]
    // 0x724b78: r4 = const [0, 0x2, 0x1, 0x1, baseUrl, 0x1, null]
    //     0x724b78: add             x4, PP, #0x1d, lsl #12  ; [pp+0x1d988] List(7) [0, 0x2, 0x1, 0x1, "baseUrl", 0x1, Null]
    //     0x724b7c: ldr             x4, [x4, #0x988]
    // 0x724b80: r0 = copyWith()
    //     0x724b80: bl              #0x7176c8  ; [package:dio/src/options.dart] RequestOptions::copyWith
    // 0x724b84: r16 = <LoginJTO>
    //     0x724b84: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e0b0] TypeArguments: <LoginJTO>
    //     0x724b88: ldr             x16, [x16, #0xb0]
    // 0x724b8c: ldur            lr, [fp, #-0xc8]
    // 0x724b90: stp             lr, x16, [SP, #8]
    // 0x724b94: str             x0, [SP]
    // 0x724b98: r4 = const [0x1, 0x2, 0x2, 0x2, null]
    //     0x724b98: ldr             x4, [PP, #0x48]  ; [pp+0x48] List(5) [0x1, 0x2, 0x2, 0x2, Null]
    // 0x724b9c: r0 = _setStreamType()
    //     0x724b9c: bl              #0x725730  ; [package:login_flutter/services/network/authentication/authentication_service.dart] _AuthenticationService::_setStreamType
    // 0x724ba0: r16 = <Map<String, dynamic>>
    //     0x724ba0: ldr             x16, [PP, #0xc0]  ; [pp+0xc0] TypeArguments: <Map<String, dynamic>>
    // 0x724ba4: ldur            lr, [fp, #-0xc0]
    // 0x724ba8: stp             lr, x16, [SP, #8]
    // 0x724bac: str             x0, [SP]
    // 0x724bb0: r4 = const [0x1, 0x2, 0x2, 0x2, null]
    //     0x724bb0: ldr             x4, [PP, #0x48]  ; [pp+0x48] List(5) [0x1, 0x2, 0x2, 0x2, Null]
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
    // 0x724bec: brk             #0
    // 0x724bf0: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x724bf0: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x724bf4: b               #0x724a2c
    // 0x724bf8: r9 = options
    //     0x724bf8: add             x9, PP, #0x1d, lsl #12  ; Field <_DioForNative&Object&DioMixin@1676344244.options>: late (offset: 0x8)
    //     0x724bfc: ldr             x9, [x9, #0x990]
    // 0x724c00: r0 = LateInitializationErrorSharedWithoutFPURegs()
    //     0x724c00: bl              #0x10cc85c  ; LateInitializationErrorSharedWithoutFPURegsStub
    // 0x724c04: r9 = _baseUrl
    //     0x724c04: add             x9, PP, #0x1d, lsl #12  ; Field <_BaseOptions&_RequestConfig&OptionsMixin@1490184022._baseUrl@1490184022>: late (offset: 0x48)
    //     0x724c08: ldr             x9, [x9, #0x998]
    // 0x724c0c: r0 = LateInitializationErrorSharedWithoutFPURegs()
    //     0x724c0c: bl              #0x10cc85c  ; LateInitializationErrorSharedWithoutFPURegsStub
    // 0x724c10: r0 = NullCastErrorSharedWithoutFPURegs()
    //     0x724c10: bl              #0x10cc5d4  ; NullCastErrorSharedWithoutFPURegsStub
  }
}

// class id: 1094, size: 0x8, field offset: 0x8
abstract class AuthenticationService extends Object {
}
