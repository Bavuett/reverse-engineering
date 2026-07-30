---
tags: [fundamentals]
aliases: ["Memory Model", "Library Stack Heap", "Runtime Data Areas", "Method Area"]
created: 2026-07-30
---

# Memory Model

## In short

Everything in this topic collapses into three memory regions a running Java program is made of — the exact triple `⟨ρc, σ, ζ⟩` the semantics carries around:

- **Library** (class environment ρc / "method area") — the loaded classes: their code, their method tables, their field layouts. Written once at class-load time, then read-only. Shared by every object.
- **Stack** (σ) — a stack of frames, one per active method call, holding parameters, `this`, and locals. Grows and shrinks with calls and returns; private to a thread.
- **Heap** (ζ) — every `new`-allocated object, keyed by reference. Shared across the program; cleaned up by garbage collection.

The value of learning it this precisely is that it's *the same model the JVM and Android's ART implement*, so it's the map you read [[Dalvik-Bytecode]] and [[ARM64-Android]] with.

## Explanation

### The three regions, and what decides which one a thing lives in

| Region | Holds | Lifetime | Shared? | In the semantics |
|---|---|---|---|---|
| **Library** / method area | class definitions, method bytecode, static fields, the constant pool | whole program (per class, from first use) | across all threads/objects | `ρc` |
| **Stack** | one frame per call: parameters, `this`, locals | call → return (LIFO) | per thread | `σ` (a stack of frames) |
| **Heap** | objects (`new`), arrays | until unreachable, then GC'd | across the program | `ζ` |

The decisive question for any value is **"who needs to see it, and for how long?"** A local that dies with its method → stack. An object that outlives the call that made it and may be shared → heap (which is why a variable holds a *reference* into the heap, not the object — [[Classes-And-Objects]]). A class's code and layout, identical for every instance → the library, once.

### Why the split exists at all

- **Stack** is cheap and automatic: push on call, pop on return, no bookkeeping — but strictly LIFO, so anything that must outlive its creating call can't live there.
- **Heap** buys unbounded lifetime and sharing at the cost of needing **garbage collection** (or manual free) to reclaim it: an object is collectable once no chain of references from a *root* (a stack slot, a static field in the library) reaches it. Reachability is exactly "is there still a path `σ`/statics → … → this location in `ζ`".
- **Library** is the shared, immutable-after-load middle: putting method code and field layouts here (not in every object) is why an object needs to store only its own field *values*, plus a pointer to its class.

### How this maps onto the real JVM

The JVM Specification's **runtime data areas** are this triple, named differently: the **method area** (called *Metaspace* since Java 8) is the library ρc; per-thread **JVM stacks** of frames are σ; the shared **heap** is ζ; plus a **PC register** per thread (the configuration's program counter from [[Operational-Semantics]]). Class **loading → linking (verify/prepare/resolve) → initialization** is the process that *builds* ρc entry by entry — and `<clinit>` running "the first time a class is used" is why static initialization is lazy.

### How this maps onto Android/ART — the payoff for reversing

This is the model you carry into static and dynamic analysis:

- **Library / method area = the dex + loaded classes.** Class defs, method bytecode, the string/type/field/method constant pools all live here. Reading smali is reading this region's contents; **reflection and dynamic class loading** ([[Reflection-and-Runtime-Internals]]) are runtime *edits and queries* to it (`InMemoryDexClassLoader` adds an entry to ρc that never existed on disk — see [[Tua-Case-Study]]'s [[In-Memory-Dex-Loading]]).
- **Stack = method register frames.** Each `invoke-*` pushes an activation with its own registers; `p0` is `this`, `p1…` the parameters, `v0…` the locals ([[Methods-And-Recursion]], [[Registers]] in [[Dalvik-Bytecode]]). A Frida or native backtrace is walking this region.
- **Heap = objects.** `new-instance` allocates here; `iget`/`iput` read/write an object's fields; references are object registers. Down at the native level ([[ARM64-Android]]) a field access is an `ldr`/`str` at a fixed offset off an object pointer, and ART/Dart heaps add tricks like tagged integers and compressed pointers ([[Memory-And-Data-Structures]], [[Flutter-Dart-AOT]]) — all still just "read a value out of the heap region".

> [!tip] The one-sentence bridge to the rest of the vault
> When you read a smali `iget-object v1, p0, LFoo;->bar:LBar;`, you are watching all three regions at once: `p0` (stack) holds a reference into the **heap**, the field `bar` and its type come from the **library** (the class definition), and the result lands back in a register on the **stack**. Every reverse-engineering task in [[Dalvik-Bytecode]] and [[ARM64-Android]] is reading or manipulating one of these three regions.

## More examples

- [[Tracing-A-Value-Through-The-Three-Regions]] — one small program, showing which region each value lives in and the smali it compiles to.

## See also

- [[Classes-And-Objects]] and [[Declarations-And-Scope]] — the heap and stack in detail.
- [[Methods-And-Recursion]] — the call stack.
- [[Reflection-and-Runtime-Internals]] in [[Dalvik-Bytecode]] — runtime data areas, class loading, and stack frames as ART implements them; the concrete counterpart to this chapter.
- [[Memory-And-Data-Structures]] in [[ARM64-Android]] — the heap region at the level of raw loads/stores.

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]

## Flashcards
#flashcards

What are the three memory regions of a running Java program, and what does each hold?::Library/method area (class code, method tables, field layouts, statics — the class environment ρc), the stack (one frame per active call: parameters, `this`, locals — σ), and the heap (all `new`-allocated objects, keyed by reference — ζ).
What single question decides whether a value lives on the stack vs. the heap?::"Who needs to see it, and for how long?" — a value that dies with its creating call goes on the stack; one that must outlive that call or be shared goes on the heap (reached via a reference).
When is a heap object eligible for garbage collection?::When it's unreachable — no chain of references from any root (a stack slot or a static field in the method area) leads to its location in the heap.
Map library/stack/heap onto Android/ART.::Library = the dex + loaded classes (method area; reflection/dynamic loading edit it at runtime); stack = per-method register frames pushed by `invoke-*` (`p0`=this); heap = objects from `new-instance`, accessed via `iget`/`iput` and, natively, `ldr`/`str` off an object pointer.
