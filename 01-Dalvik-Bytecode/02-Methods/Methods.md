---
tags: [fundamentals]
aliases: [".method", "Smali constructor", "invoke-virtual", "invoke-direct", "vtable", "itable", "move-result", "invoke-virtual/range"]
---

# Methods

A method in smali is wrapped between `.method` and `.end method`. Inside, `.locals`/`.registers` (see [[Registers]]) declare the method's register workspace, and `.line` marks the corresponding source line (used to reconstruct stack traces).

## Anatomy of a method declaration

```smali
.method <access-flags> <name>(<param-types>)<return-type>
    .locals <N>           # local registers (see Registers)
    .line <source-line>   # optional, maps back to the original source
    <instructions...>
.end method
```

| Part | Meaning |
| --- | --- |
| `<access-flags>` | `public`, `private`, `protected`, `static`, `final`, `abstract`, `native`, `synchronized`, `constructor`, `bridge`, `varargs`, ... |
| `<name>` | method name; `<init>` for instance constructors, `<clinit>` for the static initializer |
| `(<param-types>)` | parameter type descriptors, concatenated with no separators — see [[Types]] |
| `<return-type>` | descriptor of the returned type, `V` for `void` |

### invoke-direct vs invoke-virtual vs invoke-interface

Method calls use different instruction families depending on how the callee is resolved (see [[Classes]] for the direct/virtual distinction):

```smali
# constructor / private / static method → invoke-direct / invoke-static
invoke-direct {p0}, Ljava/lang/Object;-><init>()V

# public instance method → invoke-virtual (dynamic dispatch)
invoke-virtual {p0, v1}, LPerson;->greet()Ljava/lang/String;

# method declared on an interface type → invoke-interface
invoke-interface {v0}, LDrawable;->draw()V

# explicit call to the superclass implementation (used inside an override)
invoke-super {p0}, LParent;->onCreate()V
```

| Instruction | Resolution | Typical target |
| --- | --- | --- |
| `invoke-direct` | compile-time | constructors, `private` methods |
| `invoke-static` | compile-time | `static` methods |
| `invoke-virtual` | runtime, by actual object type | `public`/`protected` instance methods |
| `invoke-interface` | runtime, via interface method table | methods called through an interface reference |
| `invoke-super` | compile-time, but calls the _declared_ superclass's implementation | `super.method()` calls |

> [!tip] What the vtable/itable actually are, and why so many `invoke-*` variants
>
> Every class gets a **vtable** (virtual method table) at compile/load time: an array of method pointers, one slot per virtual method. A subclass inherits its parent's slot layout and can only _override_ a slot (same index, new pointer) or _append_ new slots for methods it introduces itself — it can never reorder or drop one, since code compiled against the parent already assumes those indices. That's why `invoke-virtual` is cheap despite being "dynamic": resolving it is just "look up slot N in whatever vtable the object's actual runtime class has", a single array read, regardless of how deep the class hierarchy is.
>
> Interfaces don't fit that scheme. Unrelated classes can each implement the same interface and place its methods at completely different vtable slots (there's no common ancestor to agree on a shared layout with), and a single class can implement several interfaces at once. So an interface call can't be a fixed-offset lookup — instead every class also carries an **itable** (interface method table), indexed by interface method rather than by a single shared numeric slot. `invoke-interface` pays for that extra indirection over the itable; `invoke-virtual` avoids it because single-inheritance class hierarchies can share one flat vtable.
>
> Static resolution (`invoke-direct`/`invoke-static`) skips both tables entirely: the target address is baked in at compile time, since there's no overriding to account for.

### Getting the return value: `move-result`

`invoke-*` instructions never name a destination register — their register list (`{p0, v1}` above) is only the _arguments_. Whatever the callee returns is instead placed in an implicit, VM-internal "result" slot right after the call returns, and the _next_ instruction — only if the value is actually needed — reads it out into a real register:

```smali
invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
move-result-object v0    # v0 now holds the returned String
```

Pick the variant matching the return type: `move-result` for a single 32-bit value (`int`, `float`, ...), `move-result-wide` for a 64-bit value (`long`, `double`), `move-result-object` for any reference type. Calling a `void` method needs none of these; likewise if the caller doesn't need a non-`void` result, the `move-result*` is simply omitted and the value in the implicit slot is never read.

### `invoke-*/range`: same call, a different argument encoding

Every `invoke-*` instruction shown above (`invoke-direct {p0, v1}, ...`) uses a compact encoding that has room for at most 5 argument registers, each referenced with only 4 bits — so it can only name registers `v0`-`v15`. A call that needs more arguments than that, or whose arguments happen to live in a register numbered above 15 (common in methods with large `.registers` counts), can't be expressed in that compact form at all.

`invoke-direct/range`, `invoke-static/range`, `invoke-virtual/range`, `invoke-interface/range`, and `invoke-super/range` are the same five instruction families, just with a wider encoding: instead of listing each argument register individually, they take a single *starting* register and a count, and the arguments are simply "the next N registers from there":

```smali
invoke-virtual/range {v0 .. v6}, LWidget;->configure(IIIIII)V
```

This still passes 7 values (`this` = `v0`, plus 6 `int` arguments in `v1`-`v6`) to `configure`, exactly like the non-range form would — resolution (`invoke-virtual` still does a vtable lookup), the surrounding `move-result*`, everything is identical. The only real constraint the `/range` form imposes is that the argument registers must be *consecutive*: `{v0 .. v6}` is valid, but there is no way to say "`v0`, then `v10`, then `v3`" in range form. Because of that, when the compiler needs `/range`, it typically also emits extra `move`/`move-object` instructions beforehand to shuffle the actual argument values into a contiguous block of registers first, purely so the call can be encoded — that shuffling has no effect on what gets called or what it does, only on how the instruction stream lays out the argument registers.

In short: `/range` is only a wider envelope for the same call — never a different resolution rule, never a different target. `baksmali` picks whichever form the raw bytecode actually used, so seeing `/range` in a disassembly just means the original call needed more than 5 registers or ones numbered above 15, nothing more.

### Abstract and native methods

Abstract methods have no body — no instructions, no `.locals`, straight to `.end method`:

```smali
.method public abstract draw()V
.end method
```

Native methods likewise have no smali body, since their implementation lives in a JNI library:

```smali
.method public native nativeCompute(I)I
.end method
```

### Synchronized methods

```smali
.method public declared-synchronized transfer(D)V
    .locals 2
    ...
.end method
```

`declared-synchronized` marks the method as if it were wrapped in `synchronized(this) { ... }` (or the class object, for `static` methods). The actual locking is expressed explicitly with the `monitor-enter`/`monitor-exit` instructions — see [[Dalvik-Instructions|Instructions]].

### Exception handling: `.catch`

```smali
.method public parse(Ljava/lang/String;)I
    .locals 1
    .catch Ljava/lang/NumberFormatException; {:try_start .. :try_end} :catch_block

    :try_start
    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v0
    goto :end
    :try_end

    :catch_block
    const/4 v0, -0x1

    :end
    return v0
.end method
```

`.catch <exception-type> {:start .. :end} :handler` declares a protected region: if the exception (or a subtype of it) is thrown between `:start` and `:end`, execution jumps to `:handler`. `.catchall` behaves the same way but catches any `Throwable`, matching a Java `catch (Throwable t)` or a `finally` block compiled into duplicated cleanup code.

### Constructors and the value returned by a function call

The letter placed right after a method's signature — or right after an invocation — is its type descriptor (`V` in the examples above): see [[Types]] for the full table. A constructor's own declared return type is always `V`, since Java constructors have no return value; what constructors actually initialize is the object referenced by `p0`.

```smali
.method public constructor <init>()V
    .locals 0
    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method
```

### Method with parameters and a return value

```java
public int sum(int a, int b) {
    return a + b;
}
```

```smali
.method public sum(II)I
    .locals 1
    .line 10
    add-int v0, p1, p2
    return v0
.end method
```

`(II)I` — two `int` parameters and an `int` return value; `p1` and `p2` are the parameters (`p0` would be `this`, see [[Registers]]).

### Static initializer: `<clinit>`

```smali
.method static constructor <clinit>()V
    .locals 1
    const/4 v0, 0x0
    sput v0, LCounter;->total:I
    return-void
.end method
```

A Java static block (`static { ... }`) compiles down to the special method `<clinit>`, executed exactly once when the class is first loaded.

## More examples

- [[Method-with-Parameters]] — multiple parameter types and a reference return type
- [[Exception-Handling]] — `.catch`/`.catchall` in practice

Real-world fragments illustrating this chapter (once added) live in `snippets/` — see [[Demo-Example-Class]] for the expected format.

## See also

- [[Classes]] — where methods are declared (direct/virtual)
- [[Registers]] — `p0`/`this`, parameters, and local registers
- [[Types]] — type descriptors used in signatures
- [[Dalvik-Instructions|Instructions]] — the instruction families mentioned above in detail

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]

## Flashcards
#flashcards

Which special method name is reserved for the instance constructor, and which for the static initializer?::`<init>` for the instance constructor, `<clinit>` for the static initializer.
Why does `invoke-super` resolve at compile time even though it calls an instance method?::Because it always targets the exact superclass implementation named in the instruction, bypassing dynamic dispatch on the object's actual runtime type.
What does `.catch Lexception; {:start .. :end} :handler` declare?::A protected code region: if the given exception type (or a subtype) is thrown between `:start` and `:end`, execution transfers to `:handler`.
Why is `invoke-interface` slower to resolve than `invoke-virtual`, even though both are "dynamic"?::`invoke-virtual` looks up a fixed slot in the object's class's vtable (shared across the single-inheritance hierarchy), while `invoke-interface` must go through the itable, since unrelated classes implementing the same interface can place its methods at different slots.
Why doesn't `invoke-virtual {p0, v1}, LPerson;->greet()Ljava/lang/String;` name a register to receive the returned `String`?::Because `invoke-*` instructions never carry a destination register; the return value lands in an implicit VM-internal slot that the following `move-result-object` (or `move-result`/`move-result-wide`) instruction must explicitly read out — and can simply be omitted if the value isn't needed.
Does `invoke-virtual/range` call a different method, or resolve differently, compared to plain `invoke-virtual`?::No — it's the exact same instruction family and resolution (still a vtable lookup); `/range` only changes how the argument registers are encoded, using a start register + count instead of listing each one, because it can address more than 5 arguments and registers above `v15`. The arguments it names must be consecutive.
