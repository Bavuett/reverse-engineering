---
tags: [moc]
aliases: ["Dalvik-Bytecode Case Studies"]
---

# Dalvik-Bytecode · Case Studies

Full, real-world investigations of one whole app at a time — as opposed to a chapter's `snippets/`, which is for tiny fragments illustrating exactly one concept. See `CLAUDE.md` for the full distinction and the expected folder shape.

```dataview
TABLE project AS "App", status AS "Status", date_started AS "Started"
FROM "Dalvik-Bytecode" AND #case-study
SORT date_started DESC
```

## Findings across all case studies

```dataview
TABLE case_study AS "Case study", created AS "Created"
FROM "Dalvik-Bytecode" AND #case-study-note
SORT created DESC
```

> [!info] Requires Dataview
>
> Both tables need the **Dataview** community plugin — see the setup notes in [[Home]].

## Starting a new case study

1. Create `Dalvik-Bytecode/Case-Studies/<app-name>/` and use the [[New-Case-Study]] template for its overview note.
2. Import only the files you actually need into `Dalvik-Bytecode/Case-Studies/<app-name>/source/`, keeping their original class/package layout.
3. Add analysis notes under `Dalvik-Bytecode/Case-Studies/<app-name>/notes/` using the [[New-Case-Study-Note]] template.
4. Add a `folder_templates` entry mapping `Dalvik-Bytecode/Case-Studies/<app-name>/notes` → `Templates/New-Case-Study-Note.md` in `.obsidian/plugins/templater-obsidian/data.json`.

See `_Topic-Skeleton/Case-Studies/demo-project-case-study/` (not copied into real topics — it's reference-only documentation) for a fully worked, fictional example of the expected shape.

## See also

- [[Dalvik-Bytecode-Reference|Reference]]
