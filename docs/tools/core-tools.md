# AstralForge Core Tools

AstralForge v3.1.0 adds a small Pi Code / Pi Agent core-tool layer focused on token efficiency, evidence-based documentation lookups, and safe semantic review. This phase does not rewrite the `v3.0.0` tag or GitHub Release.

## Why Only Context7, Serena, and Repomix

| Tool | Reason included | Default mode | Token impact |
|------|-----------------|--------------|--------------|
| Context7 CLI + Skills | Fetch current library/API/SDK/framework docs only when the task needs them. | Available on demand; MCP off by default. | Reduces stale API examples and avoids pasting large docs into chat. |
| Serena MCP | Provides semantic symbol overview, reference search, and precise edit support for coding/review profiles. | Installed/available; off in `minimal`. | Reduces full-file reads and broad repository scans. |
| Repomix CLI | Produces token-count reports and compressed repository context for large audits. | Manual/on-demand; off in `minimal`. | Identifies token-heavy folders and supports budgeted context snapshots. |

These are the only external core tools for this phase. They are local-first, can be verified with commands, and do not require default credentials.

## Non-Core Defaults

The following are intentionally **not** core defaults:

- Hermes is not a core default.
- Self-healing external agents are not a core default.
- Random marketplace MCP servers are not a core default.
- Playwright MCP is not a core default.
- GitHub MCP is not a core default.
- Browser automation MCP is not a core default.
- Video/audio/image production pipelines unrelated to repository QA.
- Cloud-login automation.
- Any tool that requires credentials by default.

They may be future considerations only after explicit scope, threat model, evidence, and opt-in activation.

## Modes

| Tool | Minimal | Coding | Repo Review | Docs Research |
|------|---------|--------|-------------|---------------|
| Context7 CLI + Skills | On demand only for library/API docs. | On demand for implementation docs. | On demand for dependency/API review. | Active for library/API/framework research. |
| Context7 MCP | Off. | Off unless user explicitly requests MCP mode. | Off unless user explicitly requests MCP mode. | Off unless user explicitly requests MCP mode. |
| Serena MCP | Off. | Active for symbol/reference/edit work. | Active for semantic repo review. | Off unless codebase reading is required. |
| Repomix CLI | Off. | Only token report/snapshot when context is too large. | Allowed for token-count tree and compressed audit context. | Off unless repository snapshot is required. |
| Skill Security Auditor | On demand. | On demand before risky skill/config changes. | Active. | On demand. |

Default profile: [`profiles/minimal.md`](../../profiles/minimal.md).

## When to Activate

- Activate Context7 when a task names a library, SDK, framework, API, CLI, cloud service, or exact version.
- Activate Serena when code structure, symbols, references, or precise edits are needed.
- Activate Repomix only for large repo reviews, token-budget reports, or compressed context snapshots.
- Activate the Skill Security Auditor before promoting new skills, provider configs, profiles, or installer behavior.

## When Not to Activate

- Do not call Context7 for general reasoning or non-library questions.
- Do not activate Serena for chat-only tasks or small known-file edits.
- Do not run Repomix for small tasks that can be answered from a few files.
- Do not enable MCP servers by default in the minimal profile.
- Do not commit raw large outputs such as `repomix-output.*`.

## Security Boundary

- Core tools must not print secrets, Authorization headers, cookies, private keys, or `.env` values.
- Provider credentials must come from environment variables only.
- Network-dependent setup can be `PARTIAL VERIFIED` or `BLOCKED`; do not fake success.
- Local Pi writes must start with a dry-run and must create a backup before changing files.
- StrykerJS remains manual-only and is not part of these core defaults.

## Verification Commands

| Tool | Command | Expected status vocabulary |
|------|---------|----------------------------|
| Context7 CLI + Skills | `npx ctx7 --help` | `Verified`, `Partial verified`, or `Blocked` |
| Context7 setup | `npx ctx7 setup` | Manual/interactive if setup cannot run non-interactively |
| Context7 library docs | `ctx7 library <name> <query>` | Use only when docs are needed |
| Context7 direct docs | `ctx7 docs /vercel/next.js <query>` | Skip resolving if library ID is already known |
| Serena install | `uv tool install -p 3.13 serena-agent` | Requires `uv`; otherwise blocked |
| Serena verify | `serena --help` and `serena init` | `Verified` only after command succeeds |
| Repomix verify | `npx repomix@latest --version` | `Verified` after version prints |
| Repomix token tree | `npx repomix@latest --token-count-tree 1000` | Write compact summary only |
| Repomix compress | `npx repomix@latest --compress --token-budget <number>` | Manual/on-demand for large audits |
| Skill Security Auditor | `npm run audit:skill-security` | Fails on HIGH/CRITICAL unless `--report-only` |

## Status Vocabulary

- **Verified**: command succeeded in the current environment and evidence was captured.
- **Supported**: scripts/docs exist, but live verification was not run for this environment.
- **Manual only**: available only when explicitly requested.
- **Partial verified**: some checks passed but a network, dependency, permission, or interactivity gap remains.
- **Blocked**: verification could not proceed because of a stated blocker.
- **Unverified**: no reliable command output or evidence exists yet.
