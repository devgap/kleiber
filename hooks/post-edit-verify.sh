#!/bin/bash
# post-edit-verify.sh — Type-checks after every file edit
# Catches hallucinated imports and wrong signatures on the first edit,
# not after 10 files of broken code.

set -euo pipefail

# Get the file that was just edited from environment
EDITED_FILE="${CLAUDE_EDITED_FILE:-}"

# Only check TypeScript/TSX files
if [[ "$EDITED_FILE" =~ \.(ts|tsx)$ ]]; then
  if [ -f "tsconfig.json" ] && command -v npx &> /dev/null; then
    OUTPUT=$(npx --no-install tsc --noEmit 2>&1 || true)
    if echo "$OUTPUT" | grep -q "error TS"; then
      # Filter to only errors in the edited file
      FILE_ERRORS=$(echo "$OUTPUT" | grep "$EDITED_FILE" || true)
      if [ -n "$FILE_ERRORS" ]; then
        echo "TYPE ERRORS in $EDITED_FILE"
        echo ""
        echo "$FILE_ERRORS"
        echo ""
        echo "Fix these before continuing to the next file."
        exit 1
      fi
    fi
  fi
fi

# Only check Python files
if [[ "$EDITED_FILE" =~ \.py$ ]]; then
  if command -v mypy &> /dev/null; then
    OUTPUT=$(mypy "$EDITED_FILE" --ignore-missing-imports 2>&1 || true)
    if echo "$OUTPUT" | grep -q "error:"; then
      echo "TYPE ERRORS in $EDITED_FILE"
      echo ""
      echo "$OUTPUT"
      echo ""
      echo "Fix these before continuing to the next file."
      exit 1
    fi
  fi
fi

exit 0
