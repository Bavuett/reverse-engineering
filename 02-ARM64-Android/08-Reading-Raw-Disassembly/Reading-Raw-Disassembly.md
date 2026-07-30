---
tags: [fundamentals]
aliases: [Cold Reading Disassembly, Static Analysis Without Annotations, Stripped Disassembly]
created: 2026-07-28
---

# Reading-Raw-Disassembly

## In short

Every excerpt elsewhere in this topic leans on blutter's synthetic comments — `SetupParameters(...)`, `LoadField:`, `DecompressPointer`, and the `; [package:...] Class::method` name attached to every call — because that's what makes a first read of Dart AOT disassembly tractable at all. But those comments are blutter's own inference from the Dart snapshot's recovered metadata, not something inherent to the bytes themselves: a different tool, an obfuscated build (`--obfuscate`, which strips exactly this metadata), a plain NDK `.so` with no such metadata to begin with, or simply wanting to double-check that blutter read something correctly, all leave you with nothing but bare addresses and instruction mnemonics. This chapter takes real excerpts already used elsewhere in this topic and re-derives the same conclusions from the instructions alone, with none of blutter's own comments to lean on — the single most transferable skill in this entire topic, and the reason chapters 1 through 7 exist. To keep every example scannable without constant round-trips to prose, each code block below carries short inline `;` comments — but these are **the reader's own working notes, written _after_ doing the deduction**, not something the disassembly came with; the prose beneath each one is where that deduction actually happens.

## Explanation

### The checklist

Nine things to do, roughly in order, whenever you land on a function with zero helpful comments:

1. **Find the boundaries.** Prologue signature (`stp fp, lr, [SP, #-N]!` / `mov fp, SP`, maybe `sub SP, SP, #N`) to matching epilogue (`mov SP, fp` / `ldp fp, lr, [SP], #N` / `ret`, or the AAPCS64-leaf variant with neither) — see [[Functions-And-Calling-Convention]].
2. **Anchor registers to their calling-convention role.** `X0`-`X7` are arguments in order; an instance method's receiver conventionally arrives as the first of those; the return value ends up in `X0` right before the epilogue. See [[Registers-And-Data]].
3. **Anchor stack slots at their first write.** The first `stur`/`str` of an argument register after the prologue fixes what that `fp`-offset means from then on — see [[Functions-And-Calling-Convention#Reading what a stack slot actually holds|the technique]] and [[Tracking-A-Stack-Slots-Meaning]].
4. **Follow data flow instruction by instruction.** `mov`, `ldur`/`stur`, register chains — no shortcut, just reading in order.
5. **Recognize allocation shapes even without a stub name.** A bump-pointer sequence against `THR` is always inline heap allocation (see [[Memory-And-Data-Structures]]); a `bl` immediately followed by field-by-field `stur`s into its result is always "allocate, then populate."
6. **Recognize field-access shapes.** A small (often odd, for Dart) offset in `ldur`/`stur` off a live pointer, especially followed by `add xd, xd, HEAP, lsl #32`, is a field access — see [[Memory-And-Data-Structures]].
7. **Recognize dispatch shapes.** `ldur xd, [xn, #-1]` + `ubfx` + a computed `blr` through a fixed table-base register (raw, e.g. `x21`) is virtual dispatch by class id — see [[Bitfield-Class-Id-Extraction]].
8. **Recognize control-flow shapes.** Forward branch = `if`; backward branch = loop; `csel`/`csinc` = branch-free conditional; cascading compares against distinct pool addresses = enum dispatch — see [[Control-Flow-Patterns]].
9. **Separate _shape_ from _identity_.** "This allocates an object and stores four fields into it" is a shape-only conclusion. "The method is named `getAvg`" or "field `0x13` is `password`" is identity — supplied by a snapshot-aware tool, prior investigation, or dynamic tracing, never by the bytes alone. Knowing exactly where that line sits is the actual skill this chapter teaches.

### A note on honesty

None of the examples below pretend to divine a string's contents or a function's declared name out of thin air. Where the bytes genuinely can't tell you something, the prose says so, and says what you'd go do about it instead (check the pool, attach a debugger, fall back on a snapshot-aware tool) — rather than quietly leaning on knowledge only available from elsewhere in this vault.

## Worked example 1 (simple): a self-contained string builder

`Servers.italyPreviousYear`, stripped to bare mnemonics — inline notes are the _conclusions_ of the walkthrough below, not something the disassembly came with:

```
0x10dedcc: stp   fp, lr, [SP, #-0x10]!  ; saves FP and LR and allocates 16 bytes
0x10dedd0: mov   fp, SP                 ; set FP to start of newly created frame
0x10dedd4: sub   SP, SP, #0x10          ; frame: 0x10 bytes locals
0x10dedd8: mov   x0, x1                 ; copy x1 in x0.
0x10deddc: stur  x1, [fp, #-8]          ; anchor: fp-8 = arg1
0x10dede0: ldr   x16, [THR, #0x38]      ; stack-limit check
0x10dede4: cmp   SP, x16                ; if true, we owerflowed the SP
0x10dede8: b.ls  #0x10dee40             ; -> overflow slow path
0x10dedec: mov   x1, NULL               ; x1 = 0
0x10dedf0: movz  x2, #0xa               ; x2 = 10
0x10dedf4: bl    #0x10cbe44             ; call #1: result populated next (alloc?)
0x10dedf8: add   x16, PP, #9, lsl #12
0x10dedfc: ldr   x16, [x16, #0xd38]     ; pool const A
0x10dee00: stur  w16, [x0, #0xf]        ; slot0 = const A
0x10dee04: ldur  x1, [fp, #-8]          ; reload arg1
0x10dee08: stur  w1, [x0, #0x13]        ; slot1 = arg1
0x10dee0c: ldr   x16, [PP, #0xf70]      ; pool const B
0x10dee10: stur  w16, [x0, #0x17]       ; slot2 = const B
0x10dee14: add   x16, PP, #9, lsl #12
0x10dee18: ldr   x16, [x16, #0xd40]     ; pool const C
0x10dee1c: stur  w16, [x0, #0x1b]       ; slot3 = const C
0x10dee20: add   x16, PP, #9, lsl #12
0x10dee24: ldr   x16, [x16, #0xd58]     ; pool const D
0x10dee28: stur  w16, [x0, #0x1f]       ; slot4 = const D
0x10dee2c: str   x0, [SP]               ; pass the populated object
0x10dee30: bl    #0x6e42b0              ; call #2: consumes it -> return value
0x10dee34: mov   SP, fp
0x10dee38: ldp   fp, lr, [SP], #0x10
0x10dee3c: ret
0x10dee40: bl    #0x10cbf4c             ; overflow slow path
0x10dee44: b     #0x10dedec             ; retry
```

Reading it cold: one argument, anchored at `fp-8` the moment it arrives — we don't yet know what it _represents_, only that `X1` (which could just as easily be `this` as a plain first parameter; the assembly alone never distinguishes the two, see [[Functions-And-Calling-Convention]]) is now live at that offset. `call #1` (bl means branch link: saves address of the instruction next to bl inside of LR, so it can resume) takes a null and the constant `10`, and its result immediately gets five sequential field writes at offsets `0xf`/`0x13`/`0x17`/`0x1b`/`0x1f` — a `bl`-then-populate-fields shape is _always_ "allocate, then fill in," per the checklist, whatever `0x10cbe44` turns out to be named. Four of those five slots come from a pool load (`add x16,PP,#page,lsl#12` / `ldr x16,[x16,#off]`, the fixed object-pool idiom from [[Flutter-Dart-AOT]]); the other comes straight from `fp-8` — the caller's own argument, sandwiched between constants. That alone says "constant, argument, constant, constant" without knowing any of the constants' actual values. Then the populated object is handed to a _second_ call (`call #2`), which produces this function's own return value — allocate-a-small-array-then-hand-it-to-one-consumer is the shape of a string built from pieces, per [[Api-Endpoint-Strings]], before ever learning that the consumer is `_interpolate`.

**Shape-only conclusion:** one argument in, a small fixed-layout object built from three constants plus that argument, piped into a single consumer — almost certainly assembled text. **Needs a lookup:** the constants' actual text, and confirmation of what the two calls really are (answered by [[Flutter-Dart-AOT]]).

## Worked example 2 (medium): a conditional with a virtual call

`IdentityUtils.isParent`, stripped:

```
0xc172a0: stp   fp, lr, [SP, #-0x10]!
0xc172a4: mov   fp, SP
0xc172a8: sub   SP, SP, #0x20
0xc172ac: stur  x1, [fp, #-0x10]        ; anchor: fp-0x10 = arg1
0xc172b0: ldr   x16, [THR, #0x38]       ; stack-limit check
0xc172b4: cmp   SP, x16
0xc172b8: b.ls  #0xc1735c
0xc172bc: ldur  w0, [x1, #7]            ; field @+7 of arg1
0xc172c0: sbfx  x2, x0, #1, #0x1f       ; untag Smi
0xc172c4: stur  x2, [fp, #-8]           ; anchor: fp-8 = count
0xc172c8: cmp   x2, #1
0xc172cc: b.le  #0xc172dc               ; if count <= 1 ...
0xc172d0: stp   xzr, x1, [SP]           ; args: (0, arg1)
0xc172d4: bl    #0x6e4858               ; call -> some value in x0
0xc172d8: b     #0xc172e0
0xc172dc: ldr   x0, [PP, #0x42e8]       ; ... else: pool const instead of a call
0xc172e0: ldur  x1, [x0, #-1]           ; header word
0xc172e4: ubfx  x1, x1, #0xc, #0x14     ; class-id of x0
0xc172e8: add   x16, PP, #0xa, lsl #12
0xc172ec: ldr   x16, [x16, #0xec0]      ; pool const E
0xc172f0: stp   x16, x0, [SP]           ; args: (const E, x0)
0xc172f4: mov   x0, x1                  ; x0 = class id
0xc172f8: mov   lr, x0
0xc172fc: ldr   lr, [x21, lr, lsl #3]   ; GDT[cid] -> function ptr
0xc17300: blr   lr                      ; virtual call
0xc17304: tbnz  w0, #4, #0xc17310       ; branch unless result == true-singleton
0xc17308: add   x0, NULL, #0x20         ; x0 = true
0xc1730c: b     #0xc17350
0xc17310: ldur  x0, [fp, #-8]           ; reload count
0xc17314: cmp   x0, #1
0xc17318: b.le  #0xc1732c               ; second round, same shape as above
0xc1731c: ldur  x16, [fp, #-0x10]
0xc17320: stp   xzr, x16, [SP]
0xc17324: bl    #0x6e4858
0xc17328: b     #0xc17330
0xc1732c: ldr   x0, [PP, #0x42e8]
0xc17330: ldur  x1, [x0, #-1]
0xc17334: ubfx  x1, x1, #0xc, #0x14
0xc17338: ldr   x16, [PP, #0x5398]      ; pool const F (different from E)
0xc1733c: stp   x16, x0, [SP]
0xc17340: mov   x0, x1
0xc17344: mov   lr, x0
0xc17348: ldr   lr, [x21, lr, lsl #3]
0xc1734c: blr   lr
0xc17350: mov   SP, fp
0xc17354: ldp   fp, lr, [SP], #0x10
0xc17358: ret
0xc1735c: bl    #0x10cbf4c
0xc17360: b     #0xc172bc
```

Reading it cold: `sbfx ...,#1,#0x1f` is always Smi-untagging (see [[Register-Width-And-Sign-Extension]]), so `fp-8` holds a real signed count read out of the argument's `+7` field. `cmp x2,#1` / `b.le` is a plain forward-branching `if`, and both arms converge on the _identical_ three-step shape: produce a value in `X0` (either by calling `0x6e4858` or loading a pool constant), extract _that_ value's class id (`ldur` at `-1` then `ubfx`, the exact shape from [[Bitfield-Class-Id-Extraction]] with zero comments attached), then perform a computed call through `[x21, cid, lsl #3]` — the [[Flutter-Dart-AOT|dispatch-table]] virtual-call shape, recognizable purely from "class-id extraction feeding a scaled indirect call," no `GDT[...]` label required. `tbnz w0,#4` testing one specific bit of a boolean-shaped result, right after a virtual call, matches exactly how [[Flutter-Dart-AOT]] describes distinguishing the `true`/`false` singletons (`NULL+0x20` differs from `NULL+0x30` in precisely bit 4) — a cheap single-bit test standing in for a full pool-constant comparison. The second half repeats the _identical_ structure with one difference: a different pool constant fed into the final call.

**Shape-only conclusion:** given one argument with a Smi count at `+7`, two structurally identical rounds — pick a value depending on whether the count exceeds 1, get its class id, virtual-call it with a distinct pool constant each round — short-circuiting to `true` if the first round's call itself returns `true`. **Needs a lookup:** what the two pool constants actually are (plausibly short strings, from how they're used, but that's an informed guess, not certainty) and what the dispatch target is named. [[Object-Pool-Constant-Loads]] confirms this is character-checking on an identifier string — the structural read above doesn't depend on that confirmation.

## Worked example 3 (deep): resolving a named optional argument

The richest instance here of "no comment could have saved you, but the shape still tells the whole story" — `AuthenticationService.login`'s prologue, stripped:

```
0x7249bc: stp   fp, lr, [SP, #-0x10]!
0x7249c0: mov   fp, SP
0x7249c4: sub   SP, SP, #0xf8           ; large frame -- does a lot
0x7249c8: stur  NULL, [fp, #-8]         ; zeroed before the overflow check (unusual!)
0x7249cc: stur  x1, [fp, #-0xc8]        ; anchor: fp-0xc8 = arg "this"?
0x7249d0: mov   x16, x2
0x7249d4: mov   x2, x1                  ; swap x1/x2 via x16 scratch
0x7249d8: mov   x1, x16
0x7249dc: stur  x1, [fp, #-0xd0]        ; anchor: fp-0xd0 = arg2 (post-swap)
0x7249e0: ldur  w0, [x4, #0x13]         ; !! x4 never anchored -- caller-supplied
0x7249e4: ldur  w3, [x4, #0x1f]         ; another field of the same x4 object
0x7249e8: add   x3, x3, HEAP, lsl #32   ; decompress -- x4 points at a heap object
0x7249ec: add   x16, PP, #0x1e, lsl #12
0x7249f0: ldr   x16, [x16, #0xa8]       ; pool const G
0x7249f4: cmp   w3, w16                 ; x4.field(+0x1f) == const G ?
0x7249f8: b.ne  #0x724a18               ; no -> skip the stack-probe below
0x7249fc: ldur  w3, [x4, #0x23]         ; yes -> a THIRD field of x4
0x724a00: add   x3, x3, HEAP, lsl #32
0x724a04: sub   w4, w0, w3              ; a computed difference
0x724a08: add   x0, fp, w4, sxtw #2     ; ... used as an fp-relative BYTE offset
0x724a0c: ldr   x0, [x0, #8]            ; reach into the CALLER's stack args
0x724a10: mov   x3, x0
0x724a14: b     #0x724a1c
0x724a18: mov   x3, NULL                ; the "no" path: just NULL
0x724a1c: stur  x3, [fp, #-0xc0]        ; anchor: fp-0xc0 = result of all this
0x724a20: ldr   x16, [THR, #0x38]       ; stack-limit check (late!)
0x724a24: cmp   SP, x16
0x724a28: b.ls  #0x724bf0
```

Reading it cold, slowly: `fp-0xc8` gets `X1` immediately — either `this` or a plain first argument, exactly the same ambiguity as example 1; nothing here yet decides which. `fp-0xd0` is `X1`/`X2` after a scratch-register swap — some mismatch between the physical calling convention and the IR's preferred order, worth noting without needing to explain _why_. Then the interesting part: `X4` is used _without ever being anchored_ — no `mov`, no `stur` from an earlier value, nothing in this function explains where it came from, which by elimination means the caller must have set it up as an extra input alongside the two ordinary arguments. Tracing it purely mechanically: two of its fields get read and one gets compared against a pool constant; only if that comparison matches does a _third_ field get read and combined (via subtraction) with the first into a byte offset that's added directly to `fp` and dereferenced — reaching into the function's own stack frame at a location computed from data, not a fixed constant, which is a shape distinct from every other stack access in this whole topic. The comparison failing (the ordinary case, no extra field passed) just sets the result to `NULL` instead of doing any of that.

**Shape-only conclusion:** two ordinary arguments (one arrived via a register swap) plus a third input reachable only through an unanchored register pointing at a caller-supplied object — probed field by field, one field checked against an expected value, and depending on the outcome either a computed, data-dependent stack location gets read or `NULL` is used. An input that _may or may not_ have been supplied, resolved by inspecting call metadata rather than a fixed register. **Needs a lookup:** the pool constant's contents and what kind of object `X4` really is — in the original investigation this came from, `X4` turned out to be the caller's named-argument descriptor and the constant the literal `"oldToken"`, confirming this whole sequence is how Dart resolves an optional named parameter with no register of its own. The shape-only read above never needed that answer to be useful.

## Worked example 4 (expert): continuing into an async network request, assembled field by field

Same function as example 3, `AuthenticationService.login`, picking up exactly where that one left off (`0x724a28`'s `b.ls` into the stack-overflow slow path) and running to the end of the function — the deepest excerpt in this topic, stripped down the same way:

```
0x724a2c: add   x0, PP, #0x1e, lsl #12
0x724a30: ldr   x0, [x0, #0xb0]         ; pool object, TypeArguments-shaped
0x724a34: bl    #0x7e86ec               ; call A: takes one arg, nothing from it used further
0x724a38: ldr   x16, [PP, #0x2050]      ; pool const H
0x724a3c: ldr   lr, [THR, #0x90]        ; a THR-relative constant
0x724a40: stp   lr, x16, [SP]
0x724a44: bl    #0x6e0e60               ; call B: args (const, const H) -> object #1 in x0
0x724a48: stur  x0, [fp, #-0xd8]        ; anchor: fp-0xd8 = object #1 (untouched for a long time)
0x724a4c: ldr   x16, [PP, #0x2050]      ; same const H again
0x724a50: ldr   lr, [THR, #0x90]
0x724a54: stp   lr, x16, [SP]
0x724a58: bl    #0x6e0e60               ; call B again, same args -> object #2 in x0
0x724a5c: add   x1, PP, #0x1e, lsl #12
0x724a60: ldr   x1, [x1, #0xb8]         ; pool: a fixed code/function reference
0x724a64: mov   x2, NULL
0x724a68: stur  x0, [fp, #-0xe0]        ; anchor: fp-0xe0 = object #2
0x724a6c: bl    #0x10cb178              ; closure-build shape (fn ref + NULL context), per the pattern above
0x724a70: ldur  x1, [fp, #-0xe0]        ; reload object #2
0x724a74: mov   x2, x0                  ; x2 = the closure just built
0x724a78: bl    #0x725920               ; call taking (object #2, closure) -> result discarded
0x724a7c: mov   x1, NULL
0x724a80: movz  x2, #0x4
0x724a84: bl    #0x10cbe44              ; AllocateArray shape, length 4 (two key/value slots)
0x724a88: add   x16, PP, #0x1d, lsl #12
0x724a8c: ldr   x16, [x16, #0xc80]      ; pool const I
0x724a90: stur  w16, [x0, #0xf]         ; array[0] = const I
0x724a94: ldur  x1, [fp, #-0xc0]        ; reload the value anchored back in worked example 3 (fp-0xc0)
0x724a98: stur  w1, [x0, #0x13]         ; array[1] = that value
0x724a9c: ldr   x16, [PP, #0x2050]      ; const H, yet again
0x724aa0: stp   x0, x16, [SP]           ; pass (array, const H)
0x724aa4: bl    #0x6e0e60               ; call B a third time, fed the 4-slot array -> object #3
0x724aa8: add   x1, PP, #0x1e, lsl #12
0x724aac: ldr   x1, [x1, #0xc0]         ; pool: the same fixed code reference as before
0x724ab0: mov   x2, NULL
0x724ab4: stur  x0, [fp, #-0xc0]        ; anchor: fp-0xc0 reused = object #3
0x724ab8: bl    #0x10cb178              ; closure-build again, same underlying function
0x724abc: ldur  x1, [fp, #-0xc0]        ; reload object #3
0x724ac0: mov   x2, x0
0x724ac4: bl    #0x725920               ; the same call as before, on object #3 this time
0x724ac8: ldr   x16, [PP, #0x2050]
0x724acc: ldr   lr, [THR, #0x90]
0x724ad0: stp   lr, x16, [SP]
0x724ad4: bl    #0x6e0e60               ; call B a fourth time, empty args again -> object #4
0x724ad8: ldur  x1, [fp, #-0xd0]        ; reload the OTHER argument anchored in example 3 (fp-0xd0)
0x724adc: stur  x0, [fp, #-0xd0]        ; anchor: fp-0xd0 overwritten with object #4
0x724ae0: bl    #0x725870               ; call taking that argument alone -> a new value in x0
0x724ae4: ldur  x1, [fp, #-0xd0]        ; reload object #4
0x724ae8: mov   x2, x0
0x724aec: bl    #0x1098f0c              ; call taking (object #4, that value) -> result discarded
0x724af0: bl    #0x75b7fc               ; allocation shape, no populated args visible beforehand
0x724af4: mov   x1, x0
0x724af8: add   x0, PP, #0x1e, lsl #12
0x724afc: ldr   x0, [x0, #0xc8]         ; pool const J
0x724b00: stur  w0, [x1, #7]            ; field(+7) = const J
0x724b04: ldur  x0, [fp, #-0xd8]        ; reload object #1 -- first use since 0x724a48
0x724b08: stur  w0, [x1, #0x2b]         ; field(+0x2b) = object #1, untouched
0x724b0c: ldur  x0, [fp, #-0xc0]        ; reload object #3 (post its own call at 0x724ac4)
0x724b10: stur  w0, [x1, #0xb]          ; field(+0xb) = object #3
0x724b14: ldur  x0, [fp, #-0xc8]        ; reload the arg anchored fp-0xc8 in example 3
0x724b18: ldur  w4, [x0, #7]            ; field(+7) of that
0x724b1c: add   x4, x4, HEAP, lsl #32   ; decompress -> a heap pointer
0x724b20: stur  x4, [fp, #-0xc0]        ; anchor: fp-0xc0 reused again = this new pointer
0x724b24: ldur  w2, [x4, #7]            ; field(+7) of THAT pointer
0x724b28: add   x2, x2, HEAP, lsl #32
0x724b2c: ldr   x16, [PP, #0x40]        ; a specific, recurring pool constant
0x724b30: cmp   w2, w16
0x724b34: b.eq  #0x724bf8               ; equal -> one of the tail cases below
0x724b38: ldur  x5, [fp, #-0xd0]        ; reload object #4 (now populated via the call at 0x724aec)
0x724b3c: ldur  x6, [fp, #-0xe0]        ; reload object #2 (post its own call at 0x724a78)
0x724b40: add   x3, PP, #0x1e, lsl #12
0x724b44: ldr   x3, [x3, #0xd0]         ; pool: a literal string
0x724b48: ldr   x4, [PP, #0x1310]       ; pool: a small fixed-shape constant list
0x724b4c: bl    #0x752c40               ; call taking (x1, x2, x3, x4, x5, x6) -> x0
0x724b50: mov   x1, x0
0x724b54: ldur  x0, [fp, #-0xc0]        ; reload the pointer anchored at 0x724b20
0x724b58: ldur  w2, [x0, #7]            ; the SAME field(+7) read again
0x724b5c: add   x2, x2, HEAP, lsl #32
0x724b60: ldur  w3, [x2, #0x47]         ; a field of THAT pointer
0x724b64: add   x3, x3, HEAP, lsl #32
0x724b68: ldr   x16, [PP, #0x40]        ; the SAME recurring pool constant as before
0x724b6c: cmp   w3, w16
0x724b70: b.eq  #0x724c04               ; equal -> a different tail case
0x724b74: str   x3, [SP]
0x724b78: add   x4, PP, #0x1d, lsl #12
0x724b7c: ldr   x4, [x4, #0x988]        ; pool: another small fixed-shape constant list
0x724b80: bl    #0x7176c8               ; call taking (x1, x3-via-SP, x4) -> x0
0x724b84: add   x16, PP, #0x1e, lsl #12
0x724b88: ldr   x16, [x16, #0xb0]       ; pool object, TypeArguments-shaped again
0x724b8c: ldur  lr, [fp, #-0xc8]        ; reload the arg anchored fp-0xc8 (example 3)
0x724b90: stp   lr, x16, [SP, #8]
0x724b94: str   x0, [SP]
0x724b98: ldr   x4, [PP, #0x48]         ; yet another small fixed-shape constant list
0x724b9c: bl    #0x725730               ; call taking (that arg, x0) -> a new x0
0x724ba0: ldr   x16, [PP, #0xc0]        ; pool object, TypeArguments-shaped
0x724ba4: ldur  lr, [fp, #-0xc0]        ; reload the pointer from 0x724b20 yet again
0x724ba8: stp   lr, x16, [SP, #8]
0x724bac: str   x0, [SP]
0x724bb0: ldr   x4, [PP, #0x48]         ; the same constant list as the previous call
0x724bb4: bl    #0x71a7a4               ; call taking (that pointer, x0) -> a Future in x0
0x724bb8: mov   x1, x0
0x724bbc: stur  x1, [fp, #-0xc0]        ; anchor: fp-0xc0 reused = the Future
0x724bc0: bl    #0x7e84ac               ; suspend-and-resume shape, cf. Flutter-Dart-AOT
0x724bc4: stur  x0, [fp, #-0xc0]        ; anchor: fp-0xc0 reused = the resolved value
0x724bc8: ldur  w2, [x0, #0xb]          ; field(+0xb) of the resolved value
0x724bcc: add   x2, x2, HEAP, lsl #32
0x724bd0: cmp   w2, NULL                ; a REAL null check -- against NULL, not a pool constant
0x724bd4: b.eq  #0x724c10               ; null -> a tail case
0x724bd8: mov   x1, NULL
0x724bdc: bl    #0x724c5c               ; call taking (NULL, that field) -> the function's real result
0x724be0: b     #0x7e8334               ; async-return shape, matches example 3's InitAsync note
0x724be4: sub   SP, fp, #0xf8           ; unwind straight to the frame base -- exception path
0x724be8: bl    #0x10ca0a0
0x724bec: brk   #0                      ; unreachable trap
0x724bf0: bl    #0x10cbf4c              ; overflow slow path
0x724bf4: b     #0x724a2c               ; retry from the start of this excerpt
0x724bf8: add   x9, PP, #0x1d, lsl #12
0x724bfc: ldr   x9, [x9, #0x990]        ; pool: some extra value, unused elsewhere
0x724c00: bl    #0x10cc85c              ; error-stub shape -- never returns
0x724c04: add   x9, PP, #0x1d, lsl #12
0x724c08: ldr   x9, [x9, #0x998]        ; a DIFFERENT pool value, identical shape to the above
0x724c0c: bl    #0x10cc85c              ; the SAME error-stub target as 0x724c00
0x724c10: bl    #0x10cc5d4              ; a THIRD, distinct error-stub target
```

Reading it cold: right after the stack-overflow check completes — the same position `AwaitStub` occupies later in this same excerpt — a call takes exactly one pool object shaped like a `TypeArguments` (per [[Flutter-Dart-AOT]]) and nothing from it is ever used again; positionally and structurally that's an async-continuation setup, the counterpart of the suspend point further down, even though naming it needs a symbol table. What follows is four calls to the same target (`0x6e0e60`), each preceded by either an empty two-slot `SP` push or a populated one — an allocation shape repeated four times, giving four containers (labeled #1-#4 above only for this walkthrough). Three of those four immediately feed into the exact closure-then-call idiom from "Closures: build, then feed to a call" earlier in this chapter: build a closure over the *same fixed function address* both times (`0x10cb178` with a constant `x1`), pass `(container, closure)` to a second fixed call, and discard the result — the shape of "mutate a container in place according to a predicate," whatever that predicate turns out to check. Object #3 is the interesting one of the three: it gets built from a *populated* 4-slot array (const `I` at slot 0, the value anchored back in example 3's own `fp-0xc0` at slot 1) — the exact "allocate an array, `stur` a couple of values into it, hand it to one consumer" shape from worked example 1, here producing a two-entry key/value container from a value this same function already resolved earlier. Object #4 reuses the *other* argument this function was handed (`fp-0xd0`, anchored in example 3), passes it alone to one call, then merges that call's result into object #4 via a `(container, value)` call whose result is likewise discarded — "convert this argument to another shape, then absorb it into a container," honestly indistinguishable at the byte level from "serialize an object into a map," which is exactly what it turns out to be (see below). Object #1, by contrast, is written once and never read again until it's dropped, completely unmodified, straight into a fourth object's field at `+0x2b` — a passthrough default. That fourth object itself is the clearest instance of worked example 1's shape in this whole excerpt: a `bl` with no visible input, immediately followed by three `stur`s into its result at `+7`/`+0x2b`/`+0xb` — allocate, then populate, full stop.

The genuinely new shape here appears twice, at `0x724b14`-`0x724b34` and again at `0x724b54`-`0x724b70`: reload a pointer, read one of its fields, decompress it, compare against *the same* recurring pool constant both times, and branch on equality to a call-only block that never returns. That's not an ordinary null check — the real one sits a few instructions later at `0x724bd0`, comparing against the `NULL` register itself, and the contrast is instructive precisely because both patterns are two-instruction guards around a field read that look superficially alike. A guard against one specific *non-`NULL`* pool value, immediately followed by a dead-end call, is the shape of a **lazily-initialized field being read before it's ready** — the two tail blocks even reinforce this: each loads one more pool value tied to its own specific field before calling the same never-returning target (`0x724bf8`/`0x724c04` both call `0x10cc85c`), while the third tail (`0x724c10`, guarded by the real null check) calls a *different* target — three distinct failure modes, distinguishable from each other purely by which guard reached them and which pool value each loads right before its own call, without yet knowing any of their names. Past both guards, three calls chain together against one repeated pointer (the one anchored at `0x724b20`): the first combines it with the two filtered/merged containers, a literal string, and a small pool-constant list; the second takes that result plus the same pointer's own field; the third takes that result plus the pointer again — "build up one configuration object, piece by piece, always against the same receiver," each step's small `const [...]` pool list a fixed-shape argument descriptor distinct from the runtime-built arrays of worked example 1, present at nearly every one of these calls but at none of the four container-building ones. What follows the chain is the suspend/resume shape by position alone (a value anchored, then a call, then the *same* stack slot immediately overwritten with what comes back) — before one field of the resumed value gets the real null check, and either a final call combines `(NULL, that field)` into the function's actual result, returned through the async-return branch rather than a plain `ret`, or execution falls into one of the three dead-end tails already described.

**Shape-only conclusion:** continuing directly from example 3's two resolved arguments, this half of the function builds two filtered key/value containers and one merged, serialized-argument container; assembles a single configuration object from a passthrough default, a filtered container, and a merged one; chains three calls against one repeated pointer, gated twice by a lazy-field guard distinct from an ordinary null check; suspends on a fourth call's result; and on resuming either extracts and returns one field or falls into one of three distinguishable, never-returning failure paths. **Needs a lookup:** what the two guarded fields and the three tail targets actually are, and what package the four "container" and three "chain" calls belong to — in the investigation this excerpt comes from ([[ClasseViva-Case-Study]], see [[Hooking-Dart-AOT-Login-With-Frida]]), this is `dio`'s `Options.compose()` and `RequestOptions.copyWith()` building the outgoing request, gated by two `late` fields on the app's `Dio` client (`options`, then `BaseOptions._baseUrl`) that throw `LateInitializationError` if read before Dio's own setup has run, followed by `dio.fetch<Map<String, dynamic>>()`, an `await`, a `response.data` null check (`NullCastError` on the tail that guards it), and `LoginJTO.fromJson()` on success — the network call this entire function exists to make. The shape-only read above reaches every one of those conclusions' *structure* without needing a single one of those names.

## More patterns, worked cold

Shorter excerpts, each isolating one additional recognizable shape not yet covered above.

### Closures: build, then feed to a call

From `GradeUtils.getAvg` — building one closure and immediately calling a method with it:

```
0xc20cfc: add  x1, PP, #0x26, lsl #12
0xc20d00: ldr  x1, [x1, #0x3f8]         ; pool: a function reference
0xc20d04: mov  x2, NULL
0xc20d08: bl   #0x10cb178               ; result in x0 = a closure object
0xc20d0c: ldur x1, [fp, #-8]            ; some other, already-anchored value
0xc20d10: ldur x2, [x1, #-1]
0xc20d14: ubfx x2, x2, #0xc, #0x14      ; class-id of THAT value (not the closure)
0xc20d18: ldr  x16, [PP, #0x3fa0]       ; pool: type-argument object
0xc20d1c: stp  x1, x16, [SP, #0x10]
0xc20d20: ldr  x16, [PP, #0x4688]       ; pool: a constant (0.0?)
0xc20d24: stp  x0, x16, [SP]            ; the closure goes here, as an argument
0xc20d28: mov  x0, x2
0xc20d2c: ldr  x4, [PP, #0x758]
0xc20d30: movz x17, #0x490d
0xc20d34: movk x17, #0x1, lsl #16
0xc20d38: add  lr, x0, x17
0xc20d3c: ldr  lr, [x21, lr, lsl #3]    ; GDT dispatch, same shape as example 2
0xc20d40: blr  lr                       ; virtual call, closure passed as an arg
```

A `bl` to a fixed address that takes _no visible object to populate afterward_ and whose result is immediately staged as one argument among several to a following virtual call — that's the tell for closure creation specifically, distinct from the "allocate, then populate its own fields" shape of example 1: here the freshly-built value isn't filled in further, it's handed _outward_, to somebody else's call. The value being dispatched on (`x1`/`fp-8`) is a _different_ object from the closure just built — this is "call a method on one thing, passing a closure built from something else" (a callback-taking method, per [[Flutter-Dart-AOT#Explanation|Closures]]), not the closure calling itself.

### Cascading enum dispatch, three cases

From `AbsenceLocalizations.absenceAbbreviationName` (compare against the fully-annotated version in [[Enum-Switch-Via-Pointer-Comparison]]):

```
0xdb281c: ldur w2, [x1, #0xf]           ; field @+0xf
0xdb2820: add  x2, x2, HEAP, lsl #32    ; decompress -> a heap pointer
0xdb2824: add  x16, PP, #9, lsl #12
0xdb2828: ldr  x16, [x16, #0x6a0]       ; pool object A
0xdb282c: cmp  w2, w16                  ; field == A ?
0xdb2830: b.ne #0xdb2954                ; no -> next case
                                         ; ... case A body (elided) ...
0xdb2954: add  x16, PP, #9, lsl #12
0xdb2958: ldr  x16, [x16, #0x6b0]       ; pool object B (different address)
0xdb295c: cmp  w2, w16                  ; field == B ?
0xdb2960: b.ne #0xdb2a10                ; no -> next case
                                         ; ... case B body (elided) ...
0xdb2a10: add  x16, PP, #9, lsl #12
0xdb2a14: ldr  x16, [x16, #0x6e0]       ; pool object C
0xdb2a18: cmp  w2, w16                  ; field == C ?
0xdb2a1c: b.ne #0xdb2acc                ; no -> default/else
```

One field, loaded once, then compared by identity against three _different_ pool-loaded addresses in sequence, each guarded by its own `b.ne` to the next comparison — a cascading `if (x == A) ... else if (x == B) ... else if (x == C) ... else ...` shape, per [[Control-Flow-Patterns]]. Nothing here needs a `switch`-keyword or an enum name to recognize: three structurally identical compare-and-branch blocks in a row, each against a distinct constant, _is_ the shape. Counting how many times this three-instruction unit (`pool-load`, `cmp`, `b.ne`) repeats before the branches stop chaining tells you how many cases there are, without reading a single case body.

### The same seven instructions, once per JSON field

From `LoginResponseJTO.fromJson` (two fields shown; a real deserializer repeats this once per field, only the key string and the following type-check differing):

```
0x724e88: ldur x0, [x3, #-1]
0x724e8c: ubfx x0, x0, #0xc, #0x14      ; class-id of the map
0x724e90: mov  x1, x3
0x724e94: add  x2, PP, #0x11, lsl #12
0x724e98: ldr  x2, [x2, #0xb20]         ; pool: key string #1
0x724e9c: sub  lr, x0, #0xd73
0x724ea0: ldr  lr, [x21, lr, lsl #3]    ; GDT dispatch -- map's own [] operator
0x724ea4: blr  lr                       ; map[key #1]
0x724ea8: mov  x3, x0                   ; result, type-unchecked so far
                                         ; ... branchIfSmi / class-id dance (elided) ...
0x724ee0: bl   #0x10f70dc               ; IsType_String_Stub -- must be non-null String
                                         ; --- repeats: key string #2, a nullable-type check ---
                                         ; --- repeats: key string #3, another type check ---
```

Same virtual-dispatch shape as examples 2 and the closure above (class-id extraction, computed `blr`), but the _target_ is always the same map-indexing operator, and the only things that change call to call are which pool string gets passed in and which `IsType_..._Stub` follows. Recognizing "this exact instruction group, repeated N times, each with a different pool string and a different (or absent) type-check stub afterward" _is_ recognizing "this is a JSON object being deserialized field by field" — without needing a single field's name to notice the pattern or count how many fields there are.

## More examples

- [[Tracking-A-Stack-Slots-Meaning]] — the anchor-then-follow technique in isolation, on a short hand-written function

## See also

- [[Functions-And-Calling-Convention]]
- [[Memory-And-Data-Structures]]
- [[Control-Flow-Patterns]]
- [[Flutter-Dart-AOT]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]

## Flashcards
#flashcards

When a comment-free disassembly shows a register used in a computation without ever being anchored by a `mov`/`stur` from an argument register or a prior instruction in the same function, what does that tell you?::It must be something the caller set up as part of the call itself, outside the normally-anchored arguments — worth tracing forward from its first use rather than assuming it's unexplainable.
What shape identifies inline heap allocation even with no `AllocateXStub` name attached to the call?::A bump-pointer sequence against a fixed thread-register offset (load top/end, compare, advance, store back) — or, for an out-of-line allocation, a `bl` whose result immediately gets populated field-by-field via `stur`s.
What shape identifies a virtual/dispatch call even with no `GDT[...]` comment?::Extracting a class id from an object header (`ldur` at `-1`, then `ubfx`) immediately followed by using that id to index a fixed table-base register in a computed `blr`.
What distinguishes a freshly-built closure from a freshly-built ordinary object in the disassembly that follows its allocation?::An ordinary object gets its own fields populated afterward (`stur`s into it); a closure instead gets staged as an argument to a following call, without further fields being written into it directly.
What shape identifies a guarded/lazy field read (e.g. a Dart `late` field) even with no field name attached?::A field read immediately compared against one specific, recurring *non-`NULL`* pool constant, branching on equality to a call-only block that never returns — distinct from an ordinary null check, which compares against the `NULL` register itself.
