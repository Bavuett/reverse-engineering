---
tags: [reference, reference-entry]
category: "instruction"
created: 2026-11-11
---

# UBFM-SBFM-And-Bitfield-Aliases

## Signature / syntax

```asm
; Underlying machine instructions (rarely printed directly by disassemblers):
ubfm   Wd|Xd, Wn|Xn, #immr, #imms      ; Unsigned Bitfield Move (zeroes bits outside the moved field)
sbfm   Wd|Xd, Wn|Xn, #immr, #imms      ; Signed Bitfield Move   (sign-extends from bit #imms, zeroes low bits)
bfm    Wd|Xd, Wn|Xn, #immr, #imms      ; Bitfield Move          (leaves destination bits outside the field unchanged)

; Preferred disassembler aliases you actually read in objdump / Ghidra / blutter:
ubfx   Wd|Xd, Wn|Xn, #lsb, #width      ; Unsigned Bitfield eXtract:        dst = zero_extend(src[lsb + width - 1 : lsb])
sbfx   Wd|Xd, Wn|Xn, #lsb, #width      ; Signed Bitfield eXtract:          dst = sign_extend(src[lsb + width - 1 : lsb])
ubfiz  Wd|Xd, Wn|Xn, #lsb, #width      ; Unsigned Bitfield Insert in Zero: dst = zero_extend(src[width - 1 : 0]) << lsb
sbfiz  Wd|Xd, Wn|Xn, #lsb, #width      ; Signed Bitfield Insert in Zero:   dst = sign_extend(src[width - 1 : 0]) << lsb
bfi    Wd|Xd, Wn|Xn, #lsb, #width      ; Bitfield Insert (keep other bits): dst[lsb + width - 1 : lsb] = src[width - 1 : 0]
bfxil  Wd|Xd, Wn|Xn, #lsb, #width      ; Bitfield eXtract and Insert Low:   dst[width - 1 : 0] = src[lsb + width - 1 : lsb]

; Shift and integer-extension aliases (also encoded as ubfm / sbfm!):
lsl    Wd|Xd, Wn|Xn, #shift            ; alias of ubfm: logical shift left by #shift
lsr    Wd|Xd, Wn|Xn, #shift            ; alias of ubfm: logical shift right by #shift
asr    Wd|Xd, Wn|Xn, #shift            ; alias of sbfm: arithmetic shift right by #shift
uxtb   Wd, Wn                          ; alias of ubfm Wd, Wn, #0, #7   (zero-extend 8-bit byte to 32/64 bits)
uxth   Wd, Wn                          ; alias of ubfm Wd, Wn, #0, #15  (zero-extend 16-bit halfword to 32/64 bits)
sxtb   Wd|Xd, Wn                       ; alias of sbfm Rd, Rn, #0, #7   (sign-extend 8-bit byte to 32 or 64 bits)
sxth   Wd|Xd, Wn                       ; alias of sbfm Rd, Rn, #0, #15  (sign-extend 16-bit halfword to 32 or 64 bits)
sxtw   Xd, Wn                          ; alias of sbfm Xd, Xn, #0, #31  (sign-extend 32-bit word to 64 bits)
```

## Description

In AArch64, immediate shifts (`lsl`, `lsr`, `asr`), sub-word integer sign/zero extensions (`uxtb`, `uxth`, `sxtb`, `sxth`, `sxtw`), bitfield extractions (`ubfx`, `sbfx`), and bitfield insertions (`ubfiz`, `sbfiz`) are **not separate machine opcodes**. Every one of them is an assembler/disassembler alias for just two underlying instructions: **`ubfm` (Unsigned Bitfield Move)** and **`sbfm` (Signed Bitfield Move)** (plus `bfm` for in-place bitfield updates that preserve surrounding destination bits).

Understanding how those aliases map to high-level C/Dart operations lets you read packed-header decoding, struct bitfields, and Dart tagged-integer (`Smi`) conversions effortlessly:

| Disassembler alias | Underlying encoding (`N` = 32 or 64) | Mathematical effect on `src` (`Wn`/`Xn`) | Primary use in Android ARM64 disassembly |
| --- | --- | --- | --- |
| `ubfx Rd, Rn, #lsb, #width` | `ubfm Rd, Rn, #lsb, #(lsb + width - 1)` | `(Rn >> lsb) & ((1 << width) - 1)` | Extracting unsigned packed fields — most famously Dart's 20-bit Class ID from the object header (`ubfx x2, x2, #0xc, #0x14`) |
| `sbfx Rd, Rn, #lsb, #width` | `sbfm Rd, Rn, #lsb, #(lsb + width - 1)` | Sign-extend `width`-bit field starting at `lsb` | **Untagging a Dart `Smi`** (`sbfx x2, x0, #1, #0x1f`, shifting right by 1 and sign-extending the 31-bit integer to 64 bits) |
| `ubfiz Rd, Rn, #lsb, #width` | `ubfm Rd, Rn, #(N - lsb), #(width - 1)` | `(Rn & ((1 << width) - 1)) << lsb` | Masking a value to `width` bits and shifting it left into position in one instruction |
| `sbfiz Rd, Rn, #lsb, #width` | `sbfm Rd, Rn, #(N - lsb), #(width - 1)` | `sign_extend(Rn[width - 1 : 0]) << lsb` | **Tagging a Dart `Smi`** (`sbfiz x0, x2, #1, #0x1f`, taking the low 31 signed bits of `x2`, shifting left by 1, and sign-extending to 64 bits) |
| `lsl Rd, Rn, #shift` | `ubfm Rd, Rn, #(N - shift), #(N - 1 - shift)` | `Rn << shift` | Multiplying by $2^{\text{shift}}$ or scaling an array/table index |
| `lsr Rd, Rn, #shift` | `ubfm Rd, Rn, #shift, #(N - 1)` | `(uint)Rn >> shift` | Unsigned division by $2^{\text{shift}}$ or shifting high bits down |
| `asr Rd, Rn, #shift` | `sbfm Rd, Rn, #shift, #(N - 1)` | `(int)Rn >> shift` | Signed division/shift preserving the sign bit |
| `uxtb` / `uxth` | `ubfm Wd, Wn, #0, #7` / `#15` | `Wn & 0xff` / `Wn & 0xffff` | Casting a register to `uint8_t` or `uint16_t` (note: `uxtw` is just `mov Wd, Wn`, since writing `Wd` zeroes the top 32 bits of `Xd`) |
| `sxtb` / `sxth` / `sxtw` | `sbfm Rd, Rn, #0, #7` / `#15` / `#31` | `(int8_t)Wn` / `(int16_t)Wn` / `(int32_t)Wn` | Casting a signed `int8_t`, `int16_t`, or `int32_t` register to 32 or 64 bits |

## Example

```asm
; 1. Dart AOT Class ID extraction from an object header (from Bitfield-Class-Id-Extraction):
    ldur   x2, [x1, #-1]           ; load 64-bit object header word at (tagged_ptr - 1)
    ubfx   x2, x2, #0xc, #0x14     ; extract 20 bits (#0x14) starting at bit 12 (#0xc), zero-extended:
                                   ; x2 = (header >> 12) & 0xfffff  -> runtime Class ID (cid)

; 2. Dart AOT Smi untagging (LoadInt32Instr, from Register-Width-And-Sign-Extension):
    ldur   w0, [x1, #7]            ; load 32-bit tagged Smi field from object
    sbfx   x2, x0, #1, #0x1f       ; extract 31 bits (#0x1f) starting at bit 1, SIGN-extended to 64-bit x2:
                                   ; x2 = (int64_t)((int32_t)w0 >> 1)

; 3. Dart AOT Smi tagging + overflow check (BoxInt64Instr, from Smi-Boxing-And-Unboxing):
    sbfiz  x0, x2, #1, #0x1f       ; take low 31 bits of x2, sign-extend to 64 bits, and shift left by 1
    cmp    x2, x0, asr #1          ; does shifting x0 right by 1 recover the full 64-bit x2?
    b.eq   .Lfits_in_smi           ; yes -> x0 is a valid tagged Smi; no -> call AllocateMintStub
```

## Notes

- **Why `sbfx x2, x0, #1, #0x1f` is used instead of `asr w2, w0, #1` to untag a 32-bit compressed Smi into a 64-bit register**: On 64-bit Dart with compressed pointers, a `Smi` stored in a heap field or passed in the low 32 bits is a **31-bit signed integer** occupying bits `[31:1]` of `x0` (with bit 0 = `0` as the Smi tag). Using `asr x2, x0, #1` would shift bit 63 down instead of sign-extending from bit 31, while `asr w2, w0, #1` would leave bits `[63:32]` of `x2` zeroed (breaking negative numbers when `x2` is later used as a 64-bit signed integer). `sbfx x2, x0, #1, #0x1f` extracts bits `[31:1]` (start at `#1`, width `#0x1f` = 31) and sign-extends bit 31 across all upper bits `[63:31]` of `x2` in a single instruction.
- **Why `sbfiz x0, x2, #1, #0x1f` + `cmp x2, x0, asr #1` is the canonical `BoxInt64Instr` test**: `sbfiz x0, x2, #1, #0x1f` takes bits `[30:0]` of the raw 64-bit integer `x2`, places them at bits `[31:1]` of `x0` with bit 0 cleared to `0`, and sign-extends bit 30 of `x2` into bits `[63:32]` of `x0`. Then `cmp x2, x0, asr #1` shifts `x0` back right by 1 bit and compares it against the original 64-bit `x2`: they are equal if and only if `x2` fit in a signed 31-bit integer ($-2^{30}$ to $2^{30}-1$).
- **Translating `#lsb, #width` to a C bitmask at a glance**: Whenever you see `ubfx Rd, Rn, #lsb, #width`, read the two immediates as **"shift right by `lsb`, then mask to `width` bits"**: `(Rn >> lsb) & ((1ULL << width) - 1)`. Whenever you see `ubfiz Rd, Rn, #lsb, #width`, read it in the opposite order — **"mask to `width` bits first, then shift left by `lsb`"**: `(Rn & ((1ULL << width) - 1)) << lsb`.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Instructions]]
- [[Registers-And-Data]]
- [[Memory-And-Data-Structures]]
- [[Register-Width-And-Sign-Extension]]
- [[Bitfield-Class-Id-Extraction]]
- [[Smi-Boxing-And-Unboxing]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
