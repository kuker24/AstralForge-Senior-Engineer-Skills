---
name: pdf
description: Read, create, extract, inspect, and validate PDF files when rendering, layout, forms, or page fidelity matter.
---

# PDF Workflows

Use this skill when PDF files are an input or output and layout fidelity matters: extracting text with coordinates, reviewing rendered pages, filling forms, generating reports, validating page counts, inspecting tables, or checking visual defects. Prefer rendering pages for layout-sensitive tasks instead of relying only on raw text extraction.

Do not use this skill when the primary deliverable is a Word document, slide deck, spreadsheet, or simple Markdown summary. Route those tasks to the file-specific skill.

## Workflow

1. Identify whether the task needs text extraction, visual inspection, generation, form handling, splitting, merging, or annotation.
2. Preserve the original file and work on a copy when modifying PDFs.
3. Use extraction tools such as `pdfplumber` or `pypdf` for text and metadata.
4. Use rendering tools such as Poppler for visual QA when layout matters.
5. Generate new PDFs with a deterministic layout library and verify page dimensions, fonts, and overflow.
6. Summarize limitations such as scanned pages, OCR needs, missing fonts, or encrypted files.

## Output Expectations

Return paths to generated files, page counts, extraction method, and validation notes. If OCR is needed, state that clearly rather than pretending text extraction succeeded.

## Safety Notes

Do not upload PDFs to cloud services unless explicitly requested. Avoid exposing private document content in logs. Keep temporary outputs ignored unless the user requests final artifacts.
