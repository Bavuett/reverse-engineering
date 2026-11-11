---
tags: [snippet, exercise]
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/bp/m1.smali"
difficulty: "★★"
skills: "desugared string concatenation, outlined calls, dead reads"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-03-Authentication-Block-Builder

## Context

`bp.m1.e(Service)` builds the `<service-name>…<authentication>…</authentication>` block that fills the second `%s` of the XML envelope (see [[Confirming-The-Outgoing-XML-Write-Path]]). It uses the helpers from [[Exercise-01-Outlined-StringBuilder-Helpers]] and [[Exercise-02-HttpURLConnection-Factory]]. `Service` is not obfuscated (`com.newspaperdirect.pressreader.android.core.Service`); its fields are. The class header is included so you can see `bp.m1`'s fields.

## Original path

`smali_classes2/bp/m1.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.class public final Lbp/m1;
.super Ljava/lang/Object;
.source "SourceFile"

# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lbp/m1$a;
    }
.end annotation

# static fields
.field public static final n:Llr/b;

.field public static final o:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field public static p:Ljava/lang/String;

.field public static q:Ljava/lang/Boolean;

.field public static final r:Ljava/util/LinkedList;

# instance fields
.field public final a:Ljava/lang/String;

.field public b:Ljava/lang/String;

.field public c:Z

.field public d:Z

.field public final e:Z

.field public final f:Landroid/sax/RootElement;

.field public final g:Landroid/sax/Element;

.field public final h:Ldx/b;

.field public i:Ldx/b;

.field public j:I

.field public k:Ljava/lang/String;

.field public final l:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Lcom/newspaperdirect/pressreader/android/devicemanagement/model/AccountDevice;",
            ">;"
        }
    .end annotation
.end field

.field public m:Ljava/lang/String;

.method public final e(Lcom/newspaperdirect/pressreader/android/core/Service;)Ljava/lang/String;
    .locals 7

    iget-boolean v0, p0, Lbp/m1;->c:Z

    if-eqz v0, :cond_1

    if-nez p1, :cond_0

    goto :goto_0

    :cond_0
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-virtual {p1}, Lcom/newspaperdirect/pressreader/android/core/Service;->f()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    iget-object v2, p1, Lcom/newspaperdirect/pressreader/android/core/Service;->j:Ljava/lang/String;

    invoke-static {v2}, Lbp/m1;->i(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    iget-object p1, p1, Lcom/newspaperdirect/pressreader/android/core/Service;->k:Ljava/lang/String;

    invoke-static {}, Ljq/t0;->e()Ljq/t0;

    move-result-object v3

    iget-object v3, v3, Ljq/t0;->A:Lvn/i;

    invoke-virtual {v3}, Lvn/i;->b()I

    move-result v3

    const-string v4, "<service-name>"

    const-string v5, "</service-name><authentication><user-name>"

    const-string v6, "</user-name><activation-number>"

    invoke-static {v4, v1, v5, v2, v6}, Landroidx/datastore/preferences/protobuf/e;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p1, "</activation-number><client-number>"

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, "</client-number></authentication>"

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p1, p0, Lbp/m1;->b:Ljava/lang/String;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    return-object p1

    :cond_1
    :goto_0
    iget-object p1, p0, Lbp/m1;->b:Ljava/lang/String;

    return-object p1
.end method
```

## Task

Rewrite `e` as a single Java method, expanding the outlined helper call inline.

## Check your reading

1. What is returned when `c` is false? When `service` is `null`?
2. `sget-object v1, Ljava/util/Locale;->US` is overwritten by the very next `move-result-object v1`. Why might a compiler keep a read whose value is never used?
3. Which of the three `Service` values is *not* passed through `i()`? Why could that matter for XML?
4. The client number is computed before any string constant is loaded. What source construct makes the compiler evaluate every dynamic part first and add the constants afterwards?

> [!tip]- Hints
> - `Ljq/t0;->e()` returns an app-wide singleton; `A` is one of its fields and `b()` reads an `int` from it.
> - `protobuf/e.c(s0, s1, s2, s3, s4)` is `new StringBuilder(s0).append(s1)…append(s4)`.

> [!success]- Solution
> ```java
> public final String e(Service service) {
>     if (!this.c || service == null) {
>         return this.b;
>     }
>     StringBuilder out = new StringBuilder();
>     String serviceName = i(service.f());
>     String userName = i(service.j);
>     String activationNumber = service.k;
>     int clientNumber = jq.t0.e().A.b();
>     out.append("<service-name>" + serviceName
>             + "</service-name><authentication><user-name>" + userName
>             + "</user-name><activation-number>" + activationNumber
>             + "</activation-number><client-number>" + clientNumber
>             + "</client-number></authentication>");
>     out.append(this.b);
>     return out.toString();
> }
> ```
>
> **Answers**
>
> 1. `this.b` in both cases: the two tests share the `:cond_1`/`:goto_0` exit.
> 2. Reading a static field can trigger class initialization, so a compiler that can't prove `Locale`'s initializer is side-effect free keeps the read even when the value is dead. It's residue of something optimized away — most likely an inlined call that used `Locale.US` — and this method alone doesn't say what. It doesn't change behavior.
> 3. `service.k`, the activation number, is appended raw. A value containing `<` or `&` would break the envelope or inject elements. [[Exercise-12-The-DQ-Request-Callable]] makes the same choice, so it's consistent rather than a one-off slip.
> 4. `+` concatenation compiled by javac 9 or later (an `invokedynamic` to `makeConcatWithConstants`), which D8 desugars back into a `StringBuilder` chain. All dynamic operands are evaluated and stored first, then the builder receives operands and constants interleaved. javac 8's older concatenation would interleave evaluation and appending instead.

## See also

- [[Smali-Exercises]]
- [[Sget-And-Sput]]
- [[Iget-And-Iput]]
- [[Dalvik-Bytecode-Reference|Reference]]
