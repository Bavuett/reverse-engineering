---
tags: [fundamentals]
aliases: ["Reflection", "Java Reflection", "Method.invoke", "ArtMethod", "JVM Runtime", "ART Runtime", "Garbage Collection", "JIT compilation"]
created: 2026-07-30
---

# Reflection and Runtime Internals

## In short

Reflection (`java.lang.reflect`) lets code look up a class or method **by name, as a string, at runtime**, instead of the compiler wiring a direct call into the bytecode. That single property is why it's a favorite technique in hardened/obfuscated apps: a disassembler can only read instructions that name their target explicitly, and a reflective call never does — the target is data, computed and possibly decrypted only while the app is running. Making sense of this, and of why it works, requires a model of what the runtime actually does with a method call: how classes get loaded, how a call is dispatched to a concrete implementation, where objects and metadata live in memory, and how that differs between a desktop JVM and ART, the runtime that actually executes the Dalvik bytecode this topic is about.

## Explanation

### Why reflection defeats static analysis

A normal method call is resolved at compile time: the compiler knows exactly which class, method, and signature it's targeting, and encodes that as a symbolic reference the bytecode instruction carries directly (see the `invoke-*` table in [[Methods]]). A decompiler or disassembler reads that reference straight off the instruction — that's the entire mechanism a call graph is built from.

Reflection routes around this. Instead of `target.method(args)` compiled directly, the code does roughly:

```java
Class<?> cls = Class.forName("com.example.SomeClass");                 // class name as a string
Method m = cls.getDeclaredMethod("hiddenCheck", long.class, long.class); // method name as a string
m.setAccessible(true);                                                   // bypass private/protected
m.invoke(instance, arg1, arg2);                                          // the actual call
```

The compiled bytecode for this contains no reference at all to `hiddenCheck` — only a call to the generic `Method.invoke`, the same instruction that appears for *every* reflective call in the entire program, regardless of what it actually invokes. The real target lives only in a `String`, and strings can be built, concatenated, or decrypted at runtime in ways a static disassembler never executes. If that string is itself stored encrypted (a very common pairing — see the `$$d`/`$$j`/`$$l` byte-array fields in [[Reading-Raw-Dalvik]]), a static tool has no way at all to know, from the file alone, what will be called.

### Direct calls vs. reflective calls, at the bytecode level

| | Direct call | Reflective call |
| --- | --- | --- |
| Bytecode instruction | `invoke-virtual`/`invoke-static`/`invoke-direct`/`invoke-interface`/`invoke-super`, naming the target class+method+signature | `invoke-virtual {...}, Ljava/lang/reflect/Method;->invoke(...)Ljava/lang/Object;` — always the same instruction, whatever the real target is |
| Target visible to a disassembler | Yes, as a symbolic reference baked into the instruction | No — only a generic `Method` object, itself produced by a preceding `getDeclaredMethod("name", ...)` whose `"name"` argument may be computed/decrypted |
| What a decompiler's call graph shows | An edge straight to the real callee | An edge to `Method.invoke`, a dead end unless the string argument is also resolved |

This is exactly the signal used to hunt reflection-hiding in the TUA case study (see [[Anti-Tampering-Pattern-Workflow]]): grepping declared methods and grepping direct `invoke-*` targets separately, then taking the set difference — a method that exists but is never the explicit target of any `invoke-*` in the whole tree is almost certainly reached only through reflection.

### Other mechanisms that hide the call graph the same way

Reflection is the most common instance of a broader family — worth knowing the others, since real hardening tools often combine them:

- **`invokedynamic` / `MethodHandle`** (`java.lang.invoke`) — a call site that decides its actual target the first time it runs, via a *bootstrap method*, rather than at compile time. Even harder for a decompiler to resolve statically than plain reflection, since even the mechanism for producing the target is user-defined code.
- **Dynamic proxies** (`java.lang.reflect.Proxy`) — a class implementing one or more interfaces is generated entirely at runtime, delegating every call to a single `InvocationHandler.invoke(...)`. There is no concrete class file to decompile until the process is actually running.
- **Dynamic class loading** — `Class.forName`, a custom `ClassLoader.loadClass`, or on Android a `DexClassLoader` pulling a second `.dex` from `assets/` or the network. Combined with reflection, the "real" code may never exist in the APK at all as a static file — it's decrypted/downloaded and loaded only at runtime.
- **JNI (native code)** — a method declared `native` has no Dalvik/Java bytecode body whatsoever; its implementation lives in a native library, requiring an entirely different toolchain (a native disassembler, not a smali one) to inspect. Native code calling back into Java via reflection (building a `jmethodID` from a runtime string) hides the Java↔native boundary from both sides at once.
- **Deserialization** — not primarily an anti-analysis technique, but built on the identical principle: `ObjectInputStream.readObject()` invokes methods (`readObject`, `readResolve`, setters) chosen by the *shape of a byte stream*, not by an explicit call in the code — which is also why insecure deserialization is a well-known vulnerability class (gadget chains).

### Class loading: Loading, Linking, Initialization

Before any method can execute, its class goes through three phases defined by the runtime:

1. **Loading** — the class's bytes (from a file, the network, or generated on the fly) are turned into an internal `Class` representation, by a **ClassLoader**.
2. **Linking**, in three sub-steps: **verification** (the bytecode is checked for type/stack safety before it's trusted to run at all — this is why arbitrary corrupted bytecode can't just be executed silently), **preparation** (static fields get storage, initialized to defaults — `0`/`null`/`false`, not their real values yet), and **resolution** (symbolic references get tied to real, concrete class/method/field data, lazily in practice).
3. **Initialization** — the class's `<clinit>` runs (see [[Methods]]): static field initializers and `static { }` blocks. Crucially, this happens the *first time the class is actually used*, not at load time — a detail sometimes exploited to hide side effects: arbitrary logic placed in a `<clinit>` fires "by itself" whenever that class is first touched, with no visible call site pointing at it.

ClassLoaders form a delegation hierarchy (bootstrap → platform → application, plus any custom loader an app installs), conventionally asking the parent first — this is what stops app code from spoofing a core class like `String`. A **custom ClassLoader** that decrypts and `defineClass`-es bytecode fetched at runtime is, again, code that is never present as an inspectable static file — only as bytes momentarily in memory at the exact instant it's defined.

### Runtime data areas: where methods and memory actually live

| Area | Scope | Holds |
| --- | --- | --- |
| **PC register** | per thread | address of the bytecode instruction currently executing (undefined while running native code) |
| **VM stack** | per thread | one frame per active method call — locals, operand stack, return address (see below) |
| **Native method stack** | per thread | stack used while executing native (JNI) code |
| **Heap** | shared | every object ever allocated with `new`, plus arrays |
| **Method area** (called **Metaspace** since Java 8; historically "PermGen") | shared | class metadata: each method's own bytecode, the resolved constant pool, static fields |

### Stack frames: how a method call actually executes

Each thread's stack is a sequence of frames, one per method call currently in progress. A frame holds a **local variable array** (arguments plus local variables, addressed by numeric slot — Dalvik's `v`/`p` registers, see [[Registers]], are this exact same concept made explicit and named in the instruction stream, rather than implicit) and an **operand stack**, a scratch area the bytecode's instructions push to and pop from (the standard JVM is a *stack* machine — `iadd` pops two values, pushes their sum — whereas Dalvik is a *register* machine, operating on explicitly numbered registers instead; a deliberate, different design choice for Android, trading slightly larger instructions for fewer of them).

Calling a method means: resolving the symbolic reference to a concrete target (for `invoke-virtual`/`invoke-interface`, that resolution depends on the *actual runtime type* of the receiver, via the vtable/itable dispatch already covered in [[Methods]]), pushing a new frame, copying the arguments into its local variable array, and jumping execution there; returning pops the frame and leaves any result available to the caller. This is precisely the step a reflective call never exposes to a static reader: the "resolve target" step happens entirely inside `Method.invoke`, driven by a runtime string, with nothing in the calling instruction itself to read.

### What `Method.invoke` actually does underneath

It still has to end in an ordinary method call eventually — reflection doesn't invent a new execution mechanism, it just reaches one indirectly:

- In HotSpot (the reference desktop JVM), the first ~15 calls through a given `Method` go through a slow, generic native accessor. After that ("inflation"), the JVM **generates bytecode on the fly** — a synthetic accessor class containing a plain, direct `invokevirtual`/`invokestatic` at the real target — and runs that instead. The JVM itself converts the reflective call into a direct one, but only at runtime, invisible to anything reading the original `.class` file.
- **Android does not run a real JVM.** `javac` output is retranslated (by `d8`/`dx`) into Dalvik bytecode, packaged into a `.dex`, and executed by **ART** (which replaced the original Dalvik VM starting with Android 5.0) — a different runtime, with its own AOT/JIT hybrid execution model, not HotSpot. `java.lang.reflect` is present (Android's core libraries, `libcore`, derive from OpenJDK), but underneath it calls down into ART-specific native code (`art::ArtMethod::Invoke`, ART's own `ArtMethod` structures and vtable/itable representation) rather than generating HotSpot-style accessor bytecode. Practically: hooking `Method.invoke` at the Java level (e.g. with Frida) still works as an entry point on Android, but the mechanism underneath it is ART's, not the desktop JVM's — tooling and mental models built for HotSpot don't transfer one-to-one.

> [!tip] Dalvik/ART bytecode is not JVM bytecode
> `javac` still produces standard JVM class files first; `d8`/`dx` then re-encodes that into the register-based Dalvik instruction set this whole topic covers, packaged per-app into one `.dex` (see [[Dalvik-Type-Table]] and the DEX format reference in [[Dalvik-Bytecode-Bibliography|Bibliography]]). Everything about frames, dispatch, and class loading above is a JVM-Specification concept; ART implements the same *ideas* against a different bytecode and a different set of native data structures, which is why "JVM" and "ART" aren't interchangeable words even though the Java-level API surface (including `java.lang.reflect`) looks identical from the outside.

### Memory management: the generational hypothesis and garbage collection

The heap is where every object lives, and it's managed on one core empirical observation: most objects die young (temporaries, iterators, short-lived wrappers), few survive long (caches, singletons, long-lived config). Hence the typical split:

- **Young generation** (an *Eden* space plus two *survivor* spaces) — where every new object is born; a *minor GC* here is frequent but cheap, since most of Eden is already garbage and only survivors need copying out.
- **Old generation (tenured)** — objects that survive enough minor GC cycles get promoted here; a *major/full GC* is rarer but more expensive, since this region is larger and mostly full of live data.

An object counts as reachable (not collectible) if there's a chain of references from a **GC root** — thread-local variables/parameters on any active stack, static fields of loaded classes, live JNI references — down to it; mark-and-sweep (or copying/compacting variants) starts from the roots and treats everything unreached as garbage. HotSpot ships several collectors tuned for different goals (Serial for small/embedded workloads, Parallel for throughput, G1 as the modern default balancing pause time against throughput, ZGC/Shenandoah for very large heaps with sub-millisecond pauses) — **ART has its own collector** (concurrent, with a compacting "Concurrent Copying" collector since Android 8), conceptually the same generational/root-based idea but a separate implementation with its own tuning and its own runtime behavior visible from a debugger or Frida.

### JIT compilation and low-level execution

A method can run three different ways depending on how "hot" it is:

- **Interpreted** — bytecode executed instruction by instruction, no compilation cost, slow per-instruction.
- **JIT-compiled** — frequently-executed code gets compiled to native machine code at runtime. HotSpot tiers this (**C1**, fast and lightly optimizing, for "warm" code; **C2**, slower but aggressive — inlining, escape analysis to stack-allocate objects that provably never leave a method — for genuinely hot code), and can **deoptimize** back to the interpreter if an assumption the compiled code relied on turns out false at runtime (e.g. a class thought to have no subclasses gets one).
- **ART's AOT/JIT hybrid** — historically ART compiled almost everything to native code *at install time* (`dex2oat`, Ahead-Of-Time), unlike a desktop JVM which never does this. Since "Profile Guided Compilation" (Android 7+), it's a hybrid: interpret/JIT initially, record a profile of what's hot, and recompile that AOT in the background when the device is idle — trading install time, storage, and steady-state performance differently from HotSpot's pure runtime-JIT model.

Heavily reflective/dynamically-loaded code tends to show up as unusually slow and hard to profile (constant generic `invoke` dispatch, classes loaded and JIT-warmed from scratch at runtime, frequent deoptimization) — an anomalous performance profile is sometimes the first hint that reflection-based hiding is present, before any code is even read.

### Practical implications for analysis

- **Statically**: search for `Ljava/lang/reflect/Method;->invoke` (and the preceding `getDeclaredMethod`/`getMethod`), and diff the set of declared methods against the set of methods that are ever the explicit target of a direct `invoke-*` — a method in the first set but not the second is almost certainly reflection-only.
- **Dynamically**: hook `Method.invoke` itself (or, lower-level, `art::ArtMethod::Invoke` in ART's native library) and log the stack trace/arguments on every call — this recovers the real target even when it was built from a string decrypted only at runtime, since by the time `invoke` runs, that string already holds its plaintext value in memory.
- **Reflection rarely travels alone** — expect it paired with encrypted strings (to hide the target name itself), reuse of real API names/signatures as camouflage for the hideout class, and sometimes dynamic class loading or JNI to hide the code even more thoroughly.

## Worked example

```smali
# a direct call: the disassembler can read the target straight off the instruction
invoke-static {v0, v1}, Lcom/example/Checks;->rootCheck(JJ)V

# the same call, rewritten through reflection: the target is now only a string
const-string v2, "com.example.Checks"
invoke-static {v2}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
move-result-object v2

const-string v3, "rootCheck"
const/4 v4, 0x2                                  # 2-element parameter-type array
new-array v5, v4, [Ljava/lang/Class;
sget-object v6, Ljava/lang/Long;->TYPE:Ljava/lang/Class;
aput-object v6, v5, v4                           # both parameters are `long`

invoke-virtual {v2, v3, v5}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;
move-result-object v3

new-array v6, v4, [Ljava/lang/Object;
# ... populate v6 with the two boxed Long arguments ...
invoke-virtual {v3, v7, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
```

The first form names `rootCheck` right in the instruction — one grep finds every caller. The second form never mentions `rootCheck` to anything except a `const-string`, which (in a real hardened app) would itself typically be built from a decrypted byte array rather than a plain literal — at which point nothing in the file text names the real target at all, and only running the code (or reading it dynamically with Frida) recovers what actually gets called.

## More examples

- None yet in `examples/` or `snippets/` for this chapter — see [[Anti-Tampering-Pattern-Workflow]] for the real, considerably more disguised instance this worked example is a simplified version of (reflection reaching a ZXing class repurposed as a hideout, with the method name itself never appearing in plaintext anywhere in the file).

## See also

- [[Methods]] — `invoke-*` instruction families, vtable/itable dispatch, what a reflective call ultimately has to reach
- [[Classes]] — direct vs. virtual methods, the distinction dispatch resolution relies on
- [[Registers]] — the register/local-variable-slot model reflection's arguments still have to flow through
- [[Reading-Raw-Dalvik]] — recognizing encrypted strings and reflection indirection cold, in real obfuscated smali
- [[Anti-Tampering-Pattern-Workflow]] — the full real-world investigation that motivated this chapter
- [[Tua-Case-Study]] — the app this pattern was found in
- [[ARM64-Android]] — the native/JNI side of this same call-hiding family, once there's no more Dalvik bytecode left to read

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]

## Flashcards
#flashcards

Why can't a disassembler see the real target of a reflective call, even though it can see the target of an `invoke-virtual`?::Because the reflective call's only bytecode target is the generic `Method.invoke`; the real target is a runtime string (built by `getDeclaredMethod`/`getMethod`), which is data the disassembler never evaluates, not an instruction operand it can read.
What are the three phases a class goes through before its code can run, and which one runs the `<clinit>`?::Loading, Linking (verification, preparation, resolution), and Initialization — `<clinit>` runs during Initialization, the first time the class is actually used, not when it's first loaded.
Why doesn't Android run "a JVM", strictly speaking, even though `java.lang.reflect` and JVM concepts like frames/GC roots still apply?::Because Android retranslates standard JVM class files into register-based Dalvik bytecode (`d8`/`dx`), packaged as `.dex` and executed by ART — a different runtime, with its own AOT/JIT hybrid execution and its own native `ArtMethod`/vtable/itable machinery, not HotSpot.
What static signal in a smali tree suggests a method is reached only through reflection?::A method that is declared somewhere in the tree but never appears as the explicit target of a direct `invoke-static`/`invoke-virtual`/`invoke-direct`/`invoke-interface` anywhere else — the set difference between "declared" and "directly called".
