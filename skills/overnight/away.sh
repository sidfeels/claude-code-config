#!/bin/sh
# Overnight guard, registered by the overnight skill's hooks.
# It acts only while the project's .kit/overnight.md starts with "Status: running";
# otherwise it exits quietly and Claude Code behaves normally.
# Usage: away.sh ask | permission   (hook input arrives on stdin)

cat >/dev/null
plan="${CLAUDE_PROJECT_DIR:-.}/.kit/overnight.md"
head -n 1 "$plan" 2>/dev/null | grep -q '^Status: running' || exit 0

case "$1" in
  ask)
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Sid is away and cannot answer. Apply the decision rule from the overnight skill: if little of the remaining work rides on this, decide, log it under Decided overnight in .kit/overnight.md, and continue; if much rides on it, write it under Parked with options and your lean, then move to work that does not depend on it."}}'
    ;;
  permission)
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","message":"Sid is away and nobody can approve this. Find a way that needs no approval, or write it under Parked in .kit/overnight.md and move on."}}}'
    ;;
esac
exit 0
