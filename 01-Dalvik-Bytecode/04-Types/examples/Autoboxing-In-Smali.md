---
tags: [example]
level: 1
aliases: ["Boxing and unboxing smali"]
created: 2026-11-12
---

# Example: Autoboxing-In-Smali

> [!info] Level 1 — basics
> One idea: autoboxing is invisible in Java source but always explicit in smali — `Integer.valueOf` going in, `check-cast` + `intValue` coming out.

## Goal

Show the instructions the compiler inserts when a primitive goes into a generic collection and comes back out, so these calls are recognized as conversions rather than logic. Belongs to [[Types]].

## Java source

```java
import java.util.ArrayList;
import java.util.List;

public class Scores {
    static int firstPlusOne() {
        List<Integer> xs = new ArrayList<>();
        xs.add(5);
        int first = xs.get(0);
        return first + 1;
    }
}
```

## Generated smali

```smali
.method static firstPlusOne()I
    .locals 2
    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    const/4 v1, 0x5
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v1
    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    const/4 v1, 0x0
    invoke-interface {v0, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/lang/Integer;
    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I
    move-result v0

    add-int/lit8 v0, v0, 0x1
    return v0
.end method
```

## Step by step

1. **Boxing**: `xs.add(5)` needs an `Object`, so `5` becomes `Integer.valueOf(5)`. The same pattern exists for every primitive: `Boolean.valueOf(Z)`, `Long.valueOf(J)`, `Double.valueOf(D)`, …
2. **Erased signature at the call**: the call is `List->add(Ljava/lang/Object;)Z`, not `add(Integer)`. Generic methods are always called with their erased descriptor (see [[Primitive-And-Reference-Descriptors]]).
3. **`add` returns a `boolean` that nobody reads**, so there's no `move-result` after it. A call without `move-result` means the return value was discarded.
4. **Unboxing is two steps**: `get` returns `Object`; `check-cast` to `Integer` restores the generic type argument; `intValue()` extracts the primitive. The `check-cast` is the only place in the bytecode where `List<Integer>`'s `Integer` is still visible — when reversing, the cast after a `get`/`next`/`getValue` call tells you the collection's element type.
5. **Register reuse across types**: `v0` holds an `ArrayList`, then an `Object`, then an `Integer`, then an `int`; `v1` holds an `int`, then an `Integer`, then an `int` again. The register says nothing about type — the last instruction that wrote it does ([[Registers]]).
6. `invoke-interface` (not `invoke-virtual`) because `xs` is declared as `List`, an interface. Had it been declared `ArrayList<Integer> xs`, the calls would be `invoke-virtual … ArrayList->add`.

## Compared with real code

PressReader's `RecyclerViewPager.onRestoreInstanceState` boxes an `int` for exactly this reason — `Field.set(Object, Object)` only accepts objects:

```smali
invoke-virtual {v3, v0}, Ljava/lang/reflect/Field;->getInt(Ljava/lang/Object;)I
move-result v4
sub-int/2addr v4, v1
invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
move-result-object v1
invoke-virtual {v3, v0, v1}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V
```

The whole method is dissected in [[Private-Field-Access-Via-Reflection-In-PressReader]].

## See also

- [[Types]]
- [[New-Instance-And-Check-Cast]]
- [[Invoke-Direct-Static-Virtual-Interface]]
- [[Generics-Erasure-And-Signature-Annotations]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
