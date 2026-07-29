---
tags: [reference]
aliases: ["Frida Dynamic Instrumentation Bibliography"]
---

# Frida-Dynamic-Instrumentation · Bibliography

Official sources, tools, and further reading used throughout this topic. Every chapter note and
template links back here under "References" — add the source when you first cite it.

## Primary sources

- [Frida — JavaScript API reference](https://frida.re/docs/javascript-api/) — the canonical reference for `Java.*`, `Interceptor.*`, `Memory.*`, `Module.*`, `Process.*`.
- [Frida — frida-java-bridge](https://github.com/frida/frida-java-bridge) — the source of `Java.perform`/`Java.use`, useful when the docs are ambiguous about exact behavior.
- [OWASP Mobile Application Security Testing Guide (MASTG) — Dynamic Analysis](https://mas.owasp.org/MASTG/) — the standard reference for Android dynamic analysis methodology, including SSL pinning bypass patterns beyond the ones in [[Network-Interception]].

## Tools

- [[Frida-Server-Setup]] — this vault's own note on getting `frida-server` running on a rooted emulator.
- [[Frida]] — the [[ARM64-Android]] topic's tool note, focused on confirming static-analysis hypotheses (particularly Dart-AOT ones) dynamically.
- [objection](https://github.com/sensepost/objection) — a Frida-powered CLI that automates common tasks covered manually in this topic (SSL pinning bypass, root detection bypass, class/method enumeration) — worth reaching for once the manual scripting here feels repetitive.

## Further reading

- [NowSecure — Frida CodeShare](https://codeshare.frida.re/) — a public repository of ready-made Frida scripts (pinning bypasses, root-detection bypasses) for common frameworks, useful both as working tools and as examples of idiomatic script structure.

## See also

- [[Frida-Dynamic-Instrumentation-Reference|Reference]]
