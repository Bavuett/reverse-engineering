---
tags: [reference, reference-entry]
category: "Tracing API"
created: 2026-11-11
---

# Stalker-Follow-And-Transform

## Signature / syntax

```javascript
// Exclude uninterested modules before following (reduces overhead & noise)
Stalker.exclude({ base: mod.base, size: mod.size })

// Start tracing a thread (defaults to current thread if tid omitted)
Stalker.follow(threadId, {
    events: {
        call: false,    // CALL instructions (BL, BLR)
        ret: false,     // RET instructions
        exec: false,    // every single instruction
        block: false,   // start of each basic block (coarse execution trace)
        compile: false  // basic block compiled by Stalker for the first time (coverage)
    },
    onReceive(rawEvents) {
        // Parse binary event buffer into [type, from/addr, to, depth] tuples
        const events = Stalker.parse(rawEvents, { annotate: true, stringify: false });
    },
    onCallSummary(summary) {
        // { targetAddress: callCount, ... } per flush window
    },
    transform(iterator) {
        let instruction = iterator.next();
        do {
            // Inspect instruction (Address, mnemonic, opStr, groups)
            // Optionally inject a runtime callback before keeping the instruction:
            // iterator.putCallout(context => { ... });
            iterator.keep();
        } while ((instruction = iterator.next()) !== null);
    }
});

// Stop tracing and reclaim recompiled code caches
Stalker.unfollow(threadId)
Stalker.flush()
Stalker.garbageCollect()
```

## Description

`Stalker` is Frida's dynamic binary translation and code-tracing engine: when `Stalker.follow(threadId, options)` is called on a thread, Stalker intercepts that thread's execution and recompiles each basic block on the fly into an instrumented code cache before running it, rewriting branch targets so execution never escapes the cache. It supports two complementary modes that can be used independently or together: **event collection** (`events` + `onReceive` / `onCallSummary`), where Stalker emits batched binary records for function calls (`call`), returns (`ret`), executed basic blocks (`block`), newly compiled blocks (`compile`), or individual instructions (`exec`); and **custom instrumentation** (`transform(iterator)`), where your callback iterates through each instruction of a basic block as Stalker compiles it (`iterator.next()`), keeps or replaces instructions via the underlying `Arm64Writer` (`iterator.keep()`), and optionally inserts a `putCallout(context => { ... })` probe that fires at runtime with the live `CpuContext` whenever that specific instruction executes.

## Example

```javascript
const appMod = Process.getModuleByName("libapp.so");

// Exclude every module EXCEPT libapp.so so Stalker doesn't recompile libc/libart/BoringSSL
Process.enumerateModules().forEach(m => {
    if (m.name !== appMod.name) {
        Stalker.exclude({ base: m.base, size: m.size });
    }
});

const entry = appMod.base.add(0x51a0);
Interceptor.attach(entry, {
    onEnter() {
        this.tid = Process.getCurrentThreadId();
        Stalker.follow(this.tid, {
            events: { call: true, compile: true },
            onReceive(events) {
                for (const ev of Stalker.parse(events, { annotate: true })) {
                    if (ev[0] === "call") {
                        const [, from, to] = ev;
                        console.log(`[call] +0x${from.sub(appMod.base).toString(16)} -> +0x${to.sub(appMod.base).toString(16)}`);
                    }
                }
            },
            transform(iterator) {
                let insn = iterator.next();
                do {
                    // Log the concrete target register of any indirect call (BLR) inside libapp.so
                    if (insn.mnemonic === "blr") {
                        const reg = insn.operands[0].value;
                        const pcOff = insn.address.sub(appMod.base);
                        iterator.putCallout(ctx => {
                            console.log(`[blr ${reg} @ +0x${pcOff.toString(16)}] target=${ctx[reg]}`);
                        });
                    }
                    iterator.keep();
                } while ((insn = iterator.next()) !== null);
            }
        });
    },
    onLeave() {
        Stalker.unfollow(this.tid);
        Stalker.flush();
        Stalker.garbageCollect();
    }
});
```

## Notes

- **Scope and ANR prevention**: Stalker's block recompilation and JS callouts carry heavy CPU and memory overhead; following Android's main UI thread continuously or leaving `events.exec: true` on across all modules will quickly trigger an Application Not Responding (ANR) watchdog kill. Always bracket `Stalker.follow`/`Stalker.unfollow` inside an `Interceptor.attach` `onEnter`/`onLeave` pair around the specific function under study, and call `Stalker.exclude(range)` on system libraries (`libc.so`, `libart.so`, etc.) so calls into them execute natively at full speed without being traced.
- Inside `transform(iterator)`, the outer `while` loop runs **at block-compilation time** (once per basic block when Stalker first encounters it), whereas a function passed to `iterator.putCallout(fn)` runs **at execution time** (every time the thread executes that instruction). Do not confuse the two: inspecting `insn.mnemonic` happens once during compilation, while reading `ctx.x0` inside `putCallout` happens on every hit.
- Every `iterator.next()` call in `transform` **must** call `iterator.keep()` (unless you are intentionally dropping or replacing the instruction with `Arm64Writer` methods on `iterator`), or the omitted instruction will literally disappear from the recompiled basic block and crash the target thread.
- After `Stalker.unfollow(tid)`, call `Stalker.flush()` to drain any buffered events to `onReceive` and `Stalker.garbageCollect()` to free the instrumented code caches once no thread is executing inside them.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
- [[Frida-Dynamic-Instrumentation-Glossary|Glossary]]
- [[Stalker-And-Code-Tracing]]
- [[Static-Dynamic-Integration]]
- [[Coverage-Diff-To-Locate-A-Feature]]
- [[Resolving-An-Indirect-Call-With-Stalker]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
