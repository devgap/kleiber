#!/bin/bash
# stop-loop-guard.sh — Ralph Loop Detection (Ralph Wiggum 2.0)
# Scans transcript for repeated errors. If an agent hit the same error 3+
# times or retried 4+ times, forces stop and report instead of burning tokens.

set -euo pipefail

TRANSCRIPT="${CLAUDE_TRANSCRIPT:-}"
if [ -z "$TRANSCRIPT" ]; then
  exit 0
fi

# Count repeated error patterns
REPEATED_ERRORS=$(echo "$TRANSCRIPT" | grep -oE 'Error:.*|error:.*|FAIL.*|Cannot find.*|Module not found.*' | sort | uniq -c | sort -rn | head -5)

# Check for retry language
RETRY_COUNT=$(echo "$TRANSCRIPT" | grep -ciE 'let me try again|trying again|another attempt|retry|retrying|let me fix' || true)

# Check for same error appearing 3+ times
HAS_LOOP=false
while IFS= read -r line; do
  COUNT=$(echo "$line" | awk '{print $1}')
  if [ -n "$COUNT" ] && [ "$COUNT" -ge 3 ] 2>/dev/null; then
    HAS_LOOP=true
    break
  fi
done <<< "$REPEATED_ERRORS"

if [ "$HAS_LOOP" = true ] || [ "$RETRY_COUNT" -ge 4 ]; then
  echo "RALPH LOOP DETECTED"
  echo ""
  echo "This agent has been spinning on the same error or retrying excessively."
  echo "Retry count: $RETRY_COUNT"
  echo ""
  echo "Top repeated errors:"
  echo "$REPEATED_ERRORS"
  echo ""
  echo "ACTION: Stop and report the issue to the team lead instead of continuing."
  exit 1
fi

exit 0
