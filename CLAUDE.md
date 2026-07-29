# Project structure guide

This repository is a multi-topic Obsidian vault of public study notes: reverse engineering, a programming language, a CS topic, ... — one self-contained **topic** per subject, each its own top-level folder at the repository root, all sharing the same structure and tooling. Every topic is organized purely as a set of **topic-centric chapters** — nothing else lives inside a topic folder. Case studies, cheatsheets, tool notes, reading notes, and personal project notes are **not** topic-scoped: a real investigation or a general-purpose tool rarely respects topic boundaries, so those five note types live once, shared across the whole vault, at the repository root (see "Standalone note types" below). Follow this convention whenever you add, move, or rename content — do not reintroduce a flat or type-grouped layout, do not nest topics under a wrapper folder, and do not move a standalone note type back inside a topic folder.

Topic folders sit directly at the repository root, each prefixed with a two-digit number in the order it was added (`01-Dalvik-Bytecode/`, `02-ARM64-Android/`, ...) — the number exists purely so topic folders are visually distinguishable at a glance from the always-unnumbered shared folders below; it plays no role in linking (wikilinks resolve by filename, and a topic's own home note stays bare-named, e.g. `02-ARM64-Android/ARM64-Android.md`). Reserved, non-topic top-level folders: `Templates/` (Templater templates, used vault-wide), `_Topic-Skeleton/` (copy-source for scaffolding a new topic's `01-Reference/`), `assets/` (non-note files — scans, screenshots, exported diagrams — shared vault-wide, not part of the Obsidian note graph), and the five shared standalone-note-type folders `Case-Studies/`, `Cheatsheets/`, `Tools/`, `Reading-Notes/`, `Projects/`. Don't name a topic after any of these, and don't number them — the number prefix is exclusively a topic-folder marker.

## Vault-wide filename uniqueness

Obsidian resolves bare `[[wikilinks]]` by filename across the **entire vault**, not per-folder or per-topic — this vault relies on that for portability (links keep working after files are moved, and stay readable without path noise). With more than one topic in the vault, this has one consequence you must respect:

- **Every filename must be unique vault-wide**, not just unique within its topic.
- The notes every topic has exactly one of — the topic's home note and its `Reference`, `Glossary`, and `Bibliography` — are **topic-prefixed** for exactly this reason (`Rust-Reference.md`, not `Reference.md`). Templates that link to them do so dynamically — see "Topic-scoped links in templates" below — so you never have to hardcode the prefix by hand.
- The five shared standalone-note-type index notes (`Case-Studies.md`, `Cheatsheets.md`, `Tools.md`, `Reading-Notes.md`, `Projects.md`) exist exactly once for the whole vault, so they're **not** prefixed at all — they're bare-named after their own folder, the same way the vault's `Home.md` is.
- Chapter/example/reference-entry/snippet/case-study/cheatsheet/tool/reading-note/project notes stay bare-named (`Classes.md`, not `Rust-Classes.md`) since a specific concept/project/tool name is usually unique on its own. If two would otherwise produce the same filename (e.g. two topics both have a chapter called "Basics", or two case studies are both about a tool called "Setup"), rename one to disambiguate — don't rely on folder location to break the tie.

## Topic-scoped links in templates

Every chapter-scoped template in `Templates/` (concepts, examples, reference entries, snippets) computes which topic it belongs to from its own folder path and uses that to link to the right `Reference`/`Bibliography` note, instead of a hardcoded name:

```
<%*
const topicSegment = tp.file.folder(true).split("/")[0].replace(/^\d+-/, "");
-%>
```

`tp.file.folder(true)` returns the note's folder relative to the vault root (e.g. `02-Rust/02-Ownership`); index `[0]` is the topic's numbered folder (e.g. `02-Rust`), and `.replace(/^\d+-/, "")` strips the number prefix to recover the bare topic name (`Rust`) that the topic's home/Reference/Bibliography notes are actually named after. `New-Chapter.md` and `New-Topic.md` already know the topic name from their own prompts, so they use that directly instead of deriving it — but they still need the same `\d+-` handling wherever they build a folder *path* (see `Templates/New-Chapter.md`'s `topicFolder`/`topicName` split). Keep this pattern when adding a new chapter-scoped template.

Case study, cheatsheet, tool-note, reading-note, and project-note templates do **not** derive a topic this way, since those five note types aren't scoped to any one topic (see "Standalone note types" below) — they carry an explicit `topics: []` frontmatter list instead, filled in by hand.

## Topics live at the repository root, scaffolded from `_Topic-Skeleton/`

Each subject is its own top-level folder, numbered by the order it was added (`01-Dalvik-Bytecode/`, `02-ARM64-Android/`, `03-Frida-Dynamic-Instrumentation/`, ...), a direct sibling of `Templates/`, `_Topic-Skeleton/`, `assets/`, and the five shared standalone-note-type folders — there's no `Topics/` wrapper folder. This template ships with zero topics. `_Topic-Skeleton/` is not a topic itself; it's a literal copy-source for the one part of a new topic that isn't safe to script blindly, using the literal placeholder text `TOPIC` in filenames, titles, aliases, Dataview `FROM` clauses, and wikilinks:

```
_Topic-Skeleton/
└── 01-Reference/
    ├── TOPIC-Reference.md
    ├── TOPIC-Glossary.md
    └── TOPIC-Bibliography.md
```

Case studies, cheatsheets, tool notes, reading notes, and project notes are **not** part of a new topic's scaffolding at all — they live once, shared vault-wide, in the root `Case-Studies/`, `Cheatsheets/`, `Tools/`, `Reading-Notes/`, and `Projects/` folders (already populated the first time any topic needed them). A brand-new topic simply links into those from its "Relevant topics & background" mentions on the other side (see "Standalone note types" below) — nothing to copy or scaffold per topic.

## Adding a new topic

1. Run Templater's **"Create new note from template"** command and pick `Templates/New-Topic.md`. It prompts for a topic name and the next free two-digit topic number, and uses `tp.file.move` to create `<NN>-<TopicName>/<TopicName>.md` — the topic's home note, at the repository root — pre-filled with a map of the topic's sections and a `[!todo]` checklist for the rest, because it touches multiple files and isn't safe to script blindly:
2. Copy `01-Reference/` from `_Topic-Skeleton/` into `<NN>-<TopicName>/`.
3. Rename every `TOPIC`-prefixed file you copied to the real topic name, e.g. `TOPIC-Reference.md` → `<TopicName>-Reference.md`.
4. Find-and-replace the `TOPIC` placeholder inside those files' content (titles, aliases, Dataview `FROM` clauses, wikilinks).
5. Add this topic's `folder_templates` entry to `.obsidian/plugins/templater-obsidian/data.json` → `folder_templates`:

   ```json
   { "folder": "<NN>-<TopicName>/01-Reference", "template": "Templates/New-Reference-Entry.md" }
   ```

6. Add the topic to the table in `Home.md` and `README.md`.

(Without Templater — e.g. using only the core "Templates" plugin — create `<NN>-<TopicName>/<TopicName>.md` by hand instead, then apply the rest of the same steps.)

## Chapter layout

Within a topic, every fundamental concept is a numbered directory (`01-ChapterName`, `02-ChapterName`, ...) — a second, independent numbering from the topic folder's own number prefix. A brand-new topic starts with zero concept chapters — add the first one with [[New-Chapter]]. Each chapter directory follows the same internal shape:

```
<NN-TopicName>/0X-ChapterName/
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

A topic's `0N-Reference/` is not a chapter about a single concept — it holds glossary, bibliography, and quick-reference tables, plus **Dataview queries that aggregate content from every chapter in that topic** (all reference-entry notes, all examples, all snippets, regardless of which chapter folder they physically live in — scoped to the topic via `FROM "<NN-TopicName>"`, the topic's numbered folder). When adding a new reference entry, example, or snippet, you never need to manually edit `<TopicName>-Reference.md`'s listings — they update themselves as long as the new note carries the right tag (`#reference-entry`, `#example`, `#snippet`).

Each topic's `Reference` chapter is always the **highest-numbered** chapter folder within that topic. Its own number moves up every time a new concept chapter is added right before it.

## Adding a new chapter

Run Templater's **"Create new note from template"** command (not folder-scoped, since the target folder doesn't exist yet) and pick `Templates/New-Chapter.md`. It prompts for the topic's exact existing numbered folder (e.g. `02-ARM64-Android`), a chapter number, and a chapter name, then uses `tp.file.move` to create `<NN-TopicName>/0N-ChapterName/` and place `ChapterName.md` inside it in one step (Templater creates any missing intermediate folders for you), pre-filled with the same body as `New-Concept.md`. It finishes by inserting a `[!todo]` checklist for the steps that still need a human, because they touch other files and aren't safe to script blindly:

1. Add the chapter to the chapter list and Mermaid diagram in the topic's home note (`<NN-TopicName>/<TopicName>.md`).
2. If the number you picked was already taken by this topic's `Reference` chapter, rename that folder to the next free number, fix up its own internal `0X-` references, and update its `folder_templates` path in `.obsidian/plugins/templater-obsidian/data.json`.
3. Add three entries to `.obsidian/plugins/templater-obsidian/data.json` → `folder_templates`: the new chapter root (→ `Templates/New-Concept.md`), its `examples/` (→ `Templates/New-Example.md`), and its `snippets/` (→ `Templates/New-Snippet.md`) — copy the pattern already used for that topic's `Reference` chapter.

(Without Templater — e.g. using only the core "Templates" plugin — create the chapter folder and its concept note by hand instead, then apply `Templates/New-Concept.md` for the body.)

## Case studies live in the vault-wide `Case-Studies/`, not inside any one topic

`Case-Studies/` is a root-level folder, shared across every topic, for **full, real-world investigation of one whole project at a time**, as opposed to a chapter's `snippets/`, which is for tiny fragments illustrating exactly one concept. It used to live inside each topic (`<TopicName>/Case-Studies/`) but moved to the root because a real project rarely respects topic boundaries — the same app gets investigated both statically and dynamically, or draws on more than one topic's chapters, and splitting or duplicating it per topic just hid that it was one investigation. Don't confuse a case study with a chapter's `snippets/`:

|  | `0X-Chapter/snippets/<project>/` | `Case-Studies/<project>/` |
| --- | --- | --- |
| Scope | one concept | one whole project, possibly spanning multiple topics |
| Content | a few lines, minimal | as much imported source as the investigation needs |
| Notes | tied to that chapter | open-ended, cross-chapter, cross-topic |

Each case study follows this shape:

```
Case-Studies/<project-name>/
├── <Project Name>.md    <- overview note (from Templates/New-Case-Study.md)
├── source/               <- imported files, real layout preserved exactly
│   └── ...
└── notes/                <- analysis notes, freely named (from Templates/New-Case-Study-Note.md)
```

- Only import the files actually needed for the investigation, not a wholesale dump — but keep their original directory layout under `source/` so it stays legible and comparable to the real project. `source/` files are pasted in from whatever tool produced them (decompiler, disassembler, source drop, ...); there's no template for them, since they're extracted/imported code, not authored notes.
- The overview note's `topics` frontmatter field lists every topic the investigation actually draws on (e.g. `["ARM64-Android", "Frida-Dynamic-Instrumentation"]`), and its "Relevant topics & background" section links the specific chapter concepts worth reviewing first — this is what replaces living inside a topic folder: the connection is made explicitly, by hand, on the project's own home note, in both directions it matters (which topics feed this project, not the reverse).
- **Narrate the investigation, not just the findings.** A case-study note should read like an account of how the finding was actually reached — what was tried first, what failed and why, which plausible-looking leads turned out to be dead ends, what signal caused the real pivot, and how a single confirmed instance was generalized into a search for sibling instances — not only the polished final answer. See `Templates/New-Case-Study-Note.md`'s "How this was found" section, and `Case-Studies/tua/notes/Anti-Tampering-Pattern-Workflow.md` for a worked example of this style.
- Analysis notes reference a specific file with a bare wikilink (Obsidian can't deep-link to a line inside a non-Markdown file) and quote the relevant excerpt inline as a fenced code block — see `Case-Studies/demo-project-case-study/notes/Demo-Finding.md` for a worked (fabricated) example.
- Enabling Obsidian's _Settings → Files & Links → Detect all file extensions_ is recommended so source files of arbitrary extensions resolve as clickable, linkable notes; this isn't auto-configured here (not confident enough in the exact `app.json` key across Obsidian versions to write it silently), so it stays a manual one-time step.
- Starting a new case study needs one manual Templater config addition, the same way adding a new chapter does: `Case-Studies/<project-name>/notes` → `Templates/New-Case-Study-Note.md` in `.obsidian/plugins/templater-obsidian/data.json` → `folder_templates`.
- `Case-Studies/demo-project-case-study/` is fabricated, fictional, and tagged `placeholder` — it lives permanently at the root of `Case-Studies/` (not copied per topic anymore, since there's only one `Case-Studies/` folder now) to show the expected shape without cluttering the real listing; it's excluded from [[Case-Studies]]'s Dataview tables by that tag.

## Standalone note types

Case studies, cheatsheets, tool notes, reading notes, and project notes all live once, shared across the whole vault, in their own root-level folder — **not** inside any topic — each with its own Dataview-powered MOC index note:

| Folder | Template | Tag | For |
| --- | --- | --- | --- |
| `Case-Studies/` | `New-Case-Study.md` / `New-Case-Study-Note.md` | `case-study` / `case-study-note` | full real-project investigations (see above) |
| `Cheatsheets/` | `New-Cheatsheet.md` | `cheatsheet` | quick-lookup syntax/commands, no explanation |
| `Tools/` | `New-Tool-Note.md` | `tool` | a specific tool's install/commands/gotchas |
| `Reading-Notes/` | `New-Reading-Note.md` | `reading-note` | books, courses, papers, RFCs |
| `Projects/` | `New-Project-Note.md` | `project` | personal coding projects, lighter than a case study |

Every note in these five folders carries a `topics: []` frontmatter field listing the topic(s) it applies to (by bare topic name, e.g. `"ARM64-Android"`, not the numbered folder) — this is what a topic-scoped folder location used to give you for free, made explicit now that the note doesn't live inside any one topic. Each MOC index note's Dataview query is vault-wide (no `FROM "<folder>"` scoping — the tag alone is enough, since these note types only exist in their own root folder) and includes a `topics` column so you can see at a glance what each entry is about.

Adding a genuinely new standalone note type follows the same shape: one root-level folder (shared, not per-topic), a template in `Templates/` with a `topics: []` field, a `folder_templates` entry pointing at that root folder, and a Dataview MOC index note linked from `Home.md`.

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
| Case study overview | `case-study` (+ `placeholder` for the demo one) | `project`, `source`, `version`, `obtained_via`, `tools_used`, `topics`, `date_started`, `status`, `license_note` |
| Case study analysis note | `case-study-note` (+ `placeholder` for the demo one) | `case_study`, `created` |
| Cheatsheet | `cheatsheet` | `subject`, `topics` |
| Tool note | `tool` | `tool_name`, `homepage`, `version`, `topics` |
| Reading note | `reading-note` | `title`, `author`, `type`, `status`, `started`, `finished`, `topics` |
| Project note | `project` | `repo`, `topics`, `status`, `started` |
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
- `New-Case-Study.md` — a new project's overview note in the vault-wide `Case-Studies/<project>/`
- `New-Case-Study-Note.md` — a new analysis note in some case study's `notes/`
- `New-Cheatsheet.md` — a new note in the vault-wide `Cheatsheets/`
- `New-Tool-Note.md` — a new note in the vault-wide `Tools/`
- `New-Reading-Note.md` — a new note in the vault-wide `Reading-Notes/`
- `New-Project-Note.md` — a new note in the vault-wide `Projects/`

Templater's `folder_templates` config (`.obsidian/plugins/templater-obsidian/data.json`) maps every existing folder to the right template — populated per topic as each one is scaffolded (see "Adding a new topic") — so creating a note in the right place auto-suggests the right starting content. `New-Topic.md` and `New-Chapter.md` are deliberately _not_ in that mapping — they only make sense for a folder that doesn't exist yet.

## Plugins in use

Use community plugins where they add real functionality — don't hesitate to configure a new one if it removes manual, repetitive work. Currently: **Templater** (note scaffolding), **Dataview** (self-updating listings in every topic's `Reference` chapter and standalone note-type indices), and **Spaced Repetition** (`#flashcards` review decks). All three are listed in `.obsidian/community-plugins.json`; a user just needs to install them from Obsidian's Community Plugins browser.
