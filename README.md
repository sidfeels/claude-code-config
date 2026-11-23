# claude-code-config

This is Sid's personal Claude Code kit: one global CLAUDE.md, ten skills and three subagents, for running several projects at once with little attention to spare. It's built for Orca and T3 Code, and for two Claude accounts. A project usually starts from scratch and goes through discussion, parallel building, review and tests, sometimes overnight.

To see how it's used day to day, read [WORKFLOW.md](WORKFLOW.md). It's one page.

## The idea

Tokens, context and your own attention all run short when you work with agents, and the kit is built around spending them carefully.

One main session holds the whole project. Depth on one part goes to a separate session, which writes back into the project files before it closes, so main stays clean and nothing lives only in a conversation.

Every project has the same small set of files, each with one job. Each file opens with a header saying what belongs in it and how to write it, so every session and subagent writes it the same way.

Questions reach Sid only when they're Sid's to answer. Facts get looked up, and technical calls get made and listed. The real choices come with what each leads to, and the agent's lean last, with the case against it.

Reviews, expert views and test audits run in fresh subagents that never saw the plan's author arguing for it.

Every rule says why it exists, because a rule the model doesn't understand gets followed in the wrong places or not at all.

## What's inside

| Path | What it is |
|---|---|
| `global/CLAUDE.md` | How to work with Sid: hunches, pushback, choices, writing, evidence, subagents. Loads in every session. |
| `skills/kit/` | The setup's knowledge of itself: Orca, T3, accounts, Claude Code features, project file templates, and how to change the kit. |
| `skills/discuss/` | Settles a design with Sid, round by round, and writes it down. |
| `skills/spinoff/` | Opens a tab or thread for one part, with a brief. |
| `skills/save/` | Writes a session into the files, tells main, and says when it's safe to close. |
| `skills/build/` | Parallel workers in waves, with a skeleton first, then proof and a checkpoint. |
| `skills/expert/` | Independent views from fresh experts, or from other models ("council"). |
| `skills/tests/` | Which checks can see which failures, how to classify a failure, what a change ripples into, and pruning. |
| `skills/rewrite/` | Rewrites text for other readers in one human voice, or Slack messages in Sid's voice. |
| `skills/retro/` | Finds what cost Sid time and fixes the cause where it lives. |
| `skills/overnight/` | Unattended runs: decide or park by how much rides on a choice, then write a morning report. |
| `agents/doubter.md` | Adversarial reviewer. It gets the artifact and its contract, never the author's conclusion. |
| `agents/expert.md` | A domain expert who reasons first and checks precedent second. |
| `agents/test-auditor.md` | Judges a test suite: what each test depends on, what it catches, and what nothing proves. |
| `WORKFLOW.md` | "When you want X, do Y", for Sid. |
| `ARSENAL.md` | Short prompts that don't need a skill. |

## Install

```
git clone https://github.com/sidfeels/claude-code-config.git ~/orca/claude-code-config
cd ~/orca/claude-code-config
./install.sh
```

`install.sh` links the skills and agents into both config folders, `~/.claude` (work) and `~/.claude-personal` (personal, used by the `claude-personal` alias). It also makes each folder's CLAUDE.md a one-line import of `global/CLAUDE.md`, after backing up any CLAUDE.md that was already there. To install into only some folders, name them: `./install.sh ~/.claude-personal`.

Install into `~/.claude` even if you mostly use the personal account. Orca copies `~/.claude` into each of its managed account folders, so every Orca tab, on either account, reads the kit from there.

Because everything is linked, `git pull` updates every session at once. Run `./install.sh` again after pulling only when a skill or agent was added or removed. `./install.sh --uninstall` removes exactly what it installed.

After installing, start a new session and type `/` to check that the skills are listed. If you want overnight runs to survive a usage limit, add `"autoContinueAtUsageLimit": true` to the settings of the account you use. WORKFLOW.md lists the one-time Orca settings.

## Changing the kit

Change the kit through the repo, so every account gets the same version. The `retro` skill proposes changes from real sessions, and kit changes arrive as PRs. To keep the kit from growing back into the overgrown kit it replaced, every rule says why it exists, and a new line comes with a look for an old one it makes redundant.

`skills/kit/claude-code.md` lists the Claude Code settings and flags that were checked against the docs. Check it before relying on a setting.

The previous kit, with paper-research, long-running loops and the rules folder, is kept at the git tag `v1-old-kit`.

## Checked on

- Claude Code 2.1.330
- Orca 1.4.271
- T3 Code, November 2026

What was tested is listed in the PR that introduced this version.
