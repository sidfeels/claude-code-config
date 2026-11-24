# Orca: what it does and how to drive it

Sid works mostly in Orca, a desktop app that runs many agent terminals side by side and has an orchestration layer for coordinating them. These facts were checked on Orca 1.4.271. Some were tested live; the rest were read from the source. Where this file and `orca <command> --help` disagree, trust the help, then fix this file.

## Tabs

- Open a terminal tab that runs a command:
  ```
  orca terminal create --title "<name>" --command "<cmd>"
  ```
  The new tab opens without taking focus.
- `orca agent launch --agent claude --surface terminal --prompt "<text>"` is the other way to open an agent tab. It always uses Orca's selected account, so use `terminal create` when the account matters.
- An agent can't choose which pane group a new tab lands in. It lands in the group Sid last clicked, and Sid drags it where they want it. Sid's habit is to keep main on the left with the session in focus beside it, and the other sessions on the right.
- Give every tab a name Sid can scan that says its kind: "Worker: <part>" or "Discuss: <topic>". For a terminal, use `orca terminal rename --terminal <handle> --title "Discuss: evals"`. For a chat, use `orca chat rename --session <id> --name "<text>"`.
- To open a Claude tab on a specific account, use the kit's `open-session.sh`.
- `orca terminal list`, `read` and `wait` let you inspect a tab. `orca terminal send` types into one. Don't use `send` to talk to another agent: it can land in the middle of a turn, or on top of Sid's typing. Use messages instead.

## Messages between sessions

- Send a message with:
  ```
  orca orchestration send --to <handle> --subject "<short>" --body-file <file>
  ```
  The handle is the recipient's `$ORCA_TERMINAL_HANDLE`.
- Always send the message from a file with `--body-file <file>`. Inside `--body "..."`, the shell expands backticks and `$`, which mangles the text, and a backticked command would actually run.
- Orca wakes the recipient by typing "You have N orchestration messages. Run `orca orchestration check …`" into its terminal. The recipient runs that command to read the message.
- To wait inside one turn, use `orca orchestration check --wait --timeout-ms <ms>`.
- To answer a question, use `orca orchestration reply --id <message id> --body-file <file>`; without a reply the question stays pending.
- To message a worker, use `send --to dispatch:<id> --subject "<topic>" --body-file <file>`. The subject is required.
- To recover mail after losing context, use `orca orchestration inbox --terminal run:<run> --limit 50 --full`.
- Delivery from a worker to its coordinator was verified live. Delivery from a plain tab to main, outside a Run, follows the same path but wasn't tested, and the CLI help calls a terminal handle a "legacy handle". That's why `save` also writes each message to `.kit/messages/`. Check this path the first time a spinoff saves.
- Orca protects an unsent draft in the recipient's input box for only 10 minutes after the last keystroke. A half-typed message older than that can get mixed into the wake-up text.

## Workers (supervised, report back)

- Start a worker:
  ```
  orca orchestration worker-start --environment local --spec-file <file> --task-title "Worker: <part>" --worktree current --keep-open --agent claude --model <id>
  ```
  `--task-title` names the worker's tab. The spec is the worker's whole brief. Orca puts a preamble in front of it that tells the worker how to ask and how to report. `--environment local` keeps the worker on this machine even when a paired server is selected.
- Orca's guide says to start at most about four workers at once and the rest as those report. If `worker-start` fails, don't run it again; do only what the CLI prints.
- A finished worker sends `worker_done` with a short report (it can name a report file with `--report-path`), and Orca wakes the coordinator, which is the session that started the worker. `orca orchestration worker-read` shows a worker's output.
- A worker can ask the coordinator a question with `orca orchestration ask`, and Orca wakes the worker with the answer.
- Without `--keep-open`, a worker in `current` closes about 2 minutes after it reports. Use `--keep-open` whenever Sid may want to review the worker. Release it with `orca orchestration worker-release --dispatch <id>` when no one needs it any more. The dispatch id is in the start receipt, so record it.
- When Sid types into a busy worker, the message is queued until the worker's whole turn ends. That can be after the worker has already reported. To steer a worker right away, Sid presses Stop (Esc) in its tab and then types.
- A worker runs on the model `--model` names, and without the flag on a model Orca picks. Whether it would follow the project's settings.json `model` instead is untested, so pass the flag.
- The coordinator gets a "stopped without reporting" alert whenever a worker ends its turn without reporting: when Sid starts chatting with it mid-task (one alert, then silence), and when it ends its turn to wait on its own background run.
- After a worker reports, Sid's further requests to it are untracked new work, and main isn't told. That's why specs say: after reporting, send main a one-line status for every change.
- Workers launch on Orca's selected account; there's no flag to choose one. To check whether it's this session's:
  1. Run `orca account list`.
  2. Find this session's account. If this session runs on an Orca-managed account, its `$CLAUDE_CONFIG_DIR` contains the account id. Otherwise compare emails: `$CLAUDE_CONFIG_DIR/.claude.json`, or `~/.claude.json` when the variable is unset.

  Sid can switch the account in Orca, and with the "Never restart" setting running sessions keep their account.
- A Run (Orca's record of a coordinator and its workers) is tied to the main tab and deleted about a day after it settles. A new main in another tab picks up an existing Run with `orca orchestration run-list`, then `run-use --id <run>`. The Run doesn't last, so record the Run id and dispatch ids in `.kit/sessions.md`.
- `orca skills get orchestration` prints Orca's own full guide.

## Worktrees

- `--worktree current` runs the worker in this same folder. This is the default for building: every part sees the others' code, the docs stay single, and there is nothing to merge. The cost is that nothing stops two workers from editing the same file, so give each part folders it owns and keep shared files with main. The git index is shared too, so workers don't commit; main commits checkpoints.
- `new-child` and `new-top-level` create a separate checkout under `~/orca/workspaces/<repo>/<name>`, on its own branch, started from the last commit. That means none of the uncommitted work. Gitignored files such as `.env` and data folders are missing unless the repo lists them in `.worktreeinclude`. Orca never merges a worktree back. Use one only for a throwaway experiment.

## Accounts and settings

- Orca keeps one selected account for new launches: `orca account list` shows it, and `orca account select --agent claude --account <id or email>` changes it. That setting is global. Switching it from the CLI or a phone can restart running sessions on the old account and break workers. The fix is the setting "When you switch accounts while Claude is running: Never restart".
- Orca gives each managed account its own folder and fills it from `~/.claude` when it sets the account up: folders are linked, settings are copied, and CLAUDE.md is written as an import. The kit doesn't depend on this, because it lives in each project's `.claude/` folder, which Claude Code reads on any account. It matters only for Sid's own user-level skills and settings. This was read from the 1.4.271 setup code.
- In an Orca terminal, `claude` is a shell function that starts Claude on the selected account. It steps aside when `CLAUDE_CONFIG_DIR` was set by hand to another folder, so `claude-personal` still gives the personal account there. This was read from the 1.4.271 code, not run in a tab; `/status` in the session shows the account.
- Agents that Orca itself launches (`agent launch`, and workers) run with permission prompts skipped (full access) by default. A `claude` started by a command in a terminal tab, as `open-session.sh` does, uses that account's own permission mode. On the work account that mode is `auto`.
- On the work account, Claude's sandbox can block the `orca` command (`runtime_access_denied`). Rerun it with the sandbox disabled for that one command.
- Keep hibernation off. A sleeping main misses reports.

## Avoid

- Claude Agent Teams. Orca shows them as split panes, but a team dies with its lead session and isn't connected to orchestration.
- Orca artifacts. They upload to share.onorca.dev. Never put safety or security material there.
