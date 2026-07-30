---
tags: [moc]
aliases: ["Java Fundamentals Reference"]
---

# Java-Fundamentals · Reference

Quick-consultation material for **Java-Fundamentals**: glossary, bibliography, plus a topic-wide, always-up-to-date overview of every reference entry, worked example, and real-world snippet — regardless of which chapter folder they live in.

| Note | Content |
|---|---|
| [[Java-Fundamentals-Glossary\|Glossary]] | Terminology used across this topic |
| [[Java-Fundamentals-Bibliography\|Bibliography]] | Sources, tools, and further reading |

## Reference entries

Individual reference entries (created from the [[New-Reference-Entry]] template, tagged `#reference-entry`) are listed here automatically as they are added, wherever they live in this topic:

```dataview
TABLE category AS "Category"
FROM "04-Java-Fundamentals" AND #reference-entry
SORT file.name ASC
```

## All practical examples

Every worked example across every chapter of this topic (tagged `#example`, normally filed under a chapter's own `examples/` subfolder):

```dataview
TABLE file.folder AS "Chapter"
FROM "04-Java-Fundamentals" AND #example
SORT file.folder ASC, file.name ASC
```

## All real-world snippets

Every real-world fragment (tagged `#snippet`, normally filed under a chapter's own `snippets/<project>/` subfolder):

```dataview
TABLE project AS "Project", source AS "Source", source_path AS "Source path", date_added AS "Added", file.folder AS "Chapter"
FROM "04-Java-Fundamentals" AND #snippet
SORT project ASC, file.name ASC
```

> [!info] Requires Dataview
> These three tables need the **Dataview** community plugin — see the setup notes in [[Home]].
> Until a matching note exists, a table simply stays empty.

## Full case studies

For a full project-by-project investigation, see the vault-wide [[Case-Studies]] rather than the per-chapter `snippets/` above — case studies aren't scoped to a single topic, so they live at the repository root instead of inside this topic folder.

## Extending this section

To add a new reference entry, use the [[New-Reference-Entry]] template. To add a new example or snippet, create it directly inside the relevant chapter's `examples/` or `snippets/` subfolder (see [[Home]] and `CLAUDE.md` for the full convention) — it will show up above automatically.

## See also

- [[Java-Fundamentals]]
