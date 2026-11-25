---
name: spinoff
description: Open a separate Orca tab for one part (or two or three closely related parts) that needs deep discussion. A brief gives it the context to start. Use for /spinoff, or when a part needs more depth than the main session should hold.
argument-hint: "<part or parts>"
---

# Spinoff

The main session holds the whole project, and going deep on one part would crowd that out and rot main's context. A spinoff gives the part its own session. It starts from a brief instead of from zero, and it ends with `save`, which writes everything back into the project files and tells main. Nothing should live only in a spinoff's conversation.

Put two or three parts in one spinoff when they share most of their decisions. Give a part its own spinoff when it would fill most of a session by itself.

## 1. Write the brief

Write `.kit/briefs/<part>.md`. Apart from the project files, it's the only context the new session has. Write it like a handoff to a capable colleague who missed the meeting. Include:

- What this part is, and why it matters to the whole.
- What to read first: architecture.md whole, the entries in decisions.md that name this part, and sid.md under "Still matters".
- What's already decided that constrains it. Point to the lines in architecture.md and decisions.md rather than restating them. Where you do include text, copy it word for word.
- The concerns that touch this part: Sid's (from sid.md and this conversation, in Sid's words), and those of the people it's for (architecture.md, "From the outside").
- The open questions for this part, from architecture.md's Open questions, plus anything you suspect nobody has raised yet.
- What done looks like:
  - the part is settled, and has its "Works when" examples in Sid's words;
  - it is written into architecture.md, and into docs/<part>.md if it needs depth;
  - Sid has confirmed it in five sentences.
- What isn't this session's to change: the other parts. If the discussion changes one, it tells main.
- Main's address, and these instructions: "Start with the discuss skill and finish with the save skill. Open by telling Sid in a few lines what you take this part to be and what's still open, so Sid can correct the picture before the questions start."

Keep your own opinion on contested choices out of the brief, or mark it as one view among several, so the spinoff thinks fresh. Mark anything that is your guess as a guess, because the spinoff can't tell your assumption from a decision.

## 2. Open the session

Main's address goes in the brief, and it depends on where you're running.

| Environment | How you know | Main's address |
|---|---|---|
| Orca | `$ORCA_TERMINAL_HANDLE` is set | `$ORCA_TERMINAL_HANDLE` |
| Plain terminal | it isn't set | none; Sid relays |

Run the kit's script:

```
"${CLAUDE_SKILL_DIR}/../kit/open-session.sh" "Discuss: <part>" "Read .kit/briefs/<part>.md and follow it."
```

The script opens a tab on this session's account, with the project's model. Outside Orca it prints the command for Sid to paste instead. Don't build the command by hand. When Sid names the other account or a model for this spinoff, pass them as the third and fourth arguments; the `kit` skill, under Which account, says how.

## 3. Record it and hand over

Add the session to `.kit/sessions.md`, with its address (the terminal handle from the script's output).

Tell Sid in one or two lines:
- the tab's name;
- that in Orca it opened beside the active tab;
- to say "save" there when the part feels settled.

## When main hears back

The spinoff's save sends main a short message: what settled, what's still open, which files changed. Then:

1. Read the changed files, not just the message.
2. Check that the part's decisions don't contradict the rest of the design.
3. Check the part's Status line in architecture.md, and remove its line from `.kit/sessions.md` if the spinoff didn't.
4. If anything affects other parts, tell Sid in one line.

A copy of every message also lands in `.kit/messages/`, so nothing is lost if main was closed when it arrived.
