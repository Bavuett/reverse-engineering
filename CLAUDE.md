# Project structure guide

This repository is a multi-topic Obsidian vault of public study notes: reverse engineering, a programming language, a CS topic, ... — one self-contained **topic** per subject, each its own top-level folder at the repository root, all sharing the same structure and tooling. Every topic is organized as a set of **topic-centric chapters** plus a handful of standalone note-type folders, not as separate "theory / examples / snippets" areas. Follow this convention whenever you add, move, or rename content — do not reintroduce a flat or type-grouped layout, and do not nest topics under a wrapper folder.

Topic folders sit directly at the repository root, alongside a few reserved, non-topic folders: `Templates/` (Templater templates, used vault-wide), `_Topic-Skeleton/` (copy-source for scaffolding a new topic), and `assets/` (non-note files — scans, screenshots, exported diagrams — shared vault-wide, not scoped to any topic, not part of the Obsidian note graph). Don't name a topic `Templates`, `_Topic-Skeleton`, or `assets`.

## Vault-wide filename uniqueness

Obsidian resolves bare `[[wikilinks]]` by filename across the **entire vault**, not per-folder or per-topic — this vault relies on that for portability (links keep working after files are moved, and stay readable without path noise). With more than one topic in the vault, this has one consequence you must respect:

- **Every filename must be unique vault-wide**, not just unique within its topic.
- The notes every topic has exactly one of — the topic's home note and its `Reference`, `Glossary`, `Bibliography`, `Case-Studies`, `Cheatsheets`, `Tools`, `Reading-Notes`, and `Projects` index notes — are **topic-prefixed** for exactly this reason (`Rust-Reference.md`, not `Reference.md`). Templates that link to them do so dynamically — see "Topic-scoped links in templates" below — so you never have to hardcode the prefix by hand.
- Chapter/example/reference-entry/snippet notes stay bare-named (`Classes.md`, not `Rust-Classes.md`) since a specific concept/example name is usually unique on its own. If two topics would otherwise produce the same filename (e.g. both have a chapter called "Basics"), rename one to disambiguate — don't rely on folder location to break the tie.

## Topic-scoped links in templates

Every note-level template in `Templates/` (chapters, examples, reference entries, snippets, case studies, cheatsheets, tool notes, reading notes, project notes) computes which topic it belongs to from its own folder path and uses that to link to the right `Reference`/`Bibliography`/ `Case-Studies` note, instead of a hardcoded name:

```
<%*
const topicSegment = tp.file.folder(true).split("/")[0];
-%>
```

`tp.file.folder(true)` returns the note's folder relative to the vault root (e.g. `Rust/02-Ownership`); index `[0]` is always the topic name, regardless of how deep the note sits inside that topic (a chapter, its `examples/`, a case study's `notes/`, ...). `New-Chapter.md` and `New-Topic.md` already know the topic name from their own prompts, so they use that directly instead of deriving it. Keep this pattern when adding a new template that needs to link back to a topic-level note.

## Topics live at the repository root, scaffolded from `_Topic-Skeleton/`

Each subject is its own top-level folder (`Rust/`, `Reverse-Engineering/`, ...), a direct sibling of `Templates/`, `_Topic-Skeleton/`, and `assets/` — there's no `Topics/` wrapper folder. This template ships with zero topics. `_Topic-Skeleton/` is not a topic itself; it's a literal copy-source for the parts of a new topic that aren't safe to script blindly (multiple files at once), using the literal placeholder text `TOPIC` in filenames, titles, aliases, Dataview `FROM` clauses, and wikilinks:

```
_Topic-Skeleton/
├── 01-Reference/
│   ├── TOPIC-Reference.md
│   ├── TOPIC-Glossary.md
│   └── TOPIC-Bibliography.md
├── Case-Studies/
│   ├── TOPIC-Case-Studies.md
│   └── demo-project-case-study/    <- reference-only, NOT copied into real topics
│       ├── Demo-Project-Case-Study.md
│       ├── source/
│       └── notes/
├── Cheatsheets/TOPIC-Cheatsheets.md
├── Tools/TOPIC-Tools.md
├── Reading-Notes/TOPIC-Reading-Notes.md
└── Projects/TOPIC-Projects.md
```

`demo-project-case-study/` is fabricated, fictional, and tagged `placeholder` — it exists permanently in `_Topic-Skeleton/` to show the expected shape of a case study (overview note, imported `source/`, analysis `notes/`) without cluttering every real topic with a copy of it.

## Adding a new topic

1. Run Templater's **"Create new note from template"** command and pick `Templates/New-Topic.md`. It prompts for a topic name and uses `tp.file.move` to create `<TopicName>/<TopicName>.md` — the topic's home note, at the repository root — pre-filled with a map of the topic's sections and a `[!todo]` checklist for the rest, because it touches multiple files and isn't safe to script blindly:
2. Copy `01-Reference/`, `Case-Studies/TOPIC-Case-Studies.md` (skip `demo-project-case-study/`), `Cheatsheets/`, `Tools/`, `Reading-Notes/`, and `Projects/` from `_Topic-Skeleton/` into `<TopicName>/`.
3. Rename every `TOPIC`-prefixed file you copied to the real topic name, e.g. `TOPIC-Reference.md` → `<TopicName>-Reference.md`.
4. Find-and-replace the `TOPIC` placeholder inside those files' content (titles, aliases, Dataview `FROM` clauses, wikilinks).
5. Add this topic's `folder_templates` entries to `.obsidian/plugins/templater-obsidian/data.json` → `folder_templates`:

   ```json
   { "folder": "<TopicName>/01-Reference", "template": "Templates/New-Reference-Entry.md" },
   { "folder": "<TopicName>/Case-Studies", "template": "Templates/New-Case-Study.md" },
   { "folder": "<TopicName>/Cheatsheets", "template": "Templates/New-Cheatsheet.md" },
   { "folder": "<TopicName>/Tools", "template": "Templates/New-Tool-Note.md" },
   { "folder": "<TopicName>/Reading-Notes", "template": "Templates/New-Reading-Note.md" },
   { "folder": "<TopicName>/Projects", "template": "Templates/New-Project-Note.md" }
   ```

6. Add the topic to the table in `Home.md` and `README.md`.

(Without Templater — e.g. using only the core "Templates" plugin — create `<TopicName>/<TopicName>.md` by hand instead, then apply the rest of the same steps.)

## Chapter layout

Within a topic, every fundamental concept is a numbered directory (`01-ChapterName`, `02-ChapterName`, ...). A brand-new topic starts with zero concept chapters — add the first one with [[New-Chapter]]. Each chapter directory follows the same internal shape:

```
<TopicName>/0X-ChapterName/
├── ChapterName.md    <- the concept note itself (same base name as the folder)
├── examples/          <- worked walkthroughs for this concept
└── snippets/          <- real-world fragments illustrating this concept
    └── <project-name-in-kebab-case>/
        └── Some-Note.md
```

- `examples/` and `snippets/` are created on demand — don't pre-create empty ones for a chapter that doesn't have any content yet. When the first example/snippet for a chapter is added, create the subfolder at that point.
- `snippets/` subfolders are per-project, not per-package: don't mirror the source's internal directory structure. A note's frontmatter (`project`, `source`, `source_path`) records the origin; folders exist only to group snippets by project.
- Put an example or snippet in the chapter whose concept it primarily demonstrates, even if it touches other chapters too — cross-link the rest via `[[wikilinks]]` instead of duplicating it.

## Cross-cutting material lives in each topic's `Reference` chapter

A topic's `0N-Reference/` is not a chapter about a single concept — it holds glossary, bibliography, and quick-reference tables, plus **Dataview queries that aggregate content from every chapter in that topic** (all reference-entry notes, all examples, all snippets, regardless of which chapter folder they physically live in — scoped to the topic via `FROM "<TopicName>"`). When adding a new reference entry, example, or snippet, you never need to manually edit `<TopicName>-Reference.md`'s listings — they update themselves as long as the new note carries the right tag (`#reference-entry`, `#example`, `#snippet`).

Each topic's `Reference` chapter is always the **highest-numbered** chapter folder within that topic. Its own number moves up every time a new concept chapter is added right before it.

## Adding a new chapter

Run Templater's **"Create new note from template"** command (not folder-scoped, since the target folder doesn't exist yet) and pick `Templates/New-Chapter.md`. It prompts for the topic, chapter number, and chapter name, then uses `tp.file.move` to create `<TopicName>/0N-ChapterName/` and place `ChapterName.md` inside it in one step (Templater creates any missing intermediate folders for you), pre-filled with the same body as `New-Concept.md`. It finishes by inserting a `[!todo]` checklist for the steps that still need a human, because they touch other files and aren't safe to script blindly:

1. Add the chapter to the chapter list and Mermaid diagram in the topic's home note (`<TopicName>/<TopicName>.md`).
2. If the number you picked was already taken by this topic's `Reference` chapter, rename that folder to the next free number, fix up its own internal `0X-` references, and update its `folder_templates` path in `.obsidian/plugins/templater-obsidian/data.json`.
3. Add three entries to `.obsidian/plugins/templater-obsidian/data.json` → `folder_templates`: the new chapter root (→ `Templates/New-Concept.md`), its `examples/` (→ `Templates/New-Example.md`), and its `snippets/` (→ `Templates/New-Snippet.md`) — copy the pattern already used for that topic's `Reference` chapter.

(Without Templater — e.g. using only the core "Templates" plugin — create the chapter folder and its concept note by hand instead, then apply `Templates/New-Concept.md` for the body.)

## Case studies live in each topic's `Case-Studies/`, separate from chapters

A topic's `Case-Studies/` (unnumbered, a peer of that topic's chapters) is for **full, real-world investigation of one whole project at a time**, as opposed to a chapter's `snippets/`, which is for tiny fragments illustrating exactly one concept. Don't confuse the two:

|  | `0X-Chapter/snippets/<project>/` | `Case-Studies/<project>/` |
| --- | --- | --- |
| Scope | one concept | one whole project |
| Content | a few lines, minimal | as much imported source as the investigation needs |
| Notes | tied to that chapter | open-ended, cross-chapter (still scoped to that topic) |

Each case study follows this shape:

```
<TopicName>/Case-Studies/<project-name>/
├── <Project Name>.md    <- overview note (from Templates/New-Case-Study.md)
├── source/               <- imported files, real layout preserved exactly
│   └── ...
└── notes/                <- analysis notes, freely named (from Templates/New-Case-Study-Note.md)
```

- Only import the files actually needed for the investigation, not a wholesale dump — but keep their original directory layout under `source/` so it stays legible and comparable to the real project. `source/` files are pasted in from whatever tool produced them (decompiler, disassembler, source drop, ...); there's no template for them, since they're extracted/imported code, not authored notes.
- Analysis notes reference a specific file with a bare wikilink (Obsidian can't deep-link to a line inside a non-Markdown file) and quote the relevant excerpt inline as a fenced code block — see `_Topic-Skeleton/Case-Studies/demo-project-case-study/notes/Demo-Finding.md` for a worked (fabricated) example.
- Enabling Obsidian's _Settings → Files & Links → Detect all file extensions_ is recommended so source files of arbitrary extensions resolve as clickable, linkable notes; this isn't auto-configured here (not confident enough in the exact `app.json` key across Obsidian versions to write it silently), so it stays a manual one-time step.
- Starting a new case study needs one manual Templater config addition, the same way adding a new chapter does: `<TopicName>/Case-Studies/<project-name>/notes` → `Templates/New-Case-Study-Note.md` in `.obsidian/plugins/templater-obsidian/data.json` → `folder_templates`.

## Standalone note types

These live in their own unnumbered folders inside each topic, are not scoped to any chapter, and each has its own Dataview-powered MOC index note (mirroring the `Reference` chapter's pattern, scoped to that topic via `FROM "<TopicName>"`):

| Folder | Template | Tag | For |
| --- | --- | --- | --- |
| `Cheatsheets/` | `New-Cheatsheet.md` | `cheatsheet` | quick-lookup syntax/commands, no explanation |
| `Tools/` | `New-Tool-Note.md` | `tool` | a specific tool's install/commands/gotchas |
| `Reading-Notes/` | `New-Reading-Note.md` | `reading-note` | books, courses, papers, RFCs |
| `Projects/` | `New-Project-Note.md` | `project` | personal coding projects |

Adding a genuinely new standalone note type follows the same shape: a folder inside each topic that wants it, a template in `Templates/`, a `folder_templates` entry per topic, an entry in `_Topic-Skeleton/` so future topics get it too, and a Dataview MOC index note linked from the topic's home note.

## Writing conventions

- **Language: English**, throughout — content, note titles, folder names, frontmatter, comments. (Adjust this if a given vault is meant to be read in another language — it's a per-vault choice, not a hard constraint of the template itself.)
- **No meta-commentary about note-taking process.** Content reads as normal authored documentation; don't add asides about how or when a note was written.
- **Links: bare Obsidian wikilinks**, e.g. `[[SomeConcept]]` or `[[SomeConcept|a nicer label]]` — never prefix them with a relative path (`[[../01-Chapter/SomeConcept]]`). See "Vault-wide filename uniqueness" above for what this requires of topic-level index notes. GitHub rendering of these links is _not_ a design goal — the vault is meant to be read in Obsidian.
- **Diagrams**: use Mermaid fenced code blocks (`classDiagram`, `graph`, `sequenceDiagram`, `flowchart`) — rendered natively by Obsidian and, incidentally, by GitHub too.
- **Callouts**: use standard Obsidian callouts (`> [!info]`, `> [!tip]`, `> [!warning]`, `> [!note]`, `> [!todo]`) for asides, not custom formatting.
- **No manual hard-wrapping inside a paragraph.** Write each paragraph as a single unbroken line (or run it through a markdown formatter with `proseWrap: never` before saving) and let Obsidian/your editor soft-wrap it visually. This vault's Obsidian setup renders every line break in the source as a visible line break rather than folding it into a space — a hand-wrapped paragraph (typing a newline every ~90 characters) shows up as a run of awkward, mid-sentence line breaks instead of a normal paragraph. This is a mistake worth double-checking after writing or editing any note: reread the raw file (not just the rendered preview) and confirm each paragraph is one line. Exceptions that must stay one-item-per-physical-line regardless: `#flashcards` `Question::Answer` entries (the Spaced Repetition plugin parses them line by line) and callout bodies that intentionally use multiple `>`-prefixed lines.

## Frontmatter conventions

| Note type | Tags | Notable frontmatter fields |
| --- | --- | --- |
| Topic home note | `moc`, `topic` | `aliases` |
| Chapter concept note | `fundamentals` | `aliases` |
| Example | `example` | — |
| Reference entry | `reference`, `reference-entry` | `category` |
| Real-world snippet | `snippet` (+ `placeholder` for demo/non-real ones) | `project`, `source`, `version`, `source_path`, `date_added`, `license_note` |
| Case study overview | `case-study` (+ `placeholder` for the demo one) | `project`, `source`, `version`, `obtained_via`, `tools_used`, `date_started`, `status`, `license_note` |
| Case study analysis note | `case-study-note` (+ `placeholder` for the demo one) | `case_study`, `created` |
| Cheatsheet | `cheatsheet` | `subject` |
| Tool note | `tool` | `tool_name`, `homepage`, `version` |
| Reading note | `reading-note` | `title`, `author`, `type`, `status`, `started`, `finished` |
| Project note | `project` | `repo`, `status`, `started` |
| Topic/chapter/case-study index note | `moc` | — |

## Chapter note structure

A chapter's main concept note (`ChapterName.md`) generally includes, in this order: a short intro, the core explanation with syntax blocks and tables, a fully worked example, a "More examples" list linking to `examples/` (and `snippets/` if populated), a "See also" list linking to other chapters, a "References" link to that topic's `Bibliography`, and a closing `## Flashcards` section tagged `#flashcards` with 2-4 `Question::Answer` pairs for the Spaced Repetition plugin.

## Templates

Every new note should be created from `Templates/`:

- `New-Topic.md` — a **brand-new** topic: prompts for a name and creates the topic's home note (see "Adding a new topic" above). Invoke it directly via Templater's "Create new note from template" command, not folder-scoped.
- `New-Chapter.md` — a **brand-new** chapter within an existing topic: prompts for topic/number/ name and creates the folder + concept note together (see "Adding a new chapter" above). Also invoked directly, not folder-scoped.
- `New-Concept.md` — the concept note's body only, for when the chapter folder already exists (this is what `folder_templates` points existing chapters at)
- `New-Example.md` — a new note in some chapter's `examples/`
- `New-Reference-Entry.md` — a new entry in a topic's `Reference` chapter
- `New-Snippet.md` — a new note in some chapter's `snippets/<project>/`
- `New-Case-Study.md` — a new project's overview note in a topic's `Case-Studies/<project>/`
- `New-Case-Study-Note.md` — a new analysis note in some case study's `notes/`
- `New-Cheatsheet.md` — a new note in a topic's `Cheatsheets/`
- `New-Tool-Note.md` — a new note in a topic's `Tools/`
- `New-Reading-Note.md` — a new note in a topic's `Reading-Notes/`
- `New-Project-Note.md` — a new note in a topic's `Projects/`

Templater's `folder_templates` config (`.obsidian/plugins/templater-obsidian/data.json`) maps every existing folder to the right template — populated per topic as each one is scaffolded (see "Adding a new topic") — so creating a note in the right place auto-suggests the right starting content. `New-Topic.md` and `New-Chapter.md` are deliberately _not_ in that mapping — they only make sense for a folder that doesn't exist yet.

## Plugins in use

Use community plugins where they add real functionality — don't hesitate to configure a new one if it removes manual, repetitive work. Currently: **Templater** (note scaffolding), **Dataview** (self-updating listings in every topic's `Reference` chapter and standalone note-type indices), and **Spaced Repetition** (`#flashcards` review decks). All three are listed in `.obsidian/community-plugins.json`; a user just needs to install them from Obsidian's Community Plugins browser.
