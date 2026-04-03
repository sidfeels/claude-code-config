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
| `CLAUDE.md` | Global operating contract: priorities, execution ladder, honesty policy, verification standards, delegation discipline, Codex/GPT-5.4 Pro usage, optimization mindset, session management |
| `rules/implementation-quality.md` | Anti-slop guard, hard mechanical rules, self-review checklist |
| `rules/delegation-and-review.md` | Facts vs suspicions, blind diagnosis, targeted falsification, checkpoint review policy |

### General Skills (on-demand)

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `implementation-quality` | `/implementation-quality` | Deep code quality: naming, functions, types, testing calibration, brownfield/greenfield |
| `optimization-loop` | `/optimization-loop [goal]` | Baseline → measure → hypothesize → change → verify → record → repeat. Reward hacking defense, memory hygiene |
| `prompting-techniques` | `/prompting-techniques` | Anti-bias delegation with 6 prompt templates: blind diagnosis, falsification, plan critique, review, rescue, GPT-5.4 Pro handoff |
| `pr-finishing` | `/pr-finishing` | PR readiness: diff review, verification rerun, narrative, risks, rollback notes |

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
  .claude/
    rules/
      implementation-quality.md
      delegation-and-review.md
    skills/
      implementation-quality/SKILL.md
      optimization-loop/SKILL.md
      prompting-techniques/SKILL.md
      pr-finishing/SKILL.md
      paper-research/
        SKILL.md
        pipeline/01-08*.md
        guardrails/*.md
        knowledge/*.md
        scaffolds/*.md
```