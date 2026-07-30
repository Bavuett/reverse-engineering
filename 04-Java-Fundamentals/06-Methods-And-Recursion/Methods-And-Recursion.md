---
tags: [fundamentals]
aliases: ["Methods", "Method Call", "this", "Recursion", "Call Stack"]
created: 2026-07-30
---

# Methods And Recursion

## In short

A **method** is an action an object can perform, declared once with the class and *invoked* many times. A declaration `public void m(T x) B` records a formal parameter `x` and a body block `B` in the class's method environment ρm. A **call** `o.m(E)` runs `B` in a **brand-new frame** containing only two bindings: the formal parameter bound to the actual argument, and the special name **`this`** bound to the receiver's reference. `this` is what lets the body reach the object's own instance variables. **Recursion** needs nothing new: each recursive call just pushes another such frame, and `this` in every frame points back at the same original object.

## Explanation

### Declaration vs. invocation

- **Declaration** happens once, with the class; it fixes *what the method does*. `ρm : Ide → (Ide × Block)` maps each method name to its `(formal parameter, body)`.
- **Invocation** (`o.m(E)`) happens at runtime; it *runs* that body with a specific receiver and argument. Different calls differ because (a) the receiver's instance-variable values differ, and (b) the actual parameter differs.

### The call rule

```
  ζ(σ(o)) = (c,ϕ′)   ρc(c) = (ϕ,ρm)   ρm(m) = (x,B)
  ⟨E,⟨ρc,σ,ζ⟩⟩ → v    σ′ = ω[v/x, σ(o)/this].Ω    ⟨B,⟨ρc,σ′,ζ⟩⟩ → ⟨σ″,ζ′⟩
  ─────────────────────────────────────────────────────────────────────────
              ⟨o.m(E), ⟨ρc,σ,ζ⟩⟩ → ⟨σ, ζ′⟩
```

Read it as three steps: (i) find `o`'s object and look up `m`'s `(x, B)` in the class environment; (ii) evaluate the argument `E` to `v`; (iii) run `B` in a **fresh single-frame stack** `{x ↦ v, this ↦ σ(o)}.Ω`. Note the conclusion returns the **original σ** with only the **heap** `ζ′` changed — a method can't touch the caller's locals, only instance variables of objects (via the heap). That's a deliberate simplification, and it's exactly why the call frame contains *nothing but* the parameter and `this`.

### `this` makes instance access work

Inside a body, every bare instance-variable reference `x` is understood as `this.x`. So `x = x + y;` in a method is really `this.x = this.x + y;`, which resolves through the heap (rule from [[Classes-And-Objects]]) using the `this` binding in the call frame. Without `this` in the frame, the body could see its parameter but not the object's own fields.

### Recursion is just more frames

For a recursive call `this.inc(y-1)`, the same call rule fires again, pushing **another** fresh frame `{y ↦ y-1, this ↦ σ(this)}.Ω`. Key point: `this` in the new frame equals `this` in the current one — so **every** activation, however deep, points at the *same original object*. The heap effects accumulate; when the base case returns, the completed heap propagates back up through each pending frame (effects "ripple back" from the innermost call outward — visible when a method does work *after* its recursive call).

### Worked example

```
class RecIncr { public int x;
  public void inc(int y){ if (y<=1) this.x = this.x+1;
                          else { this.x = this.x+1; this.inc(y-1); } } }
```

`obj.inc(3)` with `obj.x = 10` pushes frames for `y=3, 2, 1`, each `this = σ(obj)`; the body adds 1 to the same heap object three times → `obj.x = 13`. A method that instead did work *after* the recursive call (`… this.inc(y-1); this.x = 2*this.x;`) would show the doubling apply from the innermost frame outward.

> [!tip] Connection to Dalvik
> The call rule is the shape of `invoke-*` + a new activation frame:
> - **Invocation opcode.** `o.m(E)` compiles to `invoke-virtual {vObj, vArg}, LC;->m(T)V` (or `-direct`/`-static`/`-interface`/`-super` per dispatch kind — see [[Methods]] in [[Dalvik-Bytecode]]). A return value is grabbed with `move-result*`.
> - **`this` = `p0`.** In an instance method's frame, the receiver is the first parameter register `p0`; declared parameters follow in `p1, p2, …`. So "the `this` binding in the call frame" is literally register `p0`, and `this.x` is `iget/iput … p0, …`. That single fact — `p0` is `this` for non-static methods — is one of the most useful things to know when reading smali.
> - **Recursion = a stack of activation frames**, each `invoke` pushing a new register set; `p0` carries the same object reference down every level, exactly as `this` does here.
> - **The method environment ρm** is the class's method table in the dex; resolving `m` at a call site is method resolution, which reflection (see [[Reflection-and-Runtime-Internals]]) does dynamically via a name string instead.

## More examples

- [[A-Method-Call-Frame]] — the `this`/parameter call frame drawn out and mapped to `p0`/`p1`.

## See also

- [[Classes-And-Objects]] — the heap objects a method mutates through `this`.
- [[Declarations-And-Scope]] — the frame-stack this call stack extends.
- [[Memory-Model]] — the call stack as a memory region.
- [[Methods]] and [[Reflection-and-Runtime-Internals]] in [[Dalvik-Bytecode]] — `invoke-*`, `p0` as `this`, and dynamic method resolution.

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]

## Flashcards
#flashcards

What two bindings does a method call's fresh frame contain, and why exactly those?::The formal parameter bound to the actual argument value, and `this` bound to the receiver's reference — the parameter so the body can use its argument, and `this` so the body can reach the receiver's own instance variables.
Why does `this` have to be in the call frame for `x = x + y;` inside a method to work?::Because a bare instance-variable reference `x` means `this.x`, which is resolved through the heap using the `this` binding; without it the body could see the parameter but not the object's fields.
In a recursive call, what does `this` point to at every level of the recursion?::The same original receiver object — each recursive frame binds `this` to the previous frame's `this`, so however deep the recursion, all activations act on one object.
What is `this` in Dalvik terms for a non-static method?::Register `p0` — the receiver is the first parameter register, declared parameters follow in `p1, p2, …`, and `this.x` is an `iget`/`iput` through `p0`.
