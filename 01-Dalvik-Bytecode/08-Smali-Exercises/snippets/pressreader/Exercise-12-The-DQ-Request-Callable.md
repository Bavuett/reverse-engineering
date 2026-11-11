---
tags: [snippet, exercise]
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/nr/c.smali, smali_classes2/nr/b.smali"
difficulty: "★★★★★"
skills: "inlined Kotlin and OkHttp code, long-range register tracking, synchronized blocks, envelope reconstruction"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-12-The-DQ-Request-Callable

## Context

`nr.c` is the Kotlin/OkHttp rewrite of `bp.m1`. It sends the same `<nd version='1.0'>` envelope with the same `<authentication>` block, but over OkHttp, and it parses the reply into the `dx.b` XML tree instead of feeding a SAX handler. Part A is its constructor. Part B is the request lambda from [[Exercise-10-Synthetic-Lambda-And-Rx-Single]]: about 300 instructions, and the reason every earlier exercise exists.

What you already know:

- **`nr.c` fields:**
  - `a`: `lr.b`, the URL resolver ([[Exercise-06-Static-Monitors-And-Iterators]])
  - `b`: `kr.a`, which wraps a `ConnectivityManager` in its field `a`
  - `c`: `nr.d` ([[Exercise-08-Server-Mode-Map-Constructor]])
  - `d`: `lr.a`, `GeneralAppInfo` ([[Exercise-05-Kotlin-Data-Class-Reconstruction]]'s bonus)
  - `e`: push id
  - `f`: `Locale`
  - `g`: package name
  - `h`: `OkHttpClient`
- **Request types:** `mr.b` is [[Exercise-04-Kotlin-Default-Argument-Constructor]]; `mr.a` is [[Exercise-05-Kotlin-Data-Class-Reconstruction]].
- **Result types:** `mr.c(g)` wraps a result (`DqResponse`). `mr.e(dx.b, nr.a)` is `Success(xml, dqCommand)` and `mr.d(Exception)` is the error case; both extend the sealed base class misnamed `androidx.datastore.preferences.protobuf.g`.
- **Helpers:** `nr.c.a` is `parseCommand` ([[Exercise-09-Sparse-Switch-On-String-Hash]]); the `dx.b` API is described there too.

## Original path

`smali_classes2/nr/c.smali` and `smali_classes2/nr/b.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

### Part A: `nr.c`'s constructor

```smali
.class public final Lnr/c;
.super Ljava/lang/Object;
.source "SourceFile"

# instance fields
.field public final a:Llr/b;

.field public final b:Lkr/a;

.field public final c:Lnr/d;

.field public final d:Llr/a;

.field public final e:Ljava/lang/String;

.field public final f:Ljava/util/Locale;

.field public final g:Ljava/lang/String;

.field public final h:Lw50/u;

.method public constructor <init>(Landroid/content/Context;Llr/b;Lkr/a;Lnr/d;Llr/a;Ljava/lang/String;Ljava/util/Locale;Ljava/lang/String;Luo/d;)V
    .locals 1

    const-string v0, "pushId"

    invoke-static {p6, v0}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lnr/c;->a:Llr/b;

    iput-object p3, p0, Lnr/c;->b:Lkr/a;

    iput-object p4, p0, Lnr/c;->c:Lnr/d;

    iput-object p5, p0, Lnr/c;->d:Llr/a;

    iput-object p6, p0, Lnr/c;->e:Ljava/lang/String;

    iput-object p7, p0, Lnr/c;->f:Ljava/util/Locale;

    iput-object p8, p0, Lnr/c;->g:Ljava/lang/String;

    new-instance p2, Lw50/u$a;

    invoke-direct {p2}, Lw50/u$a;-><init>()V

    sget-object p3, Ljava/util/concurrent/TimeUnit;->MILLISECONDS:Ljava/util/concurrent/TimeUnit;

    const-string p4, "unit"

    invoke-static {p3, p4}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-wide/16 p4, 0x7530

    invoke-static {p4, p5, p3}, Lx50/b;->b(JLjava/util/concurrent/TimeUnit;)I

    move-result p6

    iput p6, p2, Lw50/u$a;->r:I

    invoke-static {p4, p5, p3}, Lx50/b;->b(JLjava/util/concurrent/TimeUnit;)I

    move-result p6

    iput p6, p2, Lw50/u$a;->s:I

    invoke-static {p4, p5, p3}, Lx50/b;->b(JLjava/util/concurrent/TimeUnit;)I

    move-result p3

    iput p3, p2, Lw50/u$a;->t:I

    new-instance p3, Li60/a;

    invoke-direct {p3, p9}, Li60/a;-><init>(Li60/a$b;)V

    sget-object p4, Li60/a$a;->BODY:Li60/a$a;

    const-string p5, "level"

    invoke-static {p4, p5}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    iput-object p4, p3, Li60/a;->b:Li60/a$a;

    iget-object p4, p2, Lw50/u$a;->c:Ljava/util/ArrayList;

    invoke-virtual {p4, p3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    new-instance p3, Lw50/u;

    invoke-direct {p3, p2}, Lw50/u;-><init>(Lw50/u$a;)V

    iput-object p3, p0, Lnr/c;->h:Lw50/u;

    :try_start_0
    const-string p2, "TLS"

    invoke-static {p2}, Ljavax/net/ssl/SSLContext;->getInstance(Ljava/lang/String;)Ljavax/net/ssl/SSLContext;
    :try_end_0
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception p2

    sget-object p3, Lj70/a;->a:Lj70/a$a;

    invoke-virtual {p3, p2}, Lj70/a$a;->d(Ljava/lang/Throwable;)V

    :try_start_1
    invoke-static {p1}, Luc/a;->a(Landroid/content/Context;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_0

    :catch_1
    move-exception p1

    sget-object p2, Lj70/a;->a:Lj70/a$a;

    const-string p3, "ProvideInstaller"

    invoke-virtual {p2, p3}, Lj70/a$a;->n(Ljava/lang/String;)V

    invoke-virtual {p2, p1}, Lj70/a$a;->d(Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method
```

### Part B: the request lambda

```smali
.method public final call()Ljava/lang/Object;
    .locals 14

    iget-object v0, p0, Lnr/b;->b:Lnr/c;

    iget-object v1, p0, Lnr/b;->c:Lmr/b;

    iget-object v2, p0, Lnr/b;->d:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    const-string v3, "request"

    invoke-static {v1, v3}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const/4 v3, 0x1

    invoke-static {v3}, Landroid/net/TrafficStats;->setThreadStatsTag(I)V

    iget-boolean v4, v1, Lmr/b;->d:Z

    if-eqz v4, :cond_1

    iget-object v4, v1, Lmr/b;->a:Lmr/a;

    if-eqz v4, :cond_1

    iget-boolean v4, v4, Lmr/a;->e:Z

    if-eqz v4, :cond_0

    goto :goto_0

    :cond_0
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Service is not valid"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_1
    :goto_0
    iget-object v4, v0, Lnr/c;->b:Lkr/a;

    iget-object v4, v4, Lkr/a;->a:Landroid/net/ConnectivityManager;

    invoke-virtual {v4}, Landroid/net/ConnectivityManager;->getActiveNetwork()Landroid/net/Network;

    move-result-object v5

    if-eqz v5, :cond_14

    invoke-virtual {v4, v5}, Landroid/net/ConnectivityManager;->getNetworkCapabilities(Landroid/net/Network;)Landroid/net/NetworkCapabilities;

    move-result-object v4

    if-eqz v4, :cond_14

    invoke-virtual {v4, v3}, Landroid/net/NetworkCapabilities;->hasTransport(I)Z

    move-result v3

    const/4 v5, 0x2

    const/4 v6, 0x0

    if-eqz v3, :cond_2

    goto :goto_1

    :cond_2
    invoke-virtual {v4, v6}, Landroid/net/NetworkCapabilities;->hasTransport(I)Z

    move-result v3

    if-eqz v3, :cond_3

    goto :goto_1

    :cond_3
    const/4 v3, 0x3

    invoke-virtual {v4, v3}, Landroid/net/NetworkCapabilities;->hasTransport(I)Z

    move-result v3

    if-eqz v3, :cond_4

    goto :goto_1

    :cond_4
    invoke-virtual {v4, v5}, Landroid/net/NetworkCapabilities;->hasTransport(I)Z

    move-result v3

    if-eqz v3, :cond_14

    :goto_1
    invoke-static {v2}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v3

    const/4 v4, 0x0

    if-eqz v3, :cond_a

    iget-object v2, v1, Lmr/b;->a:Lmr/a;

    if-eqz v2, :cond_5

    iget-object v3, v2, Lmr/a;->d:Ljava/lang/String;

    goto :goto_2

    :cond_5
    move-object v3, v4

    :goto_2
    invoke-static {v3}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v3

    if-nez v3, :cond_7

    if-eqz v2, :cond_6

    iget-object v2, v2, Lmr/a;->d:Ljava/lang/String;

    goto :goto_5

    :cond_6
    move-object v2, v4

    goto :goto_5

    :cond_7
    iget-object v2, v0, Lnr/c;->a:Llr/b;

    monitor-enter v2

    :goto_3
    :try_start_0
    iget-object v3, v0, Lnr/c;->a:Llr/b;

    invoke-interface {v3}, Llr/b;->isRunning()Z

    move-result v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v3, :cond_8

    :try_start_1
    iget-object v3, v0, Lnr/c;->a:Llr/b;

    const-string v7, "<this>"

    invoke-static {v3, v7}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-wide/32 v7, 0xea60

    invoke-virtual {v3, v7, v8}, Ljava/lang/Object;->wait(J)V
    :try_end_1
    .catch Ljava/lang/InterruptedException; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_3

    :catchall_0
    move-exception v0

    goto :goto_4

    :catch_0
    move-exception v3

    :try_start_2
    sget-object v7, Lj70/a;->a:Lj70/a$a;

    invoke-virtual {v7, v3}, Lj70/a$a;->d(Ljava/lang/Throwable;)V

    goto :goto_3

    :cond_8
    sget-object v3, Ln10/t;->a:Ln10/t;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    monitor-exit v2

    iget-object v2, v0, Lnr/c;->a:Llr/b;

    iget-object v3, v0, Lnr/c;->c:Lnr/d;

    iget-object v7, v3, Lnr/d;->c:Ljava/util/Map;

    iget-object v3, v3, Lnr/d;->b:Ljava/lang/String;

    invoke-interface {v7, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    if-nez v3, :cond_9

    const-string v3, ""

    :cond_9
    invoke-interface {v2, v3}, Llr/b;->a(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    goto :goto_5

    :goto_4
    monitor-exit v2

    throw v0

    :cond_a
    :goto_5
    if-nez v2, :cond_b

    new-instance v0, Lmr/c;

    new-instance v1, Lmr/d;

    new-instance v2, Ljava/io/IOException;

    const-string v3, "No server url"

    invoke-direct {v2, v3}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    invoke-direct {v1, v2}, Lmr/d;-><init>(Ljava/lang/Exception;)V

    invoke-direct {v0, v1}, Lmr/c;-><init>(Landroidx/datastore/preferences/protobuf/g;)V

    goto/16 :goto_c

    :cond_b
    new-instance v3, Lw50/w$a;

    invoke-direct {v3}, Lw50/w$a;-><init>()V

    invoke-virtual {v3, v2}, Lw50/w$a;->g(Ljava/lang/String;)V

    iget-object v2, v0, Lnr/c;->d:Llr/a;

    iget-object v7, v0, Lnr/c;->e:Ljava/lang/String;

    iget-object v8, v0, Lnr/c;->f:Ljava/util/Locale;

    iget-object v9, v0, Lnr/c;->g:Ljava/lang/String;

    const-string v10, "generalInfo"

    invoke-static {v2, v10}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v10, "pushId"

    invoke-static {v7, v10}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v10, "locale"

    invoke-static {v8, v10}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v10, "packageName"

    invoke-static {v9, v10}, Lkotlin/jvm/internal/l;->f(Ljava/lang/Object;Ljava/lang/String;)V

    iget-boolean v10, v1, Lmr/b;->e:Z

    if-eqz v10, :cond_c

    new-instance v10, Ljava/lang/StringBuilder;

    const-string v11, "<?xml version=\'1.0\' encoding=\'UTF-8\'?><nd version=\'1.0\'><client-info><software>PRAndroid</software><version>"

    invoke-direct {v10, v11}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v11, v2, Llr/a;->a:Ljava/lang/String;

    invoke-static {v11}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v11, "</version><app-version>"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v11, v2, Llr/a;->b:Ljava/lang/String;

    invoke-static {v11}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v11, "</app-version><client-type>PC</client-type><client-subtype>Tablet</client-subtype><system-manufacturer>"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v11, v2, Llr/a;->c:Ljava/lang/String;

    invoke-static {v11}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v11, "</system-manufacturer><system-model>"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v11, v2, Llr/a;->d:Ljava/lang/String;

    invoke-static {v11}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v11, "</system-model><installkey1>"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v11, v2, Llr/a;->e:Ljava/lang/String;

    invoke-static {v11}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v11, "</installkey1><client-locale-language>"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v8}, Ljava/util/Locale;->getLanguage()Ljava/lang/String;

    move-result-object v11

    invoke-static {v11}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v11, "</client-locale-language><client-locale-country>"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v8}, Ljava/util/Locale;->getCountry()Ljava/lang/String;

    move-result-object v11

    invoke-static {v11}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v11, "</client-locale-country><client-locale-variant>"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v8}, Ljava/util/Locale;->getVariant()Ljava/lang/String;

    move-result-object v8

    invoke-static {v8}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v8, "</client-locale-variant><application-id>"

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {v9}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v8, "</application-id><default-service-name>"

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v8, v2, Llr/a;->f:Ljava/lang/String;

    invoke-static {v8}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v8, "</default-service-name><device-token>"

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {v7}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v10, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v7, "</device-token></client-info><request id=\'0\' type=\'%s\'>%s</request></nd>"

    invoke-virtual {v10, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    goto :goto_6

    :cond_c
    const-string v7, "<?xml version=\'1.0\' encoding=\'UTF-8\'?><nd version=\'1.0\'><request id=\'0\' type=\'%s\'>%s</request></nd>"

    :goto_6
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    iget-boolean v9, v1, Lmr/b;->d:Z

    const-string v10, ""

    if-eqz v9, :cond_10

    new-instance v9, Ljava/lang/StringBuilder;

    const-string v10, "<service-name>"

    invoke-direct {v9, v10}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v10, v1, Lmr/b;->a:Lmr/a;

    if-eqz v10, :cond_d

    iget-object v11, v10, Lmr/a;->a:Ljava/lang/String;

    goto :goto_7

    :cond_d
    move-object v11, v4

    :goto_7
    invoke-static {v11}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v9, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v11, "</service-name><authentication><user-name>"

    invoke-virtual {v9, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    if-eqz v10, :cond_e

    iget-object v11, v10, Lmr/a;->b:Ljava/lang/String;

    goto :goto_8

    :cond_e
    move-object v11, v4

    :goto_8
    invoke-static {v11}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v9, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v11, "</user-name><activation-number>"

    invoke-virtual {v9, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    if-eqz v10, :cond_f

    iget-object v10, v10, Lmr/a;->c:Ljava/lang/String;

    goto :goto_9

    :cond_f
    move-object v10, v4

    :goto_9
    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v10, "</activation-number><client-number>"

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v2, v2, Llr/a;->i:I

    const-string v10, "</client-number></authentication>"

    invoke-static {v9, v2, v10}, Landroidx/car/app/a;->b(Ljava/lang/StringBuilder;ILjava/lang/String;)Ljava/lang/String;

    move-result-object v10

    :cond_10
    invoke-virtual {v8, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v2, v1, Lmr/b;->c:Ljava/lang/String;

    invoke-virtual {v8, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    iget-object v1, v1, Lmr/b;->b:Ljava/lang/String;

    filled-new-array {v1, v2}, [Ljava/lang/Object;

    move-result-object v1

    invoke-static {v1, v5}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;

    move-result-object v1

    invoke-static {v7, v1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    sget-object v2, Lw50/s;->d:Ljava/util/regex/Pattern;

    const-string v2, "text/xml"

    invoke-static {v2}, Lw50/s$a;->b(Ljava/lang/String;)Lw50/s;

    move-result-object v2

    sget-object v5, Lx40/a;->b:Ljava/nio/charset/Charset;

    if-eqz v2, :cond_12

    invoke-virtual {v2, v4}, Lw50/s;->a(Ljava/nio/charset/Charset;)Ljava/nio/charset/Charset;

    move-result-object v7

    if-nez v7, :cond_11

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v2, "; charset=utf-8"

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lw50/s$a;->b(Ljava/lang/String;)Lw50/s;

    move-result-object v2

    goto :goto_a

    :cond_11
    move-object v5, v7

    :cond_12
    :goto_a
    invoke-virtual {v1, v5}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v1

    const-string v5, "this as java.lang.String).getBytes(charset)"

    invoke-static {v1, v5}, Lkotlin/jvm/internal/l;->e(Ljava/lang/Object;Ljava/lang/String;)V

    array-length v5, v1

    array-length v7, v1

    int-to-long v8, v7

    int-to-long v10, v6

    int-to-long v12, v5

    invoke-static/range {v8 .. v13}, Lx50/b;->c(JJJ)V

    new-instance v7, Lw50/y;

    invoke-direct {v7, v2, v5, v1, v6}, Lw50/y;-><init>(Lw50/s;I[BI)V

    const-string v1, "POST"

    invoke-virtual {v3, v1, v7}, Lw50/w$a;->e(Ljava/lang/String;Lw50/z;)V

    invoke-virtual {v3}, Lw50/w$a;->b()Lw50/w;

    move-result-object v1

    iget-object v0, v0, Lnr/c;->h:Lw50/u;

    invoke-virtual {v0, v1}, Lw50/u;->a(Lw50/w;)La60/e;

    move-result-object v0

    invoke-static {v0}, Lcom/google/firebase/perf/network/FirebasePerfOkHttpClient;->execute(Lw50/d;)Lw50/a0;

    move-result-object v0

    :try_start_3
    iget-object v0, v0, Lw50/a0;->h:Lw50/b0;

    if-eqz v0, :cond_13

    invoke-virtual {v0}, Lw50/b0;->l()Lj60/i;

    move-result-object v0

    invoke-interface {v0}, Lj60/i;->r1()Ljava/io/InputStream;

    move-result-object v4

    :cond_13
    new-instance v0, Ldx/b;

    invoke-direct {v0}, Ldx/b;-><init>()V

    new-instance v1, Ljava/io/InputStreamReader;

    invoke-direct {v1, v4}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;)V

    invoke-virtual {v0, v1}, Ldx/b;->f(Ljava/io/Reader;)Z

    new-instance v1, Lmr/c;

    new-instance v2, Lmr/e;

    const-string v3, "response"

    invoke-virtual {v0, v3}, Ldx/b;->d(Ljava/lang/String;)Ldx/b;

    move-result-object v3

    const-string v4, "getChild(...)"

    invoke-static {v3, v4}, Lkotlin/jvm/internal/l;->e(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {v0}, Lnr/c;->a(Ldx/b;)Lnr/a;

    move-result-object v0

    invoke-direct {v2, v3, v0}, Lmr/e;-><init>(Ldx/b;Lnr/a;)V

    invoke-direct {v1, v2}, Lmr/c;-><init>(Landroidx/datastore/preferences/protobuf/g;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_1

    :goto_b
    move-object v0, v1

    goto :goto_c

    :catch_1
    move-exception v0

    sget-object v1, Lj70/a;->a:Lj70/a$a;

    invoke-virtual {v1, v0}, Lj70/a$a;->d(Ljava/lang/Throwable;)V

    new-instance v1, Lmr/c;

    new-instance v2, Lmr/d;

    invoke-direct {v2, v0}, Lmr/d;-><init>(Ljava/lang/Exception;)V

    invoke-direct {v1, v2}, Lmr/c;-><init>(Landroidx/datastore/preferences/protobuf/g;)V

    goto :goto_b

    :goto_c
    return-object v0

    :cond_14
    new-instance v0, Ljava/io/IOException;

    const-string v1, "No network connection"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0
.end method
```

## Task

**Part A.** Rewrite `nr.c`'s constructor in Kotlin, using OkHttp's public builder API names.

**Part B.** Rewrite `call()` as the lambda body of `send(request, url)` from Exercise 10. Work in passes:

1. Mark every exit (`throw`, `return-object`) and what it produces.
2. Recover the control flow that resolves the server URL.
3. Rebuild the XML envelope template and the request body.
4. Identify the inlined library code between `String.format` and `newCall`.

## Check your reading

1. `const/4 v5, 0x2` and `const/4 v6, 0x0` are loaded in the middle of the connectivity check. Where are they used again, hundreds of instructions later?
2. Which transports are `1`, `0`, `3` and `2`? When is `"No network connection"` thrown even though a network exists?
3. `v4` is set to `null` right after the first `TextUtils.isEmpty(url)`. List the later places that read it as `null`.
4. Five `checkNotNullParameter` calls name `request`, `generalInfo`, `pushId`, `locale` and `packageName`, but `call()` has no parameters. What does that tell you?
5. Where does `Arrays.copyOf(args, 2)` come from?
6. Between `"text/xml"` and `new-instance v7, Lw50/y;` there's a charset lookup, a `"; charset=utf-8"` fallback, `getBytes`, and an offset/count check. Which single OkHttp call expands to exactly that?
7. Which values are HTML-escaped and which aren't? Compare with [[Exercise-03-Authentication-Block-Builder]].
8. Given Part B's payload, what does Part A's logging interceptor record?

> [!tip]- Hints
> - `NetworkCapabilities`: `TRANSPORT_CELLULAR = 0`, `TRANSPORT_WIFI = 1`, `TRANSPORT_BLUETOOTH = 2`, `TRANSPORT_ETHERNET = 3`.
> - A `checkNotNullParameter(v3, "<this>")` inside the wait loop means an inlined *extension* function was called on `v3`.
> - `sget-object v2, Lw50/s;->d` is dead, since `v2` is overwritten immediately. Think "companion object access".
> - `FirebasePerfOkHttpClient.execute(call)` is the Firebase Perf plugin's rewrite of `call.execute()`.
> - `Lw50/b0;->l()` followed by `Lj60/i;->r1()` is `body.source().inputStream()`, which is what `ResponseBody.byteStream()` does.
> - `invoke-static/range {v8 .. v13}, Lx50/b;->c(JJJ)V` takes three `long`s, so six registers.

> [!success]- Solution, Part A
> ```kotlin
> class DqClient(
>     context: Context,
>     private val urlResolver: UrlResolver,        // a (lr.b)
>     private val connectivity: Connectivity,      // b (kr.a)
>     private val serverConfig: ServerConfig,      // c (nr.d)
>     private val generalInfo: GeneralAppInfo,     // d (lr.a)
>     private val pushId: String,                  // e
>     private val locale: Locale,                  // f
>     private val packageName: String,             // g
>     logger: HttpLoggingInterceptor.Logger,       // uo.d
> ) {
>     private val http: OkHttpClient = OkHttpClient.Builder()   // h
>         .connectTimeout(30_000, TimeUnit.MILLISECONDS)
>         .readTimeout(30_000, TimeUnit.MILLISECONDS)
>         .writeTimeout(30_000, TimeUnit.MILLISECONDS)
>         .addInterceptor(HttpLoggingInterceptor(logger).apply { level = HttpLoggingInterceptor.Level.BODY })
>         .build()
>
>     init {
>         try {
>             SSLContext.getInstance("TLS")
>         } catch (e: NoSuchAlgorithmException) {
>             Timber.e(e)
>             try {
>                 ProviderInstaller.installIfNeeded(context)
>             } catch (e: Exception) {
>                 Timber.tag("ProvideInstaller").e(e)
>             }
>         }
>     }
> }
> ```
>
> The three `Lx50/b;->b(JLjava/util/concurrent/TimeUnit;)I` calls are OkHttp's inlined duration checks inside the three timeout setters; which of `r`, `s` and `t` is connect, read or write doesn't matter, since all three are 30 s. `ProviderInstaller` runs only when `TLS` is unavailable.

> [!success]- Solution, Part B
> ```kotlin
> fun send(request: DqRequest, url: String? = null): Single<DqResponse> = Single.fromCallable {
>     TrafficStats.setThreadStatsTag(1)
>
>     if (request.requiresAuthentication) {
>         val activation = request.activation
>         if (activation != null && !activation.isValid) {
>             throw IllegalArgumentException("Service is not valid")
>         }
>     }
>
>     if (!connectivity.isConnected()) {                  // inlined, see below
>         throw IOException("No network connection")
>     }
>
>     val serverUrl: String? = if (TextUtils.isEmpty(url)) {
>         val activation = request.activation
>         if (!TextUtils.isEmpty(activation?.serverUrl)) {
>             activation?.serverUrl
>         } else {
>             synchronized(urlResolver) {
>                 while (urlResolver.isRunning()) {
>                     try {
>                         urlResolver.waitFor(60_000)       // inline fun Any.waitFor(ms: Long) = (this as Object).wait(ms)
>                     } catch (e: InterruptedException) {
>                         Timber.e(e)
>                     }
>                 }
>             }
>             urlResolver.a(serverConfig.servers[serverConfig.mode] ?: "")
>         }
>     } else {
>         url
>     }
>
>     if (serverUrl == null) {
>         return@fromCallable DqResponse(DqResult.Error(IOException("No server url")))
>     }
>
>     val builder = Request.Builder()
>     builder.url(serverUrl)
>
>     val template = request.envelopeTemplate(generalInfo, pushId, locale, packageName)   // inlined, see below
>
>     val body = StringBuilder()
>     var auth = ""
>     if (request.requiresAuthentication) {
>         val activation = request.activation
>         auth = "<service-name>" + TextUtils.htmlEncode(activation?.serviceName) +
>             "</service-name><authentication><user-name>" + TextUtils.htmlEncode(activation?.userName) +
>             "</user-name><activation-number>" + activation?.activationNumber +
>             "</activation-number><client-number>" + generalInfo.clientNumber +
>             "</client-number></authentication>"
>     }
>     body.append(auth)
>     body.append(request.requestBody)
>
>     val xml = template.format(request.type, body.toString())
>     builder.post(xml.toRequestBody("text/xml".toMediaTypeOrNull()))   // post() inlines to method("POST", body)
>
>     val response = http.newCall(builder.build()).execute()
>     try {
>         val root = XmlNode()
>         root.parse(InputStreamReader(response.body?.byteStream()))
>         DqResponse(DqResult.Success(root.child("response"), parseCommand(root)))
>     } catch (e: Exception) {
>         Timber.e(e)
>         DqResponse(DqResult.Error(e))
>     }
> }.subscribeOn(Schedulers.io())
> ```
>
> The inlined pieces, written out:
>
> ```kotlin
> // kr.a
> fun Connectivity.isConnected(): Boolean {
>     val network = manager.activeNetwork ?: return false
>     val caps = manager.getNetworkCapabilities(network) ?: return false
>     return caps.hasTransport(TRANSPORT_WIFI) || caps.hasTransport(TRANSPORT_CELLULAR) ||
>         caps.hasTransport(TRANSPORT_ETHERNET) || caps.hasTransport(TRANSPORT_BLUETOOTH)
> }
>
> // Declared somewhere that can read request.includeClientInfo without a receiver check;
> // a member of DqRequest fits.
> fun DqRequest.envelopeTemplate(generalInfo: GeneralAppInfo, pushId: String, locale: Locale, packageName: String): String =
>     if (includeClientInfo) {
>         "<?xml version='1.0' encoding='UTF-8'?><nd version='1.0'><client-info><software>PRAndroid</software>" +
>             "<version>" + htmlEncode(generalInfo.codeVersion) + "</version>" +
>             "<app-version>" + htmlEncode(generalInfo.appVersion) + "</app-version>" +
>             "<client-type>PC</client-type><client-subtype>Tablet</client-subtype>" +
>             "<system-manufacturer>" + htmlEncode(generalInfo.systemManufacturer) + "</system-manufacturer>" +
>             "<system-model>" + htmlEncode(generalInfo.systemModel) + "</system-model>" +
>             "<installkey1>" + htmlEncode(generalInfo.affiliation) + "</installkey1>" +
>             "<client-locale-language>" + htmlEncode(locale.language) + "</client-locale-language>" +
>             "<client-locale-country>" + htmlEncode(locale.country) + "</client-locale-country>" +
>             "<client-locale-variant>" + htmlEncode(locale.variant) + "</client-locale-variant>" +
>             "<application-id>" + htmlEncode(packageName) + "</application-id>" +
>             "<default-service-name>" + htmlEncode(generalInfo.serviceName) + "</default-service-name>" +
>             "<device-token>" + htmlEncode(pushId) + "</device-token></client-info>" +
>             "<request id='0' type='%s'>%s</request></nd>"
>     } else {
>         "<?xml version='1.0' encoding='UTF-8'?><nd version='1.0'><request id='0' type='%s'>%s</request></nd>"
>     }
>
> // okhttp3 (RequestBody.Companion), OkHttp 4
> fun String.toRequestBody(contentType: MediaType? = null): RequestBody {
>     var charset = Charsets.UTF_8
>     var finalContentType = contentType
>     if (contentType != null) {
>         val resolved = contentType.charset()
>         if (resolved == null) {
>             finalContentType = "$contentType; charset=utf-8".toMediaTypeOrNull()
>         } else {
>             charset = resolved
>         }
>     }
>     val bytes = toByteArray(charset)
>     return bytes.toRequestBody(finalContentType, 0, bytes.size)   // checkOffsetAndCount + new w50.y
> }
> ```
>
> **Answers**
>
> 1. `v5 = 2` is `TRANSPORT_BLUETOOTH` for the last `hasTransport`, and later the length passed to `Arrays.copyOf`. `v6 = 0` is `TRANSPORT_CELLULAR`, and later the `offset` passed to both `Lx50/b;->c` (as `int-to-long v10, v6`) and `new Lw50/y;`. The compiler loaded them where they were first needed and kept the registers alive.
> 2. Wi-Fi, cellular, Ethernet, Bluetooth. It's also thrown when the active network has capabilities but lists none of those four transports.
> 3. `move-object v3, v4` and `move-object v2, v4` (reading `activation?.serverUrl` with no activation); `move-object v11, v4` twice and `move-object v10, v4` in the auth block; `v2.a(v4)`, which is `charset(null)` — the default argument; and the response stream, which stays `null` when `body` is `null`, making `InputStreamReader(null)` throw inside the `try` so the call returns an `Error`.
> 4. They're parameter checks of functions that R8 inlined into `call()`. `request` belonged to the lambda's original body, most likely a separate `execute(request, url)` — which also explains the `getClass()` receiver check on `v0` just before it. `generalInfo`, `pushId`, `locale` and `packageName` belonged to the envelope-template builder that follows them.
> 5. Kotlin's `String.format(vararg args)` is `java.lang.String.format(this, *args)`, and a `*` spread copies the array before passing it on.
> 6. OkHttp 4's `String.toRequestBody(contentType)`, with `ByteArray.toRequestBody(contentType, 0, size)` inlined inside it. `Lw50/y;` is the anonymous `RequestBody` it returns, and `Lx50/b;->c(JJJ)V` is `checkOffsetAndCount`. The dead `sget-object v2, Lw50/s;->d` is most likely what's left of the `MediaType.Companion` access in `"text/xml".toMediaTypeOrNull()`: a static read that still triggers `MediaType`'s class initializer.
> 7. Escaped: every `<client-info>` value, the service name and the user name. Not escaped: the activation number, the client number (an `Int`), `request.type`, and `request.requestBody`, which is XML by design. These are the same choices `bp.m1.e` makes.
> 8. Everything. At `Level.BODY`, every request and response body — user name, activation number, device token, model, locale — goes to the injected `uo.d` logger. Whether that reaches Logcat in release builds depends on `uo.d`, which makes it worth a look in [[PressReader]].

## See also

- [[Smali-Exercises]]
- [[Reading-Raw-Dalvik]] — the checklist for long methods
- [[Discovering-The-Core-XML-Protocol]] — the `bp.m1` side of the same protocol
- [[Dalvik-Bytecode-Reference|Reference]]
