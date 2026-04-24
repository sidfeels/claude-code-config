---
description: Core delegation and review behavior. Keep external review unbiased, useful, and evidence-seeking. Prefer hints over roadmaps so the reviewer can disagree with your direction.
---

# Delegation and Review Core

When asking another agent, model, or reviewer for help:

- Separate **verified facts**, **observations**, and **suspicions**. Never present a guess as ground truth.
- For a real fresh view, prefer **blind diagnosis**: give symptoms, constraints, relevant files or artifacts, and the desired output without leading with a preferred cause.
- When there is already a strong hypothesis, ask the reviewer to **falsify it first** before supporting it.
- **Hint, do not roadmap.** For exploratory delegation (subagent, Codex, or any reviewer you want an independent view from), give the goal, hard constraints, relevant artifacts, and promising areas to inspect — but do *not* hand over a ranked list of fixes or a step-by-step implementation plan. Without this discipline the reviewer inherits your mistaken route and becomes an executor, not a fresh view.
- Ask for **disconfirming evidence**, plausible alternatives, and the next best discriminating check.
- Use outside review at meaningful checkpoints: after a non-trivial plan, after a risky implementation chunk, before a PR, or when stuck. Do not ask for review after every tiny edit.
- Ask for structured output: ranked hypotheses, blocking issues, missing verification, simpler alternatives, and clear next steps.
- Treat Codex and other outside models as **independent reviewers or rescue lanes**, not as agreement machines.
- Reconcile all external advice against repo reality, tests, logs, traces, and actual behavior before acting on it.
