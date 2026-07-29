// lib: , url: package:classeviva/core/misc/constants/const_link.dart

// class id: 1048767, size: 0x8
class :: {
}

// class id: 8378, size: 0x8, field offset: 0x8
abstract class ConstLink extends Object {

  static String getLoginWebUrl() {
    // ** addr: 0xc02aa0, size: 0xe4
    // 0xc02aa0: EnterFrame
    //     0xc02aa0: stp             fp, lr, [SP, #-0x10]!
    //     0xc02aa4: mov             fp, SP
    // 0xc02aa8: AllocStack(0x18)
    //     0xc02aa8: sub             SP, SP, #0x18
    // 0xc02aac: CheckStackOverflow
    //     0xc02aac: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xc02ab0: cmp             SP, x16
    //     0xc02ab4: b.ls            #0xc02b7c
    // 0xc02ab8: r1 = Null
    //     0xc02ab8: mov             x1, NULL
    // 0xc02abc: r2 = 12
    //     0xc02abc: movz            x2, #0xc
    // 0xc02ac0: r0 = AllocateArray()
    //     0xc02ac0: bl              #0x10cbe44  ; AllocateArrayStub
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
    // 0xc02b30: mov             x1, x0
    // 0xc02b34: ldur            x0, [fp, #-8]
    // 0xc02b38: LoadField: r2 = r0->field_f
    //     0xc02b38: ldur            w2, [x0, #0xf]
    // 0xc02b3c: DecompressPointer r2
    //     0xc02b3c: add             x2, x2, HEAP, lsl #32
    // 0xc02b40: cmp             w2, w1
    // 0xc02b44: b.ne            #0xc02b50
    // 0xc02b48: r0 = Null
    //     0xc02b48: mov             x0, NULL
    // 0xc02b4c: b               #0xc02b54
    // 0xc02b50: mov             x0, x1
    // 0xc02b54: cmp             w0, NULL
    // 0xc02b58: b.ne            #0xc02b60
    // 0xc02b5c: r0 = ""
    //     0xc02b5c: ldr             x0, [PP, #0x8b0]  ; [pp+0x8b0] ""
    // 0xc02b60: r16 = "home/app/default/login.php\?target=&mode="
    //     0xc02b60: add             x16, PP, #0x36, lsl #12  ; [pp+0x36a28] "home/app/default/login.php\?target=&mode="
    //     0xc02b64: ldr             x16, [x16, #0xa28]
    // 0xc02b68: stp             x16, x0, [SP]
    // 0xc02b6c: r0 = +()
    //     0xc02b6c: bl              #0x6e45ac  ; [dart:core] _StringBase::+
    // 0xc02b70: LeaveFrame
    //     0xc02b70: mov             SP, fp
    //     0xc02b74: ldp             fp, lr, [SP], #0x10
    // 0xc02b78: ret
    //     0xc02b78: ret
    // 0xc02b7c: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xc02b7c: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xc02b80: b               #0xc02ab8
  }
  static _ getSpidUrl(/* No info */) {
    // ** addr: 0xc0ebbc, size: 0xd8
    // 0xc0ebbc: EnterFrame
    //     0xc0ebbc: stp             fp, lr, [SP, #-0x10]!
    //     0xc0ebc0: mov             fp, SP
    // 0xc0ebc4: AllocStack(0x18)
    //     0xc0ebc4: sub             SP, SP, #0x18
    // 0xc0ebc8: SetupParameters(dynamic _ /* r1 => r0, fp-0x8 */)
    //     0xc0ebc8: mov             x0, x1
    //     0xc0ebcc: stur            x1, [fp, #-8]
    // 0xc0ebd0: CheckStackOverflow
    //     0xc0ebd0: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xc0ebd4: cmp             SP, x16
    //     0xc0ebd8: b.ls            #0xc0ec8c
    // 0xc0ebdc: r1 = Null
    //     0xc0ebdc: mov             x1, NULL
    // 0xc0ebe0: r2 = 12
    //     0xc0ebe0: movz            x2, #0xc
    // 0xc0ebe4: r0 = AllocateArray()
    //     0xc0ebe4: bl              #0x10cbe44  ; AllocateArrayStub
    // 0xc0ebe8: r16 = Instance_ServerNation
    //     0xc0ebe8: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dc88] Obj!ServerNation@1196871
    //     0xc0ebec: ldr             x16, [x16, #0xc88]
    // 0xc0ebf0: StoreField: r0->field_f = r16
    //     0xc0ebf0: stur            w16, [x0, #0xf]
    // 0xc0ebf4: r16 = "https://web.spaggiari.eu/"
    //     0xc0ebf4: add             x16, PP, #8, lsl #12  ; [pp+0x8380] "https://web.spaggiari.eu/"
    //     0xc0ebf8: ldr             x16, [x16, #0x380]
    // 0xc0ebfc: StoreField: r0->field_13 = r16
    //     0xc0ebfc: stur            w16, [x0, #0x13]
    // 0xc0ec00: r16 = Instance_ServerNation
    //     0xc0ec00: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dc98] Obj!ServerNation@1196831
    //     0xc0ec04: ldr             x16, [x16, #0xc98]
    // 0xc0ec08: ArrayStore: r0[0] = r16  ; List_4
    //     0xc0ec08: stur            w16, [x0, #0x17]
    // 0xc0ec0c: r16 = "https://ar.spaggiari.eu/"
    //     0xc0ec0c: add             x16, PP, #8, lsl #12  ; [pp+0x8388] "https://ar.spaggiari.eu/"
    //     0xc0ec10: ldr             x16, [x16, #0x388]
    // 0xc0ec14: StoreField: r0->field_1b = r16
    //     0xc0ec14: stur            w16, [x0, #0x1b]
    // 0xc0ec18: r16 = Instance_ServerNation
    //     0xc0ec18: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dc90] Obj!ServerNation@1196851
    //     0xc0ec1c: ldr             x16, [x16, #0xc90]
    // 0xc0ec20: StoreField: r0->field_1f = r16
    //     0xc0ec20: stur            w16, [x0, #0x1f]
    // 0xc0ec24: r16 = "https://web.spaggiari.sm/"
    //     0xc0ec24: add             x16, PP, #8, lsl #12  ; [pp+0x8390] "https://web.spaggiari.sm/"
    //     0xc0ec28: ldr             x16, [x16, #0x390]
    // 0xc0ec2c: StoreField: r0->field_23 = r16
    //     0xc0ec2c: stur            w16, [x0, #0x23]
    // 0xc0ec30: r16 = <ServerNation, String>
    //     0xc0ec30: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dfc0] TypeArguments: <ServerNation, String>
    //     0xc0ec34: ldr             x16, [x16, #0xfc0]
    // 0xc0ec38: stp             x0, x16, [SP]
    // 0xc0ec3c: r0 = Map._fromLiteral()
    //     0xc0ec3c: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
    // 0xc0ec40: r1 = LoadClassIdInstr(r0)
    //     0xc0ec40: ldur            x1, [x0, #-1]
    //     0xc0ec44: ubfx            x1, x1, #0xc, #0x14
    // 0xc0ec48: mov             x16, x0
    // 0xc0ec4c: mov             x0, x1
    // 0xc0ec50: mov             x1, x16
    // 0xc0ec54: ldur            x2, [fp, #-8]
    // 0xc0ec58: r0 = GDT[cid_x0 + -0xd73]()
    //     0xc0ec58: sub             lr, x0, #0xd73
    //     0xc0ec5c: ldr             lr, [x21, lr, lsl #3]
    //     0xc0ec60: blr             lr
    // 0xc0ec64: cmp             w0, NULL
    // 0xc0ec68: b.ne            #0xc0ec70
    // 0xc0ec6c: r0 = ""
    //     0xc0ec6c: ldr             x0, [PP, #0x8b0]  ; [pp+0x8b0] ""
    // 0xc0ec70: r16 = "/home/app/default/login_spid.php\?mob=on"
    //     0xc0ec70: add             x16, PP, #0x36, lsl #12  ; [pp+0x36918] "/home/app/default/login_spid.php\?mob=on"
    //     0xc0ec74: ldr             x16, [x16, #0x918]
    // 0xc0ec78: stp             x16, x0, [SP]
    // 0xc0ec7c: r0 = +()
    //     0xc0ec7c: bl              #0x6e45ac  ; [dart:core] _StringBase::+
    // 0xc0ec80: LeaveFrame
    //     0xc0ec80: mov             SP, fp
    //     0xc0ec84: ldp             fp, lr, [SP], #0x10
    // 0xc0ec88: ret
    //     0xc0ec88: ret
    // 0xc0ec8c: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xc0ec8c: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xc0ec90: b               #0xc0ebdc
  }
}
