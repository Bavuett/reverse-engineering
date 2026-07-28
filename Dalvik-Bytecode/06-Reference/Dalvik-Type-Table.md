---
tags: [reference, reference-entry]
category: "types"
aliases: ["Type table", "Type descriptors table"]
---

# Dalvik Type Table

Quick reference for type descriptors. Full explanation with examples: [[Types]].

## Primitive types

| Symbol | Java type | Size |
|---|---|---|
| `V` | `void` | — (return type only) |
| `Z` | `boolean` | 32 bit |
| `B` | `byte` | 32 bit |
| `S` | `short` | 32 bit |
| `C` | `char` | 32 bit |
| `I` | `int` | 32 bit |
| `F` | `float` | 32 bit |
| `J` | `long` | 64 bit (2 registers) |
| `D` | `double` | 64 bit (2 registers) |

## Reference and array types

| Descriptor | Meaning |
|---|---|
| `L<Class>;` | reference to an instance of `<Class>` (e.g. `Ljava/lang/String;`) |
| `[<T>` | array of `<T>` (e.g. `[I` -> `int[]`) |
| `[[<T>` | two-dimensional array (e.g. `[[I` -> `int[][]`) |

## Full method signature

```
L<Class>;-><methodName>(<param1><param2>...)<return>
```

Example: `Ljava/lang/String;->substring(II)Ljava/lang/String;` -> `String.substring(int, int)` returning `String`.

## See also

- [[Types]] (full explanation + examples)
- [[Registers]] (impact on `.locals`/`.registers`)
- [[Dalvik-Bytecode-Glossary|Glossary]]
