---
tags: [example]
level: 1
aliases: ["const-class vs forName"]
created: 2026-11-12
---

# Example: Class-Literal-Vs-Class-ForName

> [!info] Level 1 — basics
> One idea: there are three ways to get a `Class` object, and only one of them hides the class name from static tools.

## Goal

Compare `X.class`, `Class.forName("…")`, and `obj.getClass()` in smali, and learn what each one reveals to a static reader and what each one does at runtime. Belongs to [[Reflection-and-Runtime-Internals]].

## Java source

```java
public class Loader {
    static void demo(Object obj) throws Exception {
        Class<?> a = java.util.ArrayList.class;
        Class<?> b = Class.forName("java.util.ArrayList");
        Class<?> c = obj.getClass();
        System.out.println(a == b && b == c);
    }
}
```

## Generated smali

```smali
.method static demo(Ljava/lang/Object;)V
    .locals 4
    const-class v0, Ljava/util/ArrayList;
    const-string v1, "java.util.ArrayList"
    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v1
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object p0
    sget-object v2, Ljava/lang/System;->out:Ljava/io/PrintStream;
    if-ne v0, v1, :cond_0
    if-ne v1, p0, :cond_0
    const/4 v3, 0x1
    goto :goto_0
    :cond_0
    const/4 v3, 0x0
    :goto_0
    invoke-virtual {v2, v3}, Ljava/io/PrintStream;->println(Z)V
    return-void
.end method
```

## Step by step

1. **`X.class` → `const-class`.** The class is named in a type reference (`Ljava/util/ArrayList;`), exactly like `new-instance` or `check-cast`. Every static tool — jadx's cross-references, R8's shrinker, `grep 'Ljava/util/ArrayList;'` — sees it. Not hidden at all.
2. **`Class.forName("…")` → a `const-string` + `invoke-static`.** The class name is just *data*: a dotted string (`java.util.ArrayList`, not `Ljava/util/ArrayList;`). A grep for the descriptor misses it, and if the string were computed or decrypted at runtime, nothing static could find it. This is the call that defeats static analysis ([[Reflection-and-Runtime-Internals]]).
3. **`obj.getClass()` → `invoke-virtual Object->getClass()`.** The class depends on the runtime object; statically you only know "whatever `p0` is".
4. **Different runtime side effects.** `const-class` loads the class but doesn't run its `<clinit>`; `Class.forName(String)` loads **and initializes** it, running static initializers ([[Static-Fields-And-Class-Initializer]]). Protectors sometimes exploit this: a `forName` on an innocuous-looking name can be how a hidden `<clinit>` gets triggered.
5. **Same object.** All three produce the same `Class` instance for the same class in the same class loader, which is why `a == b && b == c` prints `true`. The `==` on references is `if-ne` (reference inequality) — see [[If-Else-And-Comparisons]].
6. **Dotted vs slashed names** are a quick tell for what a string is *for*: `"java.util.ArrayList"` is destined for `forName`/`loadClass`; `"Ljava/util/ArrayList;"` or `"java/util/ArrayList"` is destined for JNI (`FindClass`).

## Compared with real code

- [[Private-Field-Access-Via-Reflection-In-PressReader]] — real reflection that starts from `const-class` (fully visible) and only hides the *field* name.
- [[Reflection-Hidden-Check-With-Decoded-Names]] — real reflection where both the class name passed to `forName` and the method name are decoded at runtime.

## See also

- [[Reflection-and-Runtime-Internals]]
- [[Reading-A-Private-Field-Reflectively]]
- [[Const-String]]
- [[Reflective-Hidden-Method-Call]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
