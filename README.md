# Kleiber Agent TappedOut
<img width="1536" height="1024" alt="banner image homepage" src="https://github.com/user-attachments/assets/ddcdc145-45d7-43e5-83a0-44c669f3793b" />

Agent team orchestration for Claude Code. Structured roles, model routing, quality gates, and loop prevention.

Named after conductor Carlos Kleiber — one orchestrator, many virtuosos, flawless coordination.

## Why Kleiber?

Anthropic shipped native agent teams in Claude Code. Kleiber adds the opinionated layer that makes them production-ready:

- **Pre-configured roles** — 5 battle-tested spawn prompts so you don't rewrite them every session
- **Model routing** — Opus for architecture, Sonnet for implementation, Haiku for validation. Cheapest model that can reliably do the job.
- **Quality hooks** — 5 hooks enforce tests, types, and safety at every stage of the pipeline
- **Loop detection** — Ralph Loop Guard stops agents after 3 repeated errors
- **Destructive command blocker** — Blocks `rm -rf`, `git push --force`, `DROP TABLE` before execution
- **Delegate mode enforced** — Lead agent coordinates only, never implements

## Prerequisites

Agent teams are experimental and disabled by default. Enable them first:

```json
// Add to your Claude Code settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or set it in your shell:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

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

**Keyboard shortcuts** once your team is running:

| Shortcut | Action |
|----------|--------|
| `Shift+Tab` | Toggle delegate mode (lead coordinates only) |
| `Shift+Up/Down` | Switch between teammates (in-process mode) |

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
- Agent teams enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
- jq (used by hook scripts)
- Git

## Known Limitations

Agent teams are in research preview. Current constraints:

- **No session resumption** — `/resume` and `/rewind` won't restore teammates. Spawn new ones.
- **One team per session** — Teammates can't spawn their own teams.
- **Task status can lag** — Teammates may finish without marking tasks complete. Nudge the lead.
- **Split-pane needs tmux/iTerm2** — Not supported in VS Code terminal, Windows Terminal, or Ghostty. In-process mode works everywhere.

## Model Cost Reference

| Model | Input / Output per M tokens | When to Use |
|-------|----------------------------|-------------|
| Opus 4.6 | $5 / $25 | Architecture, security, compliance |
| Sonnet 4.5 | $3 / $15 | Feature implementation (default) |
| Haiku 4.5 | $1 / $5 | Validation, docs, boilerplate |

---

Built by [DevGap](https://devgap.co). Powered by Claude.
