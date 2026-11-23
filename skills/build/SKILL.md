---
name: build
description: Build settled parts in parallel with workers that report to this main session, then integrate, prove the whole thing end to end, and commit a checkpoint. Use for /build, "start building", or a build wave once parts in blueprint.md are settled.
argument-hint: "[parts]"
---

# Build

Parallel building is fast, and it goes wrong in three ways:

- Workers build on assumptions that were never settled.
- Their work drifts apart, or collides in the folder they share.
- Sid's attention gets spread across many tabs.

The answers are to build only what's settled, to give every worker a contract and folders it owns, and to keep main as the one place that integrates, records and reports.

## Before the first wave

Build only parts marked settled in blueprint.md. A part that is still being discussed will be rebuilt.

Make the first wave a skeleton: the thinnest version of the whole path that runs for real, with each part a stub that keeps its promises. Then parts fill in something that already runs, and integration problems show up on the first day instead of the last.

The skeleton needs every part's contract settled, not its internals. One worker, or main itself, builds it and owns everything: every folder, the dependencies, the config, and the keys every part will need. That's why later waves rarely need to touch shared files. Skip the skeleton only when the project has a single part.

If the folder isn't a git repository yet, run `git init` and make a first commit once `.gitignore` is in place.

## Planning a wave

For each part in the wave, write `.kit/specs/<part>.md` covering:

- **Goal:** what the part is for, and why it matters to the whole.
- **Contract:** from architecture.md, what it promises and what it depends on.
- **Concerns:** Sid's worries and hunches about this part (sid.md), and what the people it's for care about (blueprint.md). Ask the worker to say in its report how it handled each one.
- **Owned folders.** Shared files belong to main: blueprint.md, architecture.md, sid.md, dependency files, config, and anything two parts touch.
- **Proof expected:** the most direct evidence the part works. Use a real run where the part touches real systems, and tests where it's pure logic.
- **Rules,** each with its reason:
  - Load the `tests` skill before writing or changing any test, because "it's a small change" is the usual reason a test can't fail.
  - Don't commit, and don't run git commands that change the working tree or index (stash, checkout, reset, restore, clean, add). Other workers' uncommitted work lives in the same folder, and those commands can erase it.
  - Don't install, remove or upgrade packages; ask main. Lockfiles are shared, and one worker's install can undo another's.
  - Write real-run output under `.kit/runs/<part>/`, so two workers' runs never mix.
  - Don't edit files you don't own. If you need a change in one, ask main.
  - When you need a decision, ask main (`orca orchestration ask`, or a message to main's T3 thread) and carry on with work that doesn't depend on it. Never wait on Sid directly.
  - Report how far you checked each claim.
  - After you report, if Sid asks you for a change, send main a status covering four things: what changed, why (in Sid's words), whether your contract changed, and which proofs you reran.
- **Main's address:** its Orca handle or T3 thread id.

Parts that would edit the same files either go in different waves or become one part.

## Launching

**Orca.** Start one supervised worker per part, all in this folder:

```
orca orchestration worker-start --spec-file .kit/specs/<part>.md --task-title "Build: <part>" --worktree current --keep-open --agent claude
```

Use `--keep-open`. Without it, a worker closes two minutes after reporting, and Sid can't review it.

Record each worker's dispatch id from the receipt in blueprint.md Sessions, together with the Run id. You need these to release a worker, to message it, and to find everything again if main's tab is lost.

Name each worker's tab "Build: <part>":
- terminals: `orca terminal rename`;
- chats: `orca chat rename`.

Workers launch on Orca's selected account. If that isn't this session's account, tell Sid before you launch (the `kit` skill's orca.md, under Accounts).

**T3.** Call `delegate_task` once per part, with the spec as the task, `isolation: "shared"` and role `implementation`. Record each task id in Sessions.

**Elsewhere.** Use background subagents, one per part, each with the spec as its prompt.

A separate worktree (`--worktree new-child`, or `isolation: "worktree"`) is only for a throwaway experiment. Worktrees start from the last commit, can't see each other's work, and are never merged back by Orca.

## While it runs

- **Wait for messages without polling.** In Orca, end your turn, and the next message wakes you. Inside a `/goal` run, wait with `orca orchestration check --wait --timeout-ms 540000`.
- **Answer questions with `orca orchestration reply --id <message id> --body-file <file>`.** Answer from the files and this conversation, and ask Sid only about Sid's calls.
- **Pass a note to a worker with `orca orchestration send --to dispatch:<id> --body-file <file>`.**
- **Don't edit folders a worker owns.**
- **Read the "stopped without reporting" alert by context.** When Sid starts chatting with a worker mid-task, Orca sends main this alert once; that's Sid steering. When Sid is away, the same alert means the worker is stuck. Read it with `orca orchestration worker-read` and help it.

`orca skills get orchestration` prints Orca's full guide for anything not covered here.

## When a worker reports

1. Read the report and check how far each claim was proven. A claim with no evidence is unchecked.
2. Record it for the worker. Update the part's line in blueprint Parts, and its architecture.md entry: what changed, and "Proved by".
3. Note anything that affects other parts.

## End of a wave

1. Run the whole thing end to end, for real.
2. Commit a checkpoint, "wave N: <parts>". Any part can then be compared against it, or rolled back on its own, later.
3. Review the wave with fresh eyes:
   - Give the `doubter` agent the riskiest part's code and contract, not your opinion.
   - Run the `test-auditor` agent on this wave's tests.

   Both work on the committed checkpoint. Fix what holds up, and commit again.

Then tell Sid, in five lines or fewer:
- what's built, and how far each part is proven;
- what needs Sid's eyes;
- which worker tabs are open for review.

## Review

Sid reviews one part at a time, in the worker's tab. For each change, the worker sends main the four-part status. Then:

1. Update the files.
2. If the contract changed, send the change to any worker still running on a part that uses this one, and rerun the proofs of the parts on its "Used by" line.
3. Commit "review: <part>: <change>", so each accepted change stays separable.

When Sid is happy with a part, release its worker (`orca orchestration worker-release --dispatch <id>`) and close the tab.

Fixing an old part works the same way. First reproduce the failure for real. If the design was wrong, the part goes back to discussion. If the build was wrong, the fix is a new wave of one.
