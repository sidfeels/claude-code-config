---
name: long-running-research-loop
description: Discipline for research, optimization, or agentic work that spans multiple context windows or agent sessions. Prevents context poisoning, typed experiment ledger, protected-verifier doctrine, plateau detection, and human-checkpoint pattern. Use when persistent state (progress notes, handoff files, ledgers) will be inherited by a future session.
disable-model-invocation: true
argument-hint: "[goal / metric / target]"
---

# Long-Running Research Loop

Use this skill whenever the next useful step is not a single patch but repeated observe → change → verify cycles spread across sessions. The dominant failure mode of long-running agents is not bad code — it is **persistent state that compounds into defeatism or tunnel vision** across context windows. A single sloppy sentence ("this is impossible") propagates into every subsequent agent and silently stops the loop. This skill is the doctrine that prevents that.

`optimization-loop` covers the single-session empirical loop (baseline → hypothesize → change → verify → record). This skill layers on top for multi-session work: state schema, banned phrases, plateau detection, checkpoint ritual, and reset criteria.

## Trigger

Load this skill when any of the following is true:
- work is expected to span more than one context window or agent session
- a ledger, progress file, handoff doc, or memory file will be written that a future agent will read as input
- an autonomous or semi-autonomous loop is about to run (overnight optimization, sweeps, agent-driven research)
- you are **resuming** work where a prior session's state is already on disk
- the goal is a moving scalar (benchmark score, latency, eval accuracy) and multiple attempts are expected

Do **not** use this skill for:
- one-shot implementations
- single-session code review
- ambiguous open-ended architecture work without a verifier (use `prompting-techniques` and ask for a concrete goal first)

## Research posture

The hard invariants below are rules. The posture below is the stance that makes the rules actually fire when it matters. A long-running loop without the posture turns into a bureaucratic checklist that produces polished-but-useless reports. **Models propose, verifiers dispose** — every item below exists because it keeps you reaching for the verifier instead of the prose.

### Scaffolding, not a contract
A phase plan is guideposts. Only **gates** (with explicit thresholds) and **abort criteria** are contracts. If an early result makes a later phase irrelevant, skip it and log why. If a mid-phase finding opens a new question, queue it. Phases get reordered, dropped, expanded, or run in parallel as evidence accumulates. The plan is a floor, not a ceiling — the most useful phrase in autonomous research is "skip it, write why, move on."

### Manual probing is a first-class tool
When a benchmark cell, an aggregate, or a confusion-matrix outlier looks weird, the next move is often *not* to run more samples. Spin up the system, hand-feed it inputs (long ones, pathological ones, edge cases in the suspicious category, format variants, language variants), and read the raw output. This is where real failure modes get named. Save **verbatim prompt + raw response pairs** as findings — not paragraph summaries. Aggregates hide the bug; raw transcripts surface it. `data-trace-inspection` covers the data side; this is the behavioral side, and it deserves its own habit.

### Uncertainty resolves to a research action, not a guess
When something is uncertain, the answer is not "best-guess and move on" or "we'll figure it out later." It is: **do the research now.** Clone the repo to `/tmp`, fetch the paper, grep the source, read the GitHub issue thread, dispatch a focused subagent. A 15-minute investigation almost always beats hours of downstream pain from a wrong assumption baked into the plan. "Uncertain → research" is the reflex; "uncertain → guess" silently builds wrong scaffolding that the next agent inherits as fact. Add the research action as a concrete todo with the exact source to consult — never as a vague "we should look into this."

### Research at execution time, not pre-decided
For "apply techniques", "explore the design space", or "find the right optimization" phases, do not arrive with a pre-decided checklist of candidates. Pre-decided lists anchor on stale priors — technique landscapes change in weeks, and the right answer at execution time is often something that did not exist when the plan was drafted. The reflex at the decision point: dispatch a focused survey (subagent, Codex, or a manual web/source pass) for current state-of-the-art relevant to your specific architecture and hardware, then test the top one or two candidates. Rank by expected gain weighted against implementation cost and the risk of silent-wrong-numbers from the new path.

### Silent-correctness detector before any new dependency
For every new tool, backend, version, kernel, quantization scheme, or library introduced into the loop, the first action is to ask: *what is the silent-wrong-numbers failure mode for this, and how would I detect it?* Then build the smallest possible detector before trusting it. Cheapest version: a handful of greedy prompts run through both the new path and a trusted reference (e.g. `transformers` eager vs vLLM, bf16 vs FP8, before-fix vs after-fix), with token-IDs compared on structured / decision-relevant outputs. Expect near-perfect agreement; investigate any meaningful divergence before benchmarking. **The worst class of optimization bug is the one that produces plausible JSON, valid metrics, and quietly-wrong conclusions.** Positive controls are the only cheap defense.

### Stress-test the plan before kickoff
Before launching a multi-hour autonomous loop, dispatch the plan to a separate agent in **falsification mode** (Plan agent in plan mode, or Codex via `/codex:adversarial-review`). Ask it to list what breaks, not what looks good — missed dependencies, wrong-magnitude time estimates, hidden gates that should be explicit, abort criteria that are not checkable, honesty risks in the framing. This 5–15 minute pass routinely catches real bugs (assumed-local files that are not, incorrect CI math, hardware-feature assumptions) that would otherwise eat hours mid-loop. Use `prompting-techniques` Mode 3 (Plan critique) — explicitly ask for blocking issues and a revised plan, not validation.

## Hard invariants

These are load-bearing. Violating any one of them will poison a future agent.

1. **No broad negative prose in active state.** Never write "impossible", "doesn't work", "already tried", "nothing helped", "dead end" into `current_state.md` or any file a future agent will read as input. These are force multipliers for agent defeatism. Log negative evidence only as scoped, typed attempt outcomes (see Ledger schema below).
2. **Protected verifier.** Identify the evaluator / scorer / benchmark before running any variant. Do not modify it during the loop. If a change to the evaluator is required, stop the loop, make the change in a separate commit, re-baseline, and restart.
3. **Immutable baseline.** Commit the baseline and its exact rerun command before any optimization. Do not fit baseline and variant in the same session.
4. **Keep/revert ratchet.** Every verified improvement is committed. Every regression or invalid run is reverted or isolated on a branch. The current best is always the tip of a specific commit with a rerun command.
5. **Archive, don't delete.** Raw logs, old experiments, and stale reasoning are never deleted. They move to an `archive/` subdirectory that is **not** loaded into the active context of the next session.
6. **Separate the current best from the attempt log.** `current_state.md` holds only verified current best + next step + protected surfaces. Failures live in `attempts.jsonl`. Never mix.
7. **One interpretable hypothesis per iteration.** Bundled changes make results uninterpretable; a failed bundled change tempts a broad negative conclusion (see invariant 1).
8. **Reset, don't silence.** If two consecutive agents hit the same plateau or repeat the same failure, reset the active context by rewriting `current_state.md` from durable facts, do not add another caveat paragraph to the existing narrative.

## Recommended state layout

This layout works for any project. Adjust path names to fit the repo; the structure is what matters.

```txt
.agent/                              # gitignored by default, or gitignored selectively
  RUNBOOK.md                         # human-authored: goal, metric, constraints, protected files, iteration budget
  current_state.md                   # short: current best, rerun command, top 3 open hypotheses, next action
  findings.md                        # only verified durable conclusions — things a future agent should trust
  attempts.jsonl                     # raw attempt ledger (schema below)
  experiments.jsonl                  # structured run records when the loop is metric-scored (optional; merge with attempts if redundant)
  artifacts/                         # logs, traces, plots, transcripts, eval outputs
  archive/                           # superseded state, poisoned summaries, old plans — kept, not loaded
```

For paper-derived work, `paper-research` already uses `.paper_research_work/<slug>/`. Nest this state inside it: `.paper_research_work/<slug>/state/`.

Which files a new agent session should load:
- **Always:** `RUNBOOK.md`, `current_state.md`, `findings.md`
- **On demand:** `attempts.jsonl` (for specific past attempts), `artifacts/` (for specific traces)
- **Never by default:** `archive/`

## `current_state.md` shape

Keep it short. If it grows beyond a page, it is already poisoned — rewrite from evidence.

```md
# Current state — <goal slug>

## Goal
<one sentence>

## Verifier
<exact command to run the score / eval>

## Protected surfaces
<files/paths the loop must not modify — evals, gold data, hidden labels, judges, safety canaries>

## Current best
- commit: <hash>
- metric: <value> (vs baseline <value>)
- rerun: <exact command>
- artifact: <path>

## Open hypotheses (top 3)
1. <hypothesis> — next discriminating check: <what to run>
2. ...
3. ...

## Next action
<one concrete step>
```

Nothing else belongs here. Not narrative, not mood, not retrospective.

## Attempt ledger — `attempts.jsonl`

One line per attempt. JSONL so future agents can filter/grep cleanly. **Typed statuses** are mandatory — they are the discipline that prevents "this failed" from becoming active-context poison.

```json
{
  "attempt_id": "2026-04-25-cache-v2",
  "timestamp": "2026-04-25T14:32:00Z",
  "parent_commit": "abc1234",
  "hypothesis": "memoizing parsed prompts reduces eval runtime",
  "change_summary": "added LRU cache around parse_prompt in src/eval.py",
  "command": "python eval.py --subset smoke --seed 1",
  "seed": 1,
  "config_path": "configs/eval_smoke.yaml",
  "primary_metric": {"name": "runtime_sec", "baseline": 42.8, "result": 43.1},
  "guardrail_metrics": {"accuracy": 0.812, "accuracy_baseline": 0.811},
  "status": "no_effect_under_tested_conditions",
  "scope": "smoke subset only; cache hit rate was 6%",
  "artifact_path": ".agent/artifacts/2026-04-25-cache-v2/",
  "retry_if": "full eval has higher repeated-prompt rate or parser profile exceeds 10%",
  "next_check": "profile parser on full eval before another cache attempt"
}
```

### Allowed statuses

Use exactly these. Do not invent new ones; the closed set is the discipline.

- `improved` — metric beat baseline by more than the noise floor, guardrails intact
- `clean_regression` — metric regressed by more than noise; revert
- `no_effect_under_tested_conditions` — within noise; do NOT write this off as "failed"
- `partial_signal` — moved some metric but not primary; interesting but insufficient
- `invalid_run` — environment, seed, data, or verifier drifted; result cannot be trusted
- `crash` — run did not complete; record command + stack, do not interpret as failure of the idea
- `inconclusive` — noise too high or verifier too weak to distinguish
- `ruled_out_for_now` — repeated clean evidence against; still not "impossible", still scoped to tested conditions

### The negative-evidence policy

Yes, log negative evidence. No, do not write broad negatives.

**Bad** (poisons future agents):
```md
Tried caching. It failed. Probably impossible to improve this path further.
```

**Good** (preserves evidence without poison):
```json
{
  "attempt_id": "2026-04-25-cache-v2",
  "status": "no_effect_under_tested_conditions",
  "scope": "smoke subset only; cache hit rate was 6%",
  "retry_if": "full eval has higher repeated-prompt rate"
}
```

The difference is everything. The Good version lets a future agent decide when the idea is worth retrying. The Bad version makes them give up.

## Plateau detection

Declare a plateau when **any** of the following holds:

- 3–5 clean attempts in the same lane produce no gain beyond the noise floor
- the same failure class recurs twice despite targeted fixes
- the proxy metric improves but the real metric does not
- the agent has stopped inspecting raw artifacts/traces and is only editing prose or code
- recent gains are inside the noise floor
- `current_state.md` contains defeatist or stale conclusions
- the active context grows without the metric moving

### Plateau response (in order)

1. **Inspect raw artifacts**, not summaries. Look at the traces, logs, profiles, sample outputs the loop has been producing. The answer is usually there and the agent has been reading summaries instead.
2. **Change the diagnostic tool, not the code.** Add a profiler, trace parser, jq query, plot, grep. This is almost always the human's highest-leverage contribution at a plateau. Your job as course-corrector is to **change the search affordance, not to suggest the fix**.
3. **Ask for a blind external diagnosis** (Template A in `prompting-techniques`). Hide the current lane from the reviewer.
4. **Start a competing branch** with a materially different frame. Do not let the old branch's context leak in.
5. **Archive and rewrite**. Move the current `current_state.md` and the prose portions of `findings.md` to `archive/<date>/`. Rewrite `current_state.md` from `attempts.jsonl` entries with status `improved` only, plus the protected verifier, plus 1–3 next concrete checks. Start the next session from this clean slate.

## Reset criteria

Reset the active context when:
- two consecutive agents repeat the same failed pattern
- `current_state.md` or the findings file is longer than the task itself
- the agent is optimizing prose (rewording notes) instead of measurements
- broad negative phrases have slipped into active state
- the next useful move requires a different representation or tool, not another code edit

Resetting is not losing work. The raw ledger and artifacts survive in `archive/`. Only the narrative is reset.

## Human-checkpoint pattern

When a human course-corrects a long-running loop, the job is rarely "spot the bug in the code." The job is almost always **change the search affordance** — add a tool, a trace, a plot, a reducer, a smaller reproducer — so the loop can find the fix itself.

At each checkpoint, inspect in order:
1. Latest diff.
2. Latest verifier output — did the score actually move, beyond noise, under the real verifier?
3. `current_state.md` — is it short, factual, and free of banned phrases?
4. `attempts.jsonl` tail — are statuses typed correctly, or have broad negatives crept in as prose?
5. Has the agent **inspected raw artifacts** in the last N attempts, or only read summaries?
6. Did the agent change the evaluator, gold data, data split, judge prompt, or prompt template? (Evaluator tampering is the #1 silent reward hack.)
7. Is the agent repeating a lane, or has the search space actually changed?

If the same agent behavior keeps recurring, the fix is usually in `RUNBOOK.md` or a skill, not in the code. Edit the prompt before editing the repo.

## Interaction with other skills and tools

- `optimization-loop` — same inner iteration loop. This skill adds the cross-session persistence and anti-poison discipline.
- `paper-research` — nest `.agent/` state under `.paper_research_work/<slug>/state/` for paper-derived loops.
- `data-trace-inspection` — run before every non-trivial change of direction inside a long loop. Agents skip this; humans enforce it at checkpoints.
- `prompting-techniques` — for blind diagnoses at plateaus, use Template A or mode 7 (hint-don't-roadmap) to avoid leaking the current lane to the reviewer.
- **Hooks** — `HOOKS.md` documents the banned-phrase warning, protected-eval hook, and secret-scan hook that make the invariants deterministic rather than advisory. Prose in this skill catches the common cases; hooks catch the rest.

## Handoff at session end

Before ending a session that a future agent will resume from, produce (or update):
- `current_state.md` — current best, verifier, protected surfaces, top 3 open hypotheses, next action. Nothing else.
- `findings.md` — only durable conclusions added this session, each with evidence link.
- `attempts.jsonl` — all runs from this session, typed.
- `caveats.md` — conditions under which the current conclusions could be wrong. Every quantitative claim maps to a caveat that names what would falsify it. Required entries when relevant: sample-size CI width, cross-session environment deltas, simulated-vs-measured hardware behavior, single-class confusion-matrix artifacts, untested long-context behavior. **The polished-but-dishonest report is a real failure mode; the caveats artifact is the cheapest defense.** A report without a caveats section is incomplete — refuse to ship it that way.
- `archive/<date>/` — anything superseded.

Read `current_state.md` back to yourself before finishing. If it contains any of: `impossible`, `doesn't work`, `already tried`, `nothing helped`, `dead end` — rewrite or delete the sentence. The next agent will take it literally.

### Cross-session environment-delta hygiene

When citing reference numbers from earlier sessions, baseline runs, or external sources, **always name the environment delta**: which library / driver / dataset / model / dependency versions changed since the reference was generated, and which numbers are therefore not directly cross-comparable. Cross-session throughput numbers (tokens/sec, latency, memory) are the canonical place researchers lie to themselves — a minor framework version bump or a driver update can swing tok/sec by a large factor. Quality numbers are slightly more robust but not immune (different prompt version, different eval-script revision, different dataset shuffle).

Concrete rule: if a number predates this session, it gets an annotation like `(prior session, env: <key versions>)` in any table that mixes it with fresh measurements. Numbers without that annotation are assumed fresh. Mixing without labeling is a downstream lie.

## Final reminders

- The ledger is the system. A clean ledger outperforms a clever agent.
- Archive, never delete. Poisoned summaries are evidence; they just do not belong in active context.
- Your highest-leverage move at a plateau is usually to change the search affordance, not the code.
- Models propose; verifiers dispose.
