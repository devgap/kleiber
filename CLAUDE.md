# CLAUDE.md — Project Intelligence for Kleiber

This file is the main source of truth for Claude Code when working on this repository.

## Project Overview

Kleiber is a Claude Code plugin for opinionated agent team orchestration.
Shell-based. Plugin format: `.claude-plugin/plugin.json`.

## Repository Structure

```
.claude-plugin/       # Plugin metadata
agents/               # Agent role definitions
commands/             # Slash command definitions (/kleiber)
hooks/                # Pipeline hooks (5 hooks)
skills/orchestration/ # Orchestration skill
```

## Key Design Decisions

1. Delegate mode enforced — lead coordinates only, never implements
2. Model routing — Opus for architecture, Sonnet for implementation, Haiku for validation
3. Five agent roles — Architect, Engineer-Frontend, Engineer-Backend, Validator, Scribe
4. Five hooks — stop-loop-guard, task-completed, teammate-idle, post-edit-verify, block-destructive
5. Shell-only — bash scripts, no Node/Python dependencies
6. Stdin JSON API — all hooks receive JSON on stdin, parse with jq

## Coding Conventions

- `#!/bin/bash` and `set -euo pipefail` in every script
- Scripts must be executable (`chmod +x`)
- Hooks read stdin: `INPUT=$(cat)` then parse with `jq`
- Pre-hooks exit 2 to block, exit 0 to allow
- Post-hooks always exit 0
- Suppress errors with `2>/dev/null` and `|| true`

## Testing

- `shellcheck` on all .sh files
- `jq . < file.json` for JSON validation
- Live test with CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

## Do NOT

- Add Node.js, Python, or other runtime dependencies
- Read hook inputs from environment variables (use stdin JSON API)
- Use rm -rf, git push --force, git reset --hard, chmod 777, or DROP TABLE

