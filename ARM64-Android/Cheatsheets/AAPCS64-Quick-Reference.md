---
tags: [cheatsheet]
subject: "AAPCS64 calling convention"
created: 2026-07-28
---

# AAPCS64-Quick-Reference

Quick lookup — not a full explanation. See [[Functions-And-Calling-Convention]] for the "why".

## Quick reference

| Register | Role |
|---|---|
| `X0`–`X7` | Integer/pointer args 1–8; `X0` (+`X1`) also holds the return value |
| `V0`–`V7` | FP/SIMD args 1–8 |
| `X8` | Hidden pointer for large struct returns |
| `X9`–`X15` | Caller-saved scratch |
| `X16`/`X17` (`IP0`/`IP1`) | Scratch, linker veneers |
| `X18` | Reserved on Android — never allocated |
| `X19`–`X28` | Callee-saved |
| `X29` (`FP`) | Frame pointer |
| `X30` (`LR`) | Return address |
| `SP` | Stack pointer, 16-byte aligned at every call boundary |
| `stp x29, x30, [sp, #-N]!` | Standard prologue open |
| `ldp x29, x30, [sp], #N` | Standard epilogue close |
| `bl` | Call (sets `LR`) |
| `blr Xn` | Indirect call through a register |
| `ret` | Return via `LR` |

## Common pitfalls

- Don't assume `X0` on entry is "the first argument" for a Dart-AOT function — it frequently isn't
  the receiver/argument you'd expect; check `SetupParameters` annotations or trace what's actually
  moved where. See [[Flutter-Dart-AOT]].
- A JNI native method's *first Java-visible parameter* is in `X2`, not `X0`/`X1` — see
  [[Android-Native-Internals]].
- `X18` showing up as "just another scratch register" in your disassembler's output is a strong
  signal you're looking at a non-Android target, or a stripped/misidentified ABI.

## See also

- [[ARM64-Android]]
- [[Functions-And-Calling-Convention]]

## References

- [[ARM64-Android-Bibliography|Bibliography]]
