# Stage 2 — Artifact Acquisition and Source Graph

## Purpose
Acquire the actual research artifacts and map their provenance before interpreting the method.
This stage is about getting the right sources, not about deciding what the code should do.

## Inputs
- `PAPER_BRIEF.md`
- `REQUEST_MODE.md`
- `CLAIMS_AND_TARGETS.md`

## Outputs
Write these to `.paper_research_work/<paper_slug>/`:
- `ARTIFACT_REGISTRY.md`
- `SOURCE_GRAPH.md`

Create artifact directories under:
`.paper_research_work/<paper_slug>/artifacts/`

Suggested layout:
- `artifacts/paper/`
- `artifacts/appendix/`
- `artifacts/source/`
- `artifacts/html/`
- `artifacts/code/`
- `artifacts/references/`

Keep intermediate paper artifacts inside the repo-local `.paper_research_work/` tree. Do not scatter them across home directories or shared `/tmp` on multi-user systems.

## Before doing anything expensive
Read `guardrails/environment_and_compute.md`.

If acquisition may involve:
- large downloads
- datasets
- model checkpoints
- GPU work
- modifying a shared server environment

then confirm Sid’s environment choice and permissions first.

## Step 1: Build the artifact plan
List what you want to acquire:
- paper abstract/metadata page
- PDF
- HTML / ar5iv view if available
- appendix / supplementary
- source bundle when useful
- official code
- key cited references only if they close a blocking ambiguity
- benchmark repos or external metric implementations if the claim target depends on them

Not every paper needs every artifact. Acquire intentionally.

## Step 2: Acquire paper text with a fallback chain
Use this order:
1. abstract/metadata page
2. PDF
3. ar5iv/HTML fallback if PDF extraction is poor
4. source bundle / TeX only when the paper is notation-heavy, extraction quality is poor, or exact appendix/equation structure matters

Do not force source-bundle download for every paper. Use it when it solves a real extraction problem.

If arXiv source download is used, keep it under:
`.paper_research_work/<paper_slug>/artifacts/source/`

Record what was acquired, from where, and why.

## Step 3: Check extraction quality
For every extracted source, assess:
- title and abstract readable?
- section headings recoverable?
- equations preserved reasonably?
- appendix content present?
- figure/table captions readable?
- algorithm boxes readable?
- references accessible?

If the method section or appendix is unreadable, do not pretend acquisition succeeded. Escalate to a better source.

## Step 4: Mine appendices, footnotes, and captions
Treat these as first-class.
Specifically look for:
- hyperparameter tables
- training details
- prompt templates
- data filtering rules
- system prompts
- ablation caveats
- implementation notes hidden in captions or footnotes
- late-paper qualifiers like "for all experiments except..."

If the paper mentions supplementary material but it is not present, record that gap.

## Step 5: Discover official code and related code artifacts
Look for:
- official author repo
- model-card or project page
- benchmark/eval repo
- repository linked on the paper page or abstract page

When official code is found:
- verify it is actually for this paper
- record URL, branch/tag/commit if possible
- note the framework and repo shape
- do not treat it as paper truth yet

If the user already gave a repo and wants to contribute to it, treat that repo as a top-level artifact too.

## Step 6: Build the source graph
Write `SOURCE_GRAPH.md` mapping each important source to what it is good for.

Example categories:
- paper main text → conceptual specification
- appendix → hyperparameters and caveats
- figure captions → component placement or dataflow
- official code → ambiguity resolution
- reference paper X → inherited component semantics
- benchmark repo → metric exactness

A good source graph answers:
- where should I look for architecture details?
- where should I look for training recipe details?
- where should I look for evaluation exactness?
- where can ambiguity be closed if the paper is incomplete?

## Step 7: Use subagents deliberately
Good subagent roles here:
- paper-reader
- appendix-miner
- official-code-scanner
- reference-chaser

Do not yet ask Codex to review each tiny extracted component.
Use Codex only if:
- the official codebase is large and subtle
- you need a sharper code-structure read than a lightweight subagent gives
- the source graph has a difficult code-to-paper mapping problem

## Step 8: Record artifact status
In `ARTIFACT_REGISTRY.md`, record for each artifact:
- name
- source URL/path
- status (acquired / missing / low quality / superseded)
- why it matters
- trust level

## Completion condition
Do not proceed until:
- the paper method source is readable enough
- appendix/supplementary status is known
- official code status is known
- the source graph exists
- missing critical artifacts are explicitly noted
