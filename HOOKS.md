# Hooks: Deterministic Enforcement Layer

Prose in `CLAUDE.md` and skills is **advisory** — the model can ignore it under context pressure. Hooks are **deterministic** — they run every time regardless of what the model decides. For anything safety-critical (protected evals, secrets, destructive operations, banned-phrase detection in persistent state, real-verifier reminders), use hooks.

This file documents the recommended hook set for this config. Hooks are configured in Claude Code's `settings.json` (user-level at `~/.claude/settings.json` or project-level at `.claude/settings.json`). The exact JSON schema is owned by Claude Code itself and can change across versions — ask Claude to wire a hook via `/update-config` (or consult the current Claude Code docs) rather than copy-pasting a schema that may be stale.

Each hook below is described as **purpose → trigger → check → action**. Wire them up as you need them; they are independent.

## Recommended hook set

### 1. Banned-phrase warning on persistent state

**Purpose.** Prevent the #1 long-running-agent failure: broad negative conclusions (`impossible`, `doesn't work`, `already tried`, `nothing helped`, `dead end`) poisoning future sessions. See `skills/long-running-research-loop/SKILL.md` for the doctrine.

**Trigger.** After any write to `current_state.md`, `findings.md`, `RUNBOOK.md`, or any project-specific handoff / progress file.

**Check.** Grep (case-insensitive) for banned phrases:
```
impossible|doesn['’]t work|already tried|nothing helped|dead end|mathematically impossible|cannot be done
```

**Action.** Emit a warning in the tool result: "banned phrase detected in persistent state — rewrite with scoped attempt outcome (see long-running-research-loop)". Do not block; the warning is enough for a calibrated agent to self-correct.

### 2. Protected-eval guard

**Purpose.** Prevent the agent from silently editing evaluators, gold labels, hidden splits, benchmark harnesses, judge prompts, or safety canaries. This is the #1 silent reward hack.

**Trigger.** Before any write (Edit/Write) to paths matching the project's protected set.

**Check.** Path matches a project-configured glob list. Example defaults:
```
eval/**  tests/gold/**  benchmark/**  **/*.gold.*  **/*.canary.*  data/hidden/**  judge/**  scorer/**
```
Projects maintain their own list — add a `.claude/protected-paths.txt` or equivalent and have the hook read it.

**Action.** Block the write unless the session explicitly opted in (e.g. an env flag like `ALLOW_EVAL_EDIT=1` set by the user for that task). The block message should point at `optimization-loop` / `long-running-research-loop` evaluation-integrity doctrine.

### 3. Secret-scan before handoff or commit

**Purpose.** `HANDOFF_PAYLOAD.md` ships the repo's text to an external model; commits ship it to GitHub. Either is a secret-exfiltration risk.

**Trigger.** Before `HANDOFF_PAYLOAD.md` is written. Before any `git commit`.

**Check.** Run `gitleaks detect --no-git --source <target>` (or equivalent) on the payload file / staged diff. If unavailable, a grep for common patterns (`AKIA[0-9A-Z]{16}`, `-----BEGIN PRIVATE KEY-----`, `sk-[A-Za-z0-9]{20,}`, `hf_[A-Za-z0-9]{30,}`, `ghp_[A-Za-z0-9]{36}`) is a weaker fallback.

**Action.** Block on any hit. Message: "secret-like pattern detected — review and redact before proceeding."

### 4. Destructive-command soft-block

**Purpose.** Avoid accidents from autonomous agents running `rm -rf`, `sudo`, `kill -9`, force-pushes, branch deletions, global `pip install`, etc.

**Trigger.** Before any Bash command.

**Check.** Match command against a blocklist: `rm -rf`, `sudo `, `pkill`, `kill -9`, `git push --force`, `git push -f`, `git branch -D`, `git reset --hard`, `pip install -U` without `--user` or venv, `curl ... | sh`.

**Action.** Require confirmation. Not a hard block — sometimes these are the right action — but they must not run silently.

### 5. Real-verifier reminder

**Purpose.** After code changes, remind the agent what the repo's real verifier is, so it runs that rather than a toy command it invented.

**Trigger.** After any Edit/Write to non-test source files.

**Check.** Is `.claude/verifier.sh` (or equivalent pointer) present?

**Action.** Emit advisory in tool result: "verifier is `<command>` — run it before claiming the change works." Not a block.

### 6. Large-download / GPU-job approval

**Purpose.** Prevent silent multi-GB downloads or GPU jobs during an autonomous loop. Matches the guardrail in `skills/paper-research/guardrails/environment_and_compute.md`.

**Trigger.** Before commands matching: `wget`, `curl -O`, `huggingface-cli download`, `hf download`, `git lfs pull`, `python train.py`, `torchrun`, `accelerate launch`, `sbatch`, `srun`, or anything running on `cuda` with a non-toy config.

**Check.** Size/cost heuristic (file size hint, GPU flag, `--epochs` or `--max-steps` above a threshold).

**Action.** Require explicit confirmation unless a session-level `AUTO_APPROVE_COMPUTE=1` flag is set.

### 7. Payload linter (for `handoff-payload`)

**Purpose.** Before a payload goes to an external model, sanity-check token count, that the task section uses a recognized template, that suspicions are labeled, that binary data and lock files are excluded, that secret-scan passed (overlaps with hook 3).

**Trigger.** After `HANDOFF_PAYLOAD.md` is written.

**Check.**
- token count (via `code2prompt --token-format format`)
- presence of a `## Task` section
- presence of either `Verified facts`, `Observations`, `Suspicions`, or a recognized template heading
- no files matching `*.pth *.ckpt *.safetensors *.bin *.log *.lock` in the corpus
- secret-scan pass

**Action.** Print a report. Warn on any check that fails; block only on secret-scan.

## How to install hooks

Hooks live in Claude Code's settings. Invoke `/update-config` and ask Claude to wire the hooks from this file, or edit `~/.claude/settings.json` (global) or `.claude/settings.json` (per-project) by hand.

The banned-phrase warning (hook 1) and real-verifier reminder (hook 5) are the lowest-friction to start with and have no false-positive risk. Add the others as the workflow starts relying on them. Do not install all seven at once — if a hook produces many false positives and you start bypassing it, it is worse than no hook.

## When hooks are the wrong tool

- **Taste or judgment calls.** Style preferences, comment norms, architecture choices — these belong in rules/skills, not hooks. Hooks should enforce invariants, not opinions.
- **First-run discovery.** When you are still figuring out what the right rule is, write it in a skill first. Promote to a hook only after the rule has been stable for a while.
- **Anything that requires understanding context.** Hooks are regex-and-path checks. If the decision needs semantic understanding of what the agent is doing, keep it in prose.

Rule of thumb: hooks for *hard constraints*, skills for *workflows*, rules for *always-on invariants that the model evaluates*.
