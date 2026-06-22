# Pi Local - Akses Satu Api Detection Report

Date: 2026-06-22
Scope: detect Pi binary, version, native provider registration, env vars, and config locations.

## Environment Snapshot

| Check | Result |
|-------|--------|
| Working dir | `/home/fahmi/Downloads/LAB GITHUB/LAB SKILL/pro-skill-fullstack-developert` |
| `pi` binary | `/home/fahmi/.opencode/bin/pi` (symlink) |
| Resolved binary | `/home/fahmi/.opencode/lib/node_modules/@earendil-works/pi-coding-agent/dist/cli.js` |
| Binary type | ECMAScript module (Node.js) |
| Pi version | `0.79.9` |
| `AKSES_SATU_API_KEY` env var | **NOT SET** |
| `AKSES_SATU_BASE_URL` env var | not set (default would be `https://api.satuakses.top/v1`) |
| `AKSES_SATU_DEFAULT_MODEL` env var | not set (default would be `glm-4.6`) |

## Pi CLI Capability Check

| Capability | Status | Evidence |
|------------|--------|----------|
| `--provider <name>` | supported | `pi --help` lists `--provider <name>` |
| `--model <pattern>` | supported | `pi --help` lists `--model <pattern>` |
| `--api-key <key>` | supported | `pi --help` lists `--api-key <key>` |
| `--base-url` / `--api-base` / `--openai-base-url` | **not supported** | not present in `pi --help` |
| Custom provider via native API | **supported** | `pi.registerProvider()` exported from `dist/index.d.ts` (re-exported from `dist/core/extensions/index.d.ts`) |
| `models.json` merge | **supported** | `ModelRegistry.refresh()` and `loadCustomModels()` use `~/.pi/agent/models.json` |
| `OPENAI_BASE_URL` env var fallback | **not supported** for OpenAI provider | env var list in `pi --help` does not include any `OPENAI_BASE_URL`; only `AZURE_OPENAI_BASE_URL` is listed |
| Extension auto-load from `~/.pi/agent/extensions/` | **supported** | directory exists with multiple `.ts` extensions; Pi discovers them at startup |

## Config Locations

| File | Path | Notes |
|------|------|-------|
| Pi home (configDir) | `~/.pi/agent/` | from `piConfig.configDir = ".pi"` in package.json |
| Custom models | `~/.pi/agent/models.json` | present, contains `opencode-go` and `gitlawb-opengateway`; **no `akses-satu-api` yet** |
| Settings | `~/.pi/agent/settings.json` | present, `defaultProvider: openai`, `defaultModel: gpt-5.5` |
| Auth storage | `~/.pi/agent/auth.json` | **contains secrets - not inspected, not backed up** |
| Extensions | `~/.pi/agent/extensions/*.ts` | 28+ extension files |
| Backup dir (this session) | `~/.ai-agent-tool-backups/pi-akses-satu-20260622-073545/` | `models.json`, `settings.json`, `presets.json` copies |

## Live Runtime Test

| Step | Status | Reason |
|------|--------|--------|
| Run `pi --provider openai --model glm-4.6 -p "..."` with `OPENAI_BASE_URL` | **not executed** | `OPENAI_BASE_URL` is not in Pi's env var list; would have been a wasted call |
| Run `pi -e <extension>` with `registerProvider` | **not executed** | `AKSES_SATU_API_KEY` is not set; no safe live call possible |
| Run `bash scripts/test-akses-satu-api.sh` | **not executed** | `AKSES_SATU_API_KEY` is not set |

## Live API Evidence (from prior user evidence)

`POST https://api.satuakses.top/v1/chat/completions` with `glm-4.6` already returned HTTP 200 and content `BERHASIL` once. See prior `reports/akses-satu-api-provider.md`.

## Recommended Pi Integration (chosen path)

1. **Primary: extension provider** - `pi.registerProvider("akses-satu-api", ...)` via `extensions/akses-satu-api-provider/index.ts`. Pi v0.79.9 supports this directly.
2. **Secondary: merge into `~/.pi/agent/models.json`** - installer's `installer/config/models.json` already contains the `akses-satu-api` provider block; running `installer/install-pi-linux.sh` will copy it to the live location.
3. **Fallback: launcher script** - `scripts/run-pi-akses-satu.sh` exports `OPENAI_API_KEY` and execs `pi --provider openai --model glm-4.6`. **This fallback is only useful if the user is already routing all OpenAI-compatible calls through `https://api.satuakses.top/v1`; Pi v0.79.9 does not honor `OPENAI_BASE_URL` for the `openai` provider**, so the launcher is documented as a defensive convenience, not the primary mechanism.

## Required User Action Before Live Test

```fish
set -Ux AKSES_SATU_API_KEY "sk-sa-REPLACE_ME"
set -Ux AKSES_SATU_DEFAULT_MODEL "glm-4.6"
set -Ux AKSES_SATU_BASE_URL "https://api.satuakses.top/v1"
```

Then:

```bash
# Option A: native provider via extension
pi -e ./extensions/akses-satu-api-provider --provider akses-satu-api --model glm-4.6 -p "Jawab hanya satu kata: BERHASIL"

# Option B: provider already in ~/.pi/agent/models.json (after running installer)
pi --provider akses-satu-api --model glm-4.6 -p "Jawab hanya satu kata: BERHASIL"

# Option C: launcher script
bash scripts/run-pi-akses-satu.sh -p "Jawab hanya satu kata: BERHASIL"
```

## Security Notes

- No API key was read, stored, logged, or committed.
- `auth.json` was deliberately not opened or copied.
- Backup directory contains only `models.json`, `settings.json`, `presets.json` (no secrets).
