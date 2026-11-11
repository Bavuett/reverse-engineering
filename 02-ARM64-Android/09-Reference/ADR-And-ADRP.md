---
tags: [reference, reference-entry]
category: "instruction"
created: 2026-11-11
---

# ADR-And-ADRP

## Signature / syntax

```asm
; Byte-granular PC-relative address (+/- 1 MiB range from PC):
adr    Xd, label

; 4 KiB page-granular PC-relative address (+/- 4 GiB range from PC):
adrp   Xd, label

; Standard two-instruction idioms with adrp:
adrp   Xd, symbol
add    Xd, Xd, :lo12:symbol      ; materialize pointer to `symbol` in .rodata / .data / .text

adrp   Xd, symbol
ldr    Xt, [Xd, :lo12:symbol]    ; load the value at `symbol` (e.g. a global or .got entry)
```

## Description

`adr` (**Form PC-relative address**) and `adrp` (**Form PC-relative address to 4 KB page**) compute a runtime memory address relative to the current instruction's Program Counter (`PC`) and write it into `Xd`, without touching memory or condition flags. Because Android requires every native library (`.so`) and executable to be compiled as a **Position-Independent Executable/shared object (PIE/PIC)** so the dynamic linker can map it at a randomized ASLR base address, instructions cannot hardcode absolute 64-bit pointers to globals, strings, jump tables, or functions. Instead, because the distance between a code section (`.text`) and a data section (`.rodata`, `.data`, `.got`) within the same `.so` is fixed at link time, the compiler uses `adr` or `adrp` to turn that known relative offset into a real virtual address at runtime.

| Instruction | Calculation | Signed immediate bits | Reach from `PC` | Typical use |
| --- | --- | --- | --- | --- |
| `adr Xd, label` | `Xd = PC + sign_extend(imm21)` | 21 bits (byte-scaled) | $\pm 1\text{ MiB}$ | Nearby labels in the same function or small binary (e.g. a local jump table or nearby literal) |
| `adrp Xd, label` | `Xd = (PC & ~0xfff) + (sign_extend(imm21) << 12)` | 21 bits (scaled by $4096 = 2^{12}$) | $\pm 4\text{ GiB}$ | Standard compiler choice across an entire `.so`: computes the base of the 4 KiB page containing the target |

Because `adrp` clears the low 12 bits of `PC` (`PC & ~0xfff`) and adds a page-aligned offset, its result `Xd` points to the start of the **4 KiB page** containing the target symbol, not the symbol itself. A second instruction immediately supplies the remaining 12-bit unsigned byte offset (`0x000`–`0xfff`, written `:lo12:symbol` in assembly source and resolved to a literal immediate by the linker):

1. **`adrp` + `add` (pointer materialization)** — `add Xd, Xd, #page_offset` produces the exact address of the object (`&symbol`), used when passing a `.rodata` string literal, a `JNINativeMethod` array, or a jump-table base pointer to another instruction or function call.
2. **`adrp` + `ldr`/`str` (direct load/store)** — folds the 12-bit page offset directly into the unsigned immediate field of `ldr`/`str` (`ldr Xt, [Xd, #page_offset]`), reading or writing a global variable or a Global Offset Table (`.got`) slot in two instructions instead of three.

## Example

```asm
; 1. Passing a .rodata string literal and JNI method table to RegisterNatives (NDK / libflutter.so):
    adrp   x1, #0x45000                  ; x1 = 4 KiB page base 0x45000
    add    x1, x1, #0x8a0                ; x1 = 0x458a0 -> pointer to gFlutterJNIMethods table

; 2. Calling an external function through a PLT stub (.plt -> .got indirection):
malloc@plt:
    adrp   x16, #0x68000                 ; x16 = page base of the .got section
    ldr    x17, [x16, #0xc18]            ; x17 = *(0x68c18) -> runtime address of libc's malloc
    br     x17                           ; tail-jump to malloc

; 3. Indexing a position-independent switch jump table:
    adrp   x1, #0x12000                  ; page of .Ljmp_tbl in .rodata
    add    x1, x1, #0x340                ; x1 = exact base address of .Ljmp_tbl
    ldrsw  x2, [x1, w0, uxtw #2]         ; load 32-bit signed offset for case w0
    add    x1, x1, x2                    ; target = table_base + relative_offset
    br     x1
```

## Notes

- **Reading `adrp` in raw disassembly (`objdump` vs. Ghidra/IDA)**: Disassemblers already compute the target page for you and print the resolved file/VMA page address (e.g. `adrp x1, 0x45000`) rather than the raw 21-bit signed delta. To find the final target address by hand when reading raw `objdump` output, simply add the following `add` or `ldr` immediate to the page address printed on the `adrp` line (`0x45000 + 0x8a0 = 0x458a0`). Note that `adrp` uses the **page** of the current `PC` (`PC & ~0xfff`), not the exact `PC` — the disassembler has already masked the low 12 bits of `PC` when printing `0x45000`.
- **Two loads vs. one `add` (`adrp`+`add` vs. `.got` load)**: For symbols guaranteed to live inside the same `.so` and not interposable (like a `.rodata` string literal or static struct), the compiler emits `adrp` + `add` (`Xd = &symbol`). For exported global variables or functions that might live in another shared library, the compiler emits `adrp` + `ldr` from `.got` to fetch the runtime pointer filled in by the Android dynamic linker (`linker64`), followed by a second `ldr` or `blr` if dereferencing/calling that pointer.
- **How Dart AOT replaces `adrp` with the Object Pool (`PP`)**: In a Flutter `libapp.so`, AOT-compiled Dart functions rarely use `adrp` to load constants. Instead, because `PP` (`x27`) permanently points to the isolate's Object Pool in the heap, Dart code uses an analogous two-instruction split against `PP` (`add x16, PP, #0xb, lsl #12` followed by `ldr x16, [x16, #0xc40]`) — the exact same "12-bit page shift + 12-bit byte offset" arithmetic, anchored at `PP` rather than `PC` (see [[Flutter-Dart-AOT]] and [[Object-Pool-Constant-Loads]]).

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Instructions]]
- [[Android-Native-Internals]]
- [[PLT-Stub-And-Indirect-Call]]
- [[Switch-As-Jump-Table]]
- [[JNI-OnLoad-And-RegisterNatives-In-Libflutter]]
- [[Object-Pool-Constant-Loads]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
