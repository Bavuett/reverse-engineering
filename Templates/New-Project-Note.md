<%*
const topicSegment = tp.file.folder(true).split("/")[1];
-%>
---
tags: [project]
repo: ""
status: "active"
started: <% tp.date.now("YYYY-MM-DD") %>
---

# <% tp.file.title %>

## Goal

What you're building and why, and which concepts you're applying/practicing.

## Decisions

Notable design/implementation choices and the reasoning behind them.

-

## Log

- **<% tp.date.now("YYYY-MM-DD") %>** —

## Next steps

-

## See also

- [[<% topicSegment %>]]
