---
tags: [example]
level: 2
aliases: ["Stalker transform putCallout", "Stalker register inspection"]
created: 2026-11-12
---

# Example: Inspecting-Registers-With-A-Transform-Callout

> [!info] Level 2 — intermediate
> Instead of receiving events after the fact, rewrite the code Stalker is about to run: a `transform` iterates each basic block's instructions and can insert a *callout* — a JS function that sees the live CPU context at that exact instruction.

## Goal

Log the comparison operands of every `cmp` instruction inside one function while it runs — e.g. to see what a parsed value is compared against. Belongs to [[Stalker-And-Code-Tracing]].

## Script

```javascript
const mod = Process.getModuleByName("libtarget.so");
const fn = mod.base.add(0x1a2b0);              // function under study (from the disassembler)
const fnEnd = fn.add(0x200);                   // its size, from the same listing

Interceptor.attach(fn, {
    onEnter() {
        this.tid = Process.getCurrentThreadId();
        Stalker.follow(this.tid, {
            transform(iterator) {
                let insn = iterator.next();
                do {
                    const inFn = insn.address.compare(fn) >= 0 && insn.address.compare(fnEnd) < 0;
                    if (inFn && insn.mnemonic === "cmp") {
                        const [a, b] = insn.operands;            // register / immediate operands
                        const where = insn.address.sub(mod.base);
                        iterator.putCallout(ctx => {
                            const va = a.type === "reg" ? ctx[a.value] : ptr(a.value);
                            const vb = b.type === "reg" ? ctx[b.value] : ptr(b.value);
                            console.log(`+0x${where.toString(16)}  cmp ${va}, ${vb}`);
                        });
                    }
                    iterator.keep();                              // emit the original instruction
                } while ((insn = iterator.next()) !== null);
            }
        });
    },
    onLeave() {
        Stalker.unfollow(this.tid);
        Stalker.flush();
    }
});
```

## Step by step

1. **`transform(iterator)`** runs once per basic block, the first time Stalker compiles it. `iterator.next()` yields each instruction (a Capstone-style object with `address`, `mnemonic`, `opStr`, `operands`); `iterator.keep()` copies it into the recompiled block. Skipping `keep()` *drops* the instruction — a powerful but dangerous patch.
2. **`putCallout(fn)`** inserts a call to `fn(context)` *before* the next kept instruction. `context` holds the live registers (`ctx.x0`…`ctx.x28`, `ctx.sp`, `ctx.pc`), so at a `cmp` you see both operand values at that moment.
3. **The transform runs once, the callout every time.** Decisions like "is this a `cmp` in my function?" belong in the transform (cheap, once per block); only the reading belongs in the callout (every execution).
4. **Operand register names** (`x8`, `w9`) map to context keys; `w` registers are the low half of `x`, so mask or use `.toInt32()` when the code compares 32-bit values.
5. **Callouts are slow** (a native → JS transition each time). For hot loops, write the logic as a `CModule` (C compiled in the target) or log only the first N hits.
6. **Scope narrowly** — follow only inside the function's hook, as here. A whole-thread transform with callouts can make an app unusably slow.

## Compared with real code

- [[Recognizing-A-Hash-Loop-By-Its-Constants]] in [[ARM64-Android]] — the kind of comparison-heavy loop whose operands this technique reveals at runtime.
- [[Tracing-Libencrypt-Decrypt-Calls-With-Stalker]] — a real function where the branch decisions (`cbz w0` after `GetXmlAtribute`, a `b.lt` on the decrypted length) are exactly what a callout would confirm.

## See also

- [[Stalker-And-Code-Tracing]]
- [[Stalker-Follow-And-Transform]]
- [[Forcing-A-Conditional-Branch-With-PatchCode]] — changing the outcome instead of observing it

## References

- [[Frida-Dynamic-Instrumentation-Bibliography|Bibliography]]
