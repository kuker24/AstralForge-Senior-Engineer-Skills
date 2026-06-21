# Security CI Setup Evidence

Date: 2026-06-22
Phase: 3 — dedicated security scanning workflow

## Workflow

- Path: `.github/workflows/security.yml`
- Name: `Security`
- Triggers:
  - `push` to `main`
  - `pull_request` to `main`
  - `workflow_dispatch`
- Job: `security`
- Runner: `ubuntu-latest`
- Node: `26`

## Security Steps

1. Checkout repository with `actions/checkout@v4`.
2. Setup Node.js with `actions/setup-node@v4` and npm cache.
3. Install dependencies with `npm ci`.
4. Install Semgrep `1.167.0` with `python -m pip install --user semgrep==1.167.0`.
5. Install OSV-Scanner `2.4.0` from the official GitHub release with SHA256 verification.
6. Install Gitleaks `8.30.1` from the official GitHub release with SHA256 verification.
7. Run Semgrep:

   ```bash
   semgrep scan --config p/default --metrics=off --json --json-output=semgrep-results.json
   ```

8. Run OSV-Scanner:

   ```bash
   osv-scanner scan source -r . --format json --output-file osv-results.json
   ```

9. Run Gitleaks:

   ```bash
   gitleaks git --redact --report-format json --report-path gitleaks-report.json .
   ```

10. Upload security report artifacts:
    - `semgrep-results.json`
    - `osv-results.json`
    - `gitleaks-report.json`

## Local Verification Commands

These commands were run locally before committing this phase:

```bash
semgrep scan --config p/default --metrics=off --json --json-output=semgrep-results.json
osv-scanner scan source -r . --format json --output-file osv-results.json
gitleaks git --redact --report-format json --report-path gitleaks-report.json .
```

Local evidence logs are stored in `/tmp/astralforge-phase3-final-*.log` for this run and are intentionally not committed.

Local summary for this phase:

| Tool | Result |
|------|--------|
| Semgrep | 0 findings |
| OSV-Scanner | 0 vulnerability matches |
| Gitleaks git scan | 0 findings |

## No-Login / No-Secret Notes

- No Semgrep login is used.
- No API keys, cloud tokens, or repository secrets are required by this workflow.
- Reports are uploaded only as GitHub Actions artifacts for the workflow run.
- Scan outputs are also covered by `.gitignore` for local runs.

## Workflow Link

After this commit is pushed, the workflow will be available at:

<https://github.com/kuker24/AstralForge-Senior-Engineer-Skills/actions/workflows/security.yml>

## Evidence Status

- Local command evidence: present for this phase.
- Committed workflow definition: present.
- GitHub-hosted green security evidence: pending until the branch is pushed and the workflow runs on GitHub Actions.
