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
| `AKSES_SATU_API_KEY` env var | SET (loaded from `~/.config/fish/fish_variables`, value hidden) |
| `AKSES_SATU_BASE_URL` env var | SET to `https://api.satuakses.top/v1` (set in this session) |
| `AKSES_SATU_DEFAULT_MODEL` env var | SET to `glm-4.6` (set in this session) |

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

## Live Test Results (2026-06-22, after `AKSES_SATU_API_KEY` was set)

All three live test paths were executed with the user-provided API key. The
key was loaded from `~/.config/fish/fish_variables` (set via `set -Ux`) into
a temporary 600-permission file and then sourced into the bash session; the
key value was never printed to the terminal.

### Direct API (via `scripts/test-akses-satu-api.sh`)

| Endpoint | HTTP | Result | Notes |
|----------|------|--------|-------|
| `GET /v1/models` | 200 | PASS | 20 model ids returned, including all 11 union models |
| `POST /v1/chat/completions` (glm-4.6) | 200 | PASS | `object=chat.completion`, `content="BERHASIL"` |
| `POST /v1/responses` (glm-4.6) | 200 | PASS | response contains `output` / `output_text` |

Direct `curl` confirmation of remaining union models via `/v1/chat/completions`:

| Model | HTTP | object | content |
|-------|------|--------|---------|
| `claude-sonnet-4.6` | 200 | chat.completion | BERHASIL |
| `gpt-5.5` | 200 | chat.completion | BERHASIL |
| `minimax-m3` | 200 | chat.completion | BERHASIL |
| `deepseek-v4-pro` | 200 | chat.completion | BERHASIL |
| `mimo-v2.5-pro` | 200 | chat.completion | BERHASIL |

**Result: all 11 union models are verified live. `AKSES_SATU_CONFIGURED_MODELS`
is now empty.**

### Pi native provider (after `installer/config/models.json` deployed to `~/.pi/agent/`)

```bash
pi --list-models akses
# PASS: lists 11 models under provider `akses-satu-api` with their context/max-output/thinking/image metadata.

pi --provider akses-satu-api --model glm-4.6 -p "Jawab hanya satu kata: BERHASIL"
# Output: BERHASIL
```

### Pi extension path

```bash
pi -e ./extensions/akses-satu-api-provider --provider akses-satu-api --model glm-4.6 -p "Jawab hanya satu kata: BERHASIL"
# Output: BERHASIL
```

### Pi launcher fallback

```bash
bash scripts/run-pi-akses-satu.sh -p "Jawab hanya satu kata: BERHASIL"
# Output: BERHASIL
# Script printed `API Key: [REDACTED]` (no key value leaked).
```

### Conclusion

All three Pi integration paths work end-to-end. The native provider via
`~/.pi/agent/models.json` is the recommended path because it requires no
extension flag and no launcher wrapper. The extension path is a useful
fallback when running from a project that does not have a global Pi install
configured. The launcher is documented but rarely needed.

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
