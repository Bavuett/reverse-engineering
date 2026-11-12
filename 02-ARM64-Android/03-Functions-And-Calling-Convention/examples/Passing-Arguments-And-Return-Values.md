---
tags: [example]
level: 1
aliases: ["AAPCS64 argument registers", "ARM64 tail call"]
created: 2026-11-12
---

# Example: Passing-Arguments-And-Return-Values

> [!info] Level 1 — basics
> One idea: integer/pointer arguments go in `x0`–`x7`, floating-point arguments in `d0`–`d7` (counted separately), the result comes back in `x0` or `d0` — and narrow arguments are widened by the *callee* with `sxtw`/`sxth`/`uxtb`.

## Goal

Read a function's parameters and return value straight from register usage, including mixed integer widths and doubles, and recognize a tail call. Belongs to [[Functions-And-Calling-Convention]].

## Source

```c
__attribute__((noinline))
long add5(long a, int b, short c, char d, long e) { return a + b + c + d + e; }

long caller(void) { return add5(1, 2, 3, 4, 5); }

double avg(double x, double y) { return (x + y) / 2; }

double mix(int n, double scale, long base) { return base + n * scale; }
```

## Compiled (clang -O2, AArch64 Android)

```asm
add5:
    add     x8, x0, w1, sxtw        ; a + (long)b       (int  -> sign-extend word)
    add     x8, x8, w2, sxth        ;   + (long)c       (short -> sign-extend half)
    add     x8, x8, w3, uxtb        ;   + (long)d       (char  -> zero-extend byte)
    add     x0, x8, x4              ;   + e
    ret

caller:
    mov     w0, #1
    mov     w1, #2
    mov     w2, #3
    mov     w3, #4
    mov     w4, #5
    b       add5                    ; tail call: no bl, no frame

avg:
    fadd    d0, d0, d1
    fmov    d1, #0.5
    fmul    d0, d0, d1              ; /2 rewritten as *0.5
    ret

mix:
    scvtf   d1, w0                  ; (double) n
    scvtf   d2, x1                  ; (double) base
    fmadd   d0, d1, d0, d2          ; n*scale + base
    ret
```

## Step by step

1. **Position = register number.** The 1st–5th integer arguments of `add5` are `x0`–`x4`. Up to eight go in registers; the 9th and later go on the stack, at `[sp]`, `[sp, #8]`, … as seen by the callee on entry (see [[Functions-And-Calling-Convention]]).
2. **Two independent counters.** In `mix(int n, double scale, long base)`, `n` is the first *integer* argument (`w0`), `scale` the first *FP* argument (`d0`), and `base` the second integer argument (`x1`) — not `x2`. Count integer and FP parameters separately.
3. **The callee widens narrow arguments.** `add5` extends `b`, `c`, `d` itself with the extended-register forms `sxtw`, `sxth`, `uxtb`. The extension kind reveals the C type: `sxtw` = `int`, `sxth` = `short`, `uxtb` = `unsigned char` — and plain `char` is **unsigned** on ARM64 Android, hence `uxtb`.
4. **Return value.** Integer/pointer results go in `x0` (`w0` for 32-bit), FP results in `d0` (`s0` for `float`). A function that ends without writing either returns `void`, or returns whatever its last call returned.
5. **Tail call.** `caller` sets up the arguments and *branches* (`b`) to `add5` instead of calling it: `add5`'s `ret` returns directly to `caller`'s caller. No `bl`, no saved `x30`, no frame — a `b` to another function's entry at the very end of a function is a call, not a jump within the function.
6. **FP conversions** use `scvtf` (signed int → FP), `ucvtf` (unsigned), and `fcvtzs`/`fcvtzu` (FP → int, truncating). `fmadd` fuses multiply and add like integer `madd` ([[Multiply-Divide-And-Modulo]]).

## Compared with real code

- [[Mmap-Call-Arguments-In-Datastore]] — six real arguments to `mmap` set up in `x0`–`x5`, out of order.
- [[Stack-Protector-And-Tail-Call-In-Datastore-JNI]] — a real tail call (`br x3`) into a JNI function pointer.

## See also

- [[Functions-And-Calling-Convention]]
- [[Leaf-Function-Prologue-Epilogue]]
- [[AAPCS64-Quick-Reference]]
- [[B-BL-BLR-And-RET]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
