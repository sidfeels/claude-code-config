---
name: kit
description: How Sid's setup works and how to drive it. Covers where you are running (Orca or a plain terminal), which Claude account you're on, how to open, message and track other sessions, the project file templates, and how to change this kit. Use before launching or messaging another session, creating a project's files, switching accounts, or editing the kit.
---

# The kit and its environment

You are one session in a setup built so Sid can run several projects with little attention. Knowing the setup is what lets you use it fully:

- open a session for a part instead of bloating this one;
- hand work to workers and get their reports back;
- keep the files that let any session pick up where another stopped.

## Where you are

Check this once per session; it's cheap.

- Orca: `$ORCA_TERMINAL_HANDLE` is set, and it is this terminal's address. Commands and behaviour are in [orca.md](orca.md). If other `ORCA_` variables are set but there's no handle, you're in an Orca chat tab. A chat can't be addressed by a handle, so ask Sid to open main as a terminal (CLI) tab instead.
- Otherwise: you're in a plain terminal. Subagents still work. To open a new session, give Sid the exact command to paste. `open-session.sh` prints it.

## Which account

Sid has two Claude subscriptions, work and personal, and uses both for capacity: when one is near its limit, work moves to the other. Either can run any project, except security and red-team work (the working rules, under Security work).

A session's account is its config folder, `$CLAUDE_CONFIG_DIR`, which defaults to `~/.claude` when unset:

- `claude` in a plain terminal is the work account, in `~/.claude`.
- `claude2` is the personal account, in `~/.claude-personal`. It's a shell alias, and `claude-personal` is the same alias under its older name. It works inside an Orca tab too, because Orca's wrapper around `claude` leaves alone a config folder Sid set by hand.
- Inside Orca, `claude` and every tab Orca opens use Orca's selected account, kept in `~/Library/Application Support/orca/claude-profiles/<id>/home`. `orca account list` shows which one is selected.
- To see which account a session is on, type `/status` in it, or read `oauthAccount` in `$CLAUDE_CONFIG_DIR/.claude.json` (`~/.claude.json` when the variable is unset).

Launch on your own account unless Sid says otherwise. Sid opened this session on the account that has room, and a spinoff on the other one spends the limit Sid is trying to save. `${CLAUDE_SKILL_DIR}/open-session.sh "<title>" "<prompt>"` opens a session on your own account. When Sid asks for the other one, add `work` or `personal` as a third argument; Sid calls the personal account "claude2". When Sid names a model for that one session, add it as a fourth argument (with `same` third to keep the account); otherwise it gets Sid's model from `.claude/settings.local.json`, like any `claude` started in this folder. The script was tested against Orca's account folders, which contain a space, so use it instead of writing the command by hand.

Orca workers are the one exception: they always launch on Orca's selected account, and the build skill says what to tell Sid first.

The kit is the same on both accounts, because it lives in this project's `.claude/` folder and Claude Code reads that whichever account is in use. What stays separate is each account's own settings.json: the permission mode, user-level hooks and sandbox settings. `~/.claude-personal` has almost none, so a session there asks before most actions unless Sid copies the settings over.

## Project files

Every project has the following files, each made from a template in `${CLAUDE_SKILL_DIR}/templates/`.

| File | What it holds |
|---|---|
| `architecture.md` | The project as it stands today, and the file every session reads first: what we're building and why, how it looks from outside, how it fits together in five sentences, every open question, and each part with what it does, examples of it working, the choices that matter and why, its limits, what it depends on, and its status. |
| `decisions.md` | How the design got this way: one entry for each choice made or replaced, each option turned down, and each thing we relied on that turned out wrong. Entries are added at the bottom and never rewritten. |
| `sid.md` | What Sid thinks about the project, in Sid's own words: what still matters on top, what's been dealt with below. Entries are leads to check, not instructions. It is kept out of git and never pushed. |
| `CLAUDE.md` | The project's own facts, which a session can't find by looking: where to start, how to run and check it for real, and its rules. In Sid's own repo it's committed. In a team's repo their CLAUDE.md stays theirs, and Sid's notes go in CLAUDE.local.md, which is kept out of git. |
| `docs/<part>.md` | Depth for a part, created only when architecture.md's short entry isn't enough. |
| `.claude/` | This project's own copy of the kit: its skills, its agents and `rules/working-with-sid.md`. `kit-version` names the kit commit it came from, and `settings.local.json` holds Sid's model. None of it is in git; a new machine gets it by running the setup prompt again. |
| `.kit/` | Session scratch: briefs, worker specs and reports, run output, messages between sessions, expert reports, and `sessions.md`, the list of sessions working on the project right now. It is kept out of git. It is never the record; anything that matters gets copied into the files above. |

Each template opens with a short header that says what belongs in the file and how to write it. Keep the header when you create a file, and follow it whenever you edit.

### Setting up, and when files are missing

Setting the kit up in a folder, fitting it to a team's repo, replacing Sid's old v1 kit and updating a project to a newer kit are all done by a session following `SETUP.md` in the kit repo. Its README has the prompt Sid pastes. If you find this project's files missing, or `.claude/` half there, tell Sid that prompt sets it right; don't patch it by hand. The one exception: when `/discuss` starts a project and the four files don't exist yet, create them from the templates above.

### One home for each thing

The file set is small on purpose. Each kind of thing has exactly one home, so the next session knows where to look and Sid knows where to read:

- Open questions live only in architecture.md, under Open questions.
- The sessions working on the project right now are listed only in `.kit/sessions.md`, one line each: `<tab name> | <address> | <what it's doing> | started <date>`. The Orca Run id goes on its first line. A session's line is removed when it saves and closes. The list is scratch, because a terminal address means nothing outside this machine.
- How things work today lives only in architecture.md.
- Decisions and their history live only in decisions.md, each with the real reason and who decided. A reversal is a new entry there.

Who writes what matters as much as where. Later sessions build on what's written, so the writer must have seen what it records:

- Main, and spinoffs that talk with Sid, write the project files.
- Workers own only their folders. They send everything else to main, which records it.
- Subagents write only their own report files.
- Only a session that heard Sid directly writes to sid.md, or records "Sid" as the one who decided.

## Resuming as main

When main's tab was closed, its context was compacted, or Sid asks "where are we", rebuild the picture from what was written down, not from memory:

1. Read architecture.md: each part's Status, and Open questions. Then read `.kit/sessions.md`, which lists each live session's address, and the Run and dispatch ids.
2. Read any messages in `.kit/messages/` newer than the last time main recorded something.
3. Orca: run `orca orchestration run-list`, then `run-use --id <run>`, then `orca orchestration inbox --terminal run:<run> --limit 50`. That gives you the Run, its workers and the mail. `orca orchestration worker-list` shows which workers are still alive.

Then tell Sid in a few lines what's done, what's running, and what's waiting on them.

## Ways to get work done

Pick the lightest way that fits.

- Do it here. Use this when the work is small, or when it needs this conversation's context.
- A subagent (the Agent tool). Use one for research, a review, a fresh opinion, or parallel legwork. It costs little, Sid never sees it, and the result comes back to you. Three custom agents exist for recurring roles:
  - `doubter`: an adversarial review;
  - `expert`: an independent view through one lens;
  - `test-auditor`: judges a test suite.
- A spinoff session (the spinoff skill). Use one when a part needs Sid's discussion in depth. It opens as a visible tab that Sid talks in.
- Workers (the build skill). Use them to build settled parts in parallel. Each worker reports to main.
- An expert debate (the expert skill). Use it when a decision needs independent views that argue until the real disagreement is clear.

## Claude Code itself

[claude-code.md](claude-code.md) lists features that were checked against the docs on Claude Code 2.1.330:

- skill and subagent frontmatter;
- hooks;
- `/goal`;
- headless flags;
- settings that exist, and ones that don't.

Check it before you put a setting or flag into anything. A previous version of this kit used settings that didn't exist.

## Changing this kit

This project has its own copy of the kit, in `.claude/`: the skills, the agents and `rules/working-with-sid.md`. `.claude/kit-version` names the commit of sidfeels/claude-code-config it came from.

Change the copy when this project teaches you something. That's what it's for, and it can't disturb any other project.

- The copy isn't in git, so note what went wrong that the change fixes in `.kit/kit-changes.md`, one line per change. Sid reads these later, across projects, to decide what goes back into the kit.
- Before adding a line, look for one it makes redundant.
- A changed skill takes effect in sessions started after the change.

To see everything this project changed, run `install.sh --diff <this folder>` from a clone of the kit. `.kit/kit-changes.md` says why. To bring this copy up to a newer kit, Sid pastes the setup prompt again; SETUP.md covers it as "A project already on this kit".

To send a change back so future projects start with it, open a PR on sidfeels/claude-code-config from a clone of it.

A global copy of the kit overrides this project's skills of the same name, so changes here would do nothing. If `ls ~/.claude/skills/kit ~/.claude-personal/skills/kit` finds one, tell Sid. `install.sh --uninstall`, run in the folder those links point to, removes it.

When you find that this kit states a fact about the environment wrongly, fix it in the one place where that fact lives.
