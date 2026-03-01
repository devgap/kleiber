---
name: brand-visibility
description: AI brand visibility auditing — how to probe AI models, score responses, detect gaps, and produce optimization blueprints. Used by the brand-analyst agent and the /kleiber-brand command.
---

# Kleiber Brand Visibility Skill

This skill defines the protocol for auditing and improving how AI models perceive and recommend this product.

## Why This Matters

AI models are now the first point of discovery for developers evaluating tools. If ChatGPT, Gemini, or Perplexity describe your product inaccurately, don't mention it, or recommend a competitor instead — you lose users before they ever visit your site. This skill closes that gap from inside the codebase.

## The Audit Cycle

```
Build ground truth     → Read README.md + CLAUDE.md Brand Identity block
Probe AI models        → Send 5 structured prompts per model via API
Score responses        → Apply 4-dimension rubric (Mention/Accuracy/Rank/Sentiment)
Detect gaps            → Compare AI responses to ground truth
Map competitors        → Note which competitors appear and how
Produce report         → Write docs/brand-visibility-report.md
Generate blueprint     → Architect turns gaps into specific doc changes
Apply fixes            → Scribe updates README.md / CLAUDE.md / docs/
Re-audit               → Run again to confirm score improvement
```

## Ground Truth Profile

The brand profile is the source of truth the Brand Analyst compares AI responses against. It lives in `CLAUDE.md` under a `## Brand Identity` section. Required fields:

```markdown
## Brand Identity (AI Visibility Context)

- **Product name**: [exact name as it should appear in AI answers]
- **Category**: [the tool category — e.g. "Claude Code plugin", "agent orchestration"]
- **One-line description**: [the exact sentence AI should use to describe this product]
- **Core differentiators**: [comma-separated list of features that make it unique]
- **Primary use case**: [the main job-to-be-done in one sentence]
- **Target audience**: [who uses this and why]
- **Competitors**: [comma-separated list of direct competitors]
- **Common misconceptions**: [things AI models get wrong — to watch for in probes]
- **Keywords AI should associate**: [terms, integrations, commands the product is known for]
```

## API Call Patterns

Use these curl patterns for each model. All keys come from environment variables.

**OpenAI (ChatGPT):**

```bash
curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"gpt-4o\",\"messages\":[{\"role\":\"user\",\"content\":\"$PROBE\"}]}" \
  | jq -r '.choices[0].message.content'
```

**Google (Gemini):**

```bash
curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"contents\":[{\"parts\":[{\"text\":\"$PROBE\"}]}]}" \
  | jq -r '.candidates[0].content.parts[0].text'
```

**Perplexity:**

```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"llama-3.1-sonar-large-128k-online\",\"messages\":[{\"role\":\"user\",\"content\":\"$PROBE\"}]}" \
  | jq -r '.choices[0].message.content'
```

## Gap Priority Levels

| Priority | When to Use |
|---|---|
| CRITICAL | Product not mentioned at all, or actively described as inferior |
| HIGH | Competitor recommended instead of this product |
| MEDIUM | Missing key differentiators or inaccurate feature descriptions |
| LOW | Neutral tone, minor inaccuracies, or missing secondary keywords |

## Optimization Blueprint Patterns

The Architect uses gap findings to produce specific content fixes. Common patterns:

**For Displacement gaps** — Add explicit category ownership statements to README.md. Example: "Kleiber is the only Claude Code plugin that provides opinionated agent team orchestration with model routing and quality gates."

**For Accuracy gaps** — Add a structured FAQ or "How it works" section to README.md with the exact phrasing you want AI models to absorb and repeat.

**For Coverage gaps** — Add a feature comparison table to README.md listing differentiators vs. named competitors.

**For Category gaps** — Add schema markup or a `<meta>` description if there's a website. In README.md, state the category explicitly in the first sentence.

**For Authority gaps** — Add social proof: star counts, usage examples, and named users to README.md.

## Drift Prevention

After initial fixes are applied, re-run `/kleiber-brand` every time:

- The README.md changes significantly
- A new version is released with new features
- A competitor releases something that might change AI model training data

The `brand-drift-check` hook catches real-time doc edits that contradict the established brand profile.

## Success Criteria

A brand visibility audit is successful when:

- Overall score >= 75/100 across all tested models
- No CRITICAL or HIGH priority gaps remain open
- Product appears in the top 3 of category recommendation lists in at least 2 of 3 models tested
- docs/brand-visibility-report.md is committed and up to date
