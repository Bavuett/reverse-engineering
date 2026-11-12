---
tags: [snippet, exercise]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali/androidx/datastore/preferences/protobuf/e.smali, smali/androidx/car/app/a.smali"
difficulty: "★"
skills: "p registers in static methods, /2addr arithmetic, discarded results"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-01-Outlined-StringBuilder-Helpers

## Context

PressReader's XML request code calls two helpers that live in classes named `androidx.datastore.preferences.protobuf.e` and `androidx.car.app.a`. Neither belongs to those libraries: both classes are `final synthetic`, implement several unrelated interfaces, and switch on an `int` field `b` in their virtual methods — the shape of R8's merged lambda groups. R8 also parks small static fragments it extracted from many call sites (outlining) in classes like these. Only the static methods matter here.

## Original path

`smali/androidx/datastore/preferences/protobuf/e.smali` and `smali/androidx/car/app/a.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.method public static a(IIII)I
    .locals 0

    mul-int/2addr p0, p1

    div-int/2addr p0, p2

    add-int/2addr p0, p3

    return p0
.end method

.method public static b(ILjava/util/ArrayList;)Ljava/lang/Object;
    .locals 1

    invoke-virtual {p1}, Ljava/util/ArrayList;->size()I

    move-result v0

    sub-int/2addr v0, p0

    invoke-virtual {p1, v0}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method public static c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/StringBuilder;
    .locals 1

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0, p0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    return-object v0
.end method

.method public static b(Ljava/lang/StringBuilder;ILjava/lang/String;)Ljava/lang/String;
    .locals 0

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method
```

## Task

Rewrite all four static methods as Java, keeping the parameter order.

## Check your reading

1. None of these methods declares more than one local. Where do their arguments live, and why does `a` need no locals at all?
2. In `c`, every `append` returns a `StringBuilder`, yet no `move-result-object` follows. What does that tell you about the source?
3. In `b(ILjava/util/ArrayList;)`, which register is subtracted from, and what is subtracted?
4. `c` returns the builder without calling `toString()`. Where must its callers continue? (Two of them are `bp/m1.e`, in Exercise 03, and `um/u`.)

> [!tip]- Hints
> - A static method has no `this`: `p0` is the first declared parameter.
> - `mul-int/2addr A, B` means `A = A * B`.
> - A discarded return value is simply an `invoke-*` with no `move-result*` after it.

> [!success]- Solution
> ```java
> static int a(int x, int y, int z, int w) {
>     return x * y / z + w;
> }
>
> static Object b(int fromEnd, ArrayList list) {
>     return list.get(list.size() - fromEnd);
> }
>
> static StringBuilder c(String s0, String s1, String s2, String s3, String s4) {
>     StringBuilder sb = new StringBuilder(s0);
>     sb.append(s1);
>     sb.append(s2);
>     sb.append(s3);
>     sb.append(s4);
>     return sb;
> }
>
> static String b(StringBuilder sb, int i, String s) {
>     sb.append(i);
>     sb.append(s);
>     return sb.toString();
> }
> ```
>
> **Answers**
>
> 1. In `p0`–`p4`, the last registers of the frame. `a` works entirely in place in `p0` (`p0 = p0 * p1`, then `/ p2`, then `+ p3`), so it needs no scratch register; `b` and `c` need exactly one (`v0`).
> 2. Nothing reads the returned builder. That's `sb.append(x);` as separate statements — or a chain whose intermediate results R8 proved are the same object, since `StringBuilder.append` returns its receiver. Both look like this; bytecode can't tell them apart.
> 3. `v0` holds `list.size()`; `p0` is subtracted from it, and the result is reused in `v0` as the index.
> 4. Callers keep appending to the returned builder: `bp/m1.e` appends the activation number, `</activation-number><client-number>`, the client number, and the closing tags, then calls `toString()` itself.
>
> None of these were written as standalone helpers. They're fragments R8 factored out of many call sites, which is why their names mean nothing and they live in unrelated synthetic classes.

## See also

- [[Smali-Exercises]]
- [[Registers]] — `p` registers in static methods
- [[Arithmetic-And-Conversion-Opcodes]] — `/2addr` in-place arithmetic
- [[Invoke-Direct-Static-Virtual-Interface]]
- [[Move-Result]]
- [[Dalvik-Bytecode-Reference|Reference]]
