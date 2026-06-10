# Kleiber v2 — Venture-Aware Workflow OS

**Date:** 2026-06-10
**Author:** Koen Van Lysebetten (DevGap) + Claude (Opus 4.8)
**Status:** Design approved — pending user review of this spec, then implementation planning
**Repo:** `devgap/kleiber` (working clone at `~/kleiber`)

---

## 1. Problem

Kleiber today is a complete but **venture-agnostic** Claude Code orchestration plugin: it spawns a team of specialist agents, routes work to models by role, enforces quality gates, self-heals loops, and logs decisions (PRIOR → FIRE → WIN governance). What it does **not** do:

1. **Know anything about a specific venture.** Roles are generic (`engineer-frontend`, `engineer-backend`). Kleiber has no idea that Specter is light-monochrome brand, that AM Building's chat agent must never quote prices, that WPC inserts must route through an Edge Function, or that Future-Build's palette is locked to Deep Forest Green + Golden Yellow.
2. **Persist working state across a session.** Documented limitation: "No session resumption — start a fresh team each time." A model 4 turns deep in a loop forgets its goal and repeats commands.
3. **Route to current models.** The orchestration skill and README name **Opus 4.7 / Sonnet 4.6 / Haiku 4.5** — there is no **Opus 4.8** (current capable default) and no **Fable 5** (new top tier above Opus).

Plus two correctness defects:
- README install slug is `Devgapperk/kleiber`; the repo is `devgap/kleiber`.
- The local `context-mode` plugin's native module (`better-sqlite3`) is compiled against the wrong Node ABI (`NODE_MODULE_VERSION` mismatch) and currently throws on every call. (Adjacent to this work; tracked here because it blocks the context tooling.)

## 2. Goal

Add a **three-layer personalization + state layer** on top of the existing Kleiber engine so a single command (`/kleiber …`) runs with full per-venture context, current model routing, and durable loop state — without forking the engine per client (supports the WPC white-label thesis via `tenant_id`).

Non-goals (this milestone):
- Rewriting the orchestration engine, agents, or governance loop — they stay.
- Building a new loop runtime — we extend the existing `stop-loop-guard` + Ralph-detection.
- Hard, kernel-level token enforcement — not achievable in Claude Code; we ship a **soft cap** (warn/halt at the next tool call) and say so plainly.

## 3. Core principle

> **Markdown declares policy. Hooks enforce it and own volatile state. The orchestrator routes.**

`CLAUDE.md` and `AGENTS.md` are *advisory text read by the model* — they cannot stop a runaway loop or cap tokens on their own. Only deterministic **hooks** can. Volatile counters (loop count) must be hook-written, never model-written, because the failure mode we are fixing (a confused model mid-loop) is also a model that forgets to update its own counter.

```
Global CLAUDE.md   →  DECLARES: model tiers, loop thresholds, house rules   (advisory)
       │ directs
Project AGENTS.md  →  DECLARES: roster, routing overrides, gates, metadata  (advisory, per-venture)
       │ intercepts
Session context.md →  HOLDS: loop count, current goal, task checklist        (HOOK-written, model-read)
       │ enforced by
Hooks layer        →  ENFORCES: loop limits, soft token cap, gates           (deterministic)
```

## 4. Architecture decisions (locked)

| # | Decision | Choice |
|---|---|---|
| D1 | Scope | One unified "Kleiber v2" spec; build in gated phases (not a rebuild — extend the existing engine) |
| D2 | Personalization model | **Hybrid**: central venture registry in the plugin + per-repo `AGENTS.md`/`context.md` override. Auto-detect venture by repo. |
| D3 | Layers | Global `CLAUDE.md` (engine spec) → Project `AGENTS.md` (roster + overrides) → Session `context.md` (volatile state) |
| D4 | Enforcement | **Hooks enforce + own volatile state.** Markdown only declares. |
| D5 | Model IDs | Fable 5 (hardest) → Opus 4.8 (hard) → Sonnet 4.6 (build) → Haiku 4.5 (grunt). Routing axis 2 = **effort** (`low`→`max`). No fictional models (e.g. "Mythos 5"). |
| D6 | Doc source of truth | **Obsidian vault is the human source.** Operative files are projected (plugin) and/or live-read via ripgrep (Go runtime). One edit surface, no hand-kept duplicates. |
| D7 | Runtime substrate | **Two runtimes, one brain**: a **Go supervisor** (`loop.go`) for autonomous `-loop` build→test→repair jobs, and the **Claude Code plugin** for interactive 8-virtuoso team builds. Both consume the same brain. Boundary = job type. |

## 5. The three layers (contracts)

### 5.1 Global `~/.claude/CLAUDE.md` — the engine spec
Currently empty. Becomes the constitution every session reads.

- **Identity & house rules** (sourced from existing memory, treated as hard constraints):
  - Never quote prices in AM Building chat — deflect to cal.com / WhatsApp.
  - WPC content is schema-first ranking pages, never "blog posts".
  - Never claim "canonical" without reading the source file first.
  - Phased, audit-first governance: atomic, attributable commits; stop & wait for approval at phase gates.
  - No AI-slop aesthetics (no Inter/Roboto default, no purple-on-white gradients).
- **Declared model tier table** (§6).
- **Declared loop thresholds**: same-error repeat = 3 → halt; same-approach retry = 4 → halt; consecutive-tool checkpoint = N (default 25) → write progress to `context.md`; per-tier soft token cap.
- **Venture-detection map**: `cwd` / git remote → venture key (e.g. `specter-promo-dualmotor-april` → `specter-dualmotor`).
- **Pointers**: "On session start, load this repo's `AGENTS.md`; maintain `context.md`."
- **PRIOR / FIRE / WIN** reference (link to orchestration skill, do not duplicate).

### 5.2 Project `AGENTS.md` — per-venture roster + overrides
A template lives centrally; a generated instance lives in each venture repo (overrides central defaults).

Required sections:
- **Metadata**: venture key · stack · hosting · repo · prod URL · `tenant_id` (white-label) · linked Claude skill (if any).
- **Active roster**: which of the 8 virtuosos this venture spawns. A static landing page omits `engineer-backend`; a Supabase app includes it. (Core 5: architect, engineer-frontend, engineer-backend, validator, scribe. Auxiliary: brand-analyst, brand-architect, cca-coach.)
- **Routing overrides**: task-type → model, winning over the global defaults. *Example: WPC styling → Sonnet 4.6; Codex/compliance engine → Opus 4.8 pure; security/compliance arch → Fable 5 + plan approval.*
- **Brand / voice lock**: design tokens, typography, copy rules (e.g. Future-Build palette; Specter monochrome; AM Building no-prices).
- **Custom quality gates**: venture-specific, layered on the global hooks. Examples drawn from existing skills:
  - WPC / Lovable-Supabase: anon-can't-insert → route through Edge Function with service role; verify RLS.
  - Astro + Netlify static: CSP present, no `cdn.tailwindcss.com`, absolute `og:image`, network-first SW.
  - Specter dualmotor: monochrome brand, hero-video perf pattern.
- **Known traps**: free-text gotchas.

### 5.3 Session `context.md` — volatile loop state (gitignored)
Created/refreshed by a hook at session start; updated by hooks during execution; read by the model.

- **Current goal** (1 line — re-anchors a looping model).
- **Active loop count** + **last-action hash** (hook-written; drives loop detection).
- **Task checklist** with status.
- **Last N decisions / FIRE events**.
- **"Resume from here" block** — fills the no-session-resumption gap.

### 5.4 Documentation source of truth (Obsidian) — "read first, build without mistakes"

**Hard constraint: neither Claude Code nor Codex reads an Obsidian vault.** Claude Code auto-loads `~/.claude/CLAUDE.md`, repo `CLAUDE.md`, and `AGENTS.md`; Codex auto-loads `AGENTS.md` up the tree + `~/.codex/AGENTS.md`. A vault is just markdown they never open unless pointed there. So the vault cannot be the thing agents "read first" — the **operative files must sit where agents already look**, and there must be **exactly one source of truth** to honor the *never-two-canonical-copies* rule.

Chosen pattern — **Vault is the human source; operative files are projected** (decision D6, pending confirm):
- **Vault** (`~/Documents/Obsidian Vault/Kleiber/`) holds the human-authored knowledge: engine spec, per-venture notes, MOC index, backlinks, decisions. This is where Koen *edits*.
- **Projection** writes the operative files agents read:
  - Global → symlink `~/.claude/CLAUDE.md` to the vault note (same FS, always current, no build step).
  - Per-repo `AGENTS.md` → **generated/copied** into each repo (not symlinked — it must commit and travel with the repo; Codex reads it there).
  - Central registry → lives in the plugin, links (never restates) the vault notes.
- Every projected file carries a header: `GENERATED FROM vault://Kleiber/<note> — edit there, not here.`
- Repos already inside a vault (e.g. `wpc-permit-engine-v2`) get this for free: their `AGENTS.md` is simultaneously a repo file and a vault note.

This guarantees: one edit surface (vault), one read surface (repo/.claude), zero hand-maintained duplicates — the exact "build upon without mistakes" property.

> **Two read paths, one source.** The **Go runtime** reads the vault *live* via `brain.go` + ripgrep (no projection needed — it injects matched `Standards/*.md` at launch). The **plugin runtime** reads the *projected* operative files (Claude Code/Codex only look at `CLAUDE.md`/`AGENTS.md`). Both ultimately trace to the vault note.

### 5.5 Runtimes — two consumers of the brain (D7)

The brain (§5.1–5.4) is substrate-neutral. Two runtimes consume it, split by **job type**:

| Job type | Runtime | Why |
|---|---|---|
| Autonomous build→test→repair (one objective, run unattended) | **Go supervisor** (`loop.go`) | Deterministic outer loop, build-gate verification, self-repair, hard loop-guard abort. Single-agent iterations. |
| Interactive multi-concern build (frontend+backend+review together) | **Claude Code plugin** | In-session 8-virtuoso agent teams, delegate mode, live steering. |

**Go supervisor flow** (canonical — from the approved ASCII):
1. **Pre-flight hooks**: `SessionStart` (load tokens, hydrate workspace) → `PreToolUse` (block `rm -rf` etc.).
2. **Second-brain hydration** (`brain.go`): ripgrep `$OBSIDIAN_VAULT_PATH` for prompt-matched `Standards/*.md`; inject into context.
3. **Context resolve**: read `./AGENTS.md` + `./CLAUDE.md`; extract venture ID, priority boundaries, active virtuosos.
4. **Execution gateway**: `-loop` false → standard handover (evaluate complexity → route model → `syscall.Exec("claude")`); `-loop` true → supervisor loop.
5. **Supervisor loop**: step 1 → Sonnet 4.6 @ `high`; step > 1 → **Medic escalation** to Opus 4.8 @ `xhigh`; write `.claude/context.md` (anti-amnesia); run agent (`exec.Command` + wait — **not** `syscall.Exec`, which would replace the process); **quality gate** (`go build ./…`, `cargo build`, detected compiler); on fail → log stack trace to Obsidian + build self-repair prompt; **loop-guard**: step < max → recycle; step ≥ max → **abort** (safety gate).

**Plugin runtime**: unchanged orchestration engine (§ existing skill) reading the projected files + the model×effort routing of §6.

**Shared by both**: `context.md` volatile state (hook-written), `Daily/YYYY-MM-DD.md` execution-status append in the vault (Success/Fail/Abort), and the §6 routing table.

## 6. Model routing (refreshed) — two axes: model × effort

Routing is **not** just model selection. It is **(model tier) × (effort level)**. Declared in global `CLAUDE.md`; per-venture overrides in `AGENTS.md`; applied by the orchestration skill at teammate-spawn time (Claude Code agent teams set model per teammate).

> **Authoritative model catalog (do not invent tiers).** The only real models are Haiku 4.5, Sonnet 4.6, Opus 4.6/4.7/4.8, and Fable 5. **"Mythos 5" is NOT a real model** — it was hallucinated by an external tool and must never appear in routing, docs, or the dashboard. The orchestration skill should treat any unknown model ID as an error, not a tier.

### Axis 1 — Model tier

| Tier | Model ID | Default for |
|---|---|---|
| Hardest | `claude-fable-5` | Security / compliance / payment **architecture**; gnarly multi-service decisions. Requires plan approval. |
| Hard | `claude-opus-4-8` | Architect role; complex refactors. |
| Build | `claude-sonnet-4-6` | Frontend/backend engineers (default worker). |
| Grunt | `claude-haiku-4-5` | Validator, scribe, boilerplate, docs. |

### Axis 2 — Effort (`output_config.effort`)

Trades latency/cost for intelligence on Fable 5 / Opus 4.6+ / Sonnet 4.6 (errors on Haiku 4.5 and older Sonnets). Levels: `low` → `medium` → `high` (default) → `xhigh` → `max`.

| Effort | Use for |
|---|---|
| `max` | Correctness-critical: compliance/security/payment architecture (pair with Fable 5/Opus 4.8 + plan approval). |
| `xhigh` | Coding & agentic work — best quality/efficiency point for builds (Opus 4.8). |
| `high` | Default for intelligence-sensitive work. |
| `medium` | Cost-sensitive builds. |
| `low` | Subagents, validation, mechanical/boilerplate tasks (pairs with Haiku 4.5). |

Routing rules retained from v1: workers default to Build tier, downgrade to Grunt for boilerplate, upgrade to Hard/Hardest on discovered complexity; force top-tier + `max` effort + plan approval for payments, auth, encryption, GDPR/PCI/HIPAA, multi-service refactors. Per-venture `AGENTS.md` may pin effort (e.g. *WPC styling → Sonnet 4.6 @ medium; Codex compliance engine → Opus 4.8 @ xhigh*).

## 7. Hooks (enforcement + state)

Extends Kleiber's existing 7 hooks. New/changed:

| Hook | Event | Job |
|---|---|---|
| `context-init` | SessionStart | Detect venture from cwd/remote; scaffold or refresh `context.md`; surface this repo's `AGENTS.md`. |
| `loop-state` | PostToolUse (Bash/Edit/Write) | Increment loop count; write last-action hash to `context.md`; feed existing `stop-loop-guard`. |
| `routing-reminder` | PreToolUse (Agent/Task) | Inject the venture's routing table so spawns pick the right model. |
| `soft-token-cap` | PostToolUse / statusline | Track context size (mirror `gsd-context-monitor`); warn, then halt at the next tool call when over cap. **Soft, not hard.** |

Reused unchanged: `stop-loop-guard`, `block-destructive`, `post-edit-verify`, `task-completed`, `teammate-idle`, `brand-drift-check`.

## 8. Components & ownership

| Unit | Purpose | Depends on |
|---|---|---|
| `CLAUDE.md` (global) | Declared policy + house rules + venture map | none |
| `ventures/<key>.md` (central registry) | Base venture profiles in the plugin | CLAUDE.md venture map |
| `AGENTS.md` (per repo) | Override base profile | central registry, template |
| `context.md` (per repo, gitignored) | Volatile state | hooks |
| 4 hooks above | Enforce + own state (plugin runtime) | settings.json wiring |
| Templates (`docs/templates/`) | Authoring source for AGENTS.md / context.md | none |
| Go supervisor (`main.go`, `brain.go`, `loop.go`) | Autonomous `-loop` runtime (§5.5) | brain, `claude` CLI, ripgrep, `$OBSIDIAN_VAULT_PATH` |
| Vault `Kleiber/` (`Standards/`, `Daily/`, `Ventures/`) | Human source of truth + execution log | Obsidian |

## 9. Phasing (audit-first, gated — stop & wait at each gate)

- **Phase 0 — Audit & fix drift.** Model IDs 4.7→4.8 + add Fable 5 tier + effort axis across `skills/orchestration/SKILL.md`, `README.md`, `docs/agent-roles.md`; purge any `Mythos 5`; fix `Devgapperk`→`devgap` slug; fix the broken `context-mode` native module (`npm rebuild better-sqlite3`, or `/ctx-upgrade`). Atomic, attributable PRs.
- **Phase 1 — The brain (substrate-neutral).** Author global `CLAUDE.md` + `AGENTS.md`/`context.md` templates + central registry skeleton + the vault `Kleiber/` structure (`Standards/`, `Daily/`, `Ventures/`).
- **Phase 2 — Plugin enforcement.** Implement/wire the 4 hooks; verify loop-state survives a simulated loop; apply model×effort routing in the orchestration skill.
- **Phase 3 — Go supervisor (`loop.go`).** Build the Go runtime per §5.5: `main.go` CLI, `brain.go` ripgrep hydration, `loop.go` supervisor with build-gate + medic escalation + loop-guard abort + Obsidian status append. Gate on a real `-loop` run against one venture.
- **Phase 4 — Pilot.** Generate `AGENTS.md` for 2–3 ventures (proposed: WPC, Specter dualmotor, AM Building); dogfood one interactive (plugin) and one autonomous (`-loop`) task per venture.
- **Phase 5 — Roll out.** Remaining ventures + docs + README update + vault MOC index.

## 10. Success criteria

- A new session in any profiled venture repo auto-loads the right brand rules, roster, and routing without manual prompting.
- A simulated 5× repeated error halts via hook, with `context.md` showing an accurate hook-written loop count (not model-reported).
- `/kleiber` spawns teammates on Fable 5 / Opus 4.8 / Sonnet 4.6 / Haiku 4.5 per the declared + overridden routing.
- Resuming a session reads `context.md` and continues from the "Resume from here" block.
- Zero references to `Opus 4.7` as the top tier or `Devgapperk` slug remain in the repo.

## 11. Open questions (resolve during planning)

- Exact `cwd`→venture detection mechanism (git remote match vs. directory-name map vs. a `.kleiber-venture` marker file). Shared by both runtimes.
- Whether the central registry duplicates or links existing project skills (e.g. `specter-dualmotor-lp`, `supabase-vite-form-fix`) to avoid drift.
- Soft-token-cap thresholds per tier.
- Whether Phase 0's `context-mode` fix belongs in this repo's scope or is tracked separately.
- Go runtime: how does `loop.go` pass **effort** to `claude` (CLI flag support per-invocation) vs. model only? Confirm before Phase 3.
- Go vs. plugin **drift control**: both encode the §6 routing table — does it live in one shared file (e.g. `routing.json`) both read, rather than two hand-kept copies?
- `Ventures/<v>/AGENTS.md` link direction (repo→vault symlink for reading, vs. generated copy) — must keep the repo file real for Codex/clones.

## 12. Risks

- **Advisory-vs-enforced confusion** (mitigated by D4 — the whole design hinges on it).
- **Registry/skill drift** — two sources of venture truth. Mitigation: registry links skills, never restates locked facts (honors "never claim canonical without reading source").
- **Agent teams are research preview** — Kleiber's foundation may shift; keep the personalization layer engine-agnostic where possible.
