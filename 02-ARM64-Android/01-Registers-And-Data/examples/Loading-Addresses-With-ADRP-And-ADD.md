---
tags: [example]
level: 2
aliases: ["adrp add address materialization"]
created: 2026-11-12
---

# Example: Loading-Addresses-With-ADRP-And-ADD

> [!info] Level 2 — intermediate
> Combines PC-relative page arithmetic, the `:lo12:` offset folded into a load/store, and resolving the result to a real string or global by hand.

## Goal

Show how a register ends up holding the address of a string literal or a global variable, and how to compute that address yourself from `adrp` + `add`/`ldr` so you can find what it points to. Belongs to [[Registers-And-Data]].

## Source

```c
static const char kMsg[] = "java/io/IOException";
static int counter;

const char *message(void) { return kMsg; }

int bump(void) { return ++counter; }
```

## Compiled (clang -O2, AArch64, position-independent)

```asm
message:
    adrp    x0, kMsg              ; x0 = 4 KiB page containing kMsg
    add     x0, x0, :lo12:kMsg    ; + low 12 bits of kMsg's address
    ret

bump:
    adrp    x8, counter
    ldr     w9, [x8, :lo12:counter]   ; offset folded into the load
    add     w9, w9, #1
    str     w9, [x8, :lo12:counter]
    mov     w0, w9
    ret
```

## Step by step

1. **Why two instructions.** An instruction is 32 bits, so it can't carry a 64-bit address. `adrp` computes `(PC & ~0xFFF) + imm × 4096` — the start of a 4 KiB page within ±4 GiB of the code. The second instruction adds the low 12 bits.
2. **`add` for addresses, `ldr`/`str` for values.** When the code needs the *pointer* (passing a string to a function), the low bits go in an `add`. When it needs the *contents* of a global, the low bits are folded into the load's offset: `ldr w9, [x8, :lo12:counter]`. Same page arithmetic, different consumer.
3. **Resolving by hand.** Disassemblers print the `adrp` result as an absolute page (`adrp x1, #0x3a000`). Add the second instruction's immediate (`add x1, x1, #0xcf4`) and you get `0x3acf4`, an address you can look up in the section table (`objdump -h`, [[Objdump-And-Readelf]]): `.rodata` → probably a string, `.data`/`.bss` → a global variable, `.got` → a pointer to an imported symbol.
4. **Reuse of the page register.** `bump` keeps `x8` = page and uses it for both the load and the store. One `adrp` followed by several `[xN, #off]` accesses means several globals or fields of one global structure on the same page.
5. **`w` for the value, `x` for the address.** `counter` is an `int`, so it's loaded into `w9`; the address is 64-bit, so it lives in `x8`. The register width tells you the data size even with no symbols.

## Compared with real code

AndroidX DataStore's native library (shipped inside PressReader) does all three things from this example in its first 300 bytes of code:

```asm
; ThrowIoException: pass the class name "java/io/IOException" to env->FindClass
d94:  adrp    x1, #0                ; page 0x0000
d9c:  add     x1, x1, #0xa8b        ; 0x0a8b -> .rodata: "java/io/IOException"

; outline-atomics helper: read a global "CPU has LSE atomics" flag
ff4:  adrp    x16, #0x9000          ; page 0x9000
ff8:  ldrb    w16, [x16, #0x428]    ; byte at 0x9428 (.bss)

; PLT stub: load an imported function's address from the GOT
10e0: adrp    x16, #0x5000
10e4: ldr     x17, [x16, #0x3b8]    ; 0x53b8 -> GOT slot for __cxa_finalize
```

`objdump -s -j .rodata` on that library shows `java/io/IOException` starting at `0xa8b`, confirming step 3. The full functions are in [[Return-Value-Widening-In-Datastore-JNI]] and [[Outline-Atomics-LSE-Vs-LLSC-In-Datastore]].

## See also

- [[Registers-And-Data]]
- [[ADR-And-ADRP]] — encoding and range details
- [[Zero-Register-And-Special-Registers]]
- [[LDR-And-STR]]
- [[PLT-Stub-And-Indirect-Call]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
