// lib: , url: package:classeviva/ui/pages/account_pages/sign_in_pages/login_page.dart
//
// NOTE: heavily trimmed for this case study. The full dump is 4989 lines (the entire
// username/password sign-in page's widget tree, OTP sheet, forgot-password flow, error dialogs,
// ...) — kept here is only `_performSignIn()`, the handler that reads the login form and kicks
// off the actual sign-in.

// class id: 3988, size: 0x1c, field offset: 0x14
class _LoginPageState extends State<dynamic> {

  _ _performSignIn(/* No info */) {
    // ** addr: 0xc0ee1c, size: 0x354
    // 0xc0ee1c: EnterFrame
    //     0xc0ee1c: stp             fp, lr, [SP, #-0x10]!
    //     0xc0ee20: mov             fp, SP
    // 0xc0ee24: AllocStack(0x38)
    //     0xc0ee24: sub             SP, SP, #0x38
    // 0xc0ee28: SetupParameters(dynamic _ /* r2 => r4, fp-0x8 */, dynamic _ /* r3 => r3, fp-0x10 */, dynamic _ /* r5 => r0, fp-0x18 */)
    //     0xc0ee28: mov             x4, x2
    //     0xc0ee2c: mov             x0, x5
    //     0xc0ee30: stur            x2, [fp, #-8]
    //     0xc0ee34: stur            x3, [fp, #-0x10]
    //     0xc0ee38: stur            x5, [fp, #-0x18]
    // 0xc0ee3c: CheckStackOverflow
    //     0xc0ee3c: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xc0ee40: cmp             SP, x16
    //     0xc0ee44: b.ls            #0xc0f154
    // 0xc0ee48: mov             x1, x3
    // 0xc0ee4c: r2 = "username"
    //     0xc0ee4c: add             x2, PP, #0x1d, lsl #12  ; [pp+0x1df30] "username"
    //     0xc0ee50: ldr             x2, [x2, #0xf30]
    // 0xc0ee54: r0 = control()
    //     0xc0ee54: bl              #0x7dece8  ; [package:reactive_forms/src/models/models.dart] FormGroup::control
    // 0xc0ee58: r1 = LoadClassIdInstr(r0)
    //     0xc0ee58: ldur            x1, [x0, #-1]
    //     0xc0ee5c: ubfx            x1, x1, #0xc, #0x14
    // 0xc0ee60: cmp             x1, #0x2b5
    // 0xc0ee64: b.ne            #0xc0ee88
    // 0xc0ee68: LoadField: r2 = r0->field_2b
    //     0xc0ee68: ldur            w2, [x0, #0x2b]
    // 0xc0ee6c: DecompressPointer r2
    //     0xc0ee6c: add             x2, x2, HEAP, lsl #32
    // 0xc0ee70: cmp             w2, NULL
    // 0xc0ee74: b.eq            #0xc0f15c
    // 0xc0ee78: r1 = <String, Object?>
    //     0xc0ee78: add             x1, PP, #8, lsl #12  ; [pp+0x8ee8] TypeArguments: <String, Object?>
    //     0xc0ee7c: ldr             x1, [x1, #0xee8]
    // 0xc0ee80: r0 = LinkedHashMap.from()
    //     0xc0ee80: bl              #0x718cac  ; [dart:collection] LinkedHashMap::LinkedHashMap.from
    // 0xc0ee84: b               #0xc0ee98
    // 0xc0ee88: LoadField: r1 = r0->field_2b
    //     0xc0ee88: ldur            w1, [x0, #0x2b]
    // 0xc0ee8c: DecompressPointer r1
    //     0xc0ee8c: add             x1, x1, HEAP, lsl #32
    // 0xc0ee90: cmp             w1, NULL
    // 0xc0ee94: b.eq            #0xc0f144
    // 0xc0ee98: ldur            x1, [fp, #-0x10]
    // 0xc0ee9c: r2 = "password"
    //     0xc0ee9c: add             x2, PP, #0x1d, lsl #12  ; [pp+0x1df48] "password"
    //     0xc0eea0: ldr             x2, [x2, #0xf48]
    // 0xc0eea4: r0 = control()
    //     0xc0eea4: bl              #0x7dece8  ; [package:reactive_forms/src/models/models.dart] FormGroup::control
    // 0xc0eea8: r1 = LoadClassIdInstr(r0)
    //     0xc0eea8: ldur            x1, [x0, #-1]
    //     0xc0eeac: ubfx            x1, x1, #0xc, #0x14
    // 0xc0eeb0: cmp             x1, #0x2b5
    // 0xc0eeb4: b.ne            #0xc0eed8
    // 0xc0eeb8: LoadField: r2 = r0->field_2b
    //     0xc0eeb8: ldur            w2, [x0, #0x2b]
    // 0xc0eebc: DecompressPointer r2
    //     0xc0eebc: add             x2, x2, HEAP, lsl #32
    // 0xc0eec0: cmp             w2, NULL
    // 0xc0eec4: b.eq            #0xc0f160
    // 0xc0eec8: r1 = <String, Object?>
    //     0xc0eec8: add             x1, PP, #8, lsl #12  ; [pp+0x8ee8] TypeArguments: <String, Object?>
    //     0xc0eecc: ldr             x1, [x1, #0xee8]
    // 0xc0eed0: r0 = LinkedHashMap.from()
    //     0xc0eed0: bl              #0x718cac  ; [dart:collection] LinkedHashMap::LinkedHashMap.from
    // 0xc0eed4: b               #0xc0eee8
    // 0xc0eed8: LoadField: r1 = r0->field_2b
    //     0xc0eed8: ldur            w1, [x0, #0x2b]
    // 0xc0eedc: DecompressPointer r1
    //     0xc0eedc: add             x1, x1, HEAP, lsl #32
    // 0xc0eee0: cmp             w1, NULL
    // 0xc0eee4: b.eq            #0xc0f144
    // 0xc0eee8: ldur            x1, [fp, #-0x10]
    // 0xc0eeec: r0 = unfocus()
    //     0xc0eeec: bl              #0x10b6c44  ; [package:reactive_forms/src/models/models.dart] AbstractControl::unfocus
    // 0xc0eef0: r16 = <SignInBloc>
    //     0xc0eef0: add             x16, PP, #0x28, lsl #12  ; [pp+0x289f0] TypeArguments: <SignInBloc>
    //     0xc0eef4: ldr             x16, [x16, #0x9f0]
    // 0xc0eef8: ldur            lr, [fp, #-8]
    // 0xc0eefc: stp             lr, x16, [SP]
    // 0xc0ef00: r4 = const [0x1, 0x1, 0x1, 0x1, null]
    //     0xc0ef00: ldr             x4, [PP, #0xf28]  ; [pp+0xf28] List(5) [0x1, 0x1, 0x1, 0x1, Null]
    // 0xc0ef04: r0 = ReadContext.read()
    //     0xc0ef04: bl              #0x7a4edc  ; [package:provider/src/provider.dart] ::ReadContext.read
    // 0xc0ef08: ldur            x1, [fp, #-0x10]
    // 0xc0ef0c: r2 = "username"
    //     0xc0ef0c: add             x2, PP, #0x1d, lsl #12  ; [pp+0x1df30] "username"
    //     0xc0ef10: ldr             x2, [x2, #0xf30]
    // 0xc0ef14: stur            x0, [fp, #-8]
    // 0xc0ef18: r0 = control()
    //     0xc0ef18: bl              #0x7dece8  ; [package:reactive_forms/src/models/models.dart] FormGroup::control
    // ... (username/password extraction repeats the same LinkedHashMap/UnmodifiableMapView/
    //      IsType_String_Stub dance three more times -- reactive_forms' AbstractControl.value is
    //      typed `Object?`, so every read is runtime-checked before being trusted as a String) ...
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
    // 0xc0f144: r0 = Null
    //     0xc0f144: mov             x0, NULL
    // 0xc0f148: LeaveFrame
    //     0xc0f148: mov             SP, fp
    //     0xc0f14c: ldp             fp, lr, [SP], #0x10
    // 0xc0f150: ret
    //     0xc0f150: ret
    // 0xc0f154: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xc0f154: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xc0f158: b               #0xc0ee48
    // 0xc0f15c: r0 = NullCastErrorSharedWithoutFPURegs()
    //     0xc0f15c: bl              #0x10cc5d4  ; NullCastErrorSharedWithoutFPURegsStub
    // 0xc0f160: r0 = NullCastErrorSharedWithoutFPURegs()
    //     0xc0f160: bl              #0x10cc5d4  ; NullCastErrorSharedWithoutFPURegsStub
    // 0xc0f164: r0 = NullCastErrorSharedWithoutFPURegs()
    //     0xc0f164: bl              #0x10cc5d4  ; NullCastErrorSharedWithoutFPURegsStub
    // 0xc0f168: r0 = NullCastErrorSharedWithoutFPURegs()
    //     0xc0f168: bl              #0x10cc5d4  ; NullCastErrorSharedWithoutFPURegsStub
    // 0xc0f16c: r0 = NullCastErrorSharedWithoutFPURegs()
    //     0xc0f16c: bl              #0x10cc5d4  ; NullCastErrorSharedWithoutFPURegsStub
  }
}
