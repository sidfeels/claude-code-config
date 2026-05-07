---
name: long-running-research-loop
description: Discipline for any iterative empirical work — single-session optimization, multi-session research, evals, benchmarks, ablations, training recipes, prompt/agent tuning, judge-score work, or any "improve a measurable outcome under constraints" task. Covers single-session optimization (lean mode) and multi-session research (full mode with persistent state). Use whenever the work is "move a number under constraints" rather than "build a feature."
disable-model-invocation: true
argument-hint: "[goal / metric / target]"
---

# Long-Running Research Loop

Use this skill whenever the task is not "implement the spec once," but **improve a measurable outcome under constraints** — performance, quality, benchmark, eval, judge score, prompt tuning, training recipe, or any search problem where progress must be discovered empirically.

The loop is **understand → measure → hypothesize → change → verify → record → repeat**. The first job is usually to build the eyes before moving the hands: if you cannot measure progress reliably, you cannot optimize reliably.

This skill covers two modes:
- **Lean mode** — single-session optimization. Skip the full state machinery; keep a compact iteration record in chat or a single notes file. Still establish baseline, build the verifier, run one hypothesis at a time, apply ablation discipline, respect protected verifier and evaluation integrity.
- **Full mode** — work that spans multiple context windows or sessions. Use the typed-ledger state model below to prevent context poisoning.

The dominant failure mode of multi-session iterative work is not bad code — it is **persistent state that compounds into defeatism or tunnel vision** across context windows. A single sloppy sentence ("this is impossible") propagates into every subsequent agent and silently stops the loop. This skill is the doctrine that prevents that.

## Trigger

Load this skill when any of the following is true:
- the task is "improve metric X under constraints" (latency, throughput, accuracy, judge score, perplexity, refusal rate, retention, robustness)
- benchmark, eval, ablation, or training-recipe iteration
- prompt / harness / agent loop optimization
- data selection, decoding strategy, or systems tuning
- the goal is a moving scalar with multiple attempts expected
- a ledger, progress file, handoff doc, or memory file will be written that a future agent will read as input
- you are **resuming** work where a prior session's state is already on disk
- an autonomous or semi-autonomous loop is about to run

If the goal, metric, verifier, constraints, or autonomy boundaries are unclear enough to change the loop, load `requirements-interview` first.

Do **not** use this skill for:
- one-shot implementations
- single-session code review
- whole-project product delivery or multi-milestone implementation work where the main problem is project orchestration rather than empirical measurement; use `long-running-project-orchestrator`
- ambiguous open-ended architecture work without a verifier (use `prompting-techniques` and ask for a concrete goal first)

## Research posture

The hard invariants below are rules. The posture below is the stance that makes the rules actually fire when it matters. **Models propose, verifiers dispose** — every item below exists because it keeps you reaching for the verifier instead of the prose.

- **Scaffolding, not a contract.** A phase plan is guideposts. Only **gates** (with explicit thresholds) and **abort criteria** are contracts. If an early result makes a later phase irrelevant, skip it and log why. The plan is a floor, not a ceiling — the most useful phrase is "skip it, write why, move on."
- **Manual probing is a first-class tool.** When an aggregate or an outlier looks weird, the next move is often *not* to run more samples. Hand-feed the system pathological inputs and read the raw output. Save **verbatim prompt + raw response pairs** as findings, not paragraph summaries. Aggregates hide bugs; raw transcripts surface them.
- **Uncertainty resolves to a research action, not a guess.** Clone the repo to `/tmp`, fetch the paper, grep the source, dispatch a focused subagent. A 15-minute investigation almost always beats hours of downstream pain. "Uncertain → research" is the reflex; "uncertain → guess" silently builds wrong scaffolding the next agent inherits as fact.
- **Search space discovered at decision time, not pre-decided.** Optimization landscapes change in weeks — pre-decided checklists anchor on stale priors. At each "what to try next" decision, dispatch a focused survey for current state-of-the-art relevant to your specific architecture and hardware. Test the top one or two. Rank by expected gain weighted against implementation cost and silent-correctness risk.
- **Silent-correctness detector before any new dependency.** For every new tool, backend, version, kernel, quantization scheme, or library: ask *what is the silent-wrong-numbers failure mode for this, and how would I detect it?* Build the smallest detector before trusting it. Cheapest version: a handful of greedy prompts run through both the new path and a trusted reference (`transformers` eager vs vLLM, bf16 vs FP8, before-fix vs after-fix), with token-IDs compared on structured outputs. **The worst class of optimization bug is the one that produces plausible JSON, valid metrics, and quietly-wrong conclusions.** A fast number from an unvalidated path is not a result.
- **Stress-test the plan before kickoff.** Before launching a multi-hour autonomous loop, dispatch the plan to a separate agent in falsification mode (Plan agent in plan mode, or `/codex:adversarial-review`). Ask for blocking issues, not validation. Use `prompting-techniques` Mode 3 (Plan critique).

## Hard invariants

These are load-bearing. Violating any one will poison the loop or invalidate results.

1. **No broad negative prose in active state.** Never write "impossible", "doesn't work", "already tried", "nothing helped", "dead end" into `current_state.md` or any file a future agent will read. Log negative evidence only as scoped, typed attempt outcomes (see Ledger schema below).
2. **Protected verifier.** Identify the evaluator / scorer / benchmark before running any variant. Do not modify it during the loop. If a change is required, stop, make the change as a separate approved checkpoint, re-baseline, restart.
3. **Immutable baseline.** Freeze the baseline and its exact rerun command before any optimization. If git checkpoints are in scope, use a commit or branch tag; otherwise record the exact code/config state clearly enough to rerun. Do not revise the baseline after seeing variant results.
4. **Keep/revert ratchet.** Every verified improvement becomes the new recorded checkpoint. Every regression or invalid run is reverted, discarded, or isolated on a branch. The current best is always tied to a specific checkpoint with a rerun command.
5. **Archive, don't delete.** Raw logs, old experiments, and stale reasoning are never deleted. They move to an `archive/` subdirectory not loaded into the next session's active context.
6. **Separate the current best from the attempt log.** `current_state.md` holds only verified current best + next step + protected surfaces. Failures live in `attempts.jsonl`. Never mix.
7. **One interpretable hypothesis per iteration.** Bundled changes make results uninterpretable; a failed bundled change tempts a broad negative conclusion.
8. **Reset, don't silence.** If two consecutive agents hit the same plateau or repeat the same failure, reset the active context by rewriting `current_state.md` from durable facts; do not add another caveat paragraph.
9. **Treat evaluators as attack surface.** Watch for reward-hacking patterns: train/eval leakage, reading hidden labels, optimizing formatting quirks, surprising score jumps with no plausible mechanism, speed gains caused by doing less work, headline-metric improvements that hide guardrail regressions. When a result looks too good, verify harder.

## The inner loop (per iteration)

For every iteration, regardless of mode:

1. **Understand**: read prior state, current best, recent attempts. Re-verify what is actually known vs assumed. Do not inherit defeatism from old notes.
2. **Hypothesize**: one falsifiable hypothesis. *"If I change X, metric Y should improve because Z."* Specific, tied to evidence. Note: expected signal magnitude, what could regress, what command will confirm or refute.
3. **Change**: smallest coherent change that tests the hypothesis. Match the repo. Avoid bundling. If a larger rewrite is necessary, isolate it and explain why the smaller path is insufficient.
4. **Verify**: run the fast proxy and/or full verifier. Compare with baseline / current best. Check guardrails. Inspect artifacts, not just final scalars.
5. **Record**: typed status entry in `attempts.jsonl` (full mode) or compact note (lean mode). Never write "this didn't work" — use a typed status with scope and `retry_if`.

Bad hypotheses are vague, bundled, or impossible to interpret if they fail. Good hypotheses are specific, falsifiable, and tied to current-system evidence.

## Baseline and verifier

Before any optimization, produce a fresh baseline with the current code and current verifier.

Record:
- metric value(s); if noisy, run enough repetitions to estimate spread (median / mean / variance)
- exact command used
- dataset / split / seed / config / prompt / environment
- runtime or compute budget
- key artifacts (logs, traces, outputs)

If the metric is noisy, **estimate the noise floor before claiming small gains.** Re-run the baseline 3–5× with different seeds; any gain inside that spread is noise.

If there are multiple objectives, define one **primary metric** and **guardrail metrics**:
- faster without accuracy loss
- smaller without correctness loss
- higher judge score without regression on hidden retention checks
- lower perplexity without cheating the eval pipeline

If the verifier is weak, build a better one before large edits. Prefer the strongest practical verifier:
- real benchmarks over intuition
- real traces over guessed bottlenecks
- real outputs over hand-wavy claims
- real integration calls over mock-only confidence
- hidden or sealed evals over editable in-workspace grading when possible

At minimum, define: the main score command, the fast proxy command, the regression checks, the artifact location.

## Ablation discipline

When a change bundles multiple variables or when the objective is "does X matter?", switch into ablation mode before drawing causal conclusions.

Rules:
- freeze the baseline before running any variant; do not revise it after seeing variant results
- change **one interpretable variable per comparison**; use paired seed-matched runs when stochastic
- record full config lineage per run: parent checkpoint, config diff, seed, command, data version, hardware, model version
- if the gain is within the noise floor, label the result `inconclusive`, not `improved`
- track guardrail metrics, not only the headline score — wins that regress secondary metrics are often reward hacks
- **do not retroactively change the hypothesis** after seeing results; that is p-hacking
- plot/report from the raw logged results file, never from hand-copied numbers
- bundled changes require a follow-up factorial ablation before any causal claim
- a run is `invalid` (not a result) if the verifier, data, seed, or environment changed unexpectedly between runs

Named failure modes:
- **bundled changes**: multiple variables flipped at once, causal interpretation impossible
- **cherry-picked seed**: one lucky seed reported as the mean
- **proxy-real divergence**: proxy improves but held-out/real metric regresses
- **silent split drift**: data split changed between runs
- **stale plot**: figure generated from an old CSV that no longer matches the current run

## Real objective vs proxy

If the task has both a fast proxy and a real score, periodically re-anchor on the real score. Always ask:
- is this proxy still correlated with the real goal?
- am I improving user-visible quality or just the judge's taste?
- am I speeding up code by skipping important work?
- am I improving a public test while damaging hidden robustness?

Do not let the proxy become the project.

## Recommended state layout (full mode)

For multi-session work. Adjust path names to fit the repo; the structure is what matters.

```txt
.agent/                              # gitignored by default
  RUNBOOK.md                         # human-authored: goal, metric, constraints, protected files, iteration budget
  current_state.md                   # short: current best, rerun command, top 3 open hypotheses, next action
  findings.md                        # only verified durable conclusions / decisions
  attempts.jsonl                     # raw attempt ledger (schema below)
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
- checkpoint: <commit, branch/tag, artifact path, or recorded state>
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

## `findings.md` — durable decisions

Use the structured decision-log format for any non-trivial decision:

```md
### Decision: <topic>
- options considered: A / B / C
- chose: B
- rationale: <tied to verified evidence>
- trade-offs accepted: <what you gave up>
- evidence: <link to attempts.jsonl entries / artifacts>
- revisit_if: <conditions that would change the choice>
```

Decisions outrank unstructured prose findings. If a future agent needs to re-litigate, the structure tells them what was already weighed.

## Attempt ledger — `attempts.jsonl`

One line per attempt. JSONL so future agents can filter/grep cleanly. **Typed statuses** are mandatory — the discipline that prevents "this failed" from becoming active-context poison.

```json
{
  "attempt_id": "2026-04-25-cache-v2",
  "timestamp": "2026-04-25T14:32:00Z",
  "parent_checkpoint": "abc1234",
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
- `deferred` — paused; must include `retry_if` or `revisit_if`

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

The Good version lets a future agent decide when the idea is worth retrying. The Bad version makes them give up.

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

1. **Inspect raw artifacts**, not summaries. The answer is usually there and the agent has been reading summaries instead.
2. **Change the diagnostic tool, not the code.** Add a profiler, trace parser, jq query, plot, grep. This is almost always the human's highest-leverage contribution at a plateau. **Change the search affordance, not the fix.**
3. **Ask for a blind external diagnosis** (Template A in `prompting-techniques`). Hide the current lane from the reviewer.
4. **Start a competing branch** with a materially different frame. Do not let the old branch's context leak in.
5. **Bounded sub-task deferral**: if stuck on a sub-task (not the whole loop), use "3 attempts, log deferred, proceed" before reaching for a full reset. Add an `attempts.jsonl` entry with status `deferred` and a `retry_if` or `revisit_if` clause.
6. **Archive and rewrite**. Move the current `current_state.md` and the prose portions of `findings.md` to `archive/<date>/`. Rewrite `current_state.md` from `attempts.jsonl` entries with status `improved` only, plus the protected verifier, plus 1–3 next concrete checks. Start the next session from this clean slate.

## When to stop

Stop the loop when one of these is true:
- the success condition is met
- remaining gains are smaller than the real cost or risk
- the verifier cannot currently distinguish among the remaining options
- the next useful step is a different project, not another local tweak

Do not claim optimality unless there is strong evidence. Use language like:
- "current best verified result"
- "best found so far under this budget"
- "current lane appears saturated"

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

## Subagent dispatch in long loops

When delegating, point the subagent at state files directly rather than recomposing prompts each time:
- read `RUNBOOK.md`, `current_state.md`, relevant `findings.md` entries
- never re-narrate the goal in chat — let the file be the source of truth

Defense-against-self-deception: at milestone boundaries, dispatch a separate verifier subagent that runs the real verifier on the orchestrator's claimed current best. The orchestrator can talk itself into a number; an independent re-run can't.

For multi-agent build orchestration (parallel implementers in worktrees, review/fix cycles), see `long-running-project-orchestrator`.

## Interaction with other skills

- `requirements-interview` — load first if goal/metric/constraints are unclear.
- `long-running-project-orchestrator` — use that for end-to-end project delivery. Route specific empirical, benchmark, eval, or training slices back into this skill when project work becomes a measurable iteration loop.
- `paper-research` — nest `.agent/` state under `.paper_research_work/<slug>/state/` for paper-derived loops.
- `data-trace-inspection` — run before every non-trivial change of direction. Agents skip this; humans enforce it at checkpoints.
- `prompting-techniques` — for blind diagnoses at plateaus, use Template A or Mode 7 (hint-don't-roadmap). For Codex invocation syntax, see prompting-techniques' Codex section.
- **Hooks** — `HOOKS.md` documents the banned-phrase warning, protected-eval hook, and secret-scan hook that make the invariants deterministic rather than advisory.

## Handoff at session end (full mode)

Before ending a session a future agent will resume from, produce or update:
- `current_state.md` — current best, verifier, protected surfaces, top 3 open hypotheses, next action. Nothing else.
- `findings.md` — durable decisions added this session, each with the decision-log format and evidence link.
- `attempts.jsonl` — all runs from this session, typed.
- `caveats.md` — conditions under which the current conclusions could be wrong. Every quantitative claim maps to a caveat that names what would falsify it. Required entries when relevant: sample-size CI width, cross-session environment deltas, simulated-vs-measured hardware behavior, single-class confusion-matrix artifacts, untested long-context behavior. **A report without a caveats section is incomplete — refuse to ship it that way.**
- `archive/<date>/` — anything superseded.

Read `current_state.md` back to yourself before finishing. If it contains any of: `impossible`, `doesn't work`, `already tried`, `nothing helped`, `dead end` — rewrite or delete the sentence. The next agent will take it literally.

### Cross-session environment-delta hygiene

When citing reference numbers from earlier sessions, baseline runs, or external sources, **always name the environment delta**: which library / driver / dataset / model / dependency versions changed since the reference was generated, and which numbers are therefore not directly cross-comparable. Cross-session throughput numbers (tokens/sec, latency, memory) are the canonical place researchers lie to themselves — a minor framework version bump or a driver update can swing tok/sec by a large factor. Quality numbers are slightly more robust but not immune.

Concrete rule: if a number predates this session, it gets an annotation like `(prior session, env: <key versions>)` in any table that mixes it with fresh measurements. Numbers without that annotation are assumed fresh. Mixing without labeling is a downstream lie.

## Output expectations

When this skill is active, prefer compact evidence-dense updates:
- objective
- baseline
- verifier
- current hypothesis
- result
- next step

Prefer numbers and breakdowns over long prose.

## Closing principles

- **Models propose, verifiers dispose.** A fast number from an unvalidated path is not a result.
- Build the eyes before moving the hands.
- Treat evaluators as attack surfaces.
- One main hypothesis per iteration.
- Archive, never delete. Poisoned summaries are evidence; they just don't belong in active context.
- Your highest-leverage move at a plateau is usually to change the search affordance, not the code.
- The best optimization artifact is often not the winning patch, but the measurement setup that makes winning possible.
