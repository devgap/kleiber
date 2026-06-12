# Kleiber Brain Templates

Three layers (substrate-neutral — both the Go supervisor and the CC plugin consume them):

1. **global-CLAUDE.md** → installed to `~/.claude/CLAUDE.md` (Phase 2). Declared policy + house rules + routing pointer.
2. **AGENTS.template.md** → generate one `AGENTS.md` per venture repo. Roster + routing overrides + gates. Read by Claude Code and Codex.
3. **context.template.md** → seeded per session as `context.md` (gitignored). Volatile loop state, **hook-written**.

Canonical routing data: `/routing.json`. Central venture registry: `/ventures/`. Human source of truth: the Obsidian `Kleiber/` vault folder.

Projection (symlink vs generate) is wired in Phase 2 — these are authoring sources only.
