# CI Setup Evidence

Date: 2026-06-22
Phase: 2 — baseline quality workflow

## Workflow

- Path: `.github/workflows/ci.yml`
- Name: `CI`
- Triggers:
  - `push` to `main`
  - `pull_request` to `main`
- Job: `quality`
- Runner: `ubuntu-latest`
- Node: `26`

## CI Steps

1. Checkout repository with `actions/checkout@v4`.
2. Setup Node.js with `actions/setup-node@v4` and npm cache.
3. Install dependencies with `npm ci`.
4. Run `npm run typecheck`.
5. Run `npm run test:unit`.
6. Run `npm run test:coverage`.
7. Run `npm run verify:skills`.
8. Run `npx knip`.
9. Install `pre-commit` and Gitleaks `8.30.1` with checksum verification.
10. Run `pre-commit run --all-files`.
11. Upload `coverage/` artifact when present.
12. Upload `test-results/` artifact when present.

## Local Verification Commands

These commands were run locally before committing this phase:

```bash
npm run typecheck
npm run test:unit
npm run test:coverage
npm run verify:skills
npx knip
pre-commit run --all-files
```

Local evidence logs are stored in `/tmp/astralforge-phase2-final-*.log` for this run and are intentionally not committed.

## Coverage Threshold Note

`vitest.config.ts` currently uses explicit coverage thresholds of `0` for lines, branches, functions, and statements. This is intentional and honest for the current repository shape: AstralForge is primarily a Markdown/YAML/Python/shell skill package with TypeScript used for repository verification tests, not an application with instrumented runtime `src/` modules.

The CI still runs coverage and uploads the `coverage/` artifact. Later phases can raise thresholds after meaningful instrumented source modules or audit utilities are added.

## Workflow Link

After this commit is pushed, the workflow will be available at:

<https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/workflows/ci.yml>

## Evidence Status

- Local command evidence: present for this phase.
- Committed workflow definition: present.
- GitHub-hosted green CI evidence: pending until the branch is pushed and the workflow runs on GitHub Actions.
