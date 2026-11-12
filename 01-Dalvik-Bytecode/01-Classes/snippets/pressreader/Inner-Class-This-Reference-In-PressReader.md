---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/com/newspaperdirect/pressreader/android/newspaperview/NewspaperViewNavigationPanel$MyAnimation.smali"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Inner-Class-This-Reference-In-PressReader

> [!info] Level 3 — real code
> A non-static inner class in a release build: the synthetic `this$0` field, the "store before `super()`" order, and the extra marker parameter javac adds to reach a private constructor.

## Context

`NewspaperViewNavigationPanel$MyAnimation` is a tiny inner class whose only job is to expose a `setScrollX(float)` setter for an animator. It survived R8 with its real name because it's annotated `@Keep` — an animator finds `setScrollX` reflectively from the property name `"scrollX"`, so renaming it would break the animation. That makes it a clean, readable specimen of how an inner class is compiled.

## Original path

`smali_classes2/com/newspaperdirect/pressreader/android/newspaperview/NewspaperViewNavigationPanel$MyAnimation.smali`

## Snippet

```smali
.class Lcom/newspaperdirect/pressreader/android/newspaperview/NewspaperViewNavigationPanel$MyAnimation;
.super Ljava/lang/Object;

.annotation build Landroidx/annotation/Keep;
.end annotation
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/newspaperdirect/pressreader/android/newspaperview/NewspaperViewNavigationPanel;
.end annotation
.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = "MyAnimation"
.end annotation

.field final synthetic this$0:Lcom/newspaperdirect/pressreader/android/newspaperview/NewspaperViewNavigationPanel;

.method private constructor <init>(Lcom/newspaperdirect/pressreader/android/newspaperview/NewspaperViewNavigationPanel;)V
    .locals 0
    iput-object p1, p0, L...NewspaperViewNavigationPanel$MyAnimation;->this$0:L...NewspaperViewNavigationPanel;
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public synthetic constructor <init>(L...NewspaperViewNavigationPanel;L...NewspaperViewNavigationPanel$a;)V
    .locals 0
    invoke-direct {p0, p1}, L...NewspaperViewNavigationPanel$MyAnimation;-><init>(L...NewspaperViewNavigationPanel;)V
    return-void
.end method

.method public setScrollX(F)V
    .locals 1
    iget-object v0, p0, L...NewspaperViewNavigationPanel$MyAnimation;->this$0:L...NewspaperViewNavigationPanel;
    invoke-virtual {v0, p1}, Landroid/view/View;->setTranslationX(F)V
    return-void
.end method
```

(`L...` abbreviates `Lcom/newspaperdirect/pressreader/android/newspaperview/`; `.line` directives removed.)

## Reconstructed source

```java
public class NewspaperViewNavigationPanel extends /* some View */ {
    @Keep
    public class MyAnimation {
        private MyAnimation() { }

        public void setScrollX(float x) {
            NewspaperViewNavigationPanel.this.setTranslationX(x);
        }
    }
    // somewhere in the outer class:  new MyAnimation()
}
```

## Notes

- **Compared with the textbook version.** A hand-written inner class from [[Classes]] has the same three ingredients — `EnclosingClass`/`InnerClass` annotations, a `final synthetic this$0` field, and a constructor whose first parameter is the outer instance — so this is the pattern to grep for: `this$0:` finds every non-static inner class whose field R8 didn't rename.
- **Store before `super()`.** `iput-object p1, p0, ...this$0` runs *before* `invoke-direct ... Object;-><init>`. Java source can't do that, but the compiler is allowed to, so that `this$0` is already valid if the superclass constructor calls an overridden method. Seeing a field write before the parent constructor call is a reliable sign of compiler-generated code.
- **The marker parameter.** The outer class calls a `private` constructor, which pre-Java-11 bytecode can't do across classes. `javac` works around this with a second, `synthetic` constructor that takes an extra parameter of an otherwise-empty class (here R8 renamed it `NewspaperViewNavigationPanel$a`) just to get a distinct descriptor; it always receives `null`. Ignore that parameter when reconstructing source.
- **Outer-member access.** `NewspaperViewNavigationPanel.this.setTranslationX(x)` is `iget-object` of `this$0` followed by a call on it. The call is qualified by `Landroid/view/View;`, which tells you the outer class inherits `setTranslationX` from `View`.
- `accessFlags = 0x1` in `InnerClass` is the source-level modifier (`public`); the `.class` line has no `public` because, at bytecode level, an inner class is package-visible.

## See also

- [[Classes]]
- [[Inheritance-And-Super-Calls]] — the `.super` kind of parent
- [[Annotations]] — `EnclosingClass`, `InnerClass`, `Signature`
- [[Reflection-and-Runtime-Internals]] — why `@Keep` matters for members only reached reflectively
- [[PressReader]]
- [[Dalvik-Bytecode-Reference|Reference]]
