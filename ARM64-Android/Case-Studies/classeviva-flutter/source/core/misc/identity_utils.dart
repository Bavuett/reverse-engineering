// lib: , url: package:classeviva/core/misc/identity_utils.dart

// class id: 1048776, size: 0x8
class :: {
}

// class id: 8368, size: 0x8, field offset: 0x8
abstract class IdentityUtils extends Object {

  static _ generateSchoolPass(/* No info */) {
    // ** addr: 0x7e0068, size: 0xa4
    // 0x7e0068: EnterFrame
    //     0x7e0068: stp             fp, lr, [SP, #-0x10]!
    //     0x7e006c: mov             fp, SP
    // 0x7e0070: mov             x3, x1
    // 0x7e0074: CheckStackOverflow
    //     0x7e0074: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x7e0078: cmp             SP, x16
    //     0x7e007c: b.ls            #0x7e0104
    // 0x7e0080: LoadField: r4 = r2->field_7
    //     0x7e0080: ldur            x4, [x2, #7]
    // 0x7e0084: cmp             x4, #1
    // 0x7e0088: b.gt            #0x7e00ac
    // 0x7e008c: cmp             x4, #0
    // 0x7e0090: b.gt            #0x7e00a0
    // 0x7e0094: r1 = "5"
    //     0x7e0094: add             x1, PP, #0x28, lsl #12  ; [pp+0x280d0] "5"
    //     0x7e0098: ldr             x1, [x1, #0xd0]
    // 0x7e009c: b               #0x7e00f0
    // 0x7e00a0: r1 = "6"
    //     0x7e00a0: add             x1, PP, #0x28, lsl #12  ; [pp+0x280d8] "6"
    //     0x7e00a4: ldr             x1, [x1, #0xd8]
    // 0x7e00a8: b               #0x7e00f0
    // 0x7e00ac: cmp             x4, #2
    // 0x7e00b0: b.gt            #0x7e00c0
    // 0x7e00b4: r1 = "7"
    //     0x7e00b4: add             x1, PP, #0x28, lsl #12  ; [pp+0x280e0] "7"
    //     0x7e00b8: ldr             x1, [x1, #0xe0]
    // 0x7e00bc: b               #0x7e00f0
    // 0x7e00c0: r0 = BoxInt64Instr(r4)
    //     0x7e00c0: sbfiz           x0, x4, #1, #0x1f
    //     0x7e00c4: cmp             x4, x0, asr #1
    //     0x7e00c8: b.eq            #0x7e00d4
    //     0x7e00cc: bl              #0x10cc0cc  ; AllocateMintSharedWithoutFPURegsStub
    //     0x7e00d0: stur            x4, [x0, #7]
    // 0x7e00d4: cmp             w0, #6
    // 0x7e00d8: b.ne            #0x7e00e8
    // 0x7e00dc: r1 = "1"
    //     0x7e00dc: add             x1, PP, #9, lsl #12  ; [pp+0x9dd8] "1"
    //     0x7e00e0: ldr             x1, [x1, #0xdd8]
    // 0x7e00e4: b               #0x7e00f0
    // 0x7e00e8: r1 = "1"
    //     0x7e00e8: add             x1, PP, #9, lsl #12  ; [pp+0x9dd8] "1"
    //     0x7e00ec: ldr             x1, [x1, #0xdd8]
    // 0x7e00f0: mov             x2, x3
    // 0x7e00f4: r0 = finalSchoolPass()
    //     0x7e00f4: bl              #0x7e010c  ; [package:classeviva/core/misc/identity_utils.dart] IdentityUtils::finalSchoolPass
    // 0x7e00f8: LeaveFrame
    //     0x7e00f8: mov             SP, fp
    //     0x7e00fc: ldp             fp, lr, [SP], #0x10
    // 0x7e0100: ret
    //     0x7e0100: ret
    // 0x7e0104: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x7e0104: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x7e0108: b               #0x7e0080
  }
  static _ finalSchoolPass(/* No info */) {
    // ** addr: 0x7e010c, size: 0x70
    // 0x7e010c: EnterFrame
    //     0x7e010c: stp             fp, lr, [SP, #-0x10]!
    //     0x7e0110: mov             fp, SP
    // 0x7e0114: AllocStack(0x20)
    //     0x7e0114: sub             SP, SP, #0x20
    // 0x7e0118: SetupParameters(dynamic _ /* r1 => r0, fp-0x8 */, dynamic _ /* r2 => r2, fp-0x10 */)
    //     0x7e0118: mov             x0, x1
    //     0x7e011c: stur            x1, [fp, #-8]
    //     0x7e0120: stur            x2, [fp, #-0x10]
    // 0x7e0124: CheckStackOverflow
    //     0x7e0124: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x7e0128: cmp             SP, x16
    //     0x7e012c: b.ls            #0x7e0174
    // 0x7e0130: r0 = StringBuffer()
    //     0x7e0130: bl              #0x6e69c0  ; AllocateStringBufferStub -> StringBuffer (size=0x38)
    // 0x7e0134: mov             x1, x0
    // 0x7e0138: stur            x0, [fp, #-0x18]
    // 0x7e013c: r4 = const [0, 0x1, 0, 0x1, null]
    //     0x7e013c: ldr             x4, [PP, #0xa0]  ; [pp+0xa0] List(5) [0, 0x1, 0, 0x1, Null]
    // 0x7e0140: r0 = StringBuffer()
    //     0x7e0140: bl              #0x6e6288  ; [dart:core] StringBuffer::StringBuffer
    // 0x7e0144: ldur            x1, [fp, #-0x18]
    // 0x7e0148: ldur            x2, [fp, #-8]
    // 0x7e014c: r0 = write()
    //     0x7e014c: bl              #0xfbf4e4  ; [dart:core] StringBuffer::write
    // 0x7e0150: ldur            x1, [fp, #-0x18]
    // 0x7e0154: ldur            x2, [fp, #-0x10]
    // 0x7e0158: r0 = write()
    //     0x7e0158: bl              #0xfbf4e4  ; [dart:core] StringBuffer::write
    // 0x7e015c: ldur            x16, [fp, #-0x18]
    // 0x7e0160: str             x16, [SP]
    // 0x7e0164: r0 = toString()
    //     0x7e0164: bl              #0xe068c0  ; [dart:core] StringBuffer::toString
    // 0x7e0168: LeaveFrame
    //     0x7e0168: mov             SP, fp
    //     0x7e016c: ldp             fp, lr, [SP], #0x10
    // 0x7e0170: ret
    //     0x7e0170: ret
    // 0x7e0174: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x7e0174: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x7e0178: b               #0x7e0130
  }
  static _ isParent(/* No info */) {
    // ** addr: 0xc172a0, size: 0xc4
    // 0xc172a0: EnterFrame
    //     0xc172a0: stp             fp, lr, [SP, #-0x10]!
    //     0xc172a4: mov             fp, SP
    // 0xc172a8: AllocStack(0x20)
    //     0xc172a8: sub             SP, SP, #0x20
    // 0xc172ac: SetupParameters(dynamic _ /* r1 => r1, fp-0x10 */)
    //     0xc172ac: stur            x1, [fp, #-0x10]
    // 0xc172b0: CheckStackOverflow
    //     0xc172b0: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xc172b4: cmp             SP, x16
    //     0xc172b8: b.ls            #0xc1735c
    // 0xc172bc: LoadField: r0 = r1->field_7
    //     0xc172bc: ldur            w0, [x1, #7]
    // 0xc172c0: r2 = LoadInt32Instr(r0)
    //     0xc172c0: sbfx            x2, x0, #1, #0x1f
    // 0xc172c4: stur            x2, [fp, #-8]
    // 0xc172c8: cmp             x2, #1
    // 0xc172cc: b.le            #0xc172dc
    // 0xc172d0: stp             xzr, x1, [SP]
    // 0xc172d4: r0 = []()
    //     0xc172d4: bl              #0x6e4858  ; [dart:core] _StringBase::[]
    // 0xc172d8: b               #0xc172e0
    // 0xc172dc: r0 = "0"
    //     0xc172dc: ldr             x0, [PP, #0x42e8]  ; [pp+0x42e8] "0"
    // 0xc172e0: r1 = LoadClassIdInstr(r0)
    //     0xc172e0: ldur            x1, [x0, #-1]
    //     0xc172e4: ubfx            x1, x1, #0xc, #0x14
    // 0xc172e8: r16 = "G"
    //     0xc172e8: add             x16, PP, #0xa, lsl #12  ; [pp+0xaec0] "G"
    //     0xc172ec: ldr             x16, [x16, #0xec0]
    // 0xc172f0: stp             x16, x0, [SP]
    // 0xc172f4: mov             x0, x1
    // 0xc172f8: mov             lr, x0
    // 0xc172fc: ldr             lr, [x21, lr, lsl #3]
    // 0xc17300: blr             lr
    // 0xc17304: tbnz            w0, #4, #0xc17310
    // 0xc17308: r0 = true
    //     0xc17308: add             x0, NULL, #0x20  ; true
    // 0xc1730c: b               #0xc17350
    // 0xc17310: ldur            x0, [fp, #-8]
    // 0xc17314: cmp             x0, #1
    // 0xc17318: b.le            #0xc1732c
    // 0xc1731c: ldur            x16, [fp, #-0x10]
    // 0xc17320: stp             xzr, x16, [SP]
    // 0xc17324: r0 = []()
    //     0xc17324: bl              #0x6e4858  ; [dart:core] _StringBase::[]
    // 0xc17328: b               #0xc17330
    // 0xc1732c: r0 = "0"
    //     0xc1732c: ldr             x0, [PP, #0x42e8]  ; [pp+0x42e8] "0"
    // 0xc17330: r1 = LoadClassIdInstr(r0)
    //     0xc17330: ldur            x1, [x0, #-1]
    //     0xc17334: ubfx            x1, x1, #0xc, #0x14
    // 0xc17338: r16 = "X"
    //     0xc17338: ldr             x16, [PP, #0x5398]  ; [pp+0x5398] "X"
    // 0xc1733c: stp             x16, x0, [SP]
    // 0xc17340: mov             x0, x1
    // 0xc17344: mov             lr, x0
    // 0xc17348: ldr             lr, [x21, lr, lsl #3]
    // 0xc1734c: blr             lr
    // 0xc17350: LeaveFrame
    //     0xc17350: mov             SP, fp
    //     0xc17354: ldp             fp, lr, [SP], #0x10
    // 0xc17358: ret
    //     0xc17358: ret
    // 0xc1735c: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xc1735c: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xc17360: b               #0xc172bc
  }
}
