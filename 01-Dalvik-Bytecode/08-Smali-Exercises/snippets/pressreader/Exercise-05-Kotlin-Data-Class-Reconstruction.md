---
tags: [snippet, exercise]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/mr/a.smali, smali_classes2/lr/a.smali"
difficulty: "★★"
skills: "generated equals/hashCode/toString, nullability evidence"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-05-Kotlin-Data-Class-Reconstruction

## Context

`mr.a` describes a device activation. Kotlin `data class`es generate `equals`, `hashCode` and `toString` from the primary constructor, and `toString` leaks the original property names: R8 renames fields, but not string constants.

## Original path

`smali_classes2/mr/a.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.class public final Lmr/a;
.super Ljava/lang/Object;
.source "SourceFile"

# instance fields
.field public final a:Ljava/lang/String;

.field public final b:Ljava/lang/String;

.field public final c:Ljava/lang/String;

.field public final d:Ljava/lang/String;

.field public final e:Z

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lmr/a;->a:Ljava/lang/String;

    iput-object p2, p0, Lmr/a;->b:Ljava/lang/String;

    iput-object p3, p0, Lmr/a;->c:Ljava/lang/String;

    iput-object p5, p0, Lmr/a;->d:Ljava/lang/String;

    iput-boolean p4, p0, Lmr/a;->e:Z

    return-void
.end method

.method public final equals(Ljava/lang/Object;)Z
    .locals 4

    const/4 v0, 0x1

    if-ne p0, p1, :cond_0

    return v0

    :cond_0
    instance-of v1, p1, Lmr/a;

    const/4 v2, 0x0

    if-nez v1, :cond_1

    return v2

    :cond_1
    check-cast p1, Lmr/a;

    iget-object v1, p1, Lmr/a;->a:Ljava/lang/String;

    iget-object v3, p0, Lmr/a;->a:Ljava/lang/String;

    invoke-static {v3, v1}, Lkotlin/jvm/internal/l;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_2

    return v2

    :cond_2
    iget-object v1, p0, Lmr/a;->b:Ljava/lang/String;

    iget-object v3, p1, Lmr/a;->b:Ljava/lang/String;

    invoke-static {v1, v3}, Lkotlin/jvm/internal/l;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_3

    return v2

    :cond_3
    iget-object v1, p0, Lmr/a;->c:Ljava/lang/String;

    iget-object v3, p1, Lmr/a;->c:Ljava/lang/String;

    invoke-static {v1, v3}, Lkotlin/jvm/internal/l;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_4

    return v2

    :cond_4
    iget-object v1, p0, Lmr/a;->d:Ljava/lang/String;

    iget-object v3, p1, Lmr/a;->d:Ljava/lang/String;

    invoke-static {v1, v3}, Lkotlin/jvm/internal/l;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_5

    return v2

    :cond_5
    iget-boolean v1, p0, Lmr/a;->e:Z

    iget-boolean p1, p1, Lmr/a;->e:Z

    if-eq v1, p1, :cond_6

    return v2

    :cond_6
    return v0
.end method

.method public final hashCode()I
    .locals 3

    iget-object v0, p0, Lmr/a;->a:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v0

    mul-int/lit8 v0, v0, 0x1f

    const/4 v1, 0x0

    iget-object v2, p0, Lmr/a;->b:Ljava/lang/String;

    if-nez v2, :cond_0

    move v2, v1

    goto :goto_0

    :cond_0
    invoke-virtual {v2}, Ljava/lang/String;->hashCode()I

    move-result v2

    :goto_0
    add-int/2addr v0, v2

    mul-int/lit8 v0, v0, 0x1f

    iget-object v2, p0, Lmr/a;->c:Ljava/lang/String;

    if-nez v2, :cond_1

    move v2, v1

    goto :goto_1

    :cond_1
    invoke-virtual {v2}, Ljava/lang/String;->hashCode()I

    move-result v2

    :goto_1
    add-int/2addr v0, v2

    mul-int/lit8 v0, v0, 0x1f

    iget-object v2, p0, Lmr/a;->d:Ljava/lang/String;

    if-nez v2, :cond_2

    goto :goto_2

    :cond_2
    invoke-virtual {v2}, Ljava/lang/String;->hashCode()I

    move-result v1

    :goto_2
    add-int/2addr v0, v1

    mul-int/lit8 v0, v0, 0x1f

    iget-boolean v1, p0, Lmr/a;->e:Z

    invoke-static {v1}, Ljava/lang/Boolean;->hashCode(Z)I

    move-result v1

    add-int/2addr v1, v0

    return v1
.end method

.method public final toString()Ljava/lang/String;
    .locals 3

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "DqActivation(serviceName="

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v1, p0, Lmr/a;->a:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", userName="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lmr/a;->b:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", activationNumber="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lmr/a;->c:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", serverUrl="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lmr/a;->d:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", isValid="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-boolean v1, p0, Lmr/a;->e:Z

    const/16 v2, 0x29

    invoke-static {v0, v1, v2}, Lbp/e3;->a(Ljava/lang/StringBuilder;ZC)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
```

## Task

Write the Kotlin `data class` with correct property names, declaration order, types and nullability.

## Check your reading

1. `Lbp/e3;->a(StringBuilder, Z, C)` is an outlined helper. What does it do, and what character is `0x29`?
2. The constructor descriptor is `(String, String, String, Z, String)`, but `toString` prints `serverUrl` before `isValid`. Which is the declaration order, and why?
3. For each of `a`–`d`: does `hashCode` null-check it? What does that tell you?
4. The constructor has no `checkNotNullParameter` calls at all, yet one property is non-null. Which one, how do you know, and what does that say about using missing checks as evidence?

> [!tip]- Hints
> - `bp/e3.a` is `sb.append(z); sb.append(c); return sb.toString();`.
> - A generated `hashCode` uses `x?.hashCode() ?: 0` for a nullable property and a plain call for a non-null one.

> [!success]- Solution
> ```kotlin
> data class DqActivation(
>     val serviceName: String,
>     val userName: String?,
>     val activationNumber: String?,
>     val serverUrl: String?,
>     val isValid: Boolean,
> )
> ```
>
> **Answers**
>
> 1. It appends a `boolean`, then a `char`, and returns `toString()`. `0x29` is `)`, closing `DqActivation(`.
> 2. `a, b, c, d, e` — the order `equals`, `hashCode` and `toString` all visit fields in, and all three are generated in primary-constructor order. The descriptor disagrees because `p4` (the boolean) is stored into `e` and `p5` into `d`: R8 rewrote the parameter order of a constructor whose every call site it controls (most likely to reuse an existing method prototype and shrink the dex). For declaration order, trust the generated members over the descriptor.
> 3. `a`: no, a direct `a.hashCode()` — non-null. `b`, `c`, `d`: yes, `if-nez` to a `0` fallback — nullable. `e` is a `boolean`, hashed with `Boolean.hashCode(Z)`.
> 4. `serviceName`: `hashCode` calls `a.hashCode()` without a guard, which a data class only generates for a non-null property. No parameter check survived anyway, so R8 (or a compiler flag such as `-Xno-param-assertions`) removed them. Missing checks are weak evidence; unguarded dereferences in generated code are strong evidence.
>
> `equals` compares `e` with `if-eq`, a primitive comparison, and the other properties with `Intrinsics.areEqual`, which is null-safe.

## Bonus

`lr.a` is the same exercise with nine properties, and its `hashCode` uses a different outlined helper, `Lb4/d;->a(IILjava/lang/String;)I`, for most of them. Reconstruct it too; its constructor keeps checks for some parameters and not others, which you can cross-check against `hashCode`'s null checks.

```smali
.class public final Llr/a;
.super Ljava/lang/Object;
.source "SourceFile"

# instance fields
.field public final a:Ljava/lang/String;

.field public final b:Ljava/lang/String;

.field public final c:Ljava/lang/String;

.field public final d:Ljava/lang/String;

.field public final e:Ljava/lang/String;

.field public final f:Ljava/lang/String;

.field public final g:Ljava/lang/String;

.field public final h:Ljava/lang/String;

.field public final i:I

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    .locals 1

    const-string v0, "codeVersion"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "systemManufacturer"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "systemModel"

    invoke-static {p4, v0}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "affiliation"

    invoke-static {p5, v0}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "serviceName"

    invoke-static {p6, v0}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "networkOperatorName"

    invoke-static {p8, v0}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Llr/a;->a:Ljava/lang/String;

    iput-object p2, p0, Llr/a;->b:Ljava/lang/String;

    iput-object p3, p0, Llr/a;->c:Ljava/lang/String;

    iput-object p4, p0, Llr/a;->d:Ljava/lang/String;

    iput-object p5, p0, Llr/a;->e:Ljava/lang/String;

    iput-object p6, p0, Llr/a;->f:Ljava/lang/String;

    iput-object p7, p0, Llr/a;->g:Ljava/lang/String;

    iput-object p8, p0, Llr/a;->h:Ljava/lang/String;

    iput p9, p0, Llr/a;->i:I

    return-void
.end method

.method public final hashCode()I
    .locals 4

    iget-object v0, p0, Llr/a;->a:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v0

    const/16 v1, 0x1f

    mul-int/2addr v0, v1

    const/4 v2, 0x0

    iget-object v3, p0, Llr/a;->b:Ljava/lang/String;

    if-nez v3, :cond_0

    move v3, v2

    goto :goto_0

    :cond_0
    invoke-virtual {v3}, Ljava/lang/String;->hashCode()I

    move-result v3

    :goto_0
    add-int/2addr v0, v3

    mul-int/2addr v0, v1

    iget-object v3, p0, Llr/a;->c:Ljava/lang/String;

    invoke-static {v0, v1, v3}, Lb4/d;->a(IILjava/lang/String;)I

    move-result v0

    iget-object v3, p0, Llr/a;->d:Ljava/lang/String;

    invoke-static {v0, v1, v3}, Lb4/d;->a(IILjava/lang/String;)I

    move-result v0

    iget-object v3, p0, Llr/a;->e:Ljava/lang/String;

    invoke-static {v0, v1, v3}, Lb4/d;->a(IILjava/lang/String;)I

    move-result v0

    iget-object v3, p0, Llr/a;->f:Ljava/lang/String;

    invoke-static {v0, v1, v3}, Lb4/d;->a(IILjava/lang/String;)I

    move-result v0

    iget-object v3, p0, Llr/a;->g:Ljava/lang/String;

    if-nez v3, :cond_1

    goto :goto_1

    :cond_1
    invoke-virtual {v3}, Ljava/lang/String;->hashCode()I

    move-result v2

    :goto_1
    add-int/2addr v0, v2

    mul-int/2addr v0, v1

    iget-object v2, p0, Llr/a;->h:Ljava/lang/String;

    invoke-static {v0, v1, v2}, Lb4/d;->a(IILjava/lang/String;)I

    move-result v0

    iget v1, p0, Llr/a;->i:I

    invoke-static {v1}, Ljava/lang/Integer;->hashCode(I)I

    move-result v1

    add-int/2addr v1, v0

    return v1
.end method

.method public final toString()Ljava/lang/String;
    .locals 3

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "GeneralAppInfo(codeVersion="

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v1, p0, Llr/a;->a:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", appVersion="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Llr/a;->b:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", systemManufacturer="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Llr/a;->c:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", systemModel="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Llr/a;->d:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", affiliation="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Llr/a;->e:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", serviceName="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Llr/a;->f:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", deviceUserName="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Llr/a;->g:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", networkOperatorName="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Llr/a;->h:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", clientNumber="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v1, p0, Llr/a;->i:I

    const/16 v2, 0x29

    invoke-static {v0, v1, v2}, Landroidx/activity/b;->a(Ljava/lang/StringBuilder;IC)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
```

> [!success]- Bonus solution
> ```kotlin
> data class GeneralAppInfo(
>     val codeVersion: String,          // checked
>     val appVersion: String?,          // no check; hashCode null-checks b
>     val systemManufacturer: String,   // checked
>     val systemModel: String,          // checked
>     val affiliation: String,          // checked
>     val serviceName: String,          // checked
>     val deviceUserName: String?,      // no check; hashCode null-checks g
>     val networkOperatorName: String,  // checked
>     val clientNumber: Int,
> )
> ```
>
> Here the descriptor order matches `toString`, and the two unchecked parameters are exactly the two `hashCode` guards against `null`: within one constructor, a check present for some parameters and missing for others *is* reliable evidence.

## See also

- [[Smali-Exercises]]
- [[Conditional-Branches]]
- [[Classes]] — fields and generated members
- [[Dalvik-Bytecode-Reference|Reference]]
