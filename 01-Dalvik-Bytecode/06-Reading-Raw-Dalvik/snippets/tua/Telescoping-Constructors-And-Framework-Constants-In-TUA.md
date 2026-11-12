---
tags: [snippet]
level: 3
project: "TUA (net.pluservice.tua)"
source: net.pluservice.tua
version: "unknown"
source_path: "smali/net/pluservice/plusnetworking/PlusNetworking.smali"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Telescoping-Constructors-And-Framework-Constants-In-TUA

> [!info] Level 3 — real code
> Two ordinary-looking public constructors that delegate to a private one with an invented extra parameter, whose body opens by decoding strings with keys disguised as Android framework calls.

## Context

`PlusNetworking` is the HTTP client wrapper of the TUA app ([[Tua-Case-Study]]), and it's been processed by a commercial protector: renamed fields, string encryption, junk calls. Its constructors are a good first contact with that kind of code, because the *outer* layer (constructor delegation) is plain compiler output and the *inner* layer (the string decoder setup) is protector output — the contrast trains the eye to tell them apart.

## Original path

`smali/net/pluservice/plusnetworking/PlusNetworking.smali`

## Snippet

```smali
.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Lnet/pluservice/plusnetworking/Ambiente;)V
    .locals 6
    const/4 v4, 0x0                      # rules = null
    const/4 v5, 0x0                      # extra byte = 0
    move-object v0, p0
    move-object v1, p1
    move-object v2, p2
    move-object v3, p3
    invoke-direct/range {v0 .. v5}, L…/PlusNetworking;-><init>(Ljava/lang/String;Ljava/lang/String;L…/Ambiente;[L…/CertificatePinningRule;B)V
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;L…/Ambiente;[L…/CertificatePinningRule;)V
    .locals 6
    const/4 v5, 0x0                      # extra byte = 0
    move-object v0, p0
    move-object v1, p1
    move-object v2, p2
    move-object v3, p3
    move-object v4, p4
    invoke-direct/range {v0 .. v5}, L…/PlusNetworking;-><init>(…[L…/CertificatePinningRule;B)V
    return-void
.end method

.method private constructor <init>(Ljava/lang/String;Ljava/lang/String;L…/Ambiente;[L…/CertificatePinningRule;B)V
    .locals 17
    move-object/from16 v0, p0
    move-object/from16 v1, p4
    invoke-direct/range {p0 .. p0}, Ljava/lang/Object;-><init>()V

    const/16 v2, 0xb
    new-array v3, v2, [C
    fill-array-data v3, :array_0                  # 11-char encrypted blob
    const-string v2, ""
    const/4 v9, 0x0
    invoke-static {v2, v9}, Landroid/text/TextUtils;->getOffsetBefore(Ljava/lang/CharSequence;I)I
    move-result v2                                 # always 0
    const v4, 0x20754a5c
    sub-int/2addr v4, v2                           # key = 0x20754a5c
    const/4 v2, 0x4
    new-array v5, v2, [C
    fill-array-data v5, :array_1
    invoke-static {}, Landroid/view/ViewConfiguration;->getMaximumDrawingCacheSize()I
    move-result v6
    shr-int/lit8 v6, v6, 0x18                      # 1536000 >> 24 = 0
    int-to-char v6, v6
    new-array v7, v2, [C
    fill-array-data v7, :array_2
    const/4 v10, 0x1
    new-array v11, v10, [Ljava/lang/Object;        # 1-slot "out" array
    move-object v8, v11
    invoke-static/range {v3 .. v8}, L…/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V
    aget-object v3, v11, v9                        # result = out[0]
    check-cast v3, Ljava/lang/String;
    invoke-virtual {v3}, Ljava/lang/String;->intern()Ljava/lang/String;
    move-result-object v3
    iput-object v3, v0, L…/PlusNetworking;->d:Ljava/lang/String;
    # ... the same pattern repeats for the next field (69-char blob,
    #     KeyEvent.getModifierMetaStateMask(), Color.red(0), ...)
```

(`L…/` abbreviates `Lnet/pluservice/plusnetworking/`; `.line` directives removed.)

## Reconstructed source

```java
public final class PlusNetworking {
    private String d;   // ... and b, c, e, f, g (OkHttpClient), h

    public PlusNetworking(String a, String b, Ambiente env) {
        this(a, b, env, null, (byte) 0);
    }

    public PlusNetworking(String a, String b, Ambiente env, CertificatePinningRule[] rules) {
        this(a, b, env, rules, (byte) 0);
    }

    private PlusNetworking(String a, String b, Ambiente env, CertificatePinningRule[] rules, byte unused) {
        super();
        this.d = decrypt(BLOB_0, 0x20754a5c, KEY_0, (char) 0, KEY_1).intern();
        // ...
    }
}
```

## Notes

- **Telescoping constructors, compiler layer.** Two public overloads each fill in defaults and forward everything to one "real" constructor through `invoke-direct/range` ([[Invoke-Range-For-Many-Arguments]]). This is plain Java `this(...)` delegation; only the trailing `B` parameter, always `const/4 … 0x0`, is foreign. It doesn't appear in any source-level API and is never read — most likely added by the protector so the real constructor has a descriptor nobody would guess. The same trick as javac's marker parameter in [[Inner-Class-This-Reference-In-PressReader]], different author.
- **Why `/from16` and `/range {p0 .. p0}`?** With `.locals 17`, `p0` is `v17`. Regular `invoke-*` and `move-object` encode registers in 4 bits (`v0`–`v15`), so anything touching `v16`+ must use `move-object/from16` or a `/range` form, even for a single register. These forms appear whenever a method has more than 16 registers and aren't obfuscation.
- **Framework calls as constants.** `TextUtils.getOffsetBefore("", 0)` is always `0`; `ViewConfiguration.getMaximumDrawingCacheSize()` is a fixed framework constant (480 × 800 × 4 = 1 536 000), so `>> 24` is `0`; `Color.red(0)` is `0`; the low byte of `KeyEvent.getModifierMetaStateMask()` is `0xFF` (`-1` as a `byte`). Each call is a constant that a static decompiler can't fold, because it doesn't know the framework's return values. Replace each with its value by hand and the decoder's real arguments appear (`0x20754a5c`, `(char) 0`, …).
- **Out-parameter instead of return.** The decoder `j(...)` returns `void` and writes its result into `out[0]` of a fresh `Object[1]`; the caller reads it back with `aget-object` + `check-cast`. Seeing `new-array vX, 1, [Ljava/lang/Object;` passed as the last argument, then `aget-object …, vX, 0` right after the call, is the signature of this protector's string decryption — useful for grep-driven hunting ([[Hunting-Reflection-With-Grep-And-Set-Difference]] uses the same method).
- **`intern()`** on the decoded string makes every decrypted copy share one instance, so later `==` comparisons on these strings work as they would on literals.
- **Dynamic shortcut.** Rather than emulate `j` statically, hook it with Frida and log `out[0]` after the call, or read field `d` from a live instance with `Java.choose` ([[Finding-Live-Instances-With-Java-Choose]]).

## See also

- [[Reading-Raw-Dalvik]] — worked examples 3, 5, and 7 dissect other parts of this same class
- [[Same-Method-Debug-Vs-R8-Release]] — what normal optimization looks like, for contrast
- [[Fill-Array-Data]]
- [[Tua-Case-Study]]
- [[Dalvik-Bytecode-Reference|Reference]]
