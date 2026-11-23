#!/usr/bin/env bash
# Put this kit into a project, so every Claude account that opens the project gets the same skills, agents and rules.
#
#   ./install.sh --project [dir] [--private]   copy the kit into <dir>/.claude (default: the current folder)
#   ./install.sh --diff [dir]                  show what a project changed in its copy since it was installed
#   ./install.sh --uninstall [dirs]            remove a global install (default: ~/.claude and ~/.claude-personal)
#   ./install.sh --global [dirs]               link the kit into account folders instead (the old way)
#
# Why per project: Claude Code reads .claude/ from the project folder whichever account is in use. The kit then
# doesn't depend on how each account folder is set up, and each project can change its copy as it learns.
#
# A project's copy is a snapshot. .claude/kit-version records the commit it came from, and --diff compares the
# copy against that commit, so Sid can later read what each project changed.
#
# --project never overwrites a file that is already there. --private also lists what it wrote in
# .git/info/exclude, for a repo Sid doesn't own.
#
# A global install and a project copy don't mix. For a skill with the same name, Claude Code uses the account
# folder's copy and ignores the project's (run on Claude Code 2.1.330), so --project warns when it finds one.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd -P)"
IMPORT_LINE="@$KIT/global/CLAUDE.md"
RULES_FILE="rules/working-with-sid.md"

usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; }

abs() { (cd "$1" 2>/dev/null && pwd -P) || { echo "no such folder: $1" >&2; exit 1; }; }

# Tell Sid when an account folder still holds the kit, because that copy would win over the project's.
warn_global() {
  local folder link src
  for folder in "$HOME/.claude" "$HOME/.claude-personal"; do
    link="$folder/skills/kit"
    if [ ! -e "$link" ] && [ ! -L "$link" ]; then continue; fi
    src="$link"; if [ -L "$link" ]; then src="$(readlink "$link")"; fi
    echo
    echo "WARNING: a global copy of the kit is still in $folder."
    echo "  For a skill with the same name, Claude Code uses that copy and ignores this project's,"
    echo "  so a change you make to a skill in this project would have no effect."
    case "$src" in
      */skills/kit) echo "  Remove it with: ${src%/skills/kit}/install.sh --uninstall" ;;
    esac
    return 0
  done
}

install_project() { # install_project <dir> <private: 0|1>
  local dir dest src wrote="" kept="" private="$2" commit="unknown" from="$KIT" export_dir=""
  dir="$(abs "$1")"
  if [ "$dir" = "$KIT" ]; then echo "that folder is the kit itself" >&2; exit 1; fi
  dest="$dir/.claude"
  mkdir -p "$dest/skills" "$dest/agents" "$dest/rules"

  # Copy the last commit, not the working files, so the commit in kit-version is exactly what the project got.
  if git -C "$KIT" rev-parse HEAD >/dev/null 2>&1; then
    commit="$(git -C "$KIT" rev-parse HEAD)"
    export_dir="$(mktemp -d)"
    git -C "$KIT" archive HEAD skills agents global/CLAUDE.md | tar -x -C "$export_dir"
    from="$export_dir"
    if [ -n "$(git -C "$KIT" status --porcelain -- skills agents global)" ]; then
      echo "note: $KIT has uncommitted changes. This project gets the last commit, without them."
    fi
  fi

  put() { # put <source> <path under .claude>; keeps whatever is already there
    if [ -e "$dest/$2" ]; then kept="$kept$2"$'\n'; else cp -R "$1" "$dest/$2"; wrote="$wrote$2"$'\n'; fi
  }
  for src in "$from"/skills/*/; do src="${src%/}"; put "$src" "skills/$(basename "$src")"; done
  for src in "$from"/agents/*.md; do put "$src" "agents/$(basename "$src")"; done
  put "$from/global/CLAUDE.md" "$RULES_FILE"
  if [ -n "$export_dir" ]; then rm -rf "$export_dir"; fi

  # kit-version is written once. Files kept from an earlier install still belong to that commit.
  if [ ! -f "$dest/kit-version" ]; then
    printf 'source: https://github.com/sidfeels/claude-code-config\ncommit: %s\ninstalled: %s\n' "$commit" "$(date +%Y-%m-%d)" > "$dest/kit-version"
    wrote="${wrote}kit-version"$'\n'
  fi

  echo "$dest"
  echo "  $(sed -n 's/^commit: //p' "$dest/kit-version" | cut -c1-7) is the kit commit this project's copy came from"
  echo "  wrote $(printf '%s' "$wrote" | grep -c . || true) items"
  if [ -n "$kept" ]; then
    echo "  kept $(printf '%s' "$kept" | grep -c . || true) that were already there:"
    printf '%s' "$kept" | sed 's/^/    /'
  fi

  if [ "$private" = 1 ] && [ -n "$wrote" ]; then
    if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
      local exclude; exclude="$(cd "$dir" && git rev-parse --git-path info/exclude)"
      case "$exclude" in /*) ;; *) exclude="$dir/$exclude" ;; esac
      mkdir -p "$(dirname "$exclude")"
      printf '%s' "$wrote" | sed 's|^|/.claude/|' >> "$exclude"
      echo "  listed them in .git/info/exclude, so git leaves them out"
    else
      echo "  --private did nothing: $dir is not a git repository"
    fi
  fi

  echo "  Start a new Claude session in this folder to load it."
  warn_global
}

diff_project() { # diff_project <dir>
  local dir dest commit tmp
  dir="$(abs "$1")"; dest="$dir/.claude"
  if [ ! -f "$dest/kit-version" ]; then echo "no .claude/kit-version in $dir: the kit isn't installed there" >&2; exit 1; fi
  commit="$(sed -n 's/^commit: //p' "$dest/kit-version")"
  if ! git -C "$KIT" cat-file -e "$commit^{commit}" 2>/dev/null; then
    git -C "$KIT" fetch -q --depth 1 origin "$commit" 2>/dev/null || { echo "can't find commit $commit of the kit; run this from a full clone" >&2; exit 1; }
  fi
  tmp="$(mktemp -d)"
  # The path is written into the trap now, because $tmp is local and gone by the time the script exits.
  trap "rm -rf '$tmp'" EXIT
  mkdir -p "$tmp/kit/rules" "$tmp/project/rules"
  git -C "$KIT" archive "$commit" skills agents global/CLAUDE.md | tar -x -C "$tmp"
  mv "$tmp/skills" "$tmp/agents" "$tmp/kit/"
  mv "$tmp/global/CLAUDE.md" "$tmp/kit/$RULES_FILE"
  # Compare only the kit's own pieces. Other files in the project's .claude belong to the project.
  cp -R "$dest/skills" "$dest/agents" "$tmp/project/" 2>/dev/null || true
  if [ -f "$dest/$RULES_FILE" ]; then cp "$dest/$RULES_FILE" "$tmp/project/$RULES_FILE"; fi

  echo "$dir: changes since the kit was installed ($(printf '%s' "$commit" | cut -c1-7), $(sed -n 's/^installed: //p' "$dest/kit-version"))"
  cd "$tmp"
  if git --no-pager diff --no-index --quiet kit project; then echo "  none"; return 0; fi
  git --no-pager diff --no-index --stat kit project || true
  echo
  git --no-pager diff --no-index kit project || true
}

ours() { [ -L "$1" ] && case "$(readlink "$1")" in "$KIT"/*) return 0;; esac; return 1; }

link() { # link <source> <dest>
  local src="$1" dest="$2"
  if ours "$dest"; then ln -sfn "$src" "$dest"; return; fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then echo "  skip $dest (exists and isn't ours)"; return; fi
  ln -s "$src" "$dest"
}

# The old way: link the kit into account folders, or with uninstall=1 remove exactly those links.
# It never overwrites a skill or agent that isn't one of its own links.
global_links() { # global_links <uninstall: 0|1> [dirs]
  local uninstall="$1"; shift
  local targets dir entry skill agent backup
  if [ $# -gt 0 ]; then targets=("$@"); else targets=("$HOME/.claude" "$HOME/.claude-personal"); fi

  for dir in "${targets[@]}"; do
    dir="${dir%/}"
    if [ ! -d "$dir" ]; then echo "skip $dir (no such folder)"; continue; fi
    echo "$dir"
    mkdir -p "$dir/skills" "$dir/agents"

    # Remove our links: all of them on uninstall, only dangling ones otherwise.
    for entry in "$dir"/skills/* "$dir"/agents/*; do
      if ours "$entry" && { [ "$uninstall" = 1 ] || [ ! -e "$entry" ]; }; then rm "$entry"; echo "  removed $entry"; fi
    done

    if [ "$uninstall" = 1 ]; then
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
}

mode="${1:-}"
if [ $# -gt 0 ]; then shift; fi
case "$mode" in
  --project)
    dir="."; private=0
    for arg in "$@"; do
      case "$arg" in --private) private=1 ;; *) dir="$arg" ;; esac
    done
    install_project "$dir" "$private" ;;
  --diff)      diff_project "${1:-.}" ;;
  --global)    global_links 0 "$@" ;;
  --uninstall) global_links 1 "$@" ;;
  *)           usage; exit 1 ;;
esac
