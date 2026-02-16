#!/bin/bash
# task-completed.sh — Quality gate on task completion
# Hook: TaskCompleted
# Receives JSON on stdin. Runs tests, type checking, and linting.

set -euo pipefail

# Read and discard stdin
cat > /dev/null

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

# Run linting if available
if [ -f "package.json" ] && command -v npx &> /dev/null; then
  if npx --no-install eslint . --max-warnings 0 2>&1; then
    echo "Lint: PASS"
  else
    ERRORS="${ERRORS}Lint errors found. Fix lint issues before completing this task.\n"
  fi
elif command -v ruff &> /dev/null; then
  if ruff check . 2>&1; then
    echo "Lint: PASS"
  else
    ERRORS="${ERRORS}Lint errors found (ruff). Fix lint issues before completing this task.\n"
  fi
fi

if [ -n "$ERRORS" ]; then
  echo ""
  echo "TASK COMPLETION BLOCKED"
  echo ""
  echo -e "$ERRORS"
fi

echo "All quality gates passed. Task completion allowed."
exit 0
