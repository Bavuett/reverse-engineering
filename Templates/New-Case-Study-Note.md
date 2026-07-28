<%*
const topicSegment = tp.file.folder(true).split("/")[1];
-%>
---
tags: [case-study-note]
case_study: ""
created: <% tp.date.now("YYYY-MM-DD") %>
---

# <% tp.file.title %>

## Question / goal

What are you trying to figure out in this note?

## Relevant source

Wikilinks to the specific file(s) in this case study's `source/` folder, e.g. `[[SomeFile]]`.

-

## Excerpt

```

```

## Analysis

## Related concepts

Links back to the relevant chapter(s), e.g. `[[SomeConcept]]`.

-

## Open questions / next steps

## See also

- [[<% topicSegment %>-Case-Studies|Case Studies]]
