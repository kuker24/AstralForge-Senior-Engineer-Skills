# Security Policy

AstralForge Senior Engineer Skills is a local-first repository of AI skill instructions, installer scripts, and quality-gate tooling. It is not a hosted SaaS product.

## Supported Scope

Security review currently covers:

- Source skill files under `skills/`.
- Installer scripts and complete Pi installer assets.
- GitHub Actions workflow definitions.
- Local QA/security scripts.
- Package metadata and dependency lockfiles.

The repository documents evidence in:

- [`reports/security-ci-setup-evidence.md`](reports/security-ci-setup-evidence.md)
- [`reports/tool-evidence/README.md`](reports/tool-evidence/README.md)
- [`reports/evidence-inventory.md`](reports/evidence-inventory.md)

## Known Limitations

- Not every source skill is substantively verified. See [`reports/skill-audit-summary.md`](reports/skill-audit-summary.md).
- GitHub-hosted CI status is only verified after workflows run on GitHub Actions.
- Some tools depend on the contributor's local environment.
- Mutation testing is manual-only and is not part of default security validation.

## Reporting a Vulnerability

Please open a private security advisory on GitHub if available, or contact the maintainer privately before public disclosure.

Include:

- Affected file(s) or workflow(s).
- Impact and exploitability.
- Minimal reproduction steps.
- Whether secrets or private data are involved.
- Suggested fix, if known.

Do **not** include real credentials, tokens, API keys, private keys, or private customer/user data in an issue or PR.

## Local Security Checks

Recommended local checks:

```bash
semgrep scan --config p/default --metrics=off
osv-scanner scan source -r . --format json --output-file osv-results.json
gitleaks git --redact --report-format json --report-path gitleaks-report.json .
gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json .
npm audit --audit-level=moderate
```

Keep generated reports local unless a compact, redacted evidence file is intentionally committed under `reports/`.

## Secrets Handling

- Never commit `.env`, credentials, API keys, tokens, or private config files.
- Use placeholders such as `$OPENGATEWAY_API_KEY` when documenting configuration.
- Redact security scan outputs before sharing.
- If a secret is committed, rotate it immediately and then remove it from repository history only after maintainer review.

## Disclosure Expectations

The project prioritizes transparent, evidence-based security posture:

- Fixes should include tests or scan evidence where practical.
- README claims should not be upgraded until evidence exists.
- Known broken/stub skills should remain visible until fixed.
