# Stage 6 — Verification

## Purpose
Decide what has actually been demonstrated.
This stage is where you separate a runnable scaffold, a faithful baseline, a partial reproduction, and a real claim match.

## Inputs
- code or scaffold from Stage 5
- `VERIFIER_PLAN.md`
- `CLAIMS_AND_TARGETS.md`
- `AMBIGUITY_LEDGER.md`

## Outputs
Update:
- `RESULTS.md`
- `HANDOFF.md`
- optionally `CLAIM_VERIFICATION.md`

## Verification ladder

### 1. Build / import / interface verification
Check:
- imports
- construction
- config loading
- shape and interface sanity
- minimal forward/backward path if relevant

### 2. Algorithm / equation alignment checks
Check:
- key tensor shapes
- formula semantics
- masking conventions
- schedule behavior
- metric computation exactness
- where implementation intentionally differs from framework defaults

### 3. Paper-aligned sanity checks
Examples:
- expected dimensionality
- expected invariances
- small toy examples
- official-code parity on a narrow controlled input if appropriate

### 4. Claim-targeted verification
This is the real test for reproduce / audit / extension.

Examples:
- reproduce a metric within stated tolerance
- match the behavior of Algorithm 1
- confirm the official code differs from the paper on identified points
- verify that the extension preserves the original baseline while improving metric X

### 5. Heavy verification
Only if allowed and justified:
- dataset-scale training
- GPU runs
- benchmark suites
- long-horizon evaluation

Read `guardrails/environment_and_compute.md` first and ask Sid before expensive shared-resource actions.

## Result labels
Be explicit. Use one of:
- **explained**
- **scaffold built**
- **faithful baseline built**
- **partial reproduction**
- **claim reproduced**
- **audit completed**
- **extension baseline verified**
- **inconclusive**
- **blocked**

Do not say "reproduced" when you only have a scaffold or a smoke-checked implementation.

## Sources of mismatch to check before concluding failure
If the result misses the paper:
- unresolved ambiguity
- wrong metric implementation
- dataset/split mismatch
- batch-size semantics
- seed averaging vs single run
- framework default mismatch
- official-code drift
- hardware/precision differences
- hidden prompt/template or eval details
- simple implementation bug

Before concluding any of the above, run `data-trace-inspection` on the actual eval samples / agent traces / training data — "failed reproduction" is frequently "data-processing mismatch we did not inspect." Look at the rendered examples (post-tokenization, with visible roles / special tokens / loss masks / refusals) before blaming the algorithm.

Do not jump from "numbers do not match" to "the paper is wrong."

## External review
At this stage, a Codex review is useful when:
- the claim target is subtle
- the verifier logic itself may be wrong
- a PR or handoff is near
- you suspect a paper-vs-code mismatch

## Completion condition
This stage is complete when `RESULTS.md` can answer:
- what was actually verified?
- what was not verified?
- which claim target was met, missed, or left inconclusive?
- what is the most likely reason for mismatch if any?
