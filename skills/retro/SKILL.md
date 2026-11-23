---
name: retro
description: Look back at recent sessions, find what cost Sid time or attention, and fix each cause where it lives (the code, a check, a project file, or this kit). Started only by Sid with /retro.
argument-hint: "[project, sessions or date range]"
disable-model-invocation: true
---

# Retro

The kit and each project should get better from real friction, and they should get shorter as often as they get longer. Most friction repeats: the same correction, the same misunderstanding, the same kind of "done" that wasn't done. A retro finds the repeats, traces each one to its cause, and fixes the cause in the strongest place available. The goal is for the problem not to happen again, rather than for someone to remember it next time.

## Sources

- **Session transcripts.** They are the `*.jsonl` files in `<config folder>/projects/<folder>/`, where the folder name is the project path with each `/` and `.` turned into `-`. List the folders and match on the project's name rather than constructing the name. Look in both accounts, `~/.claude` and `~/.claude-personal`. Orca tabs on either account write to `~/.claude/projects`.

  Each line is one JSON object. Sid's messages are the `"type":"user"` entries whose content is text Sid typed. Exclude these, which also appear as user entries: tool results, `isMeta` entries, skill bodies, Orca wake-ups ("You have N orchestration messages…"), and a session's first prompt when it's a brief or a spec.
- **The project files:**
  - decisions.md, where every reversal and every "found wrong" entry is a lesson;
  - Open items that sat there a long time;
  - worries in sid.md that came true.
- **History.** `git log`, and any PR review comments (`gh`).

Transcripts are large, so never read them whole in this session. Hand them to subagents, a few sessions each, along with the signals below. Each subagent writes its moments, with exact quotes, to `.kit/retro/<date>/<batch>.md`.

Security work can trip a safety filter and stop a subagent. If that happens, note it and move on. Don't retry.

## What to notice

Each signal below marks a place where something cost Sid. Find the moment, quote it, and ask what was missing that would have prevented it.

| Signal | What it usually means |
|---|---|
| Sid corrected you or re-explained something. | Whatever should have carried that knowledge (a file, a brief, an instruction) didn't, or it was ignored. |
| Sid typed a different answer instead of picking an option, or picked one and later reversed it. | The options were badly framed, or the lean was wrong. |
| Sid raised a hunch or a worry, and the reply answered only the literal question. | The hunch wasn't followed to the class of problem it pointed at. |
| Sid asked for it shorter or simpler, or asked the same question twice. | The writing failed: too long, too abstract, or it answered something else. |
| Something reported as done failed later. | The claim was not checked far enough. |
| A decision was reversed. | Ask what we didn't know then, and what cheap step would have told us earlier: a real run, a lookup, an expert view. |
| Sid reminded you of something that was already in the files. | The pointer to it was weak, or the file was too long to read. |
| An agent went in circles: retries, long searches, the same expensive tool call again and again. | A tool, a fact, or some access was missing. |
| Two sessions or workers diverged, or work had to be redone. | The shared files were stale, or main wasn't told. |
| Something went notably well. | Keep whatever caused it, so the retro doesn't only add rules. |

Also look at the instructions themselves. A line in CLAUDE.md or a skill that never changed what any session did is a no-op, and deleting it counts as a fix.

## Where the fix lives

For each moment, name the root cause, not the symptom. Then put the fix in the strongest place that can hold it, in this order:

1. **The code or structure**, so the mistake can't happen at all: a type, a single source of truth, a config value instead of a constant.
2. **A check** that catches it: a test, a lint rule, or a hook. Only a hook guarantees a step happens.
3. **A project file**: a missing decision, a better pointer in CLAUDE.md, or an entry under "When something changes".
4. **The kit**: a skill, or the global CLAUDE.md. Deleting or sharpening a line beats adding one.

An instruction is the weakest fix. Use one only when nothing above can hold the lesson, and say what failure it prevents.

## Proposing

1. Merge moments that share a cause.
2. List the proposals with the most costly first. For each, give the quotes, the cause, the fix, and where the fix lives.
3. For every line you propose to add to an instruction, name one to delete.
4. Drop anything you can't tie to a quoted moment.

Show Sid the top five, and put the rest in the retro file. Change nothing until Sid picks.

## Applying

- Project fixes go into the project.
- Kit fixes go to the kit repo; the `kit` skill says where it is. Make each one on a branch, quote the moment in the commit message, and open a PR for Sid.
- Keep the `.kit/retro/` notes until the fixes land.
