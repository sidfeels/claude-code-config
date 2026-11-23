<!--
architecture.md: the project as it stands today: what we're building, how it works, how far each part has got, and what's still open. Every session reads it first. How it got this way goes in decisions.md.

Rules for whoever edits this file:

1. It reads as if written today, in one sitting. When something changes, replace the old sentence and log the change in decisions.md. "Now", "previously", "updated" and "no longer" are signs that history leaked in.
2. A line belongs if changing it would change results, cost, speed or risk: which model or service does which job, a prompt trick, a training setting, a cache or retry rule, how many runs go in parallel. A line doesn't belong if tidying the code would make it false: function names, file layout, what was edited.
3. Every choice carries its reason in a few words, so a later session can tell when the reason has stopped being true. When it has, raise it instead of building on it. A reason can name what failed ("rank 32, because rank 8 underfit"). The story of trying it goes in decisions.md.
4. Claim only what you saw. "Ran for real" is written by the session that ran it or read the output. A report that only says "it passed" isn't enough. For an experiment, "ran for real" means the result came out again from its recorded command, and a negative result is still a result.
5. Change only what your change touches: your own part's entry and its open questions, and in them only the sentences that changed. Rewording the rest shifts its meaning a little each time. Changes to another part or to the other shared sections go to main.
6. One name per thing, the same in every file and in the code. A value that lives in a config or prompt file is pointed to, not copied, so there's one place to change it.
7. No praise words (robust, secure, scalable) without the check that shows it.
8. When this file and the running system disagree, work out which one is wrong, fix that one, and tell Sid.
9. Plain sentences first, technical detail after, so Sid can follow every part. A part takes about fifteen lines. Depth goes in docs/<part>.md.
10. The part layout below is a starting shape, not a form to fill in. It suits a system made of parts that hand work to each other. Fit it to the project: add a line the project needs, or drop Promises where nothing else relies on the part. Six lines stay in every part, under these names, because later sessions and the skills look for them: What it does, Works when, Choices that matter, Limits, Depends on, Status. When one of them has nothing to say, write "none known" instead of padding it. Once the project has its shape, every part uses it.
11. An open question lives only under "Open questions", tagged with its part. When it's decided, it leaves that list and the decision gets an entry in decisions.md.
-->

# <Project name>

## What we're building and why

<Two or three sentences: the thing, the problem it solves, and what success looks like.>

## From the outside

<One short paragraph for each kind of person or thing that touches the system from outside, and only the ones that exist: who asked for it, who runs it, who uses it, who reads its results, a model under test, an attacker. For each: what they want from it, written the way they would say it, because their wants are requirements. Then what they do, what they get back, and what they can see and change.>

## How it fits together

<Up to five plain sentences a newcomer could follow: the path a run, a request or a piece of data takes through the parts, in order. Add a small diagram only if the sentences aren't enough. If they disagree, the sentences win.>

Confirmed by Sid: <the date Sid said these back in their own words, or "not yet">

## Open questions

<Everything undecided, and what each one is waiting for.>

- [<part>] <question> (needs: Sid | a fact | a run)

## <Part>

<Parts appear in the order a run passes through them.>

What it does: <up to five plain sentences; for a settled part, these are the five Sid confirmed. For an experiment, the question it answers.>

Works when: <two or three examples in Sid's words: given this, this comes out. The build has to show each one running for real. For an experiment: the result that would count as an answer, and the one that would prove the claim wrong.>

Choices that matter:
- <choice>, because <reason>. <Where the exact value lives, if it lives in a file.>

Promises: <what other parts and people can rely on: what goes in, what comes out, what always holds.>

Limits: <what it deliberately doesn't do, where its output shouldn't be trusted, and anything that is a stand-in: faked, skipped or hard-coded.>

Depends on: <other parts, models, services, keys, quotas, data.>

Status: <discussing | settled, not built | building | built, not run for real | ran for real on <date>: <the command or check, and what it showed>. If a built part has a settled change that isn't built yet, say what the running version still does.>

More: <docs/<part>.md, if it exists>

## Shared across parts

<Every key, quota, budget, config file, model or data store that more than one part uses. Collisions between parts hide here, because no single part's entry shows them.>

- <resource>: used by <parts>; limit <limit>; when it runs out, <what happens>

## When something changes

<Ripples that the Depends on lines don't make obvious.>

- If <X> changes, also <Y>, because <Z>.
