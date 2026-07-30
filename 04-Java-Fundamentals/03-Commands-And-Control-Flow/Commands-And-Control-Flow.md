---
tags: [fundamentals]
aliases: ["Commands", "Assignment", "Control Flow", "State Modification"]
created: 2026-07-30
---

# Commands And Control Flow

## In short

Where expressions *read* the state, **commands** change it — the meaning of a command is a **state transition** `⟨C, σ⟩ → σ′`. The single command that actually modifies state is **assignment**; everything else (blocks, `if`/`else`, `while`) exists to control *when and which* assignments run. The key notation is `σ[v/x]` — "σ with `x` now bound to `v`" — the semantic effect of `x = v`. A blocked command configuration models a runtime error or non-termination.

## Explanation

### Assignment is the only state-modifier

```
       ⟨E, σ⟩ → v
  ─────────────────────       (evaluate the right-hand side, then rebind x)
  ⟨x = E;, σ⟩ → σ[v/x]
```

`σ[v/x]` denotes the state identical to σ except that `x` maps to `v`. Every other command is a **control construct** whose job is to sequence and guard assignments.

### Blocks and sequencing

A block runs its statement list in order; a sequence threads the state from each statement into the next:

```
  ⟨S, σ⟩ → σ″    ⟨Slist, σ″⟩ → σ′
  ────────────────────────────────      (S runs first, then the rest run in the state S left behind)
        ⟨S Slist, σ⟩ → σ′
```

This "output state of one becomes input state of the next" threading is the essence of imperative sequencing.

### Conditionals and loops

`if` picks a branch by evaluating its guard; `while` is defined **recursively** — a true guard runs the body once and then re-runs the *whole loop* in the resulting state:

```
  ⟨E,σ⟩→tt   ⟨C₁,σ⟩→σ′                  ⟨E,σ⟩→ff
  ──────────────────────  (if-tt)     ─────────────────────  (while-ff: false guard = do nothing)
  ⟨if(E) C₁ else C₂, σ⟩→σ′             ⟨while(E) C, σ⟩ → σ

                    ⟨E,σ⟩→tt   ⟨C,σ⟩→σ″   ⟨while(E) C, σ″⟩→σ′
                    ─────────────────────────────────────────  (while-tt)
                             ⟨while(E) C, σ⟩ → σ′
```

The `while-tt` premise refers to the *same* command `while(E) C` — not circular, because the state component (σ″) has changed. A loop that never falsifies its guard (`while (x>0) x = x+1;`) produces an **infinite derivation** with no terminal configuration.

### Worked example

`while (x>0) x = x-1;` from `σ = {x ↦ 2}`:

```
⟨while (x>0) x=x-1;, {x↦2}⟩
  → (while-tt: x>0 tt, x-1 = 1)  ⟨while…, {x↦1}⟩
  → (while-tt: x>0 tt, x-1 = 0)  ⟨while…, {x↦0}⟩
  → (while-ff: x>0 ff)           {x↦0}      ← terminal
```

### Two kinds of blocked configuration = two kinds of dynamic error

`⟨x = 5 - 8;, σ⟩` is blocked (the RHS has no natural value) — a **runtime error**. An infinite loop never reaches a terminal state either. In this semantics the two are *indistinguishable* (both simply fail to reach a terminal configuration), even though they're different situations operationally.

> [!tip] Connection to Dalvik
> `σ[v/x]` is a Dalvik register/field write: `x = E;` compiles to code that computes `E` into a register then commits it — `move`/`const` into a local register, or `iput`/`sput` for a field. The control constructs compile to compares and branches: `if` → `if-*z … goto`, `while` → a guard test with a **backward** `goto` (the recursive `while-tt` rule *is* the backward jump). Sequencing "thread σ into the next statement" is just straight-line instruction order. Recognizing these shapes in raw smali is the whole game in [[Reading-Raw-Dalvik]]; the `div-int/lit8 v, v, 0x0` traps described there are deliberately-blocked configurations (an `ArithmeticException`) dressed up as arithmetic. See [[Dalvik-Instructions]] for the `if-*`/`goto`/`iput` opcodes.

## More examples

- [[Evaluating-A-While-Loop]] — a full command derivation for a loop, state by state.

## See also

- [[State-And-Expressions]] — expressions the commands evaluate.
- [[Declarations-And-Scope]] — what happens to σ when blocks also *declare* names.
- [[Control-Flow-Patterns]] in [[ARM64-Android]] and [[Dalvik-Instructions]] in [[Dalvik-Bytecode]] — the compiled shapes of these constructs.

## References

- [[Java-Fundamentals-Bibliography|Bibliography]]

## Flashcards
#flashcards

What does the notation `σ[v/x]` mean, and which command produces it?::The state identical to σ except that `x` is now bound to `v`; it's the semantic effect of the assignment `x = E;` after `E` evaluates to `v`.
Why is the `while-tt` rule (whose premise mentions the same `while` command) not circular?::Because the recursive premise is evaluated in a *changed* state (σ″ after running the body once), so the derivation makes progress rather than looping on an identical configuration.
In this semantics, how are a runtime error (`5 - 8`) and an infinite loop related?::Both are configurations that never reach a terminal configuration, and the semantics does not distinguish them — one is blocked, the other has an infinite derivation, but neither yields a final state.
How does `x = E;` map to Dalvik?::Compute `E` into a register, then commit it — a `move`/`const` for a local, or `iput`/`sput` for a field; the `σ[v/x]` rebinding is exactly that register/field write.
