# obsidian-vault-template

A GitHub template repository for a multi-topic **Obsidian vault** of public study notes on reverse engineering, coding, programming languages, and adjacent CS topics — one self-contained topic folder per subject, all sharing the same structure and tooling.

Each topic mirrors the shape of `reversing-dalvik-bytecode`: topic-centric chapters, self-updating Dataview indices, Templater scaffolding for every note type, and a small set of standalone note types (cheatsheets, tool notes, reading notes, project logs) for things that don't belong to one chapter. Topics are top-level folders at the repository root — so the vault can hold as many as you're studying, side by side.

## 📓 Using this template

1. On GitHub, click **Use this template → Create a new repository** (if this repo isn't already marked as a template, enable it once under **Settings → General → Template repository**).
2. Clone the new repository and open its root folder in [Obsidian](https://obsidian.md/).
3. Add your first topic with the `New-Topic` Templater template (see [[New-Topic]] / `Templates/New-Topic.md`) — it creates the topic's home note and walks you through copying the rest of the structure from `_Topic-Skeleton/`.
4. Add chapters within that topic with `New-Chapter` (see [[New-Chapter]]) — everything else grows from there.
5. Install the recommended community plugins (Templater, Dataview, Spaced Repetition) — see `Home.md` for why each one matters.

> [!TIP]
>
> This vault is meant to be **read and edited in Obsidian**, not on GitHub. The notes rely on Obsidian-only features — `[[wikilink]]` navigation and the graph/backlinks view, Dataview queries, Templater templates, foldable callouts — that GitHub's markdown renderer simply doesn't have; on GitHub they degrade to plain text or empty code blocks. Open the folder with Obsidian (free, available on desktop, iOS, and Android) and start from `Home.md` for the full, properly-rendered index.

## 📚 What's included

| Path | Content |
| --- | --- |
| `<TopicName>/` (one per topic) | everything for that subject, at the repository root |
| `_Topic-Skeleton/` | copy-source for a new topic's `Reference`/`Case-Studies`/`Cheatsheets`/`Tools`/`Reading-Notes`/`Projects` folders, including a fictional `demo-project-case-study/` showing the expected case-study shape |
| `Templates/` | every Templater template, used vault-wide across all topics |
| `assets/` | non-note files (scans, screenshots, exported diagrams), not topic-specific |

Topic folders sit directly at the root alongside these three — don't use `Templates`, `_Topic-Skeleton`, or `assets` as a topic name. Each topic follows this internal shape:

```
<TopicName>/
├── <TopicName>.md      <- topic home/MOC
├── 01-ChapterName/       <- numbered concept chapters, added as you go
│   ├── ChapterName.md
│   ├── examples/
│   └── snippets/
├── 0N-Reference/          <- always the highest-numbered chapter
├── Case-Studies/
├── Cheatsheets/
├── Tools/
├── Reading-Notes/
└── Projects/
```

See [`CLAUDE.md`](CLAUDE.md) for the complete structuring convention — including the vault-wide filename-uniqueness rule Obsidian's bare `[[wikilinks]]` depend on — read it before adding a new topic, chapter, note type, or top-level folder.

### Structure and extensibility

- Notes are cross-linked with Obsidian's `[[wikilink]]` syntax, which powers the graph view and backlinks panel (see the tip above about reading this in Obsidian).
- Diagrams use [Mermaid](https://mermaid.js.org/), rendered natively by both Obsidian and GitHub.
- New notes of any kind should be created from the files in [`Templates/`](Templates/New-Concept.md), via the **Templater** community plugin (recommended) or the core "Templates" plugin.
- Every topic's `Reference`, `Case-Studies`, `Cheatsheets`, `Tools`, `Reading-Notes`, and `Projects` index notes include **Dataview** queries that automatically list every matching note in that topic as it's added.

## License

[MIT](LICENSE) — do whatever you like with the skeleton; the content you fill it with is yours.
