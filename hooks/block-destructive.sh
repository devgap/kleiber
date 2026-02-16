#!/bin/bash
# block-destructive.sh — Blocks dangerous bash commands
# Hook: PreToolUse (Bash)
# Receives JSON on stdin with tool_input.command
# Exit 2 to block, exit 0 to allow

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Check for destructive patterns
BLOCKED=""

if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive.*--force|-[a-zA-Z]*f[a-zA-Z]*r)(\s|$)'; then
  BLOCKED="rm -rf is not allowed in orchestrated sessions. Use targeted rm commands or ask the lead."
fi

if echo "$COMMAND" | grep -qiE 'git\s+push\s+.*--force|git\s+push\s+-f\b'; then
  BLOCKED="git push --force is not allowed in orchestrated sessions. Use --force-with-lease or ask the lead."
fi

if echo "$COMMAND" | grep -qiE 'git\s+reset\s+--hard'; then
  BLOCKED="git reset --hard is not allowed in orchestrated sessions. Use git stash or ask the lead."
fi

if echo "$COMMAND" | grep -qiE 'chmod\s+(777|a\+rwx)'; then
  BLOCKED="chmod 777 is not allowed in orchestrated sessions. Use specific permissions or ask the lead."
fi

if echo "$COMMAND" | grep -qiE 'DROP\s+(TABLE|DATABASE|SCHEMA)'; then
  BLOCKED="DROP TABLE/DATABASE/SCHEMA is not allowed in orchestrated sessions. Ask the lead for approval."
fi

if echo "$COMMAND" | grep -qiE 'TRUNCATE\s+TABLE'; then
  BLOCKED="TRUNCATE TABLE is not allowed in orchestrated sessions. Ask the lead for approval."
fi

if [ -n "$BLOCKED" ]; then
  echo '{"decision":"block","reason":"'"$BLOCKED"'"}' >&1
  exit 2
fi

exit 0
