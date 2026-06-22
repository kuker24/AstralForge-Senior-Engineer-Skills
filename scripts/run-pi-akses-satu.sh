#!/usr/bin/env bash
#
# scripts/run-pi-akses-satu.sh
#
# Launcher script that starts Pi Code / Pi Agent against the Akses Satu Api
# custom OpenAI-compatible provider. This is a defensive convenience launcher
# and the primary recommended path remains the native `pi --provider
# akses-satu-api` invocation, which is registered via
# `installer/config/models.json` and the `extensions/akses-satu-api-provider`
# extension.
#
# Note: Pi v0.79.9 does NOT honor `OPENAI_BASE_URL` for the built-in `openai`
# provider, so this launcher falls back to the native `akses-satu-api` provider
# id (already registered via `~/.pi/agent/models.json`) whenever possible.
# The `OPENAI_*` exports are kept as a documented best-effort for compatibility
# with future Pi versions or with downstream tooling that consumes them.
#
set -euo pipefail

BASE_URL="${AKSES_SATU_BASE_URL:-https://api.satuakses.top/v1}"
MODEL="${AKSES_SATU_DEFAULT_MODEL:-glm-4.6}"
PROVIDER_ID="${AKSES_SATU_PROVIDER_ID:-akses-satu-api}"

if [ -z "${AKSES_SATU_API_KEY:-}" ]; then
  echo "ERROR: AKSES_SATU_API_KEY belum diset." >&2
  echo "" >&2
  echo "Set dulu (fish):" >&2
  echo "  set -Ux AKSES_SATU_API_KEY 'sk-sa-REPLACE_ME'" >&2
  echo "  set -Ux AKSES_SATU_DEFAULT_MODEL 'glm-4.6'" >&2
  echo "  set -Ux AKSES_SATU_BASE_URL 'https://api.satuakses.top/v1'" >&2
  echo "" >&2
  echo "Atau bash/zsh:" >&2
  echo "  export AKSES_SATU_API_KEY='sk-sa-REPLACE_ME'" >&2
  echo "  export AKSES_SATU_DEFAULT_MODEL='glm-4.6'" >&2
  echo "  export AKSES_SATU_BASE_URL='https://api.satuakses.top/v1'" >&2
  exit 1
fi

# Best-effort environment exports (some downstream tools may read these).
# Pi v0.79.9 itself does not read OPENAI_BASE_URL for the openai provider.
export OPENAI_API_KEY="${AKSES_SATU_API_KEY}"
export OPENAI_BASE_URL="${BASE_URL}"
export OPENAI_API_BASE="${BASE_URL}"
export OPENAI_DEFAULT_MODEL="${MODEL}"

echo "Starting Pi with Akses Satu Api"
echo "  Provider: ${PROVIDER_ID}"
echo "  Base URL: ${BASE_URL}"
echo "  Model:    ${MODEL}"
echo "  API Key:  [REDACTED]"
echo ""

exec pi --provider "${PROVIDER_ID}" --model "${MODEL}" "$@"
