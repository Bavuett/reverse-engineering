// lib: , url: package:classeviva/ui/pages/account_pages/sign_in_pages/login_spid_page.dart
//
// NOTE: heavily trimmed for this case study. The full blutter dump for this file covers the
// entire `_WebViewStatePage` widget state class (state field access, WebView JS-eval calls, and a
// long `build()` method running to well over a thousand lines) — only the one excerpt relevant to
// this case study's async/platform-channel notes is kept here, from partway through `build()`
// (the `AnonymousClosure (0xc112d0), in ... _WebViewStatePage::build (0xc0f8cc)` reference below
// is what anchors it to that enclosing method). Addresses are consecutive and unedited within the
// excerpt itself.

// ... (state class declaration and preceding build() logic trimmed) ...

    // 0xc10ec4: sub             lr, x0, #0xffe
    //     0xc10ec8: ldr             lr, [x21, lr, lsl #3]
    //     0xc10ecc: blr             lr
    // 0xc10ed0: tbnz            w0, #4, #0xc10f08
    // 0xc10ed4: ldur            x0, [fp, #-0x98]
    // 0xc10ed8: LoadField: r1 = r0->field_b
    //     0xc10ed8: ldur            w1, [x0, #0xb]
    // 0xc10edc: DecompressPointer r1
    //     0xc10edc: add             x1, x1, HEAP, lsl #32
    // 0xc10ee0: LoadField: r3 = r1->field_f
    //     0xc10ee0: ldur            w3, [x1, #0xf]
    // 0xc10ee4: DecompressPointer r3
    //     0xc10ee4: add             x3, x3, HEAP, lsl #32
    // 0xc10ee8: mov             x2, x0
    // 0xc10eec: stur            x3, [fp, #-0xb0]
    // 0xc10ef0: r1 = Function '<anonymous closure>':.
    //     0xc10ef0: add             x1, PP, #0x36, lsl #12  ; [pp+0x36620] AnonymousClosure: (0xc112d0), in [package:classeviva/ui/pages/account_pages/sign_in_pages/login_spid_page.dart] _WebViewStatePage::build (0xc0f8cc)
    //     0xc10ef4: ldr             x1, [x1, #0x620]
    // 0xc10ef8: r0 = AllocateClosure()
    //     0xc10ef8: bl              #0x10cb178  ; AllocateClosureStub
    // 0xc10efc: ldur            x1, [fp, #-0xb0]
    // 0xc10f00: mov             x2, x0
    // 0xc10f04: r0 = setState()
    //     0xc10f04: bl              #0x6fb36c  ; [package:flutter/src/widgets/framework.dart] State::setState
    // 0xc10f08: ldur            x0, [fp, #-0xa0]
    // 0xc10f0c: cmp             w0, NULL
    // 0xc10f10: b.eq            #0xc11044
    // 0xc10f14: str             x0, [SP]
    // 0xc10f18: r0 = toString()
    //     0xc10f18: bl              #0xe6a17c  ; [package:flutter_inappwebview_platform_interface/src/web_uri.dart] WebUri::toString
    // 0xc10f1c: mov             x1, x0
    // 0xc10f20: r2 = "intent"
    //     0xc10f20: add             x2, PP, #0x36, lsl #12  ; [pp+0x36628] "intent"
    //     0xc10f24: ldr             x2, [x2, #0x628]
    // 0xc10f28: r4 = const [0, 0x2, 0, 0x2, null]
    //     0xc10f28: ldr             x4, [PP, #0xd0]  ; [pp+0xd0] List(5) [0, 0x2, 0, 0x2, Null]
    // 0xc10f2c: r0 = startsWith()
    //     0xc10f2c: bl              #0x6ed4ac  ; [dart:core] _StringBase::startsWith
    // 0xc10f30: tbnz            w0, #4, #0xc11044
    // 0xc10f34: r1 = Null
    //     0xc10f34: mov             x1, NULL
    // 0xc10f38: r2 = 4
    //     0xc10f38: movz            x2, #0x4
    // 0xc10f3c: r0 = AllocateArray()
    //     0xc10f3c: bl              #0x10cbe44  ; AllocateArrayStub
    // 0xc10f40: stur            x0, [fp, #-0xb0]
    // 0xc10f44: r16 = "url"
    //     0xc10f44: add             x16, PP, #0xa, lsl #12  ; [pp+0xaa88] "url"
    //     0xc10f48: ldr             x16, [x16, #0xa88]
    // 0xc10f4c: StoreField: r0->field_f = r16
    //     0xc10f4c: stur            w16, [x0, #0xf]
    // 0xc10f50: ldur            x16, [fp, #-0xa0]
    // 0xc10f54: str             x16, [SP]
    // 0xc10f58: r0 = toString()
    //     0xc10f58: bl              #0xe6a17c  ; [package:flutter_inappwebview_platform_interface/src/web_uri.dart] WebUri::toString
    // 0xc10f5c: ldur            x1, [fp, #-0xb0]
    // 0xc10f60: ArrayStore: r1[1] = r0  ; List_4
    //     0xc10f60: add             x25, x1, #0x13
    //     0xc10f64: str             w0, [x25]
    //     0xc10f68: tbz             w0, #0, #0xc10f84
    //     0xc10f6c: ldurb           w16, [x1, #-1]
    //     0xc10f70: ldurb           w17, [x0, #-1]
    //     0xc10f74: and             x16, x17, x16, lsr #2
    //     0xc10f78: tst             x16, HEAP, lsr #32
    //     0xc10f7c: b.eq            #0xc10f84
    //     0xc10f80: bl              #0x10ca0f0  ; ArrayWriteBarrierStub
    // 0xc10f84: r16 = <String, String>
    //     0xc10f84: ldr             x16, [PP, #0x72d8]  ; [pp+0x72d8] TypeArguments: <String, String>
    // 0xc10f88: ldur            lr, [fp, #-0xb0]
    // 0xc10f8c: stp             lr, x16, [SP]
    // 0xc10f90: r0 = Map._fromLiteral()
    //     0xc10f90: bl              #0x6e0e60  ; [dart:core] Map::Map._fromLiteral
    // 0xc10f94: r16 = Instance_MethodChannel
    //     0xc10f94: add             x16, PP, #0x27, lsl #12  ; [pp+0x27c68] Obj!MethodChannel@1174d71
    //     0xc10f98: ldr             x16, [x16, #0xc68]
    // 0xc10f9c: stp             x16, NULL, [SP, #0x10]
    // 0xc10fa0: r16 = "openUrlIntent"
    //     0xc10fa0: add             x16, PP, #0x36, lsl #12  ; [pp+0x36630] "openUrlIntent"
    //     0xc10fa4: ldr             x16, [x16, #0x630]
    // 0xc10fa8: stp             x0, x16, [SP]
    // 0xc10fac: r4 = const [0x1, 0x3, 0x3, 0x3, null]
    //     0xc10fac: ldr             x4, [PP, #0x758]  ; [pp+0x758] List(5) [0x1, 0x3, 0x3, 0x3, Null]
    // 0xc10fb0: r0 = invokeMethod()
    //     0xc10fb0: bl              #0x1056578  ; [package:flutter/src/services/platform_channel.dart] MethodChannel::invokeMethod
    // 0xc10fb4: mov             x1, x0
    // 0xc10fb8: stur            x1, [fp, #-0xb0]
    // 0xc10fbc: r0 = Await()
    //     0xc10fbc: bl              #0x7e84ac  ; AwaitStub
    // 0xc10fc0: b               #0xc11038
    // 0xc10fc4: sub             SP, fp, #0xd0
    // 0xc10fc8: r2 = 60
    //     0xc10fc8: movz            x2, #0x3c
    // 0xc10fcc: branchIfSmi(r0, 0xc10fd8)
    //     0xc10fcc: tbz             w0, #0, #0xc10fd8
    // 0xc10fd0: r2 = LoadClassIdInstr(r0)
    //     0xc10fd0: ldur            x2, [x0, #-1]
    //     0xc10fd4: ubfx            x2, x2, #0xc, #0x14
    // 0xc10fd8: cmp             x2, #0xa52
    // 0xc10fdc: b.ne            #0xc11050
    // 0xc10fe0: ldur            x16, [fp, #-0xa0]
    // 0xc10fe4: str             x16, [SP]
    // 0xc10fe8: r0 = toString()
    //     0xc10fe8: bl              #0xe6a17c  ; [package:flutter_inappwebview_platform_interface/src/web_uri.dart] WebUri::toString
    // 0xc10fec: mov             x1, x0
    // 0xc10ff0: r0 = getIntentFallbackUrl()
    //     0xc10ff0: bl              #0xc111e0  ; [package:classeviva/core/misc/url_utils.dart] UrlUtils::getIntentFallbackUrl
    // 0xc10ff4: stur            x0, [fp, #-0x98]
    // 0xc10ff8: cmp             w0, NULL
    // 0xc10ffc: b.eq            #0xc11038

// ... (remainder of build() trimmed) ...
