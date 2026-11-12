---
tags: [example]
level: 1
aliases: ["getDeclaredField smali"]
created: 2026-11-12
---

# Example: Reading-A-Private-Field-Reflectively

> [!info] Level 1 — basics
> One idea: a direct field read is one `iget` naming the field; a reflective read is four calls where the field's name is only a string.

## Goal

Put a direct `iget` and its reflective equivalent next to each other, so the reflective version is recognizable at a glance and its static "invisibility" is understood. Belongs to [[Reflection-and-Runtime-Internals]].

## Java source

```java
import java.lang.reflect.Field;

public class Peek {
    static String direct(Account a) {
        return a.owner;                           // package-private field: direct access allowed
    }

    static String reflective(Account a) throws Exception {
        Field f = Account.class.getDeclaredField("secret");   // private field
        f.setAccessible(true);
        return (String) f.get(a);
    }
}
```

## Generated smali

```smali
.method static direct(LAccount;)Ljava/lang/String;
    .locals 0
    iget-object p0, p0, LAccount;->owner:Ljava/lang/String;
    return-object p0
.end method

.method static reflective(LAccount;)Ljava/lang/String;
    .locals 2
    const-class v0, LAccount;
    const-string v1, "secret"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V
    invoke-virtual {v0, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object p0
    check-cast p0, Ljava/lang/String;
    return-object p0
.end method
```

## Step by step

1. **Direct access** names the field in the instruction: `LAccount;->owner:Ljava/lang/String;`. Searching the app for `->owner:` finds every reader and writer.
2. **Reflective access** names the field only in `const-string v1, "secret"`. Searching for `->secret:` finds nothing — not even the field's own reads in `Account` will lead you here. You have to search for the *string* `"secret"` or for calls to `getDeclaredField`.
3. **The four-step recipe**: `getDeclaredField(name)` → `setAccessible(true)` → `get(obj)` / `set(obj, value)` → `check-cast` the result. `setAccessible(true)` is what lets code outside `Account` read a `private` field; its presence is the strongest hint that the target is private.
4. **`setAccessible` is declared on `AccessibleObject`**, so the call is qualified `Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V`, not `Field->setAccessible`. Search for the superclass name.
5. **Primitives have typed getters**: `getInt`, `getLong`, `getBoolean`, … and setters `setInt`, …; the generic `get`/`set` box and unbox (see [[Autoboxing-In-Smali]]).
6. **`getDeclaredField` vs `getField`**: `getDeclared*` sees all fields declared by that exact class, including private ones, but not inherited ones; `getField` sees only public fields, including inherited ones. Code reaching for private internals always uses the `Declared` variant.
7. **Exceptions.** `reflective` must declare `throws Exception` (`NoSuchFieldException`, `IllegalAccessException`). Real code nearly always wraps the recipe in a `try`/`catch` because the field may not exist on every Android version — look for a `.catch` around it.

## Compared with real code

- [[Private-Field-Access-Via-Reflection-In-PressReader]] — PressReader applies exactly this recipe to *Android framework* private fields (`mPopup`, `mAnchorPosition`), inside the `try`/`catch` from step 7.
- [[Reflection-Hidden-Check-With-Decoded-Names]] — the same idea for methods, with the name string decrypted at runtime.

## See also

- [[Reflection-and-Runtime-Internals]]
- [[Class-Literal-Vs-Class-ForName]]
- [[Iget-And-Iput]]
- [[Hunting-Reflection-With-Grep-And-Set-Difference]]

## References

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
