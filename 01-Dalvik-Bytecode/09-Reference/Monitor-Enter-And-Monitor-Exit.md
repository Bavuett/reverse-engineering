---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-11-11
---

# Monitor-Enter and Monitor-Exit

## Signature / syntax

```
monitor-enter vAA
monitor-exit vAA
```

## Description

Acquire (`monitor-enter`) or release (`monitor-exit`) the intrinsic monitor (reentrant mutex) associated with the object reference in `vAA`. If `vAA` is `null`, both instructions throw `NullPointerException` immediately; if `monitor-exit` is executed by a thread that does not currently own `vAA`'s monitor, it throws `IllegalMonitorStateException`.

In Dalvik bytecode, **every Java `synchronized` construct — both `synchronized (obj) { ... }` blocks and `synchronized` methods — compiles down to explicit `monitor-enter` and `monitor-exit` instructions**:

- A `synchronized (expr) { ... }` block evaluates `expr` into a register `vAA`, executes `monitor-enter vAA`, runs the body, and executes `monitor-exit vAA` on every normal and exceptional exit path.
- A `synchronized` instance method carries the `declared-synchronized` access flag on `.method`, which is purely informational in dex (the runtime-enforced `synchronized` flag is only valid on `native` methods); the compiler emits `monitor-enter p0` at the top of the method and `monitor-exit p0` before every return or unwind.
- A `static synchronized` method likewise carries `declared-synchronized` and locks the class object itself by loading `const-class v0, LMyClass;` and executing `monitor-enter v0` / `monitor-exit v0`.

## Example

Two synchronized accessors from [[Exercise-06-Static-Monitors-And-Iterators]] (`bp.m1`), showing both a `synchronized (r)` block on a static field and a `static declared-synchronized` method locking `Lbp/m1;.class`:

```smali
.method public static c()Ljava/util/ArrayList;
    .locals 2

    sget-object v0, Lbp/m1;->r:Ljava/util/LinkedList;
    monitor-enter v0

    :try_start_0
    new-instance v1, Ljava/util/ArrayList;
    invoke-direct {v1, v0}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V
    monitor-exit v0
    return-object v1

    :catchall_0
    move-exception v1
    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method

.method public static declared-synchronized n()Z
    .locals 2

    const-class v0, Lbp/m1;
    monitor-enter v0

    :try_start_0
    sget-object v1, Lbp/m1;->n:Llr/b;
    invoke-interface {v1}, Llr/b;->b()Z
    move-result v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    monitor-exit v0
    return v1

    :catchall_0
    move-exception v1
    monitor-exit v0
    throw v1
.end method
```

## Notes

Because the VM does not automatically release bytecode-acquired monitors when a frame unwinds on an uncaught exception, the compiler **always generates a synthetic `.catchall` handler around the body of every `synchronized` region** whose sole job is `move-exception vX; monitor-exit vLock; throw vX`. When reading raw smali cold, a `.catchall` handler containing nothing but `move-exception`, `monitor-exit`, and `throw` does **not** come from a source-level `try`/`catch` or `finally` block — it is compiler-synthesized lock-release plumbing and should be collapsed mentally into the enclosing `synchronized (...) { ... }` block. Notice also how in `c()` above, `:try_end_0` is placed *after* the `:catchall_0` handler's own `monitor-exit v0` (making the `.catchall` range cover its own handler): `javac` and `d8` historically emit this self-covering range so that if `monitor-exit` itself were ever to throw an asynchronous exception, the lock release would be retried rather than leaked. When an explicit `try`/`catch` (such as catching `InterruptedException` around `Object.wait(long)`) is nested inside a `synchronized` block, the inner protected range carries both the typed `.catch` directive and the outer monitor's `.catchall` directive — see [[Exercise-07-Wait-Loop-Under-A-Monitor]] for a complete multi-range wait loop dissected step by step.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Methods]] — `declared-synchronized` and `.catchall`
- [[Return-And-Throw]]
- [[Exercise-06-Static-Monitors-And-Iterators]]
- [[Exercise-07-Wait-Loop-Under-A-Monitor]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
