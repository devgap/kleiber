## Summary

Brief description of what this PR does.

## Changes

What was changed and why.

## Component

Which part of Kleiber does this affect?

- [ ] Hooks
- [ ] Agents
- [ ] Commands
- [ ] Skills
- [ ] Plugin config
- [ ] CI / Tooling
- [ ] Documentation

## Testing

How were these changes tested?

- [ ] ShellCheck passes on all .sh files
- [ ] JSON files validate (jq)
- [ ] Hook scripts are executable (chmod +x)
- [ ] Hooks tested with sample stdin JSON input
- [ ] Manual test with Claude Code agent teams

## Checklist

- [ ] Shell scripts use stdin JSON API (not env vars)
- [ ] Pre-hooks exit 2 to block, exit 0 to allow
- [ ] Post-hooks always exit 0
- [ ] No hardcoded paths (use relative paths from repo root)
- [ ] Updated CLAUDE.md if behavior changed
- [ ] Updated README.md if user-facing behavior changed

## Related Issues

Closes #

