---
description: Run a full AI brand visibility audit. Probes how ChatGPT, Gemini, and Perplexity describe and recommend this product, scores results, maps competitor displacement, and produces an optimization blueprint.
---

# /kleiber-brand — AI Brand Visibility Audit

The user wants to audit how AI models perceive and recommend this product,
then produce a blueprint for improving that visibility.

## Read the Skill First

Before doing anything, load and internalize `skills/brand-visibility/SKILL.md`.
That skill defines all probe patterns, scoring rubrics, gap types, and API call formats.

## Parse Optional Arguments

The user may pass:

- `--competitors "X, Y, Z"` — override the competitor list from CLAUDE.md
- `--models "chatgpt,gemini"` — limit which models to probe (default: all three)
- `--re-audit` — skip ground-truth rebuild, just re-run probes and rescore
- `--trend` — show score history from `docs/brand-visibility-history.json` without running a new audit

## Your Orchestration Process

### Step 1 — Build Ground Truth (skip if --re-audit)

Read `CLAUDE.md` for the `## Brand Identity` section.

If no Brand Identity section exists, read `README.md` and extract:
- Product name, category, one-line description, core differentiators, competitors, primary use case.

Tell the user: "No Brand Identity block found in CLAUDE.md. I inferred the profile from README.md. After this audit, add a `## Brand Identity` section to CLAUDE.md for more accurate future audits."

### Step 2 — Spawn Brand Analyst (Sonnet)

Spawn the brand-analyst agent with this spawn prompt:

"You are the Brand Analyst. Load `skills/brand-visibility/SKILL.md` for your full protocol.
Ground truth product: [PRODUCT_NAME].
Category: [CATEGORY].
Competitors: [COMPETITOR_LIST].
Probe all available models (check for $OPENAI_API_KEY, $GEMINI_API_KEY, $PERPLEXITY_API_KEY).
Skip any model whose API key is not set — mark it as 'not tested'.
Write your full report to `docs/brand-visibility-report.md`.
Extract citation sources/domains from AI responses — especially Perplexity citations.
Append timestamped scores to `docs/brand-visibility-history.json` for trend tracking.
If previous history exists, include a Score Trend section comparing current vs previous audit.
Message the lead when done with a one-line summary: total score, top gap, and score delta if available."

### Step 3 — Wait for Brand Analyst to Complete

Do not proceed until the brand-analyst has written `docs/brand-visibility-report.md` and messaged you.

### Step 4 — Spawn Architect (Opus) for Optimization Blueprint

Only spawn Architect if any gaps were found (score < 100 or any gaps in the report).

Spawn with:

"You are the Architect. Read `docs/brand-visibility-report.md` in full.
Your job: produce an AI Optimization Blueprint.
For each gap in the report, write a specific, actionable fix:
- Which file to change (README.md, CLAUDE.md, or a docs/ file)
- What exact content to add, rewrite, or restructure
- Why this fix closes the specific gap (cite the gap type from the skill)

Append your blueprint as a `## Optimization Blueprint` section at the bottom of
`docs/brand-visibility-report.md`. Do not modify any source code. Read-only except
for that one append. Message the lead when done."

### Step 5 — Wait for Architect to Complete

Do not proceed until Architect has appended the blueprint.

### Step 6 — Spawn Scribe (Haiku) to Apply Approved Fixes

Only apply fixes the user explicitly approves. Before spawning Scribe, show the user
the Optimization Blueprint and ask: "Should I have the Scribe apply these fixes to
README.md and CLAUDE.md now? Reply YES to proceed or list which fixes to skip."

If approved, spawn Scribe:

"You are the Scribe. Read the `## Optimization Blueprint` section in
`docs/brand-visibility-report.md`. Apply only the approved fixes to README.md and/or
CLAUDE.md as instructed. Do not change any other files. Do not modify source code.
After applying, run `git diff README.md CLAUDE.md` and paste the diff into a message
to the lead so they can review before committing."

### Step 7 — Summarize

After all teammates complete, report to the user:
- Overall visibility score (before and after fixes if applied)
- Score trend vs previous audit (if history exists)
- Number of gaps found and their priorities
- Top citation sources and domain type breakdown
- Which fixes were applied
- How to re-run: `/kleiber-brand --re-audit` after your next release
- How to view trends: `/kleiber-brand --trend`

## Example Usage

```
/kleiber-brand
/kleiber-brand --competitors "Cursor, Cline, Aider"
/kleiber-brand --models "chatgpt,perplexity"
/kleiber-brand --re-audit
/kleiber-brand --trend
```

## Cost Reference

| Agent | Model | Estimated Cost |
|---|---|---|
| Brand Analyst | Sonnet | ~$0.05-0.20 per full audit |
| Architect | Opus | ~$0.10-0.30 for blueprint |
| Scribe | Haiku | ~$0.01-0.05 for applying fixes |
