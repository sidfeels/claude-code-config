# Stage 7 — Extension

## Purpose
Turn a faithful baseline into a disciplined extension workflow.
This stage only activates when the mode is `extend`.

## Inputs
- verified or at least frozen baseline
- `CLAIMS_AND_TARGETS.md`
- `AMBIGUITY_LEDGER.md`
- `RESULTS.md`

## Outputs
Write or update:
- `EXTENSION_OPTIONS.md`
- `SELECTED_EXTENSION.md`
- `HANDOFF.md`

## Rule zero
Do not start extension work from a mushy baseline.
Freeze the baseline first:
- commit it if git is in use
- or create a worktree / branch checkpoint
- or clearly mark the baseline state in `RESULTS.md`

## Step 1: Explain the paper and baseline to Sid
Before ideating, give Sid a concise paper explanation:
- what the paper really contributes
- what was reproduced or scaffolded
- what remains uncertain
- where the obvious extension surfaces are

This keeps Sid in the loop and often improves extension choice quality.

## Step 2: Identify extension surfaces
Think in categories:
- algorithmic change
- optimization / training change
- evaluation / harness change
- systems / inference change
- data or sampling change
- interpretability / analysis addition
- robustness or safety addition
- portability / integration change

Do not brainstorm aimlessly. Tie surfaces to the paper’s actual bottlenecks, assumptions, or missing evaluations.

## Step 3: Ask Sid the highest-leverage extension questions
Useful questions:
- what matters most: quality, speed, compute, robustness, interpretability, or integration?
- should we stay paper-faithful except for one change, or are broader deviations allowed?
- what budget exists for experiments?
- is the target a publishable insight, an internal improvement, or a production contribution?
- should we optimize an existing codebase, or explore a new branch/worktree?

Keep the question count low but high-value.

## Step 4: Parallel ideation
Use subagents for independent extension ideation with lightly different framing.
Ask each to return:
- candidate extension
- why it could matter
- what evidence from the paper motivates it
- risk / downside
- verifier for success
- implementation cost

Keep these threads independent enough that they do not all inherit the same tunnel vision.

## Step 5: Synthesize the option set
Write `EXTENSION_OPTIONS.md` with:
- option
- rationale
- expected upside
- expected risk
- required verifier
- required compute
- whether it depends on unresolved ambiguity

Then explain the best few options to Sid.

## Step 6: Codex pressure test
Once the option set is coherent, use Codex for one checkpoint:
- challenge whether the top extensions are actually novel/useful
- ask if there are simpler or more factual extension directions
- ask whether the extension ignores any obvious literature or repo constraint

Do not ping Codex for each speculative idea separately.

## Step 7: Select and freeze
After Sid selects a direction, write `SELECTED_EXTENSION.md`:
- chosen extension
- why
- baseline state it branches from
- primary metric
- guardrail metrics
- immediate next step

## Step 8: Route to the right execution path
If the chosen extension becomes a measurable search problem, invoke `optimization-loop`.
If the extension is a one-shot code integration, continue with a normal implementation plan.
If the extension is strategically murky and both Claude and Codex plateau, prepare a GPT-5.4 Pro handoff via `prompting-techniques`.

## Completion condition
This stage is complete when:
- the baseline is frozen
- the option set is synthesized
- Sid has enough context to choose
- one extension path is selected and ready for execution
