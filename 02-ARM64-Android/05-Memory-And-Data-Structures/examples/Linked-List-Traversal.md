---
tags: [example]
level: 2
aliases: ["pointer chasing ARM64", "linked list ARM64"]
created: 2026-11-12
---

# Example: Linked-List-Traversal

> [!info] Level 2 — intermediate
> Combines a struct layout with padding, a loop, and the defining tell of a linked structure: a register loaded from memory at an offset of *itself*.

## Goal

Recognize pointer chasing (`ldr x0, [x0, #off]`) inside a loop, recover the node layout including padding, and tell a search loop from an accumulation loop. Belongs to [[Memory-And-Data-Structures]].

## Source

```c
struct node {
    int value;            // offset 0, 4 bytes
                          // 4 bytes padding
    struct node *next;    // offset 8
};

int sum(const struct node *n) {
    int s = 0;
    while (n) { s += n->value; n = n->next; }
    return s;
}

struct node *find(struct node *n, int key) {
    for (; n; n = n->next)
        if (n->value == key) return n;
    return 0;
}
```

## Compiled (clang -O2, AArch64)

```asm
sum:
    cbz     x0, .Lzero              ; empty list
    mov     w8, wzr                 ; s = 0
.Lloop:
    ldr     w9, [x0]                ; n->value          (offset 0, 32-bit)
    ldr     x0, [x0, #8]            ; n = n->next       (offset 8, 64-bit) <- pointer chase
    add     w8, w9, w8              ; s += value
    cbnz    x0, .Lloop              ; while (n)
    mov     w0, w8
    ret
.Lzero:
    mov     w0, wzr
    ret

find:
    cbz     x0, .Lret
.Lfloop:
    ldr     w8, [x0]                ; n->value
    cmp     w8, w1
    b.eq    .Lret                   ; found: return n (already in x0)
    ldr     x0, [x0, #8]            ; n = n->next
    cbnz    x0, .Lfloop
.Lret:
    ret                             ; returns n, or NULL when the loop ran off the end
```

## Step by step

1. **The tell.** `ldr x0, [x0, #8]` overwrites a pointer with a value loaded *through* it — "follow the link". Inside a loop that ends with `cbnz x0` (until NULL), that's a linked list; with a different stop condition it might be a tree descent or a parent chain.
2. **Layout from offsets and widths.** `value` is read as `w` at `+0` (4 bytes), `next` as `x` at `+8` (8 bytes, a pointer). The gap at `+4..+7` is alignment padding: an 8-byte pointer must sit at a multiple of 8. Offsets plus widths reconstruct the struct, padding included.
3. **Loop shape.** The test is rotated to the bottom with a guard on top (`cbz` before, `cbnz` at the end), the same shape as [[Loop-As-Backward-Branch]].
4. **Load scheduling.** In `sum`, the compiler loads `next` *before* adding `value` — it starts the slow pointer-chasing load as early as possible. Source order and instruction order differ; data dependencies don't.
5. **Search vs accumulate.** `find` has a second exit (`b.eq .Lret`) in the middle of the loop, and the return value is the loop pointer itself — "return the current node". `sum` has one exit and returns an accumulator. Two exits plus returning the induction variable means a search.
6. **Free `NULL`.** When `find` runs off the end, `x0` is already `0` (that's why the loop stopped), so `return NULL` costs nothing — no separate `mov x0, xzr`.

## Compared with real code

- [[Reading-A-Dart-AOT-Getter-Cold]] — real pointer chasing through Dart objects, where each hop is a 4-byte compressed pointer that must be decompressed (`add xN, xN, HEAP, lsl #32`) before the next load.
- [[Object-Field-Store-With-Write-Barrier]] — storing a pointer into a heap object, the write side of the same structures.

## See also

- [[Memory-And-Data-Structures]]
- [[Struct-Field-Access]]
- [[Array-Indexing-With-Scaled-Registers]]
- [[Reading-Struct-Args-With-A-Reconstructed-Layout]] in [[Frida-Dynamic-Instrumentation]] — walking the same kind of structure live

## References

- [[ARM64-Android-Bibliography|Bibliography]]
