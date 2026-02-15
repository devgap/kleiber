# Kleiber
![image](https://github.com/user-attachments/assets/6e6aa56f-e08e-4000-85eb-4db342b58a47)

Agent team orchestration for Claude Code. Structured roles, model routing, quality gates, and loop prevention.

Named after conductor Carlos Kleiber — one orchestrator, many virtuosos, flawless coordination.

## Install

```bash
# Add the marketplace
/plugin marketplace add Devgapperk/kleiber

# Install the plugin
/plugin install kleiber@kleiber-marketplace
```

## What You Get

**Slash command**: `/kleiber` — creates and orchestrates agent teams with a single command.

**5 agent roles** with pre-configured spawn prompts and model routing:

| Role | Model | Purpose |
|------|-------|---------|
| Architect | Opus | Design, review, approve. Never writes code. |
| Engineer-Frontend | Sonnet | UI components, state, accessibility, tests |
| Engineer-Backend | Sonnet | Routes, queries, business logic, integration tests |
| Validator | Haiku | Runs tests, types, lint. Read-only. |
| Scribe | Haiku | Docs, changelog, decision records |

**5 hooks** enforcing quality at every stage:

| Hook | Trigger | What It Does |
|------|---------|--------------|
| stop-loop-guard | Stop | Detects Ralph Loops (agent spinning on same error 3+ times) |
| task-completed | TaskCompleted | Blocks completion if tests or types fail |
| teammate-idle | TeammateIdle | Prevents idle if uncommitted changes exist |
| post-edit-verify | PostToolUse (Write/Edit) | Type-checks after every file edit |
| block-destructive | PreToolUse (Bash) | Blocks rm -rf, force push, DROP TABLE |

**Orchestration skill** with model routing rules, task decomposition protocol, quality gates, and anti-pattern detection.

## Usage

Start Claude Code and use the `/kleiber` command:

```
/kleiber Build user authentication with login, signup, and password reset
```

Or describe the team you want directly:

```
Create an agent team to build [feature]. Spawn architect (opus), frontend
engineer (sonnet), backend engineer (sonnet), validator (haiku), scribe (haiku).
Use delegate mode.
```

## Example Prompts

**Full feature build:**
```
/kleiber Implement a payment processing module with Stripe integration
```

**Parallel code review:**
```
Create an agent team to review PR #142. Three reviewers: security, performance,
test coverage. Have them report independently.
```

**Bug investigation:**
```
Users report [symptom]. Create a team with 4 teammates investigating competing
hypotheses. Have them challenge each other's theories.
```

## Requirements

- Claude Code CLI
- jq (used by hook scripts)
- Git

## Model Cost Reference

| Model | Input / Output per M tokens | When to Use |
|-------|----------------------------|-------------|
| Opus 4.6 | $5 / $25 | Architecture, security, compliance |
| Sonnet 4.5 | $3 / $15 | Feature implementation (default) |
| Haiku 4.5 | $1 / $5 | Validation, docs, boilerplate |

---

Built by [DevGap](https://devgap.co). Powered by Claude.
