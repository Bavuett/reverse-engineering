// lib: , url: package:login_flutter/services/keychain_service.dart
//
// NOTE: trimmed for this case study. The original dump also has `delete()`, `getAllUser()`,
// `clearAll()`, and `getUser()` (897 lines total) — cut here, kept is `save()` (how a freshly
// logged-in user's data, including the auth token, gets persisted) and `key()` (how the storage
// key for a given user is built).

// class id: 1050891, size: 0x8
class :: {
}

// class id: 1096, size: 0xc, field offset: 0x8
class KeychainService extends Object {

  _ save(/* No info */) async {
    // ** addr: 0x72031c, size: 0x174
    // 0x72031c: EnterFrame
    //     0x72031c: stp             fp, lr, [SP, #-0x10]!
    //     0x720320: mov             fp, SP
    // 0x720324: AllocStack(0x68)
    //     0x720324: sub             SP, SP, #0x68
    // 0x720328: SetupParameters(KeychainService this /* r1 => r1, fp-0x10 */, dynamic _ /* r2 => r2, fp-0x18 */)
    //     0x720328: stur            NULL, [fp, #-8]
    //     0x72032c: stur            x1, [fp, #-0x10]
    //     0x720330: stur            x2, [fp, #-0x18]
    // 0x720334: CheckStackOverflow
    //     0x720334: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x720338: cmp             SP, x16
    //     0x72033c: b.ls            #0x720488
    // 0x720340: InitAsync() -> Future<User>
    //     0x720340: add             x0, PP, #0x1d, lsl #12  ; [pp+0x1de18] TypeArguments: <User>
    //     0x720344: ldr             x0, [x0, #0xe18]
    //     0x720348: bl              #0x7e86ec  ; InitAsyncStub
    // 0x72034c: ldur            x2, [fp, #-0x18]
    // 0x720350: LoadField: r0 = r2->field_b
    //     0x720350: ldur            w0, [x2, #0xb]
    // 0x720354: DecompressPointer r0
    //     0x720354: add             x0, x0, HEAP, lsl #32
    // 0x720358: stur            x0, [fp, #-0x58]
    // 0x72035c: LoadField: r1 = r2->field_f
    //     0x72035c: ldur            w1, [x2, #0xf]
    // 0x720360: DecompressPointer r1
    //     0x720360: add             x1, x1, HEAP, lsl #32
    // 0x720364: stur            x1, [fp, #-0x50]
    // 0x720368: LoadField: r3 = r2->field_13
    //     0x720368: ldur            w3, [x2, #0x13]
    // 0x72036c: DecompressPointer r3
    //     0x72036c: add             x3, x3, HEAP, lsl #32
    // 0x720370: stur            x3, [fp, #-0x48]
    // 0x720374: ArrayLoad: r4 = r2[0]  ; List_4
    //     0x720374: ldur            w4, [x2, #0x17]
    // 0x720378: DecompressPointer r4
    //     0x720378: add             x4, x4, HEAP, lsl #32
    // 0x72037c: stur            x4, [fp, #-0x40]
    // 0x720380: LoadField: r5 = r2->field_1b
    //     0x720380: ldur            w5, [x2, #0x1b]
    // 0x720384: DecompressPointer r5
    //     0x720384: add             x5, x5, HEAP, lsl #32
    // 0x720388: stur            x5, [fp, #-0x38]
    // 0x72038c: LoadField: r6 = r2->field_1f
    //     0x72038c: ldur            w6, [x2, #0x1f]
    // 0x720390: DecompressPointer r6
    //     0x720390: add             x6, x6, HEAP, lsl #32
    // 0x720394: stur            x6, [fp, #-0x30]
    // 0x720398: LoadField: r7 = r2->field_23
    //     0x720398: ldur            w7, [x2, #0x23]
    // 0x72039c: DecompressPointer r7
    //     0x72039c: add             x7, x7, HEAP, lsl #32
    // 0x7203a0: stur            x7, [fp, #-0x28]
    // 0x7203a4: LoadField: r8 = r2->field_27
    //     0x7203a4: ldur            w8, [x2, #0x27]
    // 0x7203a8: DecompressPointer r8
    //     0x7203a8: add             x8, x8, HEAP, lsl #32
    // 0x7203ac: stur            x8, [fp, #-0x20]
    // 0x7203b0: r0 = _User()
    //     0x7203b0: bl              #0x72347c  ; Allocate_UserStub -> _User (size=0x2c)
    // 0x7203b4: ldur            x2, [fp, #-0x58]
    // 0x7203b8: StoreField: r0->field_b = r2
    //     0x7203b8: stur            w2, [x0, #0xb]
    // 0x7203bc: ldur            x1, [fp, #-0x50]
    // 0x7203c0: StoreField: r0->field_f = r1
    //     0x7203c0: stur            w1, [x0, #0xf]
    // 0x7203c4: ldur            x1, [fp, #-0x48]
    // 0x7203c8: StoreField: r0->field_13 = r1
    //     0x7203c8: stur            w1, [x0, #0x13]
    // 0x7203cc: ldur            x1, [fp, #-0x40]
    // 0x7203d0: ArrayStore: r0[0] = r1  ; List_4
    //     0x7203d0: stur            w1, [x0, #0x17]
    // 0x7203d4: ldur            x1, [fp, #-0x38]
    // 0x7203d8: StoreField: r0->field_1b = r1
    //     0x7203d8: stur            w1, [x0, #0x1b]
    // 0x7203dc: ldur            x1, [fp, #-0x30]
    // 0x7203e0: StoreField: r0->field_1f = r1
    //     0x7203e0: stur            w1, [x0, #0x1f]
    // 0x7203e4: ldur            x1, [fp, #-0x28]
    // 0x7203e8: StoreField: r0->field_23 = r1
    //     0x7203e8: stur            w1, [x0, #0x23]
    // 0x7203ec: ldur            x1, [fp, #-0x20]
    // 0x7203f0: StoreField: r0->field_27 = r1
    //     0x7203f0: stur            w1, [x0, #0x27]
    // 0x7203f4: r16 = Closure: (_User) => _User from Function '_$identity@1020496531': static.
    //     0x7203f4: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1dd00] Closure: (_User) => _User from Function '_$identity@1020496531': static. (0x2c5f1b87918)
    //     0x7203f8: ldr             x16, [x16, #0xd00]
    // 0x7203fc: stp             x0, x16, [SP]
    // 0x720400: r0 = Closure: (_User) => _User from Function '_$identity@1020496531': static.
    //     0x720400: add             x0, PP, #0x1d, lsl #12  ; [pp+0x1dd00] Closure: (_User) => _User from Function '_$identity@1020496531': static. (0x2c5f1b87918)
    //     0x720404: ldr             x0, [x0, #0xd00]
    // 0x720408: ClosureCall
    //     0x720408: ldr             x4, [PP, #0x148]  ; [pp+0x148] List(5) [0, 0x2, 0x2, 0x2, Null]
    //     0x72040c: ldur            x2, [x0, #0x1f]
    //     0x720410: blr             x2
    // 0x720414: mov             x1, x0
    // 0x720418: r0 = _$UserToJson()
    //     0x720418: bl              #0x71e004  ; [package:login_flutter/models/user.dart] ::_$UserToJson
    // 0x72041c: mov             x1, x0
    // 0x720420: r4 = const [0, 0x1, 0, 0x1, null]
    //     0x720420: ldr             x4, [PP, #0xa0]  ; [pp+0xa0] List(5) [0, 0x1, 0, 0x1, Null]
    // 0x720424: r0 = jsonEncode()
    //     0x720424: bl              #0x723408  ; [dart:convert] ::jsonEncode
    // 0x720428: mov             x3, x0
    // 0x72042c: ldur            x0, [fp, #-0x18]
    // 0x720430: stur            x3, [fp, #-0x20]
    // 0x720434: LoadField: r1 = r0->field_7
    //     0x720434: ldur            w1, [x0, #7]
    // 0x720438: DecompressPointer r1
    //     0x720438: add             x1, x1, HEAP, lsl #32
    // 0x72043c: cmp             w1, NULL
    // 0x720440: b.eq            #0x72045c
    // 0x720444: ldur            x1, [fp, #-0x10]
    // 0x720448: mov             x2, x0
    // 0x72044c: r0 = delete()
    //     0x72044c: bl              #0x721150  ; [package:login_flutter/services/keychain_service.dart] KeychainService::delete
    // 0x720450: mov             x1, x0
    // 0x720454: stur            x1, [fp, #-0x28]
    // 0x720458: r0 = Await()
    //     0x720458: bl              #0x7e84ac  ; AwaitStub
    // 0x72045c: ldur            x0, [fp, #-0x10]
    // 0x720460: LoadField: r1 = r0->field_7
    //     0x720460: ldur            w1, [x0, #7]
    // 0x720464: DecompressPointer r1
    //     0x720464: add             x1, x1, HEAP, lsl #32
    // 0x720468: ldur            x2, [fp, #-0x58]
    // 0x72046c: ldur            x3, [fp, #-0x20]
    // 0x720470: r0 = write()
    //     0x720470: bl              #0x720490  ; [package:flutter_secure_storage/flutter_secure_storage.dart] FlutterSecureStorage::write
    // 0x720474: mov             x1, x0
    // 0x720478: stur            x1, [fp, #-0x10]
    // 0x72047c: r0 = Await()
    //     0x72047c: bl              #0x7e84ac  ; AwaitStub
    // 0x720480: ldur            x0, [fp, #-0x18]
    // 0x720484: r0 = ReturnAsyncNotFuture()
    //     0x720484: b               #0x7e8334  ; ReturnAsyncNotFutureStub
    // 0x720488: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x720488: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x72048c: b               #0x720340
  }

  // ... trimmed: delete(), getAllUser(), clearAll(), getUser() — all follow the same shape as
  // save(), reading/writing through the same FlutterSecureStorage instance held in field_7.

  _ key(/* No info */) {
    // ** addr: 0x721398, size: 0x5c
    // 0x721398: EnterFrame
    //     0x721398: stp             fp, lr, [SP, #-0x10]!
    //     0x72139c: mov             fp, SP
    // 0x7213a0: AllocStack(0x10)
    //     0x7213a0: sub             SP, SP, #0x10
    // 0x7213a4: SetupParameters(dynamic _ /* r2 => r0, fp-0x8 */)
    //     0x7213a4: mov             x0, x2
    //     0x7213a8: stur            x2, [fp, #-8]
    // 0x7213ac: CheckStackOverflow
    //     0x7213ac: ldr             x16, [THR, #0x38]  ; THR::stack_limit
    //     0x7213b0: cmp             SP, x16
    //     0x7213b4: b.ls            #0x7213ec
    // 0x7213b8: r1 = Null
    //     0x7213b8: mov             x1, NULL
    // 0x7213bc: r2 = 4
    //     0x7213bc: movz            x2, #0x4
    // 0x7213c0: r0 = AllocateArray()
    //     0x7213c0: bl              #0x10cbe44  ; AllocateArrayStub
    // 0x7213c4: r16 = "KEYCHAIN_USER_ITEM_"
    //     0x7213c4: add             x16, PP, #0x1d, lsl #12  ; [pp+0x1de98] "KEYCHAIN_USER_ITEM_"
    //     0x7213c8: ldr             x16, [x16, #0xe98]
    // 0x7213cc: StoreField: r0->field_f = r16
    //     0x7213cc: stur            w16, [x0, #0xf]
    // 0x7213d0: ldur            x1, [fp, #-8]
    // 0x7213d4: StoreField: r0->field_13 = r1
    //     0x7213d4: stur            w1, [x0, #0x13]
    // 0x7213d8: str             x0, [SP]
    // 0x7213dc: r0 = _interpolate()
    //     0x7213dc: bl              #0x6e42b0  ; [dart:core] _StringBase::_interpolate
    // 0x7213e0: LeaveFrame
    //     0x7213e0: mov             SP, fp
    //     0x7213e4: ldp             fp, lr, [SP], #0x10
    // 0x7213e8: ret
    //     0x7213e8: ret
    // 0x7213ec: r0 = StackOverflowSharedWithoutFPURegs()
    //     0x7213ec: bl              #0x10cbf4c  ; StackOverflowSharedWithoutFPURegsStub
    // 0x7213f0: b               #0x7213b8
  }
}
