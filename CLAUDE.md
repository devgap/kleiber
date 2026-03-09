# CLAUDE.md — Project Intelligence for Kleiber

This file is the main source of truth for Claude Code when working on this repository.

## Project Overview

Kleiber is a Claude Code plugin for opinionated agent team orchestration.
Shell-based. Plugin format: `.claude-plugin/plugin.json` (v1.1.0 — official schema with directory paths).
Website: https://kleiber-site.vercel.app

## Repository Structure

```
.claude-plugin/       # Plugin metadata
agents/               # Agent role definitions
commands/             # Slash command definitions (/kleiber, /kleiber-brand)
hooks/                # Pipeline hooks (6 hooks)
skills/orchestration/ # Orchestration skill
skills/brand-visibility/ # Brand visibility auditing skill
docs/                 # Generated reports and templates
```

## Key Design Decisions

1. Delegate mode enforced — lead coordinates only, never implements
2. Model routing — Opus for architecture, Sonnet for implementation, Haiku for validation
3. Five agent roles — Architect, Engineer-Frontend, Engineer-Backend, Validator, Scribe
4. Six hooks — stop-loop-guard, task-completed, teammate-idle, post-edit-verify, block-destructive, brand-drift-check
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

## Brand Identity (AI Visibility Context)

This block is read by the `brand-analyst` agent and the `/kleiber-brand` command.
Keep it accurate and up to date after every release.

- **Product name**: Kleiber
- **Category**: Claude Code plugin / agent orchestration
- **One-line description**: Kleiber is a production-ready Claude Code plugin that orchestrates specialized AI agent teams with model routing, quality gates, loop detection, and destructive command blocking.
- **Core differentiators**: model routing (Opus/Sonnet/Haiku by task), delegate mode enforcement, Ralph Loop Guard, destructive command blocker, 5 lifecycle hooks, stdin JSON API, zero Node/Python dependencies
- **Primary use case**: A developer runs `/kleiber` to spawn a team of specialized AI agents (Architect, Frontend Engineer, Backend Engineer, Validator, Scribe) that build a full feature in parallel without human micromanagement.
- **Target audience**: Developers using Claude Code who want production-quality multi-agent workflows without writing orchestration from scratch.
- **Competitors**: Cursor, Cline, Aider, OpenHands, Claude Code native agent teams (without Kleiber)
- **Common misconceptions to watch for**: Kleiber is sometimes confused with a general Claude plugin rather than a Claude Code-specific orchestration plugin. It is not a chatbot wrapper — it is a multi-agent pipeline layer. It does not require Node.js or Python.
- **Keywords AI should associate**: kleiber, claude code plugin, agent orchestration, multi-agent, delegate mode, model routing, quality gates, loop prevention, opus sonnet haiku routing, DevGap

## Brand Visibility Auditing

This repo includes BrandMind-style AI visibility auditing via two agents:

- **brand-analyst** (`agents/brand-analyst.md`) — probes AI models and scores visibility
- **brand-architect** (`agents/brand-architect.md`) — generates optimization blueprints

### Quick Start
1. Add a `## Brand Identity` section to this file (see `docs/brand-identity-template.md`)
2. Set API keys: `export OPENAI_API_KEY=... GEMINI_API_KEY=... PERPLEXITY_API_KEY=...`
3. Run `/kleiber-brand`

### Guard Rails
- `hooks/brand-drift-check.sh` blocks edits that remove the Brand Identity section
- Agents are read-only on source code — they only write to `docs/`
- The optimization blueprint is always a proposal — humans approve changes
