---
name: spinoff
description: Open a separate session, an Orca tab or a T3 thread, for one part (or two or three closely related parts) that needs deep discussion. A brief gives it the context to start. Use for /spinoff, or when a part needs more depth than the main session should hold.
argument-hint: "<part or parts>"
---

# Spinoff

The main session holds the whole project, and going deep on one part would crowd that out and rot main's context. A spinoff gives the part its own session. It starts from a brief instead of from zero, and it ends with `save`, which writes everything back into the project files and tells main. Nothing should live only in a spinoff's conversation.

Put two or three parts in one spinoff when they share most of their decisions. Give a part its own spinoff when it would fill most of a session by itself.

## 1. Write the brief

Write `.kit/briefs/<part>.md`. Apart from the project files, it's the only context the new session has. Write it like a handoff to a capable colleague who missed the meeting. Include:

- What this part is, and why it matters to the whole.
- What's already decided that constrains it. Point to the lines in blueprint.md and architecture.md rather than restating them.
- The concerns that touch this part: Sid's (from sid.md and this conversation, in Sid's words), and those of the people it's for (blueprint.md, "Who it's for").
- The open questions for this part, from blueprint Open, plus anything you suspect nobody has raised yet.
- What done looks like:
  - the part is settled;
  - it is written into architecture.md, and into docs/<part>.md if it needs depth;
  - Sid has confirmed it in five sentences.
- Main's address, and this instruction: "Start with the discuss skill and finish with the save skill."

Keep your own opinion on contested choices out of the brief, or mark it as one view among several, so the spinoff thinks fresh.

## 2. Open the session on the same account

Each environment gives main a different address, which goes in the brief, and a different way to open the new session.

| Environment | How you know | Main's address |
|---|---|---|
| Orca | `$ORCA_TERMINAL_HANDLE` is set | `$ORCA_TERMINAL_HANDLE` |
| T3 Code | `$CLAUDE_CODE_ENTRYPOINT` is `t3-code` | `$T3CODE_THREAD_ID` |
| Plain terminal | neither of the above | none; Sid relays |

**Orca, or a plain terminal.** Run the kit's script:

```
"${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/kit/open-session.sh" "Discuss: <part>" "Read .kit/briefs/<part>.md and follow it."
```

The script opens a tab on this session's account. It quotes the account folder (Orca's folders contain a space) and skips Orca's account-picking shell function. Outside Orca it prints the command for Sid to paste instead. Don't build the command by hand.

**T3 Code.** Call `t3_thread_launch` with the title "Discuss: <part>" and the message "Read .kit/briefs/<part>.md and follow it." Leave out the model and modes so the thread inherits this one's. If this thread isn't at the project root (check with `git rev-parse --show-toplevel` against the project root), pass `workspaceStrategy: {type: "existing_worktree", worktreePath: <this folder>}` so both threads edit the same files. Give Sid the thread's link.

## 3. Record it and hand over

Add the session to blueprint.md under Sessions, with its address (the terminal handle from the script's output, or the thread id).

Tell Sid in one or two lines:
- the tab's name;
- that in Orca it opened beside the active tab;
- to say "save" there when the part feels settled.

## When main hears back

The spinoff's save sends main a short message: what settled, what's still open, which files changed. Then:

1. Read the changed files, not just the message.
2. Check that the part's decisions don't contradict the rest of the design.
3. Update the part's status in blueprint Parts, and remove its Sessions line if the spinoff didn't.
4. If anything affects other parts, tell Sid in one line.

A copy of every message also lands in `.kit/messages/`, so nothing is lost if main was closed when it arrived.
