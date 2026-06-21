# AstralForge Architecture

AstralForge Senior Engineer Skills is a local-first AI engineering skills package. It combines portable skill definitions with installer scripts, local QA/security gates, evidence reports, and GitHub Actions workflows.

The repository is intentionally polyglot because each layer has a different job:

- Markdown/YAML define AI agent skills and metadata.
- Shell/PowerShell install and verify skills across local agent ecosystems.
- TypeScript/Node power repository quality gates and CI-friendly tests.
- Python supports skill-specific utilities and document/media tooling.
- Reports under `reports/` store evidence and audit outputs.

## High-Level Diagram

```txt
User / AI Agent
   |
   v
AstralForge Senior Engineer Skills
   |
   +--> Skill definitions: Markdown + YAML
   |      - skills/*/SKILL.md
   |      - skills/*/agents/openai.yaml where present
   |      - skills/*/references/sources.md where present
   |
   +--> Installer scripts: shell / PowerShell
   |      - install.sh, install.ps1
   |      - install-global.sh
   |      - installer/install-pi-linux.sh
   |      - installer/install-pi-windows.ps1
   |
   +--> Local QA: Node/TypeScript
   |      - Vitest tests in tests/
   |      - TypeScript strict typecheck
   |      - Knip repository cleanup checks
   |
   +--> Security: local scanners
   |      - Semgrep CE
   |      - OSV-Scanner
   |      - Gitleaks
   |
   +--> Evidence: reports/
   |      - evidence inventory
   |      - CI/security setup evidence
   |      - skill audit reports
   |
   +--> CI: GitHub Actions
          - .github/workflows/ci.yml
          - .github/workflows/security.yml
```

## Repository Layers

### 1. Skill Package Layer

Primary paths:

- `skills/`
- `SKILLS_MANIFEST.md`
- `MISSING_SKILLS_CHECKLIST.md`
- `reports/skill-audit-results.csv`
- `reports/skill-audit-summary.md`

Purpose:

- Store source skill definitions.
- Make skill metadata auditable.
- Track whether skills are substantive or need review.

Current evidence:

- Total source skill folders: 83.
- Source/frontmatter verifier: `npm run verify:skills`.
- Substantive audit: `bash scripts/audit-skills.sh`.
- Current substantive audit result: 25 PASS, 12 STUB, 46 BROKEN, 0 NEEDS_REVIEW.

Boundary:

- A folder under `skills/` is a source skill folder.
- A skill is not considered substantively verified unless it passes the audit criteria in `reports/skill-audit-summary.md`.

### 2. Installer Layer

Primary paths:

- `install.sh`
- `install.ps1`
- `install-global.sh`
- `verify.sh`
- `verify-global.sh`
- `installer/`

Purpose:

- Package and install skills/configs for Pi/OpenCode/Claude/Codex/Agents.
- Keep cross-platform installation scripts near the package content.

Current evidence:

- Installer files exist.
- Installer package includes `installer/skills/`, `installer/extensions/`, `installer/config/`, `installer/prompts/`, and `installer/agents/`.
- Dedicated sandbox installer CI is not implemented yet.

Boundary:

- Installer scripts should not be treated as fully verified until the installer verification phase adds sandbox-safe tests and CI matrix coverage.

### 3. Local QA / Security Tooling Layer

Primary paths:

- `package.json`
- `tsconfig.json`
- `vitest.config.ts`
- `.pre-commit-config.yaml`
- `knip.json`
- `.gitleaks.toml`
- `scripts/ai-quality-checks.sh`
- `scripts/ai-senior-checks.sh`
- `scripts/verify-source-skills.sh`
- `scripts/audit-skills.sh`

Purpose:

- Provide reproducible local quality gates.
- Keep reports local and ignored unless a phase intentionally creates a redacted evidence report.
- Avoid login/cloud/API-key requirements for local validation.

Typical commands:

```bash
npm run typecheck
npm run test:unit
npm run test:coverage
npm run verify:skills
bash scripts/audit-skills.sh
pre-commit run --all-files
```

Security commands:

```bash
semgrep scan --config p/default --metrics=off --json --json-output=semgrep-results.json
osv-scanner scan source -r . --format json --output-file osv-results.json
gitleaks git --redact --report-format json --report-path gitleaks-report.json .
```

Boundary:

- StrykerJS is installed and configured but is manual-only. Do not run `npm run mutation` or `npx stryker run` unless explicitly requested.

## Node / TypeScript Role

Node and TypeScript are used for repository-level validation, not for shipping an application runtime.

Primary responsibilities:

- Run Vitest checks against repository structure and config.
- Run strict `tsc --noEmit` over tests/config.
- Provide npm scripts for CI and local quality gates.
- Run Knip against JS/TS project configuration.

Important files:

- `package.json`
- `package-lock.json`
- `tsconfig.json`
- `vitest.config.ts`
- `tests/`

Recommendation:

- Keep Node/TS tooling at the repository root because it powers cross-cutting quality gates and CI.
- Do not present this repository as a runtime Node app.

## Python Role

Python files are skill utilities, validators, converters, media helpers, and evaluation helpers. They are not a single Python application.

Audit command used in phase 6:

```bash
find . -type f -name "*.py" \
  -not -path "./node_modules/*" \
  -not -path "./.git/*"
```

Phase 6 local evidence files:

- `/tmp/astralforge-phase6-python-files-all.txt`
- `/tmp/astralforge-phase6-python-files-tracked.txt`
- `/tmp/astralforge-phase6-python-summary.txt`

Summary from this audit:

| Scope | Python files |
|-------|-------------:|
| All working-tree Python files found by the command | 312 |
| Tracked repository Python files | 198 |
| Local ignored upstream clones under `sources/` | 114 |

### Python File Groups

| Group | Tracked files | Purpose | Recommendation |
|-------|--------------:|---------|----------------|
| `skills/docx` + `installer/skills/docx` | 30 | Office document unpacking, validation, redlining helpers, schema-aware checks | Keep in skill package; later deduplicate source/installer copies if a packaging build step is introduced |
| `skills/pptx` + `installer/skills/pptx` | 32 | PowerPoint processing, validation, and Office schema utilities | Keep; later deduplicate source/installer copies |
| `skills/xlsx` + `installer/skills/xlsx` | 26 | Spreadsheet processing and Office schema utilities | Keep; later deduplicate source/installer copies |
| `skills/skill-creator` + `installer/skills/skill-creator` | 24 | Skill validation, benchmarking, packaging, and eval helper scripts | Keep; strong candidate for future shared utility package |
| `skills/claude-skill-creator` + `installer/skills/claude-skill-creator` | 20 | Skill generation/evaluation support scripts | Keep; consider consolidating with `skill-creator` after audit |
| `skills/pdf` + `installer/skills/pdf` | 16 | PDF extraction/filling/form helpers | Keep in PDF skill |
| `skills/slack-gif-creator` + `installer/skills/slack-gif-creator` | 8 | GIF validation/media helper utilities | Keep in skill |
| `skills/webapp-testing` + `installer/skills/webapp-testing` | 8 | Browser/server automation helpers | Keep; subprocess helper was hardened to avoid `shell=True` by default |
| `skills/skill-installer` + `installer/skills/skill-installer` | 6 | GitHub download/install helpers | Keep; URL handling is host-allowlisted |
| `skills/ui-ux-pro-max` + `installer/skills/ui-ux-pro-max` | 6 | UI/UX data/design helper scripts | Keep in skill |
| `skills/mcp-builder` + `installer/skills/mcp-builder` | 4 | MCP evaluation/connection helpers | Keep; XML parsing uses `defusedxml` |
| Other single/double script skill groups | 18 | Skill-specific validators, generation helpers, or examples | Keep until each skill is individually audited |
| `sources/` local ignored clone files | 114 | Upstream reference clone content, not part of committed repo | Do not commit; exclude from repo architecture decisions |

### Python Keep / Move / Remove Recommendation

- Keep Python utilities in their owning skill directories for now.
- Do not move files automatically; duplication between `skills/` and `installer/skills/` is a packaging concern and should be handled by a later installer/build phase.
- Do not remove Python files based only on this architecture audit.
- Future cleanup should first decide whether installer content is generated from `skills/` or intentionally materialized.

## Shell / PowerShell Installer Role

Shell and PowerShell scripts support local installation and verification across operating systems.

Primary responsibilities:

- Copy or link skill folders into agent-specific skill directories.
- Verify skill package structure.
- Support Linux/macOS and Windows users.

Important files:

- `install.sh`
- `install.ps1`
- `install-global.sh`
- `verify.sh`
- `verify.ps1`
- `verify-global.sh`
- `installer/install-pi-linux.sh`
- `installer/install-pi-windows.ps1`

Recommendation:

- Keep scripts in place until the installer verification phase adds sandbox support and a CI matrix.
- Avoid running installer scripts against a real `$HOME` in CI.

## CI Role

GitHub Actions provide remote evidence for quality/security workflows after commits are pushed.

Current workflows:

- `.github/workflows/ci.yml`
  - typecheck
  - unit tests
  - coverage command
  - skill verification
  - Knip
  - pre-commit
- `.github/workflows/security.yml`
  - Semgrep
  - OSV-Scanner
  - Gitleaks

Boundary:

- Workflow definitions are present locally.
- A workflow is considered verified only after it runs successfully in GitHub Actions.

## Evidence Layer

Primary paths:

- `reports/evidence-inventory.md`
- `reports/ci-setup-evidence.md`
- `reports/security-ci-setup-evidence.md`
- `reports/skill-audit-results.csv`
- `reports/skill-audit-summary.md`

Purpose:

- Document what is verified versus merely configured.
- Store compact, reviewable evidence.
- Avoid committing large raw outputs or sensitive reports.

Ignored local outputs include:

- `semgrep-results.json`
- `osv-results.json`
- `gitleaks-report.json`
- `gitleaks-dir-report.json`
- `repomix-output.*`
- `coverage/`
- `playwright-report/`
- `test-results/`
- `.stryker-tmp/`
- `mutation-report/`

## Current Known Boundaries

- The repository has verified local quality gates, but CI green status requires GitHub-hosted workflow runs after push.
- The skill package has 83 source folders, but only 25 pass the current substantive audit.
- Installer scripts exist, but sandboxed installer verification is pending.
- StrykerJS is configured but intentionally manual-only.
- Playwright is configured with a placeholder skipped test, not a real application E2E flow.
