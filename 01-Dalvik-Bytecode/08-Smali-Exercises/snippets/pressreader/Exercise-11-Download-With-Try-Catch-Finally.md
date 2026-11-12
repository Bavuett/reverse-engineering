---
tags: [snippet, exercise]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/bp/m1.smali"
difficulty: "★★★★"
skills: "duplicated finally bodies, folded flags, nested handlers"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-11-Download-With-Try-Catch-Finally

## Context

`bp.m1.b(Service, File, String)` downloads a URL into a file and stamps the service's last-download time (field `o`, a `long`). It's the most compact example in this APK of `try`/`catch`/`finally`, where the `finally` body is copied onto every exit path. `Lvw/c;->j` copies a stream into a file path, and `Lvw/c;->b` closes quietly. `a(String)` is the factory from [[Exercise-02-HttpURLConnection-Factory]].

## Original path

`smali_classes2/bp/m1.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.method public static b(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/io/File;Ljava/lang/String;)Z
    .locals 6

    const-string v0, "downloadContent failed from "

    const/4 v1, 0x0

    const/4 v2, 0x0

    :try_start_0
    invoke-static {p2}, Lbp/m1;->a(Ljava/lang/String;)Ljava/net/HttpURLConnection;

    move-result-object v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    :try_start_1
    invoke-virtual {v3}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result v4

    const/16 v5, 0xc8

    if-ne v4, v5, :cond_1

    invoke-virtual {v3}, Ljava/net/URLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object v2

    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v4

    invoke-static {v2, v4}, Lvw/c;->j(Ljava/io/InputStream;Ljava/lang/String;)V

    if-eqz p0, :cond_0

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v4

    iput-wide v4, p0, Lcom/newspaperdirect/pressreader/android/core/Service;->o:J
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    :cond_0
    const/4 v1, 0x1

    goto :goto_0

    :catchall_0
    move-exception p0

    goto :goto_2

    :cond_1
    :goto_0
    if-nez v1, :cond_2

    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    :cond_2
    invoke-static {v2}, Lvw/c;->b(Ljava/io/Closeable;)V

    :goto_1
    invoke-virtual {v3}, Ljava/net/HttpURLConnection;->disconnect()V

    goto :goto_3

    :catchall_1
    move-exception p0

    move-object v3, v2

    :goto_2
    :try_start_2
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    const-string v0, "HttpRequestHelper"

    sget-object v4, Lj70/a;->a:Lj70/a$a;

    invoke-virtual {v4, v0}, Lj70/a$a;->n(Ljava/lang/String;)V

    new-array v0, v1, [Ljava/lang/Object;

    invoke-virtual {v4, p0, p2, v0}, Lj70/a$a;->e(Ljava/lang/Throwable;Ljava/lang/String;[Ljava/lang/Object;)V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    invoke-static {v2}, Lvw/c;->b(Ljava/io/Closeable;)V

    if-eqz v3, :cond_3

    goto :goto_1

    :cond_3
    :goto_3
    return v1

    :catchall_2
    move-exception p0

    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    invoke-static {v2}, Lvw/c;->b(Ljava/io/Closeable;)V

    if-eqz v3, :cond_4

    invoke-virtual {v3}, Ljava/net/HttpURLConnection;->disconnect()V

    :cond_4
    throw p0
.end method
```

## Task

Rewrite `b` in Java with a single `try`/`catch`/`finally`. Your version must return the same value and perform the same cleanup on every path:

- success;
- a non-200 response;
- an exception while connecting;
- an exception while copying;
- an exception thrown by the logging call itself.

## Check your reading

1. List every `File.delete()` call. Why is one guarded by `if-nez v1` and the others unconditional?
2. Why does `:catchall_1` do `move-object v3, v2` before joining the common error path?
3. Which handler ends in `throw`, and what does that tell you about the source?
4. Is the catch clause `catch (Exception e)` or `catch (Throwable t)`? Justify it from the directives.
5. The normal path calls `disconnect()` on `v3` without a null check, but both error paths check. Why?

> [!tip]- Hints
> - For each path, track what `v1` (result), `v2` (stream) and `v3` (connection) hold.
> - `.catchall` catches everything. javac emits it both for `finally` and for `catch (Throwable)`.

> [!success]- Solution
> ```java
> public static boolean b(Service service, File file, String url) {
>     boolean ok = false;
>     InputStream in = null;
>     HttpURLConnection conn = null;
>     try {
>         conn = a(url);
>         if (conn.getResponseCode() == 200) {
>             in = conn.getInputStream();
>             vw.c.j(in, file.getAbsolutePath());
>             if (service != null) {
>                 service.o = System.currentTimeMillis();
>             }
>             ok = true;
>         }
>     } catch (Throwable t) {
>         String message = "downloadContent failed from " + url;
>         Timber.tag("HttpRequestHelper");
>         Timber.e(t, message);
>     } finally {
>         if (!ok) {
>             file.delete();
>         }
>         vw.c.b(in);
>         if (conn != null) {
>             conn.disconnect();
>         }
>     }
>     return ok;
> }
> ```
>
> **Answers**
>
> 1. Three calls: on the normal path at `:goto_0` (guarded by `if-nez v1`), after the catch handler's logging, and in `:catchall_2`. `const/4 v1, 0x1` sits after the last instruction that can throw into those handlers, so `ok` is provably `false` whenever they run, and the compiler folded `if (!ok)` away on those paths.
> 2. The exception came from `a(url)`, so no connection was ever assigned. The handler copies the `null` in `v2` into `v3`, so the shared `if-eqz v3` skips `disconnect()`. In source, that's just `conn` still being `null`.
> 3. `:catchall_2`, which covers the logging code inside the catch block. Cleanup followed by a rethrow is exactly a `finally` body on the "exception escaped the catch block" path.
> 4. `catch (Throwable t)`: the handlers that log and then *return* are `.catchall` ranges, not `.catch Ljava/lang/Exception;`. With `catch (Exception e)` you'd see a typed `.catch` directive plus a separate, rethrowing `.catchall` for the `finally`.
> 5. On the normal path, `getResponseCode()` was already invoked on `v3`, so the compiler knows it's non-null and dropped the check. On the error paths the connection may never have been created.

## See also

- [[Smali-Exercises]]
- [[Exception-Handling]]
- [[Return-And-Throw]]
- [[Dalvik-Bytecode-Reference|Reference]]
