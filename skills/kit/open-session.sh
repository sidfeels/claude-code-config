#!/bin/sh
# open-session.sh "<tab title>" "<first prompt>"
#
# Opens a new, visible Claude session in the current folder, on the same account as the
# session that runs this script. It exists because building this command by hand broke:
# Orca's account folders live under "Application Support", and an unquoted path with a
# space stops the new tab before Claude starts.
#
# In Orca it opens a terminal tab and prints Orca's JSON result. Anywhere else it prints
# the command for Sid to paste into a new terminal.
#
# The command uses `env`, which runs the real claude binary directly. That skips Orca's
# `claude` shell function, which would otherwise pick Orca's currently selected account.
# When this session has no CLAUDE_CONFIG_DIR (the default account), the variable is removed
# rather than set to ~/.claude, because the default account keeps its login state in
# ~/.claude.json and setting the folder explicitly would point Claude somewhere else.

set -eu
title="${1:?usage: open-session.sh <title> <prompt>}"
prompt="${2:?usage: open-session.sh <title> <prompt>}"

quote() { printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"; }

if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
  cmd="env CLAUDE_CONFIG_DIR=$(quote "$CLAUDE_CONFIG_DIR") claude $(quote "$prompt")"
else
  cmd="env -u CLAUDE_CONFIG_DIR claude $(quote "$prompt")"
fi

if [ -n "${ORCA_TERMINAL_HANDLE:-}" ] && command -v orca >/dev/null 2>&1; then
  orca terminal create --title "$title" --command "$cmd" --json
else
  printf '%s\n' "$cmd"
fi
