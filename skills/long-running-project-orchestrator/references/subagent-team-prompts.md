# Subagent Team Prompts

Use these prompts only when subagents are available and the user/runtime permits delegation. If subagents are unavailable, execute the same work packages locally.

The orchestrator owns canonical `.agent/` state. Workers may read state, but should not update `.agent/current_state.md`, `tasks.jsonl`, `decisions.jsonl`, or `attempts.jsonl` unless explicitly assigned.

## Implementer Prompt

```text
Goal:
We are implementing part of a larger project. Your task is: <task name>.

Project context:
- Read .agent/GOAL.md for intent and acceptance criteria.
- Read .agent/STANDARDS.md for repo-specific quality rules.
- Read .agent/VERIFIER.md for verification expectations.
- Relevant current state: <short excerpt from .agent/current_state.md>

Ownership:
- You own these paths/modules: <paths>
- Do not modify files outside this scope unless required; if required, explain why before doing broad edits.
- You are not alone in the codebase. Other workers may be editing separate areas. Do not revert or overwrite unrelated changes.

Task:
<task description from .agent/PLAN.md>

Acceptance criteria:
- <criteria>

Workflow:
1. Inspect neighboring code and tests before editing.
2. Implement the smallest repo-native change that satisfies the task.
3. Add or update meaningful tests when the task needs them.
4. Run the relevant verifier commands.
5. Self-review your diff for overengineering, style drift, weak tests, and unrelated cleanup.

Report:
- What changed
- Files changed
- Verifier commands and results
- Any assumptions made
- Any risks or follow-up needed
```

## Reviewer Prompt

Use after a coherent milestone or risky task, not after every tiny edit.

```text
Goal:
Review this milestone as a serious engineering review.

Project context:
- Read .agent/GOAL.md, .agent/STANDARDS.md, and .agent/VERIFIER.md.
- Milestone: <milestone name>
- Completed tasks: <task ids and summaries>
- Base/head: <base>..<head>

Verified facts:
- <commands run and results>
- <artifacts>

Task:
Review the diff and implementation. Prioritize bugs, behavioral regressions, missing tests, verifier gaps, security/privacy issues, architecture mismatch, and style drift.

Do not spend time on minor formatting preferences unless they hide a real maintainability problem.

Return:
1. Blocking issues, with file/line and why they matter
2. Non-blocking issues, with rationale
3. Missing verification or weak tests
4. Simpler implementation alternatives if the current design is overbuilt
5. Verdict: APPROVE or REQUEST CHANGES
```

## Fixer Prompt

```text
Goal:
Fix one specific review issue without broad cleanup.

Issue:
<exact reviewer finding, file/line, severity, desired behavior>

Project context:
- Read .agent/STANDARDS.md and .agent/VERIFIER.md.
- Relevant task/milestone: <id>

Ownership:
- You own these paths/modules for this fix: <paths>
- Do not modify unrelated files.
- You are not alone in the codebase. Do not revert unrelated edits.

Workflow:
1. Reproduce or inspect the issue.
2. Apply the smallest correct fix.
3. Run the relevant verifier.
4. Self-review the diff for scope creep.

Report:
- What changed
- Files changed
- Verifier command and result
- Whether the review issue is fully resolved
```

## Explorer Prompt

Use when the orchestrator needs codebase understanding or a design-space read, not implementation.

```text
Goal:
We need an independent read on <question>.

Context:
- Project goal: <one sentence>
- Relevant files/areas: <paths>
- Constraints/protected surfaces: <constraints>

Task:
Investigate the repo and return evidence. Do not implement changes.

Return:
1. Relevant files and patterns
2. Verified facts
3. Observations that are not yet causal
4. Risks or hidden assumptions
5. Recommended next discriminating check
```

## Delegation Rules

- Give workers concrete ownership scopes.
- Avoid parallel workers on the same files unless the task is explicitly a review or exploration.
- Ask reviewers for disagreement, not validation.
- Keep implementation and review as separate context windows when possible.
- Verify all worker reports in the orchestrator context before integrating.
