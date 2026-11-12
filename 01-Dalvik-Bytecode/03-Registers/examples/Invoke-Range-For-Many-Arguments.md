---
tags: [example]
level: 2
aliases: ["invoke range smali", "/range invoke"]
created: 2026-11-12
---

# Example: Invoke-Range-For-Many-Arguments

> [!info] Level 2 — intermediate
> When a call needs more than five argument registers, the compiler switches to `/range` and shuffles values into a consecutive block first.

## Goal

Explain the `invoke-*/range {vA .. vB}` form, why it forces the `move-object`/`move-wide` shuffles right before it, and how to read the argument list off a range. Belongs to [[Registers]].

## Java source

```java
public class Device {
    public Device(String id, String name, String model, long created, long lastSeen) { /* ... */ }

    static Device build(String id, String name, String model, long created, long lastSeen) {
        return new Device(id, name, model, created, lastSeen);
    }
}
```

## Generated smali

```smali
.method static build(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;JJ)LDevice;
    .locals 9
    # p0=id  p1=name  p2=model  p3/p4=created  p5/p6=lastSeen
    new-instance v0, LDevice;
    move-object v1, v0
    move-object v2, p0
    move-object v3, p1
    move-object v4, p2
    move-wide v5, p3
    move-wide v7, p5
    invoke-direct/range {v1 .. v8}, LDevice;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;JJ)V
    return-object v0
.end method
```

## Step by step

1. **Count the argument registers**: receiver (1) + three `String`s (3) + two `long`s (2 × 2) = **8**. The non-range `invoke-*` encoding has room for at most 5 registers, so `/range` is mandatory.
2. **A range names only its ends.** `{v1 .. v8}` means `v1, v2, …, v8` in order. Map them against the descriptor exactly like parameters: `v1` = receiver, `v2`–`v4` = the strings, `v5`/`v6` = `created`, `v7`/`v8` = `lastSeen`.
3. **The shuffle.** The values already exist in `p0`–`p6`, but not in a block that starts with the new object, so the compiler copies them into `v1`–`v8`. A run of `move-object`/`move-wide` immediately before a `/range` call is just this marshalling — skip it mentally and read the call as `new Device(p0, p1, p2, p3, p5)`.
4. **Why keep `v0` separate?** `<init>` returns `void`, so the new object must survive the call in a register that isn't consumed by it; `v0` holds it for `return-object v0` while `v1` is its copy heading the range.
5. **`.locals 9` looks huge** for a one-line method — that's the price of the consecutive block. A method with a suspiciously high `.locals` and few real locals is usually building `/range` calls.

## Compared with real code

PressReader's Kotlin `Parcelable.Creator` for `AccountDevice` makes exactly this call when it deserializes a device — three `readString()` and two `readLong()` results, each produced straight into its slot in the range, so only the receiver needs a `move-object`:

```smali
new-instance v0, Lcom/newspaperdirect/pressreader/android/devicemanagement/model/AccountDevice;
invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;
move-result-object v2
invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;
move-result-object v3
invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;
move-result-object v4
invoke-virtual {p1}, Landroid/os/Parcel;->readLong()J
move-result-wide v5
invoke-virtual {p1}, Landroid/os/Parcel;->readLong()J
move-result-wide v7
move-object v1, v0
invoke-direct/range {v1 .. v8}, Lcom/newspaperdirect/pressreader/android/devicemanagement/model/AccountDevice;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;JJ)V
return-object v0
```

The register allocator was smarter than the hand-written version above: it planned the range in advance and had every `move-result` land directly in place. Full context in [[Parcelable-Creator-Erased-Generics]].

## See also

- [[Registers]]
- [[Wide-Registers-For-Long-And-Double]]
- [[Invoke-Direct-Static-Virtual-Interface]]
- [[Exercise-08-Server-Mode-Map-Constructor]] — `filled-new-array` has the same 5-register limit and its own `/range` form

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
