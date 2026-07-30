---
tags: [fundamentals]
aliases: ["Reading Obfuscated Smali", "Cold Reading Dalvik", "Hand-Patching Smali"]
created: 2026-07-30
---

# Reading-Raw-Dalvik

## In short

Every example in [[Classes]] through [[Dalvik-Instructions|Instructions]] is clean, hand-written smali — real method names, no dead code, one idea per snippet — because that's what makes each concept legible in isolation. A real release APK almost never looks like that: a commercial hardening/obfuscation tool has typically renamed every non-public identifier to a short, non-descriptive token (`$$a`, `$10`, or a real Android API name borrowed as camouflage — `onNavigationEvent`, `ICustomTabsCallback`), encrypted every string literal into a byte/char array decoded only at runtime, wrapped security-relevant API calls behind custom reflection helpers so the call site never names its real target, and interleaved all of it with opaque-predicate bookkeeping designed to look identical whether or not it does anything. `jadx` (see [[Dalvik-Bytecode-Bibliography|Bibliography]]) will often choke on code like this — its Java-reconstruction either fails outright or produces something that no longer resembles real Java — which pushes you back to the one thing that's always faithful to what actually executes: raw `baksmali` output, read with no synthesized comments and no decompiler's guesses to lean on. This chapter takes real methods from a single hardened app (the `net.pluservice.tua` case study — see [[Tua-Case-Study]] and its source under `Case-Studies/tua/source/smali/`) and reads them cold, then covers the other half of the same skill: once you've understood what a method does, how to hand-edit its `.smali` to change what it does. As in [[Reading-Raw-Disassembly]], each code block below carries `#` comments — but those are the **reader's own working notes, written after doing the deduction**, not something `baksmali` produced; the prose beneath each block is where the actual reasoning happens.

## Explanation

### The checklist

Seven things to check, roughly in order, whenever a method has non-identifier names and no readable strings:

1. **Separate real control flow from opaque-predicate bookkeeping.** A recurring quadruple — `sget vX, ...:I` / `add-int/lit8 vX, vX, <k>` / `rem-int/lit16 vY, vX, 0x80` / `sput vY, ...:I` / `rem-int/2addr vX, v0` (with `v0` a small constant, usually `2`) — updates a pair of static counters that cycle mod 128. Whether it *matters* depends entirely on one thing: is the final `rem-int/2addr` result register read by anything afterward, or overwritten/discarded before it's ever used? The shape alone never tells you; you have to trace the one register forward.
2. **Identify decoder helper methods by signature, not name.** `private static` methods taking a handful of `B`/`S`/`I`/`C[]` parameters (often with cheap `mul-int/lit8`/`rsub-int/lit8`/`add-int/lit8` transforms applied to them immediately) and returning `Ljava/lang/String;`, or taking a trailing `[Ljava/lang/Object;` out-parameter and writing index `0`, are string decoders — called repeatedly, each call site supplying different literal arguments and a different `fill-array-data` block, never a plain `const-string`.
3. **Recognize reflection indirection.** A call to a one-`int`-argument static method (a cache lookup by an opaque numeric key) immediately `if-nez`-checked; on a cache miss, a slow path builds a class/member name (often via a decoder from #2) and calls a second, differently-shaped static method that actually resolves it; either way the result is `check-cast` to `Ljava/lang/reflect/{Field,Method,Constructor}` and immediately `.get`/`.set`/`.invoke`d. The real API being called never appears as a plain `invoke-*` anywhere in the method.
4. **Treat a null-check on a `private static final` field as almost always dead.** A field written exactly once, inside `<clinit>`, is guaranteed non-null by the time any other static method on that class becomes reachable — Dalvik runs `<clinit>` first. `if-nez <that field>, :cond_X` guarding an alternate path is boilerplate for confusing CFG-recovery tools, not a real branch; the live path is the one that runs after the class has obviously already finished initializing.
5. **Follow register aliasing across merge points.** Blocks of `move vA, vB` / `move vB, vA`-style shuffling right before a `goto` that rejoins another branch exist so that whichever path you came from, the registers hold values in the positions the joined code expects — this is data plumbing, not computation; skip past it once you've confirmed what ends up where.
6. **Don't trust a single pass over a register-swap-heavy accumulator loop.** A loop that carries a running value across iterations through repeated `move vA, vB` / `move vB, vA` pairs (rather than one stable accumulator register) is easy to mis-trace: which physical register holds "the running value" and which holds "the table cursor" can trade places every iteration, purely as instruction-stream plumbing. Recognize the shape, but verify the recurrence mechanically — reimplement the handful of arithmetic instructions in a short script, or call the real method dynamically (see [[Frida-Dynamic-Instrumentation]]) — rather than trust one manual trace; a single misread swap produces a wrong description of the algorithm that still looks entirely plausible, with no local signal that anything went wrong.
7. **Separate shape from identity, same as in [[Reading-Raw-Disassembly]].** "This resolves some reflective member via a decoded name and invokes it" is a shape-only conclusion, reachable from the bytes alone. "This is `PackageManager.getPackageInfo`" or "this string is `SCRTYMANAGER`" is identity — supplied by dynamic tracing (as in [[Anti-Tampering-Pattern-Workflow]]) or by actually running the decoder, never by staring at the arithmetic harder.

### A note on honesty

Nothing below claims to divine a decoded string's exact contents from the arithmetic alone where doing so would require hand-simulating a loop with data-dependent addressing — checklist item 6 exists precisely because that kind of hand-tracing is where confident-sounding static analysis quietly goes wrong. Where the bytes genuinely can't settle a question without running the code, the prose says so and says what to do instead, the same policy [[Reading-Raw-Disassembly]] follows for stripped ARM64.

## Worked example 1 (simple): a lazy-init cache mistaken for a security check

`DeviceIdProvider.onMessageChannelReady()`, from `Case-Studies/tua/source/smali/net/pluservice/plugins/DeviceInformation/DeviceIdProvider.smali` — the one obfuscated-looking method in an otherwise plain, readable class, which is exactly why it's worth reading cold first:

```smali
.method public static onMessageChannelReady()I
    .locals 2
    sget v0, Lnet/pluservice/plugins/DeviceInformation/DeviceIdProvider;->onNavigationEvent:I   # v0 = call counter (starts at 0, never reset)
    const v1, 0x944f68                    # v1 = 9,762,664 (an odd, specific modulus)
    rem-int v1, v0, v1                    # v1 = v0 mod 9762664
    add-int/lit8 v0, v0, 0x1              # v0 += 1
    sput v0, Lnet/pluservice/plugins/DeviceInformation/DeviceIdProvider;->onNavigationEvent:I   # persist the incremented counter
    if-eqz v1, :cond_0                    # first call (v0 was 0, so v0 mod anything == 0) -> recompute
    sget v0, Lnet/pluservice/plugins/DeviceInformation/DeviceIdProvider;->onMessageChannelReady:I  # every later call -> return the cached value
    return v0
    :cond_0
    invoke-static {}, Landroid/os/Process;->getElapsedCpuTime()J
    move-result-wide v0
    long-to-int v0, v0
    sput v0, Lnet/pluservice/plugins/DeviceInformation/DeviceIdProvider;->onMessageChannelReady:I  # cache it
    return v0
.end method
```

Reading it cold: two static `int` fields, one used purely as a call counter (checklist #1's quadruple shape is nowhere in sight — this is a *different*, simpler idiom). `v0 mod 0x944f68` is zero exactly when `v0` is a multiple of 9,762,664 — which, since `v0` only ever increments by one starting from zero, is true on the very first call and then not again for 9.7 million subsequent calls, i.e. for all practical purposes "true once, then never." That makes the `:cond_0` block a one-time initializer and everything past `if-eqz` on every later call a plain cache read — the entire method is `getElapsedCpuTime()`, computed once and memoized behind a modulus check standing in for a boolean flag. Nothing here reads like the `(JJ)V`-signature reflection hideouts [[Anti-Tampering-Pattern-Workflow]] found dynamically elsewhere in this same app, and nothing here is gated by anything an attacker or a debugger could meaningfully trip — it's just an odd way to write "if this is the first call, compute; otherwise, return the cached value."

**Shape-only conclusion:** a modulus-against-a-large-constant check that is true on call zero and structurally cannot be true again for millions of calls is a disguised one-shot lazy-init guard, not a security gate. **Needs a lookup:** nothing — this one resolves completely from the bytes, which is exactly the point of starting here: not every unusual-looking arithmetic gate in a hardened app is a trap, and confusing "looks like the obfuscator's other tricks" with "is one" wastes real investigation time. Compare directly against the `if-eqz`/`if-nez` gates in worked example 2, which use the checklist-#1 quadruple and *do* gate something adversarial.

## Worked example 2 (medium): three lifecycle overrides, one shared bookkeeping shape, two different intents

Four methods from `MainActivity.smali`, all overriding `CordovaActivity` lifecycle callbacks, all built from the exact same checklist-#1 quadruple — but only some of them actually consume what it computes.

`onCreate` first, since it's the control case — the quadruple appears **three times**, and every single occurrence is dead:

```smali
.method public onCreate(Landroid/os/Bundle;)V
    .locals 3
    const/4 v0, 0x2
    rem-int v1, v0, v0                     # v1 = 0, dead: overwritten below before any read
    invoke-super {p0, p1}, Lorg/apache/cordova/CordovaActivity;->onCreate(Landroid/os/Bundle;)V
    invoke-virtual {p0}, Lnet/pluservice/tua/MainActivity;->getIntent()Landroid/content/Intent;
    move-result-object p1
    invoke-virtual {p1}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;
    move-result-object p1
    if-eqz p1, :cond_1                     # <- the one REAL branch in this method: "were there extras at all?"
    sget v1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I
    add-int/lit8 v1, v1, 0x69
    rem-int/lit16 v2, v1, 0x80
    sput v2, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I
    rem-int/2addr v1, v0                   # v1 computed... and never read: overwritten by the next line
    const-string v1, "cdvStartInBackground" # <- the real work starts here
    const/4 v2, 0x0
    invoke-virtual {p1, v1, v2}, Landroid/os/Bundle;->getBoolean(Ljava/lang/String;Z)Z
    move-result p1
    const/4 v1, 0x1
    if-eq p1, v1, :cond_0                  # <- the other REAL branch: "was that extra true?"
    goto :goto_0
    :cond_0
    sget p1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I
    add-int/lit8 p1, p1, 0x2b
    rem-int/lit16 v2, p1, 0x80
    sput v2, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I
    rem-int/2addr p1, v0                   # again dead: p1 is overwritten right after
    invoke-virtual {p0, v1}, Lnet/pluservice/tua/MainActivity;->moveTaskToBack(Z)Z
    :cond_1
    :goto_0
    iget-object p1, p0, Lnet/pluservice/tua/MainActivity;->launchUrl:Ljava/lang/String;
    invoke-virtual {p0, p1}, Lnet/pluservice/tua/MainActivity;->loadUrl(Ljava/lang/String;)V
    sget p1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I
    add-int/lit8 p1, p1, 0x55
    rem-int/lit16 v1, p1, 0x80
    sput v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I
    rem-int/2addr p1, v0                   # dead a third time: the method returns immediately after
    return-void
.end method
```

The actual logic here is ordinary Cordova boilerplate — read the `cdvStartInBackground` intent extra, optionally call `moveTaskToBack`, then `loadUrl`, gated by two genuine `if`s that have nothing to do with counters. Every one of the three quadruples computes a `mod 2` result that gets immediately clobbered or the method returns before it's read; they exist purely so that grepping for "a counter update right before a branch" can't distinguish this method from `onPause` below by syntax alone.

`onPause`, `onResume`, and `onStart` share the identical quadruple shape, but here the mod-2 result is the branch condition itself, and each gates a different crash:

```smali
.method public onPause()V
    .locals 3
    const/4 v0, 0x2
    rem-int v1, v0, v0
    sget v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I
    add-int/lit8 v1, v1, 0x4f
    rem-int/lit16 v2, v1, 0x80
    sput v2, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I
    rem-int/2addr v1, v0                   # v1 IS read next -- this quadruple is live
    invoke-super {p0}, Lorg/apache/cordova/CordovaActivity;->onPause()V
    if-eqz v1, :cond_0
    const/16 v1, 0x21
    div-int/lit8 v1, v1, 0x0                # ArithmeticException: divide by zero, unconditionally on this path
    :cond_0
    sget v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I
    add-int/lit8 v1, v1, 0x1f
    rem-int/lit16 v2, v1, 0x80
    sput v2, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I
    rem-int/2addr v1, v0                    # dead: method returns right after
    return-void
.end method
```

```smali
.method public onResume()V
    .locals 3
    const/4 v0, 0x2
    rem-int v1, v0, v0
    sget v1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I
    add-int/lit8 v1, v1, 0x65
    rem-int/lit16 v2, v1, 0x80
    sput v2, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I
    rem-int/2addr v1, v0                    # live
    invoke-super {p0}, Lorg/apache/cordova/CordovaActivity;->onResume()V
    if-eqz v1, :cond_0
    return-void
    :cond_0
    const/4 v0, 0x0
    throw v0                                 # NullPointerException: throwing a null reference directly
.end method
```

```smali
.method public onStart()V
    .locals 3
    const/4 v0, 0x2
    rem-int v1, v0, v0
    sget v1, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I
    add-int/lit8 v1, v1, 0xb
    rem-int/lit16 v2, v1, 0x80
    sput v2, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I
    rem-int/2addr v1, v0                     # dead: v1 is overwritten by the very next sget
    invoke-super {p0}, Lorg/apache/cordova/CordovaActivity;->onStart()V
    sget v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I
    add-int/lit8 v1, v1, 0x19
    rem-int/lit16 v2, v1, 0x80
    sput v2, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I
    rem-int/2addr v1, v0                     # this SECOND quadruple is the live one
    if-nez v1, :cond_0
    return-void
    :cond_0
    const/4 v0, 0x0
    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I  # NullPointerException fires HERE, on the virtual call
    throw v0                                 # unreachable: control never gets here, the line above already threw
.end method
```

Reading these cold in sequence is the actual exercise: `onPause` and `onResume` each contain exactly one quadruple, and it's trivially live (nothing overwrites `v1` between the `rem-int/2addr` and the `if-*z`); `onStart` contains **two**, back to back, and only checking whether each result register survives to the following `if` tells you the first is dead filler and the second is the real gate — you cannot tell which is which from the shape of the quadruple itself, only from what happens to the register it writes. Three different crash primitives are used across the three methods — `div-int/lit8 ..., 0x0` (ArithmeticException), `throw` on a register known to hold `0`/null (NullPointerException), and `invoke-virtual` on that same null register (also NullPointerException, one instruction earlier than the redundant trailing `throw` that follows it) — which is worth noticing on its own: an obfuscator that only ever inserted `div-int ..., 0x0` would be defeated by a single grep for that one pattern, exactly the gap [[Anti-Tampering-Pattern-Workflow]] ran into when it found only 224 of an unknown larger total and had to keep widening its search.

**Shape-only conclusion:** four methods, one shared bookkeeping idiom, three genuine crash traps (one per non-`onCreate` method) and a matching pile of dead instances of the identical shape used as camouflage in all four — distinguishable from each other only by tracing one register forward from the quadruple to its next (or absent) use. **Needs a lookup:** what actually toggles `ICustomTabsCallbackStub`/`extraCallbackWithResult` between "the mod-2 result is 0" and "it's 1" at real run time (i.e. whether these traps ever fire during normal use, or only under conditions the app considers tampering) — exactly what [[Anti-Tampering-Pattern-Workflow]] answers dynamically for the sibling `(JJ)V` hideouts, via the same "observe with Frida first, generalize the shape second" method.

## Worked example 3 (deep): a self-referential byte-stream string decoder

`MainActivity.$$i(ISB)Ljava/lang/String;`, one of three near-identical decoder helpers in this class (the others, `a(BBI[Ljava/lang/Object;)V` and `c(SSS[Ljava/lang/Object;)V`, differ only in parameter shapes and which static byte array they read from):

```smali
.method private static $$i(ISB)Ljava/lang/String;
    .locals 6
    mul-int/lit8 p1, p1, 0x2        # p1 *= 2         )
    rsub-int/lit8 v0, p1, 0x1       # v0 = 1 - p1     ) cheap linear disguise --
    mul-int/lit8 p2, p2, 0x2        # p2 *= 2         ) v0/p2/p0 are really just
    add-int/lit8 p2, p2, 0x7a       # p2 += 0x7a      ) "length", "seed" and
    mul-int/lit8 p0, p0, 0x3        # p0 *= 3         ) "table start index"
    rsub-int/lit8 p0, p0, 0x3       # p0 = 3 - p0     )
    sget-object v1, Lnet/pluservice/tua/MainActivity;->$$c:[B   # v1 = the static key/delta table (private static final)
    new-array v0, v0, [B            # output = new byte[v0]        <- v0 is the disguised length
    const/4 v2, 0x0
    rsub-int/lit8 p1, p1, 0x0       # p1 = -p1                     <- loop-termination value
    if-nez v1, :cond_0              # ALWAYS taken: v1 is a private static final field, set once in <clinit>
    move v4, p2
    move v3, v2
    move p2, p0
    goto :goto_1                    # dead path -- register-shuffling twin of the live one below, never reached
    :cond_0
    move v3, v2                     # v3 = 0 (output write index) -- the real entry point
    :goto_0
    add-int/lit8 p0, p0, 0x1        # advance the table cursor
    int-to-byte v4, p2               # truncate the running value to a byte
    aput-byte v4, v0, v3             # output[v3] = that byte
    if-ne v3, p1, :cond_1            # loop until the write index reaches the (disguised) length
    new-instance p0, Ljava/lang/String;
    invoke-direct {p0, v0, v2}, Ljava/lang/String;-><init>([BI)V
    return-object p0
    :cond_1
    add-int/lit8 v3, v3, 0x1
    aget-byte v4, v1, p0             # read the NEXT delta from the key table, at the CURSOR just advanced above
    move v5, p2
    move p2, p0
    move p0, v5                      # register reshuffle to realign with the :goto_1 join point
    :goto_1
    add-int/2addr p0, v4              # running value += delta just read
    move v5, p2
    move p2, p0
    move p0, v5
    goto :goto_0
.end method
```

Reading it cold: the first six instructions are pure algebra on the three parameters — `mul`/`rsub`/`add` by small literal constants — which is checklist item #2's "cheap transform disguising length/seed/offset" in its purest form; undoing `v0 = 1 - 2*p1` and `p0 = 3 - 3*p0` is ordinary linear-equation work, safe to do by hand, and it's what turns three meaningless-looking call-site integers into "how many bytes come out," "what value the decode starts from," and "where in the key table to start reading." The `if-nez v1, :cond_0` right after is checklist item #4 exactly: `$$c` is `private static final`, assigned once inside `<clinit>` (see the array-data block in the same file), so by the time any instance method on `MainActivity` can call this static helper, `$$c` is unconditionally non-null — the `:cond_0`-vs-fall-through split is a second, permanently-unreachable copy of the same logic (compare the register moves in each branch: `v3, v2` vs `v4, p2` — same values, different names, feeding the same `:goto_0`/`:goto_1` join), present purely to give a decompiler two paths to reconcile instead of one. The loop body is where checklist item #6's register-swap hazard lives: `p0` and `p2` trade roles twice per iteration (once at `:cond_1`, once at `:goto_1`), so it's easy to lose track of which one currently holds "the table cursor" and which holds "the running value." Followed slowly, though, the two never actually mix: `p0` always advances by a plain `add-int/lit8 p0, p0, 0x1` — a fixed, one-delta-per-output-byte stride through `$$c` — and only `p2`, truncated to a byte and written out each iteration, accumulates, each output byte becoming the previous running value plus whatever delta `$$c` held at the next fixed position.

**Shape-only conclusion:** `$$i` is a keyed **cumulative-delta (prefix-sum) decoder**, not an address-computed one — three call-site integers (each disguised behind cheap linear arithmetic) select an output length, a starting value, and a starting position in a shared static delta table; the loop then walks that table at a fixed stride, accumulating each output byte from the one before it, until it has produced `length` bytes, and wraps them in a `String`. **Needs a lookup:** the exact decoded text of any given call site, and the real byte contents of `$$c` — the recurrence itself is now fully known, but summing two dozen table deltas by hand, correctly, for every call site in this file, is exactly the kind of mechanical work checklist item #6 says to hand off to a script (or to settle by calling `$$i` dynamically via Frida and reading back its real return value, the same style of technique [[Anti-Tampering-Pattern-Workflow]] used throughout its own investigation) rather than trust to a manual trace — knowing the algorithm doesn't make hand-summing it any less error-prone.

## Worked example 4 (medium-complex): recognizing a hideout with nothing but its declared signature

Not every method worth reading cold has a body worth reading — sometimes the entire "reading" is a `.method` line, an `.end method` line, and the fact that nothing in between was ever imported into this case study. `Case-Studies/tua/source/anti-tampering-workflow.md` records the exact grep that found this app's real root-detection hideout and its siblings, once dynamic investigation (hooking `Log`, reading the stack trace at the moment `"SCRTYMANAGER: RunningOnRootedDeviceException exception: -7"` gets logged — see [[Anti-Tampering-Pattern-Workflow]]) had confirmed the first one:

```
grep -rn "^\.method public static \w+(JJ)V" smali/
```

Fifteen hits, none in a class whose name suggests anything security-related:

```
android/support/v4/media/MediaBrowserCompatApi26.smali
net/pluservice/plusnetworking/R$anim.smali
com/google/zxing/RGBLuminanceSource.smali
com/google/zxing/pdf417/decoder/ec/ModulusPoly.smali
com/google/zxing/oned/UPCEANExtension2Support.smali        # <- the confirmed root-check hideout
com/google/firebase/R$drawable.smali
com/google/gson/internal/UnsafeAllocator$2.smali
com/google/zxing/client/android/encode/VCardContactEncoder.smali
com/google/android/gms/measurement/internal/zzep.smali
com/google/android/gms/dynamite/DynamiteModule$LoadingException.smali
com/google/android/gms/common/api/internal/ApiKey.smali
com/google/android/gms/common/api/internal/zaf.smali
o/setButtonDrawable.smali
o/setImeOptions.smali
o/setOnSearchClickListener.smali
```

Reading it cold: `com.google.zxing.oned.UPCEANExtension2Support` decodes barcode extension segments (a real ZXing library class, not written by this app's own developers); `com.google.zxing.RGBLuminanceSource` converts pixel data for the same barcode library; `com.google.firebase.R$drawable`/`net.pluservice.plusnetworking.R$anim` are Android resource classes, which by construction hold only `int` constants and never carry logic of their own. None of these fifteen classes has any legitimate reason to declare a `public static` method taking two opaque `long`s and returning nothing — the `(JJ)V` signature isn't inherently suspicious on its own (plenty of real Android callbacks look exactly like this), but paired with **which class it sits in**, checklist item #4's "semantic mismatch between context and content" applies at the scale of an entire class list, not just one field. [[Anti-Tampering-Pattern-Workflow]] confirmed, dynamically, that `UPCEANExtension2Support.onMessageChannelReady(long, long)` really is invoked via reflection from `FirebaseInitProvider.onCreate()` — the one entry on this list the case study's `neutralize_root_check.js` and `combined.js` scripts (in `Case-Studies/tua/source/`) target directly by name; the other fourteen were never individually confirmed to fire on their own, only grouped in because they share the exact signature of the ones that were.

**Shape-only conclusion:** a `public static (JJ)V` method inside a class with no legitimate reason to have one is a hideout candidate; the signature alone says nothing about what a given instance actually checks, or whether it's even reachable in a given run. **Needs a lookup:** everything else — which of the fifteen actually fire, in what order, and what each real body does — is exactly what reading a bare signature can never answer, and exactly what [[Anti-Tampering-Pattern-Workflow]]'s dynamic-triage-first workflow exists to answer instead. This is the sharpest illustration in this chapter of checklist item #7's shape-vs-identity split: the shape (a suspiciously-signatured method in the wrong class) is available from a grep alone; the identity (which ones are real checks, what each compares, what "not rooted" looks like to each) needs the dynamic half of this vault's toolkit — see [[Frida-Dynamic-Instrumentation]], specifically [[Anti-Detection-And-Gadget-Mode]]'s treatment of exactly this class of check. Patch 5, further down, covers what a static, permanent fix looks like once you're willing to act on the shape alone, without ever seeing a real body.

## Worked example 5 (expert): reflection indirection, and the same decode-then-consume shape repeated N times

Two excerpts, both showing checklist item #3 in the wild: first a single reflective field read from `MainActivity.attachBaseContext`, arguably the single most obfuscated method in this app; then a repeated pattern from `PlusNetworking.post()` that is structurally the same idea used for something completely different.

`attachBaseContext`'s first reflective field read (the full method repeats this six-step shape more than a dozen times end to end — only one instance is walked here, the rest are exercises in recognizing the same seven-step shape already learned):

```smali
const v0, 0x2f51eb39                          # opaque literal: a memoization key, not a meaningful constant
invoke-static {v0}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;   # step 1: cache lookup by that key
move-result-object v0
if-nez v0, :cond_0                            # cache hit -> skip straight to step 2's result
    invoke-static {}, Landroid/view/ViewConfiguration;->getMaximumFlingVelocity()I
    move-result v0
    shr-int/2addr v0, v5
    add-int/2addr v0, v2
    int-to-char v9, v0                         # )
    ...                                         # ) build the resolver's CIIIZ + decoded-String + Class[] arguments
    invoke-static {v1, v2, v0, v3}, Lnet/pluservice/tua/MainActivity;->a(BBI[Ljava/lang/Object;)V  # decode a name (checklist #2)
    aget-object v0, v3, v8
    check-cast v14, Ljava/lang/String;
    invoke-static/range {v9 .. v15}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;  # step 2: the real resolver
    move-result-object v0
:cond_0
check-cast v0, Ljava/lang/reflect/Field;       # either way, v0 is now a reflective Field
invoke-virtual {v0, v6}, Ljava/lang/reflect/Field;->getLong(Ljava/lang/Object;)J   # step 3: actually use it
```

Reading it cold: `extraCallbackWithResult(I)` takes one bare `int` and is immediately `if-nez`-checked — a cache-lookup-by-opaque-key shape identical to worked example 1's, except here a cache *miss* doesn't compute a value directly, it falls through to build arguments (several of them themselves disguised as unrelated `ViewConfiguration`/`Color`/`TextUtils` API results added to constants, then narrowed with `int-to-char`) for a *second* static call, `onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;`, whose name and five-`char`/`int`-plus-`boolean`-plus-`String`-plus-`Class[]` signature is exactly what you'd expect from a general-purpose "resolve and cache a reflective member" helper — enough parameters to encode a target class, a member name (built here via the `a(...)` decoder from worked example 3's family), a member kind, and the parameter types needed to disambiguate an overload. Whichever path is taken, the result is `check-cast` to `Ljava/lang/reflect/Field` and its value read with `.getLong(Object)` — the real API being reached for is never named as a plain `invoke-*` anywhere in this method; only `check-cast Ljava/lang/reflect/Field` and the shape of the call that follows (`.getLong`, `.get`, `.set`, or `Ljava/lang/reflect/Method;->invoke`) say what kind of member it ultimately is. This is the same `onMessageChannelReady`/`extraCallbackWithResult` name pair [[Anti-Tampering-Pattern-Workflow]] found dynamically hiding the root-check call in `UPCEANExtension2Support` — seeing it here, gating a `Field.getLong` instead, confirms it's a general-purpose indirection helper reused throughout the app, not a one-off.

The same three-step shape (cache-check, resolve-if-miss, then act on the resolved member) repeats with `Ljava/lang/reflect/Method;->invoke`, `.get`, and `.set` targets throughout the rest of `attachBaseContext` — recognizing it once, per checklist item #7, is what lets you skim the remaining dozen-plus instances by their *outcome type* (`getLong` vs `invoke` vs `.set`) instead of re-deriving the cache/resolve machinery from scratch each time.

`PlusNetworking.post()` reuses the *decoder* half of the same instinct (checklist #2, not #3) for something unrelated — building HTTP request headers — repeating one shape once per header:

```smali
new-array v11, v3, [C
fill-array-data v11, :array_0          # )
...                                      # ) four char[] literals + assorted int noise:
new-array v13, v9, [C                    # ) the exact argument shape j([CI[CC[C[Ljava/lang/Object;)V expects
fill-array-data v13, :array_1            # )
...
invoke-static/range {v11 .. v16}, Lnet/pluservice/plusnetworking/PlusNetworking;->j([CI[CC[C[Ljava/lang/Object;)V
aget-object v4, v3, v10
check-cast v4, Ljava/lang/String;
invoke-virtual {v4}, Ljava/lang/String;->intern()Ljava/lang/String;
move-result-object v4
...
invoke-virtual {v2, v3, v4}, Lokhttp3/Request$Builder;->header(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;   # <- the only line that differs in intent across repetitions
```

This block — build four `char[]` literals via `fill-array-data`, call `j(...)`, `check-cast` and `.intern()` the result, then feed it to `.header(...)` — appears (with only the literal array contents differing) once for the request URL, then again for each HTTP header name and, for most of them, again for the header value, exactly the same "same seven instructions, once per field" idiom [[Reading-Raw-Disassembly]] documents for a Dart JSON deserializer: recognizing the repeated shape tells you "this function is building N headers" without needing to decode a single one of the `char[]` literals by hand. The one call that *isn't* this shape is `Lnet/pluservice/plusnetworking/a/a;->a(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;`, invoked on a helper object built in the constructor from two already-decoded strings (`d`/`e`) and fed a base string assembled from the request path, a millisecond timestamp, and a per-instance UUID (`f`) — `a/a.smali` itself was never imported into this case study (see [[Tua-Case-Study]]'s "only import the fragments actually needed" note), so this call can only be reasoned about by its **surroundings**: something that combines a secret-shaped pair of strings with a timestamped, per-request base string and returns one more string, fed straight into a signature-shaped header, is a request-signing/HMAC call whether or not its body is ever read — black-box shape reasoning is sometimes the honest final answer, not a placeholder for "should look this up later."

**Shape-only conclusion:** `attachBaseContext` resolves upward of a dozen reflective class members through one shared cache-then-resolve helper pair, never naming a single one of them as a plain `invoke-*`; `PlusNetworking.post()` reuses the string-decoder idiom from worked example 3 once per HTTP header, plus one opaque call that is legible only as "sign this request" from its inputs and placement. **Needs a lookup:** which concrete `Field`/`Method` each `attachBaseContext` call site resolves (the case study's dynamic-triage method — hook `Log`/stack-trace, or here, hook `Field.getLong`/`Method.invoke` themselves — settles this far faster than decoding every argument by hand), and what `a/a.smali`'s signing algorithm actually is, which needs importing that file before it can be answered at all.

## Worked example 6 (expert+): reused names as key material, and reflection indirection per character

`PlusNetworking.j([CI[CC[C[Ljava/lang/Object;)V` is the decoder every string literal in this class runs through — worked example 5's header-building loop calls it once per header. Its setup, in `ICustomTabsCallback()V`, looks unremarkable in isolation:

```smali
.method static ICustomTabsCallback()V
    .locals 2
    const-wide v0, -0x120f87db1000b25bL
    sput-wide v0, Lnet/pluservice/plusnetworking/PlusNetworking;->ICustomTabsCallback:J   # 64-bit key material
    const v0, -0x36134583
    sput v0, Lnet/pluservice/plusnetworking/PlusNetworking;->onMessageChannelReady:I       # 32-bit key material
    const v0, 0xba7d
    sput-char v0, Lnet/pluservice/plusnetworking/PlusNetworking;->onNavigationEvent:C      # 16-bit key material
    const/16 v0, 0x19
    new-array v0, v0, [C
    fill-array-data v0, :array_0
    sput-object v0, Lnet/pluservice/plusnetworking/PlusNetworking;->extraCallbackWithResult:[C   # a 25-char lookup table
    const v0, 0xeb67
    sput-char v0, Lnet/pluservice/plusnetworking/PlusNetworking;->extraCallback:C          # another 16-bit key
    return-void
.end method
```

Every one of these five field names is borrowed from real Android APIs — `onMessageChannelReady`, `onNavigationEvent`, `ICustomTabsCallback`, `extraCallback`, `extraCallbackWithResult` are exactly the names [[Anti-Tampering-Pattern-Workflow]]'s own camouflage table catalogues, where in `MainActivity`/`CordovaActivity` they hold mod-128 opaque-predicate counters (worked example 2). Here, in a different class, the same five names hold something else entirely: fixed-width integer/char constants and one lookup table, set once and never reassigned — key material for a cipher, not counters for a trap. Nothing about a name tells you which role it plays in a given class; only watching how it's actually used does — the same caution [[Anti-Tampering-Pattern-Workflow]] draws for `.super Lo/getActiveNotifications;`, generalized here to a third role for names the case study already knew had at least two.

Inside `j()`'s per-character loop, a XOR cascade against exactly those five fields produces each output character:

```smali
iget-char v5, v4, Lo/getLifecycle;->extraCallbackWithResult:C   # v5 = a per-character value resolved via reflection (see below)
aput-char v5, v6, v3

iget v5, v4, Lo/getLifecycle;->onNavigationEvent:I               # v5 = loop index i
iget v7, v4, Lo/getLifecycle;->onNavigationEvent:I                # v7 = i again
aget-char v7, v0, v7                                              # v7 = input[i]  (p0, the caller's own char[])
aget-char v3, v6, v3                                               # v3 = the value just written above
xor-int/2addr v3, v7                                               # v3 = input[i] XOR that value
int-to-long v9, v3                                                 # widen into the running accumulator v9-v10

sget-wide v11, Lnet/pluservice/plusnetworking/PlusNetworking;->ICustomTabsCallback:J
const-wide v13, 0x10516a81c9ecba7dL                                # a fixed 64-bit magic constant
xor-long/2addr v11, v13
xor-long/2addr v9, v11                                             # accumulator ^= (key1 ^ magic)

sget v3, Lnet/pluservice/plusnetworking/PlusNetworking;->onMessageChannelReady:I
int-to-long v11, v3
xor-long/2addr v11, v13
long-to-int v3, v11
int-to-long v11, v3
xor-long/2addr v9, v11                                             # accumulator ^= truncate32(key2 ^ magic)

sget-char v3, Lnet/pluservice/plusnetworking/PlusNetworking;->onNavigationEvent:C
int-to-long v11, v3
xor-long/2addr v11, v13
long-to-int v3, v11
int-to-char v3, v3
int-to-long v11, v3
xor-long/2addr v9, v11                                             # accumulator ^= truncate16(key3 ^ magic)

long-to-int v3, v9
int-to-char v3, v3
aput-char v3, v2, v5                                                # output[i] = accumulator, truncated to char
```

Reading it cold: this is a plain XOR cascade, not a Feistel-style mixing round — a separate, unrelated `0x9e37`-decrementing counter appears elsewhere in `j()`, but that one belongs to the same dead mod-128 bookkeeping quadruple as worked example 2 (`sget v5, ...$10:I` / `add-int/lit8` / `rem-int/lit16` / `sput`, its result overwritten by `move-result-object v5` a few lines later — dead exactly the same way `onCreate`'s three copies were, now confirmed in a third class). Stripped of the register bookkeeping: `output[i] = input[i] XOR v6[i] XOR (ICustomTabsCallback:J XOR MAGIC) XOR truncate32(onMessageChannelReady:I XOR MAGIC) XOR truncate16(onNavigationEvent:C XOR MAGIC)`, where every term past `v6[i]` is **the same value on every iteration** — the loop recomputes three loop-invariant quantities from scratch, XOR-ing each against the identical 64-bit magic literal and re-truncating, every single character, instead of hoisting that work out once before the loop starts. That redundant per-character recomputation of an invariant is worth recognizing as its own idiom: it changes nothing about what the code computes, only how much of it a disassembly listing — and an analyst's patience — has to wade through per character.

`v6[i]` — the one genuinely per-character input — comes from `iget-char v5, v4, Lo/getLifecycle;->extraCallbackWithResult:C`, a field on the loop's own small per-call helper object (`Lo/getLifecycle`, itself a borrowed, unrelated Android name), populated earlier in the same iteration by the reflection-indirection idiom from checklist item #3 and worked example 5: cache-check via `Lo/ResultReceiver;->extraCallbackWithResult(I)`, resolve-on-miss via `Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)`, `check-cast` to `Ljava/lang/reflect/Method`, `.invoke`, `check-cast` the result to `Ljava/lang/Character`, `.charValue()`. The difference from every earlier instance of that idiom in this chapter is *where* it sits: in `attachBaseContext` it runs once per resolved class member; here it runs **once per output character**, inside the hot loop — the same three-step shape, just paid for at a completely different rate.

**Shape-only conclusion:** `j()` XORs each input character against a per-character, reflectively-resolved value and three constant, loop-invariant quantities derived from static fields that borrow real Android API names — the same names [[Anti-Tampering-Pattern-Workflow]] already found playing a counter role elsewhere in this app, here playing a key-material role instead. **Needs a lookup:** what the per-character reflective call actually invokes (worked example 5's caution about resolving `attachBaseContext`'s reflection chain applies here too, at a higher multiplicity — once per character instead of once per member), and the real values behind `ICustomTabsCallback:J`/`onMessageChannelReady:I`/`onNavigationEvent:C`/`extraCallback:C`/`extraCallbackWithResult:[C` — all static, so a debugger breakpoint or a one-line Frida field read (`Java.use("...PlusNetworking").ICustomTabsCallback.value`, once the class has loaded) settles them without touching the decode loop at all.

## More patterns worked cold

Four shorter, isolated call-outs, each reinforcing one checklist item without a full end-to-end walk.

### The dead null-check on a just-initialized static final field

Seen fully in worked example 3 (`if-nez $$c, :cond_0`). The general test: is the checked field declared `private static final`, and is it written exactly once, inside `<clinit>`? If so, every other method in the class can only ever observe it as non-null, and a null-check branch on it is dead by construction — no need to trace registers to confirm this one, the field's own declaration already answers it.

### Cache-then-resolve-via-custom-reflection, generalized

Worked example 5's `extraCallbackWithResult(I)` / `onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)` pair is one instance of a broader idiom: any single-`int`-argument static call, immediately `if-nez`-checked, where the miss path builds a name (usually via a decoder) and calls a second, differently-shaped static method before `check-cast`ing the result to a `java.lang.reflect.*` type. Once you've matched this shape once in a given app, grepping for the same two method names (`extraCallbackWithResult`/`onMessageChannelReady` here, but the obfuscator's naming is per-build) finds every other call site without re-deriving the pattern — exactly [[Anti-Tampering-Pattern-Workflow]]'s "generalize a confirmed shape into a static grep" step, applied to reflection indirection instead of `div-int ..., 0x0`.

### The same decode-then-consume idiom, once per argument

Worked example 5's header-building loop in `PlusNetworking.post()` is the general case of "the same N-instruction block, repeated once per field, only its literal arguments differing" — the same shape [[Reading-Raw-Disassembly]] calls out for a Dart JSON deserializer. Counting how many times the block repeats before the surrounding code changes intent (here: URL, then each header) tells you how many things are being built without decoding a single one.

### The same decoder, two calling conventions

`MainActivity.a(BBI[Ljava/lang/Object;)V` and `c(SSS[Ljava/lang/Object;)V` — used throughout `attachBaseContext` and elsewhere in this class — run the exact same cumulative-delta decode as `$$i` (worked example 3): a fixed-stride cursor through a static byte table (`$$a`/`$$g` respectively, siblings of `$$c`), the same `if-nez <table>, :cond_0` dead null-guard, the same two-swap-per-iteration register dance. The only real difference is calling convention: instead of `return-object`, they write the decoded `String` into index `0` of a trailing `[Ljava/lang/Object;` out-parameter (`aput-object p0, p3, v2`) — a shape checklist item #2 already calls out as its own recognizable variant. Once `$$i` has been traced once, matching `a()`/`c()` against it (same loop shape, different exit) is enough to confirm they run the same algorithm without re-deriving the recurrence from first instructions again — verifying a second instance against a first you already trust is faster, and less error-prone, than tracing each cold from scratch.

## Manipulating Dalvik methods

Reading a method is half the skill; the other half is changing what it does once you understand it — either to strip a check like the ones above, or to add your own instrumentation directly into the `.smali` rather than at runtime with Frida.

### The edit-reassemble-resign loop

```mermaid
graph LR
    A[APK] -->|apktool d / baksmali d| B[.smali tree]
    B -->|hand edit| C[patched .smali tree]
    C -->|apktool b / smali a| D[unsigned patched APK / dex]
    D -->|zipalign + apksigner sign| E[installable patched APK]
```

`apktool d app.apk -o out/` (or the lower-level `baksmali d classes.dex -o out/`, which `apktool` wraps) turns a `.dex` into the `.smali` tree this whole vault has been reading; any text editor can then change it. Rebuilding (`apktool b out/ -o patched.apk`, or `smali a out/ -o classes.dex` followed by repacking the APK by hand) produces a new `.dex`/APK from the edited text — but modifying `classes.dex` invalidates the original developer's signature, so a rebuilt APK must be re-signed with your own key (`apksigner sign`, after `zipalign`) before Android will install it; it will install as a *different* app from Android's point of view (different signing certificate), never as an in-place update of the original. See [[Dalvik-Bytecode-Bibliography|Bibliography]] for `smali`/`baksmali`/`Apktool` links.

> [!tip] Verify each change in isolation, exactly as [[Anti-Tampering-Pattern-Workflow]] recommends for its Frida patches
>
> Patch one method, rebuild, reinstall, and confirm the app still behaves as expected before stacking a second edit on top — a hand-edited `.smali` file that satisfies the verifier can still be behaviorally wrong (see patch 4 below), and finding that out after five combined edits is much harder than after one.

### What the Dalvik verifier will and won't let you get away with

The verifier is a dataflow type-checker, not a behavior-checker — it rejects edits that are structurally inconsistent, and says nothing about whether the result still makes sense:

| Constraint | What breaks it |
| --- | --- |
| Register range | Referencing `vN`/`pN` beyond what `.locals`/`.registers` declares (see [[Registers]]'s warning about `.registers` shifting parameter indices) |
| Type consistency at merge points | A register holding incompatible types along different paths into the same label — this is exactly why the obfuscator's register-shuffle-before-`goto` idiom (worked example 3) exists in the first place |
| `move-result*` placement | Must be the instruction immediately after the `invoke-*` it captures, with nothing in between — see [[Methods]] |
| `try`/`catch` ranges | `:try_start`/`:try_end` labels must still bracket exactly the instructions meant to be protected after an edit; deleting or moving code inside a protected region without updating the range leaves it silently wrong |
| Object construction order | A `new-instance` result is "uninitialized" until passed to `invoke-direct ...-><init>(...)V`; any other use before that (even just moving it to another register) is rejected |
| Labels | Purely textual, resolved by the assembler — safe to add/remove as long as every `goto`/`if-*`/`:try_start` reference still points at a label that exists somewhere in the same method |

### Patch 1 (simple): force a branch unconditionally

The cheapest, safest edit: turn a conditional gate into an unconditional jump to its "safe" arm, leaving everything else byte-for-byte identical. Neutralizing `onPause`'s div/0 trap from worked example 2:

```diff
     rem-int/2addr v1, v0
     invoke-super {p0}, Lorg/apache/cordova/CordovaActivity;->onPause()V
-    if-eqz v1, :cond_0
-    const/16 v1, 0x21
-    div-int/lit8 v1, v1, 0x0
+    goto :cond_0
     :cond_0
```

`goto` (rather than deleting the `if-eqz`/trap lines outright) keeps every other label reference and the instruction stream's shape intact; `v1` simply becomes a dead value nobody reads again, which the verifier has no objection to (dead registers are fine — inconsistent ones across a merge are not). This single technique — replace a conditional with an unconditional jump to whichever arm is "safe" — already covers most of what a runtime Frida patch does (as in `Case-Studies/tua/source/investigate.js`, which neutralizes this exact trap dynamically instead), just made permanent and static instead of applied at attach time.

### Patch 2 (medium): patch a check's outcome, not its internals

The same technique generalizes to checks whose *result* feeds a comparison rather than a direct trap. `attachBaseContext` repeatedly does `cmp-long` / `if-ltz` (or `if-eqz`) on a reflectively-read `long` against a threshold derived from a `Resources.getString(...)` computation — for example:

```smali
invoke-virtual {v9}, Ljava/lang/Long;->longValue()J
move-result-wide v9
cmp-long v0, v0, v9
if-ltz v0, :cond_4
```

Patching the branch itself, exactly as in patch 1, is preferable to trying to spoof the reflectively-read `long` at its source: the source is buried behind a `check-cast Ljava/lang/reflect/Field;` / `.getLong(Object)` pair whose arguments are themselves obfuscated (worked example 4), so intercepting *that* would mean re-deriving the whole resolve chain, while the comparison that consumes its result is a single two-instruction `cmp-long`/`if-*` pair with an obvious "did the check pass" semantics regardless of what it's actually comparing. Forcing `if-ltz v0, :cond_4` to `goto :cond_4` (or the inverse target, depending on which arm is the non-tampered one — confirmed dynamically first, per checklist item #6's advice, never assumed) bypasses whatever the comparison was checking without needing to understand the reflective read that fed it at all — the same principle [[Anti-Tampering-Pattern-Workflow]] applies by hooking `Log`/`Runtime.exit` instead of reverse-engineering each hideout's internals: neutralize at the narrowest point where the check's *outcome*, not its *mechanism*, is legible.

### Patch 3 (deep): insert instrumentation without disturbing register state

Adding new code, rather than removing/redirecting existing code, has to respect the register-range constraint from the table above. Logging every string `$$i` decodes, right before its existing `return-object p0`:

```diff
     new-instance p0, Ljava/lang/String;
     invoke-direct {p0, v0, v2}, Ljava/lang/String;-><init>([BI)V
+    const-string v3, "tua-decode"
+    invoke-static {v3, p0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
     return-object p0
 .end method
```

`.locals 6` already declares `v0`-`v5`; the inserted block reuses `v3`, which by this point in the method holds nothing live (its last use was as the output index earlier in the loop, long since superseded by `v3`'s role changing across the method) — reusing a dead register avoids having to bump `.locals` and therefore avoids the trap in [[Registers]]'s own warning about `.registers`/`.locals` changes shifting other indices. `Log.d(String, String)` returns an `int`, but since nothing needs it, the `move-result` after `invoke-static` is simply omitted — exactly the "omit `move-result*` if the value isn't needed" rule from [[Methods]]. Checking whether a register is truly dead at the insertion point (not just "not obviously used nearby") is the one step worth being careful about: inserting into the middle of a live register's lifetime, rather than after its last real use, is the most common way a hand-added instrumentation edit silently corrupts an otherwise-correct patch.

### Patch 4 (expert): reimplement a method's logic outright, and trace the change forward

The most invasive edit replaces a method's body wholesale rather than redirecting or augmenting it — which means the verifier's approval is no longer sufficient evidence the patch is correct; every caller has to be checked by hand too. Spoofing `DeviceIdProvider.getDeviceID`'s return value:

```diff
 .method private static getDeviceID(Landroid/content/Context;)Ljava/lang/String;
-    .locals 6
-    const-string v0, "android.permission.READ_PHONE_STATE"
-    invoke-static {p0, v0}, Lo/MediaMetadataCompatBitmapKey;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I
-    ...
-    :catch_0
-    move-exception p0
-    ...
-    throw p0
-    :cond_1
-    return-object v3
+    .locals 1
+    const-string v0, "00000000-0000-0000-0000-000000000000"
+    return-object v0
 .end method
```

Three things the verifier checks but a naive text edit can easily get wrong: `.locals` must be lowered to match what the new body actually references (`6` down to `1` here, since none of the original temporaries survive) or left too high, which is legal but wasteful, never left too low, which the verifier rejects outright; the `.catch Ljava/lang/SecurityException; {...}` directive (elided above) must be deleted along with the `try`/`catch` block it protected, since a `.catch` whose range no longer brackets anything meaningful is at best dead weight and at worst references labels that no longer exist; and the return type must still satisfy every caller. That last point is the one the verifier cannot check for you: `DeviceIdProvider.getHashedDeviceID`, in the same file, calls `AeSimpleSHA1.SHA1(String)` directly on this method's return value with no null-check in between — returning a placeholder *string* keeps that caller working, but returning `null` instead (also verifier-legal, `Ljava/lang/String;` accepts it) would pass reassembly cleanly and then crash `SHA1(...)`'s first `.getBytes()` call at runtime, the exact class of bug the verifier is structurally unable to catch, and the reason patch 1 and 2's narrower "redirect a branch" approach is preferable whenever it's available: reimplementing a method's body means re-establishing every guarantee its callers were relying on, by hand, one caller at a time.

### Patch 5 (expert): batch no-op a signature-matched hideout family, with no known body to preserve

Worked example 4's fifteen `(JJ)V` hideout candidates are the sharpest case for static patching in this whole app: their real bodies were never imported into this case study, so none of patches 1-4's "redirect around a known trap" or "reimplement with a known-good stand-in" techniques apply — there's nothing to redirect around or reimplement, only a bare declaration. What *is* known from the signature alone turns out to be enough: a method declared `.method public static <name>(JJ)V` returns `void`, so the minimal legal body

```diff
 .method public static onMessageChannelReady(JJ)V
-    ...unknown body...
+    .locals 0
+    return-void
 .end method
```

satisfies every caller unconditionally — a `void` return has no value for any caller to receive and possibly misuse, unlike patch 4's `getDeviceID`, where swapping in the wrong *kind* of placeholder (`null` instead of a real string) broke a downstream caller in a way the verifier couldn't flag. That asymmetry is worth internalizing on its own: **a `void`-returning method is the single safest target for a wholesale static body replacement anywhere in this chapter's toolkit**, precisely because there is no return value for any caller to misuse.

This is the static, permanent counterpart of `Case-Studies/tua/source/combined.js`'s `HIDDEN_CHECKS.forEach(...)` block, which does exactly the same thing at runtime — one Frida `overload('long', 'long').implementation = function (a, b) { ... }` per class/method pair, for the same fifteen targets — replacing each body with a no-op, for every method sharing the confirmed signature, without needing any of their real bodies either. The tradeoffs run in opposite directions: the Frida version needs `frida-server` (or Gadget, see [[Anti-Detection-And-Gadget-Mode]]) attached before `FirebaseInitProvider.onCreate()` ever runs — which is why `combined.js`'s own header insists on spawn mode (`-f`), not attach — and has to be reinstalled every launch; fifteen static edits, once applied and the APK rebuilt and re-signed (see "The edit-reassemble-resign loop" above), remove the `RunningOnRootedDeviceException`/`AppDebuggableException` crash source permanently, with no companion process required afterward, at the one-time cost of the rebuild-resign cycle and losing the ability to install over the original app (different signing certificate — see [[Anti-Detection-And-Gadget-Mode]]'s note on the same tradeoff for Gadget repackaging). Point 5 of [[Anti-Tampering-Pattern-Workflow]]'s general workflow — verify each change in isolation via Frida first, only port to static `.smali` once confirmed — applies directly here: `neutralize_root_check.js` validates the *first* hideout (`UPCEANExtension2Support`) alone before `combined.js` generalizes to all fifteen at once, and that same order — confirm dynamically, generalize by signature, then patch statically — is the right one to follow before batch-editing fifteen `.smali` files from a grep result whose individual members were never confirmed to fire at all, per worked example 4's own "needs a lookup" caveat. The generic `isDeviceRooted` template in [[Memory-Patching-And-Code-Redirection]] is the same idea one layer down: when the equivalent check lives in a native `.so` instead of a `.dex`, `Interceptor.replace` plays the role `return-void` plays here — full-body replacement, without needing the original implementation either.

## See also

- [[Classes]], [[Methods]], [[Registers]], [[Types]], [[Dalvik-Instructions|Instructions]] — the fundamentals this chapter assumes
- [[Reading-Raw-Disassembly]] — the same skill applied to stripped ARM64 disassembly, including the "same N instructions repeated once per field" idiom reused above
- [[Tua-Case-Study]] and [[Anti-Tampering-Pattern-Workflow]] — the dynamic-triage investigation this chapter's static reading complements; the full smali this chapter excerpts from lives under `Case-Studies/tua/source/smali/`
- [[Frida-Dynamic-Instrumentation]] — the dynamic alternative to hand-simulating a decoder (checklist item #6) or hand-tracing a reflective resolve chain (worked example 5)
- [[Anti-Detection-And-Gadget-Mode]] — the dynamic, runtime treatment of exactly the root-detection hideouts worked example 4 and patch 5 neutralize statically instead
- [[Memory-Patching-And-Code-Redirection]] — the native/ARM64 counterpart of "replace a function's body entirely," for when the equivalent check lives in a `.so` instead of a `.dex`

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]

## Flashcards
#flashcards

A method contains the exact same `sget`/`add-int/lit8`/`rem-int/lit16`/`sput`/`rem-int/2addr` quadruple in three places; in two of them the result register is overwritten before ever being read, and in one it feeds an `if-eqz` right after. What does this tell you?::The shape alone never distinguishes real gates from dead camouflage — only two of the three instances are live, and you can only tell which by tracing the one result register forward to its next use (or lack of one).
Why is `if-nez <field>, :cond_X` on a `private static final` field almost always dead code, when the identical check on an ordinary field could matter?::A field written exactly once, inside `<clinit>`, is guaranteed non-null by the time any other static method on that class becomes reachable, since Dalvik runs `<clinit>` before the class's other static methods do — so the branch it guards can never actually execute.
What's the signal that a pair of calls like `extraCallbackWithResult(I)` followed by a conditional `onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)` is reflection indirection, without knowing either method's real body?::The first call takes a bare opaque `int` and is immediately null-checked as a cache lookup; the miss path builds a class/member name (often via a decoder) and calls a differently-shaped second method; either way the result is `check-cast` to `Ljava/lang/reflect/{Field,Method,Constructor}` and immediately used — the real API is never named as a plain `invoke-*` anywhere in the method.
Why is a register-swap-heavy accumulator loop (like `$$i`'s decoder) easy to mis-trace by hand, and what should you do instead?::Which physical register holds "the running value" versus "the table cursor" trades places with every `move`-based swap, so misreading a single swap produces a wrong description of the algorithm that still looks entirely plausible; verifying the recurrence with a short script, or calling the real method dynamically and reading back its actual return value, catches what one manual trace alone might not.
When hand-patching `if-eqz v1, :cond_0` into an unconditional `goto :cond_0` to neutralize a trap, why is this usually safer than deleting the branch and the trap instructions outright?::`goto` keeps every label reference and the instruction stream's shape intact, and the now-unread register simply becomes dead (which the verifier allows); deleting instructions risks silently breaking other structure that referenced them, like a `.catch` range or a relative offset a naive text edit didn't account for.
Why is redirecting a branch (patch 1/2) generally preferable to reimplementing a method's body outright (patch 4), even when both pass the verifier?::The verifier only checks structural/type consistency, not behavior — reimplementing a body means every caller's assumptions about the return value (nullability, format, etc.) have to be re-verified by hand one at a time, while redirecting a branch changes which of the method's own, already-correct code paths runs, leaving everything callers depend on unchanged.
Why is a `public static (JJ)V` method inside `com.google.zxing.RGBLuminanceSource` (or a resource class like `R$anim`) worth investigating, when the signature itself is unremarkable?::The signature paired with the class is the signal, not the signature alone — a barcode pixel-source class or a resource class (which should hold only `int` constants) has no legitimate reason to declare a method taking two opaque `long`s and returning nothing; it's the mismatch between what the class is *for* and what it *contains* that makes it worth grepping for as a sibling of an already-confirmed hideout.
Why is a `void`-returning method the single safest target for a wholesale static body replacement?::A `void` return has no value for any caller to receive and potentially misuse — unlike a method returning `String`/`long`/etc., where swapping in a placeholder of the wrong shape (`null` instead of a real string, say) can pass the verifier and still crash a caller at runtime; a `void` method's callers only ever depend on it *not throwing*, which `return-void` alone guarantees.
The same five field names (`onMessageChannelReady`, `onNavigationEvent`, `ICustomTabsCallback`, `extraCallback`, `extraCallbackWithResult`) show up as mod-128 opaque-predicate counters in `MainActivity` and as fixed XOR key material in `PlusNetworking`. What does this tell you about reading a reused, Android-API-borrowed field name?::The name alone never tells you the field's role in a given class — only how it's actually read/written there does; the same handful of borrowed names get reused for structurally unrelated jobs throughout the app, which is itself the camouflage strategy, not an exception to it.
