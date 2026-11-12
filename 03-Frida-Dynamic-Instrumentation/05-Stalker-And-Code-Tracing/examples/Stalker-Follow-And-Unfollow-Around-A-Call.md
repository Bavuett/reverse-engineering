---
tags: [example]
level: 1
aliases: ["scoped Stalker trace", "Stalker inside Interceptor"]
created: 2026-11-12
---

# Example: Stalker-Follow-And-Unfollow-Around-A-Call

> [!info] Level 1 — basics
> One idea: start Stalker in a hook's `onEnter` and stop it in `onLeave`, so you trace exactly one call of one function and nothing else.

## Goal

Record which functions a native function calls during one invocation, as an ordered list. Belongs to [[Stalker-And-Code-Tracing]].

## Script

```javascript
const mod = Process.getModuleByName("libtarget.so");
const target = mod.getExportByName("process_packet");

Interceptor.attach(target, {
    onEnter() {
        this.tid = Process.getCurrentThreadId();
        this.calls = [];
        const calls = this.calls;
        Stalker.follow(this.tid, {
            events: { call: true },
            onReceive(events) {
                for (const [, from, to] of Stalker.parse(events)) {
                    const t = ptr(to);
                    if (t.compare(mod.base) >= 0 && t.compare(mod.base.add(mod.size)) < 0)
                        calls.push(`+0x${t.sub(mod.base).toString(16)}`);   // keep only in-module callees
                }
            }
        });
    },
    onLeave() {
        Stalker.unfollow(this.tid);
        Stalker.flush();
        // events arrive asynchronously; print after a short delay
        setTimeout(() => console.log(`[*] calls: ${this.calls.join(" -> ")}`), 100);
    }
});
```

## Step by step

1. **Same thread on both sides.** `onEnter` and `onLeave` run on the thread executing the call, so `Process.getCurrentThreadId()` identifies exactly the thread to follow and unfollow.
2. **`Stalker.parse(events)`** decodes the binary event buffer into arrays; for `call` events each is `["call", from, to, depth]`.
3. **Filter by module range** so the list shows the target's own internal calls rather than every libc helper. Printing them as module offsets makes them directly comparable to a disassembler listing.
4. **Events are delivered asynchronously** in batches; `flush()` forces the last batch out, and printing slightly later avoids reading an incomplete list.
5. **Re-entrancy.** If the function recurses or is called again while already followed, `follow` on an already-followed thread is a mistake; guard with a flag if the target can nest.
6. **Use it to answer one question**: "on *this* input, which path did it take?" — the dynamic confirmation of a hypothesis built by reading disassembly ([[Reading-Raw-Disassembly]]).

## Compared with real code

- [[Tracing-Libencrypt-Decrypt-Calls-With-Stalker]] — this exact pattern applied to PressReader's real `Encryption.decrypt` JNI function.
- [[Stalking-A-Dart-AOT-Login-Path-In-ClasseViva]] — the same bracket around a Dart AOT function reached by offset, not by export.

## See also

- [[Stalker-And-Code-Tracing]]
- [[Counting-Calls-In-A-Thread]]
- [[Resolving-An-Indirect-Call-With-Stalker]]

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
