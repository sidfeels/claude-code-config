---
name: implementation-quality
description: Detailed implementation quality guidance for substantial coding, refactoring, debugging, or review work. Load when starting a non-trivial implementation pass, major refactor, or thorough code review. Complements the short always-on implementation-quality rule with deeper patterns, examples, and domain-specific verification expectations.
---

# Implementation Quality — Deep Guide

This skill supplements the always-on implementation-quality rule. Load it when doing substantial implementation, refactoring, debugging, or review — not for trivial fixes.

## First principles

### Match the repository before expressing personal style

When a codebase already exists, study its local conventions before writing code:
- naming style
- file organization
- error-handling patterns
- typing style
- testing style
- dependency patterns
- logging style
- comment and docstring style

Prefer local consistency over generic textbook purity. Do not silently rewrite the project to your preferred style. If the local style is genuinely bad, improve only what you touch and only when that improvement materially helps correctness, clarity, or maintainability. Do not perform drive-by modernization.

### Solve the problem with the minimum sufficient design

Use the simplest design that cleanly solves the actual requirement.

Prefer:
- direct control flow
- small well-named helpers
- clear ownership of state
- explicit data flow
- narrow interfaces
- changes that are easy to review and revert

Avoid:
- abstractions built for imagined future reuse
- indirection that hides simple behavior
- giant helper modules created to look organized
- configuration knobs that nobody needs
- design patterns added for style rather than necessity

### Correctness before polish

A neat-looking implementation that is weakly verified is not good code. Strong code has clear invariants, realistic tests, and behavior that matches repo reality.

## What senior-quality code looks like

### Names

Choose names that help a maintainer predict behavior without reading implementation details.
- names should reveal role, not marketing language
- avoid vague placeholders like `data`, `info`, `handler`, `util`, `misc`, `stuff` unless the local codebase already uses them for something specific
- avoid over-specific names that freeze one implementation detail into the API

### Functions and methods

Functions should do one coherent thing. Split only when the split improves readability, reuse, or testability. Do not atomize logic into many tiny wrappers just to look modular.

A good function usually has:
- a clear responsibility
- inputs that make illegal states hard to express
- a return shape that is predictable
- failure behavior that matches the repository

Avoid:
- long functions with mixed responsibilities
- wrappers that merely pass through arguments without adding meaning
- hidden mutation when the surrounding code expects explicit state changes

### Data shapes and types

Use the strongest type discipline that matches the repository and language.

When the codebase is already typed:
- preserve that discipline
- add or update types when they clarify contracts
- prefer stable typed structures over ad-hoc loosely-shaped blobs

When the codebase is weakly typed or mixed:
- do not spray type annotations everywhere just because you can
- add types where they protect boundaries, clarify assumptions, or reduce bugs
- prioritize public APIs, complex data shapes, external inputs, and tricky transformations

### Comments and docs

Comments should explain why something exists, what invariant matters, or what tradeoff is being honored. Avoid comments that merely narrate the obvious line by line.

### Error handling

Handle errors where the repository expects them to be handled. Do not wrap every block in defensive try/except or catch-all handling just to appear robust.

Prefer:
- specific exceptions or error paths
- preserving useful failure information
- surfacing actionable errors at boundaries

Avoid:
- swallowing failures
- catch-all fallbacks that hide real bugs
- defensive checks for impossible states unless the boundary truly makes them possible

### Logging

Logs should help diagnose real problems, not create noise. Prefer logs that are sparse but meaningful, aligned with the repository's existing logging style, and useful during operations or debugging. Avoid suspiciously thorough logs everywhere.

## Testing and verification expectations

### For experiments or one-off research code

At minimum verify: shapes, schemas, interfaces, basic numerical or behavioral sanity, failure modes that would silently invalidate conclusions.

### For reusable repository code

Prefer: targeted tests for changed behavior, regression tests when fixing bugs, integration checks when crossing module or service boundaries, type checks and lints when the repo uses them.

### For performance or optimization work

Verification should include: a baseline, the exact measurement method, before/after numbers, correctness checks so performance is not bought with silent breakage.

### For model or eval-related work

Prefer real responses, real traces, or real judge outputs when feasible and safe. If using mocks, stubs, or toy subsets, explicitly label what remains unverified.

## Working in brownfield code

When touching existing code:
- read neighboring files first
- copy existing successful patterns before inventing new ones
- respect local module boundaries
- keep the diff tight
- leave the touched area slightly better only when it helps the task materially

If the existing code is messy, do not mirror the mess mindlessly. Match the repo enough to belong, but improve touched code where clarity or correctness clearly benefits.

## Working in greenfield code

When there is no strong local style yet:
- choose boring, readable structure
- establish consistent naming and file layout early
- define boundaries clearly
- prefer explicit interfaces at module boundaries
- write the smallest shape that can grow cleanly later

Do not prematurely build for every future scenario.

## Final self-review before reporting completion

Before calling implementation done, mentally review the diff as if a strong senior engineer on the team asked you to justify every touched line. Check:
- is the design smaller than or equal to what the problem needs?
- does the code feel native to this repo?
- did I add anything merely because LLMs tend to add it?
- are the main assumptions verified rather than narrated?
- would a future human or future agent understand the intent quickly?

If the answer is no on any important point, fix it before claiming completion.