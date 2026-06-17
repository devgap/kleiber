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
/plugin marketplace add devgap/kleiber
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

## Learn While You Build

Every Kleiber build is hands-on practice for the **Claude Certified Architect (CCA)** exam. Spawn the coach with the `--learn` flag:

```
/kleiber --learn Build payment processing with Stripe
```

The CCA Coach watches the team, annotates each architectural decision with the CCA domain it practices (Agentic Architecture, Tool Design, Claude Code Config, Structured Output, Reliability), and flags exam-style anti-patterns before they ship. Read-only, silent by default.

See [docs/claude-certification.md](docs/claude-certification.md) for the full Kleiber → CCA domain mapping, anti-patterns reference, and study path.

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
| Hardest (security / compliance / payments architecture) | Fable 5 | $10 in / $50 out |
| Architecture & high reasoning | Opus 4.8 | $5 in / $25 out |
| Feature building | Sonnet 4.6 | $3 in / $15 out |
| Testing & docs | Haiku 4.5 | $1 in / $5 out |

Most builds use Sonnet + Haiku for 80% of the work. You don't choose — Kleiber routes automatically.

---

Built by [DevGap](https://devgap.uk). Part of the [AI Plumber](https://aiplumber.dev) framework by Koen Van Lysebetten.


## Building Kleiber as a Second Brain OS

Kleiber ships as a build harness, but the same machinery makes a capable personal "second brain" — a system that captures what you know, keeps it structured, and acts on it. Treat the second brain as a product Kleiber builds and maintains for you. There are two layers: the **harness** (how work runs) and the **content model** (how knowledge is shaped). Get both right and the rest is just commands.

### Layer 1: Harness Engineering

The harness is the runtime — the part that turns "I want to remember and act on things" into a reliable, repeatable loop. Borrow Kleiber's own orchestration patterns:

- **One entry point.** Everything enters through `/kleiber`. Capture, retrieval, synthesis, and review are all the same verb: describe what you want, let the harness decide the roles.
- **Role specialisation.** Define a small standing team: a *Capturer* that normalises raw input into notes, a *Librarian* that files and links them, a *Synthesiser* that writes summaries and surfaces connections, and a *Reviewer* that checks for stale or contradictory entries.
- **Model routing by cost.** Cheap models handle tagging, dedup, and filing. Mid models handle synthesis and linking. Expensive models are reserved for hard judgement calls — resolving conflicts, deciding what to forget. The same routing table Kleiber uses for builds applies here.
- **Quality gates.** Every write to the brain is validated before it lands: schema-checked, deduplicated against existing notes, and linked to at least one existing node. Nothing enters unstructured.
- **Idempotent capture.** Re-running a capture never creates duplicates. The harness keys notes by a stable content hash so the same thought captured twice merges instead of forking.
- **Audit log.** Every decision — what was filed where, what was merged, what was forgotten — is logged automatically, the same way Kleiber logs build decisions.

A minimal harness loop looks like:

```
/kleiber capture "Met Dana from Acme — they need SOC2 by Q3, decision-maker is their CTO"
```

The Capturer normalises it, the Librarian files it under People and Accounts, the Synthesiser links it to the existing Acme thread, and the Reviewer flags that an earlier note named a different decision-maker — surfacing the contradiction for you to resolve.

### Layer 2: Content Modelling

The harness is only as good as the shape of the knowledge it moves. Content modelling is the discipline of defining that shape up front so retrieval and synthesis stay reliable as the brain grows.

- **Typed nodes, not free text.** Define a small set of node types — Note, Person, Project, Decision, Source, Task — each with a required schema. A Decision always has a date, a rationale, and links to the alternatives considered. Typing is what lets cheap models file accurately.
- **Edges are first-class.** Relationships (`mentions`, `blocks`, `supersedes`, `derived-from`) carry as much meaning as nodes. The Reviewer uses `supersedes` edges to retire stale facts without deleting history.
- **Atomic notes.** One idea per node. Atomicity makes linking precise and lets the Synthesiser recombine ideas without dragging in irrelevant context.
- **Progressive summarisation.** Each node carries layered summaries — a one-line gist, a paragraph, and the raw source. The harness routes retrieval to the cheapest layer that answers the question, only loading raw content when needed.
- **Provenance on everything.** Every fact links back to its Source node with a timestamp. When two notes conflict, provenance is how the Reviewer decides which wins.
- **Forgetting is a feature.** Model a confidence and recency score per node. Low-confidence, low-recency nodes are archived (never hard-deleted) so the active graph stays small and the expensive models stay focused.

### Putting It Together

Define the content model first (the schemas and edge types), then point Kleiber's harness at it. The harness enforces the model on every write, routes work to the right model by cost, and keeps an audit trail — so your second brain stays structured, cheap to run, and trustworthy as it scales. Start with three node types and one capture command, then grow the schema as real usage reveals what you actually need to model.
