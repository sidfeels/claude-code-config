# Stage 5 — Code Generation

## Purpose
Implement the chosen baseline or port in a way that is faithful, reviewable, and explicit about uncertainty.

## Inputs
- `IMPLEMENTATION_PLAN.md`
- `VERIFIER_PLAN.md`
- `AMBIGUITY_LEDGER.md`
- relevant source artifacts
- relevant domain knowledge files
- `implementation-quality`

## Outputs
- code changes or generated scaffold
- updated `RESULTS.md` as verification evidence appears
- updates to `AMBIGUITY_LEDGER.md` when ambiguities are resolved in a justified way

## Core principle
Do not treat this stage as "turn the paper into files."
Treat it as "implement the chosen baseline with provenance, minimal unnecessary invention, and reviewer-legible decisions."

## Step 1: Decide the provenance style
Use the least noisy provenance style that still preserves truth.

### Standalone reproduction scaffold
You may use more explicit provenance in code:
- concise section/equation comments on non-trivial choices
- comments for unresolved or `[UNSPECIFIED]` items
- a `REPRODUCTION_NOTES.md` or `PROVENANCE.md`

### Existing repo / real contribution PR
Keep the code repo-native.
Do not litter production files with citation graffiti.
Instead:
- keep inline comments only where the paper-specific choice is non-obvious
- store most provenance in `REPRODUCTION_NOTES.md`, `PROVENANCE.md`, or issue/PR notes

## Step 2: Implement by coherent chunk
Implement one meaningful chunk at a time as defined in `IMPLEMENTATION_PLAN.md`.

Suggested order:
1. config and interfaces
2. core mechanism
3. integration path
4. verifier or smoke path
5. claim-targeted eval path

Do not jump around randomly. Do not let docs lag by many chunks.

## Step 3: Verify after each chunk
After each coherent chunk:
- run the relevant smoke/interface checks
- inspect outputs
- update `RESULTS.md`
- update `AMBIGUITY_LEDGER.md` if a previously open ambiguity was actually resolved

Do not defer all verification to the end.

## Step 4: Use official code as a resolver, not a crutch
If official code clarified something:
- implement the decision in a repo-native way
- record it as `FROM_OFFICIAL_CODE`
- do not blindly copy style or unrelated infra
- if official code and paper diverge, keep the divergence visible

## Step 5: Handle blocking ambiguity honestly
If a chunk reaches a blocking ambiguity:
- do not silently choose and plow ahead
- either narrow the scope to scaffold mode,
- or ask Sid,
- or use a targeted external review/handoff,
- or stop and record the blocker

In scaffold mode, an explicit stub with a high-quality note can be correct.
In reproduction mode, a silent guess is not.

## Step 6: Codex checkpoint policy
Use Codex only at coherent checkpoints:
- after the first baseline scaffold
- after a risky or mathematically delicate chunk
- before PR or handoff if the implementation is substantial

The best Codex prompts at this stage are:
- "does this implementation actually match Eq. N / Algorithm 1?"
- "what paper-vs-code mismatch or hidden assumption do you see?"
- "is there a simpler faithful implementation path?"

Not:
- "please review every helper function"

## Step 7: Keep state synced
After meaningful progress, update:
- `IMPLEMENTATION_PLAN.md` if the plan changed
- `AMBIGUITY_LEDGER.md` if ambiguity closed or worsened
- `RESULTS.md` with new evidence
- `HANDOFF.md` if you are ending the session

## Completion condition
This stage is complete when:
- the baseline or scoped artifact is implemented to the current plan
- verification exists for each major chunk
- remaining ambiguity is explicit
- the code and docs tell the same truth
