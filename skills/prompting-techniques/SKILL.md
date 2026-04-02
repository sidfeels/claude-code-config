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

## Final reminder

The point of delegation is not to outsource thinking. The point is to get a cleaner perspective, a stronger challenge, or a deeper analysis than the current thread can provide.
You might use this to launch sub agents and prompt them carefully for any task, or prompt and use codex-plugin to ask codex (gpt-5.4-xhigh).

Use other agents to reduce bias, not multiply it.

