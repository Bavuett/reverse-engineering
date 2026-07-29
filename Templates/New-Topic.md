<%*
const topicName = await tp.system.prompt("Topic name — a short PascalCase identifier, e.g. Rust, ReverseEngineering", "", true);
const topicNumber = await tp.system.prompt("Topic number — two digits, next free number after the last existing topic folder (e.g. 04)", "01", true);
const folderName = topicNumber + "-" + topicName;
await tp.file.move(folderName + "/" + topicName);
-%>
---
tags: [moc, topic]
aliases: []
created: <% tp.date.now("YYYY-MM-DD") %>
---

# <% tp.file.title %>

One-paragraph description of this topic: what it covers and why you're studying it.

## Map of this topic

```mermaid
graph TD
    R[Reference]
```

| Section | Covers |
|---|---|
| [[<% topicName %>-Reference\|Reference]] | glossary, bibliography, vault-wide reference-entry/example/snippet listings for this topic |

This topic also draws on the vault-wide [[Case-Studies]], [[Cheatsheets]], [[Tools]],
[[Reading-Notes]], and [[Projects]] — shared across every topic rather than scoped to this one.
Filter each one's table by this topic's name in its `topics` column, or just look for a
"Relevant topics & background" section on this topic's home note pointing the other way once
something links back here.

## Chapters

_(populate as you add chapters with [[New-Chapter]])_

-

## See also

- [[Home]]

> [!todo] Finish setting up this topic (see `CLAUDE.md` → "Adding a new topic")
> This template just created `<% folderName %>/<% tp.file.title %>.md` for you. Still to do
> by hand:
> - [ ] Copy `01-Reference/` from `_Topic-Skeleton/` into `<% folderName %>/`
> - [ ] Rename every `TOPIC`-prefixed file you copied, e.g. `TOPIC-Reference.md` →
>   `<% topicName %>-Reference.md`
> - [ ] Find-and-replace the `TOPIC` placeholder inside those files' content (titles, aliases,
>   Dataview `FROM` clauses, wikilinks)
> - [ ] Add this topic's `folder_templates` entry for its Reference chapter to
>   `.obsidian/plugins/templater-obsidian/data.json` — copy the pattern from `CLAUDE.md` →
>   "Adding a new topic"
> - [ ] Add this topic to the table in `Home.md` and `README.md`
> - [ ] Delete this reminder block once everything above is done
