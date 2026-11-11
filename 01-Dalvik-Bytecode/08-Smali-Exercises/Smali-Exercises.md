---
tags: [fundamentals]
aliases: ["Smali Exercises", "Dalvik Reading Exercises"]
created: 2026-09-15
---

# Smali-Exercises

## In short

Twelve graded exercises built from real PressReader smali (`com.newspaperdirect.pressreader.android`, versionName `7.5.260731`, versionCode 64735). Each one hands you one or more raw methods and asks you to write the Java or Kotlin source that behaves identically. Solutions are folded under each exercise, so the set doubles as a self-assessment of how reliably you can read smali cold.

## Explanation

### How to work an exercise

1. Read only the exercise's smali — no JADX, no case-study `java/` folder, no solution.
2. Write your reconstruction in a scratch file. Use names that describe behavior; keep obfuscated names wherever you can't tell.
3. Answer the "Check your reading" questions in writing before unfolding anything.
4. Unfold the solution and grade yourself with the rubric below. Every 0 or 1 points at a chapter worth rereading.

### Grading rubric

| Score | Meaning |
| --- | --- |
| 3 | Same behavior on every path, including exceptions, `null`s and default branches |
| 2 | Main path right; one edge (a null branch, a `finally`, a fall-through default) wrong or missing |
| 1 | Shape right (loops, branches, calls) but data flow wrong — a register misattributed, arguments swapped |
| 0 | Structure not recovered |

Your reconstruction doesn't have to match the solution's names or its Java-vs-Kotlin choice — only its behavior.

### What was changed in the excerpts

Excerpts are copied from the apktool dump's `smali/` and `smali_classes2/` folders with exactly one change: every `.line N` directive is removed. This build's obfuscator rewrote the debug line table into a meaningless 1, 2, 3, … sequence, often several directives per instruction, so they carry no information and roughly double every method's length. Labels, `.catch` directives, register numbers and the blank lines between instructions are untouched.

> [!warning] Not the same disassembly as the case study
> The `smali/bp/m1.smali` imported into [[PressReader]]'s case study is not byte-identical to this dump (128 KB vs 114 KB), so don't expect its labels or line directives to match these excerpts line for line.

### Obfuscated names you'll meet repeatedly

These are library and runtime classes, not app logic — resolving them is not the point of the exercises, so they're given up front. **Verified** means confirmed from the class's own strings or body in this dump; **inferred** means from shape and call sites only.

| Smali reference | Real identity | Evidence |
| --- | --- | --- |
| `Lkotlin/jvm/internal/l;->f(Object, String)V` | `Intrinsics.checkNotNullParameter` | inferred: the string is always a parameter name |
| `Lkotlin/jvm/internal/l;->e(Object, String)V` | `Intrinsics.checkNotNullExpressionValue` | inferred: messages like `"getChild(...)"` |
| `Lkotlin/jvm/internal/l;->a(Object, Object)Z` | `Intrinsics.areEqual` | inferred: used by every generated `equals` |
| `Lj70/a;`, `Lj70/a$a;` | Timber-style logger: `n(String)` sets a one-shot tag, `a`/`d`/`e` log | inferred |
| `Ln10/t;->a` | `kotlin.Unit` | inferred |
| `Ln10/i;` | `kotlin.Pair` | inferred: `(Object, Object)` constructor fed to `o10/d0.p` |
| `Lo10/d0;->p([Ln10/i;)Ljava/util/Map;` | `mapOf(vararg pairs)` | inferred |
| `Lx40/s;->j0(CharSequence)CharSequence` | `CharSequence.trim()` | verified: `"<this>"` check and a two-ended whitespace scan |
| `Lbo/app/g8;->d(SharedPreferences, String, String)V` | `prefs.edit().putString(k, v).apply()` | verified |
| `Lvw/c;->b(Closeable)V` | null-safe quiet close | verified |
| `Lvw/c;->j(InputStream, String)V` | copy a stream into a file path | verified: `BufferedOutputStream(FileOutputStream)` |
| `Ljq/t0;->e()` | app-wide service-locator singleton | inferred |
| `w50.*` | `okhttp3.*`: `w50/w$a` `Request.Builder`, `w50/w` `Request`, `w50/s` `MediaType`, `w50/z` `RequestBody`, `w50/u` `OkHttpClient`, `w50/d` `Call`, `w50/a0` `Response`, `w50/b0` `ResponseBody` | `w50/q` = `HttpUrl` and `w50/a0` = `Response` verified in [[PressReader]]; `w50/w$a` verified by its `"method "` / `" must have a request body."` strings; the rest inferred |
| `Li60/a;` | `okhttp3.logging.HttpLoggingInterceptor` | verified: `"--> END "` strings |
| `La10/p;`, `Ll00/w;` | RxJava `SingleFromCallable`, `Single` (`p(Scheduler)` = `subscribeOn`) | verified: `"The callable returned a null value"`, `"scheduler is null"` |
| `Luc/a;->a(Context)V` | `ProviderInstaller.installIfNeeded` | verified: `"ProviderInstaller"` strings |
| `Landroidx/datastore/preferences/protobuf/g;` | **not** protobuf — PressReader's own sealed result base class under a reused name | verified: `mr/d` and `mr/e` both extend it |

## Exercises

| # | Exercise | Source | Difficulty | Main skills |
| --- | --- | --- | --- | --- |
| 01 | [[Exercise-01-Outlined-StringBuilder-Helpers]] | `protobuf/e`, `car/app/a` | ★ | `p` registers in static methods, `/2addr` arithmetic, discarded results |
| 02 | [[Exercise-02-HttpURLConnection-Factory]] | `bp/m1.a`, `bp/m1.i` | ★ | register reuse, `check-cast`, declaring class in method references |
| 03 | [[Exercise-03-Authentication-Block-Builder]] | `bp/m1.e` | ★★ | desugared string concatenation, outlined calls, dead reads |
| 04 | [[Exercise-04-Kotlin-Default-Argument-Constructor]] | `mr/b.<init>` | ★★ | default-argument bitmask, checks before `super()` |
| 05 | [[Exercise-05-Kotlin-Data-Class-Reconstruction]] | `mr/a` | ★★ | generated `equals`/`hashCode`/`toString`, nullability evidence |
| 06 | [[Exercise-06-Static-Monitors-And-Iterators]] | `bp/m1.c`, `h`, `n` | ★★ | `monitor-enter`/`monitor-exit`, post-increment, `declared-synchronized` |
| 07 | [[Exercise-07-Wait-Loop-Under-A-Monitor]] | `bp/m1.g` | ★★★ | `Object.wait` loops, catch inside `synchronized`, parameter register reuse |
| 08 | [[Exercise-08-Server-Mode-Map-Constructor]] | `nr/d` | ★★★ | register shuffling, `filled-new-array`, companion statics |
| 09 | [[Exercise-09-Sparse-Switch-On-String-Hash]] | `nr/c.a` | ★★★ | `when` on strings, `sparse-switch`, shared case targets |
| 10 | [[Exercise-10-Synthetic-Lambda-And-Rx-Single]] | `nr/b.<init>`, `nr/c.b` | ★★ | desugared lambdas, staticized instance methods |
| 11 | [[Exercise-11-Download-With-Try-Catch-Finally]] | `bp/m1.b` | ★★★★ | duplicated `finally` bodies, folded flags, nested handlers |
| 12 | [[Exercise-12-The-DQ-Request-Callable]] | `nr/c.<init>`, `nr/b.call` | ★★★★★ | all of the above, plus inlined Kotlin and OkHttp code |

Exercises 01–03, 06, 07 and 11 come from `bp.m1`, the original Java-style XML client; the rest are Kotlin. Exercise 12 rebuilds the modern OkHttp-based twin of `bp.m1`'s request, so doing 02, 03 and 07 first pays off. Exercise 10 can be done at any point after 04.

```dataview
TABLE difficulty AS "Difficulty", skills AS "Skills", source_path AS "Source"
FROM "01-Dalvik-Bytecode" AND #exercise
SORT file.name ASC
```

## Worked example

The smallest class on the request path, `kr.a`, as a model of what a finished answer looks like:

```smali
.class public final Lkr/a;
.super Ljava/lang/Object;
.source "SourceFile"

# instance fields
.field public final a:Landroid/net/ConnectivityManager;

.method public constructor <init>(Landroid/net/ConnectivityManager;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lkr/a;->a:Landroid/net/ConnectivityManager;

    return-void
.end method
```

1. `.locals 0` with one declared parameter: the frame is just `p0` (`this`) and `p1` (the `ConnectivityManager`).
2. `invoke-direct {p0}, Ljava/lang/Object;-><init>()V` is the implicit `super()`.
3. `iput-object p1, p0, Lkr/a;->a` stores the argument into the only field, which is `final`.

```kotlin
class Connectivity(val manager: ConnectivityManager)   // kr.a, field a
```

Score 3 needs nothing more here: there's one path, no branches, and no way to throw. The exercises are the same process with more of everything.

## More examples

- The exercise table above.
- [[Reading-Raw-Dalvik]]'s worked examples, which read obfuscated methods cold with the reasoning written out rather than folded away.

## See also

- [[Reading-Raw-Dalvik]] — the checklist these exercises practice
- [[Methods]], [[Registers]], [[Dalvik-Instructions]] — the chapters the rubric's 0s and 1s usually point back to
- [[Java-Fundamentals]] — what the reconstructed source means operationally
- [[PressReader]] — the case study the classes come from

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]

## Flashcards
#flashcards

Why can a Kotlin constructor call `Intrinsics.checkNotNullParameter` before `Object.<init>`?::Bytecode only forbids using `this` before it's initialized, not running other code first; Kotlin relies on that, while classic Java source can't express it.
What does the `declared-synchronized` flag do on a dex bytecode method?::Nothing at runtime. The compiler emits explicit `monitor-enter`/`monitor-exit`; the runtime-locking `synchronized` flag is only valid on native methods.
How do you recognize a duplicated `finally` body in smali?::The same cleanup calls appear once per exit path — normal completion, each catch handler, and a catch-all handler ending in `throw`.
What does `add-int/lit8 v4, v2, 0x1`, `aput-object v3, v1, v2`, `move v2, v4` compile from?::`array[i++] = value`: the incremented copy is computed first, the store uses the old index.
