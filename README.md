# claude-code-config

This is Sid's personal Claude Code kit: one file on how to work with Sid, nine skills and three subagents, for running several projects at once with little attention to spare. It's built for Orca, and for two Claude accounts. A project usually starts from scratch and goes through discussion, parallel building, review and tests.

To see how it's used day to day, read [WORKFLOW.md](WORKFLOW.md). It's one page.

## The idea

Tokens, context and your own attention all run short when you work with agents, and the kit is built around spending them carefully.

One main session holds the whole project. Depth on one part goes to a separate session, which writes back into the project files before it closes, so main stays clean and nothing lives only in a conversation.

Every project has the same small set of files, each with one job. Each file opens with a header saying what belongs in it and how to write it, so every session and subagent writes it the same way.

Questions reach Sid only when they're Sid's to answer. Facts get looked up, and technical calls get made and listed. The real choices come with what each option leads to and costs, and no lean, because Sid tends to take whatever is recommended.

Reviews, expert views and test audits run in fresh subagents that never saw the plan's author arguing for it.

Every rule says why it exists, because a rule the model doesn't understand gets followed in the wrong places or not at all.

## What's inside

| Path | What it is |
|---|---|
| `CLAUDE.md` | How to work with Sid: hunches, pushback, choices, writing, evidence, subagents. It loads in every session in this repo, and is installed into each project as `.claude/rules/working-with-sid.md`, where it loads the same way. |
| `SETUP.md` | What a setup session does in a folder: look first, tell Sid, then fit the kit to the case. |
| `skills/kit/` | The setup's knowledge of itself: Orca, accounts, Claude Code features, project file templates, and how to change the kit. |
| `skills/discuss/` | Settles a design with Sid, round by round, and writes it down. |
| `skills/spinoff/` | Opens a tab for one part, with a brief. |
| `skills/save/` | Writes a session into the files, tells main, and says when it's safe to close. |
| `skills/build/` | Parallel workers in waves, with a skeleton first, then proof and a checkpoint. |
| `skills/expert/` | Independent views from fresh experts on different Claude models, and a short debate when they disagree ("council"). |
| `skills/tests/` | Which checks can see which failures, how to classify a failure, what a change ripples into, and pruning. |
| `skills/rewrite/` | Rewrites text for other readers in one human voice, or Slack messages in Sid's voice. |
| `skills/retro/` | Finds what cost Sid time and fixes the cause where it lives. |
| `agents/doubter.md` | Adversarial reviewer. It gets the artifact and its contract, never the author's conclusion. |
| `agents/expert.md` | A domain expert who reasons first and checks precedent second. |
| `agents/test-auditor.md` | Judges a test suite: what each test depends on, what it catches, and what nothing proves. |
| `WORKFLOW.md` | "When you want X, do Y", for Sid. |
| `ARSENAL.md` | Short prompts that don't need a skill. |

## Install

Open the folder in Orca, start `claude` (or `claude2`) in a terminal tab, and paste this. In a plain terminal, start `claude` in the folder and paste the same thing.

```
Set up Sid's kit in this folder. Run the command below, then follow SETUP.md in the folder it prints. Tell me what you found and what you plan before you change anything.

d="${TMPDIR:-/tmp}/sid-kit"; rm -rf "$d" && git clone -q --depth 1 https://github.com/sidfeels/claude-code-config "$d" && echo "kit: $d"
```

The session clones this repo and follows [SETUP.md](SETUP.md): it looks at the folder, tells you what it found and what it plans, and changes nothing until you say go. The same prompt sets up a new folder, fits the kit into a team's repo, replaces Sid's old v1 kit, and updates a project to a newer kit. When it's done, close that session and start a new one in the folder, so the kit loads from the start.

This is the only copy of the prompt. WORKFLOW.md points here, so it can't drift.

What lands in the project is the skills, the agents and this repo's `CLAUDE.md` (as `rules/working-with-sid.md`), all in the project's `.claude/` folder, plus `.claude/kit-version`, which records the kit commit and no date. Setup also writes Sid's model to `.claude/settings.local.json`. None of these go into git, in Sid's repos or a team's: `install.sh` lists them in `.git/info/exclude`, along with sid.md, `.kit/` and CLAUDE.local.md, so a new machine or a fresh clone gets the kit by running the setup prompt again. The project's own CLAUDE.md, architecture.md and decisions.md do go into git in Sid's repos. Claude Code reads `.claude/` from the project whichever account is in use, so both accounts get the same kit and nothing is set up per account.

`install.sh` does the mechanical part:

- `--inspect` prints what a folder already has, its git hooks included, and changes nothing.
- `--project` copies the kit in and keeps it out of git. It never overwrites; it only adds what's missing.
- `--update` brings a project's copy up to the kit's commit. Files the project never changed are replaced, and files it changed are kept and listed for merging.
- `--diff` shows what a project changed in its copy since it was installed.

Don't keep a global install next to it. For a skill with the same name, Claude Code uses the copy in the account folder and ignores the project's. `./install.sh --uninstall`, run from the clone the global links point to, removes a global install. `./install.sh --global` is the old way, kept only so it can be undone.

WORKFLOW.md lists the one-time Orca settings.

## Changing the kit

Each project changes its own copy as it learns, and notes why in `.kit/kit-changes.md`. `install.sh --diff` shows those changes later, and the ones worth keeping come back here as PRs. To keep the kit from growing back into the overgrown kit it replaced, every rule says why it exists, and a new line comes with a look for an old one it makes redundant.

`skills/kit/claude-code.md` lists the Claude Code settings and flags that were checked against the docs. Check it before relying on a setting.

The previous kit, with paper-research, long-running loops and the rules folder, is kept at the git tag `v1-old-kit`.

## Checked on

- Claude Code 2.1.330
- Orca 1.4.271

What was tested is listed in the PR that introduced this version.
