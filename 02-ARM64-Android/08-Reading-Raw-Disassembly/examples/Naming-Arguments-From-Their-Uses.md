---
tags: [example]
level: 1
aliases: ["recovering parameter types ARM64"]
created: 2026-11-12
---

# Example: Naming-Arguments-From-Their-Uses

> [!info] Level 1 — basics
> One idea: an argument register's *first uses* reveal its type — dereferenced means pointer, compared against a counter means length, written through means output parameter, width means size.

## Goal

Recover a function's prototype — count, types, and roles of its parameters, plus its return type — from nothing but how `x0`–`x7` are used. Belongs to [[Reading-Raw-Disassembly]].

## The function (no symbols)

```asm
sub_2000:
2000:  cmp     w1, #1
2004:  b.lt    0x2034
2008:  mov     w8, w1
200c:  mov     w9, wzr                ; count = 0
2010:  ldrb    w10, [x0], #1          ; c = *p++
2014:  sub     w10, w10, #0x30        ; c - '0'
2018:  cmp     w10, #9
201c:  cinc    w9, w9, ls             ; if (unsigned)(c-'0') <= 9: count++
2020:  subs    w8, w8, #1
2024:  b.ne    0x2010
2028:  str     w9, [x2]               ; *out = count
202c:  mov     w0, #1
2030:  ret
2034:  str     wzr, [x2]              ; *out = 0
2038:  mov     w0, wzr
203c:  ret
```

## Step by step

1. **Which argument registers are read before being written?** `x0`, `w1`, `x2`. `x3`–`x7` are never touched → **three parameters**.
2. **`x0`**: dereferenced with `ldrb … [x0], #1` (load a byte, post-increment) → a pointer to bytes, walked forward: `const char *` or `const uint8_t *`.
3. **`w1`**: compared with `#1` and used as a down-counter → a 32-bit signed length (`b.lt` is a *signed* comparison, so `int`, not `unsigned`). Paired with a byte pointer, it's the buffer length.
4. **`x2`**: only ever written *through* (`str w9, [x2]`, `str wzr, [x2]`) → an output parameter, `int *`, written on every path.
5. **Return value**: `w0` set to `1` or `0` on the two paths → `int`/`bool` success flag. `0` when `len < 1`.
6. **The idiom in the middle.** `sub #0x30` + `cmp #9` + `ls` (unsigned ≤) is the classic `'0' <= c && c <= '9'` folded into one unsigned comparison. `cinc` counts it without a branch.
7. **Prototype and body:**

   ```c
   int count_digits(const char *p, int len, int *out) {
       if (len < 1) { *out = 0; return 0; }
       int count = 0;
       for (int i = 0; i < len; i++)
           if ((unsigned)(p[i] - '0') <= 9) count++;
       *out = count;
       return 1;
   }
   ```

8. **Callee-saved registers say "used after a call"**, argument registers moved into `x19`+ in a prologue are parameters needed later — not relevant here (it's a leaf), but the most common source of evidence in bigger functions.

## Compared with real code

- [[Encryption-Decrypt-JNI-Entry-In-Libencrypt]] — a real prologue where six argument registers are named this way, including a nullable one revealed by a `cbz` before its first use.
- [[Mmap-Call-Arguments-In-Datastore]] — the caller side: reading which values go *into* `x0`–`x5` for a known prototype.

## See also

- [[Reading-Raw-Disassembly]]
- [[Finding-Function-Boundaries-And-Calls]]
- [[Array-Indexing-With-Scaled-Registers]] — load mnemonics and element types
- [[Load-Store-Addressing-Modes]] — post-index `[x0], #1`

## References

- [[ARM64-Android-Bibliography|Bibliography]]
