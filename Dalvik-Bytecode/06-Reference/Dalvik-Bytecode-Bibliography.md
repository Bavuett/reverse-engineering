---
tags: [reference]
aliases: ["Dalvik-Bytecode Bibliography", "Dalvik Bibliography", "Dalvik Sources"]
---

# Dalvik-Bytecode · Bibliography

Sources used as a reference for this topic, and for further study of Android reverse engineering
through Dalvik bytecode.

## Official documentation

- Android Open Source Project — *Dalvik bytecode*. https://source.android.com/docs/core/runtime/dalvik-bytecode
  The official reference for the Dalvik instruction set: formats, opcodes, semantics.
- Android Open Source Project — *Dalvik Executable (DEX) format*. https://source.android.com/docs/core/runtime/dex-format
  Binary layout of the `.dex` file that packages the bytecode.
- Android Open Source Project — *ART and Dalvik*. https://source.android.com/docs/core/runtime
  Overview of the evolution from the Dalvik VM to the Android Runtime (ART).

## Tools

- **smali / baksmali** (JesusFreke) — assembler/disassembler to/from `.dex`. https://github.com/JesusFreke/smali
- **smali wiki** — detailed syntax for types, registers, and directives. https://github.com/JesusFreke/smali/wiki
- **Apktool** (iBotPeaches) — decompiling/rebuilding APKs (resources + smali). https://github.com/iBotPeaches/Apktool
- **jadx** (skylot) — Dex-to-Java-like decompiler, useful for cross-checking smali against reconstructed source. https://github.com/skylot/jadx

## Books

- Drake, J. J.; Lanier, Z.; Mulliner, C.; Fora, P. O.; Ridley, S. A.; Wicherski, G. — *Android Hacker's Handbook*. Wiley, 2014. ISBN 978-1118608647.

## Historical talks

- Bornstein, D. — *Dalvik Virtual Machine Internals*. Google I/O, 2008.
  The original Android team presentation on the Dalvik VM's design (register-based architecture, DEX format).

## See also

- [[Dalvik-Bytecode-Glossary|Glossary]]
- [[Dalvik-Bytecode-Reference|Reference]]

> [!tip] Contributing
> Add new sources keeping the format: *Author — Title. Publisher/Venue, year.* followed by the URL on its own line, if available. Avoid adding unverified URLs.
