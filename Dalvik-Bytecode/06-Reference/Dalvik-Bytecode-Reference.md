---
tags: [moc]
aliases: ["Dalvik-Bytecode Reference"]
---

# Dalvik-Bytecode · Reference

Quick-consultation material for **Dalvik-Bytecode**: glossary, bibliography, type table, plus a topic-wide, always-up-to-date overview of every opcode reference entry, worked example, and real-app snippet — regardless of which chapter folder they live in.

| Note | Content |
| --- | --- |
| [[Dalvik-Type-Table]] | Quick reference for type descriptors (drawn from [[Types]]) |
| [[Dalvik-Bytecode-Glossary\|Glossary]] | Dalvik/smali terminology used across this topic |
| [[Dalvik-Bytecode-Bibliography\|Bibliography]] | Official sources, tools, and further reading |

## Opcodes

Individual opcode notes (created from the [[New-Reference-Entry]] template, tagged `#reference-entry`) are listed here automatically as they are added, wherever they live in this topic:

```dataview
TABLE category AS "Category"
FROM "Dalvik-Bytecode" AND #reference-entry
SORT file.name ASC
```

## All practical examples

Every worked example across every chapter of this topic (tagged `#example`, normally filed under a chapter's own `examples/` subfolder):

```dataview
TABLE file.folder AS "Chapter"
FROM "Dalvik-Bytecode" AND #example
SORT file.folder ASC, file.name ASC
```

## All real-app snippets

Every real-app fragment (tagged `#snippet`, normally filed under a chapter's own `snippets/<app>/` subfolder):

```dataview
TABLE project AS "App", source AS "Package", source_path AS "Source path", date_added AS "Added", file.folder AS "Chapter"
FROM "Dalvik-Bytecode" AND #snippet
SORT project ASC, file.name ASC
```

> [!info] Requires Dataview
>
> These three tables need the **Dataview** community plugin — see the setup notes in [[Home]]. Until a matching note exists, a table simply stays empty.

## Full case studies

For a full app-by-app investigation (imported source kept in its real class/package layout, plus open-ended analysis notes not scoped to a single chapter), see [[Dalvik-Bytecode-Case-Studies|Case Studies]] rather than the per-chapter `snippets/` above.

## Extending this section

To add a new opcode entry, use the [[New-Reference-Entry]] template (`category: "opcode"`). To add a new example or real-app snippet, create it directly inside the relevant chapter's `examples/` or `snippets/` subfolder (see [[Home]] and `CLAUDE.md` for the full convention) — it will show up above automatically.

## See also

- [[Dalvik-Bytecode]]
