// lib: , url: package:login_flutter/services/network/jto/login/login_response_jto.dart
//
// NOTE: trimmed for this case study. The original dump runs to 967 lines; cut here is the
// toString()/hashCode/== boilerplate for _LoginResponseJTO (same shape as every other
// freezed/json_serializable model already excerpted elsewhere in this vault) — kept is the full
// fromJson/toJson pair, which is the part that actually shows the response's field names.

// class id: 1050907, size: 0x8
class :: {

  static _ _$LoginResponseJTOFromJson(/* No info */) {
    // ** addr: 0x724e68, size: 0x3b8
    // 0x724e68: EnterFrame
    //     0x724e68: stp             fp, lr, [SP, #-0x10]!
    //     0x724e6c: mov             fp, SP
    // 0x724e70: AllocStack(0x40)
    //     0x724e70: sub             SP, SP, #0x40
    // 0x724e74: SetupParameters(dynamic _ /* r1 => r3, fp-0x8 */)
    //     0x724e74: mov             x3, x1
    //     0x724e78: stur            x1, [fp, #-8]
    // 0x724e7c: CheckStackOverflow
    //     0x724e7c: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x724e80: cmp             SP, x16
    //     0x724e84: b.ls            #0x725218
    // 0x724e88: r0 = LoadClassIdInstr(r3)
    //     0x724e88: ldur            x0, [x3, #-1]
    //     0x724e8c: ubfx            x0, x0, #0xc, #0x14
    // 0x724e90: mov             x1, x3
    // 0x724e94: r2 = "ident"
    //     0x724e94: add             x2, PP, #0x11, lsl #12  ; [pp+0x11b20] "ident"
    //     0x724e98: ldr             x2, [x2, #0xb20]
    // 0x724e9c: r0 = GDT[cid_x0 + -0xd73]()   ; virtual call: Map<String,dynamic>.[]("ident")
    //     0x724e9c: sub             lr, x0, #0xd73
    //     0x724ea0: ldr             lr, [x21, lr, lsl #3]
    //     0x724ea4: blr             lr
    // 0x724ea8: mov             x3, x0
    // 0x724eac: r2 = Null
    //     0x724eac: mov             x2, NULL
    // 0x724eb0: r1 = Null
    //     0x724eb0: mov             x1, NULL
    // 0x724eb4: stur            x3, [fp, #-0x10]
    // 0x724eb8: r4 = 60
    //     0x724eb8: movz            x4, #0x3c
    // 0x724ebc: branchIfSmi(r0, 0x724ec8)
    //     0x724ebc: tbz             w0, #0, #0x724ec8
    // 0x724ec0: r4 = LoadClassIdInstr(r0)
    //     0x724ec0: ldur            x4, [x0, #-1]
    //     0x724ec4: ubfx            x4, x4, #0xc, #0x14
    // 0x724ec8: sub             x4, x4, #0x5e
    // 0x724ecc: cmp             x4, #1
    // 0x724ed0: b.ls            #0x724ee4
    // 0x724ed4: r8 = String
    //     0x724ed4: ldr             x8, [PP, #0x928]  ; [pp+0x928] Type: String
    // 0x724ed8: r3 = Null
    //     0x724ed8: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e168] Null
    //     0x724edc: ldr             x3, [x3, #0x168]
    // 0x724ee0: r0 = String()
    //     0x724ee0: bl              #0x10f70dc  ; IsType_String_Stub   ; ident must be a non-null String
    // 0x724ee4: ldur            x3, [fp, #-8]
    // 0x724ee8: r0 = LoadClassIdInstr(r3)
    //     0x724ee8: ldur            x0, [x3, #-1]
    //     0x724eec: ubfx            x0, x0, #0xc, #0x14
    // 0x724ef0: mov             x1, x3
    // 0x724ef4: r2 = "firstName"
    //     0x724ef4: add             x2, PP, #0x1e, lsl #12  ; [pp+0x1e178] "firstName"
    //     0x724ef8: ldr             x2, [x2, #0x178]
    // 0x724efc: r0 = GDT[cid_x0 + -0xd73]()
    //     0x724efc: sub             lr, x0, #0xd73
    //     0x724f00: ldr             lr, [x21, lr, lsl #3]
    //     0x724f04: blr             lr
    // 0x724f08: mov             x3, x0
    // 0x724f0c: r2 = Null
    //     0x724f0c: mov             x2, NULL
    // 0x724f10: r1 = Null
    //     0x724f10: mov             x1, NULL
    // 0x724f14: stur            x3, [fp, #-0x18]
    // 0x724f18: r4 = 60
    //     0x724f18: movz            x4, #0x3c
    // 0x724f1c: branchIfSmi(r0, 0x724f28)
    //     0x724f1c: tbz             w0, #0, #0x724f28
    // 0x724f20: r4 = LoadClassIdInstr(r0)
    //     0x724f20: ldur            x4, [x0, #-1]
    //     0x724f24: ubfx            x4, x4, #0xc, #0x14
    // 0x724f28: sub             x4, x4, #0x5e
    // 0x724f2c: cmp             x4, #1
    // 0x724f30: b.ls            #0x724f44
    // 0x724f34: r8 = String?
    //     0x724f34: ldr             x8, [PP, #0x100]  ; [pp+0x100] Type: String?
    // 0x724f38: r3 = Null
    //     0x724f38: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e180] Null
    //     0x724f3c: ldr             x3, [x3, #0x180]
    // 0x724f40: r0 = String?()
    //     0x724f40: bl              #0x6d76ac  ; IsType_String?_Stub   ; firstName is nullable
    // 0x724f44: ldur            x3, [fp, #-8]
    // 0x724f48: r0 = LoadClassIdInstr(r3)
    //     0x724f48: ldur            x0, [x3, #-1]
    //     0x724f4c: ubfx            x0, x0, #0xc, #0x14
    // 0x724f50: mov             x1, x3
    // 0x724f54: r2 = "lastName"
    //     0x724f54: add             x2, PP, #0x1e, lsl #12  ; [pp+0x1e190] "lastName"
    //     0x724f58: ldr             x2, [x2, #0x190]
    // 0x724f5c: r0 = GDT[cid_x0 + -0xd73]()
    //     0x724f5c: sub             lr, x0, #0xd73
    //     0x724f60: ldr             lr, [x21, lr, lsl #3]
    //     0x724f64: blr             lr
    // 0x724f68: mov             x3, x0
    // 0x724f6c: r2 = Null
    //     0x724f6c: mov             x2, NULL
    // 0x724f70: r1 = Null
    //     0x724f70: mov             x1, NULL
    // 0x724f74: stur            x3, [fp, #-0x20]
    // 0x724f78: r4 = 60
    //     0x724f78: movz            x4, #0x3c
    // 0x724f7c: branchIfSmi(r0, 0x724f88)
    //     0x724f7c: tbz             w0, #0, #0x724f88
    // 0x724f80: r4 = LoadClassIdInstr(r0)
    //     0x724f80: ldur            x4, [x0, #-1]
    //     0x724f84: ubfx            x4, x4, #0xc, #0x14
    // 0x724f88: sub             x4, x4, #0x5e
    // 0x724f8c: cmp             x4, #1
    // 0x724f90: b.ls            #0x724fa4
    // 0x724f94: r8 = String?
    //     0x724f94: ldr             x8, [PP, #0x100]  ; [pp+0x100] Type: String?
    // 0x724f98: r3 = Null
    //     0x724f98: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e198] Null
    //     0x724f9c: ldr             x3, [x3, #0x198]
    // 0x724fa0: r0 = String?()
    //     0x724fa0: bl              #0x6d76ac  ; IsType_String?_Stub
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
    // 0x724fcc: r2 = Null
    //     0x724fcc: mov             x2, NULL
    // 0x724fd0: r1 = Null
    //     0x724fd0: mov             x1, NULL
    // 0x724fd4: stur            x3, [fp, #-0x28]
    // 0x724fd8: r4 = 60
    //     0x724fd8: movz            x4, #0x3c
    // 0x724fdc: branchIfSmi(r0, 0x724fe8)
    //     0x724fdc: tbz             w0, #0, #0x724fe8
    // 0x724fe0: r4 = LoadClassIdInstr(r0)
    //     0x724fe0: ldur            x4, [x0, #-1]
    //     0x724fe4: ubfx            x4, x4, #0xc, #0x14
    // 0x724fe8: sub             x4, x4, #0x5e
    // 0x724fec: cmp             x4, #1
    // 0x724ff0: b.ls            #0x725004
    // 0x724ff4: r8 = String
    //     0x724ff4: ldr             x8, [PP, #0x928]  ; [pp+0x928] Type: String
    // 0x724ff8: r3 = Null
    //     0x724ff8: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e1a8] Null
    //     0x724ffc: ldr             x3, [x3, #0x1a8]
    // 0x725000: r0 = String()
    //     0x725000: bl              #0x10f70dc  ; IsType_String_Stub   ; token must be a non-null String
    // 0x725004: ldur            x3, [fp, #-8]
    // 0x725008: r0 = LoadClassIdInstr(r3)
    //     0x725008: ldur            x0, [x3, #-1]
    //     0x72500c: ubfx            x0, x0, #0xc, #0x14
    // 0x725010: mov             x1, x3
    // 0x725014: r2 = "tokenAP"
    //     0x725014: add             x2, PP, #0x1e, lsl #12  ; [pp+0x1e1b8] "tokenAP"
    //     0x725018: ldr             x2, [x2, #0x1b8]
    // 0x72501c: r0 = GDT[cid_x0 + -0xd73]()
    //     0x72501c: sub             lr, x0, #0xd73
    //     0x725020: ldr             lr, [x21, lr, lsl #3]
    //     0x725024: blr             lr
    // 0x725028: mov             x3, x0
    // 0x72502c: r2 = Null
    //     0x72502c: mov             x2, NULL
    // 0x725030: r1 = Null
    //     0x725030: mov             x1, NULL
    // 0x725034: stur            x3, [fp, #-0x30]
    // 0x725038: r4 = 60
    //     0x725038: movz            x4, #0x3c
    // 0x72503c: branchIfSmi(r0, 0x725048)
    //     0x72503c: tbz             w0, #0, #0x725048
    // 0x725040: r4 = LoadClassIdInstr(r0)
    //     0x725040: ldur            x4, [x0, #-1]
    //     0x725044: ubfx            x4, x4, #0xc, #0x14
    // 0x725048: sub             x4, x4, #0x5e
    // 0x72504c: cmp             x4, #1
    // 0x725050: b.ls            #0x725064
    // 0x725054: r8 = String?
    //     0x725054: ldr             x8, [PP, #0x100]  ; [pp+0x100] Type: String?
    // 0x725058: r3 = Null
    //     0x725058: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e1c0] Null
    //     0x72505c: ldr             x3, [x3, #0x1c0]
    // 0x725060: r0 = String?()
    //     0x725060: bl              #0x6d76ac  ; IsType_String?_Stub
    // 0x725064: ldur            x0, [fp, #-0x30]
    // 0x725068: cmp             w0, NULL
    // 0x72506c: b.ne            #0x725078
    // 0x725070: r8 = ""
    //     0x725070: ldr             x8, [PP, #0x8b0]  ; [pp+0x8b0] ""   ; tokenAP defaults to "" if absent
    // 0x725074: b               #0x72507c
    // 0x725078: mov             x8, x0
    // 0x72507c: ldur            x3, [fp, #-8]
    // 0x725080: ldur            x7, [fp, #-0x10]
    // 0x725084: ldur            x6, [fp, #-0x18]
    // 0x725088: ldur            x5, [fp, #-0x20]
    // 0x72508c: ldur            x4, [fp, #-0x28]
    // 0x725090: stur            x8, [fp, #-0x30]
    // 0x725094: r0 = LoadClassIdInstr(r3)
    //     0x725094: ldur            x0, [x3, #-1]
    //     0x725098: ubfx            x0, x0, #0xc, #0x14
    // 0x72509c: mov             x1, x3
    // 0x7250a0: r2 = "release"
    //     0x7250a0: add             x2, PP, #0x1e, lsl #12  ; [pp+0x1e1d0] "release"
    //     0x7250a4: ldr             x2, [x2, #0x1d0]
    // 0x7250a8: r0 = GDT[cid_x0 + -0xd73]()
    //     0x7250a8: sub             lr, x0, #0xd73
    //     0x7250ac: ldr             lr, [x21, lr, lsl #3]
    //     0x7250b0: blr             lr
    // 0x7250b4: mov             x3, x0
    // 0x7250b8: r2 = Null
    //     0x7250b8: mov             x2, NULL
    // 0x7250bc: r1 = Null
    //     0x7250bc: mov             x1, NULL
    // 0x7250c0: stur            x3, [fp, #-0x38]
    // 0x7250c4: r4 = 60
    //     0x7250c4: movz            x4, #0x3c
    // 0x7250c8: branchIfSmi(r0, 0x7250d4)
    //     0x7250c8: tbz             w0, #0, #0x7250d4
    // 0x7250cc: r4 = LoadClassIdInstr(r0)
    //     0x7250cc: ldur            x4, [x0, #-1]
    //     0x7250d0: ubfx            x4, x4, #0xc, #0x14
    // 0x7250d4: sub             x4, x4, #0x5e
    // 0x7250d8: cmp             x4, #1
    // 0x7250dc: b.ls            #0x7250f0
    // 0x7250e0: r8 = String
    //     0x7250e0: ldr             x8, [PP, #0x928]  ; [pp+0x928] Type: String
    // 0x7250e4: r3 = Null
    //     0x7250e4: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e1d8] Null
    //     0x7250e8: ldr             x3, [x3, #0x1d8]
    // 0x7250ec: r0 = String()
    //     0x7250ec: bl              #0x10f70dc  ; IsType_String_Stub
    // 0x7250f0: ldur            x1, [fp, #-0x38]
    // 0x7250f4: r0 = parse()
    //     0x7250f4: bl              #0x7226d0  ; [dart:core] DateTime::parse   ; "release" is an ISO-8601 string on the wire, a real DateTime once parsed
    // 0x7250f8: mov             x4, x0
    // 0x7250fc: ldur            x3, [fp, #-8]
    // 0x725100: stur            x4, [fp, #-0x38]
    // 0x725104: r0 = LoadClassIdInstr(r3)
    //     0x725104: ldur            x0, [x3, #-1]
    //     0x725108: ubfx            x0, x0, #0xc, #0x14
    // 0x72510c: mov             x1, x3
    // 0x725110: r2 = "expire"
    //     0x725110: add             x2, PP, #0x1e, lsl #12  ; [pp+0x1e1e8] "expire"
    //     0x725114: ldr             x2, [x2, #0x1e8]
    // 0x725118: r0 = GDT[cid_x0 + -0xd73]()
    //     0x725118: sub             lr, x0, #0xd73
    //     0x72511c: ldr             lr, [x21, lr, lsl #3]
    //     0x725120: blr             lr
    // 0x725124: mov             x3, x0
    // 0x725128: r2 = Null
    //     0x725128: mov             x2, NULL
    // 0x72512c: r1 = Null
    //     0x72512c: mov             x1, NULL
    // 0x725130: stur            x3, [fp, #-0x40]
    // 0x725134: r4 = 60
    //     0x725134: movz            x4, #0x3c
    // 0x725138: branchIfSmi(r0, 0x725144)
    //     0x725138: tbz             w0, #0, #0x725144
    // 0x72513c: r4 = LoadClassIdInstr(r0)
    //     0x72513c: ldur            x4, [x0, #-1]
    //     0x725140: ubfx            x4, x4, #0xc, #0x14
    // 0x725144: sub             x4, x4, #0x5e
    // 0x725148: cmp             x4, #1
    // 0x72514c: b.ls            #0x725160
    // 0x725150: r8 = String
    //     0x725150: ldr             x8, [PP, #0x928]  ; [pp+0x928] Type: String
    // 0x725154: r3 = Null
    //     0x725154: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e1f0] Null
    //     0x725158: ldr             x3, [x3, #0x1f0]
    // 0x72515c: r0 = String()
    //     0x72515c: bl              #0x10f70dc  ; IsType_String_Stub
    // 0x725160: ldur            x1, [fp, #-0x40]
    // 0x725164: r0 = parse()
    //     0x725164: bl              #0x7226d0  ; [dart:core] DateTime::parse   ; "expire" -- when this session token stops being valid
    // 0x725168: mov             x3, x0
    // 0x72516c: ldur            x1, [fp, #-8]
    // 0x725170: stur            x3, [fp, #-0x40]
    // 0x725174: r0 = LoadClassIdInstr(r1)
    //     0x725174: ldur            x0, [x1, #-1]
    //     0x725178: ubfx            x0, x0, #0xc, #0x14
    // 0x72517c: r2 = "showPwdChangeReminder"
    //     0x72517c: add             x2, PP, #0x1e, lsl #12  ; [pp+0x1e200] "showPwdChangeReminder"
    //     0x725180: ldr             x2, [x2, #0x200]
    // 0x725184: r0 = GDT[cid_x0 + -0xd73]()
    //     0x725184: sub             lr, x0, #0xd73
    //     0x725188: ldr             lr, [x21, lr, lsl #3]
    //     0x72518c: blr             lr
    // 0x725190: mov             x3, x0
    // 0x725194: r2 = Null
    //     0x725194: mov             x2, NULL
    // 0x725198: r1 = Null
    //     0x725198: mov             x1, NULL
    // 0x72519c: stur            x3, [fp, #-8]
    // 0x7251a0: r4 = 60
    //     0x7251a0: movz            x4, #0x3c
    // 0x7251a4: branchIfSmi(r0, 0x7251b0)
    //     0x7251a4: tbz             w0, #0, #0x7251b0
    // 0x7251a8: r4 = LoadClassIdInstr(r0)
    //     0x7251a8: ldur            x4, [x0, #-1]
    //     0x7251ac: ubfx            x4, x4, #0xc, #0x14
    // 0x7251b0: cmp             x4, #0x3f
    // 0x7251b4: b.eq            #0x7251c8
    // 0x7251b8: r8 = bool?
    //     0x7251b8: ldr             x8, [PP, #0x5878]  ; [pp+0x5878] Type: bool?
    // 0x7251bc: r3 = Null
    //     0x7251bc: add             x3, PP, #0x1e, lsl #12  ; [pp+0x1e208] Null
    //     0x7251c0: ldr             x3, [x3, #0x208]
    // 0x7251c4: r0 = bool?()
    //     0x7251c4: bl              #0x6efd40  ; IsType_bool?_Stub
    // 0x7251c8: r0 = _LoginResponseJTO()
    //     0x7251c8: bl              #0x725220  ; Allocate_LoginResponseJTOStub -> _LoginResponseJTO (size=0x28)
    // 0x7251cc: ldur            x1, [fp, #-0x10]
    // 0x7251d0: StoreField: r0->field_7 = r1
    //     0x7251d0: stur            w1, [x0, #7]
    // 0x7251d4: ldur            x1, [fp, #-0x18]
    // 0x7251d8: StoreField: r0->field_b = r1
    //     0x7251d8: stur            w1, [x0, #0xb]
    // 0x7251dc: ldur            x1, [fp, #-0x20]
    // 0x7251e0: StoreField: r0->field_f = r1
    //     0x7251e0: stur            w1, [x0, #0xf]
    // 0x7251e4: ldur            x1, [fp, #-0x28]
    // 0x7251e8: StoreField: r0->field_13 = r1
    //     0x7251e8: stur            w1, [x0, #0x13]
    // 0x7251ec: ldur            x1, [fp, #-0x30]
    // 0x7251f0: ArrayStore: r0[0] = r1  ; List_4
    //     0x7251f0: stur            w1, [x0, #0x17]
    // 0x7251f4: ldur            x1, [fp, #-0x38]
    // 0x7251f8: StoreField: r0->field_1b = r1
    //     0x7251f8: stur            w1, [x0, #0x1b]
    // 0x7251fc: ldur            x1, [fp, #-0x40]
    // 0x725200: StoreField: r0->field_1f = r1
    //     0x725200: stur            w1, [x0, #0x1f]
    // 0x725204: ldur            x1, [fp, #-8]
    // 0x725208: StoreField: r0->field_23 = r1
    //     0x725208: stur            w1, [x0, #0x23]
    // 0x72520c: LeaveFrame
    //     0x72520c: mov             SP, fp
    //     0x725210: ldp             fp, lr, [SP], #0x10
    // 0x725214: ret
    //     0x725214: ret
    // 0x725218: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x725218: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x72521c: b               #0x724e88
  }
  static _ _$LoginResponseJTOToJson(/* No info */) {
    // ** addr: 0x725274, size: 0x174
    // 0x725274: EnterFrame
    //     0x725274: stp             fp, lr, [SP, #-0x10]!
    //     0x725278: mov             fp, SP
    // 0x72527c: AllocStack(0x20)
    //     0x72527c: sub             SP, SP, #0x20
    // 0x725280: SetupParameters(dynamic _ /* r1 => r0, fp-0x8 */)
    //     0x725280: mov             x0, x1
    //     0x725284: stur            x1, [fp, #-8]
    // 0x725288: CheckStackOverflow
    //     0x725288: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x72528c: cmp             SP, x16
    //     0x725290: b.ls            #0x7253e0
    // 0x725294: r1 = Null
    //     0x725294: mov             x1, NULL
    // 0x725298: r2 = 32
    //     0x725298: movz            x2, #0x20
    // 0x72529c: r0 = AllocateArray()
    //     0x72529c: bl              #0x10cbe44  ; AllocateArrayStub
    // 0x7252a0: stur            x0, [fp, #-0x10]
    // 0x7252a4: r16 = "ident"
    //     0x7252a4: add             x16, PP, #0x11, lsl #12  ; [pp+0x11b20] "ident"
    //     0x7252a8: ldr             x16, [x16, #0xb20]
    // 0x7252ac: StoreField: r0->field_f = r16
    //     0x7252ac: stur            w16, [x0, #0xf]
    // 0x7252b0: ldur            x2, [fp, #-8]
    // 0x7252b4: LoadField: r1 = r2->field_7
    //     0x7252b4: ldur            w1, [x2, #7]
    // 0x7252b8: DecompressPointer r1
    //     0x7252b8: add             x1, x1, HEAP, lsl #32
    // 0x7252bc: StoreField: r0->field_13 = r1
    //     0x7252bc: stur            w1, [x0, #0x13]
    // 0x7252c0: r16 = "firstName"
    //     0x7252c0: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e178] "firstName"
    //     0x7252c4: ldr             x16, [x16, #0x178]
    // 0x7252c8: ArrayStore: r0[0] = r16  ; List_4
    //     0x7252c8: stur            w16, [x0, #0x17]
    // 0x7252cc: LoadField: r1 = r2->field_b
    //     0x7252cc: ldur            w1, [x2, #0xb]
    // 0x7252d0: DecompressPointer r1
    //     0x7252d0: add             x1, x1, HEAP, lsl #32
    // 0x7252d4: StoreField: r0->field_1b = r1
    //     0x7252d4: stur            w1, [x0, #0x1b]
    // 0x7252d8: r16 = "lastName"
    //     0x7252d8: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e190] "lastName"
    //     0x7252dc: ldr             x16, [x16, #0x190]
    // 0x7252e0: StoreField: r0->field_1f = r16
    //     0x7252e0: stur            w16, [x0, #0x1f]
    // 0x7252e4: LoadField: r1 = r2->field_f
    //     0x7252e4: ldur            w1, [x2, #0xf]
    // 0x7252e8: DecompressPointer r1
    //     0x7252e8: add             x1, x1, HEAP, lsl #32
    // 0x7252ec: StoreField: r0->field_23 = r1
    //     0x7252ec: stur            w1, [x0, #0x23]
    // 0x7252f0: r16 = "token"
    //     0x7252f0: add             x16, PP, #0xb, lsl #12  ; [pp+0xb290] "token"
    //     0x7252f4: ldr             x16, [x16, #0x290]
    // 0x7252f8: StoreField: r0->field_27 = r16
    //     0x7252f8: stur            w16, [x0, #0x27]
    // 0x7252fc: LoadField: r1 = r2->field_13
    //     0x7252fc: ldur            w1, [x2, #0x13]
    // 0x725300: DecompressPointer r1
    //     0x725300: add             x1, x1, HEAP, lsl #32
    // 0x725304: StoreField: r0->field_2b = r1
    //     0x725304: stur            w1, [x0, #0x2b]
    // 0x725308: r16 = "tokenAP"
    //     0x725308: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e1b8] "tokenAP"
    //     0x72530c: ldr             x16, [x16, #0x1b8]
    // 0x725310: StoreField: r0->field_2f = r16
    //     0x725310: stur            w16, [x0, #0x2f]
    // 0x725314: ArrayLoad: r1 = r2[0]  ; List_4
    //     0x725314: ldur            w1, [x2, #0x17]
    // 0x725318: DecompressPointer r1
    //     0x725318: add             x1, x1, HEAP, lsl #32
    // 0x72531c: StoreField: r0->field_33 = r1
    //     0x72531c: stur            w1, [x0, #0x33]
    // 0x725320: r16 = "release"
    //     0x725320: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e1d0] "release"
    //     0x725324: ldr             x16, [x16, #0x1d0]
    // 0x725328: StoreField: r0->field_37 = r16
    //     0x725328: stur            w16, [x0, #0x37]
    // 0x72532c: LoadField: r1 = r2->field_1b
    //     0x72532c: ldur            w1, [x2, #0x1b]
    // 0x725330: DecompressPointer r1
    //     0x725330: add             x1, x1, HEAP, lsl #32
    // 0x725334: r0 = toIso8601String()
    //     0x725334: bl              #0x71e204  ; [dart:core] DateTime::toIso8601String
    // 0x725338: ldur            x1, [fp, #-0x10]
    // 0x72533c: ArrayStore: r1[11] = r0  ; List_4
    //     0x72533c: add             x25, x1, #0x3b
    //     0x725340: str             w0, [x25]
    //     0x725344: tbz             w0, #0, #0x725360
    //     0x725348: ldurb           w16, [x1, #-1]
    //     0x72534c: ldurb           w17, [x0, #-1]
    //     0x725350: and             x16, x17, x16, lsr #2
    //     0x725354: tst             x16, HEAP, lsr #32
    //     0x725358: b.eq            #0x725360
    //     0x72535c: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0x725360: ldur            x0, [fp, #-0x10]
    // 0x725364: r16 = "expire"
    //     0x725364: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e1e8] "expire"
    //     0x725368: ldr             x16, [x16, #0x1e8]
    // 0x72536c: StoreField: r0->field_3f = r16
    //     0x72536c: stur            w16, [x0, #0x3f]
    // 0x725370: ldur            x2, [fp, #-8]
    // 0x725374: LoadField: r1 = r2->field_1f
    //     0x725374: ldur            w1, [x2, #0x1f]
    // 0x725378: DecompressPointer r1
    //     0x725378: add             x1, x1, HEAP, lsl #32
    // 0x72537c: r0 = toIso8601String()
    //     0x72537c: bl              #0x71e204  ; [dart:core] DateTime::toIso8601String
    // 0x725380: ldur            x1, [fp, #-0x10]
    // 0x725384: ArrayStore: r1[13] = r0  ; List_4
    //     0x725384: add             x25, x1, #0x43
    //     0x725388: str             w0, [x25]
    //     0x72538c: tbz             w0, #0, #0x7253a8
    //     0x725390: ldurb           w16, [x1, #-1]
    //     0x725394: ldurb           w17, [x0, #-1]
    //     0x725398: and             x16, x17, x16, lsr #2
    //     0x72539c: tst             x16, HEAP, lsr #32
    //     0x7253a0: b.eq            #0x7253a8
    //     0x7253a4: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0x7253a8: ldur            x0, [fp, #-0x10]
    // 0x7253ac: r16 = "showPwdChangeReminder"
    //     0x7253ac: add             x16, PP, #0x1e, lsl #12  ; [pp+0x1e200] "showPwdChangeReminder"
    //     0x7253b0: ldr             x16, [x16, #0x200]
    // 0x7253b4: StoreField: r0->field_47 = r16
    //     0x7253b4: stur            w16, [x0, #0x47]
    // 0x7253b8: ldur            x1, [fp, #-8]
    // 0x7253bc: LoadField: r2 = r1->field_23
    //     0x7253bc: ldur            w2, [x1, #0x23]
    // 0x7253c0: DecompressPointer r2
    //     0x7253c0: add             x2, x2, HEAP, lsl #32
    // 0x7253c4: StoreField: r0->field_4b = r2
    //     0x7253c4: stur            w2, [x0, #0x4b]
    // 0x7253c8: r16 = <String, dynamic>
    //     0x7253c8: ldr             x16, [PP, #0x2050]  ; [pp+0x2050] TypeArguments: <String, dynamic>
    // 0x7253cc: stp             x0, x16, [SP]
    // 0x7253d0: r0 = Map._fromLiteral()
    //     0x7253d0: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
    // 0x7253d4: LeaveFrame
    //     0x7253d4: mov             SP, fp
    //     0x7253d8: ldp             fp, lr, [SP], #0x10
    // 0x7253dc: ret
    //     0x7253dc: ret
    // 0x7253e0: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x7253e0: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x7253e4: b               #0x725294
  }
}

// class id: 1079, size: 0x8, field offset: 0x8
abstract class _$LoginResponseJTO extends Object {
}

// class id: 7887, size: 0x8, field offset: 0x8
//   const constructor, transformed mixin,
abstract class _LoginResponseJTO&DTO&_$LoginResponseJTO extends DTO
     with _$LoginResponseJTO {
}

// class id: 7888, size: 0x8, field offset: 0x8
//   const constructor,
abstract class LoginResponseJTO extends _LoginResponseJTO&DTO&_$LoginResponseJTO {
}

// class id: 7889, size: 0x28, field offset: 0x8
//   const constructor,
class _LoginResponseJTO extends LoginResponseJTO {

  Map<String, dynamic> toJson(_LoginResponseJTO) {
    // ** addr: 0x725244, size: 0x48
    // 0x725244: EnterFrame
    //     0x725244: stp             fp, lr, [SP, #-0x10]!
    //     0x725248: mov             fp, SP
    // 0x72524c: CheckStackOverflow
    //     0x72524c: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x725250: cmp             SP, x16
    //     0x725254: b.ls            #0x72526c
    // 0x725258: ldr             x1, [fp, #0x10]
    // 0x72525c: r0 = _$LoginResponseJTOToJson()
    //     0x72525c: bl              #0x725274  ; [package:login_flutter/services/network/jto/login/login_response_jto.dart] ::_$LoginResponseJTOToJson
    // 0x725260: LeaveFrame
    //     0x725260: mov             SP, fp
    //     0x725264: ldp             fp, lr, [SP], #0x10
    // 0x725268: ret
    //     0x725268: ret
    // 0x72526c: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x72526c: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x725270: b               #0x725258
  }

  // ... trimmed: toString(), hashCode getter, operator== (structural equality boilerplate).
}
