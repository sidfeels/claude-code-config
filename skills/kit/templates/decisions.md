<!--
decisions.md: how the design got this way. One entry per decision, oldest first, new ones added at the bottom. architecture.md says what is true today; this file never does.

Before proposing a change to a part, search this file for the part's name. The option may already have been tried or turned down.

Rules for whoever edits this file:

1. Add an entry when one of four things happens: a line in architecture.md is written or replaced; the goal or who it's for changes; an option someone could suggest again is turned down; something we relied on turns out to be wrong. Nothing else gets an entry. Code changes are in git.
2. Write the entry when the decision is made, in the same edit as the change to architecture.md. An entry rebuilt from memory at the end of a session gets the reason wrong.
3. Never rewrite, merge, tidy or delete an old entry. A reversal is a new entry.
4. Write the real reason, even a weak one: "Sid preferred it", "it was the first thing that worked", "no time to compare". Say what it rests on: a run (point to it), an argument, or a preference. A good-sounding reason made up afterwards is worse than a weak one, because later sessions will trust it.
5. Say exactly who decided. "Sid": Sid chose it or said it. "agent, Sid agreed": the agent proposed it and Sid said yes, which is weaker than Sid choosing. "agent": Sid wasn't asked. Only a session that heard Sid writes the first two. Sid wondering about something is not a decision; it goes in sid.md.
6. Say plainly what was wrong with the old way. "Improved", "refined" and "enhanced" hide it. No praise for anyone's idea.
7. Each entry makes sense alone, a month later, to someone who wasn't in the conversation: full dates, the names architecture.md uses, no "as discussed" or "the new approach".
8. Before reversing a decision, read its entry and say what is new since then: evidence, or a changed goal. If nothing is new, show Sid the old reason and let Sid choose.
-->

# Decisions

## <date>, project: starting design

<The first idea in a few sentences: what we set out to build, how we first pictured it working, and why.>

- Decided by: <Sid | agent, Sid agreed | agent>

## <date>, <part>: <the change in a few words>

- Was: <the sentence this replaced, copied from architecture.md. "Nothing" for a new choice.>
- Now: <the sentence that replaced it.>
- Why: <the real reason, and what it rests on.>
- Turned down: <the options that lost, each with why. Leave the line out if there were none.>
- Decided by: <Sid | agent, Sid agreed | agent>
- Reopen if: <something specific we could check that would make this worth another look. Leave the line out if there isn't one.>

## <date>, <part>: turned down, <the option>

- Why: <the real reason, and what it rests on.>
- Decided by: <Sid | agent, Sid agreed | agent>

## <date>, <part>: found wrong, <what>

- We relied on: <what we believed.>
- What's true: <what we found, and how we know.>
- In doubt: <the results, runs and choices from before this date that depended on it.>
