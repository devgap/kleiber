# Global Operating Brain (Kleiber OS)

> SOURCE FILE — installed to `~/.claude/CLAUDE.md` in Phase 2 (projection). Edit here (or in the Obsidian vault note this mirrors), never the installed copy. Canonical routing data lives in `routing.json` — this file references it, never restates it.

## Identity
DevGap / Koen Van Lysebetten. Governance-first builder running a portfolio of ventures (see `ventures/README.md`). One orchestrator, many specialists.

## House Rules (hard constraints)
- **Never quote prices in AM Building chat** — deflect to cal.com / WhatsApp; never commit to numbers in chat.
- **WPC content is schema-first, AI-renderable ranking pages — NOT a blog.** Never frame as "blog post strategy".
- **Never claim "canonical" without reading the source.** Before generating schema/ERD/source-of-truth artifacts, read the existing canonical file (schema/, models/, *-schema.ts, ERD docs) FIRST.
- **Phased, audit-first governance.** Refactors run audit-first with gated phases, atomic/attributable commits, stop & wait for approval. Walk the talk.
- **No AI-slop aesthetics.** No default Inter/Roboto, no purple-on-white gradients, no cookie-cutter layouts.

## Model Routing
Routing is **model × effort**. The canonical table is `routing.json` (read it). Tiers: Fable 5 (hardest) → Opus 4.8 (hard) → Sonnet 4.6 (build) → Haiku 4.5 (grunt). Effort: `low`→`max`, default `high`. Per-venture overrides live in that venture's `AGENTS.md`. Only model ids present in `routing.json` are valid — reject any unknown or hallucinated model id as an error rather than routing to it.

## Loop Thresholds (declared; hooks enforce — Phase 2)
- Same error 3× → halt and report.
- Same approach 4× → halt and reassess.
- 25 consecutive tool calls → checkpoint progress to `context.md`.
- Soft token cap per tier → warn, then halt at the next tool call (soft, not hard).

## Per-Session Discipline
1. On session start, read this repo's `AGENTS.md` (venture roster + overrides + gates).
2. Maintain `context.md` (current goal, loop count, checklist) — but the loop count is **hook-written**, you only read it.
3. Follow PRIOR → FIRE → WIN (see the orchestration skill). Do not duplicate it here.

## Venture Detection (cwd → venture key)
Resolve the active venture from the git remote or directory name, then load `ventures/<key>.md` (central base) overlaid by the repo's own `AGENTS.md`. Registry of keys: `ventures/README.md`.
