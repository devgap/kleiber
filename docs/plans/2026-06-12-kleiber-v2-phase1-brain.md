# Kleiber v2 — Phase 1: The Brain (substrate-neutral) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the substrate-neutral "brain" both runtimes read — a canonical machine-readable routing table, the global `CLAUDE.md` source, the per-venture `AGENTS.md`/`context.md` templates, a central venture registry, and the Obsidian `Kleiber/` scaffold — with zero mutation of the global `~/.claude` environment (projection/install is Phase 2).

**Architecture:** All authored artifacts live version-controlled in the kleiber repo so they're reviewable. `routing.json` is the single source of truth for model×effort routing (both the Go supervisor and the plugin read it — this resolves spec §11's Go/plugin drift question). The vault scaffold is additive folders + seed notes. No symlinks, no `~/.claude/CLAUDE.md` write — those are Phase 2.

**Tech Stack:** Markdown, JSON, `python3 -m json.tool` for validation, `grep` for structural gates, `git`.

**Source spec:** `docs/specs/2026-06-10-kleiber-v2-venture-aware-os-design.md` (§5 layers, §5.4 doc source, §5.5 runtimes, §6 routing, §8 components, §9 Phase 1).

**Prereq:** Phase 0 merged or present on this branch (model catalog already current).

---

## File Structure (what Phase 1 creates)

| File | Responsibility |
|---|---|
| `routing.json` | **Canonical** model×effort routing table (both runtimes read it) |
| `docs/templates/global-CLAUDE.md` | Source content for `~/.claude/CLAUDE.md` (installed in Phase 2) |
| `docs/templates/AGENTS.template.md` | Per-venture roster + routing-override + gates template |
| `docs/templates/context.template.md` | Volatile session-state template (hook-written, gitignored at use) |
| `docs/templates/README.md` | Explains the three layers + projection model |
| `ventures/_TEMPLATE.md` | Central registry venture-profile template |
| `ventures/README.md` | Registry index + venture-key list + cwd→venture note |
| Vault `Kleiber/` (`Standards/`, `Daily/`, `Ventures/`, `Kleiber.md`) | Human source-of-truth scaffold (vault-side, not committed) |

**Deliberately NOT done in Phase 1:** writing `~/.claude/CLAUDE.md`; symlinks; hooks; the Go binary. Those are Phases 2–3.

---

### Task 1: Canonical routing table — `routing.json`

**Files:**
- Create: `routing.json`

- [ ] **Step 1: Write the file**

Create `routing.json`:

```json
{
  "$comment": "CANONICAL model x effort routing for Kleiber. Both the Go supervisor (loop.go) and the Claude Code plugin read THIS file. Do not restate the table elsewhere — link here. No fictional models (e.g. 'Mythos 5').",
  "version": 1,
  "tiers": {
    "hardest": { "model": "claude-fable-5", "label": "Fable 5", "cost_per_m": { "in": 10, "out": 50 }, "use_for": "security/compliance/payment architecture, gnarly multi-service decisions", "requires_plan_approval": true },
    "hard":    { "model": "claude-opus-4-8", "label": "Opus 4.8", "cost_per_m": { "in": 5, "out": 25 }, "use_for": "architect role, complex refactors, hard reasoning" },
    "build":   { "model": "claude-sonnet-4-6", "label": "Sonnet 4.6", "cost_per_m": { "in": 3, "out": 15 }, "use_for": "frontend/backend engineers (default worker)" },
    "grunt":   { "model": "claude-haiku-4-5", "label": "Haiku 4.5", "cost_per_m": { "in": 1, "out": 5 }, "use_for": "validation, docs, boilerplate, mechanical tasks" }
  },
  "effort": {
    "supported_on": ["claude-fable-5", "claude-opus-4-8", "claude-opus-4-6", "claude-sonnet-4-6"],
    "unsupported_on": ["claude-haiku-4-5"],
    "levels": {
      "max":    "correctness-critical: compliance/security/payment arch (pair with hardest/hard + plan approval)",
      "xhigh":  "coding & agentic builds (Opus 4.8) — best quality/efficiency point",
      "high":   "default for intelligence-sensitive work",
      "medium": "cost-sensitive builds",
      "low":    "subagents, validation, mechanical tasks (pairs with Haiku 4.5)"
    },
    "default": "high"
  },
  "role_defaults": {
    "architect": { "tier": "hard", "effort": "xhigh" },
    "engineer-frontend": { "tier": "build", "effort": "high" },
    "engineer-backend": { "tier": "build", "effort": "high" },
    "validator": { "tier": "grunt", "effort": "low" },
    "scribe": { "tier": "grunt", "effort": "low" }
  },
  "force_hardest_plus_plan_approval": [
    "payment processing logic",
    "authentication/authorization changes",
    "data encryption",
    "GDPR/PCI-DSS/HIPAA compliance code",
    "multi-service refactors"
  ]
}
```

- [ ] **Step 2: Validate + assert no drift**

Run:
```bash
python3 -m json.tool routing.json >/dev/null && echo "json-ok"
grep -ciE "mythos|opus-4-7|claude-opus-4-7" routing.json; echo "  expect 0"
python3 -c "import json;d=json.load(open('routing.json'));print('tiers',list(d['tiers']));assert d['tiers']['hardest']['model']=='claude-fable-5';assert d['tiers']['hard']['model']=='claude-opus-4-8';print('OK')"
```
Expected: `json-ok`, count `0`, then `tiers [...]` and `OK`.

- [ ] **Step 3: Commit**

```bash
git add routing.json
git commit -m "feat(brain): add canonical routing.json (model x effort, single source)"
```

---

### Task 2: Global brain source — `docs/templates/global-CLAUDE.md`

**Files:**
- Create: `docs/templates/global-CLAUDE.md`

- [ ] **Step 1: Write the file**

Create `docs/templates/global-CLAUDE.md`:

```markdown
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
Routing is **model × effort**. The canonical table is `routing.json` (read it). Tiers: Fable 5 (hardest) → Opus 4.8 (hard) → Sonnet 4.6 (build) → Haiku 4.5 (grunt). Effort: `low`→`max`, default `high`. Per-venture overrides live in that venture's `AGENTS.md`. **"Mythos 5" is not a real model — never route to it.**

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
```

- [ ] **Step 2: Assert required sections + no drift**

Run:
```bash
grep -cE "^## (Identity|House Rules|Model Routing|Loop Thresholds|Per-Session Discipline|Venture Detection)" docs/templates/global-CLAUDE.md; echo "  expect 6"
grep -ciE "mythos|opus 4\.7|opus-4-7" docs/templates/global-CLAUDE.md; echo "  expect 0"
```
Expected: `6`, then `0`.

- [ ] **Step 3: Commit**

```bash
git add docs/templates/global-CLAUDE.md
git commit -m "feat(brain): author global CLAUDE.md source (house rules + routing pointer)"
```

---

### Task 3: Venture templates — `AGENTS.template.md`, `context.template.md`, templates README

**Files:**
- Create: `docs/templates/AGENTS.template.md`
- Create: `docs/templates/context.template.md`
- Create: `docs/templates/README.md`

- [ ] **Step 1: Write `docs/templates/AGENTS.template.md`**

```markdown
# AGENTS.md — {{VENTURE_NAME}}

> Per-venture roster + routing overrides + gates. Read by Claude Code AND Codex. Overrides the central base in `ventures/{{VENTURE_KEY}}.md`. Canonical routing: `routing.json`.

## Metadata
- venture_key: {{VENTURE_KEY}}
- stack: {{STACK}}
- hosting: {{HOSTING}}
- repo: {{REPO_URL}}
- prod_url: {{PROD_URL}}
- tenant_id: {{TENANT_ID}}        <!-- white-label; blank for first-party -->
- linked_skill: {{SKILL_OR_BLANK}}

## Active Roster
<!-- Keep only the virtuosos this venture needs. Core 5: architect, engineer-frontend, engineer-backend, validator, scribe. Aux: brand-analyst, brand-architect, cca-coach. -->
- architect
- engineer-frontend
- validator
- scribe

## Routing Overrides (win over routing.json role_defaults)
| Task type | Tier | Effort |
|-----------|------|--------|
| {{TASK}} | {{tier}} | {{effort}} |

## Brand / Voice Lock
- {{tokens, typography, copy rules}}

## Custom Quality Gates (layered on global hooks)
- {{e.g. WPC: anon insert must route through Edge Function (service role); verify RLS}}

## Known Traps
- {{free-text gotchas}}
```

- [ ] **Step 2: Write `docs/templates/context.template.md`**

```markdown
# context.md — volatile session state

> HOOK-WRITTEN, gitignored at point of use. The loop count + last-action hash are written by the loop-state hook (Phase 2); the model READS this, it does not self-report the counter. Prevents "model forgets its goal 4 turns into a loop".

current_goal: {{ONE LINE}}
active_loop_count: 0
last_action_hash: {{SHA}}

## Task Checklist
- [ ] {{task}}

## Recent Decisions / FIRE events
- {{timestamp — decision/event}}

## Resume From Here
{{handoff block — what to do next if the session restarts}}
```

- [ ] **Step 3: Write `docs/templates/README.md`**

```markdown
# Kleiber Brain Templates

Three layers (substrate-neutral — both the Go supervisor and the CC plugin consume them):

1. **global-CLAUDE.md** → installed to `~/.claude/CLAUDE.md` (Phase 2). Declared policy + house rules + routing pointer.
2. **AGENTS.template.md** → generate one `AGENTS.md` per venture repo. Roster + routing overrides + gates. Read by Claude Code and Codex.
3. **context.template.md** → seeded per session as `context.md` (gitignored). Volatile loop state, **hook-written**.

Canonical routing data: `/routing.json`. Central venture registry: `/ventures/`. Human source of truth: the Obsidian `Kleiber/` vault folder.

Projection (symlink vs generate) is wired in Phase 2 — these are authoring sources only.
```

- [ ] **Step 4: Assert structure**

Run:
```bash
grep -c "{{VENTURE_KEY}}" docs/templates/AGENTS.template.md; echo "  expect >=2"
grep -cE "active_loop_count|Resume From Here" docs/templates/context.template.md; echo "  expect 2"
test -f docs/templates/README.md && echo "readme-ok"
```
Expected: a count ≥ 2, then `2`, then `readme-ok`.

- [ ] **Step 5: Commit**

```bash
git add docs/templates/AGENTS.template.md docs/templates/context.template.md docs/templates/README.md
git commit -m "feat(brain): add AGENTS/context templates + templates README"
```

---

### Task 4: Central venture registry — `ventures/`

**Files:**
- Create: `ventures/_TEMPLATE.md`
- Create: `ventures/README.md`

- [ ] **Step 1: Write `ventures/_TEMPLATE.md`**

```markdown
# {{VENTURE_KEY}} — central base profile

> Base venture profile (the plugin's default). A repo's own AGENTS.md overrides this. Links to — never restates — the venture's Claude skill and the Obsidian Ventures/{{VENTURE_KEY}} note.

- name: {{VENTURE_NAME}}
- stack: {{STACK}}
- detect: {{git-remote substring or dir name}}
- linked_skill: {{skill name or none}}
- vault_note: Kleiber/Ventures/{{VENTURE_KEY}}.md
- roster: [architect, engineer-frontend, validator, scribe]
- routing_overrides: see AGENTS.md
- house_notes: {{venture-specific reminders}}
```

- [ ] **Step 2: Write `ventures/README.md`**

```markdown
# Kleiber Venture Registry

Central base profiles (`<key>.md`). Each repo's own `AGENTS.md` overrides its base. Profiles **link** to existing Claude skills and Obsidian notes — they never restate locked facts (honors "never claim canonical without reading source").

## cwd → venture detection
Resolve by git-remote substring first, directory name second, optional `.kleiber-venture` marker file as override. (Mechanism finalized in Phase 2.)

## Known venture keys (seed — extend as profiled)
| key | name | linked skill |
|-----|------|--------------|
| ambuilding | AM Building | — |
| specter-dualmotor | dualmotor.specter.bike | specter-dualmotor-lp |
| specter-testrit | Specter /testrit funnel | — |
| wpc-trustengine | WPC TrustEngine | supabase-vite-form-fix |
| wpc-compliance | WPC Compliance Engine (Clair) | — |
| digital-dali | digitaldali.co | supabase-vite-form-fix |
| brandmind | brandmind.app | — |
| beastfuel | Beastfuel ecosystem | — |
| aiplumber | aiplumber.dev | — |
| future-build | future-build.be | — |
| kleiber | Kleiber OS itself | — |

> Profiles are generated during Phase 4 (pilot) — this file is the skeleton + key list only.
```

- [ ] **Step 3: Assert**

Run: `test -f ventures/_TEMPLATE.md && grep -c "| ambuilding |" ventures/README.md`
Expected: `1`.

- [ ] **Step 4: Commit**

```bash
git add ventures/_TEMPLATE.md ventures/README.md
git commit -m "feat(brain): scaffold central venture registry + key list"
```

---

### Task 5: Obsidian vault scaffold (vault-side, additive)

**Files:** none in repo — creates folders/notes under the vault. No repo commit.

> Default vault path `~/Documents/Obsidian Vault`. Override by exporting `OBSIDIAN_VAULT_PATH` first. Purely additive (creates a new `Kleiber/` folder); nothing existing is touched.

- [ ] **Step 1: Create the structure**

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"
mkdir -p "$VAULT/Kleiber/Standards" "$VAULT/Kleiber/Daily" "$VAULT/Kleiber/Ventures"
echo "created under: $VAULT/Kleiber"
```

- [ ] **Step 2: Seed the MOC index + a Standards starter**

Create `$VAULT/Kleiber/Kleiber.md`:

```markdown
# Kleiber OS — Map of Content

Human source of truth for the Kleiber workflow OS. The Go supervisor ripgrep-scans `Standards/` at launch; per-venture `AGENTS.md` files are mirrored under `Ventures/`.

- [[Standards/]] — reusable rules the supervisor injects (e.g. Go-Threading, Astro-Netlify, Supabase-RLS)
- [[Daily/]] — execution log (Success / Fail / Abort appended by the loop)
- [[Ventures/]] — per-venture notes
- Repo: github.com/devgap/kleiber · Spec: docs/specs/2026-06-10-...
```

Create `$VAULT/Kleiber/Standards/_README.md`:

```markdown
# Standards

One file per reusable rule the supervisor should inject when the prompt matches. Filename = topic (e.g. `Go-Threading.md`, `Supabase-RLS.md`, `Astro-Netlify-Ship.md`). Keep each focused; ripgrep matches on filename + content.
```

- [ ] **Step 3: Verify**

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"
ls -d "$VAULT/Kleiber/Standards" "$VAULT/Kleiber/Daily" "$VAULT/Kleiber/Ventures" && test -f "$VAULT/Kleiber/Kleiber.md" && echo "vault-scaffold-ok"
```
Expected: the three dirs listed, then `vault-scaffold-ok`.

> No commit — vault is outside the repo.

---

### Task 6: Phase 1 verification gate

**Files:** none — final assertion + marker.

- [ ] **Step 1: Drift gate over all new repo files**

```bash
grep -rniE "mythos|opus 4\.7|claude-opus-4-7|opus-4-7|Devgapperk" routing.json docs/templates/ ventures/; echo "exit=$? (1=clean)"
```
Expected: no output, `exit=1`.

- [ ] **Step 2: Structural completeness**

```bash
python3 -m json.tool routing.json >/dev/null && echo "routing-json-ok"
for f in docs/templates/global-CLAUDE.md docs/templates/AGENTS.template.md docs/templates/context.template.md docs/templates/README.md ventures/_TEMPLATE.md ventures/README.md; do test -f "$f" || echo "MISSING $f"; done; echo "files-checked"
```
Expected: `routing-json-ok`, no `MISSING` lines, `files-checked`.

- [ ] **Step 3: Commit marker**

```bash
git commit --allow-empty -m "chore(phase1): brain authored — routing.json + templates + registry + vault scaffold"
```

---

## Self-Review

**Spec coverage (§9 Phase 1):**
- "global CLAUDE.md" → Task 2 (`docs/templates/global-CLAUDE.md`). ✓
- "AGENTS.md/context.md templates" → Task 3. ✓
- "central registry skeleton" → Task 4. ✓
- "vault Kleiber/ structure (Standards/, Daily/, Ventures/)" → Task 5. ✓
- Bonus, resolves §11 drift question: canonical `routing.json` → Task 1. ✓

**Placeholder scan:** Template files intentionally contain `{{TOKEN}}` placeholders — these are template fill-points, not plan gaps. Every plan step shows full file content + exact verify commands. ✓

**Consistency:** Model strings identical to Phase 0 + routing.json (`claude-fable-5`, `claude-opus-4-8`, `claude-sonnet-4-6`, `claude-haiku-4-5`). Venture keys in `ventures/README.md` match memory. ✓

**Scope discipline:** No `~/.claude/CLAUDE.md` write, no symlinks, no hooks, no Go code — all deferred to Phase 2/3. Phase 1 is additive authoring only. ✓
