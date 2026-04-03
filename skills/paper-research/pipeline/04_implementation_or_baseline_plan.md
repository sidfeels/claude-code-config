# Stage 4 — Implementation or Baseline Plan

## Purpose
Translate the claim target and ambiguity audit into an implementation plan that is:
- scoped correctly
- verifier-aware
- faithful enough for the chosen mode
- structured for execution without losing provenance

## Inputs
- `REQUEST_MODE.md`
- `CLAIMS_AND_TARGETS.md`
- `AMBIGUITY_LEDGER.md`
- `REPRODUCTION_FEASIBILITY.md`
- `SOURCE_GRAPH.md`

## Outputs
Write these to `.paper_research_work/<paper_slug>/`:
- `IMPLEMENTATION_PLAN.md`
- `VERIFIER_PLAN.md`
- `FILE_MAP.md`

Before writing code, also load:
- `implementation-quality-deep`
- `prompting-techniques` when delegating
- relevant domain knowledge files

## Step 1: Decide the baseline type
Choose the correct baseline for the mode.

### explain
No implementation plan beyond tiny illustrative snippets if necessary.

### scaffold
Plan a faithful minimal scaffold with clear TODO or uncertainty boundaries.

### reproduce
Plan a claim-targeted baseline capable of testing the selected claim honestly.

### audit
Plan the comparison path: paper ↔ official code ↔ current repo.

### extend
Plan a faithful baseline first. Extension work starts only after the baseline is frozen and verified enough.

### port
Plan a semantic-preserving translation. Clarify what behavior must remain invariant.

## Step 2: Choose the execution stack
Default rule:
- if official code exists and the goal is fidelity, prefer the same framework unless Sid requests otherwise
- if there is an existing local repo to contribute to, prefer that repo’s stack and style
- if the paper is framework-agnostic and Sid wants a new scaffold, use the stack that best matches the surrounding project or the most reproducible option

Do not switch frameworks casually in reproduction mode.
A framework change is a fidelity change.

## Step 3: Decide the implementation chunks
Do **not** plan one giant monolith.
Do **not** ask Codex to bless each tiny component separately.

Plan in coherent chunks such as:
1. configs / interfaces / data contracts
2. core mechanism or math
3. integration into model / train / inference path
4. verifier and smoke tests
5. claim-targeted evaluation

A chunk should be large enough to be meaningful and small enough to verify.

## Step 4: Design the verifier before code
Write `VERIFIER_PLAN.md` before or alongside `IMPLEMENTATION_PLAN.md`.

A good verifier plan states:
- smoke checks
- shape / interface checks
- equation- or algorithm-aligned checks
- official-code parity checks if relevant
- claim-targeted checks
- what requires CPU only
- what requires dataset / GPU / long run
- what cannot yet be verified

If the plan has no serious verifier, it is not ready.

## Step 5: Decide the documentation layer
Create research-state docs before code, not after everything is "done."

At minimum keep:
- `PAPER_BRIEF.md`
- `CLAIMS_AND_TARGETS.md`
- `AMBIGUITY_LEDGER.md`
- `IMPLEMENTATION_PLAN.md`
- `VERIFIER_PLAN.md`

These are not ceremony. They are the guardrails against drift and hallucinated certainty.

## Step 6: Decide where to use subagents
Good subagent uses at this stage:
- reading a reference paper that closes one ambiguity
- scanning a large official codebase section
- checking repo-local patterns if contributing into an existing codebase
- brainstorming extension surfaces after the baseline plan exists

Bad subagent use:
- asking five agents to produce competing full plans before the ambiguity audit exists
- asking a subagent to "implement the whole paper"

## Step 7: Decide where to use Codex
Default checkpoint policy:
- one Codex critique after the integrated plan
- one Codex review after the first coherent scaffold or risky chunk
- one Codex/adversarial review before PR or handoff if the work is substantial

Do not ask Codex to review every micro-component. That wastes tokens and amplifies local framing noise.

## Step 8: Ask Sid only the highest-leverage remaining questions
Examples:
- which result/claim matters most?
- do we optimize for fidelity or speed of contribution?
- if extension: which axis matters most — quality, compute, interpretability, robustness, systems?
- is GPU usage allowed, and in which environment?
- should git checkpoints / PR hygiene be maintained from the start?

## Completion condition
Do not proceed until:
- the baseline type is clear
- execution stack is justified
- coherent chunks are defined
- the verifier plan exists
- the remaining open questions are small enough that implementation will not become blind guessing
