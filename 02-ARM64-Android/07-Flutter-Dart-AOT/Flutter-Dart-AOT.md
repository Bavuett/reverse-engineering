---
tags: [fundamentals]
aliases: [Dart AOT, Flutter Reversing, libapp.so]
created: 2026-07-28
---

# Flutter-Dart-AOT

## In short

A release-mode Flutter app ships its entire Dart codebase pre-compiled to native ARM64 machine code inside `libapp.so` — there is no bytecode, no interpreter, and (unlike a JNI `.so`) no per-function correspondence to a Java/Kotlin class you could instead read at the Dalvik-bytecode level. Everything you need to understand a Flutter app statically has to come from reading this ARM64 directly, which is exactly why this topic exists. The good news: the Dart AOT compiler's output is _extremely_ regular — a handful of conventions, once learned, explain the overwhelming majority of every function you'll open. This chapter is that handful, illustrated throughout with real excerpts from real Dart-AOT disassembly.

## Explanation

### Where this fits among the previous chapters

Everything in [[Registers-And-Data]] through [[Memory-And-Data-Structures]] already applies — Dart AOT code is still real AArch64, still follows AAPCS64 for the physical argument/return registers, still builds `if`/loops/`switch` the same way. What this chapter adds is the _layer on top_: a set of permanently reserved registers, a mandatory frame convention, and a handful of memory representations (Smis, compressed pointers, the object pool) that a plain NDK `.so` would never have reason to use.

### Reserved registers, recap and roles

Already introduced in [[Registers-And-Data#Explanation|Reserved registers you'll meet in Android
native code]] — restated here with their concrete jobs:

| Symbolic name | Role |
| --- | --- |
| `THR` | Current `Thread*`: stack limit (offset `0x38`, used by every `CheckStackOverflow`), bump-allocation `top`/`end` (offset `0x50`, used by every inline object allocation), per-isolate static field storage |
| `PP` | Current object pool: every string literal, `TypeArguments` object, stub address, and non-Smi constant a function needs is indexed from here instead of embedded inline |
| Dispatch-table register (`GDT`, shown raw as e.g. `x21` by some tools) | Base of the table indexed by class id for dynamic/virtual dispatch |
| `NULL` | Points at the canonical `null` singleton; `true`/`false` singletons sit at small fixed offsets from it (`NULL + 0x20` = `true`, `NULL + 0x30` = `false` in the excerpts throughout this topic) |
| `HEAP` | Heap base used both for pointer decompression (`add xd, xd, HEAP, lsl #32`) and, differently masked, in write-barrier checks — see [[Memory-And-Data-Structures]] |

### The object pool (`PP`)

Rather than embedding a string or object constant directly in the instruction stream (impossible for a 64-bit pointer anyway, and wasteful for a full 64-bit constant load per use), Dart AOT code keeps one table per compilation unit and loads entries by offset:

```
// 0x10f1b1c: r16 = Instance_LoginMode
//     0x10f1b1c: add   x16, PP, #0xb, lsl #12  ; [pp+0xbc40] Obj!LoginMode@1196951
//     0x10f1b20: ldr   x16, [x16, #0xc40]
```

The `add ..., PP, #N, lsl #12` / `ldr ..., [.., #offset]` pair is because a single instruction's immediate offset field isn't wide enough to reach an arbitrarily large pool — the compiler splits the offset into a page part (`#0xb, lsl #12` = `0xb000`) and a within-page part (`#0xc40`), the same two-part-offset idea as [[Instructions#Explanation|`adrp`+`add` PIE addressing]], just against the object pool instead of the program counter. A disassembler that's recovered the pool's contents (as blutter has, here) annotates the resulting address with what's actually stored there — `Obj!LoginMode@1196951`, an enum singleton, in this case.

### The global dispatch table (GDT) and virtual calls

Covered fully in [[Bitfield-Class-Id-Extraction]] and its parent chapter [[Instructions#Explanation|instructions]]: extract a class id from the object header, then compute a call target from `GDT + cid*8 (+ a fixed per-call-site offset selecting which method)`:

```
// 0xc20d30: r0 = GDT[cid_x0 + 0x1490d]()
//     0xc20d30: movz    x17, #0x490d
//     0xc20d34: movk    x17, #0x1, lsl #16
//     0xc20d38: add     lr, x0, x17
//     0xc20d3c: ldr     lr, [x21, lr, lsl #3]
//     0xc20d40: blr     lr
```

This is Dart's answer to virtual dispatch — one flat, global table shared by every class instead of a per-class vtable, so calling _any_ method through a statically-unknown receiver type looks identical regardless of which class actually implements it; only the constant folded into `x17` (which combines the call site's method identity with an offset) changes.

### Stubs

A **stub** is a small hand-written routine (not compiled from Dart source) the AOT compiler emits calls to for common operations too fiddly or too shared to inline everywhere. You'll meet these repeatedly and should stop reading them as "a mystery function call" the moment you recognize the name:

| Stub | Purpose |
| --- | --- |
| `AllocateClosureStub` | Heap-allocate a closure object capturing whatever context it needs |
| `AllocateContextStub` | Heap-allocate the captured-variable context for a closure |
| `AllocateArrayStub` / `AllocateGrowableArrayStub` | Allocate a fixed/growable `List` |
| `AllocateDoubleStub` / `AllocateMintSharedWith[out]FPURegsStub` | Slow-path boxing when a value doesn't fit the inline bump-allocation fast path or overflows a Smi — see [[Smi-Boxing-And-Unboxing]] |
| `StackOverflowSharedWith[out]FPURegsStub` | The slow path taken by every function's `CheckStackOverflow` when it actually trips |
| `NullErrorSharedWithoutFPURegsStub` | Throws Dart's null-check failure — the target of an implicit non-null assertion, not something your source necessarily wrote explicitly |
| `ArrayWriteBarrierStub` / the plain single-field write-barrier path | See [[Object-Field-Store-With-Write-Barrier]] |
| `AwaitStub` | Suspends the current `async` function at an `await` point — see below |

The `With`/`WithoutFPURegs` naming split (seen on several of these) exists purely as an optimization: saving/restoring the full vector/FP register file around a runtime call is only worth paying for when the calling function actually uses those registers.

### Closures

An anonymous function/closure compiles to its own standalone function (shown by tools like blutter as a `[closure] ... <anonymous closure>(...)` block, physically separate from its enclosing method), plus, at the point it's created, an `AllocateClosureStub` call that packages a pointer to that function together with whatever captured context it needs:

```
// 0xc20cfc: r1 = Function '<anonymous closure>': static.
//     0xc20cfc: add   x1, PP, #0x26, lsl #12  ; AnonymousClosure: static (0xc20eb4), ...
// 0xc20d04: r2 = Null
// 0xc20d08: r0 = AllocateClosure()
//     0xc20d08: bl    #0x10cb178  ; AllocateClosureStub
```

A single top-level Dart method with two lambda arguments (e.g. two calls to `fold` in `GradeUtils.getAvg`) shows up as **three separate disassembled blocks**: the enclosing method, and one `[closure] ...` block per lambda — don't go looking for the lambda bodies inline where the source would suggest they live.

### `async`/`await` and platform channels

`await` doesn't block a thread — it compiles to a call into whatever's being awaited, followed by a call to `AwaitStub`, which suspends the current Dart-level "isolate task" and arranges for execution to resume (at a different address, recorded as part of the suspended state) once the awaited value/future completes:

```
// 0xc10fb0: r0 = invokeMethod()
//     0xc10fb0: bl   #0x1056578  ; MethodChannel::invokeMethod
// 0xc10fbc: r0 = Await()
//     0xc10fbc: bl   #0x7e84ac  ; AwaitStub
// 0xc10fc0: b    #0xc11038          <- where execution resumes after the await completes
```

`MethodChannel::invokeMethod` itself is how Dart code reaches across into the **genuinely JNI-callable native/Java side** — the Flutter engine (`libflutter.so`, plain NDK code, see [[Android-Native-Internals]]) receives the channel name/method/arguments and dispatches to whatever platform-specific handler registered for it. This is the one place the two calling conventions from this topic directly meet: Dart-AOT-convention code (`invokeMethod`) calling into engine code that ultimately does JNI-convention work on the other side. See the full excerpt in [[MethodChannel-Invoke-And-Await]].

## Worked example

See [[Object-Pool-Constant-Loads]] for a full excerpt showing multiple pool-indexed constant loads in one function, and [[MethodChannel-Invoke-And-Await]] for the `async`/platform-channel boundary end to end.

## More examples

- [[Dart-Frame-Prologue]] — the prologue shape restated standalone, cross-referencing [[Functions-And-Calling-Convention]]
- [[Object-Pool-Constant-Loads]]
- [[MethodChannel-Invoke-And-Await]]

## See also

- [[Functions-And-Calling-Convention]]
- [[Memory-And-Data-Structures]]
- [[Control-Flow-Patterns]]
- [[Android-Native-Internals]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]

## Flashcards
#flashcards

Why can't you read a Flutter release build's logic at the Dalvik-bytecode level the way you would a normal Android app?::Because the Dart code is AOT-compiled straight to native ARM64 machine code inside `libapp.so` — there's no bytecode representation of it left to decompile.
What does the two-instruction `add x16, PP, #N, lsl #12` / `ldr x16, [x16, #offset]` pair load?::A constant (string, enum instance, type arguments, stub address, ...) from the object pool — split into a page part and a within-page part because one instruction's immediate can't address the whole pool directly.
How does Dart AOT implement virtual/dynamic dispatch without a per-class vtable?::Via a single global dispatch table indexed by (class id, per-call-site offset) — extract the receiver's class id from its header, compute an index, load and call the function pointer.
What actually happens at an `await` in compiled Dart AOT code?::A call to whatever's being awaited, followed by a call to `AwaitStub`, which suspends the current task; execution resumes at a separately-recorded address once the awaited value completes — no OS thread is blocked.
