---
tags: [reference]
aliases: ["Java Fundamentals Glossary"]
---

# Java-Fundamentals · Glossary

Terminology used across this topic, in alphabetical order.

| Term | Meaning |
|---|---|
| Actual parameter | The value/expression supplied at a method **call** site (`obj.inc(8)` → `8`), bound to the formal parameter when the body runs. See [[Methods-And-Recursion]], [[Object-And-Method-Semantics-Rules]]. |
| Big-step (natural) semantics | A semantics whose transition relates a construct directly to its final result, hiding intermediate steps (`⟨E,σ⟩ → v`), as opposed to small-step/evaluation semantics. See [[Operational-Semantics]], [[Inference-Rule-Notation]]. |
| Blocked configuration | A non-terminal configuration with no applicable transition — models a runtime error (`5 - 8` over naturals, `x / 0`) or, indistinguishably here, non-termination. See [[Commands-And-Control-Flow]], [[Evaluating-Expressions-In-A-State]]. |
| Class environment (ρc / Δ) | The table mapping each class name to its instance-variable frame and method environment — the semantic "library" of loaded classes. See [[Classes-And-Objects]], [[Memory-Model]], [[Object-And-Method-Semantics-Rules]]. |
| Configuration | An element of a transition system's state set Γ; a stage the computation can be in. Terminal configurations (T) are final results. See [[Operational-Semantics]], [[Inference-Rule-Notation]]. |
| Conditional rule | An inference rule `premises / conclusion` defining a transition only when its premises hold; premises may themselves be transitions (recursive rules). See [[Operational-Semantics]], [[Inference-Rule-Notation]]. |
| Derivation | A (possibly infinite) sequence of configurations linked by transitions; a big-step derivation is presented as a justification tree. See [[Operational-Semantics]], [[Inference-Rule-Notation]], [[Deriving-An-Arithmetic-Expression]]. |
| Formal parameter | The name a method declaration gives its parameter (`inc(int y)` → `y`); bound to the actual parameter on each call. See [[Methods-And-Recursion]], [[Object-And-Method-Semantics-Rules]]. |
| Frame (ϕ / ρ) | A finite partial function from identifiers to values — one table of name→value bindings. A single scope's worth of state. See [[State-And-Expressions]], [[Declarations-And-Scope]], [[State-And-Environment-Substitution]]. |
| Heap (ζ / θ) | A finite function from locations to object representations `(class, frame)`; where every `new`-allocated object lives. See [[Classes-And-Objects]], [[Memory-Model]], [[State-And-Environment-Substitution]], [[Object-And-Method-Semantics-Rules]]. |
| Location / reference (Loc) | An element of the abstract address set the heap is keyed by; the value a variable of object type actually holds (an arrow to a heap object), distinct from the object itself. `null` is the empty reference. See [[Classes-And-Objects]], [[Object-And-Method-Semantics-Rules]]. |
| Method environment (ρm) | A class's table mapping each method name to its `(formal parameter, body block)` pair. See [[Methods-And-Recursion]], [[Object-And-Method-Semantics-Rules]]. |
| Short-circuit evaluation | Evaluating boolean `&&` and `||` so that the right operand is skipped whenever the left operand determines the result (`ff` for `&&`, `tt` for `||`), preventing side conditions in the right operand from blocking evaluation. See [[State-And-Expressions]], [[Expression-Semantics-Rules]], [[Evaluating-Expressions-In-A-State]]. |
| State | What an expression/command is evaluated against. Flat (one frame) early on; later a **stack of frames** σ, and finally a triple `⟨ρc, σ, ζ⟩` / $(\Delta, \sigma, \theta)$ (class env, stack, heap). See [[State-And-Expressions]], [[Memory-Model]], [[State-And-Environment-Substitution]]. |
| State modification (σ[v/x] / σ[x ↦ v]) | The state identical to σ except that the most-recent binding for `x` now maps to `v`; the semantic effect of assignment. See [[Commands-And-Control-Flow]], [[Command-Semantics-Rules]], [[State-And-Environment-Substitution]]. |
| Substitution / instantiation | Replacing a rule's variables with concrete values to get an instance whose premises can be checked; how a rule schema applies to a specific configuration. See [[Operational-Semantics]], [[Inference-Rule-Notation]]. |
| `this` | The implicit binding, in a method body's frame, to the reference of the receiver object; makes `this.x` resolve the receiver's own instance variable. See [[Methods-And-Recursion]], [[A-Method-Call-Frame]], [[Object-And-Method-Semantics-Rules]]. |
| Transition system | A triple ⟨Γ, T, →⟩: configurations, terminal configurations, and a transition relation. The formal object an operational semantics is. See [[Operational-Semantics]], [[Inference-Rule-Notation]]. |

## See also

- [[Java-Fundamentals-Reference|Reference]]
- [[Inference-Rule-Notation]]
- [[State-And-Environment-Substitution]]
- [[Expression-Semantics-Rules]]
- [[Command-Semantics-Rules]]
- [[Object-And-Method-Semantics-Rules]]
