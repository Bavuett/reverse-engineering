---
tags: [fundamentals]
aliases: [".method", "Smali constructor", "invoke-virtual", "invoke-direct"]
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
|---|---|
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
|---|---|---|
| `invoke-direct` | compile-time | constructors, `private` methods |
| `invoke-static` | compile-time | `static` methods |
| `invoke-virtual` | runtime, by actual object type | `public`/`protected` instance methods |
| `invoke-interface` | runtime, via interface method table | methods called through an interface reference |
| `invoke-super` | compile-time, but calls the *declared* superclass's implementation | `super.method()` calls |

> [!tip] Why so many `invoke-*` variants
> Static resolution (`invoke-direct`/`invoke-static`) is cheap: the target address is fixed at compile time. Dynamic resolution (`invoke-virtual`/`invoke-interface`) costs a vtable/itable lookup at runtime but is what makes polymorphism possible.

When a call site would need more than 5 registers (this + 4 arguments) to pass its arguments, smali switches to the `/range` variant instead of listing individual registers:

```smali
invoke-virtual/range {v0 .. v6}, LWidget;->configure(IIIIII)V
```

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
