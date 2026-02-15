#!/bin/bash
# teammate-idle.sh — Prevents idle if uncommitted work exists
# Checks for uncommitted changes. Keeps teammate working until they commit.

set -euo pipefail

if ! command -v git &> /dev/null; then
  exit 0
fi

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &> /dev/null 2>&1; then
  exit 0
fi

# Check for uncommitted changes
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
  exit 1
fi

exit 0
