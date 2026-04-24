---
name: optimization-loop
description: Run a disciplined optimization loop for performance, quality, benchmark, eval, judge-score, or search problems. Establish a baseline, build reliable measurement, iterate with one main hypothesis per cycle, detect plateaus early, and protect against reward hacking or evaluator drift.
disable-model-invocation: true
argument-hint: "[goal / metric / target]"
---

Use this skill when the task is not “implement the spec once,” but “improve a measurable outcome under constraints.”

Typical uses:
- latency / throughput / memory / CPU / GPU optimization
- benchmark score or eval improvement
- model quality work such as perplexity, accuracy, judge score, retention, or robustness
- prompt / harness / agent loop optimization
- data selection, training recipe, decoding strategy, or systems tuning
- any search problem where progress must be discovered empirically

This skill is for disciplined improvement, not vibes. The loop is:
**understand -> measure -> hypothesize -> change -> verify -> record -> repeat**

The core idea: the first job is usually to build the eyes before moving the hands.
If you cannot measure progress reliably, you cannot optimize reliably.

# 0. Read the task and classify the optimization
Interpret `$ARGUMENTS` into a concrete optimization problem.
Before changing anything, identify:
- the objective metric or metrics
- hard constraints
- what counts as a valid win
- what can be changed and what must remain fixed
- the verifier / judge / benchmark surface
- the likely attack surface for reward hacking or accidental evaluator corruption

Translate the task into a short working contract:
- **Goal**: what must improve
- **Metric**: how improvement is measured
- **Constraints**: what cannot be violated
- **Protected surfaces**: evaluator, hidden data, reference outputs, budget, safety boundaries
- **Done when**: the concrete condition for success

If any of these are missing, ask for them or derive the strongest safe approximation and label it clearly.

# 1. Start by understanding the current system
Do not jump into blind edits.
First understand:
- the current baseline behavior
- the architecture and likely bottlenecks
- the build/test/benchmark commands
- where the metric comes from
- whether the metric is deterministic, noisy, delayed, or gameable
- what prior notes, experiments, or artifacts already exist

If continuation artifacts exist, read them first:
- prior progress logs
- experiment summaries
- benchmark outputs
- traces / profiles / flamegraphs / judge results
- candidate branches or worktrees

When resuming prior work, separate:
- **verified facts**
- **hypotheses that seemed promising**
- **stale conclusions that may need re-checking**

Do not inherit defeatism from old notes. Re-verify before treating a plateau or impossibility claim as real.

# 2. Establish a trustworthy baseline
Before optimizing, produce a fresh baseline with the current code and current verifier.
Record:
- metric value(s)
- command used
- dataset / split / seed / config / prompt / environment
- runtime budget or compute budget if relevant
- important artifacts (logs, traces, outputs)

If the metric is noisy:
- run enough repetitions to estimate spread
- report median / mean / variance as appropriate
- avoid claiming a win from noise

If there are multiple objectives, define the primary metric and guardrail metrics.
Examples:
- faster without accuracy loss
- smaller without correctness loss
- higher judge score without regression on hidden retention checks
- lower perplexity without cheating the eval pipeline

# 3. Build or identify the verifier
If the verifier is weak, build a better one before large edits.
A useful verifier should make it hard to fool yourself.

Prefer the strongest practical verifier available:
- real benchmarks over intuition
- real traces over guessed bottlenecks
- real outputs over hand-wavy claims
- real integration calls over mock-only confidence
- hidden or sealed evals over editable in-workspace grading when possible

At minimum, define:
- the main score command
- the fast proxy command
- the regression checks
- the artifact location for logs/results

If relevant, create or improve diagnostics such as:
- profilers
- trace analyzers
- ablation scripts
- diff tools
- evaluation scripts
- judge breakdowns
- error-class summaries
- latency histograms
- memory counters

Your diagnostic outputs should prefer numbers and breakdowns over long prose.

# 4. Protect evaluation integrity
Assume the optimization target can be accidentally or deliberately gamed.
Treat evaluator integrity as a first-class concern.

Never casually modify:
- hidden evals
- gold answers
- sealed judges
- benchmark harnesses
- test filters that quietly narrow the task
- cached outputs presented as fresh results

If the task explicitly requires changing the evaluator or harness, separate that work from system improvement and explain the consequences.

Watch for reward-hacking patterns such as:
- train/eval leakage
- reading hidden labels or reference outputs
- changing the judge instead of the system
- optimizing formatting quirks instead of task quality
- surprising score jumps with no plausible mechanism
- speed gains caused by doing less work
- retention or correctness regressions hidden by a single headline metric

When a result looks too good, verify harder.

# 5. Form a single main hypothesis
Each iteration should test one main idea.
Not every code edit must be literally one line, but the change set should answer one main question.

Write the hypothesis explicitly:
- **Hypothesis**: if I change X, metric Y should improve because Z
- **Expected signal**: what should move, and by roughly how much
- **Risk**: what could regress or become invalid
- **Check**: what command or artifact will confirm or refute it

Good hypotheses are:
- specific
- falsifiable
- tied to evidence from the current system

Bad hypotheses are:
- vague
- bundle multiple unrelated ideas together
- impossible to interpret if they fail

# 6. Make the smallest coherent change that tests the hypothesis
Prefer minimal, interpretable deltas over sweeping rewrites.
If a larger rewrite is truly necessary, isolate it and explain why the smaller path is insufficient.

Before implementing, check:
- does the repo already have a native pattern for this?
- am I solving the bottleneck or just making the code look smarter?
- can this be isolated behind a flag or experiment path if risk is high?

For broad search spaces, you may use:
- isolated branches or worktrees for competing hypotheses
- helper scripts for repeated experiment execution
- subagents for research or alternative designs

But keep the evidence chain legible.
Do not create so many parallel threads that you stop understanding which change caused which result.

If git is active on this repo and allowed by sid to use, commit each verified improvement with a descriptive message before moving to the next iteration. If a change regresses or fails, revert cleanly. The commit history is your checkpoint mechanism — it makes rollback trivial and keeps the evidence chain auditable.

# 7. Verify immediately after each iteration
After a change:
- run the relevant fast proxy and/or full verifier
- compare with the baseline or current best
- check guardrail metrics
- inspect artifacts, not just final scalars

Classify the result clearly:
- **improved**
- **regressed**
- **unchanged**
- **invalid result**
- **inconclusive / noisy**

If improved, explain the most likely mechanism, but label it as a mechanism hypothesis unless directly established.
If unchanged or regressed, explain what the failure teaches.

# 8. Record learnings in a compact, reusable way
Do not let the session become a blur of unstructured guesses.
Maintain a concise experiment record.
A lightweight format is enough:

## Iteration N
- Goal:
- Baseline / current best:
- Hypothesis:
- Change made:
- Verifier run:
- Result:
- Guardrails:
- Interpretation:
- Next step:

Keep the notes factual and compact.
Separate:
- measured outcomes
- interpretations
- open questions

If an experiment produces artifacts, link or name them explicitly.


# 8.5 Memory hygiene: prevent future-session poisoning

Do not let the experiment record overstate what has been learned.

Separate these clearly:

- **Durable findings**: verified truths that future sessions should trust.
- **Attempt outcomes**: what happened in one implementation attempt under one set of conditions.
- **Open hypotheses**: ideas still worth testing.
- **Ruled-out lanes**: only approaches that have strong enough evidence against them.

When recording a failed or weak result, avoid writing:
- "this idea failed"
- "this approach does not work"
- "already tried this"
- "impossible"

Prefer scoped language:
- "this implementation did not improve the metric under these conditions"
- "run invalid due to verifier / environment / implementation bug"
- "no verified gain yet from this lane"
- "partial signal, but not enough to trust"
- "low priority unless retried with a different implementation"

Treat these outcomes differently:
- **invalid_run**: result cannot be trusted
- **no_effect_under_tested_conditions**: idea not supported yet, but not ruled out
- **partial_signal**: promising but insufficient
- **clean_regression**: evidence against this implementation
- **ruled_out_for_now**: repeated clean evidence makes this lane low value

Keep the active handoff short and high-signal.
Do not dump the full experiment graveyard into the next session’s core context.

If the loop is expected to span multiple context windows or agent sessions (overnight run, multi-day sweep, semi-autonomous agent loop), switch to `long-running-research-loop` for the full persistent-state schema, typed-status ledger, plateau-detection doctrine, and human-checkpoint pattern. `optimization-loop` covers the single-session empirical loop; `long-running-research-loop` covers the cross-session one.

# 8.75 Ablation discipline

When a change bundles multiple variables or when the objective is "does X matter?", switch into ablation mode before drawing causal conclusions.

Rules:
- freeze the baseline before running any variant; do not fit baseline and variant at once
- change **one interpretable variable per comparison**; use paired seed-matched runs when stochastic
- record full config lineage per run: parent commit, config diff, seed, command, data version, hardware, model version
- **estimate the noise floor** before claiming small gains (re-run the baseline 3–5× with different seeds; any gain inside that spread is noise)
- if the gain is within the noise floor, label the result `inconclusive`, not `improved`
- track guardrail metrics, not only the headline score — wins that regress secondary metrics are often reward hacks
- **do not retroactively change the hypothesis** after seeing results; that is p-hacking
- plot/report from the raw logged results file, never from hand-copied numbers
- bundled changes require a follow-up factorial ablation before any causal claim — "we changed A, B, C and the score improved" is not evidence that any single change helped
- a run is `invalid` (not a result) if the verifier, data, seed, or environment changed unexpectedly between runs

Named failure modes:
- **bundled changes**: multiple variables flipped at once, causal interpretation impossible
- **cherry-picked seed**: one lucky seed reported as the mean
- **proxy-real divergence**: proxy improves but held-out/real metric regresses
- **silent split drift**: data split changed between runs
- **stale plot**: figure generated from an old CSV that no longer matches the current run

# 9. Detect plateaus early
You are plateaued when:
- several iterations attack the same bottleneck class with little movement
- recent wins are inside noise
- you keep changing implementation details without a new mechanism
- the proxy improves but the real metric does not
- the headline score moves while quality signals get worse

When plateaued, do not just try smaller and smaller cosmetic variations.
Pivot deliberately.
Choose one of these moves:
- inspect a deeper profile or breakdown
- challenge the current bottleneck story
- reduce to a smaller reproducer
- search literature / docs / source for alternate approaches
- ask for a blind external review
- try a competing design in a worktree
- improve the verifier itself

State out loud that the current lane is saturated before pivoting.

# 10. Use external models strategically, not constantly
If you want a fresh angle:
- use blind diagnosis when you do not trust the current root-cause story
- use targeted falsification when you already have a favored hypothesis
- use checkpoint review after a significant plan or risky implementation chunk

For Codex or another coding model, provide:
- the goal
- current best metric
- constraints
- verified facts
- relevant code or artifacts
- what has already been tried
- what kind of answer you want

For a deeper external model, escalate only when the decision is architecture-level, strategy-level, or genuinely deadlocked.
Do not bounce between models after every micro-edit.

# 11. Optimize the real objective, not a proxy fantasy
Always ask:
- is this proxy still correlated with the real goal?
- am I improving user-visible quality or just the judge’s taste?
- am I speeding up the code by skipping important work?
- am I improving a public test while damaging hidden robustness?

If the task has both a fast proxy and a real score, periodically re-anchor on the real score.
Do not let the proxy become the project.

# 12. Know when to stop
Stop the loop when one of these is true:
- the success condition is met
- remaining gains are smaller than the real cost or risk
- the verifier cannot currently distinguish among the remaining options
- the next useful step is a different project, not another local tweak

Do not claim optimality unless there is strong evidence.
Use language like:
- “current best verified result”
- “best found so far under this budget”
- “current lane appears saturated”

# 13. End every run with a handoff
Before exiting, produce a concise handoff that a fresh agent or future session can trust:
- goal
- current best verified state
- important commands
- key artifacts
- verified learnings
- ruled-out approaches
- best next step
- what to re-check first if the environment changed

The handoff should help a future session resume without inheriting confusion, tunnel vision, or stale pessimism.

# Output expectations while using this skill
When this skill is active, your behavior should reflect the loop.
For non-trivial optimization work, report in a compact structure like:
- objective
- baseline
- verifier
- current hypothesis
- result
- next step

Prefer short, evidence-dense updates over long motivational narration.

# Special reminders
- Build the eyes before moving the hands.
- Treat evaluators as attack surfaces.
- One main hypothesis per iteration.
- A failed experiment is still progress if it rules out a lane.
- Fresh perspective is useful only if you do not poison it with your own tunnel vision.
- The best optimization artifact is often not the winning patch, but the measurement setup that makes winning possible.

