# Project State Templates

Use these templates when creating `.agent/` state for `long-running-project-orchestrator`.

Principle: markdown holds stable intent and compact current state. JSONL holds history. Artifacts hold proof.

## `.agent/GOAL.md`

```md
# Goal

## Problem
What problem are we solving, and why does it matter?

## Desired Outcome
What should exist when this is done?

## Users / Context
Who uses it, and in what situation?

## Acceptance Criteria
- [ ] Observable behavior or outcome
- [ ] Verification evidence required

## Non-Goals
- What this project will not build
- What should not be optimized yet

## Constraints
- Technical:
- Product / research:
- Compute / cost:
- Security / privacy:

## Autonomy Boundaries
- Agent may decide:
- Ask Sid before:
```

## `.agent/PLAN.md`

```md
# Plan

## Architecture / System Shape
Short explanation of the main components and how data/control flows through them.

## Milestones

### Milestone 1: <name>
Goal:
Depends on:
Verifier:

Tasks:
- id: M1.T1
  name:
  status: pending
  owner_scope:
  dependencies:
  acceptance:
  verification:

### Milestone 2: <name>
Goal:
Depends on:
Verifier:
Tasks:
```

## `.agent/STANDARDS.md`

Customize this to the repo. Do not paste generic "enterprise" standards if the project is a small research repo.

```md
# Standards

## Repo Style
- Naming:
- File organization:
- Error handling:
- Typing:
- Tests:
- Comments:

## Quality Bar
- Match local patterns unless there is a correctness reason not to.
- Keep abstractions minimal and task-shaped.
- No unrelated cleanup drift.
- No hardcoded secrets.
- No mock-only proof for LLM/tool/agent behavior.

## Domain Rules
- Product/UI:
- ML/research:
- Agentic/eval:
- Backend/infra:

## Git Discipline
- Work on the task branch/integration branch.
- Keep diffs coherent.
- Ask before destructive history changes.
```

## `.agent/VERIFIER.md`

```md
# Verifier

## Primary Verifier
Command:
Expected pass condition:
Artifact path:

## Fast Checks
- command:
- command:

## Manual / Real-World Checks
- screenshots:
- real API/LLM/tool call:
- sample trace inspection:

## Protected Surfaces
- eval/gold/judge paths:
- data splits:
- prompt templates:
- canaries:

## Known Gaps
- What this verifier does not prove yet:
```

## `.agent/current_state.md`

Keep this under one page.

```md
# Current State

## Goal
One sentence.

## Current Milestone
- id:
- status:

## Current Best Verified State
- checkpoint:
- verifier:
- result:
- artifact:

## Next Action
One concrete action.

## Active Blockers
- blocker:
  needs:

## Open Questions For Sid
- only questions that materially affect product, architecture, security, cost, or verification
```

## `.agent/tasks.jsonl`

One JSON object per task state change. Prefer appending a new row over editing old history.

```json
{"task_id":"M1.T1","timestamp":"2026-05-08T10:00:00Z","status":"pending","name":"Add auth middleware","owner_scope":["src/auth/**","tests/auth/**"],"dependencies":[],"acceptance":["authenticated requests reach handler","anonymous requests get 401"],"verifier":"npm test -- auth"}
{"task_id":"M1.T1","timestamp":"2026-05-08T11:15:00Z","status":"verified","checkpoint":"abc1234","verifier":"npm test -- auth","artifact":".agent/artifacts/M1.T1-auth-test.txt"}
{"task_id":"M1.T2","timestamp":"2026-05-08T11:30:00Z","status":"deferred","reason":"password reset email requires provider choice","revisit_if":"Sid chooses an email provider or auth scope expands beyond local login"}
```

## `.agent/decisions.jsonl`

Use for non-trivial decisions only.

```json
{"timestamp":"2026-05-08T10:20:00Z","decision":"Use server-side sessions","options":["JWT-only","server-side sessions"],"chosen":"server-side sessions","rationale":"Logout and revocation matter more than stateless simplicity","tradeoffs":["requires persistent session store"],"revisit_if":"deployment target cannot run the session store"}
```

## `.agent/attempts.jsonl`

Use for verifier runs, failed integrations, blocked attempts, and retries.

Allowed statuses:
- `pass`
- `fail_introduced`
- `fail_preexisting`
- `blocked`
- `invalid_run`
- `inconclusive`
- `deferred`

```json
{"attempt_id":"M1.T1-test-1","timestamp":"2026-05-08T11:00:00Z","task_id":"M1.T1","command":"npm test -- auth","status":"fail_introduced","summary":"middleware returned 403 where acceptance requires 401","artifact":".agent/artifacts/M1.T1-test-1.log","next_action":"fix status mapping and rerun auth tests"}
```

## `.agent/reviews.md`

```md
# Reviews

## Milestone <id> Review

Base:
Head:
Verifier:

### Blocking
- [ ] file:line - issue - fix owner

### Non-Blocking
- [ ] issue - rationale for defer/fix

### Verdict
APPROVE / REQUEST CHANGES
```
