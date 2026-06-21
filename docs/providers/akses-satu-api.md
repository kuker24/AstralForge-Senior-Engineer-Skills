# Akses Satu Api Provider

Akses Satu Api adalah custom OpenAI-compatible provider untuk Pi Code / Pi Agent dan helper client lokal repository ini.

## Provider

| Field | Value |
|-------|-------|
| Display name | Akses Satu Api |
| Provider id | `akses-satu-api` |
| Base URL | `https://api.satuakses.top/v1` |
| Auth | Bearer API key |
| API key env var | `AKSES_SATU_API_KEY` |
| Default model | `gpt-5.5` |
| Pi API mode | `openai-completions` for chat completions |

## Environment

Create a local `.env` outside git or export variables in your shell:

```env
AKSES_SATU_API_KEY=sk-sa-REPLACE_ME
AKSES_SATU_BASE_URL=https://api.satuakses.top/v1
AKSES_SATU_DEFAULT_MODEL=gpt-5.5
```

Do not commit real API keys. `.env` and `.env.*` are ignored by git; `.env.example` contains placeholders only.

## Available Models

- `gpt-5.5`
- `claude-opus-4.8`
- `minimax-m3`
- `mimo-v2.5-pro`
- `deepseek-v4-pro`

The helper client uses `GET /models` when available and falls back to this static model list if provider model listing fails for non-auth reasons.

## Supported Endpoints

Given `AKSES_SATU_BASE_URL=https://api.satuakses.top/v1`:

- `GET /v1/models`
- `POST /v1/chat/completions`
- `POST /v1/responses`

Pi installer config uses `openai-completions` for normal chat usage. The local helper module also exposes a Responses API request helper for apps/systems that support Responses API.

## Pi Installer Configuration

The provider is defined in:

- `installer/config/models.json`
- `installer/config/settings.json` enabled model list

The API key is referenced as `$AKSES_SATU_API_KEY`; no secret is stored in source.

## Local Helper Module

TypeScript exports are available from:

```ts
import {
  createAksesSatuChatCompletion,
  createAksesSatuResponse,
  getAksesSatuModelChoices,
  listAksesSatuModels,
} from './src/providers';
```

The helper module:

- uses `AKSES_SATU_API_KEY` from environment by default;
- never logs the Authorization header;
- supports fetch injection for unit tests;
- maps 401/404/429/5xx/network/timeout/invalid JSON into safe errors;
- prioritizes live `GET /models` results and falls back to the static list when allowed.

## Manual Smoke Test

Only run this when you intentionally want to hit the real provider and have set a valid key:

```bash
export AKSES_SATU_API_KEY='sk-sa-REPLACE_ME'
export AKSES_SATU_DEFAULT_MODEL='gpt-5.5'
bash scripts/test-akses-satu-api.sh
```

The script prints `API Key: [REDACTED]` and does not print the key value. Do not store raw API responses if they contain sensitive data.
