---
tags: [fundamentals]
aliases: [Control Flow Recovery]
created: 2026-07-28
---

# Control-Flow-Patterns

## In short

Source-level `if`/`else`, loops, `switch`, and short-circuit `&&`/`||` all get flattened into the same small vocabulary of compares and branches from [[Instructions]]. There is no "loop instruction" or "switch instruction" to grep for — recovering structure is entirely about recognizing _shapes_ in the compare/branch graph. This chapter catalogs the shapes that matter.

## Explanation

### `if`/`else` → forward branch (or no branch at all)

The classic shape is "compare, branch-if-condition-false past the true-branch, true-branch code, [unconditional branch past the else], else-branch code":

```asm
    cmp     w0, #0
    b.le    .Lelse
    ; then-branch
    b       .Lend
.Lelse:
    ; else-branch
.Lend:
```

But as shown in [[Instructions#Worked example|the previous chapter's worked example]], a compiler is equally free to skip branching entirely and use `csel` when both branches are cheap, side-effect-free expressions. **Don't assume "no branch" means "no `if`."**

### Loops → backward branch

A loop is structurally just an `if` whose branch target is _earlier_ in the code than the branch itself:

```asm
.Lloop:
    ; body
    cmp     wN, wM
    b.lt    .Lloop        ; branch BACKWARD -> this is the loop
.Lafter:
```

The test can sit at the top (while-style, may skip the body entirely), the bottom (do/while-style, guaranteed at least one iteration), or the compiler may duplicate/rotate the test so the common case only pays for one branch per iteration instead of two — a transformation with no source-level equivalent, encountered purely as a compiler optimization.

### `switch`/enum dispatch → three shapes

1. **Cascading compares** — a chain of `cmp`/`b.eq` (or, for object/enum instances, `cmp` against a canonical singleton's address) when the case count is small or the values aren't dense. This is indistinguishable from a hand-written `if`/`else if` chain in the assembly, and often _is_ exactly that under the hood — see [[Enum-Switch-Via-Pointer-Comparison]] for a real one.
2. **Jump table** — for a dense range of small integer cases, the compiler instead computes an index and loads a branch target from a table: `adr`/`adrp` to the table base, a scaled load, a `br` through the loaded address. Look for a bounds check immediately before it (values outside the dense range fall through to a default case handled separately).
3. **Binary search over compares** — for a sparse-but-large set of cases, some compilers emit a balanced tree of range compares instead of either of the above.

### Short-circuit boolean logic

`a && b` and `a || b` compile to _conditional_ evaluation of the second operand — a branch that skips evaluating `b` entirely when `a` already decides the result:

```asm
    ; if (a && b)
    cmp     w0, #0
    b.eq    .Lfalse        ; a was false -> short-circuit, never touch b
    cmp     w1, #0
    b.eq    .Lfalse
    ; both true
```

This matters for static analysis specifically because a function call inside `b` that you'd expect to always run might structurally be **unreachable on some paths** — the branch target for the short-circuit skips right past the call.

## Worked example

The real cascading-compare `switch`-over-enum pattern, trimmed from this topic's [[Classeviva-Flutter-Case-Study|Classeviva case study]] (`AbsenceLocalizations.absenceAbbreviationName` — see the full excerpt in [[Enum-Switch-Via-Pointer-Comparison]]):

```
// 0xdb281c: LoadField: r2 = r1->field_f      ; r2 = this.someEnumField
//     0xdb281c: ldur w2, [x1, #0xf]
//     0xdb2820: DecompressPointer r2
// 0xdb2824: r16 = Instance_AbsenceType        ; load a specific enum singleton's address from the object pool
//     0xdb2824: add x16, PP, #9, lsl #12
//     0xdb2828: ldr x16, [x16, #0x6a0]
// 0xdb282c: cmp w2, w16                       ; is this enum value THIS variant?
// 0xdb2830: b.ne #0xdb2954                    ; no -> fall through to the next case's comparison
```

The pattern repeats: load the field once at the top, then a sequence of `cmp` against a different enum-singleton address loaded from the pool each time, each followed by `b.ne <next comparison>` — structurally identical to `if (x == A) {...} else if (x == B) {...} else if (x == C) {...}`, which is exactly what a Dart `switch` over an `enum` compiles to (Dart enums are just objects with identity, not small integers, so this can't use a jump table the way a C `switch (int)` might).

## More examples

- [[If-Else-As-Branches]] — the forward-branch shape end to end, including the "compiler skipped the branch" `csel` variant
- [[Loop-As-Backward-Branch]] — `while`, `do/while`, and a rotated loop

## See also

- [[Instructions]]
- [[Memory-And-Data-Structures]]
- [[Flutter-Dart-AOT]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]

## Flashcards
#flashcards

What structurally distinguishes a loop from a plain `if` in disassembly?::The branch target is earlier in the instruction stream than the branch itself (a backward branch), vs. an `if`'s forward branch.
Why can't a `switch` over a Dart `enum` typically use a jump table?::Dart enum values are heap objects with identity/pointer equality, not small dense integers, so the compiler falls back to a cascading chain of pointer compares against each variant's canonical singleton address.
What should make you suspect short-circuit `&&`/`||` rather than a simple sequential check?::A branch that skips evaluating (and calling into) the second operand entirely when the first already determines the result.
Does the absence of any branch around a comparison always mean there's no `if` in the source?::No — the compiler may have used `csel`/`csinc`/etc. to compute both outcomes and branchlessly select between them.
