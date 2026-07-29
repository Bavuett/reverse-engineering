---
tags: [fundamentals]
aliases: [Object Layout, Tagged Pointers]
created: 2026-07-28
---

# Memory-And-Data-Structures

## In short

Reading `ldur`/`stur` chains as "this is a struct field access" or "this is an array element" requires knowing the layout convention the compiler used — and Android reversing forces you to know **two** conventions: plain C/C++ structs (whatever layout the source's types imply, no metadata attached) and the Dart VM's tagged-object heap (every object carries a header, integers are sometimes not real pointers at all, and every pointer store into an old object may need a write barrier). This chapter covers both, with the Dart side weighted more heavily since it's the one with no equivalent in ordinary NDK reversing.

## Explanation

### Plain struct/array access (NDK C/C++)

A struct field is just "base pointer plus a fixed compile-time offset"; an array element is "base pointer plus `index * element_size`":

```c
struct Point { int32_t x; int32_t y; };
int32_t get_y(struct Point *p) { return p->y; }
int32_t get_at(int32_t *arr, int i) { return arr[i]; }
```

```asm
get_y:
    ldr     w0, [x0, #4]          ; y is the second int32_t field, offset 4
    ret

get_at:
    ldr     w0, [x0, w1, sxtw #2] ; arr + i*4, sign-extending i and scaling by element size
    ret
```

There's no header, no type tag, nothing to decompress — the offset _is_ the field, chosen by the struct's declared layout (subject to alignment padding you have to reconstruct from the offsets you see, if the source isn't available).

### Dart's tagged heap objects

Every Dart heap object starts with a **header word immediately before** the object's own tagged pointer (see [[Bitfield-Class-Id-Extraction]] for the exact extraction instructions):

```
[header word]  <- object_ptr - 1 (in words)   packs: class id, size, GC bits
[object_ptr] -> field 0
               field 1
               ...
```

Fields are accessed with `ldur`/`stur` at small, often odd-looking byte offsets (`+0x7`, `+0xf`, `+0x1b`, ...) — these are **not misaligned**, they're just offset from the _tagged_ pointer (whose low bit is set to mark "this is a heap pointer, not a Smi" — see below), so every real field offset is odd relative to the untagged object start.

### Compressed pointers and `DecompressPointer`

Modern Dart AOT uses **compressed pointers**: object fields store only the low 32 bits of a heap pointer, and every load of a pointer-typed field is immediately followed by a fixed idiom to recover the full 64-bit address:

```
// 0xd542d8: LoadField: r2 = r0->field_f
//     0xd542d8: ldur            w2, [x0, #0xf]     ; 32-bit load -- the compressed pointer
//     0xd542dc: DecompressPointer r2
//     0xd542dc: add             x2, x2, HEAP, lsl #32   ; OR in the heap base's high bits
```

Read `ldur wN, [..]` immediately followed by `add xN, xN, HEAP, lsl #32` as a single logical operation — "load pointer field" — not two independent steps. Non-pointer fields (raw integers, doubles) are loaded at their natural width with no such follow-up.

### Tagged integers: Smi vs. boxed (Mint/Double)

Small integers are **not** heap objects at all — they're **tagged in the pointer itself**: shifted left by one bit, with the low tag bit left at 0. A real pointer's low bit is instead 1. This means "is it a small int or a heap object" is a single bit test (`tbz`/`tbnz w0, #0, ...`), and doing arithmetic on two Smis directly manipulates the tagged representation:

```
// x2 = BoxInt64Instr(x2)  -- try to represent a 64-bit int as a tagged Smi
sbfiz  x0, x2, #1, #0x1f      ; x0 = x2 << 1 (tag), keeping 31 significant bits
cmp    x2, x0, asr #1          ; does shifting back down recover the original value?
b.eq   <done, x0 is a valid Smi>
bl     AllocateMintSharedWithoutFPURegsStub   ; too big for a Smi -> heap-allocate a boxed Mint instead
stur   x2, [x0, #7]                            ; store the real 64-bit value into the box
```

If the value fits, you get a cheap tagged Smi with **no heap allocation**; if it overflows the Smi range, the compiler falls back to allocating a boxed `Mint` (or, symmetrically, a boxed `Double` for floating-point — see `inline_Allocate_Double` in [[Object-Field-Store-With-Write-Barrier]]) on the heap and storing the real value inside it at a fixed field offset. The inverse operation, `LoadInt32Instr`/untagging, is exactly the `sbfx x, x, #1, #31`-style shift from [[Register-Width-And-Sign-Extension]].

### Bump allocation

New heap objects are usually allocated **inline** (not via a real call) for the fast path — a bump pointer held in the `Thread` structure:

```
ldp   x0, x1, [THR, #0x50]   ; THR::top, THR::end -- current allocation cursor and the space's limit
add   x0, x0, #0x10          ; x0 = candidate new object's end address
cmp   x1, x0
b.ls  <slow path: call the real allocation stub, e.g. AllocateDoubleStub>
str   x0, [THR, #0x50]       ; commit: THR::top = x0
sub   x0, x0, #0xf           ; x0 now points at the new object (tagged, one word back from its header)
; write the header word at [x0, #-1], then field values
```

This is the heap-allocation analog of [[Functions-And-Calling-Convention#Explanation|the
stack-overflow check]]: a cheap inline fast path guarded by a compare against a limit held in
`THR`, falling back to a proper runtime call only when the fast path can't be taken.

### Write barriers

The garbage collector relies on knowing, cheaply, which old-generation objects might point at new-generation ones (so it doesn't have to rescan the entire old generation every minor GC). Every store of a pointer into an already-allocated object is followed by a check, and — only if necessary — a call to record the fact:

```
str  w0, [x25]                 ; the actual field/array-slot store
tbz  w0, #0, <skip>            ; skip entirely if what we stored was a Smi (never needs a barrier)
ldurb w16, [x1, #-1]           ; the destination object's header byte
ldurb w17, [x0, #-1]           ; the stored VALUE's header byte
and  x16, x17, x16, lsr #2
tst  x16, HEAP, lsr #32
b.eq <skip>
bl   ArrayWriteBarrierStub     ; (or the plain StoreBufferStub for a single-field store)
```

Seeing this exact shape after a `str`/`stur` into a heap object is not a bug in the disassembly and not application logic worth puzzling over on a first pass — it's GC bookkeeping the compiler inserts automatically after essentially every pointer-into-heap-object store.

## Worked example

See [[Object-Field-Store-With-Write-Barrier]] for a full real excerpt (from `_Absence.toString`) combining a compressed-pointer array store with its trailing write-barrier check, and [[Smi-Boxing-And-Unboxing]] for the Smi/Mint boxing decision in the wild.

## More examples

- [[Struct-Field-Access]] — plain NDK struct/array offsets, no header, no tagging
- [[String-Length-And-Pointer]] — how a length-prefixed string differs from a NUL-terminated one at the instruction level

## See also

- [[Instructions]]
- [[Control-Flow-Patterns]]
- [[Flutter-Dart-AOT]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]

## Flashcards
#flashcards

Why are Dart object field offsets in disassembly often odd numbers like `0x7` or `0xf`?::Because they're measured from the *tagged* pointer (low bit set to mark "heap object"), not from the untagged object start — every real field offset ends up odd relative to that tagged base.
What does `ldur w2, [x0, #N]` immediately followed by `add x2, x2, HEAP, lsl #32` mean?::A compressed-pointer field load: the 32-bit compressed value is loaded, then OR'd with the heap base's high bits to recover the full 64-bit pointer.
Why does a Smi-vs-Mint boxing decision need a runtime check (`cmp x2, x0, asr #1`) instead of just always tagging?::Because a Smi only has ~31 significant bits of range (one bit spent on the tag) — the check verifies the value survived the shift-and-shift-back round trip; if not, the compiler falls back to heap-allocating a boxed Mint.
What is a write barrier protecting against?::Letting the garbage collector's generational assumption ("old objects don't point at new ones without being recorded") silently become false after a pointer store, which would let it collect a still-reachable new object.
