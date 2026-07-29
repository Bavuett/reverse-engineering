// lib: , url: package:login_flutter/services/network/jto/login/login_request_jto.dart
// (package:login_flutter is Spaggiari's own shared login library, reused across their apps
// including Classeviva — a separate Dart package from package:classeviva itself, hence the
// different top-level folder here under source/.)

// class id: 1050906, size: 0x8
class :: {

  static _ _$LoginRequestJTOToJson(/* No info */) {
    // ** addr: 0x725870, size: 0xb0
    // 0x725870: EnterFrame
    //     0x725870: stp             fp, lr, [SP, #-0x10]!
    //     0x725874: mov             fp, SP
    // 0x725878: AllocStack(0x18)
    //     0x725878: sub             SP, SP, #0x18
    // 0x72587c: SetupParameters(dynamic _ /* r1 => r0, fp-0x8 */)
    //     0x72587c: mov             x0, x1
    //     0x725880: stur            x1, [fp, #-8]
    // 0x725884: CheckStackOverflow
    //     0x725884: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x725888: cmp             SP, x16
    //     0x72588c: b.ls            #0x725918
    // 0x725890: r1 = Null
    //     0x725890: mov             x1, NULL
    // 0x725894: r2 = 16
    //     0x725894: movz            x2, #0x10
    // 0x725898: r0 = AllocateArray()
    //     0x725898: bl              #0x10cbe44  ; AllocateArrayStub
    // 0x72589c: r16 = "uid"
    //     0x72589c: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e220] "uid"
    //     0x7258a0: ldr             x16, [x16, #0x220]
    // 0x7258a4: StoreField: r0->field_f = r16
    //     0x7258a4: stur            w16, [x0, #0xf]
    // 0x7258a8: ldur            x1, [fp, #-8]
    // 0x7258ac: LoadField: r2 = r1->field_7
    //     0x7258ac: ldur            w2, [x1, #7]
    // 0x7258b0: DecompressPointer r2
    //     0x7258b0: add             x2, x2, HEAP, lsl #32
    // 0x7258b4: StoreField: r0->field_13 = r2
    //     0x7258b4: stur            w2, [x0, #0x13]
    // 0x7258b8: r16 = "pass"
    //     0x7258b8: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e228] "pass"
    //     0x7258bc: ldr             x16, [x16, #0x228]
    // 0x7258c0: ArrayStore: r0[0] = r16  ; List_4
    //     0x7258c0: stur            w16, [x0, #0x17]
    // 0x7258c4: LoadField: r2 = r1->field_b
    //     0x7258c4: ldur            w2, [x1, #0xb]
    // 0x7258c8: DecompressPointer r2
    //     0x7258c8: add             x2, x2, HEAP, lsl #32
    // 0x7258cc: StoreField: r0->field_1b = r2
    //     0x7258cc: stur            w2, [x0, #0x1b]
    // 0x7258d0: r16 = "ident"
    //     0x7258d0: add             x16, PP, #0x11, lsl #12  ; [pp+0x11b20] "ident"
    //     0x7258d4: ldr             x16, [x16, #0xb20]
    // 0x7258d8: StoreField: r0->field_1f = r16
    //     0x7258d8: stur            w16, [x0, #0x1f]
    // 0x7258dc: LoadField: r2 = r1->field_f
    //     0x7258dc: ldur            w2, [x1, #0xf]
    // 0x7258e0: DecompressPointer r2
    //     0x7258e0: add             x2, x2, HEAP, lsl #32
    // 0x7258e4: StoreField: r0->field_23 = r2
    //     0x7258e4: stur            w2, [x0, #0x23]
    // 0x7258e8: r16 = "otp"
    //     0x7258e8: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e230] "otp"
    //     0x7258ec: ldr             x16, [x16, #0x230]
    // 0x7258f0: StoreField: r0->field_27 = r16
    //     0x7258f0: stur            w16, [x0, #0x27]
    // 0x7258f4: LoadField: r2 = r1->field_13
    //     0x7258f4: ldur            w2, [x1, #0x13]
    // 0x7258f8: DecompressPointer r2
    //     0x7258f8: add             x2, x2, HEAP, lsl #32
    // 0x7258fc: StoreField: r0->field_2b = r2
    //     0x7258fc: stur            w2, [x0, #0x2b]
    // 0x725900: r16 = <String, dynamic>
    //     0x725900: ldr             x16, [PP, #0x2050]  ; [pp+0x2050] TypeArguments: <String, dynamic>
    // 0x725904: stp             x0, x16, [SP]
    // 0x725908: r0 = Map._fromLiteral()
    //     0x725908: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
    // 0x72590c: LeaveFrame
    //     0x72590c: mov             SP, fp
    //     0x725910: ldp             fp, lr, [SP], #0x10
    // 0x725914: ret
    //     0x725914: ret
    // 0x725918: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x725918: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x72591c: b               #0x725890
  }
}

// class id: 1080, size: 0x8, field offset: 0x8
abstract class _$LoginRequestJTO extends Object {
}

// class id: 7909, size: 0x8, field offset: 0x8
//   const constructor, transformed mixin,
abstract class _LoginRequestJTO&JTO&_$LoginRequestJTO extends JTO
     with _$LoginRequestJTO {
}

// class id: 7910, size: 0x8, field offset: 0x8
//   const constructor,
abstract class LoginRequestJTO extends _LoginRequestJTO&JTO&_$LoginRequestJTO {
}

// class id: 7911, size: 0x18, field offset: 0x8
//   const constructor,
class _LoginRequestJTO extends LoginRequestJTO {

  Map<String, dynamic> toJson(_LoginRequestJTO) {
    // ** addr: 0x724c2c, size: 0x48
    // 0x724c2c: EnterFrame
    //     0x724c2c: stp             fp, lr, [SP, #-0x10]!
    //     0x724c30: mov             fp, SP
    // 0x724c34: CheckStackOverflow
    //     0x724c34: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x724c38: cmp             SP, x16
    //     0x724c3c: b.ls            #0x724c54
    // 0x724c40: ldr             x1, [fp, #0x10]
    // 0x724c44: r0 = _$LoginRequestJTOToJson()
    //     0x724c44: bl              #0x725870  ; [package:login_flutter/services/network/jto/login/login_request_jto.dart] ::_$LoginRequestJTOToJson
    // 0x724c48: LeaveFrame
    //     0x724c48: mov             SP, fp
    //     0x724c4c: ldp             fp, lr, [SP], #0x10
    // 0x724c50: ret
    //     0x724c50: ret
    // 0x724c54: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x724c54: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x724c58: b               #0x724c40
  }
  _ toString(/* No info */) {
    // ** addr: 0xe3ba7c, size: 0xac
    // 0xe3ba7c: EnterFrame
    //     0xe3ba7c: stp             fp, lr, [SP, #-0x10]!
    //     0xe3ba80: mov             fp, SP
    // 0xe3ba84: AllocStack(0x8)
    //     0xe3ba84: sub             SP, SP, #8
    // 0xe3ba88: CheckStackOverflow
    //     0xe3ba88: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xe3ba8c: cmp             SP, x16
    //     0xe3ba90: b.ls            #0xe3bb20
    // 0xe3ba94: r1 = Null
    //     0xe3ba94: mov             x1, NULL
    // 0xe3ba98: r2 = 18
    //     0xe3ba98: movz            x2, #0x12
    // 0xe3ba9c: r0 = AllocateArray()
    //     0xe3ba9c: bl              #0x10cbe44  ; AllocateArrayStub
    // 0xe3baa0: r16 = "LoginRequestJTO(username: "
    //     0xe3baa0: add             x16, PP, #0x2a, lsl #12  ; [pp+0x2ad78] "LoginRequestJTO(username: "
    //     0xe3baa4: ldr             x16, [x16, #0xd78]
    // 0xe3baa8: StoreField: r0->field_f = r16
    //     0xe3baa8: stur            w16, [x0, #0xf]
    // 0xe3baac: ldr             x1, [fp, #0x10]
    // 0xe3bab0: LoadField: r2 = r1->field_7
    //     0xe3bab0: ldur            w2, [x1, #7]
    // 0xe3bab4: DecompressPointer r2
    //     0xe3bab4: add             x2, x2, HEAP, lsl #32
    // 0xe3bab8: StoreField: r0->field_13 = r2
    //     0xe3bab8: stur            w2, [x0, #0x13]
    // 0xe3babc: r16 = ", password: "
    //     0xe3babc: add             x16, PP, #0x2a, lsl #12  ; [pp+0x2ad80] ", password: "
    //     0xe3bac0: ldr             x16, [x16, #0xd80]
    // 0xe3bac4: ArrayStore: r0[0] = r16  ; List_4
    //     0xe3bac4: stur            w16, [x0, #0x17]
    // 0xe3bac8: LoadField: r2 = r1->field_b
    //     0xe3bac8: ldur            w2, [x1, #0xb]
    // 0xe3bacc: DecompressPointer r2
    //     0xe3bacc: add             x2, x2, HEAP, lsl #32
    // 0xe3bad0: StoreField: r0->field_1b = r2
    //     0xe3bad0: stur            w2, [x0, #0x1b]
    // 0xe3bad4: r16 = ", ident: "
    //     0xe3bad4: add             x16, PP, #0x2a, lsl #12  ; [pp+0x2ad88] ", ident: "
    //     0xe3bad8: ldr             x16, [x16, #0xd88]
    // 0xe3badc: StoreField: r0->field_1f = r16
    //     0xe3badc: stur            w16, [x0, #0x1f]
    // 0xe3bae0: LoadField: r2 = r1->field_f
    //     0xe3bae0: ldur            w2, [x1, #0xf]
    // 0xe3bae4: DecompressPointer r2
    //     0xe3bae4: add             x2, x2, HEAP, lsl #32
    // 0xe3bae8: StoreField: r0->field_23 = r2
    //     0xe3bae8: stur            w2, [x0, #0x23]
    // 0xe3baec: r16 = ", otp: "
    //     0xe3baec: add             x16, PP, #0x2a, lsl #12  ; [pp+0x2ad90] ", otp: "
    //     0xe3baf0: ldr             x16, [x16, #0xd90]
    // 0xe3baf4: StoreField: r0->field_27 = r16
    //     0xe3baf4: stur            w16, [x0, #0x27]
    // 0xe3baf8: LoadField: r2 = r1->field_13
    //     0xe3baf8: ldur            w2, [x1, #0x13]
    // 0xe3bafc: DecompressPointer r2
    //     0xe3bafc: add             x2, x2, HEAP, lsl #32
    // 0xe3bb00: StoreField: r0->field_2b = r2
    //     0xe3bb00: stur            w2, [x0, #0x2b]
    // 0xe3bb04: r16 = ")"
    //     0xe3bb04: ldr             x16, [PP, #0xdb0]  ; [pp+0xdb0] ")"
    // 0xe3bb08: StoreField: r0->field_2f = r16
    //     0xe3bb08: stur            w16, [x0, #0x2f]
    // 0xe3bb0c: str             x0, [SP]
    // 0xe3bb10: r0 = _interpolate()
    //     0xe3bb10: bl              #0x6e42b0  ; [dart:core] _StringBase::_interpolate
    // 0xe3bb14: LeaveFrame
    //     0xe3bb14: mov             SP, fp
    //     0xe3bb18: ldp             fp, lr, [SP], #0x10
    // 0xe3bb1c: ret
    //     0xe3bb1c: ret
    // 0xe3bb20: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xe3bb20: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xe3bb24: b               #0xe3ba94
  }

  // ... trimmed: hashCode getter and operator== (structural equality boilerplate,
  // same shape as every other freezed/json_serializable model in this vault).
}
