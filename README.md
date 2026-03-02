# Kleiber Agent TappedOut
<img width="1536" height="1024" alt="banner image homepage" src="https://github.com/user-attachments/assets/ddcdc145-45d7-43e5-83a0-44c669f3793b" />

Agent team orchestration for Claude Code. Structured roles, model routing, quality gates, and loop prevention.

Named after conductor Carlos Kleiber — one orchestrator, many virtuosos, flawless coordination.

## Why Kleiber?

Anthropic shipped native agent teams in Claude Code. Kleiber adds the opinionated layer that makes them production-ready:

- **Pre-configured roles** — 7 agent roles with battle-tested spawn prompts so you don't rewrite them every session
- **Model routing** — Opus for architecture, Sonnet for implementation, Haiku for validation. Cheapest model that can reliably do the job.
- **Quality hooks** — 6 hooks enforce tests, types, safety, and brand consistency at every stage of the pipeline
- **Loop detection** — Ralph Loop Guard stops agents after 3 repeated errors
- **Destructive command blocker** — Blocks `rm -rf`, `git push --force`, `DROP TABLE` before execution
- **Delegate mode enforced** — Lead agent coordinates only, never implements
- **AI Visibility Auditing** — BrandMind-style probes that score how ChatGPT, Gemini, and Perplexity perceive your product, with automated optimization blueprints

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

**Slash commands**:
- `/kleiber` — creates and orchestrates agent teams with a single command
- `/kleiber-brand` — runs a full AI brand visibility audit

**7 agent roles** with pre-configured spawn prompts and model routing:

| Role | Model | Purpose |
|------|-------|---------|
| Architect | Opus | Design, review, approve. Never writes code. |
| Engineer-Frontend | Sonnet | UI components, state, accessibility, tests |
| Engineer-Backend | Sonnet | Routes, queries, business logic, integration tests |
| Validator | Haiku | Runs tests, types, lint. Read-only. |
| Scribe | Haiku | Docs, changelog, decision records |
| Brand Analyst | Sonnet | Probes AI models, scores visibility, detects misinformation |
| Brand Architect | Sonnet | Reads visibility gaps, produces optimization blueprint |

**6 hooks** enforcing quality at every stage:

| Hook | Trigger | What It Does |
|------|---------|--------------|
| stop-loop-guard | Stop | Detects Ralph Loops (agent spinning on same error 3+ times) |
| task-completed | TaskCompleted | Blocks completion if tests or types fail |
| teammate-idle | TeammateIdle | Prevents idle if uncommitted changes exist |
| post-edit-verify | PostToolUse (Write/Edit) | Type-checks after every file edit |
| block-destructive | PreToolUse (Bash) | Blocks rm -rf, force push, DROP TABLE |
| brand-drift-check | PostToolUse (Write/Edit) | Warns when doc edits contradict AI visibility baseline |

**2 skills**:
- **Orchestration** — model routing rules, task decomposition protocol, quality gates, and anti-pattern detection
- **Brand Visibility** — AI probe patterns, scoring rubric, gap detection, and optimization blueprint patterns

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

## AI Visibility Auditing

Kleiber includes BrandMind-style AI visibility auditing that measures how ChatGPT, Gemini, and Perplexity perceive and recommend your product.

**What it does:**

1. **Brand Analyst** probes each AI model with 5 structured prompts (identity, category, weakness, competitor, recommendation)
2. Scores responses across 4 dimensions: Mention (0-25), Accuracy (0-25), Recommendation Rank (0-25), Sentiment (0-25)
3. Detects gaps — displacement, accuracy, coverage, category, and authority
4. **Brand Architect** generates an optimization blueprint with specific content patches
5. **Brand drift hook** warns in real-time when doc edits contradict your visibility baseline

**Setup:**

```bash
# Set one or more API keys (missing keys are skipped gracefully)
export OPENAI_API_KEY=sk-...
export GEMINI_API_KEY=...
export PERPLEXITY_API_KEY=pplx-...
```

**Run an audit:**

```
/kleiber-brand
/kleiber-brand --competitors "Cursor, Cline, Aider"
/kleiber-brand --models "chatgpt,perplexity"
/kleiber-brand --re-audit
```

**Output:**
- `docs/brand-visibility-report.md` — scores, gap table, raw probe responses, and optimization blueprint
- `docs/brand-identity-template.md` — template for adding a Brand Identity block to your `CLAUDE.md`

The `## Brand Identity` section in `CLAUDE.md` serves as the ground truth that probe responses are scored against. See `docs/brand-identity-template.md` for the format.

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

Built by [DevGap](https://devgap.com). Powered by Claude.
