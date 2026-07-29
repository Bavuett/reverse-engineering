---
tags: [moc, topic]
aliases: ["ARM64 Android", "ARM64 Android Reversing"]
created: 2026-07-28
---

# ARM64-Android

Reading and statically analyzing **ARM64 machine code compiled for Android** — from the instruction set itself, through the AArch64 procedure call standard, up to the two shapes of native code you actually meet when reversing a real app: classic JNI/NDK shared libraries, and the AOT-compiled Dart code inside a Flutter app's `libapp.so`. Where a companion vault on reversing Dalvik bytecode covers the managed, stack-machine bytecode the ART interpreter/JIT runs, this topic covers the register-machine native code sitting right next to it — the layer you're forced into whenever a class file just calls into a `.so` and there's no bytecode left to read.

## Map of this topic

```mermaid
graph TD
    R[Reference] --> CS[Case Studies]
    R --> CH[Cheatsheets]
    R --> TL[Tools]
    R --> RN[Reading Notes]
    R --> PR[Projects]
```

| Section | Covers |
| --- | --- |
| [[ARM64-Android-Reference\|Reference]] | glossary, bibliography, vault-wide reference-entry/example/snippet listings for this topic |
| [[ARM64-Android-Case-Studies\|Case Studies]] | full real-project investigations |
| [[ARM64-Android-Cheatsheets\|Cheatsheets]] | standalone quick-reference pages |
| [[ARM64-Android-Tools\|Tools]] | notes on the tools you actually use |
| [[ARM64-Android-Reading-Notes\|Reading Notes]] | books, courses, papers, RFCs |
| [[ARM64-Android-Projects\|Projects]] | personal coding projects |

## Chapters

1. [[Registers-And-Data]] — the AArch64 register file, data types/sizes, and the extra reserved-register roles Android runtimes (ART, the Dart VM) layer on top of the standard ABI.
2. [[Instructions]] — the instruction classes you actually need: data processing, load/store, branches, comparisons, bitfield extraction.
3. [[Functions-And-Calling-Convention]] — AAPCS64 parameter passing and stack frames, and how the Dart VM's own frame convention (`EnterFrame`/`CheckStackOverflow`/`LeaveFrame`) diverges from it.
4. [[Control-Flow-Patterns]] — recognizing `if`/`else`, loops, and `switch`-shaped dispatch once they've been flattened into compares and branches.
5. [[Memory-And-Data-Structures]] — object layout, field access, tagged integers, arrays, strings, heap allocation — reading raw loads/stores back into "this is a field access", "this is a boxed int".
6. [[Android-Native-Internals]] — the ELF shape of an Android `.so`, JNI's calling convention, and how Java/Kotlin code on the ART side calls into native code and back.
7. [[Flutter-Dart-AOT]] — how Dart's AOT compiler targets ARM64: the object pool, the global dispatch table, stubs, closures, `async`/`await`, and why Flutter apps need this chapter instead of chapter 6.
8. [[Reading-Raw-Disassembly]] — the capstone: everything from chapters 1–7, applied with none of blutter's synthetic comments to lean on — real excerpts stripped down to bare addresses and mnemonics, read cold.
9. [[ARM64-Android-Reference|Reference]] — glossary, bibliography, and the aggregated examples/snippets/reference-entry listings for this topic.

## See also

- [[Home]]
