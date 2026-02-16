#!/bin/bash
# post-edit-verify.sh — Type-checks after every file edit
# Hook: PostToolUse (Write/Edit)
# Receives JSON on stdin with tool_input containing the edited file path
# Exit 0 always (post hooks can't block, but output is shown to agent)

set -euo pipefail

INPUT=$(cat)
EDITED_FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$EDITED_FILE" ]; then
  exit 0
fi

# TypeScript/TSX/JS/JSX check
if [[ "$EDITED_FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
  if [ -f "tsconfig.json" ] && command -v npx &> /dev/null; then
    OUTPUT=$(npx --no-install tsc --noEmit 2>&1 || true)
    if echo "$OUTPUT" | grep -q "error TS"; then
      FILE_ERRORS=$(echo "$OUTPUT" | grep "$EDITED_FILE" || true)
      if [ -n "$FILE_ERRORS" ]; then
        echo "TYPE ERRORS in $EDITED_FILE"
        echo ""
        echo "$FILE_ERRORS"
        echo ""
        echo "Fix these before continuing to the next file."
      fi
    fi
  fi
fi

# Python check
if [[ "$EDITED_FILE" =~ \.py$ ]]; then
  if command -v mypy &> /dev/null; then
    OUTPUT=$(mypy "$EDITED_FILE" --ignore-missing-imports 2>&1 || true)
    if echo "$OUTPUT" | grep -q "error:"; then
      echo "TYPE ERRORS in $EDITED_FILE"
      echo ""
      echo "$OUTPUT"
      echo ""
      echo "Fix these before continuing to the next file."
    fi
  fi
fi

exit 0
