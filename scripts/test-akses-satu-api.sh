#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${AKSES_SATU_BASE_URL:-https://api.satuakses.top/v1}"
MODEL="${AKSES_SATU_DEFAULT_MODEL:-gpt-5.5}"

if [ -z "${AKSES_SATU_API_KEY:-}" ]; then
  echo "ERROR: AKSES_SATU_API_KEY belum diset."
  echo "Set dulu dengan:"
  echo "export AKSES_SATU_API_KEY='sk-sa-REPLACE_ME'"
  exit 1
fi

echo "Testing Akses Satu Api provider"
echo "Base URL: $BASE_URL"
echo "Model: $MODEL"
echo "API Key: [REDACTED]"

echo ""
echo "== GET /models =="
response="$(curl -sS "$BASE_URL/models" \
  -H "Authorization: Bearer ${AKSES_SATU_API_KEY}")"

printf '%.2000s\n' "$response"
echo ""

echo ""
echo "== POST /chat/completions =="
response="$(curl -sS "$BASE_URL/models" \
  -H "Authorization: Bearer ${AKSES_SATU_API_KEY}")"

printf '%.2000s\n' "$response"
echo ""

echo ""
echo "== POST /responses =="
response="$(curl -sS "$BASE_URL/models" \
  -H "Authorization: Bearer ${AKSES_SATU_API_KEY}")"

printf '%.2000s\n' "$response"
echo ""
