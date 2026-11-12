---
tags: [example]
level: 2
aliases: ["Debug vs release smali", "R8 optimization comparison"]
created: 2026-11-12
---

# Example: Same-Method-Debug-Vs-R8-Release

> [!info] Level 2 — intermediate
> The same Java class compiled twice: a debug D8 build that maps almost line for line onto the source, and an R8 release build that renamed, inlined, and rewrote it. Knowing which transformations R8 performs keeps you from reversing the optimizer instead of the program.

## Goal

Make the gap between "textbook smali" and "real-app smali" concrete, one transformation at a time. Belongs to [[Reading-Raw-Dalvik]].

## Java source

```java
public class SessionManager {
    private static final String TAG = "SessionManager";
    private String token;

    public boolean isLoggedIn() {
        return token != null && !token.isEmpty();
    }

    public String authHeader() {
        if (!isLoggedIn()) throw new IllegalStateException("not logged in");
        return "Bearer " + token;
    }
}
```

## Debug build (D8, no minification)

```smali
.class public LSessionManager;
.super Ljava/lang/Object;
.source "SessionManager.java"

.field private static final TAG:Ljava/lang/String; = "SessionManager"
.field private token:Ljava/lang/String;

.method public authHeader()Ljava/lang/String;
    .registers 3
    .line 10
    invoke-virtual {p0}, LSessionManager;->isLoggedIn()Z
    move-result v0
    if-nez v0, :cond_0
    new-instance v0, Ljava/lang/IllegalStateException;
    const-string v1, "not logged in"
    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V
    throw v0
    .line 11
    :cond_0
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "Bearer "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    iget-object v1, p0, LSessionManager;->token:Ljava/lang/String;
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method
```

## Release build (R8, minified and optimized)

```smali
.class public final Lx2/c;
.super Ljava/lang/Object;
.source "SourceFile"

.field public a:Ljava/lang/String;

.method public final a()Ljava/lang/String;
    .locals 2
    iget-object v0, p0, Lx2/c;->a:Ljava/lang/String;
    if-eqz v0, :cond_0
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z
    move-result v1
    if-nez v1, :cond_0
    const-string v1, "Bearer "
    invoke-virtual {v1, v0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    return-object v0
    :cond_0
    new-instance v0, Ljava/lang/IllegalStateException;
    const-string v1, "not logged in"
    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V
    throw v0
.end method
```

## Step by step

| transformation | debug | release | what it costs the reader |
| --- | --- | --- | --- |
| **Renaming** | `SessionManager`, `token`, `authHeader` | `x2/c`, `a`, `a()` | meaning must come from behavior and strings |
| **Source info** | `.source "SessionManager.java"`, `.line 10` | `.source "SourceFile"`, lines remapped or gone | stack traces no longer point to source lines |
| **Dead constant removed** | `TAG` field present | gone | unused constants vanish entirely |
| **Inlining** | calls `isLoggedIn()` | its body (`if-eqz` + `isEmpty`) is pasted in | the callee may not exist at all; a "method" you find may be two source methods |
| **Finalization** | `public class` | `public final class`, `public final` method | `final` everywhere says nothing about the source |
| **Access widening** | `private token` | `public a` | visibility in release smali is unreliable |
| **Concat rewrite** | `StringBuilder` chain | `"Bearer ".concat(token)` | a different API call for the same source expression |
| **Branch layout** | throw-block in the middle | throw-block moved to the end | block order doesn't match source order |

1. The debug build uses `.registers 3` and the literal `StringBuilder` + `move-result-object` chain; it reads almost like a transliteration of the Java, one small instruction group per source operator.
2. In the release build, `if-eqz v0` and `if-nez v1` jumping to the same `:cond_0` is the inlined `token != null && !token.isEmpty()` negated — the `&&` shape from [[If-Else-And-Comparisons]]. Recognizing an inlined callee's shape inside a caller is the main skill this comparison trains.
3. The `concat` rewrite is safe only because the inlined null check proved `token` non-null on that path. When you see `String.concat` in R8 output, mentally rewrite it back to `+`.
4. None of these transformations change behavior, and none of them are obfuscation in the anti-reversing sense — this is just the default optimizer. Anti-tamper tooling (see [[Telescoping-Constructors-And-Framework-Constants-In-TUA]]) adds deliberate noise on top.

## Compared with real code

- [[Final-Instance-Methods-Still-Dispatch-Virtually]] — the "finalization" row, observed in PressReader.
- [[Exercise-01-Outlined-StringBuilder-Helpers]] — the opposite of inlining: R8 *outlining* repeated code into shared helpers.

## See also

- [[Reading-Raw-Dalvik]]
- [[Smali-Exercises]]
- [[Annotating-A-Short-Method-Line-By-Line]]
- [[Recognizing-An-Opaque-Predicate-Guard]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
