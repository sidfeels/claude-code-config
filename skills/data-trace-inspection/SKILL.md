---
name: data-trace-inspection
description: Build the eyes before moving the hands. Inspect raw data, agent traces, eval outputs, and log samples before changing training recipes, prompts, reward functions, safety filters, eval harnesses, or agent loops. Applies to any empirical work — not framework- or library-specific.
disable-model-invocation: true
argument-hint: "[what is being inspected and why]"
---

# Data and Trace Inspection

Use before any empirical change whose correctness depends on data, traces, or logs. LLMs skip this because it is boring and non-textual; serious researchers do it first, because data/eval/trace pathologies cause more failures than algorithm choices do.

This skill is the concrete "build the eyes" discipline. It is deliberately domain-agnostic — the failure modes listed here apply whether the data is SFT, preference pairs, red-team prompts, agent transcripts, eval samples, activations, or trajectories.

## Trigger

Load this skill before:
- training, fine-tuning, preference-data construction, reward modeling, or any data-consuming run
- debugging an eval whose number moved unexpectedly
- red-team / adversarial analysis or safety-filter iteration
- agent-loop behavior optimization (prompts, tools, judges, reward)
- interpretability work that depends on activations or sample selection
- any "my metric is weird" investigation — look at the examples before changing code

If you are about to spend compute, inspect data/traces first. If you already spent compute and got a surprising result, inspect data/traces before explaining it.

## Core rules

1. **Look at raw examples before theory.** Not summaries, not statistics — actual rows, actual turns, actual transcripts. Open 30–50 samples and read them.
2. **Sample the extremes, not just random rows.** In addition to random samples, pull: the 10 longest, 10 shortest, 10 highest-loss, 10 highest-reward, 10 judge-failures, 10 refusals, 10 most surprising.
3. **Render with the same pipeline the training/eval/agent uses.** Inspecting raw JSONL misses tokenization, chat-template, truncation, loss-mask, and special-token bugs. Print examples **as the model sees them** — post-tokenization, with roles and masks visible — before trusting the data.
4. **Compute cheap numeric summaries alongside:** length distribution, class balance, duplicate rate, refusal rate, missing/null fields, label distribution, split overlap.
5. **For agent/judge traces, inspect full turns.** Prompt → tool calls → tool results → model output → judge rationale. Not aggregates. Failures frequently hide at specific turns, not in averages.
6. **Classify failures from transcripts, not from summaries.** If the loop has been summarizing failures in prose, that prose is already lossy — go back to the raw transcripts.
7. **Save the audit as an artifact.** A small script that dumps the tables + sample rows is repeatable; a mental note is not. Link the audit from `findings.md` or the equivalent persistent state.
8. **Do not start expensive runs until obvious pathologies are addressed.** A 6-hour training run on unfixed data is a 6-hour waste.
9. **If a metric moves, inspect the changed examples before explaining causality.** The common bug is not algorithmic — it is that the data or scorer changed silently.

## Named failure modes (check for these specifically)

These are the traps. LLMs write plausible-looking code that hides every one of them.

- **Swapped user/assistant roles.** Chat template renders assistant tokens as user or vice versa. Verify by printing a rendered example with visible role markers.
- **Loss masked incorrectly.** Training on prompt tokens, or *not* training on assistant tokens. Verify by printing the loss mask alongside the token stream.
- **Truncation at the wrong end.** Right-truncated assistant response missing the EOS, or left-truncated system prompt. Check token budgets against max length.
- **Special-token drift.** BOS/EOS/PAD/chat-template tokens missing, duplicated, or swapped between base and fine-tuned models.
- **Split leakage.** Train and eval share prompts verbatim, or near-duplicates with trivial edits. Hash-based duplicate check on both prompts and responses.
- **Hidden label / answer leakage.** The eval answer is in the prompt, the system message, or a metadata field the pipeline accidentally concatenates.
- **Preference-pair inversion.** Chosen and rejected swapped in a subset of rows. Inspect 20 pairs by hand.
- **Reward learning format, not behavior.** The reward model/judge is rewarding length, formatting, or politeness instead of the intended behavior. Compare high-reward outputs side-by-side.
- **Refusal inversion / safety-label flip.** Safe vs unsafe labels swapped on a subset; common after ad-hoc data merges.
- **Benign outlier data breaking safety.** A small fraction of outlier rows (even benign-looking) can degrade safety alignment during fine-tuning. Always inspect the tails, not just random samples.
- **Template mismatch.** Training uses one chat template, serving uses another. Compare a rendered training example against a rendered inference example end-to-end.
- **Judge drift.** The same prompts scored differently across runs because the judge model/version/prompt changed silently. Pin judge identity in the run record.
- **Stale cache.** Eval numbers come from a cached result file that no longer matches the current code or data.

## What the audit artifact should contain

Keep it factual and reproducible. A minimal audit file:

- dataset / source path / revision / count
- rendered example sampler: 5 random + 5 each of the extremes listed above
- length distribution (histogram or percentiles)
- class / label / role balance
- duplicate rate (prompt, response, prompt+response)
- split overlap (train↔eval, train↔holdout)
- refusal rate (if applicable)
- known defects list with severity and fix status
- the script that produced the audit (so a future run regenerates it)

## Done means

- a sample audit artifact exists at a known path
- numeric summaries are in that artifact
- top pathologies are quantified and either fixed or explicitly accepted
- the next hypothesis references specific inspected examples, not aggregate intuition

## Interaction with other skills

- `optimization-loop` — inspect before each significant new direction in the loop, not only at the start
- `long-running-research-loop` — the audit artifact belongs under `.agent/artifacts/`; link it from `findings.md`
- `paper-research` — inspect before reproducing any data-dependent claim; many "failed reproductions" are actually data-processing mismatches
- `implementation-quality` — the real-LLM-test rule covers behavior verification; this skill covers the data that feeds those tests

## Anti-pattern

Do **not** replace inspection with "I'll write a test for it." Tests over data pipelines are useful but they only catch the pathologies you already thought to test for. Manual inspection catches the ones you did not. Do both; do inspection first.
