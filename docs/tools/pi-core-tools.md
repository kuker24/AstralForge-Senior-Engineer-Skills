# Pi Core Tools Installation and Verification

This runbook applies the AstralForge v3.1.0 Pi core-tool layer to a local Pi Code / Pi Agent home. It preserves the `v3.0.0` release/tag: `v3.0.0` remains at commit `17ea37e`; final evidence cleanup after release remains on `main` after that tag. Do not rewrite the tag or release.

## Pi Home Detection

Priority order:

1. `--pi-home <path>` argument.
2. `PI_HOME` environment variable.
3. `~/.pi/agent`.

Verification mode never creates a missing Pi home. Install mode may create it only after the command is explicit and not a dry-run.

## Backup Policy

Before any local write, create:

```txt
<pi-home>/.astralforge-backups/<timestamp>/
```

Back up existing items when present:

- `skills/`
- `extensions/`
- `settings.json`
- `models.json`
- `presets.json`
- `AGENTS.md`
- `profiles/`
- `prompts/`

Missing files are recorded in the install report. Unknown user files are not deleted.

## Install / Dry-Run

Start with dry-run:

```bash
npm run pi:install-core-tools -- --dry-run
```

Actual install, only after reviewing dry-run output:

```bash
npm run pi:install-core-tools -- --force
```

The installer syncs:

- `skills/` to `<pi-home>/skills/`
- `profiles/` to `<pi-home>/profiles/astralforge/`

It writes `<pi-home>/.astralforge-install.json` with repo path, install time, git commit, skill/profile counts, backup path, and tool status. It must never print secrets.

## Context7 CLI + Skills

Default: CLI + Skills mode. MCP is not enabled by default.

Verification:

```bash
npx ctx7 --help
```

Setup when network and interactive setup are allowed:

```bash
npx ctx7 setup
```

Use examples:

```bash
ctx7 library next.js "app router caching"
ctx7 docs /vercel/next.js "route handlers"
```

If setup requires interaction in a non-interactive environment, mark `PARTIAL VERIFIED` and run the command manually later.

## Serena MCP

Do not install Serena from random MCP/plugin marketplaces. Use the official Quick Start path with `uv`.

Verify `uv`:

```bash
uv --version
```

Install:

```bash
uv tool install -p 3.13 serena-agent
```

Verify:

```bash
serena --help
serena init
```

Serena is not active in the minimal profile. Use it for coding and repo-review profiles when semantic symbol/reference search reduces context reads.

## Repomix CLI

Verify:

```bash
npx repomix@latest --version
```

Token report:

```bash
npx repomix@latest --token-count-tree 1000
```

Compressed context, only for larger audits:

```bash
npx repomix@latest --compress --token-budget <number>
```

Do not commit raw `repomix-output.*`; commit compact summaries only under `reports/tool-evidence/`.

## Verify Local Pi State

```bash
npm run pi:verify-core-tools
```

Optional no-network verification:

```bash
npm run pi:verify-core-tools -- --skip-network
```

The verifier checks Pi home, skill count, profiles, Context7 command/fallback, Serena availability/init status, Repomix command, generated-output hygiene, and stale duplicate AstralForge skills.

## Cleanup Local Pi

Always dry-run first:

```bash
npm run pi:clean-local -- --dry-run
```

Actual cleanup quarantines uncertain files into the backup path instead of permanently deleting them:

```bash
npm run pi:clean-local -- --force
```

Cleanup may quarantine only:

- AstralForge stale duplicate skill directories not present in the current manifest.
- Generated outputs such as `repomix-output.*`, `semgrep-results.json`, `osv-results.json`, `gitleaks-report.json`, `gitleaks-dir-report.json`, `playwright-report/`, `test-results/`, `coverage/`, `.stryker-tmp/`, and `mutation-report/`.

Never delete `.env`, API keys, private notes, user custom skills, unknown manually-created files, or user-specific configuration.

## Rollback

Restore from the backup created before installation:

```bash
rsync -a <pi-home>/.astralforge-backups/<timestamp>/skills/ <pi-home>/skills/
rsync -a <pi-home>/.astralforge-backups/<timestamp>/profiles/ <pi-home>/profiles/
```

If `rsync` is unavailable, copy the backed-up directories manually. Review reports before rollback because user-created files outside backed-up paths are intentionally untouched.

## Troubleshooting

| Symptom | Classification | Next step |
|---------|----------------|-----------|
| `npx ctx7 --help` cannot reach registry | `BLOCKED_BY_NETWORK` | Retry with network or install CLI manually. |
| `npx ctx7 setup` asks questions | `BLOCKED_BY_INTERACTIVE_SETUP` | Run manually in an interactive shell. |
| `uv` missing | `BLOCKED_BY_MISSING_DEPENDENCY` | Install `uv`, then run Serena install command. |
| `serena init` writes project config | Manual review | Keep only if intentional for this repo. |
| Permission denied writing Pi home | `BLOCKED_BY_PERMISSION` | Re-run with a writable `--pi-home`. |
| Repomix output is large | Token hygiene | Keep raw output ignored; commit only compact summary. |
