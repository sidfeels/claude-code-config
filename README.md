# Sid's Claude Code Config

Personal Claude Code configuration — global contract, always-on rules, and on-demand skills for ML research, agentic harness development, optimization, red teaming, and general engineering work.

## Install

### Option 1: Paste into any Claude Code session

```text
Set up my Claude Code config in this project from https://github.com/sidfeels/claude-code-config — read the README for agent setup instructions.
```

That's it. Claude reads this README and installs into the current project.

### Option 2: Git clone (manual)

```bash
git clone https://github.com/sidfeels/claude-code-config.git /tmp/claude-config
cp /tmp/claude-config/CLAUDE.md ./CLAUDE.md
mkdir -p .claude/rules .claude/skills
cp -r /tmp/claude-config/rules/* .claude/rules/
cp -r /tmp/claude-config/skills/* .claude/skills/
rm -rf /tmp/claude-config
```

### Option 3: One-liner with curl

```bash
mkdir -p .claude/rules .claude/skills/implementation-quality .claude/skills/optimization-loop .claude/skills/prompting-techniques && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/CLAUDE.md -o ./CLAUDE.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/rules/implementation-quality.md -o .claude/rules/implementation-quality.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/rules/delegation-and-review.md -o .claude/rules/delegation-and-review.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/implementation-quality/SKILL.md -o .claude/skills/implementation-quality/SKILL.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/optimization-loop/SKILL.md -o .claude/skills/optimization-loop/SKILL.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/prompting-techniques/SKILL.md -o .claude/skills/prompting-techniques/SKILL.md
```

---

## Agent Setup Instructions

If you are a coding agent and have been asked to install this config, follow these steps exactly. **Default is project-level** — install into the current working project, not user-level.

### Step 1: Check if already installed

Look for `.claude/rules/implementation-quality.md` in the current project. If it exists, say "Config already installed" and show what's present. Stop here.

### Step 2: Clone

```bash
git clone https://github.com/sidfeels/claude-code-config.git /tmp/claude-config
```

### Step 3: Create directories and copy files into current project

```bash
mkdir -p .claude/rules
mkdir -p .claude/skills/implementation-quality
mkdir -p .claude/skills/optimization-loop
mkdir -p .claude/skills/prompting-techniques

cp /tmp/claude-config/CLAUDE.md ./CLAUDE.md
cp /tmp/claude-config/rules/* .claude/rules/
cp /tmp/claude-config/skills/implementation-quality/SKILL.md .claude/skills/implementation-quality/SKILL.md
cp /tmp/claude-config/skills/optimization-loop/SKILL.md .claude/skills/optimization-loop/SKILL.md
cp /tmp/claude-config/skills/prompting-techniques/SKILL.md .claude/skills/prompting-techniques/SKILL.md
```

### Step 4: Clean up and verify

```bash
rm -rf /tmp/claude-config
find .claude/rules .claude/skills -name "*.md" | sort
```

**Do not** modify the file contents. Install as-is.

If `./CLAUDE.md` already exists with content, ask the user whether to overwrite or merge before replacing.

### User-level install (optional)

Only if the user explicitly asks for global/user-level install instead of project-level:

```bash
mkdir -p ~/.claude/rules
mkdir -p ~/.claude/skills/implementation-quality
mkdir -p ~/.claude/skills/optimization-loop
mkdir -p ~/.claude/skills/prompting-techniques

cp /tmp/claude-config/CLAUDE.md ~/.claude/CLAUDE.md
cp /tmp/claude-config/rules/* ~/.claude/rules/
cp /tmp/claude-config/skills/implementation-quality/SKILL.md ~/.claude/skills/implementation-quality/SKILL.md
cp /tmp/claude-config/skills/optimization-loop/SKILL.md ~/.claude/skills/optimization-loop/SKILL.md
cp /tmp/claude-config/skills/prompting-techniques/SKILL.md ~/.claude/skills/prompting-techniques/SKILL.md

rm -rf /tmp/claude-config
```

If `~/.claude/CLAUDE.md` already has content, ask before overwriting. Do not touch any other files in `~/.claude/`.

---

## Contents

### `CLAUDE.md` — Global Operating Contract
Loaded every session. Contains: collaboration stance, operating priorities, execution ladder, honesty/uncertainty policy, ask-vs-act rules, verification standards, evaluation integrity, delegation discipline, Codex/GPT-5.4 Pro usage policy, optimization mindset, context management, session management, and completion criteria.

### Rules (`rules/`) — Always-On
Loaded into context every session alongside CLAUDE.md. Short, high-signal, low attention cost.

| File | Lines | What it does |
|------|-------|-------------|
| `implementation-quality.md` | ~27 | Anti-slop guard: overengineering, defensive boilerplate, fake verification, style contamination, cleanup drift, ceremonial complexity. Hard rules for common traps. Self-review checklist. |
| `delegation-and-review.md` | ~15 | Facts vs suspicions split. Blind diagnosis first. Targeted falsification. Require alternatives. Don't over-review. Summarize after. |

### Skills (`skills/`) — On-Demand
Only loaded when relevant or invoked with `/skill-name`. Zero context cost until activated.

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `implementation-quality` | `/implementation-quality` or auto | Deep guide: naming, functions, types, error handling, logging, testing calibration by context, brownfield vs greenfield, senior self-review. |
| `optimization-loop` | `/optimization-loop [goal]` | Disciplined optimization: baseline → measurement → hypothesis → change → verify → record → repeat. Plateau detection, pivot protocol, reward hacking defense, memory hygiene, session handoff. |
| `prompting-techniques` | `/prompting-techniques` or auto | Anti-bias delegation: blind diagnosis, targeted falsification, plan critique, implementation review, rescue/plateau, GPT-5.4 Pro handoff. Includes 6 prompt templates. |

## Architecture (per project)

```
project/
  CLAUDE.md                          ← project contract (every session)
  .claude/
    rules/
      implementation-quality.md      ← always-on guard (~27 lines)
      delegation-and-review.md       ← always-on delegation rules (~15 lines)
    skills/
      implementation-quality/SKILL.md  ← deep code quality (on-demand)
      optimization-loop/SKILL.md       ← scored iteration loop (on-demand)
      prompting-techniques/SKILL.md    ← delegation templates (on-demand)
```

## Updating

Edit files in this repo, push. In any project, re-run Option 1 or Option 2 to pull latest.