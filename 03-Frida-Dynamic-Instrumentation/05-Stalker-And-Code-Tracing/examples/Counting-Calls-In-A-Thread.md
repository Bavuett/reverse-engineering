---
tags: [example]
level: 1
aliases: ["Stalker call summary", "Stalker onCallSummary"]
created: 2026-11-12
---

# Example: Counting-Calls-In-A-Thread

> [!info] Level 1 — basics
> One idea: Stalker can follow a thread and simply *count* which functions it calls — a cheap first look at what a thread is doing, without any per-event processing.

## Goal

Follow the app's main thread for a few seconds and print the ten most-called targets, with symbol names where available. Belongs to [[Stalker-And-Code-Tracing]].

## Script

```javascript
const mainTid = Process.enumerateThreads()[0].id;   // first thread = the app's main thread

Stalker.follow(mainTid, {
    events: { call: true },
    onCallSummary(summary) {                      // { "0x7a1c2034": 17, ... }
        const top = Object.entries(summary)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 10);
        for (const [target, count] of top) {
            const sym = DebugSymbol.fromAddress(ptr(target));
            console.log(`${String(count).padStart(6)}  ${target}  ${sym}`);
        }
    }
});

setTimeout(() => {
    Stalker.unfollow(mainTid);
    Stalker.flush();
    console.log("[*] stopped");
}, 3000);
```

## Step by step

1. **Pick a thread.** Stalker follows one thread at a time. `Process.enumerateThreads()` lists them; on Android the first is normally the main (UI) thread. Inside a hook, `Process.getCurrentThreadId()` gives the thread that called the hooked function.
2. **`events: { call: true }`** asks for call events only — not every instruction. That keeps overhead tolerable.
3. **`onCallSummary`** receives an aggregated map *target address → number of calls* for each batch, instead of the raw event list `onReceive` would get. Counting is done inside Stalker's native side, so it's much cheaper than parsing events in JS.
4. **`DebugSymbol.fromAddress`** turns an address into `module!symbol` when a symbol exists — exported functions resolve, stripped internals show `module!0x…`.
5. **Always unfollow and flush.** A followed thread runs recompiled code until `unfollow`; `flush` delivers any buffered events. Forgetting this leaves the app permanently slowed.
6. **Reading the result.** Top entries are usually allocator, locking and libc string functions; the interesting targets are the app-module addresses further down. Filter to one module's range when you know where to look ([[Coverage-Diff-To-Locate-A-Feature]]).

## Compared with real code

- [[Tracing-Libencrypt-Decrypt-Calls-With-Stalker]] — the same idea scoped to one real JNI function, where the expected callee list is known from disassembly.
- [[Finding-Function-Boundaries-And-Calls]] in [[ARM64-Android]] — reading the same call list statically, from `bl` instructions.

## See also

- [[Stalker-And-Code-Tracing]]
- [[Stalker-Follow-And-Unfollow-Around-A-Call]]
- [[Stalker-Follow-And-Transform]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
