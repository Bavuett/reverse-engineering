---
tags: [reference, reference-entry]
category: "opcode"
created: 2026-09-06
---

# Invoke-Direct, -Static, -Virtual, -Interface, -Super

## Signature / syntax

```
invoke-direct {vC, vD, vE, vF, vG}, Lclass;->method(params)ret
invoke-static {vC, vD, vE, vF, vG}, Lclass;->method(params)ret
invoke-virtual {vC, vD, vE, vF, vG}, Lclass;->method(params)ret
invoke-interface {vC, vD, vE, vF, vG}, Lclass;->method(params)ret
invoke-super {vC, vD, vE, vF, vG}, Lclass;->method(params)ret
```

(each has an `/range` form — `invoke-direct/range {vC .. vN}, ...` — used when a call needs more than
5 argument registers)

## Description

All five encode a method call; they differ only in **how the target method is resolved**, which is
exactly the distinction Java source hides behind a single `.` call syntax:

| Kind | Resolves | Used for |
| --- | --- | --- |
| `invoke-direct` | statically, by exact class | constructors (`<init>`), `private` instance methods — never subject to override |
| `invoke-static` | statically, by exact class | `static` methods — no receiver object at all; the first argument register is a real parameter, not `this` |
| `invoke-virtual` | dynamically, via the receiver's actual runtime class (vtable dispatch) | `public`/`protected` instance methods — the same call site can reach a different override depending on what's actually in `vC` at runtime |
| `invoke-interface` | dynamically, via the receiver's interface implementation table | methods called through an interface-typed reference, where the concrete implementing class isn't statically known at the call site |
| `invoke-super` | statically, to one specific superclass's implementation, bypassing the receiver's own override | `super.method(...)` calls |

For every non-`invoke-static` form, `vC` (the first argument register) is the receiver — `this` — not
a "real" parameter; the method's declared parameter list starts at `vD`.

## Example

```smali
invoke-super {p0, p1}, Lorg/apache/cordova/CordovaActivity;->onCreate(Landroid/os/Bundle;)V
invoke-virtual {p0}, Lnet/pluservice/tua/MainActivity;->getIntent()Landroid/content/Intent;
move-result-object p1
```

(from [[Reading-Raw-Dalvik]]'s worked example 2 — `super.onCreate(savedState)` followed by
`this.getIntent()`, the latter dispatched virtually even though it happens to resolve to `Activity`'s
own implementation here)

## Notes

`invoke-direct`/`invoke-static` being statically resolved is exactly why they're the safe target for
"reimplement the body, leave every call site alone" edits ([[Reading-Raw-Dalvik]]'s patch 4/5): no
vtable lookup depends on what changes inside the method body. `invoke-virtual`/`invoke-interface`
being *dynamically* resolved is what makes hooking frameworks like Frida's `Java.use(...).method
.implementation = ...` work at all for overridable methods — replacing the vtable slot's target is
enough, every existing `invoke-virtual` call site keeps working unmodified. See [[Move-Result]] for how
a non-`void` call's return value is captured immediately afterward, and [[Methods]] for how a Java
method's `private`/`static`/instance-virtual modifiers map onto this same five-way split — including
the easy-to-get-backwards case of `final`, which restricts overriding without moving a method out of
`invoke-virtual` at all (see [[Final-Instance-Methods-Still-Dispatch-Virtually]] for a real instance).

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]]
- [[Move-Result]]
- [[Methods]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
