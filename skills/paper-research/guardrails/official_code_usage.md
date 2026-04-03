# Guardrail — Official Code Usage

## Purpose
Use official code to resolve ambiguity without allowing it to overwrite paper truth silently.

## First questions
Before trusting an official repo, check:
- is it actually from the authors or the project page?
- is it clearly tied to this paper?
- is there a tag, release, or commit near the paper date?
- does it look like research code, productionized code, or a later evolved system?

## Reading order
When using official code to close ambiguity, inspect in this order:
1. README / docs / config files
2. model definitions
3. training or inference entrypoints
4. evaluation code
5. helper utilities only when necessary

Search configs before diving into random implementation details.

## Allowed uses
You may use official code to:
- resolve unspecified hyperparameters
- resolve component placement or sequencing
- clarify prompt templates or preprocessing
- clarify metric implementation
- identify paper-vs-code drift

## Disallowed shortcuts
Do not:
- silently treat official-code decisions as paper-specified
- copy-paste large chunks without understanding
- inherit unrelated engineering scaffolding
- assume `main` is the paper-faithful state if the repo has evolved significantly

## Recording protocol
When official code closes an ambiguity, record:
- the item
- the exact file / config / function
- branch / tag / commit if available
- why this was needed
- whether it conflicts with the paper

Tag the item as `FROM_OFFICIAL_CODE`.

## Divergence protocol
If official code and paper disagree:
- record both
- decide which one your mode requires
- explain the choice

Examples:
- reproduction mode may prefer the paper unless evidence says the paper has a typo or erratum
- audit mode must preserve the divergence explicitly
- extension mode may adopt the code path if the local repo already follows it
