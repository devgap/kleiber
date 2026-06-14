#!/bin/bash
# soft-token-cap.sh — Kleiber PostToolUse: HEURISTIC context-size warning. Soft — never blocks.
# Honest limitation: real token count isn't available in a hook; we proxy on transcript bytes.
set -euo pipefail
INPUT=$(cat)
TRANSCRIPT="$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)"
{ [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; } || exit 0
LIMIT="${KLEIBER_SOFT_TOKEN_BYTES:-4000000}"
BYTES="$(wc -c < "$TRANSCRIPT" 2>/dev/null | tr -d ' ' || true)"
[ -z "$BYTES" ] && exit 0
if [ "$BYTES" -gt "$LIMIT" ]; then
  echo "Kleiber soft cap: transcript ~${BYTES}B exceeds ${LIMIT}B — consider compacting or commit+summarize. (Soft warning, not enforced.)"
fi
exit 0
