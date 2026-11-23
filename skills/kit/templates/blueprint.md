<!--
blueprint.md: the project on one page. Every session reads this first, so keep it current and short enough to read in two minutes.
Write for Sid coming back after a week: plain sentences, no private shorthand, each term defined once.
Open questions live only here, under Open. Once one is decided, it leaves Open and gets an entry in decisions.md.
Update it when something settles, not at the end. A decision that isn't written down didn't happen.
-->

# <Project name>

## What we're building and why

<Two or three sentences: the thing, the problem it solves, and what success looks like.>

## Who it's for

<Who asked for it, who will use it, and what each of them cares about most. Their concerns are requirements, so write them the way they would say them.>

## The whole thing in five sentences

<Five plain sentences a newcomer could follow. Sid confirms them in their own words once the design settles.>

Confirmed by Sid: <date, or "not yet">

## Parts

<Status is one of: idea, discussing, settled, building, built, proven. "Proven" means it ran for real, and the proof is recorded in architecture.md.
A part can be an experiment, whose output is a finding rather than code. For an experiment, "proven" means the result reproduced from its recorded command. A negative result is still a result.>

| Part | What it does | Status | Being worked on in |
|---|---|---|---|
| | | | |

## Open

<Every unresolved question in the project, tagged with its part and with what it needs to be resolved.>

- [<part>] <question> (needs: Sid | a fact | a run)

## Sessions

<The sessions working on this project right now, with their addresses, so a main session that was closed or compacted can find them again. Remove a session's line when it saves and closes.>

Run: <Orca run id, once workers exist>

- <tab or thread name> | <address: Orca terminal handle, dispatch:<id>, or T3 thread id> | <what it's doing> | started <date>
