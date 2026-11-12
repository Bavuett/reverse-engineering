---
tags: [snippet, exercise]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "7.5.260731"
source_path: "smali_classes2/bp/m1.smali"
difficulty: "★"
skills: "register reuse, check-cast, declaring class in method references"
date_added: 2026-09-15
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Exercise-02-HttpURLConnection-Factory

## Context

`bp.m1` is PressReader's original XML API manager, built on `HttpURLConnection` (see [[Discovering-The-Core-XML-Protocol]]). `a(String)` is the connection factory every GET in the class goes through; `i(String)` escapes a value before it's pasted into XML. Firebase Performance Monitoring rewrites app bytecode at build time, so a call it instruments no longer looks exactly like what the developer typed.

## Original path

`smali_classes2/bp/m1.smali` (apktool dump of `7.5.260731`, see [[Smali-Exercises]])

## Snippet

```smali
.method public static a(Ljava/lang/String;)Ljava/net/HttpURLConnection;
    .locals 1

    new-instance v0, Ljava/net/URL;

    invoke-direct {v0, p0}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object p0

    invoke-static {p0}, Lcom/google/firebase/perf/network/FirebasePerfUrlConnection;->instrument(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/net/URLConnection;

    check-cast p0, Ljava/net/HttpURLConnection;

    const/4 v0, 0x1

    invoke-virtual {p0, v0}, Ljava/net/HttpURLConnection;->setInstanceFollowRedirects(Z)V

    const/16 v0, 0x7530

    invoke-virtual {p0, v0}, Ljava/net/URLConnection;->setConnectTimeout(I)V

    invoke-virtual {p0, v0}, Ljava/net/URLConnection;->setReadTimeout(I)V

    const-string v0, "GET"

    invoke-virtual {p0, v0}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    return-object p0
.end method

.method public static i(Ljava/lang/String;)Ljava/lang/String;
    .locals 1

    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_0

    :cond_0
    invoke-static {p0}, Landroid/text/TextUtils;->htmlEncode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    :goto_0
    return-object p0
.end method
```

## Task

1. Rewrite both methods as Java.
2. For `a`, also write the single line the developer most likely typed before the Firebase Perf plugin rewrote it.

## Check your reading

1. `v0` holds several unrelated values in `a`. List them in order, with their types.
2. `setConnectTimeout` is referenced as `Ljava/net/URLConnection;->setConnectTimeout`, but `setRequestMethod` as `Ljava/net/HttpURLConnection;->setRequestMethod`, although both are called on the same object. Why?
3. Why are there two `check-cast` instructions in a row?
4. In `i`, `p0` is returned on both paths. What does it hold on each?

> [!tip]- Hints
> - Convert `0x7530` to decimal.
> - A method reference names the class that declares the method, not the static type of the variable it's called on.
> - `boolean` constants are plain `int`s in Dalvik.

> [!success]- Solution
> ```java
> public static HttpURLConnection a(String url) throws IOException {
>     URLConnection raw = new URL(url).openConnection();
>     HttpURLConnection conn = (HttpURLConnection) (URLConnection) FirebasePerfUrlConnection.instrument(raw);
>     conn.setInstanceFollowRedirects(true);
>     conn.setConnectTimeout(30_000);
>     conn.setReadTimeout(30_000);
>     conn.setRequestMethod("GET");
>     return conn;
> }
>
> public static String i(String value) {
>     return TextUtils.isEmpty(value) ? value : TextUtils.htmlEncode(value);
> }
> ```
>
> Before instrumentation, the first two lines were:
>
> ```java
> HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
> ```
>
> **Answers**
>
> 1. A `java.net.URL`, then the `int` `1` used as `true`, then the `int` `0x7530` = 30000 (for both timeouts), then the `String` `"GET"`. Meanwhile `p0` goes from the URL string to the connection object.
> 2. `setConnectTimeout` and `setReadTimeout` are declared on `URLConnection`; `setInstanceFollowRedirects` and `setRequestMethod` only exist on `HttpURLConnection`. The reference records the declaring class, so it's no evidence of the variable's type.
> 3. `instrument(Object)` returns `Object`. The plugin casts it back to what `openConnection()` returned (`URLConnection`), then the developer's own `(HttpURLConnection)` cast follows. Redundant, but both survive.
> 4. On the "empty" path, the original argument — `null` or `""`, since `TextUtils.isEmpty` is true for both. Otherwise, the encoded string, written back into the same register.
>
> The `throws IOException` isn't visible anywhere: Dalvik doesn't enforce checked exceptions, and R8 strips the `Throws` annotation that would record it.

## See also

- [[Smali-Exercises]]
- [[New-Instance-And-Check-Cast]]
- [[Invoke-Direct-Static-Virtual-Interface]]
- [[Dalvik-Bytecode-Reference|Reference]]
