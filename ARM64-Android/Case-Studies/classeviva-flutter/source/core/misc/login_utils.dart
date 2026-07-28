// lib: , url: package:classeviva/core/misc/login_utils.dart

// class id: 1048777, size: 0x8
class :: {
}

// class id: 8367, size: 0x8, field offset: 0x8
abstract class LoginUtils extends Object {

  static _ getLoginMode(/* No info */) {
    // ** addr: 0x10f1ae8, size: 0xe4
    // 0x10f1ae8: EnterFrame
    //     0x10f1ae8: stp             fp, lr, [SP, #-0x10]!
    //     0x10f1aec: mov             fp, SP
    // 0x10f1af0: AllocStack(0x8)
    //     0x10f1af0: sub             SP, SP, #8
    // 0x10f1af4: r0 = LoadStaticField(0x1214)
    //     0x10f1af4: ldr             x0, [THR, #0x68]  ; THR::field_table_values
    //     0x10f1af8: ldr             x0, [x0, #0x2428]
    //     0x10f1afc: ldr             x16, [PP, #0x6fe0]  ; [pp+0x6fe0] Obj!Flavor@119c2f1
    // 0x10f1b00: cmp             w0, w16
    // 0x10f1b04: b.ne            #0x10f1b64
    // 0x10f1b08: r0 = 4
    //     0x10f1b08: movz            x0, #0x4
    // 0x10f1b0c: mov             x2, x0
    // 0x10f1b10: r1 = Null
    //     0x10f1b10: mov             x1, NULL
    // 0x10f1b14: r0 = AllocateArray()
    //     0x10f1b14: bl              #0x10cbe44  ; AllocateArrayStub
    // 0x10f1b18: stur            x0, [fp, #-8]
    // 0x10f1b1c: r16 = Instance_LoginMode
    //     0x10f1b1c: add             x16, PP, #0xb, lsl #12  ; [pp+0xbc40] Obj!LoginMode@1196951
    //     0x10f1b20: ldr             x16, [x16, #0xc40]
    // 0x10f1b24: StoreField: r0->field_f = r16
    //     0x10f1b24: stur            w16, [x0, #0xf]
    // 0x10f1b28: r16 = Instance_LoginMode
    //     0x10f1b28: add             x16, PP, #0xb, lsl #12  ; [pp+0xbc48] Obj!LoginMode@1196931
    //     0x10f1b2c: ldr             x16, [x16, #0xc48]
    // 0x10f1b30: StoreField: r0->field_13 = r16
    //     0x10f1b30: stur            w16, [x0, #0x13]
    // 0x10f1b34: r1 = <LoginMode>
    //     0x10f1b34: add             x1, PP, #0xb, lsl #12  ; [pp+0xbc50] TypeArguments: <LoginMode>
    //     0x10f1b38: ldr             x1, [x1, #0xc50]
    // 0x10f1b3c: r0 = AllocateGrowableArray()
    //     0x10f1b3c: bl              #0x10cad78  ; AllocateGrowableArrayStub
    // 0x10f1b40: mov             x1, x0
    // 0x10f1b44: ldur            x0, [fp, #-8]
    // 0x10f1b48: StoreField: r1->field_f = r0
    //     0x10f1b48: stur            w0, [x1, #0xf]
    // 0x10f1b4c: r0 = 4
    //     0x10f1b4c: movz            x0, #0x4
    // 0x10f1b50: StoreField: r1->field_b = r0
    //     0x10f1b50: stur            w0, [x1, #0xb]
    // 0x10f1b54: mov             x0, x1
    // 0x10f1b58: LeaveFrame
    //     0x10f1b58: mov             SP, fp
    //     0x10f1b5c: ldp             fp, lr, [SP], #0x10
    // 0x10f1b60: ret
    //     0x10f1b60: ret
    // 0x10f1b64: r16 = Instance_Flavor
    //     0x10f1b64: add             x16, PP, #8, lsl #12  ; [pp+0x83b0] Obj!Flavor@119c2d1
    //     0x10f1b68: ldr             x16, [x16, #0x3b0]
    // 0x10f1b6c: cmp             w0, w16
    // 0x10f1b70: b.ne            #0x10f1bbc
    // 0x10f1b74: r0 = 2
    //     0x10f1b74: movz            x0, #0x2
    // 0x10f1b78: mov             x2, x0
    // 0x10f1b7c: r1 = Null
    //     0x10f1b7c: mov             x1, NULL
    // 0x10f1b80: r0 = AllocateArray()
    //     0x10f1b80: bl              #0x10cbe44  ; AllocateArrayStub
    // 0x10f1b84: stur            x0, [fp, #-8]
    // 0x10f1b88: r16 = Instance_LoginMode
    //     0x10f1b88: add             x16, PP, #0xb, lsl #12  ; [pp+0xbc48] Obj!LoginMode@1196931
    //     0x10f1b8c: ldr             x16, [x16, #0xc48]
    // 0x10f1b90: StoreField: r0->field_f = r16
    //     0x10f1b90: stur            w16, [x0, #0xf]
    // 0x10f1b94: r1 = <LoginMode>
    //     0x10f1b94: add             x1, PP, #0xb, lsl #12  ; [pp+0xbc50] TypeArguments: <LoginMode>
    //     0x10f1b98: ldr             x1, [x1, #0xc50]
    // 0x10f1b9c: r0 = AllocateGrowableArray()
    //     0x10f1b9c: bl              #0x10cad78  ; AllocateGrowableArrayStub
    // 0x10f1ba0: ldur            x1, [fp, #-8]
    // 0x10f1ba4: StoreField: r0->field_f = r1
    //     0x10f1ba4: stur            w1, [x0, #0xf]
    // 0x10f1ba8: r1 = 2
    //     0x10f1ba8: movz            x1, #0x2
    // 0x10f1bac: StoreField: r0->field_b = r1
    //     0x10f1bac: stur            w1, [x0, #0xb]
    // 0x10f1bb0: LeaveFrame
    //     0x10f1bb0: mov             SP, fp
    //     0x10f1bb4: ldp             fp, lr, [SP], #0x10
    // 0x10f1bb8: ret
    //     0x10f1bb8: ret
    // 0x10f1bbc: r0 = Null
    //     0x10f1bbc: mov             x0, NULL
    // 0x10f1bc0: LeaveFrame
    //     0x10f1bc0: mov             SP, fp
    //     0x10f1bc4: ldp             fp, lr, [SP], #0x10
    // 0x10f1bc8: ret
    //     0x10f1bc8: ret
  }
}
