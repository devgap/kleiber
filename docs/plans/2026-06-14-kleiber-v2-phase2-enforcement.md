# Kleiber v2 — Phase 2: Enforcement (brain goes live) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the authored brain *active*: project the global `CLAUDE.md` into `~/.claude` (loads every session), and add four plugin hooks — `context-init`, `loop-state`, `routing-reminder`, `soft-token-cap` — that enforce policy and own volatile state deterministically.

**Architecture:** Hooks ship inside the **plugin** (`hooks/` + `hooks/hooks.json`), not the user's global `settings.json` — so they're version-controlled, CI-checked, and activated by installing/enabling the plugin (no risky global-settings surgery). The one global mutation is a **reversible symlink** `~/.claude/CLAUDE.md → repo source` (resolves spec §11's projection-direction question: repo is canonical, vault mirrors later). All hooks are bash, `set -euo pipefail`, read JSON stdin, **shellcheck-clean**, `chmod +x` (CI enforces all three).

**Tech Stack:** Bash, `jq`, `shellcheck`, `shasum`/`sha256sum`, `git`, Claude Code hook events (SessionStart, PreToolUse, PostToolUse).

**Source spec:** `docs/specs/2026-06-10-...md` (§5.3 context.md, §5.4 projection, §7 hooks). **Prereq:** Phase 1 present (templates + `routing.json` exist).

**Hook runtime contract (verified against existing hooks):** command paths in `hooks.json` are relative to the plugin root; scripts locate the plugin via `PLUGIN_ROOT="$(dirname "$(cd "$(dirname "$0")" && pwd)")"` and the project via `${CLAUDE_PROJECT_DIR:-$PWD}` (or `.cwd` from stdin). Pre-hooks exit 2 to block; all Phase 2 hooks are non-blocking (exit 0).

---

## File Structure

| File | Responsibility |
|---|---|
| `hooks/context-init.sh` | SessionStart: detect venture, scaffold `context.md`, surface `AGENTS.md` |
| `hooks/loop-state.sh` | PostToolUse: increment `active_loop_count` + write `last_action_hash` into `context.md` (hook-owned) |
| `hooks/routing-reminder.sh` | PreToolUse(Task): emit `routing.json` tier summary so spawns pick model×effort |
| `hooks/soft-token-cap.sh` | PostToolUse: heuristic transcript-size warning (SOFT, never blocks) |
| `hooks/hooks.json` | Register the four hooks alongside existing ones |
| `skills/orchestration/SKILL.md` | One line: read `routing.json` + `AGENTS.md` overrides at spawn |
| `scripts/install-brain.sh` | Reversible projection of global `CLAUDE.md` → `~/.claude` (+ uninstall) |

---

### Task 1: `context-init.sh` (SessionStart)

**Files:** Create `hooks/context-init.sh`; Test inline.

- [ ] **Step 1: Write the hook**

```bash
#!/bin/bash
# context-init.sh — Kleiber SessionStart: detect venture, scaffold context.md, surface AGENTS.md.
# Reads JSON stdin (.cwd). Idempotent. Non-blocking.
set -euo pipefail

INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -z "$PROJECT_DIR" ] && PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

VENTURE=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REMOTE="$(git remote get-url origin 2>/dev/null || true)"
  [ -n "$REMOTE" ] && VENTURE="$(basename -s .git "$REMOTE")"
fi
[ -z "$VENTURE" ] && VENTURE="$(basename "$PROJECT_DIR")"

if [ ! -f "context.md" ]; then
  if [ -f "$PLUGIN_ROOT/docs/templates/context.template.md" ]; then
    cp "$PLUGIN_ROOT/docs/templates/context.template.md" "context.md"
  else
    printf 'current_goal: \nactive_loop_count: 0\nlast_action_hash: \n' > "context.md"
  fi
fi

echo "Kleiber: venture=${VENTURE}"
if [ -f "AGENTS.md" ]; then
  echo "Kleiber: loaded AGENTS.md for ${VENTURE}"
else
  echo "Kleiber: no repo AGENTS.md (central base ventures/${VENTURE}.md applies if present)"
fi
exit 0
```

- [ ] **Step 2: Make executable + shellcheck**

```bash
cd ~/kleiber && chmod +x hooks/context-init.sh && shellcheck hooks/context-init.sh && echo "shellcheck-clean"
```
Expected: `shellcheck-clean` (no findings).

- [ ] **Step 3: Test — scaffolds context.md + detects venture**

```bash
cd ~/kleiber && T=$(mktemp -d) && (cd "$T" && git init -q && git remote add origin https://github.com/devgap/wpc-trustengine.git)
echo "{\"cwd\":\"$T\"}" | hooks/context-init.sh
test -f "$T/context.md" && echo "context.md created"
echo "{\"cwd\":\"$T\"}" | hooks/context-init.sh | grep -q "venture=wpc-trustengine" && echo "venture detected"
rm -rf "$T"
```
Expected: prints `venture=wpc-trustengine ...`, then `context.md created`, then `venture detected`.

- [ ] **Step 4: Commit**

```bash
git add hooks/context-init.sh && git commit -m "feat(hooks): context-init — SessionStart venture detect + context.md scaffold"
```

---

### Task 2: `loop-state.sh` (PostToolUse — hook-owned counter)

**Files:** Create `hooks/loop-state.sh`; Test inline.

- [ ] **Step 1: Write the hook**

```bash
#!/bin/bash
# loop-state.sh — Kleiber PostToolUse: deterministically maintain volatile loop state in context.md.
# The MODEL never writes these counters — this hook does. Non-blocking.
set -euo pipefail

INPUT=$(cat)
PROJECT_DIR="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -z "$PROJECT_DIR" ] && PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
CTX="$PROJECT_DIR/context.md"
[ -f "$CTX" ] || exit 0

TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)"
TINPUT="$(printf '%s' "$INPUT" | jq -c '.tool_input // {}' 2>/dev/null || true)"
HASH="$(printf '%s' "${TOOL}${TINPUT}" | { shasum -a 256 2>/dev/null || sha256sum; } | awk '{print $1}' | cut -c1-12)"

COUNT="$(grep -oE '^active_loop_count: [0-9]+' "$CTX" | awk '{print $2}' | head -1 || true)"
[ -z "$COUNT" ] && COUNT=0
COUNT=$((COUNT + 1))

TMP="$(mktemp)"
sed -e "s/^active_loop_count: .*/active_loop_count: ${COUNT}/" \
    -e "s/^last_action_hash: .*/last_action_hash: ${HASH}/" "$CTX" > "$TMP" && mv "$TMP" "$CTX"
exit 0
```

- [ ] **Step 2: Executable + shellcheck**

```bash
cd ~/kleiber && chmod +x hooks/loop-state.sh && shellcheck hooks/loop-state.sh && echo "shellcheck-clean"
```
Expected: `shellcheck-clean`.

- [ ] **Step 3: Test — counter increments deterministically**

```bash
cd ~/kleiber && T=$(mktemp -d) && cp docs/templates/context.template.md "$T/context.md"
for i in 1 2 3; do echo "{\"cwd\":\"$T\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"ls\"}}" | hooks/loop-state.sh; done
grep "^active_loop_count: 3$" "$T/context.md" && echo "counter=3 OK"
grep -qE "^last_action_hash: [0-9a-f]{12}$" "$T/context.md" && echo "hash written"
rm -rf "$T"
```
Expected: `active_loop_count: 3`, then `counter=3 OK`, then `hash written`.

- [ ] **Step 4: Commit**

```bash
git add hooks/loop-state.sh && git commit -m "feat(hooks): loop-state — hook-owned loop counter + action hash in context.md"
```

---

### Task 3: `routing-reminder.sh` (PreToolUse Task)

**Files:** Create `hooks/routing-reminder.sh`; Test inline.

- [ ] **Step 1: Write the hook**

```bash
#!/bin/bash
# routing-reminder.sh — Kleiber PreToolUse(Task): remind orchestrator of model x effort routing.
# Reads canonical routing.json. Non-blocking (exit 0).
set -euo pipefail
cat > /dev/null
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
RJSON="$PLUGIN_ROOT/routing.json"
[ -f "$RJSON" ] || exit 0
echo "Kleiber routing (model × effort) — choose per task; venture AGENTS.md overrides win:"
jq -r '.tiers | to_entries[] | "  \(.key): \(.value.label) — \(.value.use_for)"' "$RJSON" 2>/dev/null || true
echo "  effort: low→max (default high). Hardest/security ⇒ require plan approval."
exit 0
```

- [ ] **Step 2: Executable + shellcheck**

```bash
cd ~/kleiber && chmod +x hooks/routing-reminder.sh && shellcheck hooks/routing-reminder.sh && echo "shellcheck-clean"
```
Expected: `shellcheck-clean`.

- [ ] **Step 3: Test — emits all four tiers from routing.json**

```bash
cd ~/kleiber && echo '{"tool_name":"Task"}' | hooks/routing-reminder.sh | tee /dev/stderr | grep -cE "hardest:|hard:|build:|grunt:"
```
Expected: a line count of `4`.

- [ ] **Step 4: Commit**

```bash
git add hooks/routing-reminder.sh && git commit -m "feat(hooks): routing-reminder — inject routing.json tiers at Task spawn"
```

---

### Task 4: `soft-token-cap.sh` (PostToolUse — heuristic, soft)

**Files:** Create `hooks/soft-token-cap.sh`; Test inline.

- [ ] **Step 1: Write the hook**

```bash
#!/bin/bash
# soft-token-cap.sh — Kleiber PostToolUse: HEURISTIC context-size warning. Soft — never blocks.
# Honest limitation: real token count isn't available in a hook; we proxy on transcript bytes.
set -euo pipefail
INPUT=$(cat)
TRANSCRIPT="$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)"
{ [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; } || exit 0
LIMIT="${KLEIBER_SOFT_TOKEN_BYTES:-4000000}"
BYTES="$(wc -c < "$TRANSCRIPT" 2>/dev/null | tr -d ' ' || true)"
[ -z "$BYTES" ] && exit 0
if [ "$BYTES" -gt "$LIMIT" ]; then
  echo "Kleiber soft cap: transcript ~${BYTES}B exceeds ${LIMIT}B — consider compacting or commit+summarize. (Soft warning, not enforced.)"
fi
exit 0
```

- [ ] **Step 2: Executable + shellcheck**

```bash
cd ~/kleiber && chmod +x hooks/soft-token-cap.sh && shellcheck hooks/soft-token-cap.sh && echo "shellcheck-clean"
```
Expected: `shellcheck-clean`.

- [ ] **Step 3: Test — warns over a tiny threshold, silent under**

```bash
cd ~/kleiber && T=$(mktemp) && head -c 5000 /dev/zero | tr '\0' 'x' > "$T"
KLEIBER_SOFT_TOKEN_BYTES=1000 sh -c "echo '{\"transcript_path\":\"$T\"}' | hooks/soft-token-cap.sh" | grep -q "soft cap" && echo "warns-over"
KLEIBER_SOFT_TOKEN_BYTES=999999 sh -c "echo '{\"transcript_path\":\"$T\"}' | hooks/soft-token-cap.sh" | grep -q "soft cap" && echo "UNEXPECTED" || echo "silent-under"
rm -f "$T"
```
Expected: `warns-over` then `silent-under`.

- [ ] **Step 4: Commit**

```bash
git add hooks/soft-token-cap.sh && git commit -m "feat(hooks): soft-token-cap — heuristic transcript-size warning (soft)"
```

---

### Task 5: Register hooks in `hooks/hooks.json`

**Files:** Modify `hooks/hooks.json`.

- [ ] **Step 1: Replace the file with the merged registration**

Overwrite `hooks/hooks.json` with (adds `SessionStart`, a `Bash|Edit|Write` PostToolUse block for loop-state + soft-token-cap, and a `Task` PreToolUse block — existing entries preserved):

```json
{
  "hooks": {
    "SessionStart": [
      { "matcher": "", "hooks": [ { "type": "command", "command": "./hooks/context-init.sh", "timeout": 10000 } ] }
    ],
    "Stop": [
      { "matcher": "", "hooks": [ { "type": "command", "command": "./hooks/stop-loop-guard.sh", "timeout": 10000 } ] }
    ],
    "TaskCompleted": [
      { "matcher": "", "hooks": [ { "type": "command", "command": "./hooks/task-completed.sh", "timeout": 30000 } ] }
    ],
    "TeammateIdle": [
      { "matcher": "", "hooks": [ { "type": "command", "command": "./hooks/teammate-idle.sh", "timeout": 10000 } ] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit", "hooks": [
        { "type": "command", "command": "./hooks/post-edit-verify.sh", "timeout": 15000 },
        { "type": "command", "command": "./hooks/brand-drift-check.sh", "timeout": 10000 }
      ] },
      { "matcher": "Bash|Edit|Write", "hooks": [
        { "type": "command", "command": "./hooks/loop-state.sh", "timeout": 5000 },
        { "type": "command", "command": "./hooks/soft-token-cap.sh", "timeout": 5000 }
      ] }
    ],
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "./hooks/block-destructive.sh", "timeout": 5000 } ] },
      { "matcher": "Task", "hooks": [ { "type": "command", "command": "./hooks/routing-reminder.sh", "timeout": 5000 } ] }
    ]
  }
}
```

- [ ] **Step 2: Validate JSON + every referenced script exists & is executable**

```bash
cd ~/kleiber && jq . hooks/hooks.json >/dev/null && echo "json-ok"
for s in $(jq -r '.hooks[][].hooks[].command' hooks/hooks.json | sed 's#^\./##'); do
  test -x "$s" || echo "NOT-EXECUTABLE: $s"
done; echo "exec-checked"
```
Expected: `json-ok`, no `NOT-EXECUTABLE` lines, `exec-checked`.

- [ ] **Step 3: Commit**

```bash
git add hooks/hooks.json && git commit -m "feat(hooks): register context-init/loop-state/routing-reminder/soft-token-cap"
```

---

### Task 6: Orchestration skill reads routing.json at spawn

**Files:** Modify `skills/orchestration/SKILL.md` (Model Routing section).

- [ ] **Step 1: Add the canonical-source instruction**

After the routing table's `### Effort — the second routing axis` block, insert:

```

### Canonical source
At teammate spawn, read `routing.json` (the single source of truth) and overlay the active venture's `AGENTS.md` routing overrides to choose **model × effort**. Do not hardcode model ids in spawn prompts — resolve them from `routing.json`. An id absent from `routing.json` is invalid.

```

- [ ] **Step 2: Verify**

```bash
cd ~/kleiber && grep -q "### Canonical source" skills/orchestration/SKILL.md && grep -q "routing.json" skills/orchestration/SKILL.md && echo "ok"
```
Expected: `ok`.

- [ ] **Step 3: Commit**

```bash
git add skills/orchestration/SKILL.md && git commit -m "docs(orchestration): resolve model x effort from canonical routing.json at spawn"
```

---

### Task 7: Reversible global projection — `scripts/install-brain.sh`

**Files:** Create `scripts/install-brain.sh`.

> This is the one global mutation: symlink `~/.claude/CLAUDE.md` → the repo brain source, with backup + uninstall. `~/.claude/CLAUDE.md` is currently empty, but we back up regardless. Reversible.

- [ ] **Step 1: Write the installer**

```bash
#!/bin/bash
# install-brain.sh — project Kleiber global brain into ~/.claude (reversible).
# Usage: install-brain.sh install | uninstall
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SRC="$REPO_ROOT/docs/templates/global-CLAUDE.md"
DEST="$HOME/.claude/CLAUDE.md"
CMD="${1:-install}"

case "$CMD" in
  install)
    [ -f "$SRC" ] || { echo "missing source: $SRC"; exit 1; }
    mkdir -p "$HOME/.claude"
    if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
      cp "$DEST" "${DEST}.bak-$(date +%s)"
      echo "backed up existing $DEST"
    fi
    ln -sfn "$SRC" "$DEST"
    echo "linked $DEST -> $SRC"
    ;;
  uninstall)
    if [ -L "$DEST" ]; then rm "$DEST"; echo "removed symlink $DEST"; fi
    LATEST="$(ls -t "${DEST}".bak-* 2>/dev/null | head -1 || true)"
    [ -n "$LATEST" ] && { cp "$LATEST" "$DEST"; echo "restored $LATEST -> $DEST"; }
    ;;
  *) echo "usage: install-brain.sh install|uninstall"; exit 1 ;;
esac
```

- [ ] **Step 2: Executable + shellcheck**

```bash
cd ~/kleiber && chmod +x scripts/install-brain.sh && shellcheck scripts/install-brain.sh && echo "shellcheck-clean"
```
Expected: `shellcheck-clean`.

- [ ] **Step 3: Run the projection + verify it resolves**

```bash
cd ~/kleiber && scripts/install-brain.sh install
readlink "$HOME/.claude/CLAUDE.md"
grep -q "Global Operating Brain" "$HOME/.claude/CLAUDE.md" && echo "brain-live"
```
Expected: the symlink path printed, then `brain-live`. (Revert anytime: `scripts/install-brain.sh uninstall`.)

- [ ] **Step 4: Commit**

```bash
git add scripts/install-brain.sh && git commit -m "feat(install): reversible global CLAUDE.md projection (symlink + backup)"
```

---

### Task 8: Phase 2 gate

- [ ] **Step 1: Full CI-equivalent local check**

```bash
cd ~/kleiber
find hooks scripts -name '*.sh' -type f -print0 | xargs -0 shellcheck && echo "shellcheck-all-clean"
find . -name '*.json' -not -path './.git/*' -type f -print0 | xargs -0 -I{} sh -c 'jq . "{}" >/dev/null' && echo "json-all-valid"
find hooks scripts -name '*.sh' -type f ! -perm -u+x -print | grep . && echo "NON-EXEC FOUND" || echo "all-exec"
```
Expected: `shellcheck-all-clean`, `json-all-valid`, `all-exec`.

- [ ] **Step 2: Drift invariants (per evolved guard rule)**

```bash
cd ~/kleiber
grep -rni "mythos\|Devgapperk" hooks/ scripts/ skills/ routing.json; echo "drift_exit=$? (1=clean)"
jq -e '.tiers.hard.model == "claude-opus-4-8"' routing.json >/dev/null && echo "hard-tier-invariant-ok"
```
Expected: no output / `drift_exit=1`, then `hard-tier-invariant-ok`.

- [ ] **Step 3: Marker commit**

```bash
git commit --allow-empty -m "chore(phase2): enforcement live — hooks registered, global brain projected"
```

---

## Self-Review

**Spec coverage (§7 hooks + §5.4 projection):**
- `context-init` → Task 1. `loop-state` → Task 2. `routing-reminder` → Task 3. `soft-token-cap` → Task 4. ✓
- Hook registration → Task 5. ✓
- Global CLAUDE.md projection → Task 7 (reversible). ✓
- Reuse-unchanged hooks (stop-loop-guard, block-destructive, post-edit-verify, brand-drift, task-completed, teammate-idle) preserved in Task 5's hooks.json. ✓
- Soft-token-cap honestly labeled heuristic/soft (spec's "be honest" note). ✓

**Placeholder scan:** every hook + installer shown in full; every step has exact commands + expected output. ✓

**Consistency:** all hooks use the same `PLUGIN_ROOT`/`PROJECT_DIR` resolution; `context.md` field names match `docs/templates/context.template.md` (`active_loop_count`, `last_action_hash`); routing read from canonical `routing.json`. ✓

**Risk/scope:** only one global mutation (Task 7), reversible with backup + `uninstall`. Hooks live in the plugin (not global `settings.json`). Activation of hooks in *this* CC instance still requires installing/enabling the plugin — note for the executor; the projection (Task 7) works immediately regardless. ✓

**Activation note:** To fire these hooks in Claude Code, install the plugin (`/plugin marketplace add devgap/kleiber` → `/plugin install kleiber@kleiber-marketplace`) or enable the local plugin. The global brain (Task 7) loads with no plugin needed.
