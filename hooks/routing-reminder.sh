#!/bin/bash
# routing-reminder.sh — Kleiber PreToolUse(Task): remind orchestrator of model x effort routing.
# Reads canonical routing.json. Non-blocking (exit 0).
set -euo pipefail
cat > /dev/null
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
RJSON="$PLUGIN_ROOT/routing.json"
[ -f "$RJSON" ] || exit 0
echo "Kleiber routing (model × effort) — choose per task; venture AGENTS.md overrides win:"
jq -r '.tiers | to_entries[] | "  \(.key): \(.value.label) — \(.value.use_for)"' "$RJSON" 2>/dev/null || true
echo "  effort: low→max (default high). Hardest/security ⇒ require plan approval."
exit 0
