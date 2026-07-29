---
tags: [moc]
aliases: ["Case Studies"]
---

# Case Studies

Full, real-world investigations of one whole project at a time — as opposed to a chapter's
`snippets/`, which is for tiny fragments illustrating exactly one concept. Shared across every
topic in this vault, rather than living inside one: a real project rarely respects topic
boundaries (the same app gets investigated statically and dynamically, or touches more than one
subject), so splitting or duplicating it per topic just hides that it's one investigation. See
`CLAUDE.md` for the full distinction and the expected folder shape.

```dataview
TABLE project AS "Project", topics AS "Topics", status AS "Status", date_started AS "Started"
FROM #case-study AND -#placeholder
SORT date_started DESC
```

## Findings across all case studies

```dataview
TABLE case_study AS "Case study", created AS "Created"
FROM #case-study-note AND -#placeholder
SORT created DESC
```

> [!info] Requires Dataview
> Both tables need the **Dataview** community plugin — see the setup notes in [[Home]].

## Starting a new case study

1. Create `Case-Studies/<project-name>/` and use the [[New-Case-Study]] template for its overview
   note.
2. Import only the files you actually need into `Case-Studies/<project-name>/source/`, keeping
   their original file/module layout.
3. Add analysis notes under `Case-Studies/<project-name>/notes/` using the
   [[New-Case-Study-Note]] template.
4. Add a `folder_templates` entry mapping `Case-Studies/<project-name>/notes` →
   `Templates/New-Case-Study-Note.md` in `.obsidian/plugins/templater-obsidian/data.json`.
5. Fill in the overview note's `topics` frontmatter and its "Relevant topics & background"
   section with every topic (and specific chapter concept) the investigation draws on — since the
   case study no longer lives inside a topic folder, this is what keeps it discoverable from the
   topic(s) it's actually about.

See `Case-Studies/demo-project-case-study/` (excluded from the tables above by its `#placeholder`
tag) for a fully worked, fictional example of the expected shape.

## See also

- [[Home]]
