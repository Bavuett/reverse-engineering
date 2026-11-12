---
tags: [example]
level: 2
aliases: ["djb2 in ARM64", "identifying algorithms by constants"]
created: 2026-11-12
---

# Example: Recognizing-A-Hash-Loop-By-Its-Constants

> [!info] Level 2 — intermediate
> Combines loop recovery, shifted-operand arithmetic, and the single most productive shortcut in reversing: a known algorithm identified by its magic constant and update shape, without understanding it from first principles.

## Goal

Read an unknown string-processing loop, reduce its update step to a formula, and match the formula plus its initial constant against well-known algorithms. Belongs to [[Reading-Raw-Disassembly]].

## The function (no symbols)

```asm
sub_3100:
3100:  ldrb    w9, [x0]
3104:  mov     w8, #0x1505
3108:  cbz     w9, 0x3120
310c:  add     x10, x0, #1
3110:  add     w8, w8, w8, lsl #5
3114:  add     w8, w8, w9
3118:  ldrb    w9, [x10], #1
311c:  cbnz    w9, 0x3110
3120:  mov     w0, w8
3124:  ret
```

## Step by step

1. **Shape first.** One pointer argument (`x0`) read byte by byte until a zero byte (`cbz`/`cbnz w9`) → walks a NUL-terminated C string. One 32-bit accumulator (`w8`) returned at the end. So: `unsigned f(const char *s)` reducing a string to a number — a hash or checksum.
2. **Initial value.** `w8 = 0x1505` = **5381**.
3. **Update step.** `add w8, w8, w8, lsl #5` = `h + (h << 5)` = `h * 33`; then `+ c`. So `h = h * 33 + c` ([[Arithmetic-And-Logical-Instructions]]).
4. **Match.** Initial value 5381 + update `h * 33 + c` is **djb2**, Daniel Bernstein's string hash. Writing it out:

   ```c
   unsigned djb2(const char *s) {
       unsigned h = 5381;
       for (unsigned char c; (c = *s++); )
           h = h * 33 + c;
       return h;
   }
   ```

5. **Loop layout details.** The first byte is loaded *before* the loop (`ldrb w9, [x0]`) and the loop pointer starts at `s + 1`; the load at the bottom (`ldrb w9, [x10], #1`) fetches the next byte for the next iteration. That's a rotated loop with the first iteration's load hoisted ([[Loop-As-Backward-Branch]]).
6. **Constants that identify algorithms** (search them as decimal and hex; they survive any amount of renaming):

   | constant | algorithm |
   | --- | --- |
   | `5381` / `0x1505`, ×33 | djb2 |
   | `0x811c9dc5`, ×`0x01000193` | FNV-1/FNV-1a 32-bit |
   | `0xedb88320` | CRC-32 (reflected polynomial) |
   | `0x67452301`, `0xefcdab89`, `0x98badcfe`, `0x10325476` | MD5 / SHA-1 initial state |
   | `0x6a09e667`, `0xbb67ae85`, … | SHA-256 initial state |
   | `0x9e3779b9` | golden-ratio constant (TEA/XTEA, hash mixing) |
   | `0x63, 0x7c, 0x77, 0x7b …` table | AES S-box |
   | shifts `13, 17, 5` on one word | xorshift32 PRNG |

7. **Then verify.** A constant match is a hypothesis; confirm by running the candidate on a known input (e.g. call the function with Frida's `NativeFunction` and compare against your C version).

## Compared with real code

- [[Reading-Raw-Disassembly]] — its worked examples recognize real standard routines the same way.
- The same move in Dalvik: [[Reading-Raw-Dalvik]]'s worked example 8 identifies an xorshift step (13/17/5) inside real TUA smali.
- [[Outline-Atomics-LSE-Vs-LLSC-In-Datastore]] — a real stripped helper identified by shape and naming convention rather than by constants.

## See also

- [[Reading-Raw-Disassembly]]
- [[Walking-An-Unknown-Function-Cold]]
- [[Multiply-Divide-And-Modulo]] — magic constants for division, a different family
- [[NativeFunction-And-NativeCallback]] in [[Frida-Dynamic-Instrumentation]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
