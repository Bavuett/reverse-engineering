---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/com/newspaperdirect/pressreader/android/newspaperview/a.smali"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# R8-Merged-Lambdas-Packed-Switch-In-PressReader

> [!info] Level 3 — real code
> A `packed-switch` that isn't in any source file: R8 merged several unrelated lambdas into one class and selects the right body with an `int` field.

## Context

Searching PressReader for `packed-switch` turns up many small `synthetic` classes in `newspaperview/` (`a`, `b`, `a0`, `d0`, …) that all start their methods with `iget v?, p0, ...->b:I` followed by `packed-switch`. They aren't hand-written state machines. They're the result of R8's **class merging** for lambdas: instead of one tiny class per lambda, R8 puts many lambdas into a single class, stores a *lambda id* in a field, and switches on it.

## Original path

`smali_classes2/com/newspaperdirect/pressreader/android/newspaperview/a.smali`

## Snippet

```smali
.class public final synthetic Lcom/newspaperdirect/pressreader/android/newspaperview/a;
.super Ljava/lang/Object;
.implements Lq00/j;
.implements Lnx/a$a;
.implements Lcom/newspaperdirect/pressreader/android/view/PagesView$a;
.implements Lra/h;

.field public final synthetic b:I                    # which lambda
.field public final synthetic c:Ljava/lang/Object;   # first captured value
.field public final synthetic d:Ljava/lang/Object;   # second captured value

.method public synthetic constructor <init>(ILjava/lang/Object;Ljava/lang/Object;)V
    .locals 0
    iput p1, p0, L...a;->b:I
    iput-object p2, p0, L...a;->c:Ljava/lang/Object;
    iput-object p3, p0, L...a;->d:Ljava/lang/Object;
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public h(I)V
    .locals 2
    iget p1, p0, L...a;->b:I
    packed-switch p1, :pswitch_data_0

    # default (b == 0): lambda #0 — captured (PublicationsListToolbar, NewspaperFilter)
    iget-object p1, p0, L...a;->c:Ljava/lang/Object;
    check-cast p1, L...publications/view/PublicationsListToolbar;
    # ... dismiss popup, filter.g(NewspaperFilter$d.Date), toolbar.q(filter), notify listener
    return-void

    :pswitch_0
    # case 1: lambda #1 — captured (iu.m0, po.a)
    iget-object p1, p0, L...a;->c:Ljava/lang/Object;
    check-cast p1, Liu/m0;
    invoke-virtual {p1}, Llx/z;->dismiss()V
    iget-object p1, p1, Liu/m0;->h:Lb2/a0;
    iget-object v0, p0, L...a;->d:Ljava/lang/Object;
    check-cast v0, Lpo/a;
    invoke-virtual {p1, v0}, Lb2/a0;->w(Lpo/a;)V
    return-void

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_0
    .end packed-switch
.end method
```

(`L...` abbreviates `Lcom/newspaperdirect/pressreader/android/`; the default branch is condensed, the class's other three interface methods omitted.)

## Reconstructed source

Two lambdas in two unrelated places, both implementing the same single-method interface whose method R8 renamed `h(int)`:

```kotlin
// in PublicationsListToolbar
val onPick = Listener { _ ->
    popup?.dismiss()
    filter.g(NewspaperFilter.d.Date)          // e.g. "sort by date"
    toolbar.q(filter)
    detailsListener?.a(filter)
}

// in iu.m0 (some dialog)
val onPick = Listener { _ ->
    dialog.dismiss()
    dialog.h.w(item)
}
```

## Notes

- **Compared with a source `switch`.** In [[Packed-Switch-Multi-Way-Branch]] the switched value comes from a parameter or a computation. Here it comes from `iget … ->b:I` of the object's own final field, set once in the constructor — that's the giveaway that the "switch" is R8 dispatch, not program logic. Treat each case as a separate function.
- **Reading the table.** `.packed-switch 0x1` with one label means "value 1 → `:pswitch_0`"; any other value falls through to the code right after the `packed-switch` instruction, which is therefore the handler for `0`. The fall-through block being a real case (not an error path) is typical of these merged classes.
- **The interface argument is ignored.** `iget p1, p0, …->b:I` overwrites the `int` parameter `p1` immediately: neither lambda used its argument, so the compiler recycled the register. That's why the reconstruction writes `_ ->`.
- **Captured variables become `Object` fields.** Different lambdas capture different types, so the merged class stores them as `c:Ljava/lang/Object;` and `d:Ljava/lang/Object;` and each case `check-cast`s to what *it* needs. The casts are the only type information about captures that survives.
- **Four interfaces, one class.** The `.implements` list (`q00/j`, `nx/a$a`, `PagesView$a`, `ra/h`) is the union of every merged lambda's interface. To find who creates lambda #1, search for `new-instance …newspaperview/a;` followed by `const/4 v?, 0x1` passed as the first constructor argument — the callers of `<init>` with each id are the lambdas' original locations.
- **Frida consequence.** Hooking `newspaperview.a.h` fires for *all* merged lambdas; filter on `this.b.value` inside the hook to isolate one.

## See also

- [[Dalvik-Instructions]]
- [[Packed-Switch-And-Sparse-Switch]]
- [[Exercise-10-Synthetic-Lambda-And-Rx-Single]] — an unmerged D8 lambda class from the same app, for comparison
- [[Classes]] — `synthetic` classes and fields
- [[PressReader]]
- [[Dalvik-Bytecode-Reference|Reference]]
