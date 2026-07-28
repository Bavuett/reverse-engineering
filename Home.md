---
tags: [moc]
aliases: [Index, Home]
---

# 📓 Study Vault

A multi-topic Obsidian vault for public study notes on reverse engineering, coding, programming
languages, and adjacent CS topics — one self-contained **topic** per subject, each following the
same structure. See `CLAUDE.md` at the repository root for the full structuring convention — read
it before adding new content.

> [!warning] Ethical use
> This material is for educational and personal-research purposes. If a topic involves reverse
> engineering third-party software, always respect licenses, terms of service, and applicable
> local regulations — see the `license_note` field on snippet and case-study notes.

## 🗂️ Topics

```dataview
TABLE created AS "Added"
FROM #topic
SORT file.name ASC
```

> [!info] Requires Dataview
> See the "Recommended Obsidian setup" section below.

Add another topic with the [[New-Topic]] template — it scaffolds the topic's home note, then walks
you through copying the rest of the structure from `_Topic-Skeleton/`. See `CLAUDE.md` → "Adding a
new topic".

## 🧩 How each topic is structured

Every topic is its own top-level folder at the repository root and follows the same internal
shape — the same one `reversing-dalvik-bytecode` used:

```
<TopicName>/
├── <TopicName>.md           <- topic home/MOC (this template's version of "Home.md", one per topic)
├── 01-ChapterName/           <- numbered concept chapters, added as you go
│   ├── ChapterName.md
│   ├── examples/
│   └── snippets/
├── 0N-Reference/             <- always the highest-numbered chapter: glossary, bibliography, aggregated listings
│   ├── <TopicName>-Reference.md
│   ├── <TopicName>-Glossary.md
│   └── <TopicName>-Bibliography.md
├── Case-Studies/              <- full real-project investigations
├── Cheatsheets/                <- standalone quick-reference pages
├── Tools/                      <- notes on the tools you actually use
├── Reading-Notes/               <- books, courses, papers, RFCs
└── Projects/                     <- personal coding projects
```

Chapter/example/snippet/entry notes stay bare-named (e.g. `Classes.md`, `Basic-Class.md`) since
those are usually specific enough not to collide across topics. The handful of notes every topic
has exactly one of — the topic home note and the six index notes above — are **topic-prefixed**
(`<TopicName>-Reference.md`, not `Reference.md`) precisely because they'd otherwise collide:
Obsidian resolves bare `[[wikilinks]]` by filename across the whole vault, and this vault holds
more than one topic. See `CLAUDE.md` for the full uniqueness rule.

## 🚀 Where to start

1. Create a new topic with [[New-Topic]], then finish scaffolding it from `_Topic-Skeleton/`
   (checklist included in the note it creates).
2. Add chapters within that topic with [[New-Chapter]].
3. Fill each chapter in with [[New-Concept]], [[New-Example]], [[New-Snippet]].
4. Use that topic's Case Studies / Cheatsheets / Tools / Reading Notes / Projects folders for
   everything that isn't chapter-scoped — created from [[New-Case-Study]],
   [[New-Case-Study-Note]], [[New-Cheatsheet]], [[New-Tool-Note]], [[New-Reading-Note]],
   [[New-Project-Note]].
5. Check `CLAUDE.md` before adding a new topic, chapter, or note type — it has the full
   structuring convention.

## 🧭 Root layout

| Path | Content |
|---|---|
| `<TopicName>/` (one per topic) | everything for that subject — see "How each topic is structured" above |
| `_Topic-Skeleton/` | copy-source for scaffolding a new topic's Reference/Case-Studies/Cheatsheets/Tools/Reading-Notes/Projects folders |
| `Templates/` | Templater templates for every note type, used vault-wide across all topics |
| `assets/` | non-note files (scans, screenshots, exported diagrams), not topic-specific |

Topic folders sit directly at the root alongside these three — don't use `Templates`,
`_Topic-Skeleton`, or `assets` as a topic name.

## ⚙️ Recommended Obsidian setup

The vault ships with these community plugins already bundled under `.obsidian/plugins/` and enabled
in `community-plugins.json` — no manual install from the Community Plugins browser needed, just
open the vault in Obsidian and (if prompted) trust/enable community plugins once:

| Plugin | Why it's used here |
|---|---|
| **Templater** | Powers every template in `Templates/`, including [[New-Topic]] and [[New-Chapter]], which script folder creation. Per-topic `folder_templates` mappings are added as each topic is scaffolded (see `CLAUDE.md`). |
| **Dataview** | Powers the self-updating tables here and in every topic's Reference/Case-Studies/Cheatsheets/Tools/Reading-Notes/Projects index — add a note with the right tag anywhere in a topic and it appears with no manual edits. |
| **Spaced Repetition** | Turns the `#flashcards` decks at the bottom of each chapter's concept note into a review queue (`Review flashcards` command), for active recall practice. |

Without these plugins enabled, the notes still read perfectly fine — the Dataview blocks just
render as plain code fences, and the flashcards as plain text — but enabling them turns the vault
from a static reference into something that actively helps you learn and stays organized as it
grows. If Obsidian ever reports a plugin failed to load right after pulling changes, reload the app
(or toggle the plugin off/on) so it picks up the newly-synced plugin files.

On phone/tablet: enable sync (Obsidian Sync, iCloud, or simply cloning this git repo) and use
global search or the *Backlinks* panel to jump between linked notes quickly.
