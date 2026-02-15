#!/bin/bash
# block-destructive.sh — Blocks dangerous bash commands
# Prevents rm -rf, force push, and DROP TABLE from being executed.

set -euo pipefail

COMMAND="${CLAUDE_BASH_COMMAND:-}"

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Check for destructive patterns
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive.*--force|-[a-zA-Z]*f[a-zA-Z]*r)\s'; then
  echo "BLOCKED: rm -rf is not allowed in orchestrated sessions."
  echo "If you need to remove files, use targeted rm commands or ask the lead."
  exit 1
fi

if echo "$COMMAND" | grep -qiE 'git\s+push\s+.*--force|git\s+push\s+-f\b'; then
  echo "BLOCKED: git push --force is not allowed in orchestrated sessions."
  echo "Use git push --force-with-lease if you must overwrite, or ask the lead."
  exit 1
fi

if echo "$COMMAND" | grep -qiE 'DROP\s+(TABLE|DATABASE|SCHEMA)'; then
  echo "BLOCKED: DROP TABLE/DATABASE/SCHEMA is not allowed in orchestrated sessions."
  echo "If you need to drop a table, ask the lead for approval first."
  exit 1
fi

if echo "$COMMAND" | grep -qiE 'TRUNCATE\s+TABLE'; then
  echo "BLOCKED: TRUNCATE TABLE is not allowed in orchestrated sessions."
  exit 1
fi

exit 0
