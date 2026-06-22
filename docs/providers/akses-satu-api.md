# Akses Satu Api Provider

Akses Satu Api (`https://api.satuakses.top/v1`) is a custom OpenAI-compatible
provider used by Pi Code / Pi Agent and by the helper client shipped in this
repo (`src/providers/akses-satu-api.ts`).

## Provider

| Field | Value |
|-------|-------|
| Display name | Akses Satu Api |
| Provider id | `akses-satu-api` |
| Base URL | `https://api.satuakses.top/v1` |
| Auth | `Authorization: Bearer <AKSES_SATU_API_KEY>` |
| API key env var | `AKSES_SATU_API_KEY` |
| Default model | `glm-4.6` |
| Pi API mode | `openai-completions` |
| Auth header | `true` (Pi adds `Authorization: Bearer` automatically) |

## Default Model

`glm-4.6` is the default because it is the only model verified end-to-end
through `POST /v1/chat/completions` in this environment. The other verified-live
models are advertised as `enabled` in the installer config; configured-but-not-
yet-verified models are kept in the union and may be tried on request.

## Set API key

Fish:

```fish
set -Ux AKSES_SATU_API_KEY "sk-sa-REPLACE_ME"
set -Ux AKSES_SATU_DEFAULT_MODEL "glm-4.6"
set -Ux AKSES_SATU_BASE_URL "https://api.satuakses.top/v1"
```

Bash/Zsh:

```bash
export AKSES_SATU_API_KEY="sk-sa-REPLACE_ME"
export AKSES_SATU_DEFAULT_MODEL="glm-4.6"
export AKSES_SATU_BASE_URL="https://api.satuakses.top/v1"
```

Never commit real API keys. `.env` and `.env.*` are gitignored; `.env.example`
contains only placeholders.

## Test the API

```bash
bash scripts/test-akses-satu-api.sh
```

The script:

- Validates `GET /v1/models` and reports whether the response includes a list
  of model ids.
- Validates `POST /v1/chat/completions` with a deterministic prompt and
  requires `object == "chat.completion"` plus a non-empty
  `choices[0].message.content`. PASS / FAIL is reported honestly.
- Validates `POST /v1/responses` and reports PASS only if the response contains
  `output` or `output_text`. If the response is a model list (provider
  misroute), the script reports `FAIL_PROVIDER_MISROUTE` instead of PASS.
- Never prints the value of `AKSES_SATU_API_KEY`.

## Run Pi

Three supported ways, in priority order:

### 1. Native provider (preferred)

After running the installer (`bash installer/install-pi-linux.sh`), the
`akses-satu-api` provider is registered in `~/.pi/agent/models.json`:

```bash
pi --provider akses-satu-api --model glm-4.6 -p "Jawab hanya satu kata: BERHASIL"
```

### 2. Extension (no installer required)

```bash
pi -e ./extensions/akses-satu-api-provider \
  --provider akses-satu-api \
  --model glm-4.6 \
  -p "Jawab hanya satu kata: BERHASIL"
```

The extension uses Pi's native `pi.registerProvider()` API (Pi v0.79.9+).
A mirrored copy lives at `installer/extensions/akses-satu-api-provider/` so
the installer can deploy it as a managed extension.

### 3. Launcher fallback (best-effort)

```bash
bash scripts/run-pi-akses-satu.sh -p "Jawab hanya satu kata: BERHASIL"
```

> **Note:** Pi v0.79.9 does not honor `OPENAI_BASE_URL` for the built-in
> `openai` provider, so the launcher falls back to the `akses-satu-api`
> provider id (which is already in `~/.pi/agent/models.json` after
> installation). The launcher still exports `OPENAI_*` for any downstream
> tooling that consumes them.

## Models

### Verified live models (advertised as enabled)

- `glm-4.6` (default)
- `claude-sonnet-4.6`
- `cipher`
- `idsa-v1.0`
- `google-gemma-2-9b-it`
- `mimo-v2.5`
- `claude-opus-4.8`

### Configured / requested models (kept in union, not yet verified)

- `gpt-5.5`
- `minimax-m3`
- `mimo-v2.5-pro`
- `deepseek-v4-pro`

These are NOT removed from the union just because they did not appear in
`GET /v1/models`; they may be tried and will be promoted to verified once the
provider returns them.

## Endpoints

Given `AKSES_SATU_BASE_URL=https://api.satuakses.top/v1`:

- `GET /v1/models` - list models
- `POST /v1/chat/completions` - OpenAI chat completions
- `POST /v1/responses` - OpenAI Responses API

The local helper module (`src/providers/akses-satu-api.ts`) exposes:

```ts
import {
  createAksesSatuChatCompletion,
  createAksesSatuResponse,
  getAksesSatuModelChoices,
  listAksesSatuModels,
} from "./src/providers";
```

The helper:

- uses `AKSES_SATU_API_KEY` from environment by default;
- never logs the Authorization header;
- supports fetch injection for unit tests;
- maps 401/404/429/5xx/network/timeout/invalid JSON into safe errors;
- prioritizes live `GET /v1/models` results and falls back to the static
  union when allowed.

## Security

- API key is loaded only from `AKSES_SATU_API_KEY`. Never hardcode keys in
  source, tests, snapshots, docs, or reports.
- The Authorization header is never printed by the helper client, the test
  script, or the launcher.
- `.env` and `.env.*` are gitignored. `.env.example` is the only env file
  that is ever committed and it contains only `sk-sa-REPLACE_ME`.
- The test script never prints the value of the env var; it prints
  `API Key: [REDACTED]`.
- The extension does not log Authorization headers or any other request
  data.
