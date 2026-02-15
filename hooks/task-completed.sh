#!/bin/bash
# task-completed.sh — Quality gate on task completion
# Runs tests and type checking. Blocks completion if either fails.
# The teammate gets the error output and must fix before proceeding.

set -euo pipefail

ERRORS=""

# Run tests if a test runner is available
if [ -f "package.json" ] && command -v npx &> /dev/null; then
  if npx --no-install jest --passWithNoTests --bail 2>&1; then
    echo "Tests: PASS"
  else
    ERRORS="${ERRORS}Tests failed. Fix failing tests before completing this task.\n"
  fi
elif [ -f "pyproject.toml" ] && command -v pytest &> /dev/null; then
  if pytest --tb=short -q 2>&1; then
    echo "Tests: PASS"
  else
    ERRORS="${ERRORS}Tests failed. Fix failing tests before completing this task.\n"
  fi
fi

# Run type checking if available
if [ -f "tsconfig.json" ] && command -v npx &> /dev/null; then
  if npx --no-install tsc --noEmit 2>&1; then
    echo "Types: PASS"
  else
    ERRORS="${ERRORS}TypeScript errors found. Fix type errors before completing this task.\n"
  fi
elif [ -f "pyproject.toml" ] && command -v mypy &> /dev/null; then
  if mypy . --ignore-missing-imports 2>&1; then
    echo "Types: PASS"
  else
    ERRORS="${ERRORS}Type errors found. Fix type errors before completing this task.\n"
  fi
fi

if [ -n "$ERRORS" ]; then
  echo ""
  echo "TASK COMPLETION BLOCKED"
  echo ""
  echo -e "$ERRORS"
  exit 1
fi

echo "All quality gates passed. Task completion allowed."
exit 0
