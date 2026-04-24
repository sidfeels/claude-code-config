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

### arXiv paper acquisition procedure
For arXiv papers, prefer the LaTeX source as the primary text artifact. TeX gives exact equations, algorithm boxes, appendix structure, and hyperparameter tables that PDF and HTML extraction frequently mangle or lose.

TeX source may also contain **commented-out author notes** (lines behind `%`). Treat these as drafts the authors deliberately removed — speculative author thinking, not paper specification. Do **not** cite them as truth, do **not** implement against them, and do **not** let them enter the ambiguity ledger as resolutions. They may occasionally hint at what the author meant; at most, label such hints in `AMBIGUITY_LEDGER.md` as `source: unpublished_draft_note` and treat with the same caution as model prior.

Given an arXiv ID (e.g. `2603.22281`), run these steps:

1. **Fetch metadata** — use WebFetch on `https://arxiv.org/abs/<id>` to get title, authors, abstract, and any linked code repos.
2. **Download the source bundle** — `curl -sL -o /tmp/<slug>-source.tar.gz "https://arxiv.org/e-print/<id>"`
3. **Extract into the artifacts tree** — `mkdir -p .paper_research_work/<slug>/artifacts/source && tar xzf /tmp/<slug>-source.tar.gz -C .paper_research_work/<slug>/artifacts/source/`
4. **Remove the archive** — `rm /tmp/<slug>-source.tar.gz`
5. **Verify** — confirm the extracted directory contains `.tex` files and that the main tex file is readable. If extraction fails (e.g. the source is a single gzipped TeX file rather than a tarball), adapt accordingly.

Do not download the PDF separately unless the source bundle is unavailable or a specific figure needs visual inspection. The extracted TeX files are the working text source for all subsequent pipeline stages.

If the paper is not on arXiv (e.g. conference-only, DOI-only), fall back to PDF via WebFetch or curl, stored under `artifacts/paper/`.

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
