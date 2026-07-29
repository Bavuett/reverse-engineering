---
tags: [reading-note]
title: "Procedure Call Standard for the Arm 64-bit Architecture (AAPCS64)"
author: "Arm Ltd."
type: "specification"
status: "in-progress"
started: 2026-07-28
finished: ""
---

# Aapcs64-Specification

## Why I'm reading/watching this

Every native, non-Dart function on Android follows this ABI — it's the ground truth behind [[Functions-And-Calling-Convention]], and worth reading in full at least once rather than only ever absorbing it secondhand through this topic's summaries.

## Key takeaways

- Register roles (argument/return/caller-saved/callee-saved) are exactly what [[AAPCS64-Quick-Reference]] summarizes — the spec is the authority if a summary ever seems to disagree with something observed in real disassembly.
- Stack alignment (16 bytes at every public function boundary) is a _hard_ requirement the spec states explicitly, not just a convention — useful to cite when a frame-size calculation looks odd and you want to double check rounding.
- Variadic functions, structs passed/returned by value, and the "homogeneous floating-point aggregate" rules for `V0`-`V7` are the parts most likely to look unfamiliar coming from reading only integer/pointer-heavy disassembly — worth a dedicated re-read if a function's argument marshalling ever doesn't match the simple table.

## Notes

Freeform, chapter by chapter or section by section.

## Quotes

>

## Related concepts

- [[Functions-And-Calling-Convention]]
- [[Registers-And-Data]]

## See also

- [[ARM64-Android-Bibliography|Bibliography]]
