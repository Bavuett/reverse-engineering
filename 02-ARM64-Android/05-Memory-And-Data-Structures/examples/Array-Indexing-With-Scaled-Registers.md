---
tags: [example]
level: 1
aliases: ["ARM64 register offset addressing", "array access ARM64"]
created: 2026-11-12
---

# Example: Array-Indexing-With-Scaled-Registers

> [!info] Level 1 — basics
> One idea: `a[i]` is usually a single load whose addressing mode carries the index register, its extension, and a shift equal to log₂(element size).

## Goal

Read the element size, the index's C type, and the signedness of the element straight off array loads and stores. Belongs to [[Memory-And-Data-Structures]].

## Source

```c
int   get_i(int *a, long i)              { return a[i]; }
long  get_l(long *a, int i)              { return a[i]; }
int   get_s(short *a, unsigned i)        { return a[i]; }
void  put_c(char *a, long i, char v)     { a[i] = v; }

struct P { int x, y; };
int   get_y(struct P *p, long i)         { return p[i].y; }
```

## Compiled (clang -O2, AArch64)

```asm
get_i:
    ldr     w0, [x0, x1, lsl #2]      ; *(int*)(a + i*4)
    ret

get_l:
    ldr     x0, [x0, w1, sxtw #3]     ; index is a signed 32-bit int -> sxtw, element 8 bytes
    ret

get_s:
    ldrsh   w0, [x0, w1, uxtw #1]     ; unsigned 32-bit index -> uxtw, signed 16-bit element -> ldrsh
    ret

put_c:
    strb    w2, [x0, x1]              ; 1-byte element: no shift
    ret

get_y:
    add     x8, x0, x1, lsl #3        ; &p[i]   (sizeof(struct P) = 8)
    ldr     w0, [x8, #4]              ; .y at offset 4
    ret
```

## Step by step

1. **`[base, index, lsl #n]`** = `base + index × 2ⁿ`. The shift is the element size: `#1` → 2 bytes, `#2` → 4, `#3` → 8, none → 1.
2. **The index extension gives the index type.** `x1, lsl` = 64-bit index (`long`, `size_t`); `w1, sxtw` = signed 32-bit (`int`); `w1, uxtw` = unsigned 32-bit (`unsigned`).
3. **The load mnemonic gives the element type.** `ldrb`/`ldrh` zero-extend (unsigned `char`/`short`), `ldrsb`/`ldrsh`/`ldrsw` sign-extend (signed types), `ldr w` = 32-bit, `ldr x` = 64-bit or pointer. `get_s` uses `ldrsh` because `short` is signed.
4. **Stores don't extend.** `strb`/`strh` write the low bits, so a store alone doesn't tell you signedness — look for where the value was loaded or computed.
5. **Arrays of structs** can't use the scaled mode when the struct isn't 1/2/4/8 bytes, or when a field offset must be added, so the compiler computes `&p[i]` with `add … lsl` and then loads at the field offset. `add x8, x0, x1, lsl #3` + `ldr w0, [x8, #4]` reads as "array of 8-byte structs, 4-byte field at +4" — exactly the information needed to start a struct definition ([[Struct-Field-Access]]).

## Compared with real code

- [[Smi-Boxing-And-Unboxing]] — real Dart AOT code where an index-like value is tagged with a shift before use.
- [[Object-Field-Store-With-Write-Barrier]] — real field stores at constant offsets, with compressed 4-byte pointers instead of 8-byte ones.

## See also

- [[Memory-And-Data-Structures]]
- [[Struct-Field-Access]]
- [[Load-Store-Addressing-Modes]]
- [[LDR-And-STR]]
- [[Linked-List-Traversal]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
