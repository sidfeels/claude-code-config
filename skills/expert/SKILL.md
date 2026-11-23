---
name: expert
description: Get independent views on a design question from fresh expert subagents, and optionally from other model families, without this session's bias. Use for /expert, "how would an expert do this", "council", "second opinion", or when the options on the table all look alike.
argument-hint: "<question>"
---

# Expert

Sid often asks how someone who really knows a field would approach a problem. This session can't answer that well. It has already proposed things, and it will tend to defend them.

Three things help:

- A fresh mind that never saw our lean gives an independent view.
- Several minds with different expertise show where the real disagreements are.
- A different model family has blind spots that don't line up with ours.

## 1. Brief without the lean

Write `.kit/expert/<topic>/brief.md`. It holds:

- the goal;
- the constraints that are real: budget, time, what already exists;
- what Sid and the people it's for care about (blueprint.md "Who it's for", sid.md);
- the question.

Leave out our current plan and our preference.

If the question is really "is our plan right?", that's a review, not an expert question. Send the plan and the contract it must meet to the `doubter` agent instead.

## 2. Pick the lenses from the problem

Choose two or three experts whose views would genuinely differ on this question. Derive them from the problem, not from a fixed list, by asking:

- Who has built the closest real thing?
- Who would have to run or maintain it?
- Who would try to break or abuse it?
- Who would doubt the measurement?
- Who pays if it's wrong?

Name each lens in one line, with what that expert would care about.

## 3. Run them in parallel

Launch one `expert` agent per lens, in the background. Give each:

- the path to the brief;
- its lens;
- where to write: `.kit/expert/<topic>/<lens>.md`.

They reason first and check precedent second.

Sid may say "council", meaning views from other model families. Give each model the same brief:

- **T3 Code:** call `orchestrator_capabilities` to see what's available, then `delegate_task` once per model.
- **A terminal:** pipe the brief from a file into a CLI. Before sending the real brief, check that the CLI answers a one-line prompt.

  ```
  codex exec -m gpt-6-luna -s read-only --skip-git-repo-check - < .kit/expert/<topic>/brief.md
  opencode run -m <provider/model> -f .kit/expert/<topic>/brief.md "Answer the brief in the attached file."
  ```

  Codex's default model is refused on Sid's login, so name `gpt-6-luna`. Keep the run read-only, because the job is an opinion, not edits.

If a model is unavailable, say so instead of substituting another.

## 4. Synthesize honestly

Read every report in full. Then tell Sid, briefly:

- Where they agree. That's probably the common view, which isn't the same as right. Say whether only Claude models agreed, since they share blind spots.
- Where they disagree. That's the real decision, so put it to Sid as options, with what each leads to and your lean last, with the case against it.
- What none of them raised that Sid's hunches point at.
- How our current plan compares. If it loses, say so plainly.

Put the paths to the full reports at the end.
