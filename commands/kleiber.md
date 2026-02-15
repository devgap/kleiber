---
description: Create and orchestrate an agent team using Kleiber roles and model routing
---

# /kleiber — Orchestrate an Agent Team

The user wants to create an agent team using the Kleiber orchestration method.

## Your Process

1. **Understand the objective**: What does the user want to build, fix, or review?

2. **Select roles**: Based on the task, determine which Kleiber roles are needed:
   - **Architect** (Opus) — only for new systems, security-sensitive designs, or complex refactors
   - **Engineer-Frontend** (Sonnet) — UI work
   - **Engineer-Backend** (Sonnet) — API/server work
   - **Validator** (Haiku) — testing and verification
   - **Scribe** (Haiku) — documentation
   - Not every task needs every role. A bug fix might only need 1-2 engineers + validator.

3. **Decompose into tasks**: Break the objective into independent, parallelizable tasks. Each task should be 1-2 hours of agent work with clear acceptance criteria.

4. **Spawn the team**: Create teammates with the appropriate roles, models, and spawn prompts from the Kleiber orchestration skill.

5. **Use delegate mode**: Coordinate only — do not implement tasks yourself.

6. **Enforce quality gates**: Have Validator verify each completed task. Have Scribe document decisions and progress.

## Example Usage

User says: `/kleiber Build user authentication with login, signup, and password reset`

You should:
- Spawn Architect (opus) to design the auth flow
- After design approval, spawn Engineer-Frontend (sonnet) and Engineer-Backend (sonnet) in parallel
- Spawn Validator (haiku) for continuous verification
- Spawn Scribe (haiku) for documentation
- Use delegate mode throughout
