---
name: build
description: Build settled parts in parallel with workers that report to this main session, then integrate, prove the whole thing end to end, and commit a checkpoint. Use for /build, "start building", or a build wave once parts in architecture.md are settled.
argument-hint: "[parts]"
---

# Build

Parallel building is fast, and it goes wrong in four ways:

- Workers build on assumptions that were never settled.
- Their work drifts apart, or collides in the folder they share.
- Sid's attention gets spread across many tabs.
- The wrong thing gets built well, and nobody notices until it's finished.

The answers are to build only what's settled, to give every worker a contract and folders it owns, to keep main as the one place that integrates, records and reports, and to show Sid real output early and after every wave.

## Before the first wave

Build only parts whose Status in architecture.md says settled and that have their "Works when" examples. A part that is still being discussed will be rebuilt. A part with no examples has no agreed meaning of "done", so get them from Sid first (the discuss skill).

Check that the reviewers exist: `ls .claude/agents` should list `doubter.md` and `test-auditor.md`. If it doesn't, the kit isn't fully installed in this project, and the README of sidfeels/claude-code-config has the one command that installs it.

Make the first wave a skeleton: the thinnest version of the whole path that runs for real, with each part a stub that keeps its promises. Then parts fill in something that already runs, and integration problems show up on the first day instead of the last.

The skeleton needs every part's contract settled, not its internals. One worker, or main itself, builds it and owns everything: every folder, the dependencies, the config, and the keys every part will need. That's why later waves rarely need to touch shared files. Skip the skeleton only when the project has a single part.

When the skeleton runs, show Sid what came out of it before any part is filled in: the real output, not a description of it. Ask whether this is the thing Sid meant. A wrong picture caught here costs one thin skeleton. Caught after a wave, it costs the wave.

If the folder isn't a git repository yet, run `git init` and make a first commit once `.gitignore` is in place.

## Planning a wave

For each part in the wave, write `.kit/specs/<part>.md`. The worker starts with no memory of this conversation. It has the spec, the project files, and the preamble Orca adds, which tells it how to ask and how to report. Most of what goes wrong in a wave was decided by what the spec said or left out, so write it like a handoff to a capable colleague who missed every meeting.

Three rules for the whole spec:

- Point to the files for anything they hold. Where you include text, copy it word for word, because a reworded contract is a different contract.
- Mark anything that is your guess as a guess. A worker can't tell your assumption from a decision.
- Keep it to about a page. A worker skims a long spec the way Sid skims a long reply.

The spec covers:

- **Goal:** what the part is for, and why it matters to the whole.
- **Read first:** architecture.md whole, then this part's entry and the entries of the parts it depends on; the entries in decisions.md that name this part; docs/<part>.md if it exists.
- **Done when:** the part's "Works when" examples, copied word for word. Each one has to run for real, with its command and output saved. Add any other proof the part needs: a real run where it touches real systems, tests where it's pure logic. Say whether a failing command means the work failed or is the thing to capture.
- **Not in scope:** what to leave alone even if it looks useful: other parts, extra options, tidying code the worker doesn't own. Whatever a worker adds that nobody asked for is debt.
- **Concerns:** Sid's worries and hunches about this part (sid.md, under "Still matters"), and what the people it's for care about (architecture.md, "From the outside"). Ask the worker to say in its report how it handled each one.
- **Owned folders.** Shared files belong to main: architecture.md, decisions.md, sid.md, dependency files, config, and anything two parts touch.
- **Rules,** each with its reason:
  - Load the `tests` skill before writing or changing any test, because "it's a small change" is the usual reason a test can't fail.
  - Don't commit, and don't run git commands that change the working tree or index (stash, checkout, reset, restore, clean, add). Other workers' uncommitted work lives in the same folder, and those commands can erase it.
  - Don't install, remove or upgrade packages; ask main. Lockfiles are shared, and one worker's install can undo another's.
  - Write real-run output under `.kit/runs/<part>/`, so two workers' runs never mix.
  - Don't edit files you don't own. If you need a change in one, ask main.
  - Ask main when the spec and the files don't answer something and a wrong guess would change the contract, a "Works when" example or another part, or would spend money or quota. Use `orca orchestration ask --question "<plain words>"`, carry on with work that doesn't depend on the answer, then end your turn; Orca wakes you with it. Decide anything smaller yourself and list it in your report. Never wait on Sid directly.
  - After you report, if Sid asks you for a change, send main a status covering four things: what changed, why (in Sid's words), whether your contract changed, and which proofs you reran.
- **Report:** write the full report to `.kit/reports/<part>.md`, and give that path in your short message to main (`worker_done` takes `--report-path`), so the detail survives the handoff. The report says:
  - what was built;
  - for each "Works when" example, the command you ran and where its output is;
  - everything faked, stubbed, skipped or hard-coded, however small. This is where debt hides, and main can only record what it's told;
  - every decision you made alone, with why;
  - how you handled each concern;
  - anything that changes the contract or touches another part;
  - what you're unsure of, and how far you checked each claim.
- **Main's address:** its Orca handle.

Parts that would edit the same files either go in different waves or become one part.

## Launching

**Orca.** Start one supervised worker per part, all in this folder:

```
orca orchestration worker-start --environment local --spec-file .kit/specs/<part>.md --task-title "Build: <part>" --worktree current --keep-open --agent claude
```

`--environment local` keeps the worker on this machine even when a paired server is selected. Use `--keep-open`. Without it, a worker closes two minutes after reporting, and Sid can't review it.

Start at most about four workers at once, and start the rest as those report. That limit comes from Orca's own guide, which also shows how to start a group from one shell command (`orca skills get orchestration --reference references/parallel-start.md`).

If `worker-start` fails, don't run it again, because a second start can leave two workers on one part. Do only what the CLI prints.

Record each worker's dispatch id from the receipt in `.kit/sessions.md`, together with the Run id. You need these to release a worker, to message it, and to find everything again if main's tab is lost.

Name each worker's tab "Build: <part>":
- terminals: `orca terminal rename`;
- chats: `orca chat rename`.

Workers launch on Orca's selected account. If that isn't this session's account, tell Sid before you launch (the `kit` skill's orca.md, under Accounts). When Sid wants the workers on the other account, the only way is to change Orca's selected account first, so say what else that changes.

**Elsewhere.** Use background subagents, one per part, each with the spec as its prompt.

A separate worktree (`--worktree new-child`, or `isolation: "worktree"`) is only for a throwaway experiment. Worktrees start from the last commit, can't see each other's work, and are never merged back by Orca.

## While it runs

- **Wait for messages without polling.** In Orca, end your turn, and the next message wakes you. Inside a `/goal` run, wait with `orca orchestration check --wait --timeout-ms 540000`.
- **Answer questions with `orca orchestration reply --id <message id> --body-file <file>`.** Answer from the files and this conversation. When the question is Sid's call, put it to Sid the way the global CLAUDE.md says: every option with what it leads to and costs, and no lean.
- **Pass a note to a worker with `orca orchestration send --to dispatch:<id> --subject "<topic>" --body-file <file>`.** The subject is required.
- **Don't edit folders a worker owns.**
- **Read the "stopped without reporting" alert by context.** When Sid starts chatting with a worker mid-task, Orca sends main this alert once; that's Sid steering. When Sid is away, the same alert means the worker is stuck. Read it with `orca orchestration worker-read --dispatch <id>` and help it.

`orca skills get orchestration` prints Orca's full guide for anything not covered here.

## When a worker reports

1. Read the full report file, not just the message, and check how far each claim was proven. A claim with no evidence is unchecked.
2. Record it for the worker. Update the part's architecture.md entry: what changed, and its Status line. Write "ran for real" only if the report shows the command and its output, or you reran it.
3. Write everything the report lists as faked, skipped or hard-coded on the part's Limits line, so nobody later mistakes a stand-in for the real thing.
4. Log each decision the worker made alone in decisions.md, as "Decided by: agent".
5. Note anything that affects other parts.

## End of a wave

1. Run the whole thing end to end, for real.
2. Commit a checkpoint, "wave N: <parts>". Any part can then be compared against it, or rolled back on its own, later.
3. Review the wave with fresh eyes:
   - Give the `doubter` agent the riskiest part's code and contract, not your opinion.
   - Run the `test-auditor` agent on this wave's tests.

   Both work on the committed checkpoint. Fix what holds up, and commit again.

Then show Sid what the wave produced: each part's "Works when" examples as they ran, with their output. Sid can judge output, and shouldn't have to judge code. Ask whether it's what Sid meant.

Then tell Sid, in five lines or fewer:
- what's built, how far each part is proven, and what's still a stand-in;
- what needs Sid's eyes;
- which worker tabs are open for review.

## Review

Sid reviews one part at a time, in the worker's tab. For each change, the worker sends main the four-part status. Then:

1. Update the files.
2. If the contract changed, send the change to any worker still running on a part that uses this one, and rerun the proofs of every part whose "Depends on" names it.
3. Commit "review: <part>: <change>", so each accepted change stays separable.

When Sid is happy with a part, release its worker (`orca orchestration worker-release --dispatch <id>`) and close the tab.

Fixing an old part works the same way. First reproduce the failure for real. If the design was wrong, the part goes back to discussion. If the build was wrong, the fix is a new wave of one.
