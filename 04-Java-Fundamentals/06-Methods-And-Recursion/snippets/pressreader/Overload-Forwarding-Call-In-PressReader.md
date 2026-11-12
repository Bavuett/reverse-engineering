---
tags: [snippet]
level: 3
project: "PressReader"
source: com.newspaperdirect.pressreader.android
version: "unknown"
source_path: "smali_classes2/bp/m1.smali, method l(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;)V (decompiled: Case-Studies/pressreader/source/java/bp/m1.java)"
date_added: 2026-11-12
license_note: "Personal study/research purposes only. Check the project's license and ToS before sharing publicly."
---

# Overload-Forwarding-Call-In-PressReader

> [!info] Level 3 — real code
> The smallest real call frame chain: PressReader's `m1.l(service, str)` forwards to `m1.m(service, str, 30000, 30000)` — a default-argument overload — so one `invoke-virtual` line shows formal-to-actual binding, the receiver as `p0`, and one register passed twice.

## Context

`bp.m1` sends PressReader's XML requests ([[Discovering-The-Core-XML-Protocol]]). `m(...)` does the work (it was too large for jadx to decompile, see [[Hooking-The-Core-XML-API-Methods-Directly]]); `l(...)` is the convenience entry point with default timeouts. The PressReader Frida agent hooks `m` with exactly these four parameters ([[Compiling-TypeScript-Agents-With-Frida-Compile]] in [[Frida-Dynamic-Instrumentation]]). Part of [[PressReader]].

## Original path

`smali_classes2/bp/m1.smali` → `.method public final l(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;)V`

## Snippet

```smali
.method public final l(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;)V
    .locals 1
    const/16 v0, 0x7530                                    # 30000
    invoke-virtual {p0, p1, p2, v0, v0}, Lbp/m1;->m(Lcom/newspaperdirect/pressreader/android/core/Service;Ljava/lang/String;II)V
    return-void
.end method
```

## Reconstructed source

```java
public final void l(Service service, String str) {
    m(service, str, 30000, 30000);          // connectTimeout, readTimeout in ms
}
// Kotlin original was likely one method with default arguments:
// fun m(service: Service, str: String, connectTimeout: Int = 30000, readTimeout: Int = 30000)
```

## Frames

```
caller of l:     … holds ℓ_m1 (an m1), ℓ_svc (a Service), "req-type"
l(service, str): ρ_l = {this ↦ ℓ_m1, service ↦ ℓ_svc, str ↦ "req-type"}       p0, p1, p2
  evaluate actuals of m:  this → ℓ_m1,  service → ℓ_svc,  str → "req-type",  30000,  30000
m(...):          ρ_m = {this ↦ ℓ_m1, service ↦ ℓ_svc, str ↦ "req-type",
                        connectTimeout ↦ 30000, readTimeout ↦ 30000}           p0 … p4
  (body of m runs; its heap effects persist)
return to l:     ρ_m discarded;  l returns; ρ_l discarded
```

## Notes

- **Actuals are values.** `m` receives the *values* of `l`'s parameters — the same locations `ℓ_m1`, `ℓ_svc` — so both frames alias the same objects, but `m` can't rebind `l`'s variables ([[Pass-By-Value-Of-References]]).
- **Receiver first.** `invoke-virtual {p0, …}` passes `l`'s `this` as `m`'s `this`: register list position 0 → callee's `p0`. The other arguments follow in declaration order ([[A-Method-Call-Frame]]).
- **One register, two parameters.** `v0` appears twice in the argument list: the value 30000 is copied into two separate formals. Evaluating a constant once and reusing it is equivalent to writing it twice ([[Semantic-Equivalence-Of-Two-Fragments]]).
- **Dispatch on `m`.** `invoke-virtual` would dispatch on the runtime class, but `m1` is `final` (no subclasses), so the target is always `m1.m` — R8 keeps `invoke-virtual` here because it changes nothing ([[Dynamic-Dispatch-Through-Overriding]]).
- **Why it matters for hooking.** Hooking `l` misses calls that go to `m` directly with other timeouts; hooking `m` sees all of them — the forwarding structure decides where to place a Frida hook ([[Java-Layer-Hooking]]).

## See also

- [[Methods-And-Recursion]]
- [[Overloading-And-Bridge-Methods]] in [[Dalvik-Bytecode]]
- [[Java-Fundamentals-Reference|Reference]]
