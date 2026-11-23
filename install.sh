#!/usr/bin/env bash
# Install this kit into Claude Code config folders by linking, so an edit in this repo is live everywhere.
#
#   ./install.sh                      both ~/.claude and ~/.claude-personal (whichever exist)
#   ./install.sh ~/.claude-personal   just the folders you name
#   ./install.sh --uninstall [dirs]   remove what this script installed
#
# For each folder, it:
# - links each skill folder into skills/ and each agent file into agents/;
# - writes CLAUDE.md as a one-line import of global/CLAUDE.md, backing up any CLAUDE.md that was already there;
# - removes links into this repo whose targets no longer exist.
# It never overwrites a skill or agent that isn't one of its own links.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd -P)"
IMPORT_LINE="@$KIT/global/CLAUDE.md"

uninstall=0
if [ "${1:-}" = "--uninstall" ]; then uninstall=1; shift; fi
if [ $# -gt 0 ]; then targets=("$@"); else targets=("$HOME/.claude" "$HOME/.claude-personal"); fi

ours() { [ -L "$1" ] && case "$(readlink "$1")" in "$KIT"/*) return 0;; esac; return 1; }

link() { # link <source> <dest>
  local src="$1" dest="$2"
  if ours "$dest"; then ln -sfn "$src" "$dest"; return; fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then echo "  skip $dest (exists and isn't ours)"; return; fi
  ln -s "$src" "$dest"
}

for dir in "${targets[@]}"; do
  dir="${dir%/}"
  if [ ! -d "$dir" ]; then echo "skip $dir (no such folder)"; continue; fi
  echo "$dir"
  mkdir -p "$dir/skills" "$dir/agents"

  # Remove our links: all of them on uninstall, only dangling ones otherwise.
  for entry in "$dir"/skills/* "$dir"/agents/*; do
    if ours "$entry" && { [ $uninstall = 1 ] || [ ! -e "$entry" ]; }; then rm "$entry"; echo "  removed $entry"; fi
  done

  if [ $uninstall = 1 ]; then
    if [ -f "$dir/CLAUDE.md" ] && [ "$(cat "$dir/CLAUDE.md")" = "$IMPORT_LINE" ]; then rm "$dir/CLAUDE.md"; echo "  removed $dir/CLAUDE.md"; fi
    continue
  fi

  for skill in "$KIT"/skills/*/; do
    skill="${skill%/}"; link "$skill" "$dir/skills/$(basename "$skill")"
  done
  for agent in "$KIT"/agents/*.md; do
    link "$agent" "$dir/agents/$(basename "$agent")"
  done

  if [ -f "$dir/CLAUDE.md" ] && [ "$(cat "$dir/CLAUDE.md")" != "$IMPORT_LINE" ]; then
    backup="$dir/CLAUDE.md.before-kit-$(date +%Y%m%d-%H%M%S)"
    mv "$dir/CLAUDE.md" "$backup"; echo "  backed up the old CLAUDE.md to $backup"
  fi
  printf '%s\n' "$IMPORT_LINE" > "$dir/CLAUDE.md"
  echo "  linked $(ls "$KIT"/skills | wc -l | tr -d ' ') skills, $(ls "$KIT"/agents | wc -l | tr -d ' ') agents, CLAUDE.md"
done
