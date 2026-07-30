---
tags: [case-study-note]
case_study: "TUA (net.pluservice.tua)"
created: 2026-07-30
---

# In-Memory-Dex-Loading

## Question / goal

After the 15 known reflection-hidden static stubs (`(JJ)V` methods such as `extraCallbackWithResult`, cataloged in [[Anti-Tampering-Pattern-Workflow]]) were neutralized, rebuilt, re-signed, and reinstalled, the app **still crashed on startup**. Why, and where does the surviving check actually live?

## How this was found

**1. Clean rebuild, still crashing.** All 15 static stubs had their bodies replaced with `return-void` (plus a `.locals 0` fix once `apktool b` rejected a body with no register directive at all — every non-abstract, non-native `.method` needs one). The app turned out to ship as a **split bundle** (`tua.xapk`): one base APK plus 19 `config.*.apk` splits (locales, densities, and a single ABI split, `config.armeabi_v7a.apk`). All splits had to be re-signed with the same key (`uber-apk-signer --allowResign`) and installed together (`adb install-multiple`) — installing just the resigned base alone failed with `INSTALL_FAILED_MISSING_SPLIT`. `firstInstallTime`/`lastUpdateTime` were checked via `adb shell dumpsys package` to confirm the freshly rebuilt APK, not a stale one, was actually what was running. None of that changed the outcome: `adb logcat -v threadtime` still showed the process dying deliberately, with no Java stack trace —

```
07-30 20:01:17.113 23791 23791 E SCRTYMANAGER: AppDebuggableException exception: -1
07-30 20:01:17.138  6391 10089 I ActivityManager: Process net.pluservice.tua (pid 23791) has died: fg  TOP
```

— the exact same "clean `System.exit`, no exception, no stack trace" signature already characterized in [[Anti-Tampering-Pattern-Workflow]] for this app's other checks.

**2. A plausible-looking native-library hypothesis — asserted, then challenged.** The app ships exactly one native library, `libdd7a.so`, inside the `config.armeabi_v7a.apk` split, with almost no readable strings — a shape consistent with a native packer/protector stub. It was tempting to conclude this was the source of the surviving check. **That conclusion was challenged and required proof before being accepted** — asserting a native cause without dynamic verification is exactly the kind of mistake [[Anti-Tampering-Pattern-Workflow]] already warns against in its own "lessons," now caught in the act rather than after the fact. Verification: sample `/proc/<pid>/maps` repeatedly across the process's entire observed lifetime, looking for the library ever being mapped at all:

```bash
adb shell "am start ...; for i in $(seq 1 30); do PID=$(pidof net.pluservice.tua); \
  if grep -qi dd7a /proc/$PID/maps 2>/dev/null; then echo FOUND; break; fi; sleep 0.15; done"
```

`libdd7a.so` was **never** mapped during the window the process was alive. The hypothesis was falsified by its own predicted evidence failing to appear — the native library was a red herring, not the cause.

**3. Pivoting to Frida to find the real caller.** With the native lead dead, the same technique that worked in the earlier investigation was reapplied: hook `Log.e`/`Process.killProcess`/`System.exit` and capture a full Java stack trace at the moment of the call, rather than continue guessing:

```javascript
Log.e.overload('java.lang.String', 'java.lang.String').implementation = function (tag, msg) {
    console.log('\n=== Log.e  tag="' + tag + '"  msg="' + msg + '" ===');
    console.log(Exception.$new().getStackTrace().map(e => '    at ' + e.toString()).join('\n'));
    return this.e(tag, msg);
};
```

This produced a real, direct chain:

```
=== Log.e  tag="SCRTYMANAGER"  msg="AppHookedException exception: -6" ===
    at android.util.Log.e(Native Method)
    at java.lang.reflect.Method.invoke(Native Method)
    at o.getFocusedView.onMessageChannelReady(:18)
    at java.lang.reflect.Method.invoke(Native Method)
    at org.apache.cordova.camera.FileProvider.onCreate(:223)
    at android.content.ContentProvider.attachInfo(ContentProvider.java:2388)
    ...
=== System.exit(-6) ===
    at java.lang.System.exit(Native Method)
    at java.lang.reflect.Method.invoke(Native Method)
    at o.getFocusedView.onMessageChannelReady(:19)
    ...
```

A worthwhile irony, confirmed rather than assumed: attaching Frida to *investigate* the crash tripped a **different branch of the same check** — `AppHookedException`/`-6` (the app detecting that it is itself being hooked) instead of the original `AppDebuggableException`/`-1` (a debuggable-build check). The same protection mechanism, triggered by a different one of its own trip wires, depending on what state the instrumentation itself creates.

**4. The caller class doesn't exist on disk.** `o/getFocusedView.smali` is not present anywhere in the decompiled tree. This was checked directly rather than assumed: listing every `.dex` in the entire split bundle —

```
=== net.pluservice.tua.apk ===
  9725852  classes.dex
=== config.*.apk (all 19) ===
  (no classes.dex in any of them)
```

— confirms the base APK's `classes.dex` is the **only** DEX shipped anywhere in the bundle, and `o.getFocusedView` isn't in it. The class is never present in cleartext on disk at all; it has to be materializing purely in memory at runtime.

**5. Hooking the loader, not the class.** Since `dalvik.system.InMemoryDexClassLoader` is the API that loads DEX bytecode directly from a `ByteBuffer` (rather than a file path, as the more familiar `DexClassLoader` requires — see [[Reflection-and-Runtime-Internals]] for dynamic class loading as a call-hiding mechanism in general), every constructor overload was hooked to dump its `ByteBuffer` argument to disk:

```javascript
IMDCL.$init.overloads.forEach(function (ov) {
    ov.implementation = function () {
        var args = Array.prototype.slice.call(arguments);
        if (args[0]) dumpByteBuffer(args[0], 'imdcl_' + Date.now());
        return this.$init.apply(this, args);
    };
});
```

Two payloads were captured (27,372 and 342,784 bytes), both opening with a valid DEX magic header, `64 65 78 0a 30 33 37 00` (`dex\n037\0`) — genuine `.dex` files, not arbitrary encrypted blobs, confirmed structurally rather than assumed from the byte count alone.

**6. Disassembling the recovered payload.** `dexdump -d` (from the Android build-tools, the same category of tool as `baksmali` but for a standalone `.dex`) on the 342 KB payload found the class directly:

```
14032:  Class descriptor  : 'Lo/getFocusedView;'
...
14137:011d0c:  |[011d0c] o.getFocusedView.ICustomTabsCallback:(JJ)V
```

— a **second, entirely separate set of `(JJ)V` decoys**, invisible to the original static `grep -rE "^\.method public static \w+\(JJ\)V"` that found the first 15, precisely because these live only inside a DEX that doesn't exist as a file until the app decrypts it in memory. The real target method disassembles to the same idiom already cataloged from the static stubs:

```
    #7              : (in Lo/getFocusedView;)
      name          : 'onMessageChannelReady'
      type          : '(JJ)V'
      access        : 0x0009 (PUBLIC STATIC)
      catches       : 4
        0x0003 - 0x0009
          Lo/getExitTransition; -> 0x0009
        ...

012d48: 1221                    |0000: const/4 v1, #int 2
012d4a: 9400 0101                |0001: rem-int v0, v1, v1
012d4e: 2200 a300                |0003: new-instance v0, Lo/getChildFragmentManager;
012d52: 7010 9a01 0000           |0005: invoke-direct {v0}, Lo/getChildFragmentManager;.<init>:()V
012d58: 2700                     |0008: throw v0
...
012e18: 6e20 8200 a900           |0068: invoke-virtual {v9, v10}, Ljava/lang/Class;.getDeclaredConstructor:(...)Ljava/lang/reflect/Constructor;
012e26: 6e20 da00 8900           |006f: invoke-virtual {v9, v8}, Ljava/lang/reflect/Constructor;.newInstance:(...)Ljava/lang/Object;
...
012eb2: 6e30 e000 890a           |00b5: invoke-virtual {v9, v8, v10}, Ljava/lang/reflect/Method;.invoke:(...)Ljava/lang/Object;
```

Same `new-instance` + `throw` + immediate `.catch` idiom (offsets `0003`–`0008`, catching `Lo/getExitTransition;`) and the same `getDeclaredConstructor` → `newInstance`/`getMethod` → `invoke` chain seen in the static code — the same two structural patterns already cataloged as `self-throw-catch` and reflective-dispatch idioms, just applied to code loaded dynamically instead of shipped on disk.

**7. Tracing back to a real, patchable caller.** Rather than patch `o/getFocusedView.smali` (which cannot be patched — it doesn't exist as a file on disk), the goal shifted to the real static call site that loads and invokes it, found via the stack trace's `FileProvider.onCreate(:223)`. That method — `org.apache.cordova.camera.FileProvider.smali`, `.method public onCreate()Z` — spans **9,850 lines as a single method**, heavily control-flow-flattened. Searching for `.line 223` inside the method's bounds (not just anywhere in the file, since `.line` numbers repeat across different methods) located the actual instructions at file lines 2396–2509:

```smali
2396	    .line 223
2397	    :try_start_2
2398	    new-array v14, v9, [Ljava/lang/Object;
2400	    invoke-static {v12, v13}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;
2402	    move-result-object v9
2404	    aput-object v9, v14, v7
2406	    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;
2408	    move-result-object v0
2410	    aput-object v0, v14, v3
2412	    const v0, 0xb4beacf
2414	    invoke-static {v0}, Lo/ResultReceiver;->extraCallbackWithResult(I)Ljava/lang/Object;
2416	    move-result-object v0
2418	    if-nez v0, :cond_8
2420	    invoke-static {v3, v3}, Landroid/view/View$MeasureSpec;->makeMeasureSpec(II)I
    ; ... (lines 2422-2496: string reconstruction via
    ;      Lorg/apache/cordova/camera/FileProvider;->c(SSB[Ljava/lang/Object;)V, then:)
2494	    invoke-static/range {v27 .. v33}, Lo/ResultReceiver;->onMessageChannelReady(CIIIZLjava/lang/String;[Ljava/lang/Class;)Ljava/lang/Object;
2496	    move-result-object v0
2498	    :cond_8
2499	    check-cast v0, Ljava/lang/reflect/Method;
2501	    const/4 v1, 0x0
2503	    invoke-virtual {v0, v1, v14}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
2504	    :try_end_2
2505	    .catchall {:try_start_2 .. :try_end_2} :catchall_2
2507	    const/4 v0, 0x4
2509	    new-array v1, v0, [Ljava/lang/Object;
```

`Lo/ResultReceiver;->extraCallbackWithResult`/`onMessageChannelReady` are **the exact same two method names** seen in the very first static stub excerpt examined at the start of this investigation (§2.1 of the original session, the `extraCallbackWithResult(JJ)V` stub in an unrelated class). This confirms `Lo/ResultReceiver` isn't a one-off — it's a **shared, central reflection resolver-cache class**, reused throughout the app as the actual dispatch point for whichever concrete check (static stub, or dynamically loaded class) is meant to run in a given call site.

**8. Verifying a fix is safe before touching anything.** Line 2503's `invoke-virtual {...}, Ljava/lang/reflect/Method;->invoke(...)` is not followed by any `move-result-object` — its return value is discarded outright. Immediately after `:try_end_2`, `v0` (line 2507) and `v1` (line 2509) are both reassigned unconditionally, with no branch depending on anything computed inside the block. A search for every reference to `cond_8`/`try_start_2`/`try_end_2` confirmed all of them are local to this exact span, with nothing outside the block ever jumping into it. Put together: the block at lines 2397–2504 is a **pure, self-contained side effect** with no data flow leaving it — safe, mechanically, to collapse to a single `nop`, matching the "verify in isolation before combining changes" step in [[Anti-Tampering-Pattern-Workflow]]'s general workflow.

```diff
     :try_start_2
-    new-array v14, v9, [Ljava/lang/Object;
-    ... (original lines 2398-2503) ...
-    invoke-virtual {v0, v1, v14}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
+    nop
     :try_end_2
     .catchall {:try_start_2 .. :try_end_2} :catchall_2
```

This patch was verified as register/label-safe but **not applied**: unlike the 15 already-neutralized stubs (which were provably dead decoys — never reached by any live `invoke-*`, see [[Anti-Tampering-Pattern-Workflow]]), this is a call site that is **actually firing** and currently causing the app's real, observed crash. Disabling a live anti-tamper gate is a materially different action from deleting an already-inert decoy, and was treated as such — the change was proposed and left for explicit sign-off rather than applied autonomously.

**Friction points worth remembering, on the Frida side specifically** (distinct from, but as valuable as, the grep/regex friction already cataloged in [[Anti-Tampering-Pattern-Workflow]]):

- Frida's **Python bindings** don't auto-inject the Java bridge the way the **CLI** does — calling `Java.perform` from a Python-driven script throws `ReferenceError: 'Java' is not defined` unless the script is run via `frida -U -f pkg -l script.js` (CLI), not the Python API directly.
- Writing dumped bytes to `/data/local/tmp` from **inside the target app's own process** fails — the app runs in the `untrusted_app` SELinux domain, which that path isn't reachable from; the app's own private data directory (`/data/data/<package>/`) is.
- A Java array handed to a Frida script by the bridge does **not** implement `Array.prototype` — `.slice()` on it throws `TypeError: not a function`; copying byte-by-byte into a native `Uint8Array` is the workaround.
- Calling through to an overload's original implementation via `ov.apply(this, args)` fails the same way — the correct call is through the **method's general name** (`this.$init(...)`), which Frida redispatches to the matching overload based on the actual argument types, not by invoking the overload object itself.

## Relevant source

No new files were imported into this case study's `source/` for this note — every excerpt below is quoted directly from the session log rather than from a full file, since only partial excerpts (not the complete 9,850-line `FileProvider.smali`, nor the recovered in-memory `.dex` payloads, nor the full Frida hook scripts) were captured at the time. See "Open questions / next steps" below.

## Analysis

Three distinct mechanisms compound here, each independently cataloged in [[Reflection-and-Runtime-Internals]]:

- **Reflection** (`Class.forName`/`getDeclaredMethod`/`Method.invoke`) hides *which* method is really being called, in both the static stubs and the dynamically loaded ones alike.
- **`self-throw-catch`** (construct an exception, throw it, catch it immediately, unconditionally) is a disguised `goto`, not real error handling — used as connective tissue inside every one of these stub/decoy methods, static or dynamic.
- **Dynamic class loading via `InMemoryDexClassLoader`** is the mechanism that defeats static analysis *categorically*, not just by obscurity: `Lo/getFocusedView;` is not merely obfuscated, it is **absent from the file system entirely** until the app's own code decrypts a `ByteBuffer` and hands it to the loader. A `grep` across the decompiled tree cannot find code that has no on-disk representation to grep — this is the concrete, real-world instance of the "dynamic class loading" call-hiding mechanism described in general terms in [[Reflection-and-Runtime-Internals]]. `InMemoryDexClassLoader` is itself a legitimate, publicly documented Android API (added in API 26, specifically so a `.dex` never has to touch disk as a file to be loaded) — repurposed here for exactly the property that makes it attractive to an obfuscator: no file, no static artifact, nothing for `baksmali`/`apktool` to ever see.

The two decoy sets (the 15 originally found by static `grep`, and this newly discovered set living only inside the recovered in-memory DEX) share the identical structural idiom — same `(JJ)V` signature family, same `self-throw-catch` opener, same `getDeclaredConstructor`/`getMethod` → `invoke` reflection chain. That consistency is itself evidence: this is **one protection mechanism/generator applied uniformly across two different loading layers**, not two unrelated obfuscation systems that happen to look similar.

`Lo/ResultReceiver` deserves its own note: `android.os.ResultReceiver` is a real, unrelated Android SDK class (a `Parcelable` callback for cross-process results). Naming the app's central reflection resolver-cache class after it is the exact same **reused-real-API-name camouflage** already cataloged as a named pattern in [[Anti-Tampering-Pattern-Workflow]] (alongside `onNavigationEvent`, `onMessageChannelReady`, `ICustomTabsCallback`, `asInterface`) — this investigation adds `Lo/ResultReceiver` itself to that list, and demonstrates that the same resolver-cache class is queried both from statically-visible call sites (`FileProvider.onCreate`) and, presumably, from wherever else in the app decides which check should fire.

## Generalizing the pattern

Two separate generalizations, at two different layers:

1. **The reused-name camouflage** (as before): grep for classes/fields/methods named after real Android SDK identifiers whose actual signature, class, or field type doesn't match the real API — `Lo/ResultReceiver` and `Lo/getFocusedView` both fit this, alongside the names already cataloged in [[Anti-Tampering-Pattern-Workflow]].
2. **The dynamic-loading layer, which needs a completely different technique**, since static grep is structurally blind to it by construction: hook every constructor overload of `dalvik.system.InMemoryDexClassLoader` (and, for completeness, `DexClassLoader`/`PathClassLoader`/`BaseDexClassLoader`, its siblings that load from a file path instead of a `ByteBuffer`) on process start, and dump/`dexdump` whatever bytes or path each one is given. This generalizes past this specific app: any hardened/packed app using this loading technique is only discoverable this way, not via static search, however thorough.

## Related concepts

- [[Reflection-and-Runtime-Internals]] — dynamic class loading as a call-hiding mechanism in general (§3.3), and what `Method.invoke` actually resolves to underneath, both directly exercised here
- [[Anti-Tampering-Pattern-Workflow]] — the earlier investigation this one continues: the same `self-throw-catch`/reflective-dispatch idiom, the same reused-API-name camouflage technique (now extended with `ResultReceiver`/`getFocusedView`), and the general dynamic-triage-before-static-search workflow this note's own §2–3 followed again
- [[Methods]] — `invoke-*` semantics underlying every reflection chain read here, both in the static stubs and inside the recovered in-memory DEX

## Open questions / next steps

- The `FileProvider.onCreate` patch above is verified safe at the register/label level but **not applied** — it disables a live, currently-firing anti-tamper check rather than an already-dead decoy, and is left pending explicit sign-off rather than treated as a routine cleanup.
- The two recovered in-memory DEX payloads (27,372 and 342,784 bytes) were only searched for the one class already known to be relevant (`Lo/getFocusedView;`); neither has been fully mapped for other decoys or hideouts they might also contain.
- Whether `Lo/ResultReceiver`'s resolver-cache is queried from call sites other than `FileProvider.onCreate` is unconfirmed — the same static/dynamic-target grep-diff technique from [[Anti-Tampering-Pattern-Workflow]] (declared vs. directly-invoked) could be pointed specifically at `Lo/ResultReceiver;->` call sites to find them.

## See also

- [[Tua-Case-Study]]
- [[Case-Studies]]
