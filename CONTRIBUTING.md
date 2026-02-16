# Contributing to Kleiber

Thanks for your interest in contributing!

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Enable agent teams: `export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
4. Ensure `jq` and `git` are installed

## Development Workflow

1. Create a feature branch from `main`
2. Make your changes
3. Run `shellcheck` on modified `.sh` files
4. Validate JSON with `jq . < file.json`
5. Test hooks in a live Claude Code session
6. Commit with a descriptive message
7. Open a pull request

## Code Standards

- Use `#!/bin/bash` and `set -euo pipefail`
- Read hook input from stdin: `INPUT=$(cat)`, parse with `jq`
- Pre-hooks: exit 2 to block, exit 0 to allow
- Post-hooks: always exit 0
- Keep scripts focused — one responsibility per file

## Pull Request Guidelines

- Keep PRs focused on a single change
- Include a clear description
- All shell scripts must pass `shellcheck`
- Test with a real Claude Code agent team session if possible

## Reporting Issues

Include: Claude Code version, OS, steps to reproduce, expected vs actual behavior, and hook output.

## Questions?

Open an issue or reach out at [devgap.co](https://devgap.co).

