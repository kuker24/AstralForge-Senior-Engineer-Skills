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
curl -sS "$BASE_URL/models" \
  -H "Authorization: Bearer ${AKSES_SATU_API_KEY}" \
  | head -c 2000
echo ""

echo ""
echo "== POST /chat/completions =="
curl -sS "$BASE_URL/chat/completions" \
  -H "Authorization: Bearer ${AKSES_SATU_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"${MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Halo! Jawab singkat.\"}]}" \
  | head -c 2000
echo ""

echo ""
echo "== POST /responses =="
curl -sS "$BASE_URL/responses" \
  -H "Authorization: Bearer ${AKSES_SATU_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"${MODEL}\",\"input\":\"Jelaskan API gateway secara singkat.\"}" \
  | head -c 2000
echo ""
