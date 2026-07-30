---
tags: [reference]
aliases: ["Dalvik-Bytecode Glossary", "Dalvik Glossary", "Dalvik Terminology"]
---

# Dalvik-Bytecode · Glossary

Terminology used throughout this topic, linked to the note that covers it in depth. For individual instruction mnemonics specifically, skip straight to [[#Instruction quick reference|Instruction quick reference]] below — it mirrors [[Dalvik-Instructions|Instructions]]'s own category headings, opcode by opcode, so a fast lookup mid-read doesn't need to re-read that chapter's prose.

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

## Instruction quick reference

Every mnemonic that appears anywhere in this topic (including the real-app excerpts in [[Reading-Raw-Dalvik]] and the `snippets/` folders), grouped the same way [[Dalvik-Instructions|Instructions]] introduces them, for a fast lookup that doesn't need the surrounding prose.

### Encoding suffixes

Most instruction *families* below appear under several suffixed names — the suffix changes only the encoding, never the operation:

| Suffix | Meaning |
| --- | --- |
| `/4`, `/16` | The literal/register operand fits in 4 or 16 bits respectively — smaller encoding for small values (e.g. `const/4` vs `const/16` vs plain `const`) |
| `/high16` | The literal occupies only the *high* 16 bits of the destination, zero-filled below — used for values that are naturally shifted (e.g. float/double bit patterns, or `const/high16` for a value like `0x12340000`) |
| `/lit8`, `/lit16` | One operand is an immediate literal baked into the instruction itself (8 or 16 bits), instead of a second register — e.g. `add-int/lit8 v0, v1, 5` computes `v0 = v1 + 5` without needing a register to hold `5` |
| `/2addr` | Compact 2-operand form where the destination register doubles as the first source (`add-int/2addr v0, v1` means `v0 = v0 + v1`) — see [[Dalvik-Instructions#Arithmetic and conversion\|Instructions]] |
| `/from16`, `/jumbo` | Wider register-index encodings, needed when a register number doesn't fit the instruction's normal (smaller) register-index field |
| `/range` | Arguments passed as a contiguous `{vN .. vM}` block (start register + count) instead of listing each individually — used by `invoke-*` and `filled-new-array` when more than 5 registers, or one above `v15`, are involved; see [[Methods]] |
| `-wide` | Operates on a 64-bit register pair instead of a single 32-bit register — see [[Registers]] |
| `-object` | Operates on an object reference instead of a 32-bit primitive |
| `-boolean`, `-byte`, `-char`, `-short` | Narrows a field/array read-write to that specific sub-32-bit type, for verifier type-tracking purposes — see [[Types#Primitive types\|Types]] |

### Constants and data movement

| Instruction | Meaning |
| --- | --- |
| `const`, `const/4`, `const/16`, `const/high16` | Load a 32-bit integer literal into a register |
| `const-wide`, `const-wide/16`, `const-wide/32`, `const-wide/high16` | Load a 64-bit literal into a register pair |
| `const-string`, `const-string/jumbo` | Load a reference to an interned `String` literal from the constant pool |
| `const-class` | Load a `Class` object literal (e.g. `MyClass.class`) |
| `move`, `move/from16`, `move/16` | Copy a 32-bit value between registers |
| `move-wide` (+ `/from16`, `/16`) | Copy a 64-bit value between register pairs |
| `move-object` (+ `/from16`, `/16`) | Copy an object reference between registers |
| `move-result`, `move-result-wide`, `move-result-object` | Capture the return value of the immediately preceding `invoke-*` — see [[Methods]] |
| `move-exception` | At the top of a catch block, capture the just-thrown exception — see [[Methods]] |

### Field access

| Instruction | Meaning |
| --- | --- |
| `iget`, `iput` | Read/write an instance field holding a 32-bit primitive |
| `iget-wide`, `iput-wide` | Same, for a 64-bit field |
| `iget-object`, `iput-object` | Same, for a reference-typed field |
| `iget-boolean`/`-byte`/`-char`/`-short` (+ `iput-*`) | Same, narrowed to that sub-32-bit primitive type |
| `sget`, `sput` (+ same `-wide`/`-object`/`-boolean`/`-byte`/`-char`/`-short` suffixes) | Read/write a **static** field instead of an instance field |

### Array access

| Instruction | Meaning |
| --- | --- |
| `array-length` | Store an array's length into a register |
| `new-array` | Allocate a new single-dimension array of a given length |
| `filled-new-array`, `filled-new-array/range` | Allocate and populate a small array in one instruction, result read out via `move-result-object` |
| `fill-array-data` | Populate an already-allocated primitive array from a literal `.array-data <width> ... .end array-data` block — see [[Encrypted-String-Table-Array-Data]] for a real-app instance |
| `aget`, `aput` (+ `-wide`/`-object`/`-boolean`/`-byte`/`-char`/`-short`) | Read/write one array element |

### Method invocation

| Instruction | Meaning |
| --- | --- |
| `invoke-direct` (+ `/range`) | Call a constructor or `private` instance method — resolved at compile time |
| `invoke-static` (+ `/range`) | Call a `static` method |
| `invoke-virtual` (+ `/range`) | Call a public/protected instance method via the vtable — dynamic dispatch |
| `invoke-interface` (+ `/range`) | Call a method declared on an interface, via the itable |
| `invoke-super` (+ `/range`) | Call the exact superclass implementation, bypassing dynamic dispatch on the receiver's runtime type |

### Object and type operations

| Instruction | Meaning |
| --- | --- |
| `new-instance` | Allocate an object of a given class, **uninitialized** until a matching `invoke-direct ...-><init>(...)V` runs on it |
| `check-cast` | Verify (and narrow) a reference's type, throwing `ClassCastException` on mismatch |
| `instance-of` | Test whether a reference is an instance of a type, storing a `boolean` result — never throws |

### Arithmetic and conversion

| Instruction | Meaning |
| --- | --- |
| `add-int`, `sub-int`, `mul-int`, `div-int`, `rem-int` (+ `int`→`long`/`float`/`double` variants, `/2addr`, `/lit8`, `/lit16`) | Binary arithmetic; `div-int .../lit8 ..., 0x0` always throws `ArithmeticException` — see [[Reading-Raw-Dalvik]] |
| `and-int`, `or-int`, `xor-int`, `shl-int`, `shr-int`, `ushr-int` (+ `-long` variants, `/2addr`, `/lit8`, `/lit16`) | Bitwise AND/OR/XOR and left/arithmetic-right/logical-right shift |
| `neg-int`, `neg-long`, `neg-float`, `neg-double` | Unary negation |
| `not-int`, `not-long` | Bitwise complement |
| `int-to-long`, `int-to-float`, `int-to-double`, `long-to-int`, `float-to-int`, `double-to-long`, ... | Explicit numeric conversions between primitive types |
| `int-to-byte`, `int-to-char`, `int-to-short` | Narrowing conversions, truncating to the sub-32-bit type |

### Comparisons and control flow

| Instruction | Meaning |
| --- | --- |
| `if-eq`, `if-ne`, `if-lt`, `if-ge`, `if-gt`, `if-le` | Two-register conditional branch |
| `if-eqz`, `if-nez`, `if-ltz`, `if-gez`, `if-gtz`, `if-lez` | Compare a single register against zero (also used for reference null-checks, `if-eqz`/`if-nez`) |
| `cmp-long` | Three-way compare of two `long`s (`-1`/`0`/`1`), result fed into a following `if-*z` |
| `cmpl-float`, `cmpg-float`, `cmpl-double`, `cmpg-double` | Three-way float/double compare; the `l`/`g` suffix picks which result (`-1` or `1`) `NaN` produces |
| `goto`, `goto/16`, `goto/32` | Unconditional jump, in increasingly wide encodings |
| `packed-switch` | Multi-way branch over a dense, contiguous range of `int` values (compiled `switch`) |
| `sparse-switch` | Multi-way branch over an arbitrary, non-contiguous set of `int` values |

### Returning, exceptions, and synchronization

| Instruction | Meaning |
| --- | --- |
| `return-void` | Return with no value |
| `return` | Return a 32-bit primitive |
| `return-wide` | Return a 64-bit primitive |
| `return-object` | Return a reference |
| `throw` | Raise an exception — throws `NullPointerException` immediately if the register is null, per [[Reading-Raw-Dalvik]] |
| `monitor-enter`, `monitor-exit` | Acquire/release the intrinsic lock backing a `synchronized` block — see `declared-synchronized` in [[Methods]] |

## See also

- [[Dalvik-Bytecode-Bibliography|Bibliography]]
- [[Dalvik-Bytecode-Reference|Reference]]
- [[Dalvik-Instructions|Instructions]] — the same instructions, grouped by concept and explained in prose
- [[Reading-Raw-Dalvik]] — these instructions read cold, in real, obfuscated app code
