---
tags: [fundamentals]
aliases: ["Instruction formats", "Opcodes overview"]
---

# Instructions

Once [[Classes]], [[Methods]], [[Registers]] and [[Types]] are familiar, reading a method body is mostly a matter of recognizing recurring instruction families. This chapter groups the most common ones by purpose; each family can later get its own detailed entry under [[Dalvik-Bytecode-Reference|Reference]] using the [[New-Reference-Entry]] template.

## Constants and data movement

| Family | Purpose |
| --- | --- |
| `const`, `const/4`, `const/16`, `const/high16` | load a small/large 32-bit literal into a register |
| `const-wide`, `const-wide/16`, `const-wide/high16` | load a 64-bit literal into a register pair |
| `const-string` | load a reference to an interned `String` literal |
| `const-class` | load a `Class` object literal (e.g. `MyClass.class`) |
| `move`, `move-wide`, `move-object` | copy a value between registers (see [[Registers]]) |
| `move-result`, `move-result-wide`, `move-result-object` | capture the return value of the last `invoke-*` |

## Field access

| Family | Purpose |
| --- | --- |
| `iget`, `iput` (+ `-wide`, `-object`, `-boolean`, `-byte`, `-char`, `-short`) | read/write an **instance** field |
| `sget`, `sput` (+ same suffixes) | read/write a **static** field |

```smali
iget v0, p0, LPerson;->age:I      # v0 = this.age
sput v0, LCounter;->total:I       # Counter.total = v0
```

## Array access

| Family | Purpose |
| --- | --- |
| `array-length` | store an array's length into a register |
| `new-array` | allocate a new single-dimension array |
| `filled-new-array` / `filled-new-array/range` | allocate and initialize a small array in one step, from individual register values |
| `fill-array-data` | populate an **already-allocated** primitive array from a literal data block, rather than register values |
| `aget`, `aput` (+ `-wide`, `-object`, `-boolean`, `-byte`, `-char`, `-short`) | read/write an array element |

See [[Multidimensional-Arrays]] for how these compose to model `int[][]`-style types.

### `fill-array-data` and `.array-data`

`fill-array-data` is a different tool from `filled-new-array`: it doesn't allocate anything itself (a preceding `new-array` does that), and instead of listing element values as individual registers, it points at a literal data block placed after the method body, delimited by `.array-data <element-width> ... .end array-data`:

```smali
const/4 v0, 0x3
new-array v0, v0, [B          # allocate a 3-element byte[]
fill-array-data v0, :array_0  # populate it from the literal table below
...
:array_0
.array-data 1                 # element width in bytes: 1 -> this is a byte[]
    0x1t
    0x2t
    0x3t
.end array-data
```

The `<element-width>` argument (`1` for `byte[]`, `2` for `short[]`/`char[]`, `4` for `int[]`/`float[]`, `8` for `long[]`/`double[]`) must match the array's actual element size; each literal is written with a lowercase type-width suffix (`t` for byte-width values) matching how `baksmali` renders two's-complement negative values. This is exactly how compile-time-constant arrays — including the encrypted string/delta tables that string-decoding routines read from — get embedded into a class, since a compiler favors one `fill-array-data` block over dozens of individual `aput` instructions whenever an array's contents are all known at compile time. See [[Encrypted-String-Table-Array-Data]] for a real-app instance, and [[Reading-Raw-Dalvik]] for what a decode loop built on top of one looks like.

## Method invocation

| Family | Purpose |
| --- | --- |
| `invoke-direct` | constructors, `private` methods (see [[Methods]]) |
| `invoke-static` | `static` methods |
| `invoke-virtual` | public/protected instance methods, dynamic dispatch |
| `invoke-interface` | methods called through an interface reference |
| `invoke-super` | explicit call to the superclass's implementation |
| `*/range` variants of the above | used when the call needs more than 5 registers to pass its arguments |

## Object and array creation

| Family | Purpose |
| --- | --- |
| `new-instance` | allocate an (uninitialized) object of a given class — must be followed by a call to `<init>` |
| `new-array` | allocate an array (see above) |
| `check-cast` | verify (and narrow) a reference's type, throwing `ClassCastException` on mismatch |
| `instance-of` | test whether a reference is an instance of a type, without throwing |

## Arithmetic and conversion

| Family | Purpose |
| --- | --- |
| `add-`, `sub-`, `mul-`, `div-`, `rem-` (`int`/`long`/`float`/`double`) | binary arithmetic |
| `rsub-int`, `rsub-int/lit8` | **reverse** subtract: `literal - register`, not `register - literal` |
| `and-`, `or-`, `xor-`, `shl-`, `shr-`, `ushr-` (`int`/`long`) | bitwise operations |
| `neg-`, `not-` | unary negation / bitwise complement |
| `.../2addr` forms | compact 2-operand encoding (`add-int/2addr v0, v1` means `v0 = v0 + v1`) |
| `int-to-long`, `long-to-int`, `int-to-float`, `float-to-double`, ... | explicit numeric conversions |

> [!warning] `rsub-int`'s operand order is reversed
>
> There is no plain `sub-int/lit8` — literal subtraction only exists in the *reversed* form, `rsub-int/lit8 vA, vB, #lit` meaning `vA = #lit - vB`, not `vB - #lit`. It's easy to misread on a first pass as ordinary subtraction with the operands swapped in the mnemonic; they're swapped in the *computation* instead. This shows up constantly in hand-obfuscated code, where a call-site integer gets disguised as `rsub-int/lit8 v0, p1, 0x1` (i.e. `v0 = 1 - p1`) rather than a more obviously-reversible `p1 - 1` — see [[Reading-Raw-Dalvik]]'s decoder examples for real instances.

## Comparisons and control flow

| Family | Purpose |
| --- | --- |
| `if-eq`, `if-ne`, `if-lt`, `if-ge`, `if-gt`, `if-le` | two-register conditional branch |
| `if-eqz`, `if-nez`, `if-ltz`, `if-gez`, `if-gtz`, `if-lez` | compare a single register against zero |
| `cmp-long`, `cmpg-float`, `cmpl-float`, `cmpg-double`, `cmpl-double` | three-way compare, result fed into an `if-*z` |
| `goto`, `goto/16`, `goto/32` | unconditional jump |
| `packed-switch`, `sparse-switch` | multi-way branch (Java `switch`) |

```smali
if-lt v0, v1, :cond_0
# ... "then" branch ...
:cond_0
# ... "else"/continuation ...
```

## Returning and exceptions

| Family | Purpose |
| --- | --- |
| `return-void` | return with no value |
| `return` | return a 32-bit primitive |
| `return-wide` | return a 64-bit primitive (`long`/`double`) |
| `return-object` | return a reference |
| `throw` | raise an exception |
| `monitor-enter`, `monitor-exit` | acquire/release the intrinsic lock used by `synchronized` (see [[Methods]]) |
| `move-exception` | at the top of a catch block, capture the thrown exception (see `.catch` in [[Methods]]) |

## Where these show up

Every practical example across the vault exercises several of these families at once — see e.g. [[Constructor-and-Fields]] for `iput`/`iget`, [[Multidimensional-Arrays]] for `aget`/`aput`, or [[Exception-Handling]] for `throw`/`move-exception`.

## See also

- [[Dalvik-Bytecode-Reference|Reference]] — where individual opcodes get their own detailed entry over time
- [[Registers]], [[Types]], [[Methods]], [[Classes]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]

## Flashcards
#flashcards

What is the difference between `invoke-virtual` and `invoke-virtual/range`?::They call the same kind of method; `/range` is used when the call needs more registers for its arguments than the compact encoding can hold (more than 5), listing a contiguous register range instead of individual registers.
Which instruction must always be called right after `new-instance`, and why?::A constructor call (`invoke-direct ...-><init>(...)V`) on the freshly allocated, still-uninitialized object — `new-instance` only allocates memory, it does not run the constructor.
What does `check-cast` do if the reference is not an instance of the target type?::It throws a `ClassCastException`.
What does `rsub-int/lit8 v0, p1, 0x1` compute, and why is it easy to misread?::`v0 = 0x1 - p1` — the *literal minus the register*, not the register minus the literal; there's no plain `sub-int/lit8`, so the reversed form is the only way to subtract a register from a literal, and it's easy to assume ordinary left-to-right subtraction on a quick read.
What's the difference between `filled-new-array` and `fill-array-data`?::`filled-new-array` allocates a small array and populates it from individual register values in one instruction; `fill-array-data` populates an array a preceding `new-array` already allocated, from a literal `.array-data` block instead of registers — the tool a compiler reaches for when every element's value is already known at compile time.
