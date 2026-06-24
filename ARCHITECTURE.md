# Architecture

AstralForge Senior Engineer Skills is a local-first AI engineering skills package. The repository is intentionally polyglot because skill content, installer scripts, QA gates, and optional helper utilities have different jobs.

## Tech Stack

### Node.js / TypeScript (Core QA Toolchain)

All primary engineering validation gates run through Node.js/TypeScript and npm scripts:

- TypeScript typecheck: `npm run typecheck`
- Vitest unit and repository policy tests: `npm run test:unit`
- Vitest coverage: `npm run test:coverage`
- Playwright package smoke test: `npm run test:e2e`
- Knip dead-code/dependency report: `npx knip`
- Source skill verifier: `npm run verify:skills`
- Substantive skill audit: `npm run audit:skills`

The GitHub Actions CI workflow in `.github/workflows/ci.yml` runs these checks in separate jobs and uploads coverage, Playwright, Knip, and skill-audit artifacts where relevant.

### Python (Tooling / Build / Skill Helpers)

GitHub's language bar reports Python as the largest language because this repository vendors many skill-specific helper scripts, especially for document/media workflows. The Python audit is stored in [`reports/python-audit.txt`](reports/python-audit.txt).

Audit result:

| Category | Count | Meaning |
|----------|------:|---------|
| TOOLING | 312 | Skill helper scripts, installer mirrored copies, and source reference snapshots. |
| LEGACY | 0 | No Python files were classified as unused legacy files. |
| CORE | 0 | The core QA/CI toolchain is Node.js/TypeScript and shell scripts, not Python. |

Python is used for:

- Office document utilities under `skills/docx`, `skills/pptx`, and `skills/xlsx`.
- PDF/image/media helper scripts for file-oriented skills.
- MCP and skill-packaging evaluation utilities.
- Mirrored installer copies under `installer/skills/`.
- Source reference snapshots under `sources/` used for provenance and comparison.

Python helpers are not the main runtime of this repository and are not executed automatically by the primary CI jobs. They are invoked only by their owning skill workflows or reviewed as packaged skill assets.

### Shell Scripts and PowerShell

Shell and PowerShell scripts handle local installation, verification, and manual smoke tests:

- `install.sh`, `verify.sh`
- `install-global.sh`, `verify-global.sh`
- `installer/install-pi-linux.sh`
- `installer/install-pi-windows.ps1`
- `scripts/ai-checks.sh`, `scripts/ai-quality-checks.sh`, `scripts/ai-senior-checks.sh`
- `scripts/test-akses-satu-api.sh`

Installer scripts support sandbox targets for CI and local verification. Real-home installation is used only when explicitly requested.

### Markdown / YAML / JSON

- `skills/*/SKILL.md` defines operational skill behavior.
- `skills/*/agents/openai.yaml` defines agent metadata and trigger hints.
- `skills/*/references/sources.md` records relevant sources and license notes.
- `installer/config/*.json` configures Pi settings, models, and presets.
- `reports/` stores evidence, audit output, and verification records.

## Folder Structure

```txt
AstralForge-Senior-Engineer-Skills/
├── .github/workflows/        # GitHub Actions CI, security, installer checks
├── docs/                     # ADRs, release docs, provider docs
├── e2e/                      # Playwright package smoke test
├── installer/                # Complete Pi installer payload
│   ├── agents/
│   ├── config/
│   ├── extensions/
│   ├── prompts/
│   └── skills/               # Mirrored installable skill payload
├── reports/                  # Evidence, audit output, readiness reports
├── scripts/                  # Local QA, audit, smoke-test scripts
├── skills/                   # Source skill set, 83 retained folders
├── sources/                  # Source/reference snapshots for provenance
├── tests/                    # Vitest repository policy tests
├── package.json              # Node QA toolchain entrypoint
└── tsconfig.json             # TypeScript configuration
```

## Data Flow

```txt
User / Maintainer
  │
  ├─ edits skills/<name>/SKILL.md + agents/openai.yaml + references/sources.md
  │
  ├─ runs local gates
  │     npm run typecheck
  │     npm run test:coverage
  │     npm run verify:skills
  │     npm run audit:skills
  │     pre-commit run --all-files
  │
  ├─ installs package locally when needed
  │     install.sh / install-global.sh / installer/install-pi-*.sh
  │
  └─ AI agent consumes installed skill files from local skill directories
        ~/.pi/agent/skills
        ~/.config/opencode/skills
        ~/.claude/skills
        ~/.codex/skills
        ~/.agents/skills
```

## Skill Quality Model

A retained source skill is considered locally audit-passing only when `scripts/audit-skills.sh` validates:

- `SKILL.md` exists.
- Frontmatter exists and `name` matches the folder.
- `description` is non-empty.
- Body has at least 150 substantive words.
- No unfinished marker phrases are present.
- `agents/openai.yaml` exists and is non-empty.
- `references/sources.md` exists and includes HTTP URLs.
- Reference links pass the audit link checker.

Current status: 83 retained source skills, 83 PASS, 0 NEEDS_REVIEW, 0 STUB, 0 BROKEN.

## Security and Evidence Boundaries

- API keys and provider credentials must come from environment variables.
- `.env` and `.env.*` are ignored; `.env.example` may contain placeholders only.
- Authorization headers and API key values must never be printed in logs, docs, tests, or reports.
- Generated local outputs such as `coverage/`, `playwright-report/`, `test-results/`, and raw scanner reports remain ignored unless intentionally committed as compact evidence under `reports/`.
- StrykerJS mutation testing is manual-only and is not part of default CI.

## Known Limitations

- Playwright currently verifies package wiring with a skipped placeholder smoke test; this repository is not a runnable web application.
- The language bar is dominated by Python because of bundled helper scripts and mirrored skill assets, not because Python is the primary QA/CI runtime.
- The local substantive audit is evidence for repository quality gates; it is not an external certification of every upstream tool or source.
