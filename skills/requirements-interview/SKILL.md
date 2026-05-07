---
name: requirements-interview
description: Adaptive requirements interview for ambiguous or non-trivial work. Use before substantial implementation, architecture, product/UX work, ML/research work, agentic harness work, or long-running autonomous execution when the user intent, acceptance criteria, constraints, or tradeoffs are not yet clear. Also use when Sid asks to be grilled, interviewed, or turned from high-level vision into a concrete spec.
---

# Requirements Interview

Use this skill to turn high-level intent into a buildable, verifiable spec. The goal is not to ask many questions. The goal is to remove the ambiguity that would otherwise compound into wrong implementation.

## Core stance

Sid often knows what should exist at the concept level, but may not know which implementation details matter. Act like a senior engineer translating product/research intent into concrete system behavior:
- infer the likely domain from the request
- explain only the technical mechanisms needed to make a decision
- ask questions that expose real tradeoffs
- propose defaults when the repo or goal strongly implies them
- stop interviewing once the remaining ambiguity is low-risk

Do not ask lazy questions such as "what language should I use?" when the repo already answers it. Do not ask "do you want tests?" Ask what kind of evidence would convince Sid the thing works.

## Depth control

Scale the interview to the blast radius:

- **Tiny fix:** no interview; just do it.
- **Small feature:** ask 1-3 blocking questions, or state assumptions and proceed.
- **Multi-file feature:** ask 3-8 questions focused on behavior, boundaries, and verification.
- **End-to-end project or autonomous run:** run a setup interview, write `.agent/GOAL.md`, and usually route to `long-running-project-orchestrator`.
- **Research, ML, eval, or optimization:** identify the target claim/metric, protected evaluation surface, data/traces to inspect, and verifier before implementation.

If the user explicitly asks for "full interview" or "grill me", ask a larger set, but group questions by decision. Prefer several focused rounds over one giant list unless the user wants a full spec pass.

## Adaptive question selection

First classify the task. Use only the relevant lenses.

### Product or UX
Clarify:
- target user and primary workflow
- what the first screen or default path should do
- success criteria from the user's point of view
- taste constraints, density, navigation, and visual hierarchy
- what is explicitly out of scope

Explain tradeoffs in product terms. Example: "If the user repeats this workflow all day, a dense table with filters beats a card-heavy layout. If this is a public launch page, the first viewport needs a stronger visual signal."

### ML, training, or research
Clarify:
- exact research goal or claim
- data source, split, and preprocessing assumptions
- metric, baseline, and acceptable tolerance
- compute budget and environment
- whether this is reproduction, extension, audit, or exploration
- what raw examples/traces must be inspected before changes

Explain mechanisms from the pipeline outward. Example: "The examples flow through preprocessing, then tokenization, then loss masking, then batching. If the mask is wrong, the model can train on prompt tokens instead of answer tokens, so the loss can look valid while the behavior is wrong."

### Agentic harness, evals, or LLM tools
Clarify:
- which model/tool/judge is involved
- tool schemas and real-call verification surface
- success transcript shape
- failure classes to catch
- protected evals, gold labels, judge prompts, or canaries
- cost/privacy constraints for real calls

Explain why mocks are insufficient when relevant. Example: "A mock can prove our parser handles one response shape. It cannot prove the model follows the tool schema, avoids refusal, or stays stable under the real prompt."

### Backend, infra, or data systems
Clarify:
- source of truth and data ownership
- API contracts and failure behavior
- migration/backfill needs
- security and permissions
- deployment/runtime constraints
- observability and rollback needs

Prefer repo-native architecture over generic "best practice" unless the existing pattern is actively harmful.

### Library, framework, or unfamiliar API
Clarify:
- version and runtime constraints
- whether docs/source must be checked before committing to an API
- compatibility with the existing repo
- what should be documented for future sessions

If uncertain about the library, say so and research before proposing signatures or patterns.

## Question style

Ask questions in a way that helps Sid decide:

```text
I see two viable directions:
1. Simple path: [what it buys], but [tradeoff].
2. More structured path: [what it buys], but [tradeoff].

Which matches what you want this to become?
```

When Sid sounds uncertain, explain the mechanism in the project context before asking:

```text
The important choice is where the state lives. If it lives in the browser, the UI is fast but another device will not see it. If it lives in the database, it survives sessions but we need auth and persistence. For your use case, should this feel like a local tool or a durable account-based app?
```

Avoid jargon-only questions. If technical vocabulary is necessary, define it in one sentence tied to the current task.

## Output shape

For non-trivial work, finish the interview with a compact spec:

```md
# Working Spec

## Goal

## Users / Context

## Desired Behavior

## Non-Goals

## Constraints

## Key Decisions

## Acceptance Criteria

## Verification

## Autonomy Boundaries
What the agent may decide alone, and what must come back to Sid.
```

When preparing an autonomous project run, write or update `.agent/GOAL.md` using the same sections. If the work is not going autonomous, a chat summary is enough unless Sid asks for files.

## Completion condition

The interview is complete when:
- the goal is concrete
- success can be verified
- non-goals are explicit enough to prevent scope drift
- remaining assumptions are low-risk or written down
- the next skill or implementation path is clear

Re-run the interview if the goal, acceptance criteria, non-goals, constraints, or autonomy boundaries change materially mid-flight.

Route next:
- end-to-end product/project delivery -> `long-running-project-orchestrator`
- iterative empirical work (scored optimization, eval, benchmark, ablation, training-recipe, multi-session research) -> `long-running-research-loop` (lean mode for single-session, full mode for multi-session)
- paper-derived work -> `paper-research`
- data/eval/trace-dependent work -> `data-trace-inspection`
