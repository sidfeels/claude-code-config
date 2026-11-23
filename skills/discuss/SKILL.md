---
name: discuss
description: Work through a design, a part or a whole project with Sid until it's settled and written down. Use for /discuss, "let's discuss", "grill me", or when a plan has open decisions that are Sid's to make.
argument-hint: "[part or topic]"
---

# Discuss

Discussion is where a project's quality is decided, and where most of Sid's attention goes. The aim is a design that Sid understands and agrees with, written into the project files. Every decision that is Sid's should be made by Sid, and nothing should be silently assumed.

Two failures to guard against:

- **Decisions outrun understanding.** Sid approves a set of rules and two days later has the basic design wrong.
- **The session's context rots.** It fills up with detail until it stops working well.

## Before the first question

Read these first:

- architecture.md, and docs/ for the parts in question;
- the entries in decisions.md for the parts in question (search for each part's name), so you don't propose what was already tried or turned down;
- sid.md.

If the project has no files yet, load the `kit` skill and create them from its templates as soon as there is something to write.

Map the topic as a design tree: each decision, and the decisions that hang on it.

Then do the expert's pass yourself before asking Sid anything. Ask what someone who has built this many times would:

- settle first;
- worry about first;
- refuse to do.

Look for the risk nobody has named yet. If Sid has raised hunches, in this conversation or in sid.md, follow each one to the class of problem it points at.

If a question's answer is a finding (a measurement, an experiment, a red-team result), write down three things: the claim, the result that would prove it wrong, and the cheapest run that could produce that result. That run usually comes first, before anything is built around the claim.

If there is a clearly more ambitious version of what Sid is asking for, name it once.

## Sorting

Every open point is one of three kinds, and only one kind reaches Sid.

| Kind | Examples | What you do |
|---|---|---|
| Facts | How a library behaves, what the code does, what an API allows | Find them yourself. Send a subagent so you don't block, and keep asking the questions that don't depend on its answer. |
| Technical calls Sid wouldn't have a feel for | Library choice, file layout, retry policy | Make them and write each one down with why. List them for Sid, one line each, so Sid can veto. |
| Sid's calls | Goals, taste, scope, trade-offs Sid will live with | Ask Sid. |

## Asking

Ask in rounds. A round holds the questions that can be answered now, without guessing the answers to other open questions. That is usually two to four. For each question give:

- the question in plain words;
- the options, each with what it leads to, what it costs, and when Sid would regret it.

Give no lean and mark no favourite, in the wording or in the order, because Sid tends to take whatever is recommended. Don't word a question so that "yes" picks an option. If Sid asks what you'd pick, say it then, with the strongest case against it. Ask in prose rather than with a picker. Sid usually types their own answer, and the answer is often a third option.

When Sid answers with a hunch or a worry instead of a choice, treat it as the most useful thing in the round. Say what you think it points at, follow it further, and fold it into the tree.

A quick "yes" settles what's cheap to undo. A choice that's costly to undo gets asked alone, in a form "yes" can't answer.

When Sid asks for an expert's view, or when your options all look alike, use the `expert` skill. Don't answer from this session's view, which is already anchored on what it proposed.

## What working looks like

Before a part counts as settled, get two or three examples of it working, in Sid's words: given this, this comes out. They show fastest whether you and Sid picture the same thing, and they become what the build has to show running for real. Write them on the part's "Works when" line in architecture.md.

Ask Sid for them first. If Sid wants a start, offer several to choose from and correct, so the answer can't be a plain yes.

What an example looks like depends on the project:

- a website: "someone who isn't signed in opens the dashboard and lands on the login page";
- a data pipeline: "a row with no label is dropped, and the number of dropped rows is reported";
- a CI pipeline: "a pull request with a failing test can't be merged";
- a training run: "after one epoch on the small split, validation loss is below the baseline's";
- a paper implementation: "the number in Table 2 comes out within the margin the paper reports".

## Writing as you go

Write each point down as soon as it settles, not at the end:

- Decisions go in decisions.md, in the same edit as the change to architecture.md, with the real reason and who decided.
- Sid's thoughts and worries go in sid.md, in Sid's own words, quoted from the message while you still have it.
- Anything left open goes in architecture.md, under Open questions.

Sid should be able to close this session at any moment without losing anything.

If a part turns out to need its own deep discussion, propose a spinoff with the `spinoff` skill instead of going deep here. The main session should hold the whole picture, not every detail.

## Done

The discussion is done when both of these are true:

- every branch of the tree is settled, or explicitly parked in Open;
- every part that will be built has its "Works when" examples;
- Sid has confirmed the whole thing in five sentences.

Write those five sentences in plain words. For the project they go in architecture.md, under "How it fits together". For a part they go in the part's "What it does". Ask Sid to say back anything that doesn't match their picture. Sid restating it in their own words is the real check; a "yes" to your words is a weaker one.

Then say in one line what's ready next: a spinoff, a build, or more discussion.
