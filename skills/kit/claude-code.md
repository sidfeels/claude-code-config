# Claude Code features this kit relies on

These were checked against code.claude.com docs and `claude --help` on Claude Code 2.1.330, in November 2026. When something here looks stale, check the docs and fix this file.

## Skills (`skills/<name>/SKILL.md`)

### Frontmatter

| Field | What it does |
|---|---|
| `name` | The skill's name. |
| `description` | When to use it. With `when_to_use`, capped at 1,536 characters. |
| `when_to_use` | Extra trigger text. It counts toward the same cap. |
| `argument-hint` | Hint shown for the skill's argument. |
| `arguments` | Named arguments. |
| `disable-model-invocation: true` | Only Sid can start it. Use this when starting it is Sid's decision. |
| `user-invocable: false` | Hidden from the `/` menu. |
| `allowed-tools` | Tools that skip prompts for the turn. |
| `disallowed-tools` | Tools the skill can't use. |
| `model`, `effort` | Apply to the current turn. |
| `context: fork` with `agent` | Runs the skill in a subagent. |
| `hooks` | Registered when the skill is invoked, and active for the rest of the session. |
| `paths` | Globs that activate the skill. |

Unknown fields are ignored.

### What loads when

Descriptions are always in context. All of them share a budget of about 1% of the context window, so keep descriptions tight. The body loads only when the skill runs.

### Substitutions

- `$ARGUMENTS` and `$N`
- `${CLAUDE_SKILL_DIR}`: the skill's own folder. Use it for supporting files.
- `${CLAUDE_SESSION_ID}`, `${CLAUDE_PROJECT_DIR}`
- `` !`cmd` `` injects a command's output. A failing command aborts the skill unless it ends in `|| true`.

There is no documented way to point at another skill's folder. Load that skill instead.

### Symlinks

A symlinked skill folder works.

## Subagents (`agents/<name>.md`)

### Frontmatter

| Field | What it does |
|---|---|
| `name`, `description` | Required. |
| `tools`, `disallowedTools` | Which tools the subagent gets. |
| `model` | sonnet, opus, haiku, fable, a full id, or `inherit`. |
| `permissionMode` | The subagent's permission mode. |
| `maxTurns` | Turn limit. |
| `skills` | Skills to preload. |
| `memory` | `user`, `project` or `local`. |
| `background` | Runs it in the background. |
| `effort` | Reasoning effort. |
| `isolation: worktree` | Gives it its own checkout. |
| `hooks` | Hooks scoped to the subagent. |
| `color` | Display color. |
| `omitClaudeMd` | Skips CLAUDE.md. |

### What subagents can and can't do

- A subagent can use Write and Edit unless you remove them.
- A subagent can start its own subagents, up to depth 3.
- AskUserQuestion is always removed from subagents, so a subagent can't ask Sid anything. Put everything it needs in the brief.

## Hooks

Hooks can be defined in settings.json, in a skill's frontmatter, or in a subagent's frontmatter. The structure is event, then a matcher group, then the handlers. The matcher is `*` or a tool name such as `AskUserQuestion`.

Commands receive JSON on stdin. They can use `$CLAUDE_PROJECT_DIR`.

| What you want | What the hook returns |
|---|---|
| Deny a tool call, with a reason Claude sees | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` |
| Answer a permission prompt | `{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}`, or `"deny"`. Exit code 2 is ignored for this event. |
| Keep the session from stopping | `{"decision":"block","reason":"..."}` from a Stop hook. `stop_hook_active` is true when the stop follows a block. A session allows at most 8 consecutive blocks. |
| Add context at session start | `{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"..."}}` |

Only a hook guarantees that a step happens. Instructions get skipped.

## Running unattended

### `/goal <condition>`

`/goal <condition>` keeps the session working until a small model judges that the condition is met. Only Sid can type it.

- The evaluator sees only the transcript, so make the condition something visible there.
- Include a turn bound ("or 100 turns have passed"). There is no `--max-turns` flag.
- `/goal clear` stops it.

### Headless runs (`claude -p`)

| Flag | What it does |
|---|---|
| `--permission-mode` | `default`, `acceptEdits`, `plan`, `auto`, `dontAsk` or `bypassPermissions`. |
| `--permission-prompts none` | Denies anything that would prompt, and removes AskUserQuestion. |
| `--max-budget-usd` | Spending cap. |
| `--output-format json` | Machine-readable output. |
| `--continue` / `--resume` | Picks up an earlier session. |

### Settings that exist

| Setting | What it does |
|---|---|
| `autoContinueAtUsageLimit` | Resumes after a usage limit resets. User settings only. |
| `permissions.defaultMode` | `auto` and `bypassPermissions` count only from user settings. |
| `permissions.denyInsteadOfPrompting` | User settings only. |
| `sandbox.excludedCommands` | Commands that run outside the sandbox. |
| `skipDangerousModePermissionPrompt` | Skips the warning for bypass mode. |
| `askUserQuestionTimeout` | `60s`, `5m` or `10m`. |
| `attribution` | Replaces the deprecated `includeCoAuthoredBy`. |
| `skillListingBudgetFraction` | Share of the context window for skill descriptions. |
| `skillOverrides` | Per-skill overrides. |
| `claudeMdExcludes` | CLAUDE.md files to skip. |
| `autoMemoryEnabled` | Turns auto memory on or off. |

### Names that don't exist

- `skillListingBudget`
- a top-level `denyInsteadOfPrompting`
- `--max-turns`

## What Claude Code reads from a project

Run on 2.1.330 on 2026-11-23, with `claude -p` in a test project, on both accounts:

- `.claude/skills/<name>/SKILL.md` and `.claude/agents/<name>.md` load whichever account is in use.
- `./CLAUDE.md`, `.claude/CLAUDE.md` and every `.claude/rules/*.md` load as instructions.
- When a skill of the same name is also in the account folder, the account folder's copy is used and the project's is ignored. For an agent of the same name it is the other way round: the project's copy is used.
- A test project under `/private/tmp` loaded its skills and agents but none of its instruction files. Put test projects under the home folder.

## Config folders and memory

`CLAUDE_CONFIG_DIR` moves everything that would be under `~/.claude` to the folder it names:

- CLAUDE.md
- settings.json
- skills/
- agents/
- projects/ (transcripts)

In CLAUDE.md, `@path` imports another file. A user-level import loads without asking.

Auto memory lives at `<config>/projects/<project>/memory/MEMORY.md`. The first 200 lines load at session start. Memory is per machine and per config folder. Orca's account folders link their `projects/` to `~/.claude/projects`, so they share memory and transcripts with the default account; a session started with `claude-personal` doesn't. Other tools never see it. So anything a project needs goes in the project files, not memory.

## Also available

- Background sessions: `claude --bg` and `claude agents`.
- `claude -w` for a worktree session.
- Output styles, in `<config>/output-styles/`.
- `claude plugin validate <dir>` checks skill frontmatter.
