// lib: , url: package:login_flutter/services/network/jto/login/login_request_jto.dart
//
// Imported excerpt: only the pieces that reveal `_LoginRequestJTO`'s field
// layout (`_$LoginRequestJTOToJson` and `toString`) — `hashCode`/`==` trimmed,
// not needed to justify the hook's field offsets.
// Source: blutter_out_arm64/asm/login_flutter/services/network/jto/login/login_request_jto.dart

class :: {

  static _ _$LoginRequestJTOToJson(/* No info */) {
    // ** addr: 0x725870, size: 0xb0
    // 0x725870: EnterFrame
    //     0x725870: stp             fp, lr, [SP, #-0x10]!
    //     0x725874: mov             fp, SP
    // 0x72587c: SetupParameters(dynamic _ /* r1 => r0, fp-0x8 */)
    //     0x72587c: mov             x0, x1
    //     0x725880: stur            x1, [fp, #-8]
    // 0x72589c: r16 = "uid"
    //     0x72589c: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e220] "uid"
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
    // 0x7258c4: LoadField: r2 = r1->field_b
    //     0x7258c4: ldur            w2, [x1, #0xb]
    // 0x7258c8: DecompressPointer r2
    //     0x7258c8: add             x2, x2, HEAP, lsl #32
    // 0x7258cc: StoreField: r0->field_1b = r2
    //     0x7258cc: stur            w2, [x0, #0x1b]
    // 0x7258d0: r16 = "ident"
    //     0x7258d0: add             x16, PP, #0x11, lsl #12  ; [pp+0x11b20] "ident"
    // 0x7258dc: LoadField: r2 = r1->field_f
    //     0x7258dc: ldur            w2, [x1, #0xf]
    // 0x7258e0: DecompressPointer r2
    //     0x7258e0: add             x2, x2, HEAP, lsl #32
    // 0x7258e4: StoreField: r0->field_23 = r2
    //     0x7258e4: stur            w2, [x0, #0x23]
    // 0x7258e8: r16 = "otp"
    //     0x7258e8: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e230] "otp"
    // 0x7258f4: LoadField: r2 = r1->field_13
    //     0x7258f4: ldur            w2, [x1, #0x13]
    // 0x7258f8: DecompressPointer r2
    //     0x7258f8: add             x2, x2, HEAP, lsl #32
    // 0x7258fc: StoreField: r0->field_2b = r2
    //     0x7258fc: stur            w2, [x0, #0x2b]
    // 0x725900: r16 = <String, dynamic>
    // 0x725908: r0 = Map._fromLiteral()
    //     0x725908: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
    // 0x72590c: LeaveFrame
    // 0x725914: ret
  }
}

// class id: 7911, size: 0x18, field offset: 0x8
//   const constructor,
class _LoginRequestJTO extends LoginRequestJTO {

  _ toString(/* No info */) {
    // ** addr: 0xe3ba7c, size: 0xac
    // 0xe3baa0: r16 = "LoginRequestJTO(username: "
    // 0xe3baac: ldr             x1, [fp, #0x10]
    // 0xe3bab0: LoadField: r2 = r1->field_7
    //     0xe3bab0: ldur            w2, [x1, #7]
    // 0xe3bab4: DecompressPointer r2
    //     0xe3bab4: add             x2, x2, HEAP, lsl #32
    // 0xe3babc: r16 = ", password: "
    // 0xe3bac8: LoadField: r2 = r1->field_b
    //     0xe3bac8: ldur            w2, [x1, #0xb]
    // 0xe3bacc: DecompressPointer r2
    //     0xe3bacc: add             x2, x2, HEAP, lsl #32
    // 0xe3bad4: r16 = ", ident: "
    // 0xe3bae0: LoadField: r2 = r1->field_f
    //     0xe3bae0: ldur            w2, [x1, #0xf]
    // 0xe3bae4: DecompressPointer r2
    //     0xe3bae4: add             x2, x2, HEAP, lsl #32
    // 0xe3baec: r16 = ", otp: "
    // 0xe3baf8: LoadField: r2 = r1->field_13
    //     0xe3baf8: ldur            w2, [x1, #0x13]
    // 0xe3bafc: DecompressPointer r2
    //     0xe3bafc: add             x2, x2, HEAP, lsl #32
    // 0xe3bb04: r16 = ")"
    // 0xe3bb10: r0 = _interpolate()
    //     0xe3bb10: bl              #0x6e42b0  ; [dart:core] _StringBase::_interpolate
  }
}
