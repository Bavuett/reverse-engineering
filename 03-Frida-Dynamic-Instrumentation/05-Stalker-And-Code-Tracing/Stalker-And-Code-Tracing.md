---
tags: [fundamentals]
aliases: ["Stalker", "Instruction Tracing", "Code Coverage"]
created: 2026-07-28
---

# Stalker-And-Code-Tracing

## In short

`Interceptor.attach` (see [[Native-Memory-And-ARM64]]) tells you what happens at a handful of addresses you already picked. Frida's **Stalker** engine does the opposite: it follows a thread through *every* instruction it executes, transparently recompiling each basic block so it can emit an event before continuing — call tracing, block tracing, or full instruction-level tracing, over a region you specify. Where `Interceptor` requires you to already know what you're looking for, Stalker is how you find it: point it at a thread around the moment something interesting happens (a click, a login) and get back the actual, ground-truth path the CPU took, instead of a guess built from reading disassembly cold.

## Explanation

### Why this matters on top of static disassembly

[[Reading-Raw-Disassembly]] in [[ARM64-Android]] teaches you to read a function's disassembly and reconstruct its control flow *by hand* — which branch is taken, which `switch` arm executes, whether a loop runs zero or many times. That reconstruction is always a hypothesis until something confirms it. Stalker removes the guesswork for a specific run: instead of asking "which branch would be taken if X", you run the app with X actually true and get the literal sequence of blocks/calls that executed. It's the single fastest way to turn "I think this is a state machine with N branches" into "here is the exact path taken on this input."

### Following a thread

```javascript
const tid = Process.getCurrentThreadId(); // or a specific thread ID from Process.enumerateThreads()

Stalker.follow(tid, {
    events: {
        call: true,   // function calls
        ret: false,   // returns
        exec: false,  // every single instruction — very high volume, use sparingly
    },
    onReceive(events) {
        const parsed = Stalker.parse(events, { annotate: true, stringify: false });
        parsed.forEach(([kind, from, to]) => {
            console.log(`[${kind}] ${from} -> ${to}`);
        });
    }
});

// ... later, once you have what you need:
Stalker.unfollow(tid);
Stalker.flush();
```

`events.call` alone (rather than `exec`) is almost always the right starting point — a full instruction trace (`exec: true`) over any nontrivial time window produces an overwhelming amount of data and a real performance hit, since Stalker has to recompile every block it hasn't already cached.

### Turning a trace into a call graph

Combining `call` events with `Module.findRangeByAddress(address)` (or a pre-built table of a module's known function boundaries, e.g. from Ghidra's export) lets you map each raw address in the trace back to a symbol name, producing something close to a real call graph for whatever code path just ran — genuinely hard to reconstruct by hand from static disassembly alone once indirect calls (vtables, Dart AOT's dispatch table — see [[Flutter-Dart-AOT]]) are involved.

### Coverage tracing

A common, narrower use: run the app through one specific flow (e.g. tap "login"), collect the set of unique addresses/blocks visited via `events.block`, and diff that set against a second run through a *different* flow. Addresses that appear only in the login-flow trace and nowhere else are very likely login-specific logic — a fast way to narrow down where in a large `.so` a specific feature lives, before opening Ghidra at all.

### Cost and scope

Stalker only follows *one thread* at a time (`Stalker.follow(threadId, ...)`) and only while explicitly told to — always pair `Stalker.follow` with a matching `Stalker.unfollow`, ideally scoped tightly around the moment you care about (e.g. inside an `Interceptor.attach`'s `onEnter`/`onLeave` for the function that starts the flow you want traced), rather than leaving it running for the whole app lifetime.

## Worked example

Trace every native call made by the current thread for exactly the duration of one native function call, bracketing `Stalker.follow`/`unfollow` around an existing `Interceptor.attach` hook:

```javascript
const target = Module.findExportByName("libnative-lib.so", "Java_com_example_app_Auth_login");

Interceptor.attach(target, {
    onEnter() {
        this.tid = Process.getCurrentThreadId();
        Stalker.follow(this.tid, {
            events: { call: true },
            onReceive(events) {
                Stalker.parse(events, { annotate: true }).forEach(([kind, from, to]) => {
                    console.log(`[call] ${from} -> ${to}`);
                });
            }
        });
    },
    onLeave() {
        Stalker.unfollow(this.tid);
        Stalker.flush();
    }
});
```

## More examples

- [[Frida-JS-API-Cheatsheet]] in [[Cheatsheets]].

## See also

- [[Native-Memory-And-ARM64]]
- [[Static-Dynamic-Integration]] — using a Stalker trace's addresses together with a disassembler.
- [[Reading-Raw-Disassembly]] in [[ARM64-Android]] — the static-analysis skill Stalker's output confirms or corrects.

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]

## Flashcards
#flashcards

What's the key difference between what `Interceptor.attach` and `Stalker` each let you observe?::`Interceptor.attach` only sees the specific addresses you already told it to hook; `Stalker` follows a thread through every instruction/call it actually executes, so it reveals paths you didn't already know to look for.

Why is `events.exec` (full instruction tracing) usually a bad first choice compared to `events.call`?::Full instruction tracing produces a very high volume of events and forces Stalker to recompile every executed block, which is both noisy to analyze and a significant performance cost — `call`-level tracing is almost always enough to answer "what ran".

What's a fast way to narrow down where in a large native library a specific feature lives, without opening a disassembler first?::Coverage tracing — collect the set of unique addresses/blocks visited during one flow (e.g. login), collect the set for a different, unrelated flow, and diff them; addresses unique to the flow of interest are strong candidates for where that feature's code lives.
