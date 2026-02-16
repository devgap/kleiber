#!/bin/bash
# stop-loop-guard.sh — Ralph Loop Detection (Ralph Wiggum 2.0)
# Hook: Stop
# Receives JSON on stdin with transcript_path
# Scans transcript for repeated errors. Outputs warning if loop detected.

set -euo pipefail

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

# Extract recent content from transcript (last 50 lines)
RECENT=$(tail -50 "$TRANSCRIPT_PATH" 2>/dev/null || true)

if [ -z "$RECENT" ]; then
  exit 0
fi

# Count repeated error patterns (escaped quotes for grep in JSONL)
REPEATED_ERRORS=$(echo "$RECENT" | grep -oE '\"Error:.*\"|\"error:.*\"|\"FAIL.*\"|\"Cannot find.*\"|\"Module not found.*\"' | sort | uniq -c | sort -rn | head -5 2>/dev/null || true)

# Count retry language
RETRY_COUNT=$(echo "$RECENT" | grep -ciE 'let me try again|trying again|another attempt|retry|retrying|let me fix' 2>/dev/null || echo "0")

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
fi

exit 0
