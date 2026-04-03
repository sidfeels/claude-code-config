---
name: paper-research
description: Understand, reproduce, audit, extend, or port a research paper or research-derived codebase with explicit uncertainty, strong provenance, and claim-targeted verification. Use for arXiv links, paper PDFs/text, official-code audits, research-code contributions, and extension research.
disable-model-invocation: true
argument-hint: "[paper link | arxiv id | repo link | request]"
---

# Paper Research

This skill is for research work that begins from a paper, a paper plus code, or an existing research codebase derived from a paper.

It is **not** a naive "paper in, code out" generator.
It is a staged workflow for:
- understanding the paper honestly
- choosing the right mode
- acquiring the right artifacts
- auditing ambiguity and reproducibility
- building a faithful baseline or audit
- optionally extending the method with disciplined verification

## The six modes
Every request must resolve to one primary mode:

1. **explain** — understand and teach the paper clearly; no code unless needed for explanation
2. **scaffold** — build a faithful minimal implementation scaffold with explicit uncertainty
3. **reproduce** — target a specific claim, table, figure, metric, or algorithmic result
4. **audit** — compare paper, official code, and current repo behavior
5. **extend** — start from a frozen baseline and propose / test new research directions
6. **port** — preserve the method while moving to another stack, framework, or codebase

Do not let the workflow stay vague as "implement the paper." Resolve the mode first.

## Source-of-truth hierarchy
Use sources in this order unless there is a compelling reason not to:
1. numbered equations and algorithm boxes
2. method text in the main paper
3. appendix / supplementary / footnotes / figure and table captions
4. later arXiv versions / errata
5. official code
6. strong independent reimplementations or benchmark repos
7. field-standard defaults
8. model prior or memory

Official code can resolve ambiguity, but it does not retroactively turn an unspecified paper detail into a paper-specified fact.

## Core artifacts
Keep research state in `.paper_research_work/<paper_slug>/`.
Main working artifacts:
- `PAPER_BRIEF.md`
- `REQUEST_MODE.md`
- `CLAIMS_AND_TARGETS.md`
- `ARTIFACT_REGISTRY.md`
- `SOURCE_GRAPH.md`
- `AMBIGUITY_LEDGER.md`
- `REPRODUCTION_FEASIBILITY.md`
- `IMPLEMENTATION_PLAN.md`
- `VERIFIER_PLAN.md`
- `RESULTS.md`
- `HANDOFF.md`

Use scaffolds when useful, but keep them factual and compact.

## Dynamic routing
Do not always start from the beginning.

When invoked:
1. inspect `.paper_research_work/<paper_slug>/` if it exists
2. determine which stage artifacts already exist and are still trustworthy
3. resume from the earliest missing or invalid stage
4. only restart earlier stages if inputs changed materially

A changed paper version, changed official code, changed framework target, or changed claim target can invalidate later stages.

## Pipeline stages
Fresh work usually flows like this:
1. `pipeline/01_intake_and_claim_gate.md`
2. `pipeline/02_artifact_acquisition_and_source_graph.md`
3. `pipeline/03_ambiguity_and_reproducibility_audit.md`
4. `pipeline/04_implementation_or_baseline_plan.md`
5. `pipeline/05_code_generation.md`
6. `pipeline/06_verification.md`
7. `pipeline/07_extension.md` (only when mode is extend)
8. `pipeline/08_handoff.md`

But route dynamically based on current state.

## When to read guardrails
Read the guardrails when they become relevant:

- Before ambiguity work: `guardrails/uncertainty_and_honesty.md`
- Before scope decisions or declaring a paper blocked: `guardrails/scope_and_ambiguity.md`
- Before using or trusting official code: `guardrails/official_code_usage.md`
- Before downloads, GPU work, long runs, env setup, or shared-machine actions: `guardrails/environment_and_compute.md`

## When to read knowledge files
Read knowledge only when the domain demands it. These files are references, not always-on context.

- `knowledge/paper_to_code_mistakes.md` — generic translation traps and framework mismatches
- `knowledge/training_and_optimization.md` — training recipes, optimizer and schedule semantics, batch size, mixed precision, EMA, and optimization pitfalls
- `knowledge/agentic_and_posttraining.md` — RLHF, DPO/GRPO, judge/reward, prompt-template, and eval leakage pitfalls
- `knowledge/systems_and_inference.md` — inference, kernels, latency, benchmarking, hardware, and systems-paper pitfalls

## Subagents vs Codex vs GPT-5.4 Pro

### Use subagents for
- paper reading and section extraction
- appendix mining
- reference chasing
- official-code structure scanning
- parallel extension brainstorming

### Use Codex for
- checkpoint plan critique after the audit and implementation plan
- official-code analysis when the repo is large or subtle
- math-to-code or code-to-math cross-checking
- adversarial review before merge or after a risky chunk
- rescue on a hard local subproblem

Do not ask Codex to review every tiny component in isolation. Prefer one integrated checkpoint after a coherent plan, one after a meaningful scaffold or risky chunk, and one before merge or handoff if the work is substantial.

### Use GPT-5.4 Pro only when
- the ambiguity is strategic or architecture-level
- extension direction is genuinely hard and high stakes
- Claude plus Codex plateau on the same question

If escalating, use the `prompting-techniques` skill to prepare a clean handoff packet.

## Relationship to other skills
- Use `implementation-quality-deep` before non-trivial code generation or refactors.
- Use `prompting-techniques` for all subagent/Codex/GPT-5.4 Pro handoffs.
- Use `optimization-loop` when extension or reproduction turns into an empirical optimization problem.
- Use `pr-finishing` when turning the final result into a reviewable PR.

## Hard rules
- Do not silently invent missing details.
- Do not overstate what the paper proves or specifies.
- Do not claim reproduction when you only have a scaffold.
- Do not let one failed implementation become "this idea does not work."
- Do not start heavy GPU, dataset, or long-running jobs without checking the environment and asking Sid when required.
- Do not allow official code to erase paper-vs-code differences; record them.
