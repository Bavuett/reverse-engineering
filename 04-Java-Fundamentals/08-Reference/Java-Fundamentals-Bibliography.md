---
tags: [reference]
aliases: ["Java Fundamentals Bibliography"]
---

# Java-Fundamentals · Bibliography

Official sources, tools, and further reading used throughout this topic.

## Primary sources

- R. Barbuti, P. Mancarella, F. Turini — *Elementi di Semantica Operazionale*. Appunti per Fondamenti di Programmazione, Corso di Laurea in Informatica, Università di Pisa (A.A. 2004/05). The operational-semantics treatment of a Java core (transition systems, big-step semantics, state as a stack of frames, objects/heap, classes, methods, `this`, recursion) that this whole topic follows.
- *The Java® Language Specification* (Oracle) — the authoritative reference for the real language's scoping, initialization, and evaluation-order rules the simplified core abstracts.
- *The Java® Virtual Machine Specification* (Oracle) — runtime data areas (method area/heap/JVM stacks/PC), class loading/linking/initialization, and bytecode; the real machine the abstract memory model maps onto.

## Further reading

- G. Winskel — *The Formal Semantics of Programming Languages* — the standard textbook backing for operational (and denotational/axiomatic) semantics.
- [[Reflection-and-Runtime-Internals]] in [[Dalvik-Bytecode]] — class loading, the method area/Metaspace, runtime data areas, and stack frames as ART actually implements them; the concrete counterpart to this topic's abstract memory model.

## See also

- [[Java-Fundamentals-Reference|Reference]]
