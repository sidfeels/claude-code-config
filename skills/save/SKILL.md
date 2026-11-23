---
name: save
description: Put everything worth keeping from this session into the project files, or send it to main if this is a worker, then confirm the session is safe to close. Use for /save, "save", "wrap up", or before closing or clearing a session.
---

# Save

Sid keeps sessions open for fear of losing what's in them, and the tabs pile up. Saving removes that fear. Once it's done, everything a later session needs is either in the files or with main, and this session can close.

## Who writes what

What a session writes down is what later sessions build on, so the writer must have seen what it records.

- A main session, or a spinoff that talked with Sid, writes the project files directly.
- A build worker owns only its folders. Its spec names main as the owner of the shared files (blueprint.md, architecture.md, sid.md). A worker writes nothing there. It puts everything in its message to main, and main records it.
- Only a session that heard Sid directly writes to sid.md, or records "Sid" as the one who decided something.

## What to keep

Go through the whole session, not just its end. Send each thing to its one home:

- Decisions go where they apply, each with why and who decided: blueprint.md if project-wide, or the part's entry in architecture.md or docs/<part>.md. A reversed decision goes in blueprint.md, under "Changed our mind".
- How things work now goes in the part's entry in architecture.md. Depth goes in docs/<part>.md.
- Sid's thoughts, worries, hunches and preferences go in sid.md, in Sid's voice (see its header). Keep the ones that went nowhere too.
- Anything unresolved goes in blueprint.md, under Open, tagged with the part and with who must answer.
- Measured results go in docs/<part>.md, under Results, with how to reproduce them.
- Status goes in the part's line in blueprint Parts.

Leave out anything the files or git already hold. Leave out the back-and-forth that led to a decision, too: the decision's "why" carries what matters.

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
3. If you're a spinoff, remove your line from blueprint.md Sessions.

## Reply

At most five lines:

- what you wrote and where;
- anything you chose not to keep, and why;
- then "Safe to close."
