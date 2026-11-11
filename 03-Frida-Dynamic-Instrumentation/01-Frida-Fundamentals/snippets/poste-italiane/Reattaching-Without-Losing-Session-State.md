---
tags: [snippet]
project: "Poste Italiane (com.posteitaliane.spim)"
source: "com.posteitaliane.spim — the official Poste Italiane Android app, from Google Play"
version: "6.0.38"
source_path: "frida CLI invocations (shell history), not app source"
date_added: 2026-09-04
license_note: "Personal study/research purposes only, against a device and account the investigator owns."
---

# Reattaching-Without-Losing-Session-State

## Context

Once past login, the app was already authenticated and mid-session — spawning fresh (`-f`) would have meant a cold restart and re-doing the whole PIN+OTP login flow just to add one more hook (a `RealInterceptorChain.proceed` exception logger, added to chase down a specific bug). Attaching to the already-running, already-authenticated process instead kept that session state intact while still getting the new hook in place before the next relevant network call.

## Original path

`` frida CLI invocations, not app source ``

## Snippet

### Example 1 — reattaching post-login, to test a script change without re-authenticating

```
# Get the PID of the already-running, already-logged-in process
adb shell "su -c 'pidof com.posteitaliane.spim'"

# Attach (not spawn) — the app keeps running exactly as it was; the new script's
# hooks apply to everything from this point forward, but miss anything that
# already happened (e.g. the original login network calls)
frida -U -p 13834 -l http-pinning-bypass-and-dump.js -q -t inf
```

### Example 2 — reattaching mid-investigation, after a process the app itself relaunched

```
adb shell "su -c 'ps -A | grep posteitaliane'"
# u0_a176      10636   660 42980208  419948 0    R com.posteitaliane.spim   <- new PID, not 13834

frida -U -p 10636 -l root-and-frida-hiding.js -l http-pinning-bypass-and-dump.js -l login-diagnostics.js -q -t inf
```

Same command shape as Example 1, but a genuinely different situation: the app's own process had been recreated (a normal Android lifecycle event here, not a crash — no `FATAL EXCEPTION` in `adb logcat` around the PID change) between the previous attach and this one. Attaching by *name* instead of PID (`frida -U -n "Poste Italiane"`) would have survived this transparently, at the cost of Frida picking whichever process currently owns that name — worth the PID lookup's extra step when precision matters more than convenience, as it did here while actively correlating hook output against a specific process's `adb logcat` timeline.

## Notes

- This is the direct, practical version of the attach-vs-spawn tradeoff [[Frida-Fundamentals]] states in the abstract: attach only sees events *after* the script is injected. Here that tradeoff was a deliberate choice, not a limitation being worked around — losing the already-logged-in session by spawning fresh would have cost more (a full re-auth cycle, including PIN/OTP) than the hook gap it avoided.
- Used repeatedly through this case study whenever a script fix needed testing against a process that had already reached a state (logged in, past a splash-screen ANR, past onboarding) that was expensive to reproduce from a cold spawn.
- Getting the current PID cheaply (`adb shell "su -c 'pidof <package>'"`) before every reattach was necessary specifically because the app's process kept getting a *new* PID across restarts during this session (crashes, force-stops, the `frida-server` wedge above) — a stale, remembered PID silently fails to attach to anything.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Frida-Fundamentals]]
- [[Diagnosing-A-Wedged-Frida-Server]]
- [[Poste-Italiane]] in [[Case-Studies]]
