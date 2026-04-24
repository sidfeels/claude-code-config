---
name: prompting-techniques
description: Prepare unbiased, high-signal prompts for subagents, Codex, and external models. Use when asking for a fresh view, plan critique, review, rescue, or deep outside consultation.
---

# Prompting Techniques

Use this skill whenever you are about to ask another agent, model, or reviewer for help.

The goal is not merely to "write a prompt." The goal is to create a prompt that preserves truth, avoids tunnel vision, and gets a genuinely useful second perspective.

## Core principle

Most bad delegations fail for one of three reasons:
1. The reviewer is biased by the lead agent's preferred explanation.
2. The reviewer receives too little context and gives generic advice.
3. The reviewer receives too much noisy context and inherits stale assumptions.

This skill exists to avoid all three.

Always separate:
- **Verified facts**: things observed in code, logs, docs, tests, traces, or outputs.
- **Observations**: patterns seen, but not yet causally explained.
- **Suspicions**: hypotheses about root cause, best plan, or likely fix.
- **Desired deliverable**: what kind of answer you want back.

Never present suspicions as facts.

## First choose the delegation mode

Before writing the prompt, decide which mode you need.

### 1. Blind diagnosis
Use when you want a real fresh view.
Do this for bugs, regressions, odd eval behavior, unexplained benchmark movement, or architecture uncertainty.

Give:
- symptoms
- constraints
- relevant files
- logs / traces / outputs
- what has been tried
- desired result format

Do **not** lead with your preferred root cause.

### 2. Targeted falsification
Use when you already have a strong hypothesis, but want to avoid self-confirmation.

Give:
- the suspected cause or plan
- the strongest evidence for it
- ask the reviewer to **try to falsify it first**
- ask for alternative explanations if falsification succeeds

This is better than asking "do you agree?"

### 3. Plan critique
Use after a non-trivial plan and before expensive implementation.

Ask the reviewer to check:
- hidden assumptions
- missing edge cases
- cheaper or simpler paths
- dependency/order risks
- evaluation risks
- where the plan may fail in repo reality

### 4. Implementation review
Use after a meaningful chunk of work, not after every tiny edit.

Ask the reviewer to check:
- correctness
- missing tests or weak verification
- simpler implementation paths
- integration risks
- style mismatch with repo patterns
- likely maintainer objections

### 5. Rescue / plateau
Use when the current line of attack has stalled.

Summarize:
- current goal
- best verified result
- what has been tried
- what failed
- where progress plateaued
- what kind of new direction is needed

Ask for a **different frame**, not small variations of the same idea.

### 6. Deep outside consultation
Use for GPT-5.4 Pro or equivalent only when:
- architecture decisions are genuinely hard
- the task needs deeper strategic reasoning
- there is a deadlock between plausible approaches
- the problem is novel enough that a stronger external reasoning pass is worth the latency and manual copy/paste

Do not escalate routine coding or simple repo review to a heavyweight model.

### 7. Hint, don't roadmap

Use when you want the reviewer (subagent, Codex, external model) to explore independently for a niche or novel implementation, and you suspect your own plan may be wrong.

The problem this mode fixes: if you hand a reviewer your preferred route as a numbered plan, they will usually execute it instead of disagreeing with it. You then get back polished execution of the wrong idea.

Give:
- the goal
- hard constraints and protected surfaces
- relevant artifacts, files, traces
- **areas worth inspecting**, not fixes
- what kind of evidence would count as an answer
- the decision you need to make

Do **not** give:
- a step-by-step implementation plan
- your preferred root cause
- a ranked list of fixes
- stale failed-attempt lists unless directly relevant to the current question

Good:
> Investigate whether the batching path, cache invalidation logic, or prompt formatter could explain this latency regression. Return ranked hypotheses with supporting evidence and the next discriminating check for each.

Bad:
> I think cache invalidation is broken in `cache.py`. Check `invalidate_on_write`, then patch it, then add a test for stale entries.

The Good version preserves the reviewer's independence; the Bad version turns them into an executor.

This mode pairs naturally with Template A (blind diagnosis). Use Template B (targeted falsification) instead when you already have a strong hypothesis and specifically want it stress-tested.

## Prompt construction rules

### Rule 1: Say what problem is being solved
Start with the real goal, not the immediate local step.

Bad:
> Check this file for a bug around batching.

Better:
> We are trying to explain a 12% throughput regression in a VLM inference path after a refactor. I need an independent diagnosis of likely causes and the best next discriminating checks.

### Rule 2: Give enough context to reason, not enough to drown
Include:
- relevant repo/module context
- the exact subsystem or files that matter
- short outputs, logs, diffs, metrics, or traces
- constraints (time, safety, API limits, compatibility)
- what success would look like

Avoid dumping giant unrelated transcripts.

### Rule 3: Distinguish evidence from interpretation
Explicitly label sections:
- `Verified facts`
- `Observed symptoms`
- `Current suspicions`
- `Open questions`

This lowers the chance that the receiving model treats your guesses as ground truth.

### Rule 4: Ask for structured output
Always request an output format.

Good examples:
- top 3 hypotheses with supporting and disconfirming evidence
- critique of the plan, then a revised plan
- likely bug locations ranked by confidence
- maintainer-style review with blocking / non-blocking issues
- what to try next, in order

Unstructured prompts produce vague responses.

### Rule 5: Ask for disconfirming evidence
For diagnosis or design questions, ask explicitly:
- what evidence would prove this wrong?
- what alternative explanation best fits the facts?
- what important assumption might be false?

This is one of the best defenses against tunnel vision.

### Rule 6: Never ask another model to merely bless your choice
Avoid prompts like:
- "I think the bug is in X, confirm please"
- "This plan is good, right?"
- "Review this and tell me it's fine"

Replace them with prompts that invite disagreement.

### Rule 7: Specify the decision boundary
If the answer should recommend action, say what threshold matters.

Examples:
- whether to re-architect or patch locally
- whether to escalate to a new worktree
- whether this is PR-ready
- whether the eval is trustworthy enough to optimize against

## File and artifact inclusion policy

When preparing a prompt for another model or manual handoff:
- include only the files or snippets that are decision-relevant
- prefer the smallest self-contained snippets over whole files
- if a whole file matters, say why
- include diffs instead of full files when the question is about a recent change
- include benchmark tables, traces, or stack traces when available
- never include secrets or protected evaluation assets

If manual copy/paste is required, explicitly tell Sid:
- which files to paste
- which snippets are enough
- which command outputs to include
- what can be omitted safely

## When to use Codex

Codex is best as:
- plan critic
- implementation reviewer
- adversarial reviewer
- rescue lane for a stuck problem
- alternate implementation perspective

Do **not** use Codex after every tiny implementation step. Use it at meaningful checkpoints.

If asking Codex for review, specify whether you want:
- standard review
- adversarial review
- rescue / alternate path
- implementation suggestion

## When to use GPT-5.4 Pro

Use only when a deeper outside reasoning pass is justified.

Good triggers:
- architecture deadlock
- hard research planning
- novel algorithmic framing
- proof-like reasoning or tradeoff analysis where shallow review is not enough

Before escalating, compress the state into a clean packet. Do not paste raw conversation sludge.

## Standard prompt templates

### Template A: Blind diagnosis

```text
Goal:
[What we are ultimately trying to achieve]

Context:
[Short subsystem / repo context]

Verified facts:
- [...]
- [...]

Observed symptoms:
- [...]
- [...]

What has already been tried:
- [...]
- [...]

Constraints:
- [...]

Relevant files/snippets:
- [file/path + why it matters]
- [file/path + why it matters]

Task:
Give an independent diagnosis. Do not assume my current theory is correct.
Return:
1. Top 3 hypotheses, ranked
2. Evidence for each
3. Disconfirming evidence or what would falsify each
4. The next 2-3 discriminating checks to run
```

### Template B: Targeted falsification

```text
Goal:
[Goal]

Current hypothesis:
[I suspect X because Y]

Verified facts:
- [...]

Relevant artifacts:
- [...]

Task:
Try to falsify this hypothesis first.
If it survives, say why.
If it fails, give the best alternative explanation.
Return:
1. Strongest reason the hypothesis may be wrong
2. Whether the current evidence is sufficient
3. Best alternative explanation
4. Best next test to distinguish them
```

### Template C: Plan critique

```text
Goal:
[Goal]

Proposed plan:
1. ...
2. ...
3. ...

Constraints:
- [...]

Repo/context notes:
- [...]

Task:
Critique this plan like a strong maintainer or staff engineer.
Return:
1. Hidden assumptions
2. Biggest failure modes
3. Cheaper or simpler alternatives
4. Missing verification steps
5. Revised plan if needed
```

### Template D: Implementation review

```text
Goal:
[Goal]

What changed:
[Short summary]

Diff/files:
- [...]

Verification already run:
- [...]

Task:
Review this as if it were a serious PR.
Return:
1. Blocking issues
2. Non-blocking improvements
3. Missing tests / weak verification
4. Style or architecture mismatches
5. Whether this looks ready to ship, and if not, why
```

### Template E: Rescue / plateau

```text
Goal:
[Goal]

Best verified current result:
[Metric / state]

Tried approaches:
- [approach] -> [result]
- [approach] -> [result]

Plateau pattern:
[What keeps happening]

Constraints:
- [...]

Task:
Give a materially different angle, not micro-variations of the same approach.
Return:
1. What assumptions may be trapping the current search
2. 2-3 different directions worth trying
3. Why each direction could work
4. Which one to test first
```

### Template F: GPT-5.4 Pro handoff

```text
Goal:
[True end goal]

Current state:
[What exists now]

Best verified facts:
- [...]
- [...]

Current suspicions:
- [...]

Relevant repo/files:
- [file + why it matters]

Failed or weak approaches:
- [...]

Constraints:
- [...]

What I need from you:
[architecture decision / strategy / deep critique / novel framing]

Please answer in this format:
1. Main conclusion
2. Why
3. What assumptions matter most
4. Best path forward
5. What to avoid
```

## Additional guidance for manual copy/paste handoffs

When the user will manually paste into another interface, end by producing:
1. a polished prompt
2. the exact files/snippets to paste
3. optional supporting artifacts to include if space allows
4. one sentence explaining what kind of answer to expect back

## After receiving external input

When Sid pastes back a response from GPT-5.4 Pro, or when Codex returns a review:
- State what you are adopting and why.
- State what you are discarding and why.
- Update the plan or code accordingly.

Do not silently absorb everything or silently ignore everything. External advice is input, not truth — reconcile it against repo evidence before acting on it.

## Codex plugin — invocation guide

**This section is the single source of truth for Codex invocation.** Whenever any skill (optimization-loop, paper-research, implementation-quality, or any other) says to use Codex, always load this skill first for the correct command syntax and flags. No other skill documents how to invoke the plugin.

**Anti-patterns — never do these:**
- Never use the raw `codex` binary (`codex exec`, `codex --quiet`, etc.). Always use the plugin commands below.
- Never invoke Codex commands via the `Skill` tool (e.g. `Skill(codex:rescue)` or `Skill(codex:codex-rescue)`). There is no such skill — `codex:codex-rescue` is a subagent, not a skill, and `codex:rescue` is a slash command. A `Skill` call re-enters the slash command and hangs the session (a documented v1.0.3 bug that v1.0.4 warns against explicitly). Valid entry points: the user-typed slash command (`/codex:rescue ...`), or Claude invoking the subagent directly via `Agent(subagent_type: "codex:codex-rescue", prompt: "...")` for autonomous delegation. Both paths route through the same subagent — only the `Skill` path is broken.
- Never sleep-poll to check if a Codex task is done. Use `--background` and then `/codex:status --wait` (optionally `--timeout-ms <ms>`) to block until the most recent job completes, or `/codex:status <job-id> --wait` for a specific one. Plain `/codex:status` for a non-blocking check.
- Never pipe prompts to `codex` via stdin or shell redirects. Pass the prompt as free text after the flags.

Run `/codex:setup` first if Codex is not yet configured.

### Command selection

| Task | Command |
|------|---------|
| Diagnosis, fix, rescue, research, implementation | `/codex:rescue` |
| Standard code review of local git changes | `/codex:review` |
| Adversarial / design-challenge review of local git changes | `/codex:adversarial-review` |
| Check job progress | `/codex:status` |
| Fetch completed job output | `/codex:result` |
| Cancel a running job | `/codex:cancel` |

`/codex:rescue` is the general-purpose delegation command. Use it for everything that is not a review of uncommitted or branch-level git changes. `/codex:review` and `/codex:adversarial-review` only operate on git diffs.

### Flags

**Effort level** (`--effort`):
- `xhigh` — maximum reasoning. Use for architecture review, subtle bugs, security review, anything where missing a detail is expensive. This is the right default for most non-trivial work.
- `high` — strong reasoning, slightly faster than xhigh.
- Omit the flag to let the plugin choose. Bias toward `xhigh` when the task matters.

**Execution mode**:
- `--wait` — foreground, blocks until Codex finishes. Use for quick tasks (estimated under 3-5 minutes).
- `--background` — detached, returns immediately. Use for longer investigations, multi-file reviews, or implementation tasks. Check progress with `/codex:status`, fetch output with `/codex:result`.

**Thread continuity**:
- `--resume` — continue the most recent Codex thread from this session. Use for follow-up instructions on the same investigation: "apply the top fix", "dig deeper on hypothesis 2", "now try approach B".
- `--fresh` — start a new Codex thread with no prior context. Use when the problem changed materially or the prior thread explored a dead end.
- Omit both when starting a new task. Most of the time you do not need `--fresh` — only use it when you explicitly want to discard prior Codex context.

**Model**:
- Always use `--model gpt-5.4`. This is the strongest Codex model and should be the default for all tasks.

**Review-specific flags** (for `/codex:review` and `/codex:adversarial-review`):
- `--base <ref>` — compare against a specific git ref (default: auto-detected main branch).
- `--scope auto|working-tree|branch` — what to review.

### Prompt text placement

For `/codex:rescue`, the free-text prompt follows all flags:
```
/codex:rescue --background --effort xhigh Diagnose why training loss plateaus after epoch 12. Relevant files: src/training/loop.py and src/data/loader.py. Loss drops normally until epoch 12 then oscillates around 0.34. Return top 3 hypotheses ranked by likelihood with evidence.
```

For `/codex:adversarial-review`, optional focus text follows the flags:
```
/codex:adversarial-review --background --base main Focus on the new caching layer and its invalidation paths
```

For `/codex:review`, no prompt text is needed — the review contract is built in:
```
/codex:review --background --base main
```

### Job management

After launching a background job:
1. `/codex:status` — see all active and recent jobs with phase and elapsed time.
2. `/codex:status <job-id>` — detailed status for a specific job.
3. `/codex:result` or `/codex:result <job-id>` — fetch the full output once complete.
4. `/codex:cancel <job-id>` — cancel if direction changed.

After results come back, apply the "After receiving external input" rules: state what you adopt and why, what you discard and why, update the plan or code accordingly.

### Decision heuristics

**background vs wait**: wait for bounded questions and single-file checks. Background for multi-file investigation, broad review, implementation, or anything estimated over 3-5 minutes.

**resume vs fresh**: resume when giving follow-up on the same problem. Fresh only when you explicitly want to discard prior Codex context (new problem, different area, dead-end thread). Most of the time, omit both.

**effort**: xhigh for anything where missing a detail is expensive (architecture, concurrency, security, subtle reproduction bugs). medium for moderate well-scoped tasks. Bias toward xhigh — the cost of under-reasoning is usually higher than the cost of extra tokens.

**When NOT to use Codex**: after every tiny edit, for tasks Claude finishes in under a minute, for prompts with no structure ("look at this and tell me what you think").

## Final reminder

The point of delegation is not to outsource thinking. The point is to get a cleaner perspective, a stronger challenge, or a deeper analysis than the current thread can provide.
You might use this to launch subagents with carefully composed prompts, or use the Codex plugin commands above to delegate to Codex.

Use other agents to reduce bias, not multiply it.

