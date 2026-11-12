<%*
const topicSegment = tp.file.folder(true).split("/")[0].replace(/^\d+-/, "");
-%>
---
tags: [example]
level: 1
created: <% tp.date.now("YYYY-MM-DD") %>
---

# Example: <% tp.file.title %>

> [!info] Level 1 — basics
> One sentence on the single idea this example isolates. (For an example that combines ideas or shows a compiler idiom, use `level: 2` and "Level 2 — intermediate"; real code from an analysed app goes in `snippets/` as Level 3.)

## Goal

What this example demonstrates, and which chapter concept it belongs to (link back to the
chapter's main note, e.g. `[[SomeConcept]]`).

## Walkthrough

```

```

## Step by step

1.

## Diagram

```mermaid
graph TD
    A[Start] --> B[End]
```

## See also

-

## References

- [[<% topicSegment %>-Bibliography|Bibliography]]
