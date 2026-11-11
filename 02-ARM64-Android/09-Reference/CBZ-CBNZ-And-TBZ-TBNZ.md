---
tags: [reference, reference-entry]
category: "instruction"
created: 2026-11-11
---

# CBZ-CBNZ-And-TBZ-TBNZ

## Signature / syntax

```asm
; Compare register against zero and branch (+/- 1 MiB range):
cbz    Wt|Xt, label             ; branch to `label` if Wt/Xt == 0
cbnz   Wt|Xt, label             ; branch to `label` if Wt/Xt != 0

; Test a single bit in a register and branch (+/- 32 KiB range):
tbz    Wt|Xt, #bit_num, label   ; branch to `label` if bit `#bit_num` of Wt/Xt == 0
tbnz   Wt|Xt, #bit_num, label   ; branch to `label` if bit `#bit_num` of Wt/Xt == 1
```

## Description

`cbz`/`cbnz` (**Compare and Branch on Zero / Non-Zero**) and `tbz`/`tbnz` (**Test bit and Branch if Zero / Non-Zero**) combine a register test and a PC-relative conditional jump into a single instruction, **without reading or modifying the `PSTATE.NZCV` condition flags**.

| Instruction | Condition tested | Immediate branch range | Typical source-level or runtime meaning |
| --- | --- | --- | --- |
| `cbz Wt\|Xt, label` | `reg == 0` | $\pm 1\text{ MiB}$ (19-bit signed word offset) | C/C++ null-pointer check (`if (!ptr)`), zero integer check (`if (n == 0)`), NUL byte terminator check (`if (*p == '\0')`), C `bool` false check |
| `cbnz Wt\|Xt, label` | `reg != 0` | $\pm 1\text{ MiB}$ (19-bit signed word offset) | Non-null pointer check (`if (ptr)`), C `strlen`-style loop continuation (`while (*p != '\0')`), C `bool` true check |
| `tbz Wt\|Xt, #b, label` | `(reg >> b) & 1 == 0` | $\pm 32\text{ KiB}$ (14-bit signed word offset) | Bitflag clear check (`!(flags & (1 << b))`), sign-bit check (`b = 31` or `63`, i.e. `reg >= 0`), Dart Smi tag test (`b = 0`), Dart boolean test (`b = 4`) |
| `tbnz Wt\|Xt, #b, label` | `(reg >> b) & 1 == 1` | $\pm 32\text{ KiB}$ (14-bit signed word offset) | Bitflag set check (`flags & (1 << b)`), negative sign-bit check (`b = 31` or `63`, i.e. `reg < 0`), Dart heap-pointer tag test (`b = 0`) |

For `tbz`/`tbnz`, `#bit_num` ranges from `0` to `31` when the operand is printed as `Wt`, and from `32` to `63` when printed as `Xt` (the underlying 6-bit field `b5:b40` uses its top bit `b5` to select 64-bit vs. 32-bit view). Because six bits of the 32-bit instruction word are spent encoding `#bit_num`, `tbz`/`tbnz` has a shorter branch reach ($\pm 32\text{ KiB}$) than `cbz`/`cbnz` ($\pm 1\text{ MiB}$).

## Example

```asm
; 1. C null check and NUL-terminated string loop (NDK C/C++, from Walking-An-Unknown-Function-Cold):
    cbz    x1, .Lret                  ; if (src == NULL) return;  -- 64-bit pointer null check
.Lloop:
    ldrb   w9, [x1], #1               ; w9 = *src++
    cbnz   w9, .Lloop                 ; keep looping while byte != '\0'

; 2. Signed < 0 / >= 0 check compiled as a sign-bit test instead of cmp + b.lt / b.ge:
    tbnz   w0, #31, .Lis_negative     ; bit 31 is the 32-bit sign bit: branches if (int32_t)w0 < 0
    tbz    x0, #63, .Lis_non_negative ; bit 63 is the 64-bit sign bit: branches if (int64_t)x0 >= 0

; 3. Dart AOT Smi tag check (bit 0 == 0 means Smi, bit 0 == 1 means heap object pointer):
    tbz    w0, #0, #0xe3d02c          ; branchIfSmi: skip write barrier or class-id load if w0 is a Smi

; 4. Dart AOT boolean singleton check (true = NULL + 0x20, false = NULL + 0x30 -> differ in bit 4):
    tbnz   w0, #4, .Lwas_false        ; bit 4 is 0 for `true` (+0x20) and 1 for `false` (+0x30)
```

## Notes

- **Why they do NOT touch `NZCV` flags (and why that matters when reading disassembly)**: Neither `cbz`/`cbnz` nor `tbz`/`tbnz` reads or alters `PSTATE.NZCV`. This has two practical consequences for static analysis:
  1. You will see a conditional branch happen **with no preceding `cmp` or `tst` instruction** — the instruction itself is both the comparison and the branch.
  2. A compiler can set `NZCV` with an earlier `cmp` or `subs`, execute a `cbz`/`tbz` along one path, and then still consume those *earlier* `NZCV` flags in a subsequent `b.<cond>` or `csel` without re-comparing. When tracing what flags a `b.eq` or `csel` reads, look past any intervening `cbz`/`cbnz`/`tbz`/`tbnz` back to the last flag-setting instruction (`cmp`, `cmn`, `tst`, `adds`, `subs`, `ands`).
- **Recognizing `tbz`/`tbnz` on bit 31 or 63 as a `< 0` or `>= 0` comparison**: Compilers (both Clang/LLVM in the Android NDK and the Dart AOT backend) routinely optimize `if (x < 0)` into `tbnz w0, #31, label` (or `tbnz x0, #63, label`) and `if (x >= 0)` into `tbz w0, #31, label`, saving a `cmp w0, #0` instruction. Whenever you see `#31` (`#0x1f`) on a `w` register or `#63` (`#0x3f`) on an `x` register, translate it mentally as a signed zero comparison rather than bitwise manipulation.
- **Dart AOT's two ubiquitous `tbz`/`tbnz` idioms**:
  - **`tbz wN, #0, label` (`branchIfSmi`)**: Because Dart tags small integers with bit 0 = `0` and heap pointers with bit 0 = `1`, `tbz` on bit 0 appears before every polymorphic type check (in case the receiver is a `Smi`, which has no heap object header at `[xN, #-1]`) and at the start of every generational GC write barrier (storing a `Smi` into an object or array can never create an old-to-new heap pointer, so `tbz w0, #0, <skip>` bypasses the barrier immediately — see [[Object-Field-Store-With-Write-Barrier]]).
  - **`tbnz`/`tbz wN, #4, label` (Dart `bool` check)**: Unlike C/C++ (where `false` is `0` and tested with `cbz`/`cbnz`), Dart's `true` and `false` are heap singletons located at fixed offsets from the `NULL` register (`NULL + 0x20` for `true`, `NULL + 0x30` for `false`). Because `0x20` (`0b010_0000`) and `0x30` (`0b011_0000`) differ in bit 4 (`0x10`), Dart AOT code tests a boolean return value with `tbnz w0, #4, <if_false>` or `tbz w0, #4, <if_true>` instead of loading the `true` singleton and running `cmp` (see [[Reading-Raw-Disassembly#Worked example 2 (medium): a conditional with a virtual call|Worked example 2 in Reading-Raw-Disassembly]]).
  - Conversely, **Dart null checks do not use `cbz`**, because Dart's `null` is a canonical heap object stored in the reserved `NULL` register (`x22`), not numeric `0` — so a Dart null check is `cmp wN, NULL` + `b.eq`, whereas `cbz` is the hallmark of a native C/C++/JNI null check.

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Instructions]]
- [[Control-Flow-Patterns]]
- [[Memory-And-Data-Structures]]
- [[If-Else-As-Branches]]
- [[String-Length-And-Pointer]]
- [[Object-Field-Store-With-Write-Barrier]]
- [[MethodChannel-Invoke-And-Await]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
