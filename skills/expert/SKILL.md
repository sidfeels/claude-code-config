---
name: expert
description: Get independent views on a design question from fresh expert subagents, without this session's bias, and have them debate when they disagree. Use for /expert, "how would an expert do this", "council", "debate", "second opinion", or when the options on the table all look alike.
argument-hint: "<question>"
---

# Expert

Sid often asks how someone who really knows a field would approach a problem. This session can't answer that well. It has already proposed things, and it will tend to defend them.

Three things help:

- A fresh mind that never saw our lean gives an independent view.
- Several minds with different expertise show where the real disagreements are.
- Making two of them argue it out separates the real crux from talk past each other.

## 1. Brief without the lean

Write `.kit/expert/<topic>/brief.md`. It holds:

- the goal;
- the constraints that are real: budget, time, what already exists;
- what Sid and the people it's for care about (architecture.md "From the outside", sid.md);
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

Run them on different Claude models through the Agent tool's model setting: for example `opus` for one lens and `sonnet` or `fable` for another. They share a family, so they also share some blind spots, but they differ enough to catch some of each other's.

## 3b. Debate, when they disagree on the crux

If the first round splits on the decision that matters, or Sid says "council" or "debate", make the two strongest opposing views argue it out.

1. Give each side the other side's report. Continue its agent with SendMessage so it keeps its own reasoning, or, if that agent is gone, start a fresh `expert` agent with both reports. Ask it to answer in a new file, `.kit/expert/<topic>/<lens>-reply.md`:
   - where the other side is right;
   - where it's wrong, with evidence;
   - what would change its own mind.
2. Stop after two rounds. A debate that hasn't converged by then won't. What's left is the crux, and that's Sid's to decide.

This uses plain subagents that exchange files, not Claude Agent Teams. Teams are experimental and die with the session that started them, while files keep the whole argument for Sid to read.

## 4. Synthesize honestly

Read every report in full. Then tell Sid, briefly:

- Where they agree. That's probably the common view, which isn't the same as right, because Claude models share blind spots.
- What the debate settled, and the crux it couldn't.
- Where they disagree. That's the real decision, so put it to Sid as options, with what each leads to and your lean last, with the case against it.
- What none of them raised that Sid's hunches point at.
- How our current plan compares. If it loses, say so plainly.

Put the paths to the full reports at the end.
