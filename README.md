# Kleiber
<img width="1536" height="1024" alt="banner image homepage" src="https://github.com/user-attachments/assets/ddcdc145-45d7-43e5-83a0-44c669f3793b" />

One command. A whole team.

Type `/kleiber` and describe what you want. Kleiber figures out the team, picks the right models, enforces quality, and delivers — no configuration required.

**Website:** [kleiber.sh](https://kleiber.sh) | **By:** [DevGap](https://devgap.uk) | [AI Plumber](https://aiplumber.dev)

## How It Works

```
/kleiber Build a payment system with Stripe integration
```

That's it. Kleiber handles everything behind the scenes:

1. **Reads your request** and decides what roles are needed
2. **Spawns the right team** — designers, builders, testers, documenters
3. **Routes each task to the right model** — expensive models for hard decisions, cheap models for grunt work
4. **Enforces quality** — every change is tested, type-checked, and verified before it ships
5. **Catches mistakes** — if an agent gets stuck or makes an error, Kleiber stops it, fixes it, and moves on
6. **Documents everything** — decisions, changes, and outcomes are logged automatically

You just describe what you want in plain English. Kleiber does the rest.

## Install

```bash
/plugin marketplace add Devgapperk/kleiber
/plugin install kleiber@kleiber-marketplace
```

Two commands. Done.

## What People Build With Kleiber

**"Build user auth with login, signup, and password reset"**
→ Kleiber designs the flow, builds frontend + backend in parallel, tests everything, writes the docs.

**"Review PR #142 for security, performance, and test coverage"**
→ Three independent reviewers check the code simultaneously and report back.

**"Users report slow dashboard loads — investigate"**
→ Multiple agents pursue different hypotheses, challenge each other, converge on root cause, fix it.

**"Build a compliance platform for Belgian work permits"**
→ Kleiber decomposed a full PRD into 12 tasks, built RBAC with 8 roles, document validation with OCR, and a traffic light dashboard. Caught 3 security issues before production. [Full case study →](https://kleiber.sh)

## What Happens Under the Hood

You don't need to know this to use Kleiber. But if you're curious:

<details>
<summary>Team roles</summary>

Kleiber assembles teams from 7 specialized roles:

| Who | What they do |
|-----|-------------|
| Architect | Designs the plan. Reviews decisions. Never writes code. |
| Frontend Engineer | Builds the UI. Tests every component. |
| Backend Engineer | Builds the API. Tests every endpoint. |
| Validator | Tests everything. Read-only — can't break anything. |
| Scribe | Documents what happened and why. |
| Brand Analyst | Checks how AI models perceive your product. |
| Brand Architect | Creates a plan to improve AI visibility. |

Not every task needs every role. Kleiber picks what fits.
</details>

<details>
<summary>Model routing</summary>

Kleiber automatically picks the right model for each task:

- **Hard decisions** (architecture, security, compliance) → most capable model
- **Building** (features, APIs, UI) → balanced model
- **Grunt work** (tests, docs, validation) → fastest, cheapest model

This saves 40-60% on token costs compared to running everything on the most expensive model.
</details>

<details>
<summary>Quality gates</summary>

Six automatic checks run throughout every build:

- **Loop detection** — stops agents that get stuck repeating the same error
- **Test gate** — blocks completion until tests pass
- **Idle check** — keeps agents working until they commit
- **Edit verification** — type-checks every file change instantly
- **Destructive blocker** — prevents dangerous commands like `rm -rf` or force push
- **Brand drift** — warns when edits contradict your brand positioning

You never have to configure these. They just work.
</details>

<details>
<summary>Governance (PRIOR FIRE WIN)</summary>

Every build follows a simple loop:

- **PRIOR** — classify risks before building. Security boundaries, data categories, compliance requirements.
- **FIRE** — when something goes wrong, stop immediately. Preserve evidence. Route to the right person. Fix at the root, not the surface.
- **WIN** — all checks pass. Every change is traceable, auditable, and reversible.

This is how Kleiber built a production compliance platform with zero governance gaps.
</details>

## Brand Visibility

Kleiber also includes AI brand auditing. Run `/kleiber-brand` to find out how ChatGPT, Gemini, and Perplexity describe your product — and get a plan to improve it.

```
/kleiber-brand
/kleiber-brand --competitors "Cursor, Cline, Aider"
```

## Requirements

- Claude Code
- Git
- jq

## Known Limitations

- Agent teams are in research preview
- No session resumption — start a fresh team each time
- One team per session

## Cost

Kleiber routes work to save money automatically:

| Task type | Model used | Cost per M tokens |
|-----------|-----------|-------------------|
| Architecture & security | Opus 4.7 | $5 in / $25 out |
| Feature building | Sonnet 4.6 | $3 in / $15 out |
| Testing & docs | Haiku 4.5 | $1 in / $5 out |

Most builds use Sonnet + Haiku for 80% of the work. You don't choose — Kleiber routes automatically.

---

Built by [DevGap](https://devgap.uk). Part of the [AI Plumber](https://aiplumber.dev) framework by Koen Van Lysebetten.
