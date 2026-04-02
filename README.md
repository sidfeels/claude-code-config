# Sid's Claude Code Config

Personal Claude Code configuration — global contract, always-on rules, and on-demand skills for ML research, agentic harness development, optimization, red teaming, and general engineering work.

## Quick Install

### Option 1: One-liner (any machine with curl)

```bash
mkdir -p ~/.claude/rules ~/.claude/skills/implementation-quality ~/.claude/skills/optimization-loop ~/.claude/skills/prompting-techniques && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/CLAUDE.md -o ~/.claude/CLAUDE.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/rules/implementation-quality.md -o ~/.claude/rules/implementation-quality.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/rules/delegation-and-review.md -o ~/.claude/rules/delegation-and-review.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/implementation-quality/SKILL.md -o ~/.claude/skills/implementation-quality/SKILL.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/optimization-loop/SKILL.md -o ~/.claude/skills/optimization-loop/SKILL.md && \
curl -sL https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/prompting-techniques/SKILL.md -o ~/.claude/skills/prompting-techniques/SKILL.md
```

### Option 2: Git clone

```bash
git clone https://github.com/sidfeels/claude-code-config.git /tmp/claude-config
cp /tmp/claude-config/CLAUDE.md ~/.claude/CLAUDE.md
mkdir -p ~/.claude/rules ~/.claude/skills
cp -r /tmp/claude-config/rules/* ~/.claude/rules/
cp -r /tmp/claude-config/skills/* ~/.claude/skills/
rm -rf /tmp/claude-config
```

### Option 3: Selective install

```bash
git clone https://github.com/sidfeels/claude-code-config.git /tmp/claude-config

# Pick only what you need
cp /tmp/claude-config/CLAUDE.md ~/.claude/CLAUDE.md
cp /tmp/claude-config/rules/implementation-quality.md ~/.claude/rules/
cp -r /tmp/claude-config/skills/optimization-loop ~/.claude/skills/

rm -rf /tmp/claude-config
```

## For AI Agents: Self-Install Instructions

If you are a coding agent (Claude Code, Codex, or similar) and have been asked to install this config, follow these steps:

1. Create the required directories:
```bash
mkdir -p ~/.claude/rules
mkdir -p ~/.claude/skills/implementation-quality
mkdir -p ~/.claude/skills/optimization-loop
mkdir -p ~/.claude/skills/prompting-techniques
```

2. Fetch each file from GitHub raw URLs and write to the correct path:

| Source URL | Destination |
|-----------|------------|
| `https://raw.githubusercontent.com/sidfeels/claude-code-config/main/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `https://raw.githubusercontent.com/sidfeels/claude-code-config/main/rules/implementation-quality.md` | `~/.claude/rules/implementation-quality.md` |
| `https://raw.githubusercontent.com/sidfeels/claude-code-config/main/rules/delegation-and-review.md` | `~/.claude/rules/delegation-and-review.md` |
| `https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/implementation-quality/SKILL.md` | `~/.claude/skills/implementation-quality/SKILL.md` |
| `https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/optimization-loop/SKILL.md` | `~/.claude/skills/optimization-loop/SKILL.md` |
| `https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/prompting-techniques/SKILL.md` | `~/.claude/skills/prompting-techniques/SKILL.md` |

3. Do not modify the file contents. Install as-is.
4. Do not touch any other files in `~/.claude/` (sessions, cache, plugins, settings, etc.).
5. After install, verify with: `find ~/.claude/rules ~/.claude/skills -name "*.md" | sort`

## Contents

### `CLAUDE.md` — Global Operating Contract
Loaded every session, every project. Contains: collaboration stance, operating priorities, execution ladder, honesty/uncertainty policy, ask-vs-act rules, verification standards, evaluation integrity, delegation discipline, Codex/GPT-5.4 Pro usage policy, optimization mindset, context management, session management, and completion criteria.

### Rules (`rules/`) — Always-On
Loaded into context every session alongside CLAUDE.md. Short, high-signal, low attention cost.

| File | Lines | What it does |
|------|-------|-------------|
| `implementation-quality.md` | ~27 | Anti-slop guard: overengineering, defensive boilerplate, fake verification, style contamination, cleanup drift, ceremonial complexity. Hard rules for common traps. Self-review checklist. |
| `delegation-and-review.md` | ~15 | Facts vs suspicions split. Blind diagnosis first. Targeted falsification. Require alternatives. Don't over-review. Summarize after. |

### Skills (`skills/`) — On-Demand
Only loaded when relevant or invoked with `/skill-name`. Descriptions are visible to Claude for auto-loading; full content loads only when activated.

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `implementation-quality` | `/implementation-quality` or auto | Deep guide: naming, functions, types, error handling, logging, testing calibration by context, brownfield vs greenfield, senior self-review. |
| `optimization-loop` | `/optimization-loop [goal]` | Disciplined optimization: baseline → measurement → hypothesis → change → verify → record → repeat. Plateau detection, pivot protocol, reward hacking defense, memory hygiene, session handoff. |
| `prompting-techniques` | `/prompting-techniques` or auto | Anti-bias delegation: blind diagnosis, targeted falsification, plan critique, implementation review, rescue/plateau, GPT-5.4 Pro handoff. Includes 6 ready-to-use prompt templates. |

## Architecture

```
~/.claude/
  CLAUDE.md                          ← global contract (every session)
  rules/
    implementation-quality.md        ← always-on guard (~27 lines)
    delegation-and-review.md         ← always-on delegation rules (~15 lines)
  skills/
    implementation-quality/SKILL.md  ← deep code quality (on-demand)
    optimization-loop/SKILL.md       ← scored iteration loop (on-demand)
    prompting-techniques/SKILL.md    ← delegation templates (on-demand)
```

Always-on context cost: CLAUDE.md (~205 lines) + rules (~42 lines) = ~247 lines. Under Anthropic's recommended 200-line guideline for CLAUDE.md alone, but justified — every line is high-signal.

Skills add zero context cost until loaded.

## Updating

Edit files in this repo, commit, push. On other machines:

```bash
git clone https://github.com/sidfeels/claude-code-config.git /tmp/claude-config
cp /tmp/claude-config/CLAUDE.md ~/.claude/CLAUDE.md
cp -r /tmp/claude-config/rules/* ~/.claude/rules/
cp -r /tmp/claude-config/skills/* ~/.claude/skills/
rm -rf /tmp/claude-config
```

Or re-run the one-liner from Option 1.