# Akses Satu Api Provider Integration Report

Latest update: switched default model to `glm-4.6` (verified live), expanded model union to 11 (7 verified live + 4 configured), added Pi extension, Pi launcher, and Pi detection report. Prior draft integration (May 2026) is preserved in git history.

## Scope

Added Akses Satu Api as a custom OpenAI-compatible provider for this AstralForge/Pi installer repository, the local TypeScript helper client, and the local Pi Code / Pi Agent binary.

## Detected Project Structure

| Item | Finding |
|------|---------|
| Primary language/tooling | TypeScript tests + shell/PowerShell installer scripts; no application runtime server. |
| Provider config location | `installer/config/models.json` and `installer/config/settings.json`. |
| Adapter/provider abstraction | No existing app adapter; added a small local helper module under `src/providers/`. |
| OpenAI client existing | No existing OpenAI SDK/client in repo runtime source. |
| UI settings | No app UI settings; installer settings use `enabledModels`. |
| Env handling | Gitignored `.env` / `.env.*`; added `.env.example` placeholder. |
| Test framework | Vitest + TypeScript. |
| Local Pi binary | `/home/fahmi/.opencode/bin/pi` resolving to `…/earendil-works/pi-coding-agent/dist/cli.js` (v0.79.9). |
| Local Pi config | `~/.pi/agent/models.json` and `~/.pi/agent/settings.json`; both backed up to `~/.ai-agent-tool-backups/pi-akses-satu-20260622-073545/`. |

## Implementation

| Capability | Status | Evidence |
|------------|--------|----------|
| Provider id `akses-satu-api` | Added | `src/providers/akses-satu-api.ts`, `installer/config/models.json` |
| Base URL `https://api.satuakses.top/v1` | Added | provider module + Pi config + extension |
| Bearer API key via `AKSES_SATU_API_KEY` | Added | provider module + Pi config + extension |
| Default model `glm-4.6` | Added (was `gpt-5.5` in v1; switched because `glm-4.6` is verified live) | provider module + `.env.example` |
| Model union (11 models, no duplicates) | Added | `AKSES_SATU_MODELS` = `AKSES_SATU_VERIFIED_LIVE_MODELS` (7) + `AKSES_SATU_CONFIGURED_MODELS` (4) |
| Verified live models | Added | `glm-4.6`, `claude-sonnet-4.6`, `cipher`, `idsa-v1.0`, `google-gemma-2-9b-it`, `mimo-v2.5`, `claude-opus-4.8` |
| Configured / requested models | Added | `gpt-5.5`, `minimax-m3`, `mimo-v2.5-pro`, `deepseek-v4-pro` (kept in union even if not in `/v1/models` yet) |
| Static model fallback list | Added | `AKSES_SATU_MODELS` |
| `GET /models` | Added | `listAksesSatuModels()` |
| `POST /chat/completions` | Added | `createAksesSatuChatCompletion()` |
| `POST /responses` | Added | `createAksesSatuResponse()` |
| Installer model picker support | Added | `installer/config/settings.json` enabled models |
| Pi extension (native provider) | Added | `extensions/akses-satu-api-provider/index.ts` + mirror at `installer/extensions/akses-satu-api-provider/` |
| Pi launcher fallback | Added | `scripts/run-pi-akses-satu.sh` |
| Manual smoke test script | Rewritten (chat/responses sections now call real endpoints and classify honestly) | `scripts/test-akses-satu-api.sh` |
| Local Pi detection report | Added | `reports/pi-akses-satu-detection.md` |

## Security Notes

- No real API key was added.
- `.env.example` contains `sk-sa-REPLACE_ME` placeholder only.
- `.gitignore` keeps `.env` and `.env.*` ignored while allowing `.env.example`.
- Runtime helper never logs Authorization headers.
- Manual script prints `API Key: [REDACTED]`.
- Unit tests use a non-secret fake key string, not a real-looking provider key.

## Validation Evidence

| Command | Status | Evidence |
|---------|--------|----------|
| Initial structure detection commands | PASS | `/tmp/astralforge-akses-satu-config-check.log` and shell output |
| `bash -n scripts/test-akses-satu-api.sh` | PASS | `/tmp/astralforge-akses-satu-final-script-check.log` |
| `npm run typecheck` | PASS | `/tmp/astralforge-akses-satu-final2-typecheck.log` |
| `npm run test:unit` | PASS | `/tmp/astralforge-akses-satu-final2-test-unit.log` |
| `npm run test:coverage` | PASS | `/tmp/astralforge-akses-satu-final2-test-coverage.log` |
| `npm run verify:skills` | PASS | `/tmp/astralforge-akses-satu-final2-verify-skills.log` |
| `pre-commit run --all-files` | PASS | `/tmp/astralforge-akses-satu-final3-precommit.log` |
| `gitleaks dir --redact --report-format json --report-path gitleaks-dir-report.json .` | PASS, no leaks | `/tmp/astralforge-akses-satu-final2-gitleaks.log` |
| `semgrep scan --config p/default --metrics=off --json --json-output=semgrep-results.json` | 0 findings, 3 partial parsing errors | `/tmp/astralforge-akses-satu-final2-semgrep.log`, `/tmp/astralforge-akses-satu-final2-semgrep-summary.txt` |

## Known Limitations

- Unit tests use mocked `fetch`; no live Akses Satu Api call was made from this repo (no `AKSES_SATU_API_KEY` is set in this environment).
- `scripts/test-akses-satu-api.sh` was not executed in this session because `AKSES_SATU_API_KEY` is not set locally. The script is key-safe and ready to run after the key is exported.
- Pi `models.json` uses `api: "openai-completions"` for chat usage. The local helper also supports the Responses API for systems/apps that call it directly.
- Pi v0.79.9 does NOT honor `OPENAI_BASE_URL` for the built-in `openai` provider. The launcher therefore uses the native `akses-satu-api` provider id (already registered via `~/.pi/agent/models.json` after installer runs). The launcher keeps `OPENAI_*` exports as a defensive convenience.
- Local Pi binary was detected but no live provider call was run from this session.
- Semgrep reported partial parsing errors in existing YAML/complex Bash snippets, but reported zero findings.

## Files Changed (this session)

- `src/providers/akses-satu-api.ts` (default model + union + verified/configured lists)
- `src/providers/index.ts` (re-exports)
- `installer/config/models.json` (full 11-model union with metadata)
- `installer/config/settings.json` (all verified-live `akses-satu-api/*` in enabledModels)
- `.env.example` (default model → `glm-4.6`)
- `scripts/test-akses-satu-api.sh` (fixed endpoints, honest classification)
- `scripts/run-pi-akses-satu.sh` (new launcher fallback)
- `extensions/akses-satu-api-provider/index.ts` + `package.json` (new Pi extension)
- `installer/extensions/akses-satu-api-provider/index.ts` + `package.json` (new installer copy)
- `docs/providers/akses-satu-api.md` (rewrite per spec)
- `README.md` (Akses Satu Api section)
- `AGENTS.md` (provider note)
- `tests/akses-satu-api-provider.test.ts` (extended assertions)
- `tests/installer-scripts.test.ts` (new required script entries)
- `CHANGELOG.md` (Unreleased Added/Changed/Security block)
- `reports/pi-akses-satu-detection.md` (new local Pi detection report)

## Backup

Files were backed up before editing under the timestamped directory stored in `/tmp/astralforge-akses-satu-backup-dir.txt`.
