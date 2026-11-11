---
tags: [reference, reference-entry]
category: "instruction"
created: 2026-11-11
---

# LDR-And-STR

## Signature / syntax

```asm
; 1. Unsigned scaled offset (base register unchanged, #pimm >= 0 and multiple of access size):
ldr    Xt|Wt, [Xn|SP, #pimm]
str    Xt|Wt, [Xn|SP, #pimm]

; 2. Unscaled signed 9-bit byte offset (-256 .. +255, any byte alignment):
ldur   Xt|Wt, [Xn|SP, #simm9]
stur   Xt|Wt, [Xn|SP, #simm9]

; 3. Pre-index (update base FIRST) and Post-index (update base AFTER), signed 9-bit byte offset:
ldr    Xt|Wt, [Xn|SP, #simm9]!
ldr    Xt|Wt, [Xn|SP], #simm9

; 4. Register offset (with optional index extension and shift):
ldr    Xt|Wt, [Xn|SP, Xm {, lsl #amount}]
ldr    Xt|Wt, [Xn|SP, Wm, uxtw|sxtw {#amount}]

; Sub-word zero-extending and sign-extending variants (all addressing modes above apply):
ldrb / strb   Wt, [...]          ; 8-bit unsigned load (zero-extends to Wt/Xt) / 8-bit store
ldrh / strh   Wt, [...]          ; 16-bit unsigned load (zero-extends to Wt/Xt) / 16-bit store
ldrsb         Wt|Xt, [...]       ; 8-bit signed load (sign-extends to 32-bit Wt or 64-bit Xt)
ldrsh         Wt|Xt, [...]       ; 16-bit signed load (sign-extends to 32-bit Wt or 64-bit Xt)
ldrsw         Xt, [...]          ; 32-bit signed load (sign-extends to 64-bit Xt)
```

## Description

`ldr` (**Load Register**) and `str` (**Store Register**), along with their unscaled (`ldur`/`stur`) and sub-word (`b`/`h`/`sb`/`sh`/`sw`) siblings, are the primary single-register memory access instructions in AArch64. Because AArch64 is a strict load/store architecture, arithmetic and logical instructions never touch memory directly; every struct field read, array indexing operation, vtable lookup, and local stack spill passes through this family.

### The three main addressing modes

1. **Offset mode (base unchanged)** — computes `addr = base + offset` and leaves `base` unmodified. At the machine-encoding level, this splits into two distinct opcodes that disassemblers print with different mnemonics:
   - **`ldr`/`str` (unsigned scaled 12-bit immediate)**: the immediate is scaled by the access size (`1` for byte, `2` for halfword, `4` for 32-bit word (`0`..`16380`), `8` for 64-bit doubleword (`0`..`32760`)). It cannot encode negative offsets or offsets that aren't multiples of the access width.
   - **`ldur`/`stur` (unscaled signed 9-bit immediate)**: encodes any raw byte offset in `-256`..`+255` regardless of alignment. Compilers emit `ldur`/`stur` whenever an offset is negative (such as frame-pointer-relative stack locals `[fp, #-8]`) or not a multiple of the access size (such as tagged Dart heap pointers).
2. **Pre-index (`[base, #simm9]!`) and Post-index (`[base], #simm9`)** — folds a pointer increment or decrement into the load/store using a signed 9-bit byte offset (`-256`..`+255`). Pre-index updates `base` before the memory access; post-index accesses `[base]` first and then adds `#simm9` to `base` (classic for pointer-walking loops like `ldrb w2, [x1], #1` in [[String-Length-And-Pointer]]).
3. **Register offset (`[base, index, extend #shift]`)** — computes `addr = base + (extend(index) << shift)`. When the index is a 32-bit `Wm` register (e.g. a C `int i`), the instruction sign-extends (`sxtw`) or zero-extends (`uxtw`) it to 64 bits and optionally shifts it by `log2(sizeof(element))` (`#1` for `int16_t`, `#2` for `int32_t`, `#3` for `int64_t`/pointers).

### Zero-extension vs. sign-extension into `Wn`/`Xn`

Every write to a 32-bit `Wt` register in AArch64 automatically zeroes the upper 32 bits of the underlying 64-bit `Xt` register:

| Instruction | Bytes read | Bits `[31:0]` of `Xt` | Bits `[63:32]` of `Xt` |
| --- | --- | --- | --- |
| `ldrb Wt, [...]` | 1 | Zero-extended from byte (`0x000000XX`) | Cleared to `0` |
| `ldrsb Wt, [...]` | 1 | Sign-extended to 32 bits | Cleared to `0` |
| `ldrsb Xt, [...]` | 1 | Sign-extended to 64 bits | Copies of bit 7 (sign bit) |
| `ldr Wt, [...]` / `ldur Wt, [...]` | 4 | Raw 32-bit word | Cleared to `0` |
| `ldrsw Xt, [...]` / `ldursw Xt, [...]` | 4 | Raw 32-bit word | Copies of bit 31 (sign bit) |
| `ldr Xt, [...]` / `ldur Xt, [...]` | 8 | Low 32 bits of doubleword | High 32 bits of doubleword |

## Example

```asm
; 1. Plain C array indexing with sign-extended 32-bit index (arr[i] where arr is int32_t*):
    ldr     w0, [x0, w1, sxtw #2]    ; w0 = *(int32_t *)((char *)x0 + (int64_t)w1 * 4)

; 2. Jump-table relative offset load (unsigned-extended 32-bit index, sign-extended 32-bit entry):
    ldrsw   x2, [x1, w0, uxtw #2]    ; x2 = (int64_t)(*(int32_t *)(x1 + (uint64_t)w0 * 4))

; 3. Dart AOT tagged-pointer field reads and header read (why `ldur` dominates libapp.so):
    ldur    x2, [x1, #-1]            ; read 64-bit object header at (tagged_ptr - 1)
    ldur    w3, [x1, #7]             ; read 32-bit compressed pointer field at (tagged_ptr + 7)
    add     x3, x3, HEAP, lsl #32    ; DecompressPointer: restore upper 32 bits from HEAP (x28)
    ldur    x4, [x1, #0x3f]          ; read 64-bit unboxed int/double field at (tagged_ptr + 0x3f)
```

## Notes

- **Why Dart AOT uses `ldur` with odd and negative offsets (`#-1`, `#7`, `#0xf`, `#0x13`)**: Every heap pointer in the Dart VM is **tagged** by setting bit 0 to `1` (`tagged_ptr = raw_object_addr + 1`) so the runtime can distinguish heap pointers from tagged small integers (Smis, bit 0 = `0`) with a single bit test (see [[CBZ-CBNZ-And-TBZ-TBNZ]]). Because `tagged_ptr` is 1 byte past the object's real 8-byte-aligned start address:
  - The object's header word at `raw_object_addr + 0` sits at `tagged_ptr - 1` (`[xN, #-1]`).
  - The first field after the 8-byte header (`raw_object_addr + 8`) sits at `tagged_ptr + 7` (`[xN, #7]`), the next 4-byte compressed field at `raw_object_addr + 12` sits at `tagged_ptr + 0xb` (`[xN, #0xb]`), and so on.
  - Because `-1`, `7`, `0xb`, `0xf`, `0x13` are neither non-negative multiples of 4 nor multiples of 8, `ldr`'s scaled unsigned offset encoding cannot represent them — forcing the compiler to emit `ldur` and `stur` for virtually every Dart object field access.
- **Compressed pointer loads (`ldur wN` vs `ldur xN`)**: On 64-bit Android, Dart AOT stores object references inside heap fields as 32-bit compressed pointers. Because writing `wN` automatically clears the upper 32 bits of `xN`, `ldur w3, [x1, #7]` zero-extends the 32-bit compressed offset into `x3` so that the immediately following `add x3, x3, HEAP, lsl #32` can reconstruct the full 64-bit pointer in one instruction.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Registers-And-Data]]
- [[Instructions]]
- [[Memory-And-Data-Structures]]
- [[Register-Width-And-Sign-Extension]]
- [[Load-Store-Addressing-Modes]]
- [[Struct-Field-Access]]
- [[STP-And-LDP]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
