# Stage 8 — Handoff and State Hygiene

## Purpose
End the session in a way that a future agent or Sid can resume without inheriting confusion, tunnel vision, or stale pessimism.

## Inputs
- current artifacts
- current code state
- current results

## Outputs
Update:
- `HANDOFF.md`
- `RESULTS.md`
- optional detailed experiment logs

## Two-layer state model

### Layer 1: Primary handoff
This is the only thing a fresh session should need immediately.
Keep it short and high-signal.

Include:
- mode
- goal
- target claim or artifact
- current best verified state
- durable findings
- unresolved blockers
- immediate next step
- re-check conditions if the environment changed

### Layer 2: Secondary logs
This is where detailed attempts live:
- experiment log
- extension idea graveyard
- debug notes
- run outputs
- failed hypotheses

Future sessions may consult these, but they should not be forced into the primary context.

## Typed outcome language
Do not write vague poison like:
- "this idea failed"
- "already tried"
- "impossible"
- "nothing worked"

Instead type outcomes narrowly:
- **invalid_run** — result not trustworthy
- **attempt_failed** — this implementation under these conditions failed
- **partial_signal** — some evidence, not enough to trust
- **clean_regression** — evidence against this implementation
- **ruled_out_for_now** — repeated good evidence lowers priority
- **durable_finding** — verified truth worth carrying forward

## What to update after meaningful work
At minimum keep these aligned:
- `AMBIGUITY_LEDGER.md` when ambiguity is resolved or escalates
- `IMPLEMENTATION_PLAN.md` when the plan actually changes
- `RESULTS.md` when new evidence exists
- `HANDOFF.md` at session end or before compaction

## Session-end checklist
Before ending:
- summarize current truth, not current mood
- separate facts from interpretations
- keep the best next step concrete
- mention any environment assumptions that must be rechecked
- record branch/worktree or commit if relevant

## Completion condition
A fresh agent should be able to read `HANDOFF.md` and know:
- what we are doing
- what is already trustworthy
- what remains uncertain
- what to do next
without rereading the whole transcript.
