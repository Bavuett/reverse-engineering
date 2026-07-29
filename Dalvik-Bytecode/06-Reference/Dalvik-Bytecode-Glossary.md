---
tags: [reference]
aliases: ["Dalvik-Bytecode Glossary", "Dalvik Glossary", "Dalvik Terminology"]
---

# Dalvik-Bytecode · Glossary

Terminology used throughout this topic, linked to the note that covers it in depth.

| Term | Definition | See also |
| --- | --- | --- |
| **Dalvik** | The register-based virtual machine used by Android to run bytecode up through Android 4.4; later replaced by ART, which keeps the same bytecode format/instruction set. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **DEX** | _Dalvik Executable_, the binary format (`.dex`) that packages classes and Dalvik bytecode. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **ART** | _Android Runtime_, the runtime that replaced Dalvik starting with Android 5.0, while preserving format/instruction compatibility. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **smali / baksmali** | The textual language (smali) and tool (baksmali) used to represent/disassemble Dalvik bytecode in human-readable form; smali is also the assembler that does the reverse operation. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **APK** | _Android Package_, the zip archive that contains, among other things, one or more `.dex` files. | [[Dalvik-Bytecode-Bibliography\|Bibliography]] |
| **Direct method** | A method resolved statically (`private`, `static`, or the `<init>` constructor): no dynamic dispatch involved. | [[Classes]] |
| **Virtual method** | A public/protected method resolved at runtime based on the object's actual type (dynamic dispatch, supports overriding). | [[Classes]] |
| **Register (`v`)** | A 32-bit slot used for local variables/temporaries within a method. | [[Registers]] |
| **Parameter (`p`)** | A register that represents a method parameter (including `p0` = `this`, when the method isn't `static`). | [[Registers]] |
| **`.locals`** | Directive declaring how many local (`v`) registers are used, excluding parameters. | [[Registers]] |
| **`.registers`** | Directive declaring the _total_ register count (locals + parameters). | [[Registers]] |
| **Type descriptor** | The textual representation of a type (`I`, `Z`, `L<Class>;`, `[I`, ...). | [[Types]] |
| **`<init>`** | The reserved name for the instance constructor. | [[Methods]] |
| **`<clinit>`** | The reserved name for the class's static initializer. | [[Methods]] |
| **`invoke-virtual` / `invoke-direct` / `invoke-static` / `invoke-interface` / `invoke-super`** | Instruction families used to call virtual, direct, static, interface, and explicit-superclass methods respectively. | [[Methods]] |
| **vtable** | Virtual method table: per-class array of method pointers, one slot per virtual method, inherited and only ever overridden/appended by subclasses. What `invoke-virtual` looks up. | [[Methods]] |
| **itable** | Interface method table: per-class lookup keyed by interface method, since unrelated classes implementing the same interface can't share fixed vtable slots for it. What `invoke-interface` looks up. | [[Methods]] |
| **`move-result` / `move-result-wide` / `move-result-object`** | Reads the return value of the immediately preceding `invoke-*` out of its implicit VM slot into a real register; omitted entirely if the value isn't needed. | [[Methods]] |
| **`invoke-*/range`** | Wide-encoding counterpart of each `invoke-*` (e.g. `invoke-virtual/range`), used when a call needs more than 5 argument registers or one numbered above `v15`; same resolution and target, only the argument-register encoding (start register + count, must be consecutive) differs. | [[Methods]] |
| **Opcode** | The numeric/mnemonic identifier of a single Dalvik instruction (e.g. `invoke-virtual`, `add-int`). | [[Dalvik-Instructions\|Instructions]] |

## See also

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
- [[Dalvik-Bytecode-Reference|Reference]]
