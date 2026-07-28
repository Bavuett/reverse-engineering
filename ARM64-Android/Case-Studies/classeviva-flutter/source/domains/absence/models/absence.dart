// lib: , url: package:classeviva/domains/absence/models/absence.dart
//
// NOTE: trimmed for this case study. The original blutter dump for this file runs to ~1200 lines
// (freezed-generated copyWith/equality/hashCode boilerplate for `Absence` and `HourlyAbsence`
// makes up most of what's cut). Kept here: the two top-level enum-dispatch helpers
// (AbsenceColors.getTypeColor, AbsenceLocalizations.absenceAbbreviationName), the class hierarchy
// freezed generates for an immutable `Absence` model, and `_Absence`'s `hourlyAbsences` getter and
// `toString()` — enough to see object layout, enum-pointer dispatch, and a real write-barrier in
// context. See this case study's notes/ for what each excerpt is used to illustrate.

// class id: 1048821, size: 0x8
class :: {

  static _ AbsenceColors.getTypeColor(/* No info */) {
    // ** addr: 0xd542b4, size: 0x14c
    // 0xd542b4: EnterFrame
    //     0xd542b4: stp             fp, lr, [SP, #-0x10]!
    //     0xd542b8: mov             fp, SP
    // 0xd542bc: AllocStack(0x10)
    //     0xd542bc: sub             SP, SP, #0x10
    // 0xd542c0: SetupParameters(dynamic _ /* r1 => r0 */, dynamic _ /* r2 => r1, fp-0x8 */)
    //     0xd542c0: mov             x0, x1
    //     0xd542c4: mov             x1, x2
    //     0xd542c8: stur            x2, [fp, #-8]
    // 0xd542cc: CheckStackOverflow
    //     0xd542cc: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xd542d0: cmp             SP, x16
    //     0xd542d4: b.ls            #0xd543e4
    // 0xd542d8: LoadField: r2 = r0->field_f
    //     0xd542d8: ldur            w2, [x0, #0xf]
    // 0xd542dc: DecompressPointer r2
    //     0xd542dc: add             x2, x2, HEAP, lsl #32
    // 0xd542e0: r16 = Instance_AbsenceType
    //     0xd542e0: add             x16, PP, #9, lsl #12  ; [pp+0x96a0] Obj!AbsenceType@119c391
    //     0xd542e4: ldr             x16, [x16, #0x6a0]
    // 0xd542e8: cmp             w2, w16
    // 0xd542ec: b.ne            #0xd5435c
    // 0xd542f0: LoadField: r2 = r0->field_27
    //     0xd542f0: ldur            w2, [x0, #0x27]
    // 0xd542f4: DecompressPointer r2
    //     0xd542f4: add             x2, x2, HEAP, lsl #32
    // 0xd542f8: r0 = LoadClassIdInstr(r2)
    //     0xd542f8: ldur            x0, [x2, #-1]
    //     0xd542fc: ubfx            x0, x0, #0xc, #0x14
    // 0xd54300: str             x2, [SP]
    // 0xd54304: r0 = GDT[cid_x0 + 0x10dab]()
    //     0xd54304: movz            x17, #0xdab
    //     0xd54308: movk            x17, #0x1, lsl #16
    //     0xd5430c: add             lr, x0, x17
    //     0xd54310: ldr             lr, [x21, lr, lsl #3]
    //     0xd54314: blr             lr
    // 0xd54318: cbz             w0, #0xd5433c
    // 0xd5431c: ldur            x1, [fp, #-8]
    // 0xd54320: r0 = BuildContextExtensions.absenceTypeColor()
    //     0xd54320: bl              #0xd54400  ; [package:classeviva/core/extensions/context_extentions.dart] ::BuildContextExtensions.absenceTypeColor
    // 0xd54324: cmp             w0, NULL
    // 0xd54328: b.eq            #0xd543ec
    // 0xd5432c: ArrayLoad: r1 = r0[0]  ; List_4
    //     0xd5432c: ldur            w1, [x0, #0x17]
    // 0xd54330: DecompressPointer r1
    //     0xd54330: add             x1, x1, HEAP, lsl #32
    // 0xd54334: mov             x0, x1
    // 0xd54338: b               #0xd543d8
    // 0xd5433c: ldur            x1, [fp, #-8]
    // 0xd54340: r0 = BuildContextExtensions.absenceTypeColor()
    //     0xd54340: bl              #0xd54400  ; [package:classeviva/core/extensions/context_extentions.dart] ::BuildContextExtensions.absenceTypeColor
    // 0xd54344: cmp             w0, NULL
    // 0xd54348: b.eq            #0xd543f0
    // 0xd5434c: LoadField: r1 = r0->field_b
    //     0xd5434c: ldur            w1, [x0, #0xb]
    // 0xd54350: DecompressPointer r1
    //     0xd54350: add             x1, x1, HEAP, lsl #32
    // 0xd54354: mov             x0, x1
    // 0xd54358: b               #0xd543d8
    // 0xd5435c: r16 = Instance_AbsenceType
    //     0xd5435c: add             x16, PP, #9, lsl #12  ; [pp+0x96e0] Obj!AbsenceType@119c311
    //     0xd54360: ldr             x16, [x16, #0x6e0]
    // 0xd54364: cmp             w2, w16
    // 0xd54368: b.ne            #0xd5438c
    // 0xd5436c: ldur            x1, [fp, #-8]
    // 0xd54370: r0 = BuildContextExtensions.absenceTypeColor()
    //     0xd54370: bl              #0xd54400  ; [package:classeviva/core/extensions/context_extentions.dart] ::BuildContextExtensions.absenceTypeColor
    // 0xd54374: cmp             w0, NULL
    // 0xd54378: b.eq            #0xd543f4
    // 0xd5437c: LoadField: r1 = r0->field_f
    //     0xd5437c: ldur            w1, [x0, #0xf]
    // 0xd54380: DecompressPointer r1
    //     0xd54380: add             x1, x1, HEAP, lsl #32
    // 0xd54384: mov             x0, x1
    // 0xd54388: b               #0xd543d8
    // 0xd5438c: r16 = Instance_AbsenceType
    //     0xd5438c: add             x16, PP, #9, lsl #12  ; [pp+0x96b0] Obj!AbsenceType@119c371
    //     0xd54390: ldr             x16, [x16, #0x6b0]
    // 0xd54394: cmp             w2, w16
    // 0xd54398: b.ne            #0xd543bc
    // 0xd5439c: ldur            x1, [fp, #-8]
    // 0xd543a0: r0 = BuildContextExtensions.absenceTypeColor()
    //     0xd543a0: bl              #0xd54400  ; [package:classeviva/core/extensions/context_extentions.dart] ::BuildContextExtensions.absenceTypeColor
    // 0xd543a4: cmp             w0, NULL
    // 0xd543a8: b.eq            #0xd543f8
    // 0xd543ac: ArrayLoad: r1 = r0[0]  ; List_4
    //     0xd543ac: ldur            w1, [x0, #0x17]
    // 0xd543b0: DecompressPointer r1
    //     0xd543b0: add             x1, x1, HEAP, lsl #32
    // 0xd543b4: mov             x0, x1
    // 0xd543b8: b               #0xd543d8
    // 0xd543bc: ldur            x1, [fp, #-8]
    // 0xd543c0: r0 = BuildContextExtensions.absenceTypeColor()
    //     0xd543c0: bl              #0xd54400  ; [package:classeviva/core/extensions/context_extentions.dart] ::BuildContextExtensions.absenceTypeColor
    // 0xd543c4: cmp             w0, NULL
    // 0xd543c8: b.eq            #0xd543fc
    // 0xd543cc: LoadField: r1 = r0->field_13
    //     0xd543cc: ldur            w1, [x0, #0x13]
    // 0xd543d0: DecompressPointer r1
    //     0xd543d0: add             x1, x1, HEAP, lsl #32
    // 0xd543d4: mov             x0, x1
    // 0xd543d8: LeaveFrame
    //     0xd543d8: mov             SP, fp
    //     0xd543dc: ldp             fp, lr, [SP], #0x10
    // 0xd543e0: ret
    //     0xd543e0: ret
    // 0xd543e4: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xd543e4: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xd543e8: b               #0xd542d8
    // 0xd543ec: r0 = NullErrorSharedWithoutFPURegs()
    //     0xd543ec: bl              #0x10cc784  ; NullErrorSharedWithoutFPURegsStub
    // 0xd543f0: r0 = NullErrorSharedWithoutFPURegs()
    //     0xd543f0: bl              #0x10cc784  ; NullErrorSharedWithoutFPURegsStub
    // 0xd543f4: r0 = NullErrorSharedWithoutFPURegs()
    //     0xd543f4: bl              #0x10cc784  ; NullErrorSharedWithoutFPURegsStub
    // 0xd543f8: r0 = NullErrorSharedWithoutFPURegs()
    //     0xd543f8: bl              #0x10cc784  ; NullErrorSharedWithoutFPURegsStub
    // 0xd543fc: r0 = NullErrorSharedWithoutFPURegs()
    //     0xd543fc: bl              #0x10cc784  ; NullErrorSharedWithoutFPURegsStub
  }
  static _ AbsenceLocalizations.absenceAbbreviationName(/* No info */) {
    // ** addr: 0xdb27fc, size: 0x384
    // 0xdb27fc: EnterFrame
    //     0xdb27fc: stp             fp, lr, [SP, #-0x10]!
    //     0xdb2800: mov             fp, SP
    // 0xdb2804: AllocStack(0x10)
    //     0xdb2804: sub             SP, SP, #0x10
    // 0xdb2808: SetupParameters(dynamic _ /* r2 => r0, fp-0x8 */)
    //     0xdb2808: mov             x0, x2
    //     0xdb280c: stur            x2, [fp, #-8]
    // 0xdb2810: CheckStackOverflow
    //     0xdb2810: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xdb2814: cmp             SP, x16
    //     0xdb2818: b.ls            #0xdb2b78
    // 0xdb281c: LoadField: r2 = r1->field_f
    //     0xdb281c: ldur            w2, [x1, #0xf]
    // 0xdb2820: DecompressPointer r2
    //     0xdb2820: add             x2, x2, HEAP, lsl #32
    // 0xdb2824: r16 = Instance_AbsenceType
    //     0xdb2824: add             x16, PP, #9, lsl #12  ; [pp+0x96a0] Obj!AbsenceType@119c391
    //     0xdb2828: ldr             x16, [x16, #0x6a0]
    // 0xdb282c: cmp             w2, w16
    // 0xdb2830: b.ne            #0xdb2954
    // 0xdb2834: r0 = isPartialAbsences()
    //     0xdb2834: bl              #0xdb2b80  ; [package:classeviva/domains/absence/models/absence.dart] Absence::isPartialAbsences
    // 0xdb2838: tbnz            w0, #4, #0xdb28ac
    // 0xdb283c: ldur            x1, [fp, #-8]
    // 0xdb2840: r0 = of()
    //     0xdb2840: bl              #0x7a3d20  ; [package:classeviva/core/localization/cvv_app_localizations.dart] CvvAppLocalizations::of
    // 0xdb2844: cmp             w0, NULL
    // 0xdb2848: b.ne            #0xdb2854
    // 0xdb284c: r0 = Null
    //     0xdb284c: mov             x0, NULL
    // 0xdb2850: b               #0xdb2894
    // 0xdb2854: r1 = LoadClassIdInstr(r0)
    //     0xdb2854: ldur            x1, [x0, #-1]
    //     0xdb2858: ubfx            x1, x1, #0xc, #0x14
    // 0xdb285c: r17 = 8489
    //     0xdb285c: movz            x17, #0x2129
    // 0xdb2860: cmp             x1, x17
    // 0xdb2864: b.ne            #0xdb2874
    // 0xdb2868: r0 = "Assenze Parziali"
    //     0xdb2868: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c410] "Assenze Parziali"
    //     0xdb286c: ldr             x0, [x0, #0x410]
    // 0xdb2870: b               #0xdb2894
    // 0xdb2874: r17 = 8490
    //     0xdb2874: movz            x17, #0x212a
    // 0xdb2878: cmp             x1, x17
    // 0xdb287c: b.ne            #0xdb288c
    // 0xdb2880: r0 = "Ausencias parciales"
    //     0xdb2880: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c418] "Ausencias parciales"
    //     0xdb2884: ldr             x0, [x0, #0x418]
    // 0xdb2888: b               #0xdb2894
    // 0xdb288c: r0 = "Partial Absences"
    //     0xdb288c: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c420] "Partial Absences"
    //     0xdb2890: ldr             x0, [x0, #0x420]
    // 0xdb2894: cmp             w0, NULL
    // 0xdb2898: b.ne            #0xdb28a4
    // 0xdb289c: r0 = "label_partial_absences"
    //     0xdb289c: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c428] "label_partial_absences"
    //     0xdb28a0: ldr             x0, [x0, #0x428]
    // 0xdb28a4: mov             x1, x0
    // 0xdb28a8: b               #0xdb2918
    // 0xdb28ac: ldur            x1, [fp, #-8]
    // 0xdb28b0: r0 = of()
    //     0xdb28b0: bl              #0x7a3d20  ; [package:classeviva/core/localization/cvv_app_localizations.dart] CvvAppLocalizations::of
    // 0xdb28b4: cmp             w0, NULL
    // 0xdb28b8: b.ne            #0xdb28c4
    // 0xdb28bc: r0 = Null
    //     0xdb28bc: mov             x0, NULL
    // 0xdb28c0: b               #0xdb2904
    // 0xdb28c4: r1 = LoadClassIdInstr(r0)
    //     0xdb28c4: ldur            x1, [x0, #-1]
    //     0xdb28c8: ubfx            x1, x1, #0xc, #0x14
    // 0xdb28cc: r17 = 8489
    //     0xdb28cc: movz            x17, #0x2129
    // 0xdb28d0: cmp             x1, x17
    // 0xdb28d4: b.ne            #0xdb28e4
    // 0xdb28d8: r0 = "Assenze"
    //     0xdb28d8: add             x0, PP, #0x28, lsl #12  ; [pp+0x284d8] "Assenze"
    //     0xdb28dc: ldr             x0, [x0, #0x4d8]
    // 0xdb28e0: b               #0xdb2904
    // 0xdb28e4: r17 = 8490
    //     0xdb28e4: movz            x17, #0x212a
    // 0xdb28e8: cmp             x1, x17
    // 0xdb28ec: b.ne            #0xdb28fc
    // 0xdb28f0: r0 = "Ausencias"
    //     0xdb28f0: add             x0, PP, #0x28, lsl #12  ; [pp+0x284e0] "Ausencias"
    //     0xdb28f4: ldr             x0, [x0, #0x4e0]
    // 0xdb28f8: b               #0xdb2904
    // 0xdb28fc: r0 = "Absences"
    //     0xdb28fc: add             x0, PP, #0x28, lsl #12  ; [pp+0x284e8] "Absences"
    //     0xdb2900: ldr             x0, [x0, #0x4e8]
    // 0xdb2904: cmp             w0, NULL
    // 0xdb2908: b.ne            #0xdb2914
    // 0xdb290c: r0 = "label_absences"
    //     0xdb290c: add             x0, PP, #0x28, lsl #12  ; [pp+0x284f0] "label_absences"
    //     0xdb2910: ldr             x0, [x0, #0x4f0]
    // 0xdb2914: mov             x1, x0
    // 0xdb2918: r16 = 2
    //     0xdb2918: movz            x16, #0x2
    // 0xdb291c: str             x16, [SP]
    // 0xdb2920: r2 = 0
    //     0xdb2920: movz            x2, #0
    // 0xdb2924: r4 = const [0, 0x3, 0x1, 0x3, null]
    //     0xdb2924: ldr             x4, [PP, #0xbe8]  ; [pp+0xbe8] List(5) [0, 0x3, 0x1, 0x3, Null]
    // 0xdb2928: r0 = substring()
    //     0xdb2928: bl              #0x6e5b74  ; [dart:core] _StringBase::substring
    // 0xdb292c: r1 = LoadClassIdInstr(r0)
    //     0xdb292c: ldur            x1, [x0, #-1]
    //     0xdb2930: ubfx            x1, x1, #0xc, #0x14
    // 0xdb2934: str             x0, [SP]
    // 0xdb2938: mov             x0, x1
    // 0xdb293c: r0 = GDT[cid_x0 + -0xff8]()
    //     0xdb293c: sub             lr, x0, #0xff8
    //     0xdb2940: ldr             lr, [x21, lr, lsl #3]
    //     0xdb2944: blr             lr
    // 0xdb2948: LeaveFrame
    //     0xdb2948: mov             SP, fp
    //     0xdb294c: ldp             fp, lr, [SP], #0x10
    // 0xdb2950: ret
    //     0xdb2950: ret
    // 0xdb2954: r16 = Instance_AbsenceType
    //     0xdb2954: add             x16, PP, #9, lsl #12  ; [pp+0x96b0] Obj!AbsenceType@119c371
    //     0xdb2958: ldr             x16, [x16, #0x6b0]
    // 0xdb295c: cmp             w2, w16
    // 0xdb2960: b.ne            #0xdb2a10
    // 0xdb2964: ldur            x1, [fp, #-8]
    // 0xdb2968: r0 = of()
    //     0xdb2968: bl              #0x7a3d20  ; [package:classeviva/core/localization/cvv_app_localizations.dart] CvvAppLocalizations::of
    // 0xdb296c: cmp             w0, NULL
    // 0xdb2970: b.ne            #0xdb297c
    // 0xdb2974: r0 = Null
    //     0xdb2974: mov             x0, NULL
    // 0xdb2978: b               #0xdb29bc
    // 0xdb297c: r1 = LoadClassIdInstr(r0)
    //     0xdb297c: ldur            x1, [x0, #-1]
    //     0xdb2980: ubfx            x1, x1, #0xc, #0x14
    // 0xdb2984: r17 = 8489
    //     0xdb2984: movz            x17, #0x2129
    // 0xdb2988: cmp             x1, x17
    // 0xdb298c: b.ne            #0xdb299c
    // 0xdb2990: r0 = "Assenze Parziali"
    //     0xdb2990: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c410] "Assenze Parziali"
    //     0xdb2994: ldr             x0, [x0, #0x410]
    // 0xdb2998: b               #0xdb29bc
    // 0xdb299c: r17 = 8490
    //     0xdb299c: movz            x17, #0x212a
    // 0xdb29a0: cmp             x1, x17
    // 0xdb29a4: b.ne            #0xdb29b4
    // 0xdb29a8: r0 = "Ausencias parciales"
    //     0xdb29a8: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c418] "Ausencias parciales"
    //     0xdb29ac: ldr             x0, [x0, #0x418]
    // 0xdb29b0: b               #0xdb29bc
    // 0xdb29b4: r0 = "Partial Absences"
    //     0xdb29b4: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c420] "Partial Absences"
    //     0xdb29b8: ldr             x0, [x0, #0x420]
    // 0xdb29bc: cmp             w0, NULL
    // 0xdb29c0: b.ne            #0xdb29d0
    // 0xdb29c4: r1 = "label_partial_absences"
    //     0xdb29c4: add             x1, PP, #0x2c, lsl #12  ; [pp+0x2c428] "label_partial_absences"
    //     0xdb29c8: ldr             x1, [x1, #0x428]
    // 0xdb29cc: b               #0xdb29d4
    // 0xdb29d0: mov             x1, x0
    // 0xdb29d4: r16 = 2
    //     0xdb29d4: movz            x16, #0x2
    // 0xdb29d8: str             x16, [SP]
    // 0xdb29dc: r2 = 0
    //     0xdb29dc: movz            x2, #0
    // 0xdb29e0: r4 = const [0, 0x3, 0x1, 0x3, null]
    //     0xdb29e0: ldr             x4, [PP, #0xbe8]  ; [pp+0xbe8] List(5) [0, 0x3, 0x1, 0x3, Null]
    // 0xdb29e4: r0 = substring()
    //     0xdb29e4: bl              #0x6e5b74  ; [dart:core] _StringBase::substring
    // 0xdb29e8: r1 = LoadClassIdInstr(r0)
    //     0xdb29e8: ldur            x1, [x0, #-1]
    //     0xdb29ec: ubfx            x1, x1, #0xc, #0x14
    // 0xdb29f0: str             x0, [SP]
    // 0xdb29f4: mov             x0, x1
    // 0xdb29f8: r0 = GDT[cid_x0 + -0xff8]()
    //     0xdb29f8: sub             lr, x0, #0xff8
    //     0xdb29fc: ldr             lr, [x21, lr, lsl #3]
    //     0xdb2a00: blr             lr
    // 0xdb2a04: LeaveFrame
    //     0xdb2a04: mov             SP, fp
    //     0xdb2a08: ldp             fp, lr, [SP], #0x10
    // 0xdb2a0c: ret
    //     0xdb2a0c: ret
    // 0xdb2a10: r16 = Instance_AbsenceType
    //     0xdb2a10: add             x16, PP, #9, lsl #12  ; [pp+0x96e0] Obj!AbsenceType@119c311
    //     0xdb2a14: ldr             x16, [x16, #0x6e0]
    // 0xdb2a18: cmp             w2, w16
    // 0xdb2a1c: b.ne            #0xdb2acc
    // 0xdb2a20: ldur            x1, [fp, #-8]
    // 0xdb2a24: r0 = of()
    //     0xdb2a24: bl              #0x7a3d20  ; [package:classeviva/core/localization/cvv_app_localizations.dart] CvvAppLocalizations::of
    // 0xdb2a28: cmp             w0, NULL
    // 0xdb2a2c: b.ne            #0xdb2a38
    // 0xdb2a30: r0 = Null
    //     0xdb2a30: mov             x0, NULL
    // 0xdb2a34: b               #0xdb2a78
    // 0xdb2a38: r1 = LoadClassIdInstr(r0)
    //     0xdb2a38: ldur            x1, [x0, #-1]
    //     0xdb2a3c: ubfx            x1, x1, #0xc, #0x14
    // 0xdb2a40: r17 = 8489
    //     0xdb2a40: movz            x17, #0x2129
    // 0xdb2a44: cmp             x1, x17
    // 0xdb2a48: b.ne            #0xdb2a58
    // 0xdb2a4c: r0 = "Uscite"
    //     0xdb2a4c: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c430] "Uscite"
    //     0xdb2a50: ldr             x0, [x0, #0x430]
    // 0xdb2a54: b               #0xdb2a78
    // 0xdb2a58: r17 = 8490
    //     0xdb2a58: movz            x17, #0x212a
    // 0xdb2a5c: cmp             x1, x17
    // 0xdb2a60: b.ne            #0xdb2a70
    // 0xdb2a64: r0 = "Salidas"
    //     0xdb2a64: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c438] "Salidas"
    //     0xdb2a68: ldr             x0, [x0, #0x438]
    // 0xdb2a6c: b               #0xdb2a78
    // 0xdb2a70: r0 = "Exits"
    //     0xdb2a70: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c440] "Exits"
    //     0xdb2a74: ldr             x0, [x0, #0x440]
    // 0xdb2a78: cmp             w0, NULL
    // 0xdb2a7c: b.ne            #0xdb2a8c
    // 0xdb2a80: r1 = "label_exits"
    //     0xdb2a80: add             x1, PP, #0x2c, lsl #12  ; [pp+0x2c448] "label_exits"
    //     0xdb2a84: ldr             x1, [x1, #0x448]
    // 0xdb2a88: b               #0xdb2a90
    // 0xdb2a8c: mov             x1, x0
    // 0xdb2a90: r16 = 2
    //     0xdb2a90: movz            x16, #0x2
    // 0xdb2a94: str             x16, [SP]
    // 0xdb2a98: r2 = 0
    //     0xdb2a98: movz            x2, #0
    // 0xdb2a9c: r4 = const [0, 0x3, 0x1, 0x3, null]
    //     0xdb2a9c: ldr             x4, [PP, #0xbe8]  ; [pp+0xbe8] List(5) [0, 0x3, 0x1, 0x3, Null]
    // 0xdb2aa0: r0 = substring()
    //     0xdb2aa0: bl              #0x6e5b74  ; [dart:core] _StringBase::substring
    // 0xdb2aa4: r1 = LoadClassIdInstr(r0)
    //     0xdb2aa4: ldur            x1, [x0, #-1]
    //     0xdb2aa8: ubfx            x1, x1, #0xc, #0x14
    // 0xdb2aac: str             x0, [SP]
    // 0xdb2ab0: mov             x0, x1
    // 0xdb2ab4: r0 = GDT[cid_x0 + -0xff8]()
    //     0xdb2ab4: sub             lr, x0, #0xff8
    //     0xdb2ab8: ldr             lr, [x21, lr, lsl #3]
    //     0xdb2abc: blr             lr
    // 0xdb2ac0: LeaveFrame
    //     0xdb2ac0: mov             SP, fp
    //     0xdb2ac4: ldp             fp, lr, [SP], #0x10
    // 0xdb2ac8: ret
    //     0xdb2ac8: ret
    // 0xdb2acc: ldur            x1, [fp, #-8]
    // 0xdb2ad0: r0 = of()
    //     0xdb2ad0: bl              #0x7a3d20  ; [package:classeviva/core/localization/cvv_app_localizations.dart] CvvAppLocalizations::of
    // 0xdb2ad4: cmp             w0, NULL
    // 0xdb2ad8: b.ne            #0xdb2ae4
    // 0xdb2adc: r0 = Null
    //     0xdb2adc: mov             x0, NULL
    // 0xdb2ae0: b               #0xdb2b24
    // 0xdb2ae4: r1 = LoadClassIdInstr(r0)
    //     0xdb2ae4: ldur            x1, [x0, #-1]
    //     0xdb2ae8: ubfx            x1, x1, #0xc, #0x14
    // 0xdb2aec: r17 = 8489
    //     0xdb2aec: movz            x17, #0x2129
    // 0xdb2af0: cmp             x1, x17
    // 0xdb2af4: b.ne            #0xdb2b04
    // 0xdb2af8: r0 = "Ritardi"
    //     0xdb2af8: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c3f0] "Ritardi"
    //     0xdb2afc: ldr             x0, [x0, #0x3f0]
    // 0xdb2b00: b               #0xdb2b24
    // 0xdb2b04: r17 = 8490
    //     0xdb2b04: movz            x17, #0x212a
    // 0xdb2b08: cmp             x1, x17
    // 0xdb2b0c: b.ne            #0xdb2b1c
    // 0xdb2b10: r0 = "Retrasos"
    //     0xdb2b10: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c3f8] "Retrasos"
    //     0xdb2b14: ldr             x0, [x0, #0x3f8]
    // 0xdb2b18: b               #0xdb2b24
    // 0xdb2b1c: r0 = "Tardiness"
    //     0xdb2b1c: add             x0, PP, #0x2c, lsl #12  ; [pp+0x2c400] "Tardiness"
    //     0xdb2b20: ldr             x0, [x0, #0x400]
    // 0xdb2b24: cmp             w0, NULL
    // 0xdb2b28: b.ne            #0xdb2b38
    // 0xdb2b2c: r1 = "label_delays"
    //     0xdb2b2c: add             x1, PP, #0x2c, lsl #12  ; [pp+0x2c408] "label_delays"
    //     0xdb2b30: ldr             x1, [x1, #0x408]
    // 0xdb2b34: b               #0xdb2b3c
    // 0xdb2b38: mov             x1, x0
    // 0xdb2b3c: r16 = 2
    //     0xdb2b3c: movz            x16, #0x2
    // 0xdb2b40: str             x16, [SP]
    // 0xdb2b44: r2 = 0
    //     0xdb2b44: movz            x2, #0
    // 0xdb2b48: r4 = const [0, 0x3, 0x1, 0x3, null]
    //     0xdb2b48: ldr             x4, [PP, #0xbe8]  ; [pp+0xbe8] List(5) [0, 0x3, 0x1, 0x3, Null]
    // 0xdb2b4c: r0 = substring()
    //     0xdb2b4c: bl              #0x6e5b74  ; [dart:core] _StringBase::substring
    // 0xdb2b50: r1 = LoadClassIdInstr(r0)
    //     0xdb2b50: ldur            x1, [x0, #-1]
    //     0xdb2b54: ubfx            x1, x1, #0xc, #0x14
    // 0xdb2b58: str             x0, [SP]
    // 0xdb2b5c: mov             x0, x1
    // 0xdb2b60: r0 = GDT[cid_x0 + -0xff8]()
    //     0xdb2b60: sub             lr, x0, #0xff8
    //     0xdb2b64: ldr             lr, [x21, lr, lsl #3]
    //     0xdb2b68: blr             lr
    // 0xdb2b6c: LeaveFrame
    //     0xdb2b6c: mov             SP, fp
    //     0xdb2b70: ldp             fp, lr, [SP], #0x10
    // 0xdb2b74: ret
    //     0xdb2b74: ret
    // 0xdb2b78: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xdb2b78: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xdb2b7c: b               #0xdb281c
  }
}

// class id: 7718, size: 0x14, field offset: 0x8
class __$AbsenceCopyWithImpl<X0> extends Object
    implements _$AbsenceCopyWith<X0> {
}

// class id: 7719, size: 0xc, field offset: 0x8
abstract class _$AbsenceCopyWith<X0> extends Object
    implements $AbsenceCopyWith<X0> {
}

// class id: 7720, size: 0xc, field offset: 0x8
abstract class $AbsenceCopyWith<X0> extends Object {
}

// class id: 7721, size: 0x8, field offset: 0x8
abstract class _$Absence extends Object {
}

// class id: 7722, size: 0x8, field offset: 0x8
//   const constructor, transformed mixin,
abstract class _Absence&Object&_$Absence extends Object
     with _$Absence {
}

// class id: 7723, size: 0x8, field offset: 0x8
//   const constructor,
abstract class Absence extends _Absence&Object&_$Absence {

  get _ isPartialAbsences(/* No info */) {
    // ** addr: 0xdb2b80, size: 0x6c
    // 0xdb2b80: EnterFrame
    //     0xdb2b80: stp             fp, lr, [SP, #-0x10]!
    //     0xdb2b84: mov             fp, SP
    // 0xdb2b88: AllocStack(0x8)
    //     0xdb2b88: sub             SP, SP, #8
    // 0xdb2b8c: CheckStackOverflow
    //     0xdb2b8c: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xdb2b90: cmp             SP, x16
    //     0xdb2b94: b.ls            #0xdb2be4
    // 0xdb2b98: LoadField: r0 = r1->field_27
    //     0xdb2b98: ldur            w0, [x1, #0x27]
    // 0xdb2b9c: DecompressPointer r0
    //     0xdb2b9c: add             x0, x0, HEAP, lsl #32
    // 0xdb2ba0: r1 = LoadClassIdInstr(r0)
    //     0xdb2ba0: ldur            x1, [x0, #-1]
    //     0xdb2ba4: ubfx            x1, x1, #0xc, #0x14
    // 0xdb2ba8: str             x0, [SP]
    // 0xdb2bac: mov             x0, x1
    // 0xdb2bb0: r0 = GDT[cid_x0 + 0x10dab]()
    //     0xdb2bb0: movz            x17, #0xdab
    //     0xdb2bb4: movk            x17, #0x1, lsl #16
    //     0xdb2bb8: add             lr, x0, x17
    //     0xdb2bbc: ldr             lr, [x21, lr, lsl #3]
    //     0xdb2bc0: blr             lr
    // 0xdb2bc4: cbnz            w0, #0xdb2bd0
    // 0xdb2bc8: r1 = false
    //     0xdb2bc8: add             x1, NULL, #0x30  ; false
    // 0xdb2bcc: b               #0xdb2bd4
    // 0xdb2bd0: r1 = true
    //     0xdb2bd0: add             x1, NULL, #0x20  ; true
    // 0xdb2bd4: mov             x0, x1
    // 0xdb2bd8: LeaveFrame
    //     0xdb2bd8: mov             SP, fp
    //     0xdb2bdc: ldp             fp, lr, [SP], #0x10
    // 0xdb2be0: ret
    //     0xdb2be0: ret
    // 0xdb2be4: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xdb2be4: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xdb2be8: b               #0xdb2b98
  }
}

// class id: 7724, size: 0x34, field offset: 0x8
//   const constructor,
class _Absence extends Absence {

  get _ hourlyAbsences(/* No info */) {
    // ** addr: 0x893bbc, size: 0x3c
    // 0x893bbc: EnterFrame
    //     0x893bbc: stp             fp, lr, [SP, #-0x10]!
    //     0x893bc0: mov             fp, SP
    // 0x893bc4: AllocStack(0x8)
    //     0x893bc4: sub             SP, SP, #8
    // 0x893bc8: LoadField: r0 = r1->field_27
    //     0x893bc8: ldur            w0, [x1, #0x27]
    // 0x893bcc: DecompressPointer r0
    //     0x893bcc: add             x0, x0, HEAP, lsl #32
    // 0x893bd0: stur            x0, [fp, #-8]
    // 0x893bd4: r1 = <HourlyAbsence>
    //     0x893bd4: add             x1, PP, #0x25, lsl #12  ; [pp+0x25418] TypeArguments: <HourlyAbsence>
    //     0x893bd8: ldr             x1, [x1, #0x418]
    // 0x893bdc: r0 = EqualUnmodifiableListView()
    //     0x893bdc: bl              #0x761510  ; AllocateEqualUnmodifiableListViewStub -> EqualUnmodifiableListView<X0> (size=0x14)
    // 0x893be0: ldur            x1, [fp, #-8]
    // 0x893be4: StoreField: r0->field_f = r1
    //     0x893be4: stur            w1, [x0, #0xf]
    // 0x893be8: StoreField: r0->field_b = r1
    //     0x893be8: stur            w1, [x0, #0xb]
    // 0x893bec: LeaveFrame
    //     0x893bec: mov             SP, fp
    //     0x893bf0: ldp             fp, lr, [SP], #0x10
    // 0x893bf4: ret
    //     0x893bf4: ret
  }
  _ toString(/* No info */) {
    // ** addr: 0xe3cfb0, size: 0x2c4
    // 0xe3cfb0: EnterFrame
    //     0xe3cfb0: stp             fp, lr, [SP, #-0x10]!
    //     0xe3cfb4: mov             fp, SP
    // 0xe3cfb8: AllocStack(0x18)
    //     0xe3cfb8: sub             SP, SP, #0x18
    // 0xe3cfbc: CheckStackOverflow
    //     0xe3cfbc: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0xe3cfc0: cmp             SP, x16
    //     0xe3cfc4: b.ls            #0xe3d26c
    // 0xe3cfc8: r1 = Null
    //     0xe3cfc8: mov             x1, NULL
    // 0xe3cfcc: r2 = 42
    //     0xe3cfcc: movz            x2, #0x2a
    // 0xe3cfd0: r0 = AllocateArray()
    //     0xe3cfd0: bl              #0x10cbe44  ; AllocateArrayStub
    // 0xe3cfd4: mov             x2, x0
    // 0xe3cfd8: stur            x2, [fp, #-0x10]
    // 0xe3cfdc: r16 = "Absence(id: "
    //     0xe3cfdc: add             x16, PP, #0x37, lsl #12  ; [pp+0x37aa8] "Absence(id: "
    //     0xe3cfe0: ldr             x16, [x16, #0xaa8]
    // 0xe3cfe4: StoreField: r2->field_f = r16
    //     0xe3cfe4: stur            w16, [x2, #0xf]
    // 0xe3cfe8: ldr             x3, [fp, #0x10]
    // 0xe3cfec: LoadField: r4 = r3->field_7
    //     0xe3cfec: ldur            x4, [x3, #7]
    // 0xe3cff0: r0 = BoxInt64Instr(r4)
    //     0xe3cff0: sbfiz           x0, x4, #1, #0x1f
    //     0xe3cff4: cmp             x4, x0, asr #1
    //     0xe3cff8: b.eq            #0xe3d004
    //     0xe3cffc: bl              #0x10cc0cc  ; AllocateMintSharedWithoutFPURegsStub
    //     0xe3d000: stur            x4, [x0, #7]
    // 0xe3d004: mov             x1, x2
    // 0xe3d008: ArrayStore: r1[1] = r0  ; List_4
    //     0xe3d008: add             x25, x1, #0x13
    //     0xe3d00c: str             w0, [x25]
    //     0xe3d010: tbz             w0, #0, #0xe3d02c
    //     0xe3d014: ldurb           w16, [x1, #-1]
    //     0xe3d018: ldurb           w17, [x0, #-1]
    //     0xe3d01c: and             x16, x17, x16, lsr #2
    //     0xe3d020: tst             x16, HEAP, lsr #32
    //     0xe3d024: b.eq            #0xe3d02c
    //     0xe3d028: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xe3d02c: r16 = ", code: "
    //     0xe3d02c: add             x16, PP, #0x2e, lsl #12  ; [pp+0x2e2d0] ", code: "
    //     0xe3d030: ldr             x16, [x16, #0x2d0]
    // 0xe3d034: ArrayStore: r2[0] = r16  ; List_4
    //     0xe3d034: stur            w16, [x2, #0x17]
    // 0xe3d038: LoadField: r0 = r3->field_f
    //     0xe3d038: ldur            w0, [x3, #0xf]
    // 0xe3d03c: DecompressPointer r0
    //     0xe3d03c: add             x0, x0, HEAP, lsl #32
    // 0xe3d040: mov             x1, x2
    // 0xe3d044: ArrayStore: r1[3] = r0  ; List_4
    //     0xe3d044: add             x25, x1, #0x1b
    //     0xe3d048: str             w0, [x25]
    //     0xe3d04c: tbz             w0, #0, #0xe3d068
    //     0xe3d050: ldurb           w16, [x1, #-1]
    //     0xe3d054: ldurb           w17, [x0, #-1]
    //     0xe3d058: and             x16, x17, x16, lsr #2
    //     0xe3d05c: tst             x16, HEAP, lsr #32
    //     0xe3d060: b.eq            #0xe3d068
    //     0xe3d064: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xe3d068: r16 = ", date: "
    //     0xe3d068: add             x16, PP, #0x2d, lsl #12  ; [pp+0x2d630] ", date: "
    //     0xe3d06c: ldr             x16, [x16, #0x630]
    // 0xe3d070: StoreField: r2->field_1f = r16
    //     0xe3d070: stur            w16, [x2, #0x1f]
    // 0xe3d074: LoadField: r0 = r3->field_13
    //     0xe3d074: ldur            w0, [x3, #0x13]
    // 0xe3d078: DecompressPointer r0
    //     0xe3d078: add             x0, x0, HEAP, lsl #32
    // 0xe3d07c: mov             x1, x2
    // 0xe3d080: ArrayStore: r1[5] = r0  ; List_4
    //     0xe3d080: add             x25, x1, #0x23
    //     0xe3d084: str             w0, [x25]
    //     0xe3d088: tbz             w0, #0, #0xe3d0a4
    //     0xe3d08c: ldurb           w16, [x1, #-1]
    //     0xe3d090: ldurb           w17, [x0, #-1]
    //     0xe3d094: and             x16, x17, x16, lsr #2
    //     0xe3d098: tst             x16, HEAP, lsr #32
    //     0xe3d09c: b.eq            #0xe3d0a4
    //     0xe3d0a0: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xe3d0a4: r16 = ", hourPosition: "
    //     0xe3d0a4: add             x16, PP, #0x2d, lsl #12  ; [pp+0x2dc90] ", hourPosition: "
    //     0xe3d0a8: ldr             x16, [x16, #0xc90]
    // 0xe3d0ac: StoreField: r2->field_27 = r16
    //     0xe3d0ac: stur            w16, [x2, #0x27]
    // 0xe3d0b0: ArrayLoad: r0 = r3[0]  ; List_4
    //     0xe3d0b0: ldur            w0, [x3, #0x17]
    // 0xe3d0b4: DecompressPointer r0
    //     0xe3d0b4: add             x0, x0, HEAP, lsl #32
    // 0xe3d0b8: mov             x1, x2
    // 0xe3d0bc: ArrayStore: r1[7] = r0  ; List_4
    //     0xe3d0bc: add             x25, x1, #0x2b
    //     0xe3d0c0: str             w0, [x25]
    //     0xe3d0c4: tbz             w0, #0, #0xe3d0e0
    //     0xe3d0c8: ldurb           w16, [x1, #-1]
    //     0xe3d0cc: ldurb           w17, [x0, #-1]
    //     0xe3d0d0: and             x16, x17, x16, lsr #2
    //     0xe3d0d4: tst             x16, HEAP, lsr #32
    //     0xe3d0d8: b.eq            #0xe3d0e0
    //     0xe3d0dc: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xe3d0e0: r16 = ", isJustified: "
    //     0xe3d0e0: add             x16, PP, #0x2e, lsl #12  ; [pp+0x2ea58] ", isJustified: "
    //     0xe3d0e4: ldr             x16, [x16, #0xa58]
    // 0xe3d0e8: StoreField: r2->field_2f = r16
    //     0xe3d0e8: stur            w16, [x2, #0x2f]
    // 0xe3d0ec: LoadField: r0 = r3->field_1b
    //     0xe3d0ec: ldur            w0, [x3, #0x1b]
    // 0xe3d0f0: DecompressPointer r0
    //     0xe3d0f0: add             x0, x0, HEAP, lsl #32
    // 0xe3d0f4: StoreField: r2->field_33 = r0
    //     0xe3d0f4: stur            w0, [x2, #0x33]
    // 0xe3d0f8: r16 = ", justificationReasonCode: "
    //     0xe3d0f8: add             x16, PP, #0x2e, lsl #12  ; [pp+0x2ea60] ", justificationReasonCode: "
    //     0xe3d0fc: ldr             x16, [x16, #0xa60]
    // 0xe3d100: StoreField: r2->field_37 = r16
    //     0xe3d100: stur            w16, [x2, #0x37]
    // 0xe3d104: LoadField: r0 = r3->field_1f
    //     0xe3d104: ldur            w0, [x3, #0x1f]
    // 0xe3d108: DecompressPointer r0
    //     0xe3d108: add             x0, x0, HEAP, lsl #32
    // 0xe3d10c: mov             x1, x2
    // 0xe3d110: ArrayStore: r1[11] = r0  ; List_4
    //     0xe3d110: add             x25, x1, #0x3b
    //     0xe3d114: str             w0, [x25]
    //     0xe3d118: tbz             w0, #0, #0xe3d134
    //     0xe3d11c: ldurb           w16, [x1, #-1]
    //     0xe3d120: ldurb           w17, [x0, #-1]
    //     0xe3d124: and             x16, x17, x16, lsr #2
    //     0xe3d128: tst             x16, HEAP, lsr #32
    //     0xe3d12c: b.eq            #0xe3d134
    //     0xe3d130: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xe3d134: r16 = ", justificationReasonDescription: "
    //     0xe3d134: add             x16, PP, #0x37, lsl #12  ; [pp+0x37ab0] ", justificationReasonDescription: "
    //     0xe3d138: ldr             x16, [x16, #0xab0]
    // 0xe3d13c: StoreField: r2->field_3f = r16
    //     0xe3d13c: stur            w16, [x2, #0x3f]
    // 0xe3d140: LoadField: r0 = r3->field_23
    //     0xe3d140: ldur            w0, [x3, #0x23]
    // 0xe3d144: DecompressPointer r0
    //     0xe3d144: add             x0, x0, HEAP, lsl #32
    // 0xe3d148: mov             x1, x2
    // 0xe3d14c: ArrayStore: r1[13] = r0  ; List_4
    //     0xe3d14c: add             x25, x1, #0x43
    //     0xe3d150: str             w0, [x25]
    //     0xe3d154: tbz             w0, #0, #0xe3d170
    //     0xe3d158: ldurb           w16, [x1, #-1]
    //     0xe3d15c: ldurb           w17, [x0, #-1]
    //     0xe3d160: and             x16, x17, x16, lsr #2
    //     0xe3d164: tst             x16, HEAP, lsr #32
    //     0xe3d168: b.eq            #0xe3d170
    //     0xe3d16c: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xe3d170: r16 = ", hourlyAbsences: "
    //     0xe3d170: add             x16, PP, #0x2e, lsl #12  ; [pp+0x2ea70] ", hourlyAbsences: "
    //     0xe3d174: ldr             x16, [x16, #0xa70]
    // 0xe3d178: StoreField: r2->field_47 = r16
    //     0xe3d178: stur            w16, [x2, #0x47]
    // 0xe3d17c: LoadField: r0 = r3->field_27
    //     0xe3d17c: ldur            w0, [x3, #0x27]
    // 0xe3d180: DecompressPointer r0
    //     0xe3d180: add             x0, x0, HEAP, lsl #32
    // 0xe3d184: stur            x0, [fp, #-8]
    // 0xe3d188: r1 = <HourlyAbsence>
    //     0xe3d188: add             x1, PP, #0x25, lsl #12  ; [pp+0x25418] TypeArguments: <HourlyAbsence>
    //     0xe3d18c: ldr             x1, [x1, #0x418]
    // 0xe3d190: r0 = EqualUnmodifiableListView()
    //     0xe3d190: bl              #0x761510  ; AllocateEqualUnmodifiableListViewStub -> EqualUnmodifiableListView<X0> (size=0x14)
    // 0xe3d194: mov             x1, x0
    // 0xe3d198: ldur            x0, [fp, #-8]
    // 0xe3d19c: StoreField: r1->field_f = r0
    //     0xe3d19c: stur            w0, [x1, #0xf]
    // 0xe3d1a0: StoreField: r1->field_b = r0
    //     0xe3d1a0: stur            w0, [x1, #0xb]
    // 0xe3d1a4: mov             x0, x1
    // 0xe3d1a8: ldur            x1, [fp, #-0x10]
    // 0xe3d1ac: ArrayStore: r1[15] = r0  ; List_4
    //     0xe3d1ac: add             x25, x1, #0x4b
    //     0xe3d1b0: str             w0, [x25]
    //     0xe3d1b4: tbz             w0, #0, #0xe3d1d0
    //     0xe3d1b8: ldurb           w16, [x1, #-1]
    //     0xe3d1bc: ldurb           w17, [x0, #-1]
    //     0xe3d1c0: and             x16, x17, x16, lsr #2
    //     0xe3d1c4: tst             x16, HEAP, lsr #32
    //     0xe3d1c8: b.eq            #0xe3d1d0
    //     0xe3d1cc: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xe3d1d0: ldur            x2, [fp, #-0x10]
    // 0xe3d1d4: r16 = ", userIdentifier: "
    //     0xe3d1d4: add             x16, PP, #0x2e, lsl #12  ; [pp+0x2e3a8] ", userIdentifier: "
    //     0xe3d1d8: ldr             x16, [x16, #0x3a8]
    // 0xe3d1dc: StoreField: r2->field_4f = r16
    //     0xe3d1dc: stur            w16, [x2, #0x4f]
    // 0xe3d1e0: ldr             x3, [fp, #0x10]
    // 0xe3d1e4: LoadField: r0 = r3->field_2b
    //     0xe3d1e4: ldur            w0, [x3, #0x2b]
    // 0xe3d1e8: DecompressPointer r0
    //     0xe3d1e8: add             x0, x0, HEAP, lsl #32
    // 0xe3d1ec: mov             x1, x2
    // 0xe3d1f0: ArrayStore: r1[17] = r0  ; List_4
    //     0xe3d1f0: add             x25, x1, #0x53
    //     0xe3d1f4: str             w0, [x25]
    //     0xe3d1f8: tbz             w0, #0, #0xe3d214
    //     0xe3d1fc: ldurb           w16, [x1, #-1]
    //     0xe3d200: ldurb           w17, [x0, #-1]
    //     0xe3d204: and             x16, x17, x16, lsr #2
    //     0xe3d208: tst             x16, HEAP, lsr #32
    //     0xe3d20c: b.eq            #0xe3d214
    //     0xe3d210: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xe3d214: r16 = ", justificationStatus: "
    //     0xe3d214: add             x16, PP, #0x2e, lsl #12  ; [pp+0x2ea78] ", justificationStatus: "
    //     0xe3d218: ldr             x16, [x16, #0xa78]
    // 0xe3d21c: StoreField: r2->field_57 = r16
    //     0xe3d21c: stur            w16, [x2, #0x57]
    // 0xe3d220: LoadField: r0 = r3->field_2f
    //     0xe3d220: ldur            w0, [x3, #0x2f]
    // 0xe3d224: DecompressPointer r0
    //     0xe3d224: add             x0, x0, HEAP, lsl #32
    // 0xe3d228: mov             x1, x2
    // 0xe3d22c: ArrayStore: r1[19] = r0  ; List_4
    //     0xe3d22c: add             x25, x1, #0x5b
    //     0xe3d230: str             w0, [x25]
    //     0xe3d234: tbz             w0, #0, #0xe3d250
    //     0xe3d238: ldurb           w16, [x1, #-1]
    //     0xe3d23c: ldurb           w17, [x0, #-1]
    //     0xe3d240: and             x16, x17, x16, lsr #2
    //     0xe3d244: tst             x16, HEAP, lsr #32
    //     0xe3d248: b.eq            #0xe3d250
    //     0xe3d24c: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xe3d250: r16 = ")"
    //     0xe3d250: ldr             x16, [PP, #0xdb0]  ; [pp+0xdb0] ")"
    // 0xe3d254: StoreField: r2->field_5f = r16
    //     0xe3d254: stur            w16, [x2, #0x5f]
    // 0xe3d258: str             x2, [SP]
    // 0xe3d25c: r0 = _interpolate()
    //     0xe3d25c: bl              #0x6e42b0  ; [dart:core] _StringBase::_interpolate
    // 0xe3d260: LeaveFrame
    //     0xe3d260: mov             SP, fp
    //     0xe3d264: ldp             fp, lr, [SP], #0x10
    // 0xe3d268: ret
    //     0xe3d268: ret
    // 0xe3d26c: r0 = StackOverflowSharedWithoutFPURegs()
    //     0xe3d26c: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0xe3d270: b               #0xe3cfc8
  }

  // ... trimmed: hashCode getter, operator==, and the freezed copyWith
  // machinery (__$AbsenceCopyWithImpl et al. above are declared but empty in
  // this dump because their bodies live at call sites, not as named methods).
}
