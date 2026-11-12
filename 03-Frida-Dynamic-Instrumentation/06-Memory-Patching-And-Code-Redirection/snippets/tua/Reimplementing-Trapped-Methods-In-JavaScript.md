---
tags: [snippet]
level: 3
project: "TUA (net.pluservice.tua)"
source: "net.pluservice.tua — Cordova/Android hybrid app, decompiled to smali from the APK"
version: "11.26.4"
source_path: "smali/net/pluservice/tua/MainActivity.smali (onPause, onResume) and Frida script bypass_traps.js"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. This is a small fragment kept to illustrate one patching pattern. Check the app's ToS before any redistribution."
---

# Reimplementing-Trapped-Methods-In-JavaScript

> [!info] Level 3 — real code
> When a method mixes real work with an injected trap, a no-op breaks the app. The fix is to replace the method with a JavaScript reimplementation of only its legitimate part — or, for a thin override, to call the superclass's version directly and skip the subclass body.

## Context

Besides the hidden checks ([[Neutralizing-A-Hidden-Check-With-A-No-Op-Implementation]]), the TUA app has anti-tampering *traps* woven into ordinary lifecycle methods of `MainActivity` and Cordova's `CordovaActivity`: arithmetic on shared static counters that, in a tampered state, ends in a division by zero or `throw null`. These methods also do essential work (creating the WebView, calling the superclass's lifecycle), so they can't simply be emptied. Part of [[Tua-Case-Study]].

## Original path

`smali/net/pluservice/tua/MainActivity.smali`, methods `onPause()V` and `onResume()V`; fix in `bypass_traps.js`.

## Snippet — the trap (smali)

```smali
.method public onPause()V
    .locals 3
    const/4 v0, 0x2
    rem-int v1, v0, v0                                          # junk
    sget v1, Lnet/pluservice/tua/MainActivity;->ICustomTabsCallbackStub:I
    add-int/lit8 v1, v1, 0x4f
    rem-int/lit16 v2, v1, 0x80
    sput v2, Lnet/pluservice/tua/MainActivity;->extraCallbackWithResult:I   # update the other counter
    rem-int/2addr v1, v0                                        # v1 = (counter + 0x4f) % 2
    invoke-super {p0}, Lorg/apache/cordova/CordovaActivity;->onPause()V    # the real work
    if-eqz v1, :cond_0
    const/16 v1, 0x21
    div-int/lit8 v1, v1, 0x0                                    # trap: ArithmeticException
    :cond_0
    ...                                                         # counter update again
    return-void
.end method

.method public onResume()V
    ...                                                         # v1 = (extraCallbackWithResult + 0x65) % 2
    invoke-super {p0}, Lorg/apache/cordova/CordovaActivity;->onResume()V
    if-eqz v1, :cond_0
    return-void
    :cond_0
    const/4 v0, 0x0
    throw v0                                                    # trap: throw null -> NullPointerException
.end method
```

## Snippet — the fix (Frida)

```javascript
const CordovaActivity = Java.use('org.apache.cordova.CordovaActivity');
const MainActivity = Java.use('net.pluservice.tua.MainActivity');

// MainActivity.onPause(): skip the trap by calling CordovaActivity's "real" onPause directly.
MainActivity.onPause.implementation = function () {
    CordovaActivity.onPause.call(this);
    console.log('[MainActivity.onPause] bypass applied');
};
MainActivity.onResume.implementation = function () {
    CordovaActivity.onResume.call(this);
    console.log('[MainActivity.onResume] bypass applied');
};

// CordovaActivity.createViews(): reimplemented from the smali, without the div/0 at its end.
CordovaActivity.createViews.implementation = function () {
    const view = this.appView.value.getView();
    view.setId(0x64);
    view.setLayoutParams(Java.use('android.widget.FrameLayout$LayoutParams').$new(-1, -1));  // MATCH_PARENT
    this.setContentView(view);
    const prefs = this.preferences.value;
    if (prefs.contains('BackgroundColor')) {
        try { view.setBackgroundColor(prefs.getInteger('BackgroundColor', -0x1000000)); }
        catch (e) { console.log('[createViews] NumberFormatException on BackgroundColor: ' + e); }
    }
    view.requestFocusFromTouch();
};
```

## Reconstructed source

```java
// MainActivity, as shipped (trap code reconstructed)
@Override public void onPause() {
    int v1 = (ICustomTabsCallbackStub + 0x4f) % 2;
    extraCallbackWithResult = (ICustomTabsCallbackStub + 0x4f) % 0x80;
    super.onPause();
    if (v1 != 0) { int x = 0x21 / 0; }            // crashes when the counters are in a "tampered" state
    ...
}

// what the hook leaves: MainActivity adds nothing to the lifecycle
@Override public void onPause() { super.onPause(); }
```

## Notes

- **Read the trap before choosing the fix.** In `onPause` the only legitimate statement is `invoke-super … CordovaActivity;->onPause()V`; everything else is counter arithmetic and the trap. So the whole body reduces to "call the superclass".
- **`Superclass.method.call(this)`** invokes `CordovaActivity`'s implementation on the `MainActivity` instance — the JS equivalent of `super.onPause()`. Calling `this.onPause()` instead would re-enter the hook and recurse forever ([[Calling-Through-An-Overload-Without-Recursing]]).
- **Field access with `.value`.** The reimplementation of `createViews` reads Cordova's fields `appView` and `preferences` with `.value` ([[Finding-Live-Instances-With-Java-Choose]]). Constants like `0x64` (view id) and `-1, -1` (`MATCH_PARENT`) are copied from the smali.
- **Iterative by nature.** The script's own header says: if it still crashes, take the `FATAL EXCEPTION` stack from logcat and add an override for the next trapped method. Each trap is found by its crash, then neutralized — and the comment warns that if `CordovaActivity.onPause()` itself contained a trap, the crash would simply move there.
- **Why the traps exist.** The counters `ICustomTabsCallbackStub`/`extraCallbackWithResult` are shared across many methods; tampering that skips some updates leaves them in a state where the parity check fires somewhere later, far from the cause — a deliberate way to make crashes hard to attribute ([[Anti-Tampering-Pattern-Workflow]]).

## See also

- [[Memory-Patching-And-Code-Redirection]]
- [[Calling-The-Original-From-A-Replacement]] — the same "keep the real work" principle in native code
- [[Dalvik-Instructions]] in [[Dalvik-Bytecode]] — `rem-int`, `div-int/lit8`, `throw`
- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
