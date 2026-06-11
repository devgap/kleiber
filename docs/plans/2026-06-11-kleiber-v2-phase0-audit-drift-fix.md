# Kleiber v2 — Phase 0: Audit & Drift-Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove all factual drift from the Kleiber repo — bring model routing to the current catalog (Fable 5 / Opus 4.8 / Sonnet 4.6 / Haiku 4.5 + effort axis), fix the install slug, and guarantee no fictional model (`Mythos 5`) is present — so later phases build on accurate ground.

**Architecture:** Pure documentation/config edits to the existing plugin repo, each gated by a `grep` verification step (the "test" analog for doc changes). No runtime code changes. One atomic commit per logical edit, matching the repo's audit-first governance.

**Tech Stack:** Markdown, JSON (plugin manifests), `grep` for verification, `git` for atomic commits.

**Source spec:** `docs/specs/2026-06-10-kleiber-v2-venture-aware-os-design.md` (§6 routing, §9 Phase 0).

**Scope note:** This is the FIRST of 6 phase plans. Phases 1–5 get their own plans, written and approved one at a time after the prior phase executes (gated, per governance rule D1). Do not start Phase 1 work here.

---

## File Structure (what Phase 0 touches)

| File | Responsibility | Change |
|---|---|---|
| `README.md` | Public-facing install + cost | Fix slug (L30); refresh cost table (L~148–152) |
| `skills/orchestration/SKILL.md` | The routing the model follows | Refresh routing table (L~56–60) + add Effort subsection |
| `docs/agent-roles.md` | Role→model reference | Architect ID 4-7→4-8 (L7) |
| `.claude-plugin/plugin.json` | Plugin manifest description | Model list in description (L4) |
| `.claude-plugin/marketplace.json` | Marketplace description | Model list in description (L12) |

**Deliberately NOT touched:** `agents/*.md` frontmatter (`model: opus|sonnet|haiku` are aliases that resolve to current versions — not stale). Generic role headers like `### ARCHITECT (Opus)` in the skill (no version pinned). The Fable-5-for-hardest *escalation behavior* is Phase 2 routing work, not a Phase 0 string fix.

---

### Task 1: Fix the install marketplace slug

**Files:**
- Modify: `README.md:30`

- [ ] **Step 1: Verify the stale slug is present (failing check)**

Run: `grep -n "Devgapperk/kleiber" README.md`
Expected: `30:/plugin marketplace add Devgapperk/kleiber`

- [ ] **Step 2: Apply the edit**

Replace in `README.md`:

```
/plugin marketplace add Devgapperk/kleiber
```

with:

```
/plugin marketplace add devgap/kleiber
```

- [ ] **Step 3: Verify the fix (passing check)**

Run: `grep -n "Devgapperk" README.md; echo "exit=$?"`
Expected: no output, `exit=1` (grep found nothing).

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "fix(readme): correct install slug Devgapperk -> devgap"
```

---

### Task 2: Refresh the orchestration routing table + add Effort axis

**Files:**
- Modify: `skills/orchestration/SKILL.md` (Model Routing section, ~L52–60)

- [ ] **Step 1: Verify the stale table is present (failing check)**

Run: `grep -n "Opus 4.7" skills/orchestration/SKILL.md`
Expected: `58:| Opus 4.7 | $5 / $25 | Architecture, security, compliance, complex refactors |`

- [ ] **Step 2: Replace the routing table**

Replace this block in `skills/orchestration/SKILL.md`:

```
| Model | Cost (Input/Output per M) | Use For |
|-------|---------------------------|---------|
| Opus 4.7 | $5 / $25 | Architecture, security, compliance, complex refactors |
| Sonnet 4.6 | $3 / $15 | Feature implementation, APIs, UI components (default) |
| Haiku 4.5 | $1 / $5 | Validation, docs, boilerplate, mechanical tasks |
```

with:

```
| Model | Cost (Input/Output per M) | Use For |
|-------|---------------------------|---------|
| Fable 5 | $10 / $50 | Hardest calls: security/compliance/payment architecture, gnarly multi-service decisions (require plan approval) |
| Opus 4.8 | $5 / $25 | Architecture, complex refactors, hard reasoning |
| Sonnet 4.6 | $3 / $15 | Feature implementation, APIs, UI components (default) |
| Haiku 4.5 | $1 / $5 | Validation, docs, boilerplate, mechanical tasks |
```

- [ ] **Step 3: Add the Effort axis subsection**

Immediately AFTER the routing table (before the `### Force Opus + Require Plan Approval` heading), insert:

```

### Effort — the second routing axis

Routing is **model × effort**, not model alone. Set `output_config.effort` to trade latency/cost for intelligence. Supported on Fable 5 / Opus 4.6+ / Sonnet 4.6; errors on Haiku 4.5 and older Sonnets.

| Effort | Use for |
|--------|---------|
| `max` | Correctness-critical: compliance / security / payment architecture (pair with Fable 5 or Opus 4.8 + plan approval) |
| `xhigh` | Coding & agentic builds (Opus 4.8) — best quality/efficiency point |
| `high` | Default for intelligence-sensitive work |
| `medium` | Cost-sensitive builds |
| `low` | Subagents, validation, mechanical tasks (pairs with Haiku 4.5) |

```

- [ ] **Step 4: Verify (passing check)**

Run: `grep -n "Opus 4.7" skills/orchestration/SKILL.md; echo "stale_exit=$?"; grep -cE "Fable 5|Effort — the second routing axis" skills/orchestration/SKILL.md`
Expected: no `Opus 4.7` line, `stale_exit=1`, and count `2`.

- [ ] **Step 5: Commit**

```bash
git add skills/orchestration/SKILL.md
git commit -m "feat(routing): refresh tiers to Fable 5/Opus 4.8 and add effort axis"
```

---

### Task 3: Refresh the README cost table

**Files:**
- Modify: `README.md` (Cost section, ~L148–152)

- [ ] **Step 1: Verify stale row present (failing check)**

Run: `grep -n "Opus 4.7" README.md`
Expected: `150:| Architecture & security | Opus 4.7 | $5 in / $25 out |`

- [ ] **Step 2: Replace the cost table body**

Replace this block in `README.md`:

```
| Task type | Model used | Cost per M tokens |
|-----------|-----------|-------------------|
| Architecture & security | Opus 4.7 | $5 in / $25 out |
| Feature building | Sonnet 4.6 | $3 in / $15 out |
| Testing & docs | Haiku 4.5 | $1 in / $5 out |
```

with:

```
| Task type | Model used | Cost per M tokens |
|-----------|-----------|-------------------|
| Hardest (security / compliance / payments architecture) | Fable 5 | $10 in / $50 out |
| Architecture & high reasoning | Opus 4.8 | $5 in / $25 out |
| Feature building | Sonnet 4.6 | $3 in / $15 out |
| Testing & docs | Haiku 4.5 | $1 in / $5 out |
```

- [ ] **Step 3: Verify (passing check)**

Run: `grep -n "Opus 4.7" README.md; echo "stale_exit=$?"; grep -c "Fable 5 | \$10 in" README.md`
Expected: no `Opus 4.7`, `stale_exit=1`, count `1`.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs(readme): refresh cost table to current model catalog"
```

---

### Task 4: Refresh agent-roles + plugin manifests

**Files:**
- Modify: `docs/agent-roles.md:7`
- Modify: `.claude-plugin/plugin.json:4`
- Modify: `.claude-plugin/marketplace.json:12`

- [ ] **Step 1: Verify stale IDs present (failing check)**

Run: `grep -rn "claude-opus-4-7\|Opus 4.7/Sonnet" docs/agent-roles.md .claude-plugin/`
Expected: three matches — `docs/agent-roles.md:7`, `.claude-plugin/plugin.json:4`, `.claude-plugin/marketplace.json:12`.

- [ ] **Step 2: Fix the Architect model ID in agent-roles**

Replace in `docs/agent-roles.md`:

```
## Architect (claude-opus-4-7)
```

with:

```
## Architect (claude-opus-4-8)
```

- [ ] **Step 3: Fix the plugin.json description**

In `.claude-plugin/plugin.json`, within the `description` field, replace the substring:

```
model routing (Opus 4.7/Sonnet 4.6/Haiku 4.5)
```

with:

```
model routing (Fable 5/Opus 4.8/Sonnet 4.6/Haiku 4.5)
```

- [ ] **Step 4: Fix the marketplace.json description**

In `.claude-plugin/marketplace.json`, replace the same substring:

```
model routing (Opus 4.7/Sonnet 4.6/Haiku 4.5)
```

with:

```
model routing (Fable 5/Opus 4.8/Sonnet 4.6/Haiku 4.5)
```

- [ ] **Step 5: Verify JSON still parses + IDs updated (passing check)**

Run:
```bash
python3 -m json.tool .claude-plugin/plugin.json >/dev/null && python3 -m json.tool .claude-plugin/marketplace.json >/dev/null && echo "json-ok"
grep -rn "claude-opus-4-7\|Opus 4.7/Sonnet" docs/agent-roles.md .claude-plugin/; echo "stale_exit=$?"
```
Expected: `json-ok`, then no matches and `stale_exit=1`.

- [ ] **Step 6: Commit**

```bash
git add docs/agent-roles.md .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "docs(roles,manifest): bump model IDs to Opus 4.8 + add Fable 5"
```

---

### Task 5: Repo-wide drift verification gate

**Files:**
- No edits — this is the final assertion that Phase 0 is complete.

- [ ] **Step 1: Assert zero stale strings remain (excluding planning docs)**

Run:
```bash
grep -rniE "opus 4\.7|claude-opus-4-7|opus-4-7|Devgapperk|Mythos" . \
  --include="*.md" --include="*.json" --include="*.sh" --include="*.js" --include="*.yml" \
  | grep -vE "docs/specs/|docs/plans/"
echo "exit=$?"
```
Expected: no output and `exit=1` (the grep matched nothing outside the planning docs).

> If any line prints, fix that file the same way (edit → re-run this grep) before continuing. Do NOT proceed with matches present.

- [ ] **Step 2: Assert the new catalog IS present**

Run: `grep -rcE "Fable 5" README.md skills/orchestration/SKILL.md .claude-plugin/plugin.json | grep -v ":0"`
Expected: each of the three files reports a non-zero count.

- [ ] **Step 3: Commit the phase marker**

```bash
git commit --allow-empty -m "chore(phase0): drift verification gate passed — catalog current, no Mythos/4.7/Devgapperk"
```

---

### Task 6 (OPTIONAL, out-of-repo): Fix the broken context-mode native module

> **Flagged in spec §11 as possibly out of scope.** This is environment hygiene in `~/.claude/plugins/`, NOT a change to the kleiber repo — it produces no repo commit. Do it only if you want the context tooling working now; otherwise skip and track separately.

**Files:** none in this repo.

- [ ] **Step 1: Confirm the breakage**

Run: `node -e "require(process.env.HOME + '/.claude/plugins/cache/context-mode/context-mode/1.0.107/node_modules/better-sqlite3')" 2>&1 | head -3`
Expected: a `NODE_MODULE_VERSION` mismatch error.

- [ ] **Step 2: Rebuild or upgrade (pick one)**

Preferred (upgrades + fixes hooks): run the `/context-mode:ctx-upgrade` skill in Claude Code.
Fallback (rebuild in place):
```bash
cd ~/.claude/plugins/cache/context-mode/context-mode/1.0.107 && npm rebuild better-sqlite3
```

- [ ] **Step 3: Verify**

Run the Step 1 command again.
Expected: no error (silent success).

---

## Self-Review (run before handing off)

**Spec coverage (§9 Phase 0):**
- "Model IDs 4.7→4.8" → Tasks 2, 3, 4. ✓
- "add Fable 5 tier" → Tasks 2 (routing), 3 (cost), 4 (manifests). ✓
- "add effort axis" → Task 2 Step 3. ✓
- "purge any Mythos 5" → Task 5 Step 1 (guard — none currently present). ✓
- "fix Devgapperk→devgap slug" → Task 1. ✓
- "fix broken context-mode native module" → Task 6 (optional, out-of-repo). ✓

**Placeholder scan:** No TBD/TODO; every edit shows exact old→new text and exact verify commands. ✓

**Consistency:** Model strings used identically across tasks — `Fable 5`, `Opus 4.8`, `Sonnet 4.6`, `Haiku 4.5`; slug `devgap/kleiber`. ✓

**Branch:** Work continues on `spec/kleiber-v2-venture-aware-os` (already checked out) or a fresh `phase0/audit-drift-fix` branch — confirm with the executor before Task 1.
