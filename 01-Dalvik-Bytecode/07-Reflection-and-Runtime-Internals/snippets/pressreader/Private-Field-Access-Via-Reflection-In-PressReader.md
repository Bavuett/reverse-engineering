---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/com/newspaperdirect/pressreader/android/search/SearchView.smali; smali_classes2/com/newspaperdirect/pressreader/android/view/RecyclerViewPager.smali"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Private-Field-Access-Via-Reflection-In-PressReader

> [!info] Level 3 — real code
> Two real call sites where an app reaches into private fields of Android framework classes: a two-hop `get` chain through `mPopup`, and a read-modify-write of `mAnchorPosition` through `getInt`/`set`.

## Context

Not all reflection is hiding something. Apps routinely use it to work around framework limitations — here, to tweak a popup that `AutoCompleteTextView` doesn't expose, and to restore a `RecyclerView` scroll position whose state class is private. These are the benign baseline against which suspicious reflection (decrypted names, `Method.invoke` on security checks) stands out.

## Original path

- `smali_classes2/com/newspaperdirect/pressreader/android/search/SearchView.smali`, method `c()V`
- `smali_classes2/com/newspaperdirect/pressreader/android/view/RecyclerViewPager.smali`, method `onRestoreInstanceState(Landroid/os/Parcelable;)V`

## Snippet 1 — a chain of private fields (`SearchView.c`)

```smali
const-string v0, "mPopup"                      # declared at the top of the method
# ...
:try_start_0
const-class v1, Landroid/widget/AutoCompleteTextView;
invoke-virtual {v1, v0}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
move-result-object v1
const/4 v2, 0x1
invoke-virtual {v1, v2}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V
iget-object v3, p0, L…/search/SearchView;->f:L…/search/SearchAutoComplete;
invoke-virtual {v1, v3}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
move-result-object v1
check-cast v1, Landroid/widget/ListPopupWindow;           # hop 1: AutoCompleteTextView.mPopup

const-class v3, Landroid/widget/ListPopupWindow;
invoke-virtual {v3, v0}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
move-result-object v0
invoke-virtual {v0, v2}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V
invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
move-result-object v0
check-cast v0, Landroid/widget/PopupWindow;               # hop 2: ListPopupWindow.mPopup
invoke-static {v0}, Llx/z;->d(Landroid/widget/PopupWindow;)V
:try_end_0
.catchall {:try_start_0 .. :try_end_0} :catchall_0
goto :goto_0
:catchall_0
move-exception v0
invoke-static {v0}, Lj70/a;->a(Ljava/lang/Throwable;)V
:goto_0
```

## Snippet 2 — read-modify-write of a private `int` (`RecyclerViewPager.onRestoreInstanceState`)

```smali
:try_start_0
invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
move-result-object v0
const-string v1, "mLayoutState"
invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
move-result-object v0
const/4 v1, 0x1
invoke-virtual {v0, v1}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V
invoke-virtual {v0, p1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
move-result-object v0                                     # state.mLayoutState
invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
move-result-object v2
const-string v3, "mAnchorOffset"
invoke-virtual {v2, v3}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
move-result-object v2
invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
move-result-object v3
const-string v4, "mAnchorPosition"
invoke-virtual {v3, v4}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
move-result-object v3
invoke-virtual {v3, v1}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V
invoke-virtual {v2, v1}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V
invoke-virtual {v2, v0}, Ljava/lang/reflect/Field;->getInt(Ljava/lang/Object;)I
move-result v4
if-lez v4, :cond_0                                         # if (anchorOffset > 0)
invoke-virtual {v3, v0}, Ljava/lang/reflect/Field;->getInt(Ljava/lang/Object;)I
move-result v4
sub-int/2addr v4, v1                                       #   anchorPosition - 1
invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
move-result-object v1
invoke-virtual {v3, v0, v1}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V
# ... else-branch handles anchorOffset < 0 the same way
```

(`L…/` abbreviates `Lcom/newspaperdirect/pressreader/android/`; `.line` directives removed.)

## Reconstructed source

```java
// SearchView.c()
try {
    Field f1 = AutoCompleteTextView.class.getDeclaredField("mPopup");
    f1.setAccessible(true);
    ListPopupWindow lpw = (ListPopupWindow) f1.get(this.f /* SearchAutoComplete */);
    Field f2 = ListPopupWindow.class.getDeclaredField("mPopup");
    f2.setAccessible(true);
    PopupWindow pw = (PopupWindow) f2.get(lpw);
    lx.z.d(pw);                                    // adjust the real PopupWindow
} catch (Throwable t) {
    j70.a.a(t);
}

// RecyclerViewPager.onRestoreInstanceState(Parcelable state)
try {
    Object layoutState = field(state, "mLayoutState").get(state);
    Field offset = field(layoutState, "mAnchorOffset");
    Field position = field(layoutState, "mAnchorPosition");
    if (offset.getInt(layoutState) > 0) {
        position.set(layoutState, position.getInt(layoutState) - 1);
    } /* else if (offset < 0) { ... } */
} catch (Throwable t) { /* ... */ }
```

## Notes

- **Compared with the basic recipe.** Both sites are [[Reading-A-Private-Field-Reflectively]]'s four steps, unchanged. What differs is what a real app adds around them: a `.catchall` with a crash reporter (`j70.a.a` is the same reporter used by [[Reading-A-Native-Facade-Class-Cold]]), because framework internals change between Android versions.
- **One string, two fields.** In snippet 1 the single `const-string v0, "mPopup"` at the top of the method serves both hops — two *different* fields in two classes that happen to share a name. Track the `Class` object each `getDeclaredField` is called on, not just the string.
- **`const-class` vs `getClass()`.** Snippet 1 names its classes with `const-class` (statically visible); snippet 2 uses `getClass()` on runtime objects, so the target class (`LinearLayoutManager$SavedState`, judging from the field names) isn't named anywhere. See [[Class-Literal-Vs-Class-ForName]].
- **Plain-text names are the benign tell.** Every field name here is a readable literal matching real AOSP field names. Compare [[Reflection-Hidden-Check-With-Decoded-Names]], where the names are produced by a decoder — the same API calls, opposite intent.
- **`getInt` + boxed `set`.** Reading uses the typed `getInt`, writing uses the generic `set(Object, Object)` with `Integer.valueOf` — inconsistent but legal; [[Autoboxing-In-Smali]] covers the boxing.
- **Dynamic check.** Hooking `java.lang.Class.getDeclaredField` with Frida and logging the name plus the receiver class lists every field touched this way at runtime, including ones whose names *are* computed.

## See also

- [[Reflection-and-Runtime-Internals]]
- [[Hunting-Reflection-With-Grep-And-Set-Difference]] — how sites like these are found in bulk
- [[Java-Layer-Hooking]] in [[Frida-Dynamic-Instrumentation]]
- [[PressReader]]
- [[Dalvik-Bytecode-Reference|Reference]]
