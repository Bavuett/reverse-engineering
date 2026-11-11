---
tags: [snippet, exercise]
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/mr/b.smali"
difficulty: "★★"
skills: "default-argument bitmask, checks before super()"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-04-Kotlin-Default-Argument-Constructor

## Context

`mr.b` is the request object handed to PressReader's newer, Kotlin XML client (`nr.c`, see [[Exercise-10-Synthetic-Lambda-And-Rx-Single]] and [[Exercise-12-The-DQ-Request-Callable]]). The `"requestBody"` string passed to `Intrinsics.checkNotNullParameter` is the only real name left in the class.

## Original path

`smali_classes2/mr/b.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.class public final Lmr/b;
.super Ljava/lang/Object;
.source "SourceFile"

# instance fields
.field public final a:Lmr/a;

.field public final b:Ljava/lang/String;

.field public final c:Ljava/lang/String;

.field public final d:Z

.field public final e:Z

.method public constructor <init>(Lmr/a;Ljava/lang/String;Ljava/lang/String;I)V
    .locals 0

    and-int/lit8 p4, p4, 0x4

    if-eqz p4, :cond_0

    const-string p3, ""

    :cond_0
    const-string p4, "requestBody"

    invoke-static {p3, p4}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lmr/b;->a:Lmr/a;

    iput-object p2, p0, Lmr/b;->b:Ljava/lang/String;

    iput-object p3, p0, Lmr/b;->c:Ljava/lang/String;

    const/4 p1, 0x1

    iput-boolean p1, p0, Lmr/b;->d:Z

    iput-boolean p1, p0, Lmr/b;->e:Z

    return-void
.end method
```

## Task

1. Write the Kotlin class declaration that most plausibly compiled to this.
2. Write the constructor as Java statements in exactly the order the bytecode executes them. It won't compile as classic Java — say why.

## Check your reading

1. What does `and-int/lit8 p4, p4, 0x4` test, and which parameter does bit `0x4` belong to?
2. What parameter normally follows the `int` in a Kotlin default-arguments constructor, and why might it be missing here?
3. Fields `d` and `e` are always set to `true`. Name two different Kotlin sources that compile to this.
4. Only `requestBody` gets a null check. What can and can't you conclude about the nullability of `a` and `b`?

> [!tip]- Hints
> - Kotlin's synthetic default-arguments constructor takes a bitmask: bit *n* set means "argument *n* wasn't passed, use its default".
> - Look at how [[Exercise-12-The-DQ-Request-Callable]] uses `Lmr/b;->a`: is it ever tested with `if-eqz`?

> [!success]- Solution
> ```kotlin
> class DqRequest(
>     val activation: DqActivation?,   // a: null-checked before every use in nr.b.call()
>     val type: String?,               // b: becomes <request type='%s'>
>     val requestBody: String = "",    // c: the only real name left
> ) {
>     val requiresAuthentication = true  // d: gates the <authentication> block
>     val includeClientInfo = true       // e: gates the <client-info> block
> }
> ```
>
> In bytecode order:
>
> ```java
> public DqRequest(DqActivation a, String b, String c, int defaults) {
>     if ((defaults & 0x4) != 0) c = "";
>     Intrinsics.checkNotNullParameter(c, "requestBody");
>     super();                          // Object.<init>
>     this.a = a;
>     this.b = b;
>     this.c = c;
>     this.d = true;
>     this.e = true;
> }
> ```
>
> Classic Java requires `super()` to be the first statement. Bytecode only forbids *using* `this` before it's initialized, so Kotlin can run parameter checks (and default substitution) first.
>
> **Answers**
>
> 1. Bit 2, counting from zero — the third parameter, `c`. When set, `p3` is replaced with `""` before anything else runs.
> 2. A trailing `DefaultConstructorMarker`, which only exists to keep the synthetic signature unique. Once R8 removed the unused non-default constructor and rewrote the callers, the marker was dead and was dropped too.
> 3. A property with an initializer in the class body (`val d = true`), or a constructor parameter `d: Boolean = true` that every caller left at its default, so R8 propagated the constant and deleted the parameter. The bytecode can't tell them apart.
> 4. Kotlin checks every non-null parameter of a public constructor, so the missing checks *suggest* `a` and `b` are nullable — but R8 can strip these checks, so their absence is weak evidence ([[Exercise-05-Kotlin-Data-Class-Reconstruction]] has a non-null property with no check at all). Use-site evidence is stronger: `nr.b.call()` null-checks `a` before each read, so `a` really is nullable. Nothing proves anything about `b`.
>
> `type`, `requiresAuthentication` and `includeClientInfo` are descriptive names taken from how Exercise 12 uses the fields, not recovered names.

## See also

- [[Smali-Exercises]]
- [[Methods]] — constructors and `<init>`
- [[Bitwise-Operations]]
- [[Dalvik-Bytecode-Reference|Reference]]
