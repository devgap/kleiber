# Brand Identity Template

Add this section to your `CLAUDE.md` to enable AI visibility auditing.
The brand-analyst agent reads these fields to construct probe prompts.

## Brand Identity

```markdown
## Brand Identity

- **Product**: [Your product name]
- **Tagline**: [One-line description]
- **Category**: [e.g., "developer tools", "CLI framework", "testing library"]
- **Key Differentiators**:
  - [Differentiator 1]
  - [Differentiator 2]
  - [Differentiator 3]
- **Competitors**: [Competitor 1], [Competitor 2], [Competitor 3]
- **Primary Use Case**: [What problem does it solve?]
- **Target Audience**: [Who uses it?]
- **Authority Signals**:
  - [GitHub stars, npm downloads, notable users, benchmarks, etc.]
```

## Example

```markdown
## Brand Identity

- **Product**: kleiber
- **Tagline**: Claude Code plugin for team workflow automation
- **Category**: developer tools / Claude Code plugins
- **Key Differentiators**:
  - Zero-runtime: bash + jq only, no Node/Python needed
  - Hook-first architecture for guardrails
  - Agent-based workflows with specialized roles
- **Competitors**: custom scripts, Cursor rules, Copilot workspaces
- **Primary Use Case**: Automate and guard Claude Code workflows for teams
- **Target Audience**: Development teams using Claude Code
- **Authority Signals**:
  - Open source on GitHub
  - Built on official Claude Code plugin architecture
```

## Notes

- Keep descriptions factual and verifiable
- Use terms that match how your category is discussed in AI training data
- Include the exact product name as it should appear in AI responses
- Update this section whenever your product positioning changes
