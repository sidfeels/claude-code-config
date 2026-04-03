# Stage 3 — Ambiguity and Reproducibility Audit

## Purpose
This is the anti-hallucination core of the workflow.
Before implementation, audit every claim-critical detail and classify both its provenance and its impact on reproduction.

## Inputs
- `PAPER_BRIEF.md`
- `REQUEST_MODE.md`
- `CLAIMS_AND_TARGETS.md`
- `ARTIFACT_REGISTRY.md`
- `SOURCE_GRAPH.md`

## Outputs
Write these to `.paper_research_work/<paper_slug>/`:
- `AMBIGUITY_LEDGER.md`
- `REPRODUCTION_FEASIBILITY.md`

Before starting, read:
- `guardrails/uncertainty_and_honesty.md`
- `guardrails/scope_and_ambiguity.md`

Read domain knowledge files only when relevant.

## The two axes: status and severity

### Status
For each implementation-relevant item, assign one:
- **SPECIFIED** — directly stated in the paper artifact graph
- **PARTIALLY_SPECIFIED** — mentioned but ambiguous
- **UNSPECIFIED** — missing from paper sources
- **FROM_OFFICIAL_CODE** — resolved by official code, not by the paper
- **CONTRADICTED** — sources disagree in a way that matters

### Severity
Also assign:
- **low** — unlikely to affect the target claim materially
- **medium** — may affect fidelity or quality
- **high** — likely to affect the target claim
- **blocking** — cannot honestly claim target reproduction without resolving or scoping around it

A missing LayerNorm epsilon is often low.
A missing batch-size interpretation, metric implementation, prompt template, reward model spec, or evaluation split may be high or blocking.

## Step 1: Audit only what matters to the target
Do not try to audit the entire paper universe.
Audit the details that affect the selected mode and target claim.

Examples:
- reproducing a training result → optimizer, LR schedule, batch semantics, seed handling, dataset split, eval protocol
- implementing a novel module → architecture details, tensor shapes, normalization placement, initialization if stability depends on it
- auditing official code → exact divergences between paper and repo
- extension research → enough to freeze a faithful baseline first

## Step 2: Build the ambiguity ledger
For each claim-critical item, record:
- item
- status
- severity
- source location
- exact quote or evidence if available
- current best default or interpretation
- alternatives
- whether this must be resolved before implementation

Do not let "standard practice" or "the model knows this" substitute for a proper ledger entry.

## Step 3: Reconcile contradictions
When sources disagree:
- equation vs prose
- figure vs text
- appendix vs main section
- paper vs official code
- official code vs benchmark repo

record the contradiction explicitly and state the default decision path.

Do not hide contradictions inside a casual comment.
A contradiction is often more important than a missing value.

## Step 4: Use official code carefully
Only after the paper-side ambiguity is visible should you use official code to close some gaps.
When you do:
- read `guardrails/official_code_usage.md`
- mark resolved items as `FROM_OFFICIAL_CODE`
- note exact file / config / function / commit if possible
- record paper-vs-code divergence instead of silently overwriting the paper

## Step 5: Judge reproducibility feasibility
Write `REPRODUCTION_FEASIBILITY.md` with one of these outcomes:

- **faithful reproduction appears feasible**
- **faithful scaffold feasible, exact reproduction uncertain**
- **partial reproduction only**
- **audit-only or explain-only is honest**
- **blocking gaps remain**

The output must say *why*.
Do not let “this seems hard” become a fake blocker.
Likewise, do not call something reproducible when key elements are still blocking.

## Step 6: External checkpoint review
After the integrated audit exists, one Codex checkpoint review is useful.
Ask for:
- hidden blockers
- over-scoping
- missing provenance
- paper-vs-code mismatches you may have underweighted

Do not do per-component Codex review here. One integrated checkpoint is enough.

## Anti-poisoning rule
Do not convert one failed interpretation or weak run into:
- "this idea does not work"
- "the paper is impossible"
- "already tried this"

Phrase things narrowly:
- "this interpretation is weak because..."
- "current evidence does not support this reading"
- "this remains blocking for claim X"
- "this may be workable only as scaffold, not reproduction"

## Completion condition
Do not proceed until:
- the ambiguity ledger exists
- the high/blocking items are visible
- the target reproduction/extension feasibility is stated honestly
- the implementation boundary is clear enough to plan without silent invention
