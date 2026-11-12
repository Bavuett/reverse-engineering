---
tags: [snippet, exercise]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/nr/b.smali, smali_classes2/nr/c.smali"
difficulty: "★★"
skills: "desugared lambdas, staticized instance methods"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-10-Synthetic-Lambda-And-Rx-Single

## Context

`nr.c`, PressReader's Kotlin XML client, exposes each request as an RxJava `Single`. D8 compiles every lambda into a small synthetic class whose fields are the captured values. `nr.b` is that class for the request lambda; its `call()` body is [[Exercise-12-The-DQ-Request-Callable]]. `La10/p;` is `SingleFromCallable`, and `Ll00/w;->p` is `subscribeOn`.

## Original path

`smali_classes2/nr/b.smali` and `smali_classes2/nr/c.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.class public final synthetic Lnr/b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/util/concurrent/Callable;

# instance fields
.field public final synthetic b:Lnr/c;

.field public final synthetic c:Lmr/b;

.field public final synthetic d:Ljava/lang/String;

.method public synthetic constructor <init>(Lnr/c;Lmr/b;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lnr/b;->b:Lnr/c;

    iput-object p2, p0, Lnr/b;->c:Lmr/b;

    iput-object p3, p0, Lnr/b;->d:Ljava/lang/String;

    return-void
.end method

.method public static b(Lnr/c;Lmr/b;)La10/v;
    .locals 2

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    new-instance v0, Lnr/b;

    const/4 v1, 0x0

    invoke-direct {v0, p0, p1, v1}, Lnr/b;-><init>(Lnr/c;Lmr/b;Ljava/lang/String;)V

    new-instance p0, La10/p;

    invoke-direct {p0, v0}, La10/p;-><init>(Ljava/util/concurrent/Callable;)V

    sget-object p1, Lj10/a;->c:Ll00/v;

    invoke-virtual {p0, p1}, Ll00/w;->p(Ll00/v;)La10/v;

    move-result-object p0

    return-object p0
.end method
```

## Task

1. Write the Kotlin source for `nr.c.b`, including the lambda, with the lambda body as `TODO()`.
2. Say what each of `nr.b`'s three fields captures.

## Check your reading

1. `nr.c.b` is `static`, yet it takes an `nr.c` first and immediately calls `getClass()` on it. What was it before R8?
2. The third captured value is always `null` here. What kind of source parameter explains that?
3. Why do the class and its fields carry the `synthetic` flag?
4. `Lj10/a;->c` is one of four static `Scheduler`s. Which one would you expect for a network call, and how would you confirm it from the smali?

> [!tip]- Hints
> - Dalvik has no bytecode-level lambdas: a captured variable becomes a constructor argument and a field.
> - Compare the `getClass()` here with answer 4 of [[Exercise-09-Sparse-Switch-On-String-Hash]].

> [!success]- Solution
> ```kotlin
> class DqClient(/* Exercise 12 */) {
>     fun send(request: DqRequest, url: String? = null): Single<DqResponse> =
>         Single.fromCallable<DqResponse> { TODO("Exercise 12") }   // captures this, request, url
>             .subscribeOn(Schedulers.io())
> }
> ```
>
> `nr.b.b` is the enclosing `DqClient` (`this`), `nr.b.c` is `request`, and `nr.b.d` is `url`.
>
> **Answers**
>
> 1. An instance method `send(request)` of `nr.c`. R8 "staticized" it, turning `this` into an explicit first parameter, and kept a `getClass()` so a null receiver still throws the same `NullPointerException` the virtual call would have.
> 2. A parameter with a default value (`url: String? = null`) that these callers never pass. R8 propagated the constant into this variant; the lambda still captures it as a field.
> 3. They're compiler-generated and have no source counterpart. `synthetic` tells tools and reflection not to present them as user code.
> 4. `Schedulers.io()`. `smali_classes2/j10/a.smali`'s `<clinit>` initializes its fields in exactly the order of RxJava's `Schedulers` static initializer: `a` (SINGLE), `b` (COMPUTATION), `c` (IO), then a dead `sget` of `Lc10/o;->c` where TRAMPOLINE's `TrampolineScheduler.instance()` would be, then `d` (NEW_THREAD). Each of the four is built from its own `Callable` (`j10/a$h`, `$b`, `$c`, `$f`) passed to the same plugin hook, which is RxJava's `initXScheduler(new XTask())` pattern.

## See also

- [[Smali-Exercises]]
- [[Classes]] — synthetic classes
- [[Invoke-Direct-Static-Virtual-Interface]]
- [[Dalvik-Bytecode-Reference|Reference]]
