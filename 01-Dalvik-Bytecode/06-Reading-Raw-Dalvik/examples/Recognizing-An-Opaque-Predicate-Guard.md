---
tags: [example]
created: 2026-07-30
---

# Example: Recognizing-An-Opaque-Predicate-Guard

## Goal

Read a small chunk of unannotated smali and recognize an **opaque-predicate-gated trap** — a branch that looks conditional but whose outcome is fixed at compile time, guarding a deliberate crash (`div-int/lit8 ..., 0x0` → `ArithmeticException`, or a bare `throw`). Belongs to [[Reading-Raw-Dalvik]]. This is the exact anti-tamper shape the TUA case study found injected across the app; the skill is spotting it without any comments to help.

## Walkthrough

```smali
.method public onResume()V
    .registers 4
    invoke-super {p0}, Landroidx/appcompat/app/AppCompatActivity;->onResume()V

    sget v0, Lnet/pluservice/tua/MainActivity;->a:I     # static state field
    const/16 v1, 0x2a                                   # 42
    if-ne v0, v1, :cond_0                               # "if a != 42, skip the trap"

    const/4 v2, 0x0
    div-int/lit8 v2, v2, 0x0                            # 0 / 0  -> ArithmeticException at runtime

    :cond_0
    return-void
.end method
```

## Step by step

1. The branch `if-ne v0, v1, :cond_0` reads like a normal guard, but `v0` comes from a **static field the app controls** (`MainActivity->a`) and `v1` is a fixed constant. If you trace the field and find it's only ever set to a value that makes the branch fall *into* the trap on a tampered device, the "condition" is opaque — its result is effectively decided ahead of time, not by real program state.
2. `div-int/lit8 v2, v2, 0x0` is the payload: an integer divide by a literal zero, which throws `ArithmeticException: / by zero` at runtime. It's a crash disguised as arithmetic — there's no `throw` to grep for, which is the point. A bare `throw vN` after a decoded message is the other common form.
3. The trap sits in a lifecycle override (`onResume`/`onPause`/`onStart`) so it fires on ordinary app use, not at a suspicious-looking entry point. Recognizing it means noticing that a normal-looking override contains arithmetic whose only purpose is to be undefined.
4. The neutralization (see [[Anti-Tampering-Pattern-Workflow]]) is to make the method delegate to its real superclass implementation and drop the trap — but first you have to *see* it, which is this example's skill: a guarded `div/0` in a lifecycle method is almost never legitimate code.

## Diagram

```mermaid
graph TD
    A["onResume"] --> B["read static field a"]
    B --> C{"a != 42 ?"}
    C -->|true (normal)| E["return-void"]
    C -->|false (tampered)| D["div-int/lit8 v2, v2, 0x0 -> crash"]
```

## See also

- [[Reading-Raw-Dalvik]]
- [[Dalvik-Instructions]] — the `if-*`, `div-int/lit8`, `sget` shapes read here.
- [[Anti-Tampering-Pattern-Workflow]] and [[Tua-Case-Study]] in [[Case-Studies]] — the real app this pattern was generalized from.

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
