<%*
const topicFolder = await tp.system.prompt("Topic this chapter belongs to — the exact existing top-level folder, e.g. 02-ARM64-Android", "", true);
const topicName = topicFolder.replace(/^\d+-/, "");
const chapterNumber = await tp.system.prompt("Chapter number (new chapters go right before this topic's Reference chapter, which then gets renumbered)", "02", true);
const chapterName = await tp.system.prompt("Chapter name — a single PascalCase word, e.g. Ownership, BufferOverflows", "", true);
const folderName = topicFolder + "/" + chapterNumber + "-" + chapterName;
await tp.file.move(folderName + "/" + chapterName);
-%>
---
tags: [fundamentals]
aliases: []
created: <% tp.date.now("YYYY-MM-DD") %>
---

# <% tp.file.title %>

## In short

## Explanation

## Worked example

```

```

## More examples

-

## See also

-

## References

- [[<% topicName %>-Bibliography|Bibliography]]

## Flashcards
#flashcards


> [!todo] Finish setting up this chapter (see `CLAUDE.md` → "Adding a new chapter")
> This template just created `<% folderName %>/<% tp.file.title %>.md` for you. Still to do by hand:
> - [ ] Add `<% chapterNumber %>-<% chapterName %>` to the chapter list and Mermaid diagram in this
>   topic's home note (`<% topicFolder %>/<% topicName %>.md`)
> - [ ] If `<% chapterNumber %>` was already taken by this topic's Reference chapter, rename that
>   folder to the next free number, fix up its own internal `0X-` references, and update its
>   `folder_templates` path in `.obsidian/plugins/templater-obsidian/data.json`
> - [ ] Add three `folder_templates` entries to `.obsidian/plugins/templater-obsidian/data.json`:
>   `<% folderName %>` → `Templates/New-Concept.md`, `<% folderName %>/examples` →
>   `Templates/New-Example.md`, `<% folderName %>/snippets` → `Templates/New-Snippet.md`
> - [ ] Delete this reminder block once everything above is done
