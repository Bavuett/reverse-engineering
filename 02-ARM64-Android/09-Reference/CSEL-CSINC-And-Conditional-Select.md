---
tags: [reference, reference-entry]
category: "instruction"
created: 2026-11-11
---

# CSEL-CSINC-And-Conditional-Select

## Signature / syntax

```asm
; Core conditional-select instructions (read NZCV flags, never modify them):
csel    Wd|Xd, Wn|Xn, Wm|Xm, cond   ; Rd = cond ? Rn : Rm
csinc   Wd|Xd, Wn|Xn, Wm|Xm, cond   ; Rd = cond ? Rn : (Rm + 1)
csinv   Wd|Xd, Wn|Xn, Wm|Xm, cond   ; Rd = cond ? Rn : ~Rm
csneg   Wd|Xd, Wn|Xn, Wm|Xm, cond   ; Rd = cond ? Rn : -Rm

; Preferred disassembler aliases (when Rn and/or Rm are the same register or XZR/WZR):
cset    Wd|Xd, cond                 ; Rd = cond ? 1 : 0        (alias of csinc Rd, RZR, RZR, invert(cond))
csetm   Wd|Xd, cond                 ; Rd = cond ? -1 : 0       (alias of csinv Rd, RZR, RZR, invert(cond))
cinc    Wd|Xd, Wn|Xn, cond          ; Rd = cond ? (Rn + 1) : Rn (alias of csinc Rd, Rn, Rn, invert(cond))
cinv    Wd|Xd, Wn|Xn, cond          ; Rd = cond ? ~Rn : Rn      (alias of csinv Rd, Rn, Rn, invert(cond))
cneg    Wd|Xd, Wn|Xn, cond          ; Rd = cond ? -Rn : Rn      (alias of csneg Rd, Rn, Rn, invert(cond))
```

## Description

The **Conditional Select** family (`csel`, `csinc`, `csinv`, `csneg`) and its disassembler aliases (`cset`, `csetm`, `cinc`, `cinv`, `cneg`) evaluate a condition code `cond` against the current `PSTATE.NZCV` flags (set by an earlier `cmp`, `cmn`, `tst`, `adds`, `subs`, or `ands`) and write one of two values into the destination register **without branching**.

When the two arms of a source-level `if`/`else` or ternary `cond ? a : b` are short, side-effect-free expressions, compilers strongly prefer emitting a conditional select over a `b.<cond>` forward branch because it keeps execution straight-line and avoids CPU branch-predictor misprediction penalties.

| Instruction / Alias | Operation when `cond` is **TRUE** | Operation when `cond` is **FALSE** | Typical source-level C/Kotlin/Dart construct |
| --- | --- | --- | --- |
| `csel Rd, Rn, Rm, cond` | `Rd = Rn` | `Rd = Rm` | Ternary operator `cond ? a : b`, `min(a, b)`, `max(a, b)`, or picking between Dart's `true`/`false` singletons |
| `csinc Rd, Rn, Rm, cond` | `Rd = Rn` | `Rd = Rm + 1` | Branchless `cond ? a : b + 1` (and the underlying encoding for `cset` and `cinc`) |
| `csinv Rd, Rn, Rm, cond` | `Rd = Rn` | `Rd = ~Rm` | Branchless `cond ? a : ~b` (and the underlying encoding for `csetm` and `cinv`) |
| `csneg Rd, Rn, Rm, cond` | `Rd = Rn` | `Rd = -Rm` | Branchless `cond ? a : -b` (and the underlying encoding for `cneg`) |
| `cset Rd, cond` | `Rd = 1` | `Rd = 0` | Materializing a C/JNI boolean (`bool ok = (a == b);`, `return x > 5;`) into `0` or `1` |
| `csetm Rd, cond` | `Rd = -1` (`0xff..ff`) | `Rd = 0` | Creating an all-ones bitmask when `cond` holds, or returning `-1` vs `0` |
| `cinc Rd, Rn, cond` | `Rd = Rn + 1` | `Rd = Rn` | Conditional increment (`if (cond) count++;`) without a branch |
| `cneg Rd, Rn, cond` | `Rd = -Rn` | `Rd = Rn` | Branchless `abs(x)` (`cmp w0, #0` + `cneg w0, w0, lt`) or sign-flipping |

## Example

```asm
; 1. Materializing a boolean (return a == b) and branchless max(a, b) (from Compare-And-Conditional-Select):
is_equal:
    cmp     w0, w1
    cset    w0, eq                  ; w0 = (w0 == w1) ? 1 : 0  (encoded as: csinc w0, wzr, wzr, ne)
    ret

max2:
    cmp     w0, w1
    csel    w0, w0, w1, gt          ; w0 = (w0 > w1) ? w0 : w1
    ret

; 2. Branchless absolute value (return x < 0 ? -x : x):
abs_i32:
    cmp     w0, #0
    cneg    w0, w0, lt              ; if w0 < 0, w0 = -w0; else w0 = w0 (encoded as: csneg w0, w0, w0, ge)
    ret

; 3. Clamping a negative integer to zero (return x < 0 ? 0 : x * 2, from Instructions):
clamp_or_double:
    lsl     w1, w0, #1              ; w1 = x * 2 (computed unconditionally before the select)
    cmp     w0, #0
    csel    w0, wzr, w1, lt         ; w0 = (x < 0) ? 0 (wzr) : w1
    ret

; 4. Dart AOT boolean singleton selection (selecting `true` vs `false` heap objects without branching):
    add     x1, NULL, #0x20         ; x1 = canonical `true` singleton  (NULL + 0x20)
    add     x2, NULL, #0x30         ; x2 = canonical `false` singleton (NULL + 0x30)
    cmp     w0, w3
    csel    x0, x1, x2, eq          ; x0 = (w0 == w3) ? true_obj : false_obj
```

## Notes

- **Why the underlying `csinc`/`csinv`/`csneg` encoding inverts the condition code for `cset`, `cinc`, and `cneg`**: In the raw `csinc Rd, Rn, Rm, cond` instruction, the `+ 1` happens when `cond` is **false** (`Rd = cond ? Rn : Rm + 1`). Therefore, to make `cset Wd, eq` evaluate to `1` when `eq` is **true**, the assembler actually encodes `csinc Wd, WZR, WZR, ne` ("if `ne`, pick `0`; else pick `0 + 1`"). Modern disassemblers (`objdump`, Ghidra, IDA, blutter) automatically invert the condition back and display the readable alias `cset w0, eq` or `cinc w0, w0, eq`, but if you ever inspect raw instruction fields or a bare-bones disassembler that prints raw `csinc w0, wzr, wzr, ne`, remember to invert the printed condition when translating to `cset`/`cinc`/`cinv`/`cneg`.
- **Both operands are evaluated unconditionally**: Unlike a branched `if`/`else` (or short-circuit `&&`/`||`), a `csel` sequence computes **both** candidate values into registers first and then picks one. When reading disassembly, don't be confused if you see the compiler compute a value (`lsl w1, w0, #1` in `clamp_or_double` above) that appears "wasted" when `x < 0` — Speculating cheap arithmetic in registers so `csel` can select the winner is standard compiler output.
- **No control-flow graph split in Ghidra/IDA**: Because `csel` does not branch, a function that uses several `cmp` + `csel` pairs will appear in a disassembler's graph view as a single tall basic block with zero outgoing branch arrows, even though the original source code contained multiple `if`/`else` statements or `?:` expressions. Always scan long straight-line basic blocks for `cmp`/`tst` + `csel`/`cset` pairs when reconstructing control flow (see [[Control-Flow-Patterns]]).

## See also

- [[ARM64-Android-Reference|Reference]]
- [[Instructions]]
- [[Control-Flow-Patterns]]
- [[Compare-And-Conditional-Select]]
- [[If-Else-As-Branches]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
