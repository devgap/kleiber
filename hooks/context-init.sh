#!/bin/bash
# context-init.sh — Kleiber SessionStart: detect venture, scaffold context.md, surface AGENTS.md.
# Reads JSON stdin (.cwd). Idempotent. Non-blocking.
set -euo pipefail

INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -z "$PROJECT_DIR" ] && PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

VENTURE=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REMOTE="$(git remote get-url origin 2>/dev/null || true)"
  [ -n "$REMOTE" ] && VENTURE="$(basename -s .git "$REMOTE")"
fi
[ -z "$VENTURE" ] && VENTURE="$(basename "$PROJECT_DIR")"

if [ ! -f "context.md" ]; then
  if [ -f "$PLUGIN_ROOT/docs/templates/context.template.md" ]; then
    cp "$PLUGIN_ROOT/docs/templates/context.template.md" "context.md"
  else
    printf 'current_goal: \nactive_loop_count: 0\nlast_action_hash: \n' > "context.md"
  fi
fi

echo "Kleiber: venture=${VENTURE}"
if [ -f "AGENTS.md" ]; then
  echo "Kleiber: loaded AGENTS.md for ${VENTURE}"
else
  echo "Kleiber: no repo AGENTS.md (central base ventures/${VENTURE}.md applies if present)"
fi
exit 0
