# AstralForge Token Profile: docs-research

Profile for documentation-heavy work involving libraries, SDKs, frameworks, APIs, CLIs, or cloud services.

## Purpose

Use current documentation on demand while avoiding stale API examples and broad context dumps.

## Active Tools

- Context7 CLI + Skills for current docs and examples.
- Built-in file tools for local docs and reports.

## Inactive Tools

- Serena is off unless codebase reading or symbol/reference navigation becomes necessary.
- Repomix is off unless a repository snapshot is required.
- Context7 MCP is off unless the user explicitly chooses MCP mode.
- Non-core MCP servers are off.

## Expand Context When

- A docs answer depends on project version/configuration.
- Local code conflicts with external documentation.
- A migration guide or release note affects implementation.

## Summarize When

- External docs are long.
- Multiple libraries are compared.
- A report needs citations/evidence without full pasted docs.

## Context7 Rule

Use Context7 for named libraries/frameworks/SDKs/APIs/cloud services/versions. If the library ID is known, query it directly, for example:

```bash
ctx7 docs /vercel/next.js "route handlers"
```

Do not call Context7 for general knowledge or non-API reasoning.

## Serena Rule

Keep Serena off unless the docs task requires reading repository code structure.

## Repomix Rule

Keep Repomix off unless a repository-level context snapshot is explicitly needed.

## Cleanup Behavior

- Do not generate large context files unless requested.
- Keep raw outputs ignored.
- Commit only compact evidence summaries.

## Security Boundary

- Do not include secrets, private customer data, Authorization headers, cookies, or `.env` values in docs.
- Do not promote unverified claims to `Verified`.

## Final Answer Discipline

Cite local files or command evidence when available, summarize docs conclusions, and state if verification is partial or blocked.
