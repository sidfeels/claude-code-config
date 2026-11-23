---
name: save
description: Put everything worth keeping from this session into the project files, or send it to main if this is a worker, then confirm the session is safe to close. Use for /save, "save", "wrap up", or before closing or clearing a session.
---

# Save

Sid keeps sessions open for fear of losing what's in them, and the tabs pile up. Saving removes that fear. Once it's done, everything a later session needs is either in the files or with main, and this session can close.

## Who writes what

What a session writes down is what later sessions build on, so the writer must have seen what it records.

- A main session, or a spinoff that talked with Sid, writes the project files directly.
- A build worker owns only its folders. Its spec names main as the owner of the shared files (architecture.md, decisions.md, sid.md). A worker writes nothing there. It puts everything in its message to main, and main records it.
- Only a session that heard Sid directly writes to sid.md, or records "Sid" as the one who decided something.

## What to keep

Go through the whole session, not just its end. Send each thing to its one home:

- Decisions go in decisions.md, one entry each, with the real reason and who decided (see its header). That covers choices made or replaced, options turned down, and things we relied on that turned out wrong.
- How things work now goes in the part's entry in architecture.md. Depth goes in docs/<part>.md.
- Sid's thoughts, worries, hunches and taste go in sid.md, in Sid's own words (see its header). Keep the ones that went nowhere too. Only Sid moves one to "Dealt with"; when you think one is answered, ask in your reply.
- A rule Sid set for this project goes in CLAUDE.md, under "Rules for this project", with its reason.
- Anything unresolved goes in architecture.md, under Open questions, tagged with the part and with who must answer.
- Measured results go in docs/<part>.md, under Results, with how to reproduce them.
- How far a part has got goes on its Status line in architecture.md.

Leave out anything the files or git already hold. Leave out the back-and-forth that led to a decision, too: the decision's "why" carries what matters.

## Check architecture.md and decisions.md

architecture.md describes the system as it is today. If you changed it, search it for words that mean history leaked in:

```
grep -inwE 'now|previously|formerly|updated|no longer|used to|anymore' architecture.md
```

The header's own rule matches; skip it. Rewrite every other hit as a plain statement of how the system works. The story of the change goes in decisions.md.

Then check the two files against each other:

- If architecture.md changed and decisions.md didn't, find the entry you owe. A change of wording alone owes none.
- Old entries in decisions.md are never rewritten. `git diff HEAD -- decisions.md | grep '^-' | grep -v '^--- a/'` should print nothing. If it prints a line, put the old entry back and add a new one instead.

## Check sid.md stays private

sid.md holds what Sid wouldn't say in public. Before anything is committed:

```
git check-ignore -q sid.md || echo "sid.md is NOT ignored"
```

If that prints, stop and add sid.md to `.gitignore` (or to `.git/info/exclude` in a repo Sid doesn't own) before doing anything else.

## Tell main

Skip this if the session is main. Otherwise, main's address is in the brief or spec.

1. Write the message to `.kit/messages/<date>-<part>.md`. Say:
   - what settled;
   - what's still open;
   - which files changed (or, for a worker, everything main should record);
   - anything that affects other parts.

   The file keeps the message safe even if main was closed when it was sent.
2. Send it:
   - **Orca:** `orca orchestration send --to <main's address> --subject "saved: <part>" --body-file .kit/messages/<file>`. A body-file sends the text as written; quoting it inline lets the shell eat backticks and `$`. On the work account the sandbox may block `orca`; if so, rerun it outside the sandbox.
   - **T3:** `t3_thread_send` to main's thread id, with mode `queue`, so it waits for main's turn instead of interrupting it.
   - **Plain terminal:** tell Sid to point main at the file.
3. If you're a spinoff, remove your line from `.kit/sessions.md`.

## Reply

At most five lines:

- what you wrote and where;
- anything you chose not to keep, and why;
- then "Safe to close."
