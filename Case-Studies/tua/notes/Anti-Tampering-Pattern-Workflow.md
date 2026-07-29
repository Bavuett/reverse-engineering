---
tags: [case-study-note]
case_study: "TUA (net.pluservice.tua)"
created: 2026-07-29
---

# Workflow for spotting anti-tampering patterns in smali

Notes gathered while analyzing `net.pluservice.tua`, useful as a general method
(not just for this app) before moving on to an automated tool.

## How we got here: the timeline of the investigation

This file doesn't come from research planned at a desk from the start — it comes from a path
where blind static search failed repeatedly, and only dynamic analysis
(Frida + logcat) revealed where to look. It's worth reconstructing,
because "how we got here" is the real lesson, more than the file lists.

**1. The first attempt (failed): grepping for keywords.**
The starting question was "where does the protection that detects untrusted
devices start?". The first instinct was to search for the strings typical of a root check
(`su`, `test-keys`, `Superuser`, `RootBeer`, `Magisk`, `Xposed`, `SafetyNet`...)
directly in the decompiled smali. **Zero results.** The reason, discovered only later:
almost all of the app's literal strings are encrypted at runtime (static fields
`$$d`/`$$j`/`$$l` as byte arrays, decrypted only when needed) — searching
for "root" or "security" as plain text could not work by construction.

**2. Exploring plausible but wrong leads.**
The `FirebaseInstanceId` lead (used in `DeviceIdProvider` to
generate a device fingerprint) was followed, as was the JS-bundle encryption
system (`EncryptionProvider`/`KeyKeeper`/`PluserviceKeyStore`, with an AES key
managed via `AccountManager`). Both were legitimate leads to investigate, but
**neither was the real blocking mechanism** — this was only discovered by
continuing to test, not by deducing it up front.

**3. The crash while testing hooking, and the pivot to dynamic analysis.**
While trying to hook `EncryptionProvider` with Frida, the app crashed before
the hook could observe anything at all. This is where the real change of method happened: instead of
continuing to read obfuscated smali by eye, `adb logcat` was **read**
during the crash, revealing the key line:
```
E SCRTYMANAGER: RunningOnRootedDeviceException exception: -7
```
A plaintext string in the log (because the message, once decrypted at runtime
and passed to `Log.e`, is no longer encrypted) — logcat completely bypassed
the static-encryption problem.

**Why the crash gave no signal at first.** This is worth explaining, because it wasn't a
limitation of the tools used but a deliberate design choice by whoever protected the app. The first
crash observed with Frida produced only `Process terminated` in the console — no
stack trace, no message, nothing to reason about. The reasons:

- **It isn't an unhandled exception.** The div/0 and NPE traps found later
  *are* real Java exceptions (`ArithmeticException`, `NullPointerException`) — if
  one of those had caused this crash, `FATAL EXCEPTION` with a full
  stack trace would have shown up in logcat right away. The real block, instead,
  calls `System.exit(status)` **directly**: a clean, deliberate termination,
  not an error. With no exception to propagate there's no stack trace to generate —
  it's indistinguishable, as far as the system is concerned, from an app that voluntarily
  decides to close itself.
- **Frida doesn't distinguish the causes.** The REPL's `Process terminated`
  message is generic by construction: it appears both for an unhandled exception, for a
  process killed by the system, and for a voluntary `System.exit()`. Zero
  diagnostic information on its own.
- **The real signal lived in a separate stream, not shown by default.** The
  line `SCRTYMANAGER: RunningOnRootedDeviceException exception: -7` only existed
  in `adb logcat`, a stream Frida doesn't read/show automatically. You had to
  know to open it in parallel, at the exact moment of the crash — these lines are
  unbuffered: a one-second delay, or scrolling too fast, and they're lost.
- **System noise added an extra layer of camouflage.** The same
  log block contained dozens of irrelevant lines (`AppUtils`,
  `AppButtonsPrefCtl`, `ActivityManager`, `CompatibilityChangeReporter`...) — the
  useful signal was one line in fifty, easy to miss without explicit filtering
  (`grep SCRTYMANAGER`, `grep "FATAL EXCEPTION"`).

In short: the "signless" crash wasn't a limitation of Frida or the method used,
but the intended result of an implementation choice (`System.exit` instead of
an exception) designed specifically to leave no easily observable trace —
the same anti-forensics logic seen elsewhere in this app too (encrypted
strings, reflection to hide calls, class/method names borrowed
from real APIs, see the dedicated section further below).

**4. Frida to trace back from symptom to cause.**
Knowing *what* to search for ("SCRTYMANAGER" in the log) but not *where* it came from, a
Frida script was written that hooks every overload of `android.util.Log`
(`d`/`i`/`w`/`v`/`e`) and, when the message contains that string, prints the
full Java stack trace (`Throwable.$new().getStackTrace()`) of whoever called
the log. This revealed the real chain:
```
FirebaseInitProvider.onCreate()  (the real Firebase ContentProvider, hijacked)
  → reflection → UPCEANExtension2Support.onMessageChannelReady(J J)  (a ZXing class, reused as a hideout)
    → Log.e("SCRTYMANAGER", "RunningOnRootedDeviceException exception: -7")
```
`FirebaseInitProvider` starts before any Activity/`Application.onCreate()`
(it runs inside `handleBindApplication()`), which explained why the crash happened
"before anything else happened" — there's nothing earlier to
hook into. This also retroactively validated the initial hunch
about Firebase's involvement, even though the real mechanism (hijacking
`FirebaseInitProvider`) was different from what was originally hypothesized
(`FirebaseInstanceId`).

**5. Every fix revealed the next level (controlled whack-a-mole).**
Once that specific method was neutralized via Frida (runtime no-op override), the crash
came back with a **second** SCRTYMANAGER message (`AppDebuggableException`),
from another hideout class (`MediaBrowserCompatApi26`, AndroidX). Repeating
the same technique (hook on `Log.*`, stack trace, identifying the class) found
that one too. At that point, counting how many reflection calls
`FirebaseInitProvider.onCreate()` made in total (`grep` on `Method;->invoke` in the file:
more than 60 occurrences), it became clear that chasing every hideout one
at a time was not sustainable.

**6. From "chase every check" to "generalize the pattern".**
The three hideout classes found so far all shared the exact same method
signature: `(JJ)V`. From there came the idea of **generalizing**: instead of continuing
to discover hideouts one at a time via Frida, search **statically** for all
methods with that exact signature across the entire smali tree (`grep -rn
"^\.method public static \w+(JJ)V" smali/`) — finding 15 in one shot,
many never discovered dynamically. In parallel, it was noticed that every check,
whatever it was, always ended up calling `System.exit(status)` (also visible
in logcat: `System.exit called, status: -7`) — so a "safety net" hook was also
added on `Runtime.exit`/`Runtime.halt`/`Process.killProcess`,
which neutralizes the effect of *any* check, even ones not yet discovered.

**7. The same pattern repeated for the div/0 traps.**
Similarly: the first trap (`div-int/lit8 v1, v1, 0x0` inside
`MainActivity.onPause()`) was found by **reading the code by eye** after
noticing a suspicious structural pattern (a state counter conditioning
a branch that always blows up). Once the exact shape
of the instruction was recognized, it was generalized with a grep across the entire smali
tree, finding 224 occurrences in 98 files — including third-party
library files (Gson, ZXing) never hand-written by the app's developers,
proof that the trap is injected mechanically by a hardening tool at
build time, not application code.

**The common thread**: static keyword search never worked on its
own (the strings are encrypted). What worked was always the same
cycle: *observe a real symptom dynamically (logcat/crash) → use
Frida to trace back from the stack trace to the exact cause → recognize the
exact shape of the bytecode pattern → generalize that shape with a grep across the
whole tree to find sibling instances*. The following sections are the
crystallized result of this process, not the starting point.

## Files already mapped in this session

### Div-by-zero traps (224 occurrences, 98 files)

Command to regenerate the list:
```
grep -rn "div-int(/lit8)\? [vp][0-9]\+, [vp][0-9]\+, 0x0" smali/
```
(check by eye that the two registers match — in every case observed they did)

Priority files (on the real startup path, not third-party libraries):
- `smali/net/pluservice/tua/MainActivity.smali` (1 occurrence, in `onPause`)
- `smali/org/apache/cordova/CordovaActivity.smali` (6 occurrences: `createViews`, `init`,
  `onDestroy`, `onMessage`, `onNewIntent`, `onOptionsItemSelected`)
- `smali/org/apache/cordova/CordovaPlugin.smali` (4 occurrences — not yet examined)

The remaining ~90 occurrences are scattered across third-party libraries (Gson, ZXing,
Play Services) — lower priority to edit by hand.

### Hideout methods with signature `(JJ)V` (15 total)

Command to regenerate the list:
```
grep -rn "^\.method public static \w\+(JJ)V" smali/
```

```
android/support/v4/media/MediaBrowserCompatApi26.smali
net/pluservice/plusnetworking/R$anim.smali
com/google/zxing/RGBLuminanceSource.smali
com/google/zxing/pdf417/decoder/ec/ModulusPoly.smali
com/google/zxing/oned/UPCEANExtension2Support.smali
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

## General workflow

1. **Dynamic triage before anything else, not static.** Don't start with blind
   grepping in a binary running to hundreds of thousands of lines. Use Frida to figure out
   *where* a suspicious behavior fires (hook `Log.e`/`RuntimeException.<init>`
   and read the stack trace) — it tells you the exact class/method before you've even
   opened an editor. Blind static search is the last resort, not the first.

2. **Once you understand the "shape" of a trap, grep for that exact shape, not
   the concept.** Don't search for "root check" or "security" (the strings are encrypted,
   you'll never find them) — search for the observed **bytecode pattern**: an instruction
   that mathematically always blows up (`div-int ..., 0x0`), or a pattern like
   `const/4 vX, 0x0` followed a few lines later by `invoke-virtual {vX}, ...` and then
   `throw vX` (a call on null followed by a throw).

3. **For reflection-hiding, the signal is "declared but never called
   directly".** Two separate greps (declarations vs. direct calls via
   `invoke-static`/`invoke-virtual`) and a set difference — a method with a
   suspicious signature never referenced directly anywhere in the tree is almost certainly
   reached only via reflection.

4. **Follow reused names as a sign of disguise.** The obfuscator reuses
   real Android method/field names (`onNavigationEvent`, `ICustomTabsCallback`,
   `asInterface`, `onMessageChannelReady`...) as a "mask" for state counters
   and hideouts, scattered across unrelated classes. The same unlikely method name
   inside a class that has nothing to do with that name is a strong signal.

5. **Verify each change in isolation before combining them.** First validate
   via Frida (runtime no-op, zero cost) that neutralizing that specific
   instruction/method doesn't break anything — only afterward carry the change into the
   static smali file.

## Why the `(JJ)V` signature became a signal (and its limits)

It's not that `(JJ)V` is inherently suspicious — it's a trivial signature that any
legitimate method could have. It became a useful signal **in this specific case**
for an empirical reason, not a theoretical one:

1. With Frida, three hidden security checks were observed dynamically (real stack
   traces, not hypotheses) — root check, debuggable check, and a third —
   invoked via reflection from `FirebaseInitProvider.onCreate()`.
2. All three shared exactly the same signature: `(JJ)V`.
3. Hypothesis: if the obfuscation tool generates these hideouts with an
   automatic template/codegen, it's plausible it always uses the same signature shape
   for every injected check, whatever container class is
   chosen for camouflage. Searching for that exact signature is a way to find
   "siblings" of the same already-confirmed pattern — not a general rule.

**The real signal isn't the signature, it's the signature paired with the wrong class.**
`VCardContactEncoder` (a vCard encoder for QR codes) has no
legitimate reason to have a public static method that takes two opaque longs and
returns nothing. Same for `RGBLuminanceSource` or for a resource class
`R$drawable`/`R$anim` (which should only contain `int` constants, never methods
with logic). The semantic mismatch between context and content is the real clue;
the signature is just the practical shortcut for finding it via grep.

Why two `long`s, probably (unverified speculation): convenient for
packing a selector/flag/magic-value into a single parameter (the captured
arguments, e.g. `5571322406892470000, 1297174580`, look like opaque values), and a
fixed `(long, long)` signature shape resembles real Android callbacks, which
aligns with the camouflage strategy seen everywhere in this app.

**Limits of the heuristic:**
- Possible false positives: a legitimate method elsewhere could coincidentally
  have the same signature.
- Certain false negatives: if the obfuscator uses different signatures for other checks not
  yet discovered dynamically, this grep won't find them — for those you need
  to go back to step 1 of the workflow (dynamic triage) before updating the signature
  to search for.

## Examples of names/signatures reused as camouflage

Point 4 of the general workflow says to "follow reused names" — here are the
concrete cases found in this app, comparing the name's real meaning
in the Android API against the (incorrect/unrelated) use the obfuscator makes of it. In each
case the name is identical, but the signature, class, and purpose have nothing to do with
the original — it's exactly this mismatch that's the signal to look for, not the name
itself.

| Reused name | Real meaning (Android API) | Usage found in the app | Key difference |
|---|---|---|---|
| `onNavigationEvent` | Method of the AIDL interface `ICustomTabsCallback.onNavigationEvent(int, Bundle)` — the browser notifies navigation events (START, FINISHED, FAILED...) to an app that opened a Custom Tab | Static field `private static onNavigationEvent:I` used as a state counter (in `CordovaActivity`, `MainActivity`, `PluserviceKeyStore`); elsewhere it's instead a static method `(JJ)V` (`o/setImeOptions.smali`, `ApiKey.smali`) | The real signature is `(int, Bundle): void` inside an AIDL interface. Here it's sometimes a plain `int`, sometimes a method with a completely different signature — no relation to Custom Tabs |
| `onMessageChannelReady` | `ICustomTabsCallback.onMessageChannelReady(Bundle)` — notifies that an app↔browser postMessage channel is ready | `UPCEANExtension2Support.onMessageChannelReady(long, long): void` — **the root-check hideout** found with Frida | Different signature (`(JJ)V` instead of `(Bundle)V`), inside a ZXing barcode-decoding class that has nothing to do with browser tabs |
| `ICustomTabsCallback` | Name of the entire AIDL **interface** (not a method), with multiple methods inside it | Reused as the name of a single static *method* in `VCardContactEncoder.smali` (`(JJ)V`) and in `PluserviceKeyStore.smali` (`(Context, int, int): Object[]`) | An interface with multiple methods has been "flattened" into a single method name, reused with different signatures in unrelated classes |
| `asInterface` | Standard AIDL-generated pattern: `XXX.Stub.asInterface(IBinder)` converts a raw Binder into the typed interface | Static field `private static asInterface:I`, a plain counter (`CordovaActivity`, `PluserviceKeyStore`) | The real API is a method that takes an `IBinder` and returns an object; here it's just a number going up and down |
| `getActiveNotifications` | `NotificationListenerService.getActiveNotifications()` — returns the active notifications for a notification-listener service | `.super Lo/getActiveNotifications;` — **the entire superclass of `CordovaActivity`** renamed this way (actually `androidx.appcompat.app.AppCompatActivity`) | The most extreme case: here the "reuse" isn't even a method, but the name of an entire **class** — aggressive enough to be mistaken for an unidentified legitimate API |
| `getEnterTransitionCallback` | Traceable to Fragment shared-element-transition APIs (`SharedElementCallback`, screen-to-screen animations) | `Lo/getEnterTransitionCallback` is a **custom exception class** (with an `Enum` field), thrown and caught in the same method purely as a disguised goto — not a real exception | In the real API it's a callback for UI animations; here it's a control-flow trick that doesn't throw/catch a real error |

**Why this fools even a careful human reader**: during analysis, seeing
`invoke-super {p0, p1}, Lo/getActiveNotifications;->onCreate(...)` instinctively
suggests a real, not-yet-seen class, not a renamed `AppCompatActivity` — you need
to follow the hierarchy (`.super`) and verify what the method actually does
(calls `setContentView`, manages the `ActionBar`...) before trusting the name. The same
caution applies to every "familiar" name encountered in a class that, on
reflection, shouldn't need it.

## Quick guide to grep and the regexes used

### grep flags

Basic syntax: `grep [flag...] PATTERN file...`

| Flag | What it does | Example from this session |
|---|---|---|
| `-n` | Shows the line number before each match | `grep -n "onCreate" file.smali` → `6980:.method public onCreate...` |
| `-r` / `-R` | Searches recursively through all subfolders | `grep -rn "pattern" smali/` |
| `-i` | Case-insensitive (ignores upper/lowercase) | searching `root\|Rooted\|ROOT` with a single pattern |
| `-v` | **Inverts** the match: prints lines that do NOT match | useful for excluding noise |
| `-c` | Counts matching **lines** (not total occurrences!) per file | `grep -rc "pattern" smali/` |
| `-o` | Prints **only** the matched part, not the whole line | useful with `wc -l` to count total occurrences instead of lines |
| `-l` | Prints only the names of files with at least one match | equivalent to `output_mode: files_with_matches` |
| `-A N` | Prints N lines **after** each match (After) | `grep -A 30 "FATAL EXCEPTION" logcat.txt` |
| `-B N` | Prints N lines **before** each match (Before) | seeing the context before `div-int/lit8` |
| `-C N` | Context: N lines before AND after (Context) | shorthand for `-A N -B N` together |
| `-w` | Match whole words only (not substrings) | avoids false positives on partial names |
| `-E` | Extended regex: enables `+ ? \| ( )` as metacharacters without a backslash | **essential**, see below |
| `-P` | Perl-compatible regex (GNU grep only): enables `\d`, `\w`, lookahead | alternative to `-E` with richer syntax |
| `--include="*.smali"` | Filters by filename pattern when using `-r` | equivalent to the `glob` parameter |

⚠️ **Practical warning**: `-c` counts matching **lines**, not total
occurrences. If a line contains the pattern twice, it still counts as 1. To count total
occurrences: `grep -o "pattern" file | wc -l`.

### plain `grep` vs `grep -E` (a crucial difference)

"Bare" `grep` uses **BRE** (Basic Regular Expressions): characters like `+ ? | ( )`
are **literal**, not special. To make them special you need a backslash in front
(`\+`, `\?`, `\|`, `\(`, `\)`).

With `-E` (or `egrep`) you get **ERE** (Extended): `+ ? | ( )` are special by default,
and to match them literally you need a backslash (`\+` for a literal `+`).

A tool built on ripgrep always behaves like `-E` (in fact, richer, in the
Rust-regex/PCRE style) — you never need an equivalent flag. But copying these patterns into
a terminal with plain `grep`, without `-E` they won't work as intended.

### The regexes explained on the real patterns used in this session

**Pattern 1 — the div/0 traps**
```
div-int(/lit8)? [vp]\d+, [vp]\d+, 0x0
```
| Piece | Meaning |
|---|---|
| `div-int` | Literal text — matches itself |
| `(/lit8)?` | `( )` groups `/lit8`; `?` after the group = "0 or 1 times" → captures both `div-int` and `div-int/lit8` |
| `[vp]` | Character class: matches exactly one character, `v` or `p` |
| `\d` | Shorthand for "a digit" (`[0-9]`) |
| `+` | Quantifier: "one or more repetitions of the preceding element" |
| `0x0` | Literal — the three characters/digits `0`, `x`, `0` |

Reads as: *"`div-int`, optionally followed by `/lit8`, then a register (`v`/`p` +
number), comma, another register in the same form, comma, `0x0`"*.

**Pattern 2 — the hideout methods**
```
^\.method public static \w+\(JJ\)V
```
| Piece | Meaning |
|---|---|
| `^` | Anchor: "start of line" (a position, not a character) |
| `\.` | A bare `.` means "any character"; escaped with `\` it matches a literal dot |
| `\w+` | `\w` = word character (letters/digits/underscore); `+` = one or more times |
| `\(` `\)` | Round parentheses are grouping metacharacters; escaped they match literal parentheses |

**Pattern 3 — alternation**
```
SCRTYMANAGER|RunningOnRootedDeviceException
```
`|` is a logical OR: matches the text on the left or the text on the right.

### Symbol summary table

| Symbol | Name | Meaning |
|---|---|---|
| `.` | Dot (unescaped) | Any single character |
| `\.` | Escaped dot | The literal `.` character |
| `*` | Asterisk | 0 or more repetitions of the preceding character/group |
| `+` | Plus | 1 or more repetitions |
| `?` | Question mark | 0 or 1 repetition (makes the preceding element optional) |
| `^` | Caret | Anchor: start of line |
| `$` | Dollar | Anchor: end of line |
| `[abc]` | Character class | Any one of the listed characters |
| `\d` | Shorthand | A digit `[0-9]` |
| `\w` | Shorthand | A word character `[a-zA-Z0-9_]` |
| `(...)` | Group | Groups multiple characters to apply a quantifier to them together |
| `\(` `\)` | Escaped parentheses | Literal round parentheses (not grouping) |
| `\|` | Pipe | OR between alternatives |

### Practical exercises

```bash
# count the lines with "onCreate" across all smali files
grep -rc "onCreate" smali/ | grep -v ":0"

# find every ZXing class with a suspicious method
grep -rEn "^\.method public static \w+\(JJ\)V" smali/com/google/zxing/

# print 5 lines of context before and after each "div-int...0x0"
grep -B 5 -A 2 "div-int/lit8.*0x0" smali/net/pluservice/tua/MainActivity.smali
```

## See also

- [[Tua-Case-Study]]
- [[Case-Studies]]
