#!/bin/bash
# teammate-idle.sh — Prevents idle if uncommitted work exists
# Hook: TeammateIdle
# Receives JSON on stdin. Checks for uncommitted changes.

set -euo pipefail

# Read and discard stdin
cat > /dev/null

if ! command -v git &> /dev/null; then
  exit 0
fi

if ! git rev-parse --is-inside-work-tree &> /dev/null 2>&1; then
  exit 0
fi

CHANGES=$(git status --porcelain 2>/dev/null || true)

if [ -n "$CHANGES" ]; then
  CHANGED_COUNT=$(echo "$CHANGES" | wc -l | tr -d ' ')
  echo "UNCOMMITTED WORK DETECTED ($CHANGED_COUNT files)"
  echo ""
  echo "You have uncommitted changes. Before going idle:"
  echo "1. Commit your current work with a descriptive message"
  echo "2. Or stash changes if the work is incomplete"
  echo "3. Or discard changes if they were exploratory"
  echo ""
  echo "Changed files:"
  echo "$CHANGES"
fi

exit 0
