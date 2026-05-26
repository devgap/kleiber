# Claude Certified Architect (CCA) — How Kleiber Trains You

Kleiber is the CCA exam content practiced in production form.

> The Claude Certified Architect, Foundations is Anthropic's first proctored technical credential. 60 questions, 120 minutes, $99. Launched 12 March 2026. Five domains: agentic architecture, MCP, Claude Code config, structured output, reliability. Every domain maps to something Kleiber already enforces.

## Mapping: Kleiber → CCA Domains

| CCA Domain | Weight | Kleiber Feature That Trains It |
|---|---|---|
| 1. Agentic Architecture & Orchestration | 27% | Spawn protocol, file ownership per role, delegate-mode lead, PRIOR FIRE WIN coordinator pattern |
| 2. Tool Design & MCP Integration | 18% | Role-scoped tool access (Engineer-Frontend cannot touch `server/`), `agents/*.md` frontmatter |
| 3. Claude Code Configuration & Workflows | 20% | `CLAUDE.md` as source of truth, `commands/*.md` slash commands, `hooks/hooks.json` lifecycle |
| 4. Prompt Engineering & Structured Output | 20% | Hooks (programmatic) vs spawn prompts (guidance), `stop-loop-guard`, `post-edit-verify` |
| 5. Context Management & Reliability | 15% | PRIOR FIRE WIN governance, retry budgets, escalation, context-exhaustion handoffs |

Every `/kleiber` build practices Domains 1 + 2 + 3 by default. Every hook firing is Domain 4. Every PRIOR FIRE WIN cycle is Domain 5.

## The Single Most Tested Concept

Across all five domains, the exam consistently rewards one principle: **programmatic enforcement over prompt-based guidance**.

When a behaviour MUST hold, encode it as code (hook, schema, validator, pre-check). When it's a *preference*, use a prompt. Candidates who blur this distinction fail the exam.

Kleiber bakes this in:
- `block-destructive` hook prevents `rm -rf` — it doesn't ASK the agent not to
- `task-completed` hook blocks completion when tests fail — it doesn't suggest re-running
- `post-edit-verify` type-checks every edit programmatically — it doesn't prompt-instruct
- The Architect's "never write code" rule is a prompt; the Validator's read-only constraint is enforced by file scope

## The Seven Anti-Patterns Kleiber Catches

| # | Anti-Pattern | How Kleiber Prevents It |
|---|---|---|
| 1 | Few-shot examples to enforce tool ordering | Spawn-prompt prerequisites + delegate mode |
| 2 | Self-reported model confidence for escalation | Deterministic model routing by role |
| 3 | Batch API for blocking workflows | Kleiber agents run realtime by default |
| 4 | Larger context to fix attention dilution | Per-teammate task slicing, Scribe-summary handoffs |
| 5 | Empty results on subagent failure | Validator returns structured failure with file:line |
| 6 | All tools to all agents | Hard file-ownership constraints per role |
| 7 | Prompt-only JSON enforcement | `post-edit-verify` hook + type-check validation |

## Study Path

Anthropic Academy is free at https://anthropic.skilljar.com/. The official 13-course track plus Kleiber hands-on practice is enough preparation.

| Phase | Resource | Where Kleiber Helps |
|---|---|---|
| Week 1–2 | Claude 101 + AI Fluency | — |
| Week 3–5 | Building with the Claude API (8.1h) | Domains 1, 4 — practice in `/kleiber` builds |
| Week 6–7 | MCP Intro + MCP Advanced | Domain 2 — practice via Kleiber agent scoping |
| Week 8–9 | Claude Code in Action | Domain 3 — Kleiber IS this config |
| Week 10–11 | Practice questions | Spawn `cca-coach` during Kleiber runs |
| Week 12 | Anti-patterns review | All 7 are encoded in this doc + the coach |

## Use The CCA Coach

```
/kleiber --learn Build payment processing with Stripe
```

This spawns `cca-coach` (Haiku) alongside the team. The coach:
- Annotates each architectural decision with the CCA domain it practices
- Flags anti-patterns BEFORE teammates ship them
- Prints a session recap mapping what you practiced to what's on the exam

The coach is read-only and silent by default. It only surfaces when something is genuinely worth marking.

## Exam Details

- **Format**: 60 questions, 120 minutes, proctored, no external resources
- **Cost**: $99 USD (free for the first 5,000 Anthropic Partner Network employees)
- **Passing**: 720 / 1000, scaled across five domains
- **Register**: https://anthropic.skilljar.com/
- **Anchored to 6 scenario contexts** — Customer Support Resolution Agent, Code Generation with Claude Code, Multi-Agent Research System, Developer Productivity with Claude, Claude Code for CI/CD, Structured Data Extraction. 4 of 6 appear on any given sitting.

## Why The Credential Matters

The CCA is the first AI credential where preparing for it makes you better at the job, not just better at the test. The exam measures architectural judgment under production scenarios — the exact judgment that Kleiber forces you to practice every time you spawn a team.

Engineers who use Kleiber daily are passively preparing for Domains 1–5. The coach makes that preparation explicit. The exam validates it.

## Disclaimer

Kleiber and DevGap are not affiliated with Anthropic beyond using Claude. The CCA exam is Anthropic's. This doc is a mapping aid, not a study replacement. Anthropic Academy materials at https://anthropic.skilljar.com/ are the authoritative source.
