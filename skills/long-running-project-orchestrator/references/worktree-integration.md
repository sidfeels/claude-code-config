# Worktree Integration

Use this reference before parallel implementation with git worktrees.

## Core rule

Do not merge worker output directly to `main` unless Sid explicitly asked for that workflow. Integrate on a task branch or integration branch, verify there, then decide how to publish.

## Recommended flow

1. Start from a clean integration branch.
2. Create one worktree per independent task.
3. Pass each worker a read-only state snapshot or explicit prompt context.
4. Keep canonical `.agent/` state in the orchestrator worktree.
5. Ask workers to commit their task changes in their worktree when possible.
6. Inspect each worker diff before merging.
7. Run the task verifier in the worker worktree.
8. Merge or cherry-pick into the integration branch.
9. Run the milestone verifier on the integrated branch.
10. Update canonical `.agent/` ledgers from the orchestrator, not from worker reports alone.

## `.agent/` state and worktrees

`.agent/` may be gitignored or untracked. A new worktree may not contain it.

Options:
- Provide the relevant state directly in the worker prompt.
- Copy a read-only snapshot into the worker worktree if the runtime supports it.
- Track stable `.agent` files intentionally only if the project wants that state in git.

Do not let parallel workers update canonical `.agent/current_state.md`, `tasks.jsonl`, or `decisions.jsonl`. Concurrent state edits create conflicts and stale truth.

## Task independence check

A task is safe to parallelize when:
- file ownership is mostly disjoint
- dependencies are explicit
- verifier can run independently
- expected merge conflicts are small
- the task does not decide global architecture or product behavior

Keep local when:
- the next step is on the critical path
- the task touches shared abstractions used by other workers
- the decision needs Sid's taste or product judgment
- the failure mode is subtle enough that delegation would just add integration burden

## Merge conflict policy

Handle conflicts immediately. If conflicts reveal that two workers made incompatible architecture decisions, stop and reconcile the design instead of blindly resolving text conflicts.

When resolving:
- preserve user and unrelated worker changes
- rerun the relevant verifier after resolution
- record the conflict and decision in `.agent/decisions.jsonl` if it changed architecture or behavior

## Verification gates

Before integrating a worker branch:
- diff reviewed
- task verifier passed or gap recorded
- no unrelated cleanup drift
- no new dependency without rationale
- no protected eval/gold/judge changes unless explicitly in scope

Before completing a milestone:
- integrated verifier passed
- reviewer pass completed for meaningful changes
- blocking review findings resolved
- `.agent/current_state.md` reflects current truth
