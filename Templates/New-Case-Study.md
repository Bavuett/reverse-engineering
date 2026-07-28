<%*
const topicSegment = tp.file.folder(true).split("/")[1];
-%>
---
tags: [case-study]
project: ""
source: ""
version: ""
obtained_via: ""
tools_used: ""
date_started: <% tp.date.now("YYYY-MM-DD") %>
status: "in-progress"
license_note: "Personal study/research purposes only. Only import the fragments you actually need, keeping their original file/module structure; check the project's license and ToS before sharing publicly."
---

# <% tp.file.title %>

## Overview

What this project is, why it's worth analyzing, and what you're hoping to learn or verify.

## Source layout

Which files/modules were imported into `source/` and why, and how they were obtained.

## Findings

Links into this case study's `notes/` folder, added as you go — or just rely on the Dataview
query in [[<% topicSegment %>-Case-Studies|Case Studies]] to see them all automatically.

-

## See also

- [[<% topicSegment %>-Case-Studies|Case Studies]]
