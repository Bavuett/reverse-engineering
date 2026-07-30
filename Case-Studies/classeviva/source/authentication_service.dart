// lib: , url: package:login_flutter/services/network/authentication/authentication_service.dart
//
// Imported excerpt: only `login()` (the hooked function) is kept. The real
// file also has `_setStreamType`, `refreshSpid`, `spidLogin`, etc. — trimmed
// here since they're not part of this investigation.
// Source: blutter_out_arm64/asm/login_flutter/services/network/authentication/authentication_service.dart
// (Blutter disassembly of eu.spaggiari.classevivastudente's libapp.so)

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
    // ... (headers map construction, elided — irrelevant to the hook)
    // 0x724ac8: r16 = <String, dynamic>
    //     0x724ac8: ldr             x16, [PP, #0xc0]  ; [pp+0xc0] TypeArguments: <Map<String, dynamic>>
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
    // ... (Options/RequestOptions setup, elided)
    // 0x724b40: r3 = "rest/v1/auth/login"
    //     0x724b40: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e0d0] "rest/v1/auth/login"
    //     0x724b44: ldr             x3, [x3, #0xd0]
    // 0x724b4c: r0 = compose()
    //     0x724b4c: bl              #0x752c40  ; [package:dio/src/options.dart] Options::compose
    // 0x724b9c: r0 = _setStreamType()
    //     0x724b9c: bl              #0x725730  ; [package:login_flutter/services/network/authentication/authentication_service.dart] _AuthenticationService::_setStreamType
    // 0x724bb4: r0 = fetch()
    //     0x724bb4: bl              #0x71a7a4  ; [package:dio/src/dio/dio_for_native.dart] _DioForNative&Object&DioMixin::fetch
    // 0x724bc0: r0 = Await()
    //     0x724bc0: bl              #0x7e84ac  ; AwaitStub
    // 0x724bc4: stur            x0, [fp, #-0xc0]
    // 0x724bc8: LoadField: r2 = r0->field_b
    //     0x724bc8: ldur            w2, [x0, #0xb]
    // 0x724bcc: DecompressPointer r2
    //     0x724bcc: add             x2, x2, HEAP, lsl #32
    // 0x724bd0: cmp             w2, NULL
    // 0x724bd4: b.eq            #0x724c10
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
  }
}
