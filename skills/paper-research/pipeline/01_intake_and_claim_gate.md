# Stage 1 — Intake, Mode, and Claim Gate

## Purpose
Resolve what the user actually wants before doing heavy work.
A paper request is not one task. It could mean explanation, scaffold generation, claim-targeted reproduction, official-code audit, extension, or porting.

## Inputs
- User request
- Paper link / arXiv ID / PDF / pasted text / repo link
- Any explicit constraints or deadlines from Sid

## Outputs
Write these to `.paper_research_work/<paper_slug>/`:
- `PAPER_BRIEF.md`
- `REQUEST_MODE.md`
- `CLAIMS_AND_TARGETS.md`

## Step 1: Normalize the request
Identify:
- paper identifiers (arXiv, DOI, PDF, local path)
- code repos if given
- whether there is already a local repo to modify
- whether the ask is about paper understanding, paper reproduction, existing code contribution, or extension research

Normalize all links and names so later stages can refer to one canonical paper slug.

## Step 2: Build the first paper brief
Before any deep implementation reasoning, produce a short `PAPER_BRIEF.md` with:
- title
- authors
- year / version if known
- one-sentence contribution guess
- likely paper type
- likely output style (architecture, training method, inference method, dataset/benchmark, theory+empirical, systems)
- whether the task looks implementable, partially implementable, or probably not implementable

This brief is provisional. Later stages can refine it.

## Step 3: Resolve the primary mode
Choose one primary mode:
- explain
- scaffold
- reproduce
- audit
- extend
- port

If the request is ambiguous, ask Sid one high-leverage question instead of many low-value ones.

Good example:
"Do you want me to explain the paper, build a faithful scaffold, reproduce a specific claim/result, audit it against official code, extend it, or port it into an existing codebase?"

Bad example:
"Should I use PyTorch or JAX?" before the real mode is clear.

Record the answer in `REQUEST_MODE.md`.

## Step 4: Define the target claim or artifact
For modes other than pure explanation, determine the exact target.

Examples:
- reproduce Table 2 BLEU score
- implement Algorithm 1 faithfully
- port the training loss into an existing RLHF codebase
- extend the decoding method with a new caching strategy
- audit official code against Equation 4 and the appendix schedule

Write this in `CLAIMS_AND_TARGETS.md`.

A good target statement includes:
- the claim or artifact
- what "done" means
- the primary metric or acceptance test
- the most important constraints

If the paper contains no concrete implementable artifact, say so directly and switch to explain/audit mode instead of pretending reproduction is possible.

## Step 5: Determine environment and resource boundaries
Before downloads, builds, or runs, clarify:
- local Mac or shared GPU server?
- can we create a new project-local virtual environment?
- are large downloads or GPU jobs allowed?
- is there an existing repo to work inside?
- do we need to preserve a clean PR path?

If any of this is unclear and the next step could be expensive or invasive, ask Sid now.

## Step 6: Choose the initial success condition
Write a short working contract:

- **Goal**
- **Mode**
- **Target claim / artifact**
- **Primary verifier**
- **Constraints**
- **Environment**
- **Done when**

This contract should be strong enough that a fresh agent could continue from it.

## Step 7: Decide whether official code matters immediately
If the user supplied a repo or said "extend this codebase", official code or local code becomes first-class.
If not, paper acquisition still comes first, and official code remains a later ambiguity resolver.

## Completion condition
Do not proceed until:
- the mode is resolved
- the target claim or artifact is concrete enough
- the environment boundary is known
- the working contract exists

If any of those are missing, stop and resolve them instead of rushing into acquisition or code generation.
