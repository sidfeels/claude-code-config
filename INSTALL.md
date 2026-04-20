# Install

Pick what you need. Paste the relevant prompt into Claude Code, or run the commands manually.

---

## Codex Plugin (recommended)

Many skills (prompting-techniques, optimization-loop, paper-research) delegate work to Codex for independent review, rescue, and adversarial analysis. Install the Codex plugin to enable this.

**Requirements:** Node.js 18.18+, ChatGPT subscription (incl. Free) or OpenAI API key.

```bash
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

If Codex CLI is missing, `/codex:setup` will offer to install it. If already installed but not logged in:

```bash
!codex login
```

Verify with `/codex:review --background` then `/codex:status`.

---

## Option A: Core only (no paper-research)

Best for general engineering, optimization, agentic harness, and backend work.

### Paste this into Claude Code:

```text
Install Claude Code config from https://github.com/sidfeels/claude-code-config into this project (project-level, not user-level).

Fetch and install these files:

**Global contract:**
- https://raw.githubusercontent.com/sidfeels/claude-code-config/main/CLAUDE.md → ./CLAUDE.md

**Rules:**
- https://raw.githubusercontent.com/sidfeels/claude-code-config/main/rules/implementation-quality.md → .claude/rules/implementation-quality.md
- https://raw.githubusercontent.com/sidfeels/claude-code-config/main/rules/delegation-and-review.md → .claude/rules/delegation-and-review.md

**Skills:**
- https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/implementation-quality/SKILL.md → .claude/skills/implementation-quality/SKILL.md
- https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/optimization-loop/SKILL.md → .claude/skills/optimization-loop/SKILL.md
- https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/prompting-techniques/SKILL.md → .claude/skills/prompting-techniques/SKILL.md
- https://raw.githubusercontent.com/sidfeels/claude-code-config/main/skills/handoff-payload/SKILL.md → .claude/skills/handoff-payload/SKILL.md

Create directories as needed. Do NOT overwrite existing files — ask before replacing.

Note: `handoff-payload` depends on the `code2prompt` CLI. Install it with `brew install code2prompt` (macOS) or `cargo install code2prompt`.
```

### Or manually:

```bash
git clone https://github.com/sidfeels/claude-code-config.git /tmp/cc
cp /tmp/cc/CLAUDE.md ./CLAUDE.md
mkdir -p .claude/rules .claude/skills/implementation-quality .claude/skills/optimization-loop .claude/skills/prompting-techniques .claude/skills/handoff-payload
cp /tmp/cc/rules/* .claude/rules/
cp /tmp/cc/skills/implementation-quality/SKILL.md .claude/skills/implementation-quality/SKILL.md
cp /tmp/cc/skills/optimization-loop/SKILL.md .claude/skills/optimization-loop/SKILL.md
cp /tmp/cc/skills/prompting-techniques/SKILL.md .claude/skills/prompting-techniques/SKILL.md
cp /tmp/cc/skills/handoff-payload/SKILL.md .claude/skills/handoff-payload/SKILL.md
rm -rf /tmp/cc
```

**Also install the code2prompt CLI** (required by `handoff-payload`):
```bash
brew install code2prompt   # or: cargo install code2prompt
```

---

## Option B: Everything (core + paper-research)

Best when working with research papers — reproduction, extension, auditing, or paper-to-code tasks.

### Paste this into Claude Code:

```text
Install full Claude Code config from https://github.com/sidfeels/claude-code-config into this project (project-level, not user-level).

Clone the repo and copy everything:

1. git clone https://github.com/sidfeels/claude-code-config.git /tmp/cc
2. cp /tmp/cc/CLAUDE.md ./CLAUDE.md
3. mkdir -p .claude/rules .claude/skills
4. cp -r /tmp/cc/rules/* .claude/rules/
5. cp -r /tmp/cc/skills/* .claude/skills/
6. rm -rf /tmp/cc
7. Verify: find .claude -name "*.md" | sort

Do NOT overwrite existing files — ask before replacing. This includes the paper-research skill bundle with pipeline, guardrails, knowledge, and scaffold templates.
```

### Or manually:

```bash
git clone https://github.com/sidfeels/claude-code-config.git /tmp/cc
cp /tmp/cc/CLAUDE.md ./CLAUDE.md
mkdir -p .claude/rules .claude/skills
cp -r /tmp/cc/rules/* .claude/rules/
cp -r /tmp/cc/skills/* .claude/skills/
rm -rf /tmp/cc
```

---

## Option C: Add paper-research to an existing setup

If you already have core installed and want to add the paper-research bundle.

### Paste this into Claude Code:

```text
Add the paper-research skill from https://github.com/sidfeels/claude-code-config to this project.

1. git clone https://github.com/sidfeels/claude-code-config.git /tmp/cc
2. cp -r /tmp/cc/skills/paper-research .claude/skills/paper-research
3. rm -rf /tmp/cc
4. Verify: find .claude/skills/paper-research -name "*.md" | sort

This should install the SKILL.md, 8 pipeline stages, 4 guardrails, 4 knowledge files, and 5 scaffold templates.
```

---

## Option D: User-level install (global, all projects)

Only if you want this config to apply to every project on this machine.

```bash
git clone https://github.com/sidfeels/claude-code-config.git /tmp/cc
cp /tmp/cc/CLAUDE.md ~/.claude/CLAUDE.md
mkdir -p ~/.claude/rules ~/.claude/skills
cp -r /tmp/cc/rules/* ~/.claude/rules/
cp -r /tmp/cc/skills/* ~/.claude/skills/
rm -rf /tmp/cc
```

**Warning:** If `~/.claude/CLAUDE.md` already has content, back it up first.

---

## Agent Setup Instructions

If you are a coding agent installing this config, follow these rules:

1. **Default is project-level** — install into `./` and `.claude/`, not `~/.claude/`, unless the user explicitly says global/user-level.
2. **Do NOT overwrite existing files.** If `./CLAUDE.md` or any target file already exists, ask the user: skip, overwrite, or merge.
3. **Do NOT modify file contents.** Install as-is from the repo.
4. **Do NOT touch other files** in `.claude/` or `~/.claude/` (sessions, cache, plugins, settings, history).
5. **After install**, run `find .claude -name "*.md" | sort` and show the result to confirm.

---

## What Gets Installed

| Option | CLAUDE.md | Rules | General Skills | Paper Research | Total files |
|--------|-----------|-------|---------------|----------------|-------------|
| A: Core only | 1 | 2 | 4 | — | 7 |
| B: Everything | 1 | 2 | 4 | 22 | 29 |
| C: Add paper-research | — | — | — | 22 | 22 |
| D: User-level | 1 | 2 | 4 | 22 | 29 |

## After Install

Restart Claude Code or start a new session. Verify with: `/implementation-quality` or `/paper-research` to check skills are available.