# Installer Audit

Date: 2026-06-22
Phase: 7 — installer verification plan and CI matrix

## Scope

Installer scripts audited:

| Script | Platform | Purpose | Dry-run support | Sandbox target support | Verification status |
|--------|----------|---------|-----------------|------------------------|---------------------|
| `install.sh` | Linux/macOS shell | Install source skills to one Pi/OpenClaude-style skills directory | Yes: `--dry-run` | Yes: `--target-dir DIR` or `ASTRALFORGE_SKILL_DIR` | Local sandbox PASS |
| `verify.sh` | Linux/macOS shell | Verify one installed skills directory | Not applicable | Yes: `--target-dir DIR` or `ASTRALFORGE_SKILL_DIR` | Local sandbox PASS |
| `install-global.sh` | Linux/macOS shell | Symlink skills to Pi/OpenCode/Claude/Codex/Agents dirs | Yes: `--dry-run` | Yes: `--home DIR` or `ASTRALFORGE_HOME` | Local sandbox PASS |
| `verify-global.sh` | Linux/macOS shell | Verify all global skill dirs | Not applicable | Yes: `--home DIR` or `ASTRALFORGE_HOME` | Local sandbox PASS |
| `install.ps1` | Windows PowerShell | Install source skills to one Pi/OpenClaude-style skills directory | Yes: `-DryRun` | Yes: `-TargetDir` or `ASTRALFORGE_SKILL_DIR` | Pending Windows CI; `pwsh` unavailable locally |
| `verify.ps1` | Windows PowerShell | Verify one installed skills directory | Not applicable | Yes: `-TargetDir` or `ASTRALFORGE_SKILL_DIR` | Pending Windows CI; `pwsh` unavailable locally |
| `installer/install-pi-linux.sh` | Linux/macOS shell | Install complete Pi package to Pi home | Yes: `--dry-run` | Yes: `--pi-home DIR` or `ASTRALFORGE_PI_HOME`; `--skip-pi-check` for CI | Local sandbox PASS |
| `installer/install-pi-windows.ps1` | Windows PowerShell | Install complete Pi package to Pi home | Yes: `-DryRun` | Yes: `-PiHome` or `ASTRALFORGE_PI_HOME`; `-SkipPiCheck` for CI | Pending Windows CI; `pwsh` unavailable locally |

## Local Sandbox Evidence

Shell installer checks were run against a temporary directory, not the real user home.

| Check | Status | Evidence File |
|-------|--------|---------------|
| `bash -n install.sh verify.sh install-global.sh verify-global.sh installer/install-pi-linux.sh` | PASS | command output |
| `bash install.sh --dry-run --target-dir <tmp>/pi-skills` | PASS | `/tmp/astralforge-phase7-install-sh-dry-run.log` |
| `bash install.sh --force --target-dir <tmp>/pi-skills` | PASS | `/tmp/astralforge-phase7-install-sh-install.log` |
| `bash verify.sh --target-dir <tmp>/pi-skills` | PASS | `/tmp/astralforge-phase7-verify-sh.log` |
| `bash install-global.sh --dry-run --home <tmp>/home` | PASS | `/tmp/astralforge-phase7-install-global-dry-run.log` |
| `bash install-global.sh --force --home <tmp>/home` | PASS | `/tmp/astralforge-phase7-install-global-install.log` |
| `bash verify-global.sh --home <tmp>/home` | PASS | `/tmp/astralforge-phase7-verify-global.log` |
| `bash installer/install-pi-linux.sh --dry-run --pi-home <tmp>/pi-home --skip-pi-check` | PASS | `/tmp/astralforge-phase7-pi-linux-dry-run.log` |
| `bash installer/install-pi-linux.sh --force --pi-home <tmp>/pi-home --skip-pi-check` | PASS | `/tmp/astralforge-phase7-pi-linux-install.log` |
| PowerShell local run | SKIPPED | `/tmp/astralforge-phase7-pwsh-unavailable.log` |

## CI Matrix Plan

Workflow path: `.github/workflows/installers.yml`

Matrix:

- `ubuntu-latest`
- `macos-latest`
- `windows-latest`

Linux/macOS jobs test:

1. Single-platform dry-run with `install.sh --dry-run --target-dir "$RUNNER_TEMP/pi-skills"`.
2. Single-platform sandbox install with `install.sh --force --target-dir "$RUNNER_TEMP/pi-skills"`.
3. Verification with `verify.sh --target-dir "$RUNNER_TEMP/pi-skills"`.
4. Skill count and non-empty `SKILL.md` checks.
5. Global dry-run/install/verify using `--home "$RUNNER_TEMP/astralforge-home"`.
6. Complete Pi installer dry-run/install using `--pi-home "$RUNNER_TEMP/pi-home" --skip-pi-check`.
7. Config, extension, and skill count checks.

Windows job tests:

1. Single-platform dry-run with `install.ps1 -DryRun -TargetDir "$env:RUNNER_TEMP\pi-skills"`.
2. Single-platform sandbox install with `install.ps1 -Force -TargetDir "$env:RUNNER_TEMP\pi-skills"`.
3. Verification with `verify.ps1 -TargetDir "$env:RUNNER_TEMP\pi-skills"`.
4. Skill count and non-empty `SKILL.md` checks.
5. Complete Pi installer dry-run/install using `-PiHome "$env:RUNNER_TEMP\pi-home" -SkipPiCheck`.
6. Config, extension, and skill count checks.

## Risks and Guardrails

- CI never installs into the real runner `$HOME` / `$USERPROFILE`; all writes go to `RUNNER_TEMP`.
- Complete Pi installer uses `--skip-pi-check` / `-SkipPiCheck` in CI because the goal is package install verification, not validating Pi binary availability.
- The workflow checks counts and representative non-empty files to catch truncated or incomplete copies.
- Existing real-user install paths remain defaults for normal usage.
- No force push, cloud login, API key, or secret is needed.

## Known Limitations

- Windows PowerShell installer validation could not run locally because `pwsh` is unavailable in this environment; it is covered by the `windows-latest` GitHub Actions job.
- `installer/install-pi-linux.sh` and `installer/install-pi-windows.ps1` verify installed file counts but do not launch Pi.
- Installer scripts still duplicate materialized content under `installer/skills`; future phases may decide whether to generate this from `skills/`.

## Recommendation

Keep installer verification in CI as a separate workflow from baseline quality and security. Do not run real-home installer tests in CI. Future hardening can add deeper installer assertions after the sandbox workflow is green on GitHub Actions.
