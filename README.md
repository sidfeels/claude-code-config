# Sid's Claude Code Config

Rules, skills, and global contract for ML research, agentic harness development, optimization, red teaming, and general engineering work.

## Quick Install

Paste into any Claude Code session:

```
Set up my Claude Code config in this project from https://github.com/sidfeels/claude-code-config — read INSTALL.md for instructions.
```

For selective install options, see [INSTALL.md](INSTALL.md).

## What's Included

### Always-on (loaded every session)

| File | What it does |
|------|-------------|
| `CLAUDE.md` | Global operating contract: priorities, execution ladder, honesty policy, real-model and real-tool verification, data/trace-before-theory, evaluation integrity, delegation discipline, Codex/GPT-5.4 Pro doctrine (post-artifact default), persistent-state hygiene, deterministic-enforcement rule |
| `rules/implementation-quality.md` | Anti-slop guard, named AI code smells (cosplay, mock theater, comment certainty, style transplant), hard mechanical rules, real-LLM test rule, self-review checklist |
| `rules/delegation-and-review.md` | Facts vs suspicions, blind diagnosis, targeted falsification, hint-don't-roadmap discipline, checkpoint review policy |

### Deterministic layer (optional, recommended)

| File | What it does |
|------|-------------|
| `HOOKS.md` | Doctrine and concrete recommendations for deterministic enforcement via Claude Code hooks: banned-phrase warning on persistent state, protected-eval guard, secret-scan before handoff/commit, destructive-command soft-block, real-verifier reminder, large-download approval, payload linter. Prose is advisory; hooks are deterministic |

### General Skills (on-demand)

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `implementation-quality` | `/implementation-quality` | Deep code quality: naming, functions, types, testing calibration, brownfield/greenfield |
| `optimization-loop` | `/optimization-loop [goal]` | Baseline → measure → hypothesize → change → verify → record → repeat. Reward-hacking defense, memory hygiene, ablation discipline |
| `long-running-research-loop` | `/long-running-research-loop [goal]` | Doctrine for multi-session research, optimization, or agentic work. Typed-status ledger, banned-phrase discipline, plateau detection, human-checkpoint pattern. Prevents progress-file poisoning across context windows |
| `data-trace-inspection` | `/data-trace-inspection [target]` | Build the eyes before moving the hands. Inspect raw data, agent traces, eval samples before training / fine-tuning / eval debugging / red-team work. Domain-agnostic |
| `prompting-techniques` | `/prompting-techniques` | Anti-bias delegation with 7 prompt modes: blind diagnosis, falsification, plan critique, review, rescue, deep consultation, hint-don't-roadmap |
| `handoff-payload` | `/handoff-payload [ask]` | Build `HANDOFF_PAYLOAD.md` for manual paste into GPT-5.4 Pro or other web-only models. Uses code2prompt for the corpus + prompting-techniques for framing, with token-budget guidance |

### Paper Research Bundle (on-demand)

| Component | What it does |
|-----------|-------------|
| `paper-research/SKILL.md` | Orchestrator: 6 modes (explain, scaffold, reproduce, audit, extend, port), dynamic routing, source-of-truth hierarchy |
| `pipeline/` (8 stages) | Intake → acquisition → ambiguity audit → implementation plan → code generation → verification → extension → handoff |
| `guardrails/` (4 files) | Uncertainty/honesty, scope/ambiguity, official code usage, environment/compute safety |
| `knowledge/` (4 files) | Paper-to-code mistakes, training/optimization, agentic/post-training, systems/inference |
| `scaffolds/` (5 templates) | Paper brief, claims/targets, ambiguity ledger, results, handoff |

## Architecture

```
project/
  CLAUDE.md
  HOOKS.md                          (optional, recommended)
  .claude/
    rules/
      implementation-quality.md
      delegation-and-review.md
    skills/
      implementation-quality/SKILL.md
      optimization-loop/SKILL.md
      long-running-research-loop/SKILL.md
      data-trace-inspection/SKILL.md
      prompting-techniques/SKILL.md
      handoff-payload/SKILL.md
      paper-research/
        SKILL.md
        pipeline/01-08*.md
        guardrails/*.md
        knowledge/*.md
        scaffolds/*.md
```