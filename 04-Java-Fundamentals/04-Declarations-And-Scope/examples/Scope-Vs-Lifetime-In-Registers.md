---
tags: [example]
level: 2
aliases: ["scope vs lifetime", "register allocation and scope", "variable reuse in smali"]
created: 2026-11-12
---

# Example: Scope-Vs-Lifetime-In-Registers

> [!info] Level 2 — intermediate
> Combines the frame-stack model with register allocation: *scope* is where a name can be used (a source notion, modelled by frames), *lifetime* is when a storage location holds a needed value (a machine notion) — and compiled code shows only the second.

## Goal

Follow two sibling blocks whose locals share one register, and learn to read a register as "storage that different variables pass through". Belongs to [[Declarations-And-Scope]].

## Program

```java
int total = 0;
{ int a = x * 2; total = total + a; }
{ int b = y + 1; total = total + b; }
return total;
```

## Frames vs registers

```
Semantics (frames)                                  Dalvik (registers)
{total↦0} · Ω                                       v0 = total
{a↦2x} · {total↦0} · Ω          ← block 1           v1 = a
{total↦2x} · Ω                  ← a popped          v1 dead
{b↦y+1} · {total↦2x} · Ω        ← block 2           v1 = b   (same register reused)
{total↦2x+y+1} · Ω              ← b popped          v1 dead
```

## Compiled

```smali
# x in p1, y in p2
const/4 v0, 0x0               # total = 0
mul-int/lit8 v1, p1, 0x2      # a = x * 2
add-int/2addr v0, v1          # total += a        (last use of a: v1 becomes free)
add-int/lit8 v1, p2, 0x1      # b = y + 1         (v1 reused for a different variable)
add-int/2addr v0, v1          # total += b
return v0
```

## Step by step

1. **Scope is static.** `a` can be named only inside block 1; outside it, `σ(a) = ⊥` and the program wouldn't compile. The frame model captures this: block 1's frame is popped before block 2's is pushed.
2. **Lifetime is dynamic and shorter.** `a`'s value is needed only until its last use, `total + a`. After that its register can hold anything.
3. **Register allocators exploit disjoint lifetimes.** `a` and `b` are never needed at the same time, so both live in `v1`. In release builds even variables from the *same* scope share registers when their lifetimes don't overlap.
4. **Reading smali: track values, not register names.** "v1" means `a` before line 3 and `b` after it. Naming a register by one variable for the whole method is the most common misreading of optimized bytecode.
5. **Debug info restores scope.** With `.local`/`.end local` directives (debug builds), smali shows each variable's name and range explicitly; R8 release builds usually strip them ([[Same-Method-Debug-Vs-R8-Release]]).

## Compared with real code

- [[Branch-Assigned-Locals-In-PressReader-HttpUrl-Builder]] — real register reuse: one register holds a field value, then an iterator, then another field.
- [[Counting-Locals-And-Parameters]] in [[Dalvik-Bytecode]] — how `.locals` counts registers, not variables.

## See also

- [[Declarations-And-Scope]]
- [[Nested-Blocks-And-Shadowing]]
- [[Registers]] in [[Dalvik-Bytecode]]

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]
