// lib: , url: package:classeviva/core/misc/grade_utils.dart

// class id: 1048775, size: 0x8
class :: {
}

// class id: 8369, size: 0x8, field offset: 0x8
//   const constructor,
abstract class GradeUtils extends Object {

  static _ getAvg(/* No info */) {
    // ** addr: 0xc20cdc, size: 0xf4
    // 0xc20cdc: EnterFrame
    //     0xc20cdc: stp             fp, lr, [SP, #-0x10]!
    //     0xc20ce0: mov             fp, SP
    // 0xc20ce4: AllocStack(0x30)
    //     0xc20ce4: sub             SP, SP, #0x30
    // 0xc20ce8: SetupParameters(dynamic _ /* r1 => r0, fp-0x8 */)
    //     0xc20ce8: mov             x0, x1
    //     0xc20cec: stur            x1, [fp, #-8]
    // 0xc20cf0: CheckStackOverflow
    //     0xc20cf0: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xc20cf4: cmp             SP, x16
    //     0xc20cf8: b.ls            #0xc20dc8
    // 0xc20cfc: r1 = Function '<anonymous closure>': static.
    //     0xc20cfc: add             x1, PP, #0x26, lsl #12  ; [pp+0x263f8] AnonymousClosure: static (0xc20eb4), in [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getAvg (0xc20cdc)
    //     0xc20d00: ldr             x1, [x1, #0x3f8]
    // 0xc20d04: r2 = Null
    //     0xc20d04: mov             x2, NULL
    // 0xc20d08: r0 = AllocateClosure()
    //     0xc20d08: bl              #0x10cb178  ; AllocateClosureStub
    // 0xc20d0c: ldur            x1, [fp, #-8]
    // 0xc20d10: r2 = LoadClassIdInstr(r1)
    //     0xc20d10: ldur            x2, [x1, #-1]
    //     0xc20d14: ubfx            x2, x2, #0xc, #0x14
    // 0xc20d18: r16 = <double>
    //     0xc20d18: ldr             x16, [PP, #0x3fa0]  ; [pp+0x3fa0] TypeArguments: <double>
    // 0xc20d1c: stp             x1, x16, [SP, #0x10]
    // 0xc20d20: r16 = 0.000000
    //     0xc20d20: ldr             x16, [PP, #0x4688]  ; [pp+0x4688] 0
    // 0xc20d24: stp             x0, x16, [SP]
    // 0xc20d28: mov             x0, x2
    // 0xc20d2c: r4 = const [0x1, 0x3, 0x3, 0x3, null]
    //     0xc20d2c: ldr             x4, [PP, #0x758]  ; [pp+0x758] List(5) [0x1, 0x3, 0x3, 0x3, Null]
    // 0xc20d30: r0 = GDT[cid_x0 + 0x1490d]()
    //     0xc20d30: movz            x17, #0x490d
    //     0xc20d34: movk            x17, #0x1, lsl #16
    //     0xc20d38: add             lr, x0, x17
    //     0xc20d3c: ldr             lr, [x21, lr, lsl #3]
    //     0xc20d40: blr             lr
    // 0xc20d44: r1 = Function '<anonymous closure>': static.
    //     0xc20d44: add             x1, PP, #0x26, lsl #12  ; [pp+0x26400] AnonymousClosure: static (0xc20dd0), in [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getAvg (0xc20cdc)
    //     0xc20d48: ldr             x1, [x1, #0x400]
    // 0xc20d4c: r2 = Null
    //     0xc20d4c: mov             x2, NULL
    // 0xc20d50: stur            x0, [fp, #-0x10]
    // 0xc20d54: r0 = AllocateClosure()
    //     0xc20d54: bl              #0x10cb178  ; AllocateClosureStub
    // 0xc20d58: mov             x1, x0
    // 0xc20d5c: ldur            x0, [fp, #-8]
    // 0xc20d60: r2 = LoadClassIdInstr(r0)
    //     0xc20d60: ldur            x2, [x0, #-1]
    //     0xc20d64: ubfx            x2, x2, #0xc, #0x14
    // 0xc20d68: r16 = <double>
    //     0xc20d68: ldr             x16, [PP, #0x3fa0]  ; [pp+0x3fa0] TypeArguments: <double>
    // 0xc20d6c: stp             x0, x16, [SP, #0x10]
    // 0xc20d70: r16 = 0.000000
    //     0xc20d70: ldr             x16, [PP, #0x4688]  ; [pp+0x4688] 0
    // 0xc20d74: stp             x1, x16, [SP]
    // 0xc20d78: mov             x0, x2
    // 0xc20d7c: r4 = const [0x1, 0x3, 0x3, 0x3, null]
    //     0xc20d7c: ldr             x4, [PP, #0x758]  ; [pp+0x758] List(5) [0x1, 0x3, 0x3, 0x3, Null]
    // 0xc20d80: r0 = GDT[cid_x0 + 0x1490d]()
    //     0xc20d80: movz            x17, #0x490d
    //     0xc20d84: movk            x17, #0x1, lsl #16
    //     0xc20d88: add             lr, x0, x17
    //     0xc20d8c: ldr             lr, [x21, lr, lsl #3]
    //     0xc20d90: blr             lr
    // 0xc20d94: LoadField: d1 = r0->field_7
    //     0xc20d94: ldur            d1, [x0, #7]
    // 0xc20d98: d2 = 0.000000
    //     0xc20d98: eor             v2.16b, v2.16b, v2.16b
    // 0xc20d9c: fcmp            d1, d2
    // 0xc20da0: b.eq            #0xc20db8
    // 0xc20da4: ldur            x0, [fp, #-0x10]
    // 0xc20da8: LoadField: d2 = r0->field_7
    //     0xc20da8: ldur            d2, [x0, #7]
    // 0xc20dac: fdiv            d3, d2, d1
    // 0xc20db0: mov             v0.16b, v3.16b
    // 0xc20db4: b               #0xc20dbc
    // 0xc20db8: d0 = 0.000000
    //     0xc20db8: eor             v0.16b, v0.16b, v0.16b
    // 0xc20dbc: LeaveFrame
    //     0xc20dbc: mov             SP, fp
    //     0xc20dc0: ldp             fp, lr, [SP], #0x10
    // 0xc20dc4: ret
    //     0xc20dc4: ret
    // 0xc20dc8: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xc20dc8: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xc20dcc: b               #0xc20cfc
  }
  [closure] static double <anonymous closure>(dynamic, double, MasterGrade) {
    // ** addr: 0xc20dd0, size: 0xe4
    // 0xc20dd0: EnterFrame
    //     0xc20dd0: stp             fp, lr, [SP, #-0x10]!
    //     0xc20dd4: mov             fp, SP
    // 0xc20dd8: ldr             x1, [fp, #0x10]
    // 0xc20ddc: LoadField: r2 = r1->field_7
    //     0xc20ddc: ldur            w2, [x1, #7]
    // 0xc20de0: DecompressPointer r2
    //     0xc20de0: add             x2, x2, HEAP, lsl #32
    // 0xc20de4: LoadField: r1 = r2->field_1b
    //     0xc20de4: ldur            w1, [x2, #0x1b]
    // 0xc20de8: DecompressPointer r1
    //     0xc20de8: add             x1, x1, HEAP, lsl #32
    // 0xc20dec: cmp             w1, NULL
    // 0xc20df0: b.eq            #0xc20e94
    // 0xc20df4: r16 = Instance_GradeType
    //     0xc20df4: add             x16, PP, #9, lsl #12  ; [pp+0x97e8] Obj!GradeType@119cf71
    //     0xc20df8: ldr             x16, [x16, #0x7e8]
    // 0xc20dfc: cmp             w1, w16
    // 0xc20e00: b.eq            #0xc20e8c
    // 0xc20e04: LoadField: r1 = r2->field_23
    //     0xc20e04: ldur            w1, [x2, #0x23]
    // 0xc20e08: DecompressPointer r1
    //     0xc20e08: add             x1, x1, HEAP, lsl #32
    // 0xc20e0c: cmp             w1, NULL
    // 0xc20e10: b.eq            #0xc20e84
    // 0xc20e14: d0 = 0.000000
    //     0xc20e14: eor             v0.16b, v0.16b, v0.16b
    // 0xc20e18: LoadField: d1 = r1->field_7
    //     0xc20e18: ldur            d1, [x1, #7]
    // 0xc20e1c: fcmp            d1, d0
    // 0xc20e20: b.le            #0xc20e7c
    // 0xc20e24: LoadField: r1 = r2->field_8f
    //     0xc20e24: ldur            w1, [x2, #0x8f]
    // 0xc20e28: DecompressPointer r1
    //     0xc20e28: add             x1, x1, HEAP, lsl #32
    // 0xc20e2c: tbz             w1, #4, #0xc20e74
    // 0xc20e30: ldr             x0, [fp, #0x18]
    // 0xc20e34: LoadField: d0 = r2->field_5b
    //     0xc20e34: ldur            d0, [x2, #0x5b]
    // 0xc20e38: LoadField: d1 = r0->field_7
    //     0xc20e38: ldur            d1, [x0, #7]
    // 0xc20e3c: fadd            d2, d1, d0
    // 0xc20e40: r0 = inline_Allocate_Double()
    //     0xc20e40: ldp             x0, x1, [THR, #0x50]  ; THR::top
    //     0xc20e44: add             x0, x0, #0x10
    //     0xc20e48: cmp             x1, x0
    //     0xc20e4c: b.ls            #0xc20ea4
    //     0xc20e50: str             x0, [THR, #0x50]  ; THR::top
    //     0xc20e54: sub             x0, x0, #0xf
    //     0xc20e58: movz            x1, #0xe15c
    //     0xc20e5c: movk            x1, #0x3, lsl #16
    //     0xc20e60: stur            x1, [x0, #-1]
    // 0xc20e64: StoreField: r0->field_7 = d2
    //     0xc20e64: stur            d2, [x0, #7]
    // 0xc20e68: LeaveFrame
    //     0xc20e68: mov             SP, fp
    //     0xc20e6c: ldp             fp, lr, [SP], #0x10
    // 0xc20e70: ret
    //     0xc20e70: ret
    // 0xc20e74: ldr             x0, [fp, #0x18]
    // 0xc20e78: b               #0xc20e98
    // 0xc20e7c: ldr             x0, [fp, #0x18]
    // 0xc20e80: b               #0xc20e98
    // 0xc20e84: ldr             x0, [fp, #0x18]
    // 0xc20e88: b               #0xc20e98
    // 0xc20e8c: ldr             x0, [fp, #0x18]
    // 0xc20e90: b               #0xc20e98
    // 0xc20e94: ldr             x0, [fp, #0x18]
    // 0xc20e98: LeaveFrame
    //     0xc20e98: mov             SP, fp
    //     0xc20e9c: ldp             fp, lr, [SP], #0x10
    // 0xc20ea0: ret
    //     0xc20ea0: ret
    // 0xc20ea4: SaveReg d2
    //     0xc20ea4: str             q2, [SP, #-0x10]!
    // 0xc20ea8: r0 = AllocateDouble()
    //     0xc20ea8: bl              #0x10cbd9c  ; AllocateDoubleStub
    // 0xc20eac: RestoreReg d2
    //     0xc20eac: ldr             q2, [SP], #0x10
    // 0xc20eb0: b               #0xc20e64
  }
  [closure] static double <anonymous closure>(dynamic, double, MasterGrade) {
    // ** addr: 0xc20eb4, size: 0xe8
    // 0xc20eb4: EnterFrame
    //     0xc20eb4: stp             fp, lr, [SP, #-0x10]!
    //     0xc20eb8: mov             fp, SP
    // 0xc20ebc: ldr             x1, [fp, #0x10]
    // 0xc20ec0: LoadField: r2 = r1->field_7
    //     0xc20ec0: ldur            w2, [x1, #7]
    // 0xc20ec4: DecompressPointer r2
    //     0xc20ec4: add             x2, x2, HEAP, lsl #32
    // 0xc20ec8: LoadField: r1 = r2->field_1b
    //     0xc20ec8: ldur            w1, [x2, #0x1b]
    // 0xc20ecc: DecompressPointer r1
    //     0xc20ecc: add             x1, x1, HEAP, lsl #32
    // 0xc20ed0: cmp             w1, NULL
    // 0xc20ed4: b.eq            #0xc20f7c
    // 0xc20ed8: r16 = Instance_GradeType
    //     0xc20ed8: add             x16, PP, #9, lsl #12  ; [pp+0x97e8] Obj!GradeType@119cf71
    //     0xc20edc: ldr             x16, [x16, #0x7e8]
    // 0xc20ee0: cmp             w1, w16
    // 0xc20ee4: b.eq            #0xc20f74
    // 0xc20ee8: LoadField: r1 = r2->field_23
    //     0xc20ee8: ldur            w1, [x2, #0x23]
    // 0xc20eec: DecompressPointer r1
    //     0xc20eec: add             x1, x1, HEAP, lsl #32
    // 0xc20ef0: cmp             w1, NULL
    // 0xc20ef4: b.eq            #0xc20f6c
    // 0xc20ef8: d0 = 0.000000
    //     0xc20ef8: eor             v0.16b, v0.16b, v0.16b
    // 0xc20efc: LoadField: d1 = r1->field_7
    //     0xc20efc: ldur            d1, [x1, #7]
    // 0xc20f00: fcmp            d1, d0
    // 0xc20f04: b.le            #0xc20f64
    // 0xc20f08: LoadField: r1 = r2->field_8f
    //     0xc20f08: ldur            w1, [x2, #0x8f]
    // 0xc20f0c: DecompressPointer r1
    //     0xc20f0c: add             x1, x1, HEAP, lsl #32
    // 0xc20f10: tbz             w1, #4, #0xc20f5c
    // 0xc20f14: ldr             x0, [fp, #0x18]
    // 0xc20f18: LoadField: d0 = r2->field_5b
    //     0xc20f18: ldur            d0, [x2, #0x5b]
    // 0xc20f1c: fmul            d2, d1, d0
    // 0xc20f20: LoadField: d0 = r0->field_7
    //     0xc20f20: ldur            d0, [x0, #7]
    // 0xc20f24: fadd            d1, d0, d2
    // 0xc20f28: r0 = inline_Allocate_Double()
    //     0xc20f28: ldp             x0, x1, [THR, #0x50]  ; THR::top
    //     0xc20f2c: add             x0, x0, #0x10
    //     0xc20f30: cmp             x1, x0
    //     0xc20f34: b.ls            #0xc20f8c
    //     0xc20f38: str             x0, [THR, #0x50]  ; THR::top
    //     0xc20f3c: sub             x0, x0, #0xf
    //     0xc20f40: movz            x1, #0xe15c
    //     0xc20f44: movk            x1, #0x3, lsl #16
    //     0xc20f48: stur            x1, [x0, #-1]
    // 0xc20f4c: StoreField: r0->field_7 = d1
    //     0xc20f4c: stur            d1, [x0, #7]
    // 0xc20f50: LeaveFrame
    //     0xc20f50: mov             SP, fp
    //     0xc20f54: ldp             fp, lr, [SP], #0x10
    // 0xc20f58: ret
    //     0xc20f58: ret
    // 0xc20f5c: ldr             x0, [fp, #0x18]
    // 0xc20f60: b               #0xc20f80
    // 0xc20f64: ldr             x0, [fp, #0x18]
    // 0xc20f68: b               #0xc20f80
    // 0xc20f6c: ldr             x0, [fp, #0x18]
    // 0xc20f70: b               #0xc20f80
    // 0xc20f74: ldr             x0, [fp, #0x18]
    // 0xc20f78: b               #0xc20f80
    // 0xc20f7c: ldr             x0, [fp, #0x18]
    // 0xc20f80: LeaveFrame
    //     0xc20f80: mov             SP, fp
    //     0xc20f84: ldp             fp, lr, [SP], #0x10
    // 0xc20f88: ret
    //     0xc20f88: ret
    // 0xc20f8c: SaveReg d1
    //     0xc20f8c: str             q1, [SP, #-0x10]!
    // 0xc20f90: r0 = AllocateDouble()
    //     0xc20f90: bl              #0x10cbd9c  ; AllocateDoubleStub
    // 0xc20f94: RestoreReg d1
    //     0xc20f94: ldr             q1, [SP], #0x10
    // 0xc20f98: b               #0xc20f4c
  }
  static _ getSubjectAveragesForPeriods(/* No info */) {
    // ** addr: 0xcf6d54, size: 0x104
    // 0xcf6d54: EnterFrame
    //     0xcf6d54: stp             fp, lr, [SP, #-0x10]!
    //     0xcf6d58: mov             fp, SP
    // 0xcf6d5c: AllocStack(0x20)
    //     0xcf6d5c: sub             SP, SP, #0x20
    // 0xcf6d60: SetupParameters(dynamic _ /* r1 => r0, fp-0x8 */)
    //     0xcf6d60: mov             x0, x1
    //     0xcf6d64: stur            x1, [fp, #-8]
    // 0xcf6d68: CheckStackOverflow
    //     0xcf6d68: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xcf6d6c: cmp             SP, x16
    //     0xcf6d70: b.ls            #0xcf6e50
    // 0xcf6d74: r1 = Function '<anonymous closure>': static.
    //     0xcf6d74: add             x1, PP, #0x26, lsl #12  ; [pp+0x26e20] AnonymousClosure: static (0xcf72c0), in [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getSubjectAveragesForPeriods (0xcf6d54)
    //     0xcf6d78: ldr             x1, [x1, #0xe20]
    // 0xcf6d7c: r2 = Null
    //     0xcf6d7c: mov             x2, NULL
    // 0xcf6d80: r0 = AllocateClosure()
    //     0xcf6d80: bl              #0x10cb178  ; AllocateClosureStub
    // 0xcf6d84: r16 = <MasterGrade, String?>
    //     0xcf6d84: add             x16, PP, #0x26, lsl #12  ; [pp+0x26e28] TypeArguments: <MasterGrade, String?>
    //     0xcf6d88: ldr             x16, [x16, #0xe28]
    // 0xcf6d8c: ldur            lr, [fp, #-8]
    // 0xcf6d90: stp             lr, x16, [SP, #8]
    // 0xcf6d94: str             x0, [SP]
    // 0xcf6d98: r4 = const [0x2, 0x2, 0x2, 0x2, null]
    //     0xcf6d98: ldr             x4, [PP, #0x7d0]  ; [pp+0x7d0] List(5) [0x2, 0x2, 0x2, 0x2, Null]
    // 0xcf6d9c: r0 = IterableGrouping.groupBy()
    //     0xcf6d9c: bl              #0xcf6e58  ; [package:flutter_essentials_kit/extensions/iterable.dart] ::IterableGrouping.groupBy
    // 0xcf6da0: r1 = LoadClassIdInstr(r0)
    //     0xcf6da0: ldur            x1, [x0, #-1]
    //     0xcf6da4: ubfx            x1, x1, #0xc, #0x14
    // 0xcf6da8: mov             x16, x0
    // 0xcf6dac: mov             x0, x1
    // 0xcf6db0: mov             x1, x16
    // 0xcf6db4: r0 = GDT[cid_x0 + 0x8a3]()
    //     0xcf6db4: add             lr, x0, #0x8a3
    //     0xcf6db8: ldr             lr, [x21, lr, lsl #3]
    //     0xcf6dbc: blr             lr
    // 0xcf6dc0: r1 = Function '<anonymous closure>': static.
    //     0xcf6dc0: add             x1, PP, #0x26, lsl #12  ; [pp+0x26e30] AnonymousClosure: static (0xcf7098), in [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getSubjectAveragesForPeriods (0xcf6d54)
    //     0xcf6dc4: ldr             x1, [x1, #0xe30]
    // 0xcf6dc8: r2 = Null
    //     0xcf6dc8: mov             x2, NULL
    // 0xcf6dcc: stur            x0, [fp, #-8]
    // 0xcf6dd0: r0 = AllocateClosure()
    //     0xcf6dd0: bl              #0x10cb178  ; AllocateClosureStub
    // 0xcf6dd4: mov             x1, x0
    // 0xcf6dd8: ldur            x0, [fp, #-8]
    // 0xcf6ddc: r2 = LoadClassIdInstr(r0)
    //     0xcf6ddc: ldur            x2, [x0, #-1]
    //     0xcf6de0: ubfx            x2, x2, #0xc, #0x14
    // 0xcf6de4: r16 = <SubjectGrades>
    //     0xcf6de4: add             x16, PP, #0x26, lsl #12  ; [pp+0x26e38] TypeArguments: <SubjectGrades>
    //     0xcf6de8: ldr             x16, [x16, #0xe38]
    // 0xcf6dec: stp             x0, x16, [SP, #8]
    // 0xcf6df0: str             x1, [SP]
    // 0xcf6df4: mov             x0, x2
    // 0xcf6df8: r4 = const [0x1, 0x2, 0x2, 0x2, null]
    //     0xcf6df8: ldr             x4, [PP, #0x48]  ; [pp+0x48] List(5) [0x1, 0x2, 0x2, 0x2, Null]
    // 0xcf6dfc: r0 = GDT[cid_x0 + 0x1458e]()
    //     0xcf6dfc: movz            x17, #0x458e
    //     0xcf6e00: movk            x17, #0x1, lsl #16
    //     0xcf6e04: add             lr, x0, x17
    //     0xcf6e08: ldr             lr, [x21, lr, lsl #3]
    //     0xcf6e0c: blr             lr
    // 0xcf6e10: r1 = LoadClassIdInstr(r0)
    //     0xcf6e10: ldur            x1, [x0, #-1]
    //     0xcf6e14: ubfx            x1, x1, #0xc, #0x14
    // 0xcf6e18: r16 = false
    //     0xcf6e18: add             x16, NULL, #0x30  ; false
    // 0xcf6e1c: str             x16, [SP]
    // 0xcf6e20: mov             x16, x0
    // 0xcf6e24: mov             x0, x1
    // 0xcf6e28: mov             x1, x16
    // 0xcf6e2c: r4 = const [0, 0x2, 0x1, 0x1, growable, 0x1, null]
    //     0xcf6e2c: ldr             x4, [PP, #0x2b50]  ; [pp+0x2b50] List(7) [0, 0x2, 0x1, 0x1, "growable", 0x1, Null]
    // 0xcf6e30: r0 = GDT[cid_x0 + 0x1451e]()
    //     0xcf6e30: movz            x17, #0x451e
    //     0xcf6e34: movk            x17, #0x1, lsl #16
    //     0xcf6e38: add             lr, x0, x17
    //     0xcf6e3c: ldr             lr, [x21, lr, lsl #3]
    //     0xcf6e40: blr             lr
    // 0xcf6e44: LeaveFrame
    //     0xcf6e44: mov             SP, fp
    //     0xcf6e48: ldp             fp, lr, [SP], #0x10
    // 0xcf6e4c: ret
    //     0xcf6e4c: ret
    // 0xcf6e50: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xcf6e50: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xcf6e54: b               #0xcf6d74
  }
  [closure] static SubjectGrades <anonymous closure>(dynamic, MapEntry<String?, List<MasterGrade>>) {
    // ** addr: 0xcf7098, size: 0x144
    // 0xcf7098: EnterFrame
    //     0xcf7098: stp             fp, lr, [SP, #-0x10]!
    //     0xcf709c: mov             fp, SP
    // 0xcf70a0: AllocStack(0x28)
    //     0xcf70a0: sub             SP, SP, #0x28
    // 0xcf70a4: CheckStackOverflow
    //     0xcf70a4: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xcf70a8: cmp             SP, x16
    //     0xcf70ac: b.ls            #0xcf71d4
    // 0xcf70b0: ldr             x0, [fp, #0x10]
    // 0xcf70b4: LoadField: r1 = r0->field_b
    //     0xcf70b4: ldur            w1, [x0, #0xb]
    // 0xcf70b8: DecompressPointer r1
    //     0xcf70b8: add             x1, x1, HEAP, lsl #32
    // 0xcf70bc: cmp             w1, NULL
    // 0xcf70c0: b.ne            #0xcf70cc
    // 0xcf70c4: r3 = ""
    //     0xcf70c4: ldr             x3, [PP, #0x8b0]  ; [pp+0x8b0] ""
    // 0xcf70c8: b               #0xcf70d0
    // 0xcf70cc: mov             x3, x1
    // 0xcf70d0: stur            x3, [fp, #-0x10]
    // 0xcf70d4: LoadField: r4 = r0->field_f
    //     0xcf70d4: ldur            w4, [x0, #0xf]
    // 0xcf70d8: DecompressPointer r4
    //     0xcf70d8: add             x4, x4, HEAP, lsl #32
    // 0xcf70dc: stur            x4, [fp, #-8]
    // 0xcf70e0: r1 = Function '<anonymous closure>': static.
    //     0xcf70e0: add             x1, PP, #0x26, lsl #12  ; [pp+0x26e40] AnonymousClosure: static (0xcf7288), in [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getSubjectAveragesForPeriods (0xcf6d54)
    //     0xcf70e4: ldr             x1, [x1, #0xe40]
    // 0xcf70e8: r2 = Null
    //     0xcf70e8: mov             x2, NULL
    // 0xcf70ec: r0 = AllocateClosure()
    //     0xcf70ec: bl              #0x10cb178  ; AllocateClosureStub
    // 0xcf70f0: r16 = <MasterGrade, int>
    //     0xcf70f0: add             x16, PP, #0x26, lsl #12  ; [pp+0x26e48] TypeArguments: <MasterGrade, int>
    //     0xcf70f4: ldr             x16, [x16, #0xe48]
    // 0xcf70f8: ldur            lr, [fp, #-8]
    // 0xcf70fc: stp             lr, x16, [SP, #8]
    // 0xcf7100: str             x0, [SP]
    // 0xcf7104: r4 = const [0x2, 0x2, 0x2, 0x2, null]
    //     0xcf7104: ldr             x4, [PP, #0x7d0]  ; [pp+0x7d0] List(5) [0x2, 0x2, 0x2, 0x2, Null]
    // 0xcf7108: r0 = IterableGrouping.groupBy()
    //     0xcf7108: bl              #0xcf6e58  ; [package:flutter_essentials_kit/extensions/iterable.dart] ::IterableGrouping.groupBy
    // 0xcf710c: r1 = LoadClassIdInstr(r0)
    //     0xcf710c: ldur            x1, [x0, #-1]
    //     0xcf7110: ubfx            x1, x1, #0xc, #0x14
    // 0xcf7114: mov             x16, x0
    // 0xcf7118: mov             x0, x1
    // 0xcf711c: mov             x1, x16
    // 0xcf7120: r0 = GDT[cid_x0 + 0x8a3]()
    //     0xcf7120: add             lr, x0, #0x8a3
    //     0xcf7124: ldr             lr, [x21, lr, lsl #3]
    //     0xcf7128: blr             lr
    // 0xcf712c: r1 = Function '<anonymous closure>': static.
    //     0xcf712c: add             x1, PP, #0x26, lsl #12  ; [pp+0x26e50] AnonymousClosure: static (0xcf720c), in [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getSubjectAveragesForPeriods (0xcf6d54)
    //     0xcf7130: ldr             x1, [x1, #0xe50]
    // 0xcf7134: r2 = Null
    //     0xcf7134: mov             x2, NULL
    // 0xcf7138: stur            x0, [fp, #-8]
    // 0xcf713c: r0 = AllocateClosure()
    //     0xcf713c: bl              #0x10cb178  ; AllocateClosureStub
    // 0xcf7140: mov             x1, x0
    // 0xcf7144: ldur            x0, [fp, #-8]
    // 0xcf7148: r2 = LoadClassIdInstr(r0)
    //     0xcf7148: ldur            x2, [x0, #-1]
    //     0xcf714c: ubfx            x2, x2, #0xc, #0x14
    // 0xcf7150: r16 = <AverageGrade>
    //     0xcf7150: add             x16, PP, #0x26, lsl #12  ; [pp+0x26e58] TypeArguments: <AverageGrade>
    //     0xcf7154: ldr             x16, [x16, #0xe58]
    // 0xcf7158: stp             x0, x16, [SP, #8]
    // 0xcf715c: str             x1, [SP]
    // 0xcf7160: mov             x0, x2
    // 0xcf7164: r4 = const [0x1, 0x2, 0x2, 0x2, null]
    //     0xcf7164: ldr             x4, [PP, #0x48]  ; [pp+0x48] List(5) [0x1, 0x2, 0x2, 0x2, Null]
    // 0xcf7168: r0 = GDT[cid_x0 + 0x1458e]()
    //     0xcf7168: movz            x17, #0x458e
    //     0xcf716c: movk            x17, #0x1, lsl #16
    //     0xcf7170: add             lr, x0, x17
    //     0xcf7174: ldr             lr, [x21, lr, lsl #3]
    //     0xcf7178: blr             lr
    // 0xcf717c: r1 = LoadClassIdInstr(r0)
    //     0xcf717c: ldur            x1, [x0, #-1]
    //     0xcf7180: ubfx            x1, x1, #0xc, #0x14
    // 0xcf7184: r16 = false
    //     0xcf7184: add             x16, NULL, #0x30  ; false
    // 0xcf7188: str             x16, [SP]
    // 0xcf718c: mov             x16, x0
    // 0xcf7190: mov             x0, x1
    // 0xcf7194: mov             x1, x16
    // 0xcf7198: r4 = const [0, 0x2, 0x1, 0x1, growable, 0x1, null]
    //     0xcf7198: ldr             x4, [PP, #0x2b50]  ; [pp+0x2b50] List(7) [0, 0x2, 0x1, 0x1, "growable", 0x1, Null]
    // 0xcf719c: r0 = GDT[cid_x0 + 0x1451e]()
    //     0xcf719c: movz            x17, #0x451e
    //     0xcf71a0: movk            x17, #0x1, lsl #16
    //     0xcf71a4: add             lr, x0, x17
    //     0xcf71a8: ldr             lr, [x21, lr, lsl #3]
    //     0xcf71ac: blr             lr
    // 0xcf71b0: stur            x0, [fp, #-8]
    // 0xcf71b4: r0 = _SubjectGrades()
    //     0xcf71b4: bl              #0xcf71dc  ; Allocate_SubjectGradesStub -> _SubjectGrades (size=0x10)
    // 0xcf71b8: ldur            x1, [fp, #-0x10]
    // 0xcf71bc: StoreField: r0->field_7 = r1
    //     0xcf71bc: stur            w1, [x0, #7]
    // 0xcf71c0: ldur            x1, [fp, #-8]
    // 0xcf71c4: StoreField: r0->field_b = r1
    //     0xcf71c4: stur            w1, [x0, #0xb]
    // 0xcf71c8: LeaveFrame
    //     0xcf71c8: mov             SP, fp
    //     0xcf71cc: ldp             fp, lr, [SP], #0x10
    // 0xcf71d0: ret
    //     0xcf71d0: ret
    // 0xcf71d4: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xcf71d4: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xcf71d8: b               #0xcf70b0
  }
  [closure] static AverageGrade <anonymous closure>(dynamic, MapEntry<int, List<MasterGrade>>) {
    // ** addr: 0xcf720c, size: 0x70
    // 0xcf720c: EnterFrame
    //     0xcf720c: stp             fp, lr, [SP, #-0x10]!
    //     0xcf7210: mov             fp, SP
    // 0xcf7214: AllocStack(0x18)
    //     0xcf7214: sub             SP, SP, #0x18
    // 0xcf7218: CheckStackOverflow
    //     0xcf7218: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xcf721c: cmp             SP, x16
    //     0xcf7220: b.ls            #0xcf7274
    // 0xcf7224: ldr             x0, [fp, #0x10]
    // 0xcf7228: LoadField: r2 = r0->field_b
    //     0xcf7228: ldur            w2, [x0, #0xb]
    // 0xcf722c: DecompressPointer r2
    //     0xcf722c: add             x2, x2, HEAP, lsl #32
    // 0xcf7230: stur            x2, [fp, #-0x10]
    // 0xcf7234: LoadField: r3 = r0->field_f
    //     0xcf7234: ldur            w3, [x0, #0xf]
    // 0xcf7238: DecompressPointer r3
    //     0xcf7238: add             x3, x3, HEAP, lsl #32
    // 0xcf723c: mov             x1, x3
    // 0xcf7240: stur            x3, [fp, #-8]
    // 0xcf7244: r0 = getAvg()
    //     0xcf7244: bl              #0xc20cdc  ; [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getAvg
    // 0xcf7248: stur            d0, [fp, #-0x18]
    // 0xcf724c: r0 = _AverageGrade()
    //     0xcf724c: bl              #0xcf727c  ; Allocate_AverageGradeStub -> _AverageGrade (size=0x18)
    // 0xcf7250: ldur            x1, [fp, #-0x10]
    // 0xcf7254: StoreField: r0->field_7 = r1
    //     0xcf7254: stur            w1, [x0, #7]
    // 0xcf7258: ldur            d0, [fp, #-0x18]
    // 0xcf725c: StoreField: r0->field_b = d0
    //     0xcf725c: stur            d0, [x0, #0xb]
    // 0xcf7260: ldur            x1, [fp, #-8]
    // 0xcf7264: StoreField: r0->field_13 = r1
    //     0xcf7264: stur            w1, [x0, #0x13]
    // 0xcf7268: LeaveFrame
    //     0xcf7268: mov             SP, fp
    //     0xcf726c: ldp             fp, lr, [SP], #0x10
    // 0xcf7270: ret
    //     0xcf7270: ret
    // 0xcf7274: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xcf7274: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xcf7278: b               #0xcf7224
  }
  [closure] static int <anonymous closure>(dynamic, MasterGrade) {
    // ** addr: 0xcf7288, size: 0x38
    // 0xcf7288: ldr             x2, [SP]
    // 0xcf728c: LoadField: r3 = r2->field_7
    //     0xcf728c: ldur            w3, [x2, #7]
    // 0xcf7290: DecompressPointer r3
    //     0xcf7290: add             x3, x3, HEAP, lsl #32
    // 0xcf7294: LoadField: r2 = r3->field_3f
    //     0xcf7294: ldur            x2, [x3, #0x3f]
    // 0xcf7298: r0 = BoxInt64Instr(r2)
    //     0xcf7298: sbfiz           x0, x2, #1, #0x1f
    //     0xcf729c: cmp             x2, x0, asr #1
    //     0xcf72a0: b.eq            #0xcf72bc
    //     0xcf72a4: stp             fp, lr, [SP, #-0x10]!
    //     0xcf72a8: mov             fp, SP
    //     0xcf72ac: bl              #0x10cc0cc  ; AllocateMintSharedWithoutFPURegsStub
    //     0xcf72b0: mov             SP, fp
    //     0xcf72b4: ldp             fp, lr, [SP], #0x10
    //     0xcf72b8: stur            x2, [x0, #7]
    // 0xcf72bc: ret
    //     0xcf72bc: ret
  }
  [closure] static String? <anonymous closure>(dynamic, MasterGrade) {
    // ** addr: 0xcf72c0, size: 0x18
    // 0xcf72c0: ldr             x1, [SP]
    // 0xcf72c4: LoadField: r2 = r1->field_7
    //     0xcf72c4: ldur            w2, [x1, #7]
    // 0xcf72c8: DecompressPointer r2
    //     0xcf72c8: add             x2, x2, HEAP, lsl #32
    // 0xcf72cc: LoadField: r0 = r2->field_f
    //     0xcf72cc: ldur            w0, [x2, #0xf]
    // 0xcf72d0: DecompressPointer r0
    //     0xcf72d0: add             x0, x0, HEAP, lsl #32
    // 0xcf72d4: ret
    //     0xcf72d4: ret
  }
  static _ removeDecimalZeroFormat(/* No info */) {
    // ** addr: 0xd8624c, size: 0xc4
    // 0xd8624c: EnterFrame
    //     0xd8624c: stp             fp, lr, [SP, #-0x10]!
    //     0xd86250: mov             fp, SP
    // 0xd86254: AllocStack(0x8)
    //     0xd86254: sub             SP, SP, #8
    // 0xd86258: d1 = 10.000000
    //     0xd86258: fmov            d1, #10.00000000
    // 0xd8625c: CheckStackOverflow
    //     0xd8625c: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xd86260: cmp             SP, x16
    //     0xd86264: b.ls            #0xd862d8
    // 0xd86268: fmul            d2, d0, d1
    // 0xd8626c: fcmp            d2, d2
    // 0xd86270: b.vs            #0xd862e0
    // 0xd86274: fcvtzs          x0, d2
    // 0xd86278: asr             x16, x0, #0x1e
    // 0xd8627c: cmp             x16, x0, asr #63
    // 0xd86280: b.ne            #0xd862e0
    // 0xd86284: lsl             x0, x0, #1
    // 0xd86288: r1 = LoadInt32Instr(r0)
    //     0xd86288: sbfx            x1, x0, #1, #0x1f
    //     0xd8628c: tbz             w0, #0, #0xd86294
    //     0xd86290: ldur            x1, [x0, #7]
    // 0xd86294: scvtf           d0, x1
    // 0xd86298: fdiv            d2, d0, d1
    // 0xd8629c: r0 = inline_Allocate_Double()
    //     0xd8629c: ldp             x0, x1, [THR, #0x50]  ; THR::top
    //     0xd862a0: add             x0, x0, #0x10
    //     0xd862a4: cmp             x1, x0
    //     0xd862a8: b.ls            #0xd86300
    //     0xd862ac: str             x0, [THR, #0x50]  ; THR::top
    //     0xd862b0: sub             x0, x0, #0xf
    //     0xd862b4: movz            x1, #0xe15c
    //     0xd862b8: movk            x1, #0x3, lsl #16
    //     0xd862bc: stur            x1, [x0, #-1]
    // 0xd862c0: StoreField: r0->field_7 = d2
    //     0xd862c0: stur            d2, [x0, #7]
    // 0xd862c4: str             x0, [SP]
    // 0xd862c8: r0 = toString()
    //     0xd862c8: bl              #0xe7b0e8  ; [dart:core] _Double::toString
    // 0xd862cc: LeaveFrame
    //     0xd862cc: mov             SP, fp
    //     0xd862d0: ldp             fp, lr, [SP], #0x10
    // 0xd862d4: ret
    //     0xd862d4: ret
    // 0xd862d8: r0 = StackOverflowSharedWithFPURegs()
    //     0xd862d8: bl              #0x10cbfcc  ; StackOverflowSharedWithFPURegsStub
    // 0xd862dc: b               #0xd86268
    // 0xd862e0: stp             q1, q2, [SP, #-0x20]!
    // 0xd862e4: d0 = 0.000000
    //     0xd862e4: fmov            d0, d2
    // 0xd862e8: r0 = 74
    //     0xd862e8: movz            x0, #0x4a
    // 0xd862ec: r30 = DoubleToIntegerStub
    //     0xd862ec: ldr             lr, [PP, #0x17e0]  ; [pp+0x17e0] Stub: DoubleToInteger (0x6d1848)
    // 0xd862f0: LoadField: r30 = r30->field_7
    //     0xd862f0: ldur            lr, [lr, #7]
    // 0xd862f4: blr             lr
    // 0xd862f8: ldp             q1, q2, [SP], #0x20
    // 0xd862fc: b               #0xd86288
    // 0xd86300: SaveReg d2
    //     0xd86300: str             q2, [SP, #-0x10]!
    // 0xd86304: r0 = AllocateDouble()
    //     0xd86304: bl              #0x10cbd9c  ; AllocateDoubleStub
    // 0xd86308: RestoreReg d2
    //     0xd86308: ldr             q2, [SP], #0x10
    // 0xd8630c: b               #0xd862c0
  }
  static _ getAvgForPeriod(/* No info */) {
    // ** addr: 0xd90844, size: 0x134
    // 0xd90844: EnterFrame
    //     0xd90844: stp             fp, lr, [SP, #-0x10]!
    //     0xd90848: mov             fp, SP
    // 0xd9084c: AllocStack(0x30)
    //     0xd9084c: sub             SP, SP, #0x30
    // 0xd90850: SetupParameters(dynamic _ /* r1 => r3, fp-0x10 */)
    //     0xd90850: mov             x3, x1
    //     0xd90854: stur            x1, [fp, #-0x10]
    // 0xd90858: CheckStackOverflow
    //     0xd90858: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xd9085c: cmp             SP, x16
    //     0xd90860: b.ls            #0xd90970
    // 0xd90864: r0 = BoxInt64Instr(r2)
    //     0xd90864: sbfiz           x0, x2, #1, #0x1f
    //     0xd90868: cmp             x2, x0, asr #1
    //     0xd9086c: b.eq            #0xd90878
    //     0xd90870: bl              #0x10cc0cc  ; AllocateMintSharedWithoutFPURegsStub
    //     0xd90874: stur            x2, [x0, #7]
    // 0xd90878: stur            x0, [fp, #-8]
    // 0xd9087c: r1 = 1
    //     0xd9087c: movz            x1, #0x1
    // 0xd90880: r0 = AllocateContext()
    //     0xd90880: bl              #0x10cadb4  ; AllocateContextStub
    // 0xd90884: mov             x1, x0
    // 0xd90888: ldur            x0, [fp, #-8]
    // 0xd9088c: StoreField: r1->field_f = r0
    //     0xd9088c: stur            w0, [x1, #0xf]
    // 0xd90890: mov             x2, x1
    // 0xd90894: r1 = Function '<anonymous closure>': static.
    //     0xd90894: add             x1, PP, #0x2c, lsl #12  ; [pp+0x2c370] AnonymousClosure: static (0xd90978), in [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getAvgForPeriod (0xd90844)
    //     0xd90898: ldr             x1, [x1, #0x370]
    // 0xd9089c: r0 = AllocateClosure()
    //     0xd9089c: bl              #0x10cb178  ; AllocateClosureStub
    // 0xd908a0: ldur            x1, [fp, #-0x10]
    // 0xd908a4: r2 = LoadClassIdInstr(r1)
    //     0xd908a4: ldur            x2, [x1, #-1]
    //     0xd908a8: ubfx            x2, x2, #0xc, #0x14
    // 0xd908ac: mov             x16, x0
    // 0xd908b0: mov             x0, x2
    // 0xd908b4: mov             x2, x16
    // 0xd908b8: r0 = GDT[cid_x0 + 0x143c9]()
    //     0xd908b8: movz            x17, #0x43c9
    //     0xd908bc: movk            x17, #0x1, lsl #16
    //     0xd908c0: add             lr, x0, x17
    //     0xd908c4: ldr             lr, [x21, lr, lsl #3]
    //     0xd908c8: blr             lr
    // 0xd908cc: LoadField: r1 = r0->field_7
    //     0xd908cc: ldur            w1, [x0, #7]
    // 0xd908d0: DecompressPointer r1
    //     0xd908d0: add             x1, x1, HEAP, lsl #32
    // 0xd908d4: mov             x2, x0
    // 0xd908d8: r0 = _GrowableList.of()
    //     0xd908d8: bl              #0x6d7d08  ; [dart:core] _GrowableList::_GrowableList.of
    // 0xd908dc: r1 = Function '<anonymous closure>': static.
    //     0xd908dc: add             x1, PP, #0x2c, lsl #12  ; [pp+0x2c378] AnonymousClosure: static (0xc20eb4), in [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getAvg (0xc20cdc)
    //     0xd908e0: ldr             x1, [x1, #0x378]
    // 0xd908e4: r2 = Null
    //     0xd908e4: mov             x2, NULL
    // 0xd908e8: stur            x0, [fp, #-8]
    // 0xd908ec: r0 = AllocateClosure()
    //     0xd908ec: bl              #0x10cb178  ; AllocateClosureStub
    // 0xd908f0: r16 = <double>
    //     0xd908f0: ldr             x16, [PP, #0x3fa0]  ; [pp+0x3fa0] TypeArguments: <double>
    // 0xd908f4: ldur            lr, [fp, #-8]
    // 0xd908f8: stp             lr, x16, [SP, #0x10]
    // 0xd908fc: r16 = 0.000000
    //     0xd908fc: ldr             x16, [PP, #0x4688]  ; [pp+0x4688] 0
    // 0xd90900: stp             x0, x16, [SP]
    // 0xd90904: r4 = const [0x1, 0x3, 0x3, 0x3, null]
    //     0xd90904: ldr             x4, [PP, #0x758]  ; [pp+0x758] List(5) [0x1, 0x3, 0x3, 0x3, Null]
    // 0xd90908: r0 = fold()
    //     0xd90908: bl              #0xa1ba88  ; [dart:collection] ListBase::fold
    // 0xd9090c: r1 = Function '<anonymous closure>': static.
    //     0xd9090c: add             x1, PP, #0x2c, lsl #12  ; [pp+0x2c380] AnonymousClosure: static (0xc20dd0), in [package:classeviva/core/misc/grade_utils.dart] GradeUtils::getAvg (0xc20cdc)
    //     0xd90910: ldr             x1, [x1, #0x380]
    // 0xd90914: r2 = Null
    //     0xd90914: mov             x2, NULL
    // 0xd90918: stur            x0, [fp, #-0x10]
    // 0xd9091c: r0 = AllocateClosure()
    //     0xd9091c: bl              #0x10cb178  ; AllocateClosureStub
    // 0xd90920: r16 = <double>
    //     0xd90920: ldr             x16, [PP, #0x3fa0]  ; [pp+0x3fa0] TypeArguments: <double>
    // 0xd90924: ldur            lr, [fp, #-8]
    // 0xd90928: stp             lr, x16, [SP, #0x10]
    // 0xd9092c: r16 = 0.000000
    //     0xd9092c: ldr             x16, [PP, #0x4688]  ; [pp+0x4688] 0
    // 0xd90930: stp             x0, x16, [SP]
    // 0xd90934: r4 = const [0x1, 0x3, 0x3, 0x3, null]
    //     0xd90934: ldr             x4, [PP, #0x758]  ; [pp+0x758] List(5) [0x1, 0x3, 0x3, 0x3, Null]
    // 0xd90938: r0 = fold()
    //     0xd90938: bl              #0xa1ba88  ; [dart:collection] ListBase::fold
    // 0xd9093c: LoadField: d1 = r0->field_7
    //     0xd9093c: ldur            d1, [x0, #7]
    // 0xd90940: d2 = 0.000000
    //     0xd90940: eor             v2.16b, v2.16b, v2.16b
    // 0xd90944: fcmp            d1, d2
    // 0xd90948: b.eq            #0xd90960
    // 0xd9094c: ldur            x0, [fp, #-0x10]
    // 0xd90950: LoadField: d2 = r0->field_7
    //     0xd90950: ldur            d2, [x0, #7]
    // 0xd90954: fdiv            d3, d2, d1
    // 0xd90958: mov             v0.16b, v3.16b
    // 0xd9095c: b               #0xd90964
    // 0xd90960: d0 = 0.000000
    //     0xd90960: eor             v0.16b, v0.16b, v0.16b
    // 0xd90964: LeaveFrame
    //     0xd90964: mov             SP, fp
    //     0xd90968: ldp             fp, lr, [SP], #0x10
    // 0xd9096c: ret
    //     0xd9096c: ret
    // 0xd90970: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xd90970: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xd90974: b               #0xd90864
  }
  [closure] static bool <anonymous closure>(dynamic, MasterGrade) {
    // ** addr: 0xd90978, size: 0x44
    // 0xd90978: ldr             x1, [SP, #8]
    // 0xd9097c: ArrayLoad: r2 = r1[0]  ; List_4
    //     0xd9097c: ldur            w2, [x1, #0x17]
    // 0xd90980: DecompressPointer r2
    //     0xd90980: add             x2, x2, HEAP, lsl #32
    // 0xd90984: ldr             x1, [SP]
    // 0xd90988: LoadField: r3 = r1->field_7
    //     0xd90988: ldur            w3, [x1, #7]
    // 0xd9098c: DecompressPointer r3
    //     0xd9098c: add             x3, x3, HEAP, lsl #32
    // 0xd90990: LoadField: r1 = r3->field_3f
    //     0xd90990: ldur            x1, [x3, #0x3f]
    // 0xd90994: LoadField: r3 = r2->field_f
    //     0xd90994: ldur            w3, [x2, #0xf]
    // 0xd90998: DecompressPointer r3
    //     0xd90998: add             x3, x3, HEAP, lsl #32
    // 0xd9099c: r2 = LoadInt32Instr(r3)
    //     0xd9099c: sbfx            x2, x3, #1, #0x1f
    //     0xd909a0: tbz             w3, #0, #0xd909a8
    //     0xd909a4: ldur            x2, [x3, #7]
    // 0xd909a8: cmp             x1, x2
    // 0xd909ac: r16 = true
    //     0xd909ac: add             x16, NULL, #0x20  ; true
    // 0xd909b0: r17 = false
    //     0xd909b0: add             x17, NULL, #0x30  ; false
    // 0xd909b4: csel            x0, x16, x17, eq
    // 0xd909b8: ret
    //     0xd909b8: ret
  }
}
