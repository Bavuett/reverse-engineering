---
tags: [case-study-note]
case_study: "Classeviva (Spaggiari ClasseViva student app)"
created: 2026-07-28
---

# Async-Await-And-Platform-Channels

## Question / goal

Trace the SPID (Italian SPID/CIE public digital-identity SSO) login page's call out to open a URL in an external app — an operation Dart can't do unassisted — through the full `MethodChannel.invokeMethod` + `await` boundary, and figure out what a static reader can learn about the app's native capabilities _without_ first locating the native/Java handler itself.

## Relevant source

- `[[login_spid_page.dart]]` — the excerpt around `MethodChannel::invokeMethod` / `AwaitStub`

## Excerpt

```
// 0xc10f94: r16 = Instance_MethodChannel        <- a pool-loaded, reused MethodChannel object
// 0xc10fa0: r16 = "openUrlIntent"                <- the channel METHOD name
// 0xc10fb0: r0 = invokeMethod()                  <- bl MethodChannel::invokeMethod
// 0xc10fbc: r0 = Await()                         <- bl AwaitStub -- suspend here
// 0xc10fc0: b #0xc11038                          <- one possible continuation, not necessarily the next line
// 0xc10fc4: ...                                   <- actual resume point after the awaited value arrives
// 0xc10fcc: branchIfSmi(r0, 0xc10fd8)
// 0xc10fd0-0xc10fd4: LoadClassIdInstr(r0)
// 0xc10fd8: cmp x2, #0xa52 / b.ne #0xc11050       <- runtime type-check on invokeMethod's dynamic result
```

## Analysis

The single most reusable takeaway from this excerpt: **the string literal `"openUrlIntent"` is the `MethodChannel` method name**, and it will be sitting right there in the app's recovered string table (or Ghidra/radare2's string listing) regardless of whether you've found this call site yet. Enumerating every plausible-looking method-channel-name string in a Flutter binary is a fast way to build a checklist of "everything this app can ask the native/Java side to do" — opening intents, reading device identifiers, biometric prompts, whatever else — before committing to reading any one call site in full.

The `await` itself confirms this is genuinely asynchronous — the app doesn't block waiting for the platform side; it suspends and resumes later, per [[Flutter-Dart-AOT#Explanation|`async`/`await`]]. The class-id check immediately after resuming (`cmp x2, #0xa52`) exists because `invokeMethod`'s return type is `dynamic` — the platform side could hand back anything, so the generated code defensively checks what it actually got before treating it as the expected type. This is a general lesson about platform-channel boundaries: **whatever crosses from native/Java back into Dart is untyped until proven otherwise**, and the proof is exactly this kind of inline class-id check.

Structurally, this is also the one place in this whole case study where the two calling conventions from this topic meet: `invokeMethod` is called using the Dart-AOT convention (through `PP`, with `THR`-relative stack checks all around it), but it's a bridge into `libflutter.so` — genuine NDK/JNI-callable code, following AAPCS64 with the `JNIEnv`-table convention from [[Android-Native-Internals]] once you cross into the engine and, eventually, the Android platform channel handler registered by the app's Java/Kotlin `MainActivity`.

## Related concepts

- [[Flutter-Dart-AOT]]
- [[Android-Native-Internals]]
- [[MethodChannel-Invoke-And-Await]]

## Open questions / next steps

- The actual native handler for `"openUrlIntent"` isn't in this excerpt at all — it lives in the app's Android-side (Kotlin/Java) `MethodCallHandler` registration, outside the Dart snapshot entirely. Finding it would require decompiling `classes.dex` (see the companion Dalvik-bytecode vault) rather than anything in `libapp.so`.
- What does the fallback path at `#0xc11050` (reached when the class-id check fails) do? Worth a quick read to see whether it's genuine error handling or another expected-but-untyped-result branch.

## See also

- [[ARM64-Android-Case-Studies|Case Studies]]
