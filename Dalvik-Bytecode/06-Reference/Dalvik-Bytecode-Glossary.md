---
tags: [reference]
aliases: ["Dalvik-Bytecode Glossary", "Dalvik Glossary", "Dalvik Terminology"]
---

# Dalvik-Bytecode · Glossary

Terminology used throughout this topic, linked to the note that covers it in depth.

| Term | Definition | See also |
|---|---|---|
| **Dalvik** | The register-based virtual machine used by Android to run bytecode up through Android 4.4; later replaced by ART, which keeps the same bytecode format/instruction set. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **DEX** | *Dalvik Executable*, the binary format (`.dex`) that packages classes and Dalvik bytecode. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **ART** | *Android Runtime*, the runtime that replaced Dalvik starting with Android 5.0, while preserving format/instruction compatibility. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **smali / baksmali** | The textual language (smali) and tool (baksmali) used to represent/disassemble Dalvik bytecode in human-readable form; smali is also the assembler that does the reverse operation. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **APK** | *Android Package*, the zip archive that contains, among other things, one or more `.dex` files. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **Direct method** | A method resolved statically (`private`, `static`, or the `<init>` constructor): no dynamic dispatch involved. | [[Classes]] |
| **Virtual method** | A public/protected method resolved at runtime based on the object's actual type (dynamic dispatch, supports overriding). | [[Classes]] |
| **Register (`v`)** | A 32-bit slot used for local variables/temporaries within a method. | [[Registers]] |
| **Parameter (`p`)** | A register that represents a method parameter (including `p0` = `this`, when the method isn't `static`). | [[Registers]] |
| **`.locals`** | Directive declaring how many local (`v`) registers are used, excluding parameters. | [[Registers]] |
| **`.registers`** | Directive declaring the *total* register count (locals + parameters). | [[Registers]] |
| **Type descriptor** | The textual representation of a type (`I`, `Z`, `L<Class>;`, `[I`, ...). | [[Types]] |
| **`<init>`** | The reserved name for the instance constructor. | [[Methods]] |
| **`<clinit>`** | The reserved name for the class's static initializer. | [[Methods]] |
| **`invoke-virtual` / `invoke-direct` / `invoke-static` / `invoke-interface` / `invoke-super`** | Instruction families used to call virtual, direct, static, interface, and explicit-superclass methods respectively. | [[Methods]] |
| **Opcode** | The numeric/mnemonic identifier of a single Dalvik instruction (e.g. `invoke-virtual`, `add-int`). | [[Dalvik-Instructions\|Instructions]] |

## See also

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
- [[Dalvik-Bytecode-Reference|Reference]]
