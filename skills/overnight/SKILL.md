---
name: overnight
description: Set up and run unattended work while Sid is away. Writes a plan with a finish line and a budget, makes decisions by rule instead of waiting, parks the choices that matter for the morning, and ends with a morning report. Started only by Sid with /overnight.
argument-hint: "<what should be done by morning>"
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: AskUserQuestion
      hooks:
        - type: command
          command: '"${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/overnight/away.sh" ask'
  PermissionRequest:
    - matcher: "*"
      hooks:
        - type: command
          command: '"${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/overnight/away.sh" permission'
---

# Overnight

While Sid sleeps, two things waste the night. A session that stops to ask a question or wait for an approval wastes it by waiting. A session that guesses through every decision can waste it just as badly, by building six hours of work on a wrong choice. Overnight work runs on one rule: decide alone only what is yours to decide and cheap to get wrong, and park the rest while you work around it.

## Setting up (Sid is still here)

1. **Read the project.** Read architecture.md and sid.md, and check that what Sid wants by morning is settled enough to build. If it isn't, say so now, because discussion can't happen overnight.

2. **Create a work branch.** Make `overnight/<date>` so the night's commits stay separate.

3. **Write the plan.** Create `.kit/overnight.md` with these sections:
   - `Status: running` on the first line. This turns on the guard hooks (see below).
   - **Goal:** what done means by morning, in a form you can check.
   - **Budget:** the most the night may spend, in money or in model calls, and which keys it uses. Sid confirms this number.
   - **Plan:** ordered items. Mark the ones that don't depend on each other. Those are what you switch to when something gets parked.
   - **Off limits.** These are always off limits, plus anything else this project needs ruled out:
     - pushing to main or any shared branch;
     - deploying;
     - messaging people;
     - deleting data that can't be regenerated;
     - spending beyond the budget;
     - changing anything outside this project.
   - **Decided overnight**, **Parked**, and **Morning report**, each empty for now.

4. **Make sure nothing will need approval.**
   - List the commands the plan will run, and check that none of them will prompt. Orca-launched agents and workers skip prompts by default. A tab Sid opened with `claude`, or a plain terminal, uses its own permission mode. There, either add the commands to the project's `permissions.allow`, or ask Sid to restart in auto mode before leaving. On the work account, check that `orca` is in `sandbox.excludedCommands`.
   - Read `autoContinueAtUsageLimit` in the user settings. If it's off, tell Sid that a usage limit will end the night early.

   The guard is the backstop: it turns any prompt that still appears into a denial with instructions, so the work around it continues.

5. **Hand over.** Show Sid the plan and the budget in ten lines or fewer. Then give them this line to paste, and tell them they can go:
   ```
   /goal The assistant has posted a message starting "Morning report" after finishing or parking every item in .kit/overnight.md, or 150 turns have passed.
   ```
   Only Sid can start `/goal`. It keeps the session working between turns until the condition holds.

## The guard

This skill registers two hooks for the rest of the session. While the first line of `.kit/overnight.md` is `Status: running`, they work like this:
- An AskUserQuestion call is denied, and you're told to apply the decision rule.
- A permission prompt is denied, and you're told to find another way or park the item.

Plain-text questions to Sid still work, during setup and in the morning.

The hooks only cover this session. Workers you start need the same rules in their spec, so add this to every spec written tonight:

> Sid is away. Never wait on Sid or use AskUserQuestion. Ask main (`orca orchestration ask`) and continue with work that doesn't depend on the answer.

## The decision rule

For each choice, ask two questions in order.

**First, whose call is it?** Some choices are Sid's even when little rides on them: a goal, a matter of taste, or what a result means, such as how a score is aggregated or what counts as a pass. Park those. Then build so that every option stays open: store the raw data, compute each candidate, and mark any number that depends on the choice as provisional.

**Second, how much of tonight's remaining work rides on it?**
- **Little.** Decide. Use the project's stated goals and Sid's past choices (architecture.md, decisions.md, sid.md). Among options of equal merit, pick the one that is easiest to change later. Log the decision under **Decided overnight**, with the alternative and how to reverse it.
- **Much**, meaning most of what follows would be built on top of it. Park it. Under **Parked**, write the question, the options with what each leads to, and your lean with the case against it. Add the question to architecture.md, under Open questions. Then switch to plan items that don't depend on it.
- **If everything left is parked,** finish early. A short night with the right questions waiting beats a long one built on a guess.

Reversibility is not the test. A wrong guess at 11pm can be undone in one git command, and the night is still lost if everything after it was built on top.

The usual standards still hold, and matter more with nobody watching: prove each change, running it for real where you can, and commit checkpoints on the work branch.

Build waves can run overnight, using the `build` skill. Main answers workers' questions with this same rule. A "stopped without reporting" alert at night means a stuck worker, not Sid. Read it and help.

## Morning report

The night can end at a usage limit or at the turn bound, so keep the report current as you go. After each plan item, rewrite the draft **Morning report** in `.kit/overnight.md`. It covers:
- what got done, and how far each part is proven;
- what was decided overnight, and how to reverse each decision;
- what's parked, written as questions Sid can answer quickly;
- what broke or is unfinished;
- what Sid should look at first.

When the plan is finished or blocked, post the report as a message starting "Morning report". Then:
1. Copy each **Decided overnight** entry into decisions.md as its own entry, with "Decided by: agent" and a Why line that starts "Decided overnight while Sid was away." `.kit/` is scratch, and these entries have to outlive it.
2. Update architecture.md, as for any save.
3. Change the first line of `.kit/overnight.md` to `Status: done`. This turns off the guard.

If Sid finds the guard still on in the morning, because the night was cut off, the fix is the same: change that line to `Status: done`.
