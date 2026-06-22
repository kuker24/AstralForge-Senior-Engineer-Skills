---
name: pptx
description: Read, create, edit, combine, inspect, and validate PowerPoint .pptx presentations and slide decks.
---

# PowerPoint Deck Workflows

Use this skill whenever a `.pptx` file is an input or output, including creating slide decks, editing existing presentations, extracting slide text, updating templates, combining decks, adding speaker notes, or checking slide layout. Presentation work requires attention to visual hierarchy, consistency, and file fidelity.

Do not use this skill for PDF, Word, spreadsheet, or web-page deliverables unless a slide deck is also involved. If the task is only to summarize content from a slide deck into prose, still use this skill to inspect the `.pptx` accurately before writing the summary.

## Workflow

1. Identify the deck goal, audience, slide count, template constraints, and required output format.
2. Preserve the original deck before modifying it.
3. Extract text, notes, layouts, and embedded media as needed.
4. Make edits consistently across titles, spacing, typography, colors, and slide masters.
5. Validate slide count, broken media, overflow, and speaker notes.
6. Provide a change summary and any manual review items.

## Output Expectations

Return the edited or generated file path, slide count, key changes, and validation notes. For generated decks, include an outline and speaker note guidance when useful.

## Quality Notes

Do not invent data for charts. Avoid leaking private deck content in logs. Keep temporary exports ignored unless they are final deliverables.
