# Guardrail — Scope and Ambiguity

## Purpose
Keep the workflow honest about what should be implemented, what should be referenced, and what should be declared out of scope.

## Scope by mode

### explain
Do not drift into code generation unless a tiny runnable example is genuinely helpful.

### scaffold
Implement the core contribution with explicit uncertainty, but do not pretend to reproduce final numbers.

### reproduce
Implement and verify only what is necessary for the selected claim or artifact. Do not expand to every paper component just because it exists.

### audit
Focus on divergences between paper, official code, and local repo. Avoid building new features unless the audit requires a minimal test.

### extend
Freeze a faithful baseline first. Extension happens after, not before.

### port
Preserve semantics first; stack polish comes second.

## Ambiguity severity
Every important ambiguity must get a severity:
- low
- medium
- high
- blocking

A detail is **blocking** when a reasonable expert would say the selected claim cannot be honestly reproduced without resolving or scoping around it.

## When to stop
Stop and say so when:
- the paper is conceptual or theoretical with no implementable artifact
- the claim target depends on missing information that remains blocking
- the request is really an explanation/audit task, not a reproduction task
- the current result is a faithful scaffold and going further would require silent invention

## What to exclude by default
Unless the request explicitly needs them, do not automatically build:
- distributed training infrastructure
- experiment tracking stacks
- Docker/CI/CD
- benchmark dashboards
- full dataset downloaders
- unrelated baselines
- production APIs or UIs
- broad refactors of an existing repo

## Extension boundary
Do not mix reproduction and extension casually.
If you extend before freezing the baseline, you lose the ability to say what came from the paper and what came from you.
