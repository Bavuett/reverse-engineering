---
tags: [example]
level: 1
aliases: ["xzr wzr", "ARM64 special registers"]
created: 2026-11-12
---

# Example: Zero-Register-And-Special-Registers

> [!info] Level 1 — basics
> One idea: register number 31 is either the zero register or the stack pointer, and several "missing" instructions (`neg`, `cmp`, `mvn`, `tst`) are really ordinary instructions that write to or read from the zero register.

## Goal

Learn to read `xzr`/`wzr` and the registers with fixed roles on Android (`sp`, `x29`, `x30`, `x16`/`x17`, `x18`, `x8`) so they're never mistaken for program variables. Belongs to [[Registers-And-Data]].

## Source

```c
struct pair { long a; long b; };

void reset(struct pair *p) { p->a = 0; p->b = 0; }

long negate(long x)        { return -x; }

int is_zero(long x)        { return x == 0; }

unsigned flip(unsigned x)  { return ~x; }
```

## Compiled (clang -O2, AArch64)

```asm
reset:
    stp     xzr, xzr, [x0]        ; p->a = 0; p->b = 0
    ret

negate:
    neg     x0, x0                ; alias of: sub x0, xzr, x0
    ret

is_zero:
    cmp     x0, #0                ; alias of: subs xzr, x0, #0
    cset    w0, eq                ; w0 = (Z flag set) ? 1 : 0
    ret

flip:
    mvn     w0, w0                ; alias of: orn w0, wzr, w0
    ret
```

## Step by step

1. **`xzr`/`wzr` read as 0 and discard writes.** Storing zero never needs a constant load: `stp xzr, xzr, [x0]` writes two zero doublewords in one instruction. `mov x0, xzr` is "return 0" (or "pass `NULL`").
2. **Aliases hide the zero register.** Disassemblers print `neg`, `cmp`, `mvn`, `tst`, `mov` as if they were separate instructions; underneath, `cmp a, b` is `subs xzr, a, b` (subtract, keep only the flags), `tst a, b` is `ands xzr, a, b`, `neg` is `sub` from zero. When a tool shows the raw form, translate it back.
3. **Register 31 is context-dependent.** In arithmetic like `add`, register 31 means `sp`; in most others it means `xzr`. That's why `mov x29, sp` (really `add x29, sp, #0`) is legal while `mov x0, xzr` is `orr x0, xzr, xzr`. You don't need the encoding rules — just know `sp` and `xzr` never mean "a variable".
4. **Fixed-role registers on Android:**

   | register | role | how you'll see it |
   | --- | --- | --- |
   | `x0`–`x7` | arguments and return values | the function's inputs/outputs |
   | `x8` | indirect result (large struct return); also a scratch | `ldr x8, [x0]` then `blr x8` |
   | `x16`, `x17` | intra-procedure-call scratch (`IP0`/`IP1`) | inside PLT stubs and veneers |
   | `x18` | platform register — reserved on Android (shadow call stack) | never used as a temporary |
   | `x19`–`x28` | callee-saved | values that must survive calls |
   | `x29` | frame pointer | `mov x29, sp` in prologues |
   | `x30` | link register (return address) | saved with `stp x29, x30, …` |
   | `sp` | stack pointer, 16-byte aligned | prologue/epilogue arithmetic |

5. **`cset`** turns a condition flag into `0`/`1` — the compiled form of returning a comparison result as a boolean.

## Compared with real code

- [[Mmap-Call-Arguments-In-Datastore]] — `mov x0, xzr` and `mov x5, xzr` passing `NULL` and offset `0` to a real `mmap` call.
- [[Return-Value-Widening-In-Datastore-JNI]] — `mov x0, xzr` as a real JNI function's success return, next to `mov x0, #-1` for failure.
- [[PLT-Stub-And-Indirect-Call]] — `x16`/`x17` doing their one job.

## See also

- [[Registers-And-Data]]
- [[Basic-Arithmetic-And-Moves]]
- [[Compare-And-Conditional-Select]]
- [[AAPCS64-Quick-Reference]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
