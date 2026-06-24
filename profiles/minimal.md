# AstralForge Token Profile: minimal

Default profile for Pi Code / Pi Agent.

## Purpose

Handle normal chat, small edits, and direct questions with the least context and tool usage needed.

## Active Tools

- Built-in file read/edit/shell tools only when needed.
- Context7 CLI + Skills only when a library, framework, SDK, API, cloud service, CLI, or exact version is explicitly relevant.

## Inactive Tools

- Context7 MCP is off by default.
- Serena is inactive by default.
- Repomix is inactive by default.
- Browser/GitHub/random marketplace MCP tools are inactive by default.

## Expand Context When

- The user asks for a code change and the target files are not known.
- A failing command identifies a specific file, symbol, or config.
- A claim needs direct evidence from a repo file or report.

## Summarize When

- Command output is long or noisy.
- More than a few files are read.
- A log is useful as evidence but not useful to paste fully.

## Context7 Rule

Call Context7 only for library/API/version-specific work. If a library ID is already known, use it directly and do not resolve again.

## Serena Rule

Do not activate Serena in this profile. Switch to `coding` or `repo-review` if semantic symbol/reference search is needed.

## Repomix Rule

Do not run Repomix in this profile. Switch to `repo-review` for token tree or compressed context generation.

## Cleanup Behavior

- Do not delete files.
- Do not run local Pi cleanup except dry-run when explicitly requested.
- Keep raw generated outputs ignored.

## Security Boundary

- Never print secrets, Authorization headers, cookies, private keys, `.env`, or private config.
- No MCP servers are enabled by default.
- No cloud login or credentialed setup.

## Final Answer Discipline

Answer concisely with files changed, commands run, verification status, and blockers. Do not include full logs unless requested.
