---
name: kit
description: How Sid's setup works and how to drive it. Covers where you are running (Orca, T3 Code, a plain terminal), which Claude account you're on, how to open, message and track other sessions, the project file templates, and how to change this kit. Use before launching or messaging another session, creating a project's files, switching accounts, or editing the kit.
---

# The kit and its environment

You are one session in a setup built so Sid can run several projects with little attention. Knowing the setup is what lets you use it fully:

- open a session for a part instead of bloating this one;
- hand work to workers and get their reports back;
- keep the files that let any session pick up where another stopped.

## Where you are

Check this once per session; it's cheap.

- Orca: `$ORCA_TERMINAL_HANDLE` is set, and it is this terminal's address. Commands and behaviour are in [orca.md](orca.md). If other `ORCA_` variables are set but there's no handle, you're in an Orca chat tab. A chat can't be addressed by a handle, so ask Sid to open main as a terminal (CLI) tab instead.
- T3 Code: `$CLAUDE_CODE_ENTRYPOINT` is `t3-code`, and `$T3CODE_THREAD_ID` is this thread's address. Tools and behaviour are in [t3.md](t3.md).
- Neither: you're in a plain terminal. Subagents still work. To open a new session, give Sid the exact command to paste. `open-session.sh` prints it.

## Which account

Sid has two Claude subscriptions. The work one is cleared for security work; the other is personal. Sid picks the account per project.

A session's account is its config folder, `$CLAUDE_CONFIG_DIR`, which defaults to `~/.claude` when unset:

- `~/.claude-personal` is the personal account, started with the `claude-personal` alias.
- Inside Orca, accounts are Orca-managed folders, `~/Library/Application Support/orca/claude-profiles/<id>/home`. `orca account list` shows which id is which.
- To see an account's email, read `oauthAccount` in `$CLAUDE_CONFIG_DIR/.claude.json`, or in `~/.claude.json` when the variable is unset.

Anything you launch must run on the same account as you, unless Sid says otherwise. A personal project's spinoff on the work account bills the wrong subscription. `${CLAUDE_SKILL_DIR}/open-session.sh "<title>" "<prompt>"` opens a session on your own account. It was tested against Orca's account folders, which contain a space, so use it instead of writing the command by hand. Orca workers are the one exception: they always launch on Orca's selected account (orca.md, under Accounts).

## Project files

Every project has the following files, each made from a template in `${CLAUDE_SKILL_DIR}/templates/`.

| File | What it holds |
|---|---|
| `blueprint.md` | The project on one page: what and why, who it's for, the five sentences, parts and their status, decisions, every open question, the decisions we reversed, and the sessions working on it now. Every session reads it first. |
| `architecture.md` | How the system works today, part by part. For each part: what it does and promises, what it depends on, what uses it, and what proves it works. |
| `sid.md` | Sid's own thinking, in Sid's voice. It is gitignored and never pushed. |
| `CLAUDE.md` | Only what a session can't find by looking: where to start, how to run and check the project for real, and the project's own rules. |
| `docs/<part>.md` | Depth for a part, created only when architecture.md's short entry isn't enough. |
| `.kit/` | Session scratch: briefs, worker specs, expert reports, the overnight plan. It is gitignored. It is never the record; anything that matters gets copied into the files above. |

Each template opens with a short header that says what belongs in the file and how to write it. Keep the header when you create a file, and follow it whenever you edit.

To start a project:

1. Run `git init` if the folder isn't a git repository.
2. Copy the templates in and fill in what you know.
3. Add the lines from `templates/gitignore` to `.gitignore`.
4. Make a first commit.

In a repo Sid doesn't own, ask first. Put the kit's files in `.git/info/exclude` rather than the team's `.gitignore`.

The file set is small on purpose. Each kind of thing has exactly one home, so the next session knows where to look and Sid knows where to read:

- Open questions live only in blueprint.md, under Open.
- Decisions live where they apply, each with why and who decided.
- When a decision is reversed, it moves to blueprint.md "Changed our mind", together with what replaced it and why.

Who writes what matters as much as where. Later sessions build on what's written, so the writer must have seen what it records:

- Main, and spinoffs that talk with Sid, write the project files.
- Workers own only their folders. They send everything else to main, which records it.
- Subagents write only their own report files.
- Only a session that heard Sid directly writes to sid.md, or records "Sid" as the one who decided.

## Resuming as main

When main's tab was closed, its context was compacted, or Sid asks "where are we", rebuild the picture from what was written down, not from memory:

1. Read blueprint.md: Parts, Open and Sessions. Sessions lists each session's address, and the Run and dispatch ids.
2. Read any messages in `.kit/messages/` newer than the last time main recorded something.
3. Orca: run `orca orchestration run-list`, then `run-use --id <run>`, then `orca orchestration inbox --terminal run:<run> --limit 50`. That gives you the Run, its workers and the mail. `orca orchestration worker-list` shows which workers are still alive.
4. T3: run `t3_thread_list`, and `t3_thread_read` for each open session.

Then tell Sid in a few lines what's done, what's running, and what's waiting on them.

## Ways to get work done

Pick the lightest way that fits.

- Do it here. Use this when the work is small, or when it needs this conversation's context.
- A subagent (the Agent tool). Use one for research, a review, a fresh opinion, or parallel legwork. It costs little, Sid never sees it, and the result comes back to you. Three custom agents exist for recurring roles:
  - `doubter`: an adversarial review;
  - `expert`: an independent view through one lens;
  - `test-auditor`: judges a test suite.
- A spinoff session (the spinoff skill). Use one when a part needs Sid's discussion in depth. It opens as a visible tab or thread that Sid talks in.
- Workers (the build skill). Use them to build settled parts in parallel. Each worker reports to main.
- An expert debate (the expert skill). Use it when a decision needs independent views that argue until the real disagreement is clear.
- Overnight (the overnight skill). Use it for work that continues while Sid is away.

## Claude Code itself

[claude-code.md](claude-code.md) lists features that were checked against the docs on Claude Code 2.1.330:

- skill and subagent frontmatter;
- hooks;
- `/goal`;
- headless flags;
- settings that exist, and ones that don't.

Check it before you put a setting or flag into anything. A previous version of this kit used settings that didn't exist.

## Changing this kit

The kit is a git repo. It lives wherever this skill folder really points:

```
git -C "$(readlink -f "${CLAUDE_SKILL_DIR}")" rev-parse --show-toplevel
```

Its GitHub home is sidfeels/claude-code-config. `install.sh` symlinks its skills and agents into `~/.claude` and `~/.claude-personal`, and makes each folder's CLAUDE.md import the repo's `global/CLAUDE.md`. Because of that, an edit in the repo is live everywhere at once. Orca mirrors `~/.claude` into its account folders, so Orca tabs on either account see the same kit.

Change the kit only through the repo:

- Make the change on a branch.
- Say in the commit message what went wrong that the change fixes.
- Open a PR for Sid.
- Before adding a line, look for one it makes redundant. Say in the PR if there was none.

When you find that this kit states a fact about the environment wrongly, fix it in the one place where that fact lives.
