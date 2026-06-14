#!/bin/bash
# loop-state.sh — Kleiber PostToolUse: deterministically maintain volatile loop state in context.md.
# The MODEL never writes these counters — this hook does. Non-blocking.
set -euo pipefail

INPUT=$(cat)
PROJECT_DIR="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -z "$PROJECT_DIR" ] && PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
CTX="$PROJECT_DIR/context.md"
[ -f "$CTX" ] || exit 0

TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)"
TINPUT="$(printf '%s' "$INPUT" | jq -c '.tool_input // {}' 2>/dev/null || true)"
HASH="$(printf '%s' "${TOOL}${TINPUT}" | { shasum -a 256 2>/dev/null || sha256sum; } | awk '{print $1}' | cut -c1-12)"

COUNT="$(grep -oE '^active_loop_count: [0-9]+' "$CTX" | awk '{print $2}' | head -1 || true)"
[ -z "$COUNT" ] && COUNT=0
COUNT=$((COUNT + 1))

TMP="$(mktemp)"
sed -e "s/^active_loop_count: .*/active_loop_count: ${COUNT}/" \
    -e "s/^last_action_hash: .*/last_action_hash: ${HASH}/" "$CTX" > "$TMP" && mv "$TMP" "$CTX"
exit 0
