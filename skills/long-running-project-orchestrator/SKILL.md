---
name: long-running-project-orchestrator
description: Orchestrate end-to-end software project delivery over milestones with adaptive setup interview, persistent project state, verifier gates, optional subagent/worktree teams, reviewer/fixer loops, and compact handoff state. Use for "build this whole project", large multi-file features, autonomous project execution, or multi-hour/multi-day implementation work. Do not use as the primary loop for empirical optimization or paper reproduction; route those to long-running-research-loop or paper-research.
---

# Long-Running Project Orchestrator

Use this skill for project delivery: turning a spec into a sequence of implementation milestones with verification and review gates.

This is different from `long-running-research-loop`. Project delivery asks "what do we need to build next?" Research/optimization asks "what does the evidence say after this attempt?" If a project turns into a scored empirical loop, route that slice to `long-running-research-loop` (lean mode for single-session optimization, full mode for multi-session).

## Load order

Before using this skill:
- Load `requirements-interview` if the goal, acceptance criteria, non-goals, or autonomy boundaries are unclear.
- Load `implementation-quality` before substantial code changes.
- Load `prompting-techniques` before delegating to subagents, Codex, or external models.
- Load `data-trace-inspection` before changing data, evals, traces, training, red-team, or agent-loop behavior.

Reference files:
- Read `references/project-state-templates.md` when creating or repairing `.agent/` state.
- Read `references/subagent-team-prompts.md` before dispatching implementer/reviewer/fixer agents.
- Read `references/worktree-integration.md` before using git worktrees or merging parallel work.

## Operating model

The orchestrator owns project state. Workers may read state, but only the orchestrator updates canonical `.agent/` files unless explicitly delegated.

Scale state to the task. Do not create ceremony for work that fits in the current session.

- **Single-session feature:** no `.agent/` state by default. Use a short plan in chat and normal verification.
- **Medium multi-file feature:** create only the files that prevent real drift, usually `.agent/GOAL.md`, `.agent/VERIFIER.md`, and `.agent/current_state.md`.
- **Long-running or multi-agent project:** use the full state model below.

Full state model:

```txt
.agent/
  GOAL.md              # stable intent: goal, users, acceptance criteria, non-goals
  PLAN.md              # milestone plan and task breakdown
  STANDARDS.md         # repo-specific quality bar
  VERIFIER.md          # exact commands and evidence required before "done"
  current_state.md     # short active state; one page max
  tasks.jsonl          # append/update task ledger
  decisions.jsonl      # append-only decision log
  attempts.jsonl       # verifier attempts, failures, retries, blocked work
  reviews.md           # current review findings and resolution status
  artifacts/           # logs, screenshots, transcripts, reports
  archive/             # superseded plans, old summaries, stale state
```

Do not create a single giant `progress.md` narrative. Long prose progress files become stale context. Markdown is for stable intent and current summary; JSONL is for history; artifacts are for proof.

## Setup phase

Do not start autonomous execution from a vague prompt.

1. Interview Sid enough to remove product/research/technical ambiguity that would change implementation.
2. Inspect the repo and infer local conventions, existing verifier commands, deployment/runtime shape, and likely protected surfaces.
3. Choose the state depth from the operating model above. For long-running or multi-agent projects, write or update `.agent/GOAL.md`, `.agent/STANDARDS.md`, `.agent/VERIFIER.md`, and `.agent/PLAN.md`; for medium work, create only the files that prevent real drift.
4. Break the plan into milestones and tasks. Each task needs owner scope, dependencies, acceptance criteria, and verification.
5. If persistent state is being used, write `.agent/current_state.md` with only current milestone, next action, verifier, and blockers.
6. Before the first long autonomous milestone, present the concrete plan and verifier. Signoff is per-plan, not per-session; an earlier "go ahead" does not authorize a materially different plan, product behavior, cost profile, or risk level.

When explaining the setup to Sid, use concept-level language first, then implementation detail. Example: "The data enters here, gets validated here, then branches into training and evaluation. If we do not define the split boundary now, an agent can accidentally improve the score by leaking training data into eval."

## Execution loop

At each milestone:

1. Read `.agent/GOAL.md`, `.agent/PLAN.md`, `.agent/STANDARDS.md`, `.agent/VERIFIER.md`, and `.agent/current_state.md`.
2. Identify the next task or task group.
3. Decide local vs delegated execution:
   - do locally: tiny fixes, tightly coupled work, urgent critical-path decisions
   - delegate: independent multi-file tasks with clear ownership and verifier
   - ask Sid: product behavior, security, cost, destructive git, credentials, irreversible architecture
4. Before adding a new behavior-critical dependency or execution path, ask what plausible-but-wrong output would look like and build the smallest detector for it. Examples: one real API call, a reference-vs-new-path comparison, a schema round trip, a rendered prompt sample, or a small parity fixture.
5. If delegating, assign disjoint file/module ownership and use the prompts in `references/subagent-team-prompts.md`.
6. Verify worker output directly. Do not trust subagent reports without tests, diffs, logs, or artifacts.
7. Integrate on the project branch or integration worktree. Do not casually merge to `main`.
8. Run the milestone verifier from `.agent/VERIFIER.md`.
9. Run a reviewer pass for meaningful milestones.
10. Fix blocking review findings. Non-blocking findings may be deferred only if recorded with rationale and `revisit_if`.
11. Update `tasks.jsonl`, `decisions.jsonl`, `attempts.jsonl`, `reviews.md`, and `current_state.md`.

Repeat until the project goal is met, a gate blocks progress, or Sid should make a decision.

## Task ledger statuses

Use stable task statuses:
- `pending`
- `in_progress`
- `blocked`
- `implemented`
- `verified`
- `review_changes_requested`
- `done`
- `deferred`

Use `attempts.jsonl` for verifier runs and failed/blocked attempts. Keep negative evidence scoped: this exact task, this exact command, this exact result, this retry condition.

## Autonomy boundaries

Act without asking when the choice is low-risk, reversible, and repo-native.

Ask Sid when:
- the decision changes product behavior or user workflow
- the architecture has materially different paths with real tradeoffs
- security, privacy, data policy, legal, or release risk is involved
- the action is destructive or expensive
- credentials, paid services, large downloads, or long GPU jobs are needed
- success criteria are not actually clear

Do not use "we will not ask again" as a rule. Upfront interviews reduce ambiguity; they do not remove the need for judgment when new information appears.

## Review gates

Every meaningful milestone needs a review gate:
- implementation matches the goal and non-goals
- verifier passed or unresolved gaps are explicit
- tests are meaningful, not mock theater
- style matches the repo
- no unrelated cleanup drift
- no hidden eval/gold/judge changes unless explicitly in scope
- no stale state or broad negative prose in `.agent/current_state.md`

If a reviewer and implementer disagree, the orchestrator decides from evidence. Do not loop forever. Escalate to Sid only when the remaining issue changes product/architecture/security/cost.

## Completion

Before reporting complete:
1. Run the strongest practical verifier in `.agent/VERIFIER.md`.
2. Run or perform a final cross-cutting review.
3. Update `.agent/current_state.md` with final verified state.
4. Move obsolete plans or stale summaries to `.agent/archive/`.
5. Report what was built, what was verified, what remains risky, and the next useful step.

Do not call a project done because the checklist is complete. Done means the requested behavior exists and the evidence supports it.
