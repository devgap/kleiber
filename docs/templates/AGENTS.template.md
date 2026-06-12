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
