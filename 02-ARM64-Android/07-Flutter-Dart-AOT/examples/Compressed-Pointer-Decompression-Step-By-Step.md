---
tags: [example]
level: 2
aliases: ["Dart DecompressPointer", "HEAP lsl 32"]
created: 2026-11-12
---

# Example: Compressed-Pointer-Decompression-Step-By-Step

> [!info] Level 2 — intermediate
> A two-hop field access (`order.customer.name`) with a null check in between: what each `ldur w` / `add …, HEAP, lsl #32` pair does to the bits, why the null check compares against the `NULL` register, and how to do the same arithmetic by hand in a debugger or Frida.

## Goal

Make pointer decompression concrete with actual numbers, and learn to follow a chain of field loads through a Dart AOT function. Belongs to [[Flutter-Dart-AOT]].

## Dart source

```dart
class Customer { final String name; Customer(this.name); }
class Order    { final int id; final Customer? customer; Order(this.id, this.customer); }

String customerName(Order o) => o.customer?.name ?? '-';
```

## Compiled (Blutter-style annotation, simplified)

```
customerName(Order) {
    // ldr   x1, [fp, #0x10]               ; x1 = o (tagged, decompressed 64-bit pointer)
    // LoadField: r1 = r1->field_f
    //     ldur  w1, [x1, #0xf]            ; o.customer, compressed (32 bits)
    // DecompressPointer r1
    //     add   x1, x1, HEAP, lsl #32
    // cmp   x1, NULL                      ; customer == null ?
    // b.eq  use_default
    // LoadField: r0 = r1->field_7
    //     ldur  w0, [x1, #7]              ; customer.name, compressed
    // DecompressPointer r0
    //     add   x0, x0, HEAP, lsl #32
    // ... return x0
  use_default:
    // r0 = "-"                            ; from the object pool (PP)
}
```

(Here `id` is assumed stored as a compressed Smi/boxed reference, so `customer` is field 2 → `#0xf`; an unboxed `int` would shift it — see [[Dart-Object-Header-And-Field-Offsets]].)

## Step by step

1. **The heap is a 4 GiB cage.** All Dart objects of an isolate group live inside one 4 GiB-aligned region, so every heap pointer shares the same upper 32 bits. The reserved `HEAP` register (`x28`, "heap bits") keeps those upper bits in its **low** half (its high half holds the write-barrier mask used elsewhere).
2. **Compressing** keeps only the low 32 bits of a pointer. **Decompressing** puts the upper half back: `add x1, x1, HEAP, lsl #32` — shifting `HEAP` left by 32 discards the barrier mask and moves the cage's upper bits into place. Worked numbers:

   ```
   HEAP               = 0x0000_0060_0000_0072     (high: barrier mask, low: cage base >> 32)
   HEAP, lsl #32      = 0x0000_0072_0000_0000     (cage base)
   ldur w1, [x1, #0xf] -> x1 = 0x0000_0000_0012_3451   (compressed, tagged: low bit 1)
   add  x1, x1, HEAP, lsl #32
                       -> x1 = 0x0000_0072_0012_3451   (full tagged pointer)
   ```

   (Illustrative values; read the real `HEAP` from a register dump at any hook site.)
3. **Writing a `w` register zero-extends**, so after `ldur w1` the upper 32 bits of `x1` are already zero before the `add` — the add can't carry garbage in ([[Register-Width-And-Sign-Extension]]).
4. **Null is a real object.** Dart's `null` is a heap singleton, pointed to by the reserved `NULL` register, so `o.customer == null` is a pointer comparison `cmp x1, NULL` *after* decompression. There's no comparison against `0` anywhere in Dart AOT reference code; seeing `cbz` on a decompressed pointer would be unusual.
5. **One `ldur w` + one `add HEAP` per hop.** Count the pairs to count the dereferences: two pairs here, `o → customer → name`. The `field_X` offsets name the fields at each hop.
6. **By hand in Frida.** Reading `this.context` or a field from a hook means doing step 2 yourself: read 32 bits with `ptr.add(0xf).readU32()`, then add the cage base (taken from the `HEAP` register in `this.context` at the hook site, or computed from any known object's address). [[Attaching-At-A-Dart-AOT-Entry-Offset]] does exactly this on real code.

## Compared with real code

- [[Reading-A-Dart-AOT-Getter-Cold]] — a real one-hop getter (`MasterGrade.subjectId`): one `ldur w` + one `add HEAP`, nothing else.
- [[Object-Field-Store-With-Write-Barrier]] — the reverse operation: storing a compressed pointer into an object, plus the write barrier that must follow.

## See also

- [[Flutter-Dart-AOT]]
- [[Dart-Object-Header-And-Field-Offsets]]
- [[Linked-List-Traversal]] — pointer chasing in uncompressed C code
- [[Memory-And-Data-Structures]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
