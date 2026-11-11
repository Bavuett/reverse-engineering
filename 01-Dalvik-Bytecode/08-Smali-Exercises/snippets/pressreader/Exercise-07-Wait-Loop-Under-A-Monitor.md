---
tags: [snippet, exercise]
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/bp/m1.smali"
difficulty: "★★★"
skills: "Object.wait loops, catch inside synchronized, parameter register reuse"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-07-Wait-Loop-Under-A-Monitor

## Context

`bp.m1.g(Service)` resolves the base URL for a request. A `Service` may carry its own URL in field `n`. Otherwise the method waits until the shared resolver — the static `lr.b` field `n` from [[Exercise-06-Static-Monitors-And-Iterators]] — has finished whatever it's running, then asks it for the URL stored in map `o` under the current server mode, the static `String` `p`.

## Original path

`smali_classes2/bp/m1.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.method public static g(Lcom/newspaperdirect/pressreader/android/core/Service;)Ljava/lang/String;
    .locals 3

    if-eqz p0, :cond_0

    iget-object v0, p0, Lcom/newspaperdirect/pressreader/android/core/Service;->n:Ljava/lang/String;

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_0

    iget-object p0, p0, Lcom/newspaperdirect/pressreader/android/core/Service;->n:Ljava/lang/String;

    return-object p0

    :cond_0
    sget-object p0, Lbp/m1;->n:Llr/b;

    monitor-enter p0

    :goto_0
    :try_start_0
    sget-object v0, Lbp/m1;->n:Llr/b;

    invoke-interface {v0}, Llr/b;->isRunning()Z

    move-result v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v1, :cond_1

    const-wide/32 v1, 0xea60

    :try_start_1
    invoke-virtual {v0, v1, v2}, Ljava/lang/Object;->wait(J)V
    :try_end_1
    .catch Ljava/lang/InterruptedException; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception v0

    goto :goto_1

    :catch_0
    move-exception v0

    :try_start_2
    invoke-static {v0}, Lj70/a;->a(Ljava/lang/Throwable;)V

    goto :goto_0

    :cond_1
    monitor-exit p0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    sget-object p0, Lbp/m1;->o:Ljava/util/HashMap;

    sget-object v1, Lbp/m1;->p:Ljava/lang/String;

    invoke-virtual {p0, v1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    invoke-interface {v0, p0}, Llr/b;->a(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0

    :goto_1
    :try_start_3
    monitor-exit p0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v0
.end method
```

## Task

Rewrite `g` in Java.

## Check your reading

1. `p0` starts as the `Service` argument. What does it hold after `sget-object p0, Lbp/m1;->n`, and after the `HashMap.get` call?
2. How many `.catch`/`.catchall` directives are there, over how many ranges, and which source construct does each come from?
3. The `InterruptedException` handler jumps back to `:goto_0`. What happens to the interrupt, and is the thread still holding the monitor when the handler runs?
4. `v0` is loaded from `Lbp/m1;->n` inside the loop but used after `monitor-exit`. Is it the same object as the lock?

> [!tip]- Hints
> - `const-wide/32 v1, 0xea60` loads a `long` into the register pair `v1`/`v2`.
> - `Lj70/a;->a(Throwable)V` is a static logging call.

> [!success]- Solution
> ```java
> public static String g(Service service) {
>     if (service != null && !TextUtils.isEmpty(service.n)) {
>         return service.n;
>     }
>     synchronized (n) {
>         while (n.isRunning()) {
>             try {
>                 n.wait(60_000);
>             } catch (InterruptedException e) {
>                 Timber.e(e);
>             }
>         }
>     }
>     return n.a((String) o.get(p));
> }
> ```
>
> **Answers**
>
> 1. First the lock (the static resolver), then the `String` looked up in `o`. The parameter register is recycled twice once `service` is no longer needed.
> 2. Five directives over four ranges, all but one pointing at `:catchall_0`, the `synchronized` block's release-and-rethrow handler. `_0` covers `isRunning()`; `_1` covers `wait` and carries both the source's `.catch Ljava/lang/InterruptedException;` and the `.catchall`, because that `try` sits inside the `synchronized` block; `_2` covers the logging call through the normal-path `monitor-exit`; `_3` covers the exceptional-path `monitor-exit` itself, so a failing release is retried as in [[Exercise-06-Static-Monitors-And-Iterators]].
> 3. It's logged and swallowed. `wait` clears the interrupt status when it throws, so the loop simply waits again. `wait` re-acquires the monitor before throwing, so the handler runs with the lock held — which is why the logging call is still covered by the `.catchall`.
> 4. Yes: `n` is `static final`, so every read returns the same instance. The compiler just didn't reuse the register holding the lock.

## See also

- [[Smali-Exercises]]
- [[Monitor-Enter-And-Monitor-Exit]]
- [[Registers]] — wide registers and register reuse
- [[Exercise-12-The-DQ-Request-Callable]] — the same wait loop, rewritten in Kotlin
- [[Dalvik-Bytecode-Reference|Reference]]
