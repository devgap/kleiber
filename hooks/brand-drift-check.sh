#!/bin/bash
# brand-drift-check.sh — Warns when edits to README/CLAUDE.md/docs/ may
# contradict the established AI visibility baseline.
# Hook: PostToolUse (Write|Edit)
# Receives JSON on stdin with tool_input.file_path and tool_input.new_content
# Post-hooks always exit 0 (never block — only warn)
set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
NEW_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_content // empty' 2>/dev/null)

# Only act on documentation files
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

if ! echo "$FILE_PATH" | grep -qE '(README\.md|CLAUDE\.md|docs/.+\.md)'; then
  exit 0
fi

# Only run the check if a brand visibility baseline exists
REPORT="docs/brand-visibility-report.md"
if [ ! -f "$REPORT" ]; then
  exit 0
fi

WARNINGS=""

# Check 1: Brand Identity block still present in CLAUDE.md edits
if echo "$FILE_PATH" | grep -q "CLAUDE\.md"; then
  if [ -n "$NEW_CONTENT" ] && ! echo "$NEW_CONTENT" | grep -q "## Brand Identity"; then
    WARNINGS="${WARNINGS}WARNING: The Brand Identity block appears to have been removed from CLAUDE.md. This block is required for /kleiber-brand audits. Re-add it if this was accidental.\n"
  fi
fi

# Check 2: Product name still present in README edits
if echo "$FILE_PATH" | grep -q "README\.md"; then
  PRODUCT=$(grep -m1 "Product name:" "$REPORT" 2>/dev/null | sed 's/.*: *//' | tr -d '`*' | xargs 2>/dev/null || true)
  if [ -n "$PRODUCT" ] && [ -n "$NEW_CONTENT" ] && ! echo "$NEW_CONTENT" | grep -qi "$PRODUCT"; then
    WARNINGS="${WARNINGS}WARNING: The product name '$PRODUCT' does not appear in the new README.md content. If you renamed the product, run /kleiber-brand --re-audit to update the visibility baseline.\n"
  fi
fi

# Check 3: Warn if a known competitor is now being described favourably
# (competitors listed in the report under "Competitor Mentions")
COMPETITORS=$(grep -A2 "Competitor Mentions" "$REPORT" 2>/dev/null | grep -oE '\b(Cursor|Cline|Aider|OpenHands|Copilot|Windsurf)\b' | sort -u | tr '\n' '|' | sed 's/|$//' 2>/dev/null || true)
if [ -n "$COMPETITORS" ] && [ -n "$NEW_CONTENT" ]; then
  COMP_MATCH=$(echo "$NEW_CONTENT" | grep -iE "($COMPETITORS) is (better|superior|recommended|preferred)" 2>/dev/null || true)
  if [ -n "$COMP_MATCH" ]; then
    WARNINGS="${WARNINGS}WARNING: The edited doc contains language that may position a competitor favourably: \"$COMP_MATCH\". Review this before committing — it may hurt AI visibility scores.\n"
  fi
fi

# Output warnings if any
if [ -n "$WARNINGS" ]; then
  printf "\nBrand Drift Check:\n"
  printf '%b' "$WARNINGS"
  printf "Run /kleiber-brand --re-audit to refresh your AI visibility scores after significant doc changes.\n\n"
fi

# Post-hooks always exit 0
exit 0
