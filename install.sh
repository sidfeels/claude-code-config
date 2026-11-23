#!/usr/bin/env bash
# Put this kit into a project, so every Claude account that opens the project gets the same skills, agents and rules.
#
#   ./install.sh --inspect [dir]               print what a folder already has; changes nothing
#   ./install.sh --project [dir] [--private]   copy the kit into <dir>/.claude (default: the current folder)
#   ./install.sh --update [dir]                bring a project's copy up to this kit's commit, keeping what the project changed
#   ./install.sh --diff [dir]                  show what a project changed in its copy since it was installed
#   ./install.sh --uninstall [dirs]            remove a global install (default: ~/.claude and ~/.claude-personal)
#   ./install.sh --global [dirs]               link the kit into account folders instead (the old way)
#
# SETUP.md says which of these a setup session runs, and when.
#
# Why per project: Claude Code reads .claude/ from the project folder whichever account is in use. The kit then
# doesn't depend on how each account folder is set up, and each project can change its copy as it learns.
#
# The kit's CLAUDE.md is Sid's rules. In a project it becomes .claude/rules/working-with-sid.md, which loads the
# same way, because the project's own CLAUDE.md belongs to the project (or to a team). Kit commits before the
# setup-first change kept that file at global/CLAUDE.md; rules_path finds it under either name.
#
# A project's copy is a snapshot. .claude/kit-version records the commit it came from. --diff compares the copy
# against that commit, and --update uses it to tell a file the project changed from one it never touched.
#
# --project never overwrites a file that is already there. --private lists what it wrote in .git/info/exclude,
# along with sid.md, .kit/ and CLAUDE.local.md, for a repo Sid doesn't own.
#
# A global install and a project copy don't mix. For a skill with the same name, Claude Code uses the account
# folder's copy and ignores the project's (run on Claude Code 2.1.330), so --project warns when it finds one.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd -P)"
IMPORT_LINE="@$KIT/CLAUDE.md"
OLD_IMPORT_LINE="@$KIT/global/CLAUDE.md"
RULES_FILE="rules/working-with-sid.md"
SOURCE="https://github.com/sidfeels/claude-code-config"

usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; }

abs() { (cd "$1" 2>/dev/null && pwd -P) || { echo "no such folder: $1" >&2; exit 1; }; }

short() { printf '%s' "$1" | cut -c1-7; }

# A scratch folder under $TMPDIR. A bare `mktemp -d` on macOS ignores $TMPDIR and uses /var/folders, which the
# sandbox doesn't allow, so install failed inside a sandboxed session.
scratch() { mktemp -d "${TMPDIR:-/tmp}/sid-kit-tmp.XXXXXX"; }

count() { printf '%s' "$1" | grep -c . || true; }

is_repo() { git -C "$1" rev-parse --git-dir >/dev/null 2>&1; }

exclude_file() { # exclude_file <dir>: the path of the repo's .git/info/exclude, which works in a worktree too
  local e; e="$(cd "$1" && git rev-parse --git-path info/exclude)"
  case "$e" in /*) ;; *) e="$1/$e" ;; esac
  mkdir -p "$(dirname "$e")"; printf '%s' "$e"
}

# Where the rules file sits in a given kit commit.
rules_path() {
  if git -C "$KIT" cat-file -e "$1:global/CLAUDE.md" 2>/dev/null; then echo global/CLAUDE.md; else echo CLAUDE.md; fi
}

# A path in a project's .claude/, as it is named in a given kit commit.
kit_path() { if [ "$2" = "$RULES_FILE" ]; then rules_path "$1"; else printf '%s' "$2"; fi; }

# The kit's pieces at <commit>, laid out the way they sit in a project's .claude/.
export_kit() { # export_kit <commit> <dir>
  local rules; rules="$(rules_path "$1")"
  mkdir -p "$2/rules"
  git -C "$KIT" archive "$1" skills agents "$rules" | tar -x -C "$2"
  mv "$2/$rules" "$2/$RULES_FILE"
  rm -rf "$2/global"
}

# The clone from the setup prompt is shallow, so an older commit may need fetching first.
have_commit() {
  if git -C "$KIT" cat-file -e "$1^{commit}" 2>/dev/null; then return 0; fi
  if git -C "$KIT" fetch -q --depth 1 origin "$1" 2>/dev/null; then return 0; fi
  echo "can't find commit $1 of the kit; run this from a full clone" >&2; exit 1
}

kit_commit_of() { sed -n 's/^commit: //p' "$1/.claude/kit-version"; }

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

# Facts a setup session needs before it changes anything. SETUP.md says what each one means.
inspect_folder() { # inspect_folder <dir>
  local dir top n p f first found kind list item
  dir="$(abs "$1")"
  echo "folder: $dir"
  if [ "$dir" = "$KIT" ]; then echo "  this is the kit itself"; return 0; fi

  echo
  echo "git"
  if is_repo "$dir"; then
    top="$(git -C "$dir" rev-parse --show-toplevel)"
    if [ "$top" != "$dir" ]; then echo "  inside the repo at $top, not at its top"; fi
    if [ -n "$(git -C "$dir" remote)" ]; then
      git -C "$dir" remote -v | awk '$3 == "(fetch)" { print "  remote " $1 ": " $2 }'
    else
      echo "  no remote"
    fi
    n="$(git -C "$dir" rev-list --count HEAD 2>/dev/null || echo 0)"
    echo "  $n commits"
    if [ "$n" != 0 ]; then
      echo "  most commits by: $(git -C "$dir" log --format=%an | sort | uniq -c | sort -rn | head -3 \
        | awk '{ c = $1; $1 = ""; sub(/^ /, ""); printf "%s%s (%s)", sep, $0, c; sep = ", " }')"
    fi
    echo "  files under .claude/ that git tracks: $(git -C "$dir" ls-files -- .claude | wc -l | tr -d ' ')"
  else
    echo "  not a git repository"
  fi

  echo
  echo "instruction files Claude Code loads from here"
  found=0
  for p in "$dir/CLAUDE.md" "$dir/CLAUDE.local.md" "$dir/AGENTS.md" "$dir/.claude/CLAUDE.md" "$dir"/.claude/rules/*.md; do
    if [ ! -f "$p" ]; then continue; fi
    found=1; f="${p#"$dir"/}"
    first="$(grep -m 1 -v '^[[:space:]]*$' "$p" | cut -c1-70 || true)"
    echo "  $f: $(wc -l < "$p" | tr -d ' ') lines, starts \"$first\""
  done
  if [ "$found" = 0 ]; then echo "  none"; fi

  echo
  echo ".claude/"
  if [ -d "$dir/.claude" ]; then
    for kind in skills agents; do
      list="$(ls "$dir/.claude/$kind" 2>/dev/null | sed 's/\.md$//' | tr '\n' ' ' || true)"
      echo "  $kind: ${list:-none}"
    done
    for f in settings.json settings.local.json; do
      if [ ! -f "$dir/.claude/$f" ]; then continue; fi
      if grep -q '"hooks"' "$dir/.claude/$f"; then echo "  $f, with hooks"; else echo "  $f"; fi
    done
    if [ -f "$dir/.claude/kit-version" ]; then
      echo "  this kit is installed:"; sed 's/^/    /' "$dir/.claude/kit-version"
      echo "    the kit is now at: $(git -C "$KIT" rev-parse HEAD 2>/dev/null || echo unknown)"
    else
      echo "  this kit is not installed"
    fi
  else
    echo "  none"
  fi

  echo
  echo "Sid's old v1 kit"
  found=0
  if [ -f "$dir/CLAUDE.md" ] && grep -q '^# Sid Global Claude Code Contract' "$dir/CLAUDE.md"; then
    echo "  CLAUDE.md is the v1 contract"; found=1
  fi
  if [ -f "$dir/HOOKS.md" ] && grep -q 'Deterministic Enforcement Layer' "$dir/HOOKS.md"; then
    echo "  HOOKS.md is the v1 hook guide"; found=1
  fi
  for item in rules/implementation-quality.md rules/delegation-and-review.md skills/data-trace-inspection \
      skills/handoff-payload skills/implementation-quality skills/long-running-project-orchestrator \
      skills/long-running-research-loop skills/paper-research skills/prompting-techniques skills/requirements-interview; do
    if [ -e "$dir/.claude/$item" ]; then echo "  .claude/$item"; found=1; fi
  done
  if [ "$found" = 0 ]; then echo "  none"; fi
  list=""
  for item in .agent RUNBOOK.md current_state.md findings.md caveats.md attempts.jsonl HANDOFF_PAYLOAD.md; do
    if [ -e "$dir/$item" ]; then list="$list $item"; fi
  done
  if [ -n "$list" ]; then echo "  names the v1 skills kept state under (may be the project's own):$list"; fi

  echo
  echo "the kit's project files"
  list=""
  for f in architecture.md decisions.md sid.md docs .kit; do
    if [ -e "$dir/$f" ]; then list="$list $f"; fi
  done
  echo "  present:${list:- none}"
  if is_repo "$dir"; then
    for f in sid.md .kit/; do
      if git -C "$dir" check-ignore -q "$f"; then echo "  git ignores $f"; else echo "  git does NOT ignore $f"; fi
    done
  fi

  echo
  echo "global copies of the kit, which would override this project's skills"
  found=0
  for f in "$HOME/.claude" "$HOME/.claude-personal"; do
    if [ -e "$f/skills/kit" ] || [ -L "$f/skills/kit" ]; then echo "  $f/skills/kit"; found=1; fi
  done
  if [ "$found" = 0 ]; then echo "  none"; fi
}

install_project() { # install_project <dir> <private: 0|1>
  local dir dest src wrote="" kept="" private="$2" commit="unknown" from="$KIT" rules_src="$KIT/CLAUDE.md" export_dir="" exclude p
  dir="$(abs "$1")"
  if [ "$dir" = "$KIT" ]; then echo "that folder is the kit itself" >&2; exit 1; fi
  dest="$dir/.claude"
  mkdir -p "$dest/skills" "$dest/agents" "$dest/rules"

  # Copy the last commit, not the working files, so the commit in kit-version is exactly what the project got.
  if git -C "$KIT" rev-parse HEAD >/dev/null 2>&1; then
    commit="$(git -C "$KIT" rev-parse HEAD)"
    export_dir="$(scratch)"
    export_kit HEAD "$export_dir"
    from="$export_dir"; rules_src="$export_dir/$RULES_FILE"
    if [ -n "$(git -C "$KIT" status --porcelain -- skills agents CLAUDE.md)" ]; then
      echo "note: $KIT has uncommitted changes. This project gets the last commit, without them."
    fi
  fi

  put() { # put <source> <path under .claude>; keeps whatever is already there
    if [ -e "$dest/$2" ]; then kept="$kept$2"$'\n'; else cp -R "$1" "$dest/$2"; wrote="$wrote$2"$'\n'; fi
  }
  for src in "$from"/skills/*/; do src="${src%/}"; put "$src" "skills/$(basename "$src")"; done
  for src in "$from"/agents/*.md; do put "$src" "agents/$(basename "$src")"; done
  put "$rules_src" "$RULES_FILE"
  if [ -n "$export_dir" ]; then rm -rf "$export_dir"; fi

  # kit-version is written once. Files kept from an earlier install still belong to that commit; --update moves it.
  if [ ! -f "$dest/kit-version" ]; then
    printf 'source: %s\ncommit: %s\ninstalled: %s\n' "$SOURCE" "$commit" "$(date +%Y-%m-%d)" > "$dest/kit-version"
    wrote="${wrote}kit-version"$'\n'
  fi

  echo "$dest"
  echo "  $(short "$(kit_commit_of "$dir")") is the kit commit this project's copy came from"
  echo "  wrote $(count "$wrote") files and folders"
  if [ -n "$kept" ]; then
    echo "  kept what was already there ($(count "$kept")):"
    printf '%s' "$kept" | sed 's/^/    /'
  fi

  if [ "$private" = 1 ]; then
    if is_repo "$dir"; then
      exclude="$(exclude_file "$dir")"
      # Sid's private files go in now, before any session can create and commit them.
      for p in $(printf '%s' "$wrote" | sed 's|^|/.claude/|') /sid.md /.kit/ /CLAUDE.local.md; do
        if ! git -C "$dir" check-ignore -q "${p#/}"; then printf '%s\n' "$p" >> "$exclude"; fi
      done
      echo "  listed them, sid.md, .kit/ and CLAUDE.local.md in .git/info/exclude, so git leaves them out"
    else
      echo "  --private did nothing: $dir is not a git repository"
    fi
  fi

  echo "  Start a new Claude session in this folder to load it."
  warn_global
}

update_project() { # update_project <dir>
  local dir dest old new tmp rel item installed private=0 exclude="" listed="|" added="" updated="" merge="" gone="" dropped=""
  dir="$(abs "$1")"; dest="$dir/.claude"
  if [ ! -f "$dest/kit-version" ]; then echo "no .claude/kit-version in $dir: install the kit with --project first" >&2; exit 1; fi
  if ! git -C "$KIT" rev-parse HEAD >/dev/null 2>&1; then echo "--update needs the kit as a git clone" >&2; exit 1; fi
  old="$(kit_commit_of "$dir")"; new="$(git -C "$KIT" rev-parse HEAD)"
  if [ "$old" = "$new" ]; then echo "$dest is already on the kit's commit $(short "$new")"; return 0; fi
  have_commit "$old"
  tmp="$(scratch)"
  # The path is written into the trap now, because $tmp is local and gone by the time the script exits.
  trap "rm -rf '$tmp'" EXIT
  export_kit "$old" "$tmp/old"
  export_kit "$new" "$tmp/new"

  # A copy kept out of git stays out: files new to the kit get listed in .git/info/exclude too.
  if is_repo "$dir" && git -C "$dir" check-ignore -q .claude/kit-version; then private=1; exclude="$(exclude_file "$dir")"; fi

  while IFS= read -r rel; do
    if [ -e "$dest/$rel" ]; then
      if cmp -s "$dest/$rel" "$tmp/new/$rel"; then continue; fi
      if [ -f "$tmp/old/$rel" ] && cmp -s "$dest/$rel" "$tmp/old/$rel"; then
        cp "$tmp/new/$rel" "$dest/$rel"; updated="$updated$rel"$'\n'          # the project never touched it
      elif [ -f "$tmp/old/$rel" ] && cmp -s "$tmp/old/$rel" "$tmp/new/$rel"; then
        continue                                                              # only the project changed it
      else
        merge="$merge$rel"$'\n'                                               # both changed it; keep the project's
      fi
    elif [ -f "$tmp/old/$rel" ]; then
      # The project deleted a file it was given. Don't bring it back, but say so if the kit has since changed it.
      if ! cmp -s "$tmp/old/$rel" "$tmp/new/$rel"; then gone="$gone$rel"$'\n'; fi
    else
      mkdir -p "$(dirname "$dest/$rel")"; cp "$tmp/new/$rel" "$dest/$rel"; added="$added$rel"$'\n'
      if [ "$private" = 1 ]; then
        item="$(printf '%s' "$rel" | cut -d/ -f1-2)"
        case "$listed" in *"|$item|"*) ;; *)
          listed="$listed$item|"
          if ! git -C "$dir" check-ignore -q ".claude/$item"; then printf '/.claude/%s\n' "$item" >> "$exclude"; fi ;;
        esac
      fi
    fi
  done < <(cd "$tmp/new" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)

  while IFS= read -r rel; do
    if [ ! -f "$tmp/new/$rel" ] && [ -e "$dest/$rel" ]; then dropped="$dropped$rel"$'\n'; fi
  done < <(cd "$tmp/old" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)

  installed="$(sed -n 's/^installed: //p' "$dest/kit-version")"
  printf 'source: %s\ncommit: %s\ninstalled: %s\nupdated: %s, from %s\n' \
    "$SOURCE" "$new" "${installed:-unknown}" "$(date +%Y-%m-%d)" "$old" > "$dest/kit-version"

  echo "$dest"
  echo "  updated from the kit's commit $(short "$old") to $(short "$new")"
  if [ -n "$updated" ]; then echo "  replaced, because this project hadn't changed them ($(count "$updated")):"; printf '%s' "$updated" | sed 's/^/    /'; fi
  if [ -n "$added" ]; then
    echo "  added, because they're new in the kit ($(count "$added")):"; printf '%s' "$added" | sed 's/^/    /'
    if [ "$private" = 1 ]; then echo "    (listed in .git/info/exclude like the rest of the copy)"; fi
  fi
  if [ -n "$merge" ]; then
    echo "  MERGE BY HAND ($(count "$merge")): this project changed these and so did the kit. The project's copy was kept."
    while IFS= read -r rel; do
      echo "    .claude/$rel"
      if [ -f "$tmp/old/$rel" ]; then
        echo "      the kit's change: git -C '$KIT' diff $(short "$old"):$(kit_path "$old" "$rel") $(short "$new"):$(kit_path "$new" "$rel")"
      else
        echo "      this project had its own file here; the kit's: git -C '$KIT' show $(short "$new"):$(kit_path "$new" "$rel")"
      fi
    done < <(printf '%s' "$merge")
  fi
  if [ -n "$gone" ]; then echo "  this project deleted these, and the kit has changed them since; left deleted:"; printf '%s' "$gone" | sed 's/^/    /'; fi
  if [ -n "$dropped" ]; then echo "  the kit no longer has these; delete them if this project doesn't use them:"; printf '%s' "$dropped" | sed 's/^/    /'; fi
  if [ -z "$updated$added$merge$gone$dropped" ]; then echo "  nothing in this project's copy needed changing"; fi
  echo "  Start a new Claude session in this folder to load the changes."
  warn_global
}

diff_project() { # diff_project <dir>
  local dir dest commit tmp
  dir="$(abs "$1")"; dest="$dir/.claude"
  if [ ! -f "$dest/kit-version" ]; then echo "no .claude/kit-version in $dir: the kit isn't installed there" >&2; exit 1; fi
  commit="$(kit_commit_of "$dir")"
  have_commit "$commit"
  tmp="$(scratch)"
  # The path is written into the trap now, because $tmp is local and gone by the time the script exits.
  trap "rm -rf '$tmp'" EXIT
  export_kit "$commit" "$tmp/kit"
  # Compare only the kit's own pieces. Other files in the project's .claude belong to the project.
  mkdir -p "$tmp/project/rules"
  cp -R "$dest/skills" "$dest/agents" "$tmp/project/" 2>/dev/null || true
  if [ -f "$dest/$RULES_FILE" ]; then cp "$dest/$RULES_FILE" "$tmp/project/$RULES_FILE"; fi

  echo "$dir: changes since the kit was installed ($(short "$commit"), $(sed -n 's/^installed: //p' "$dest/kit-version"))"
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
  local targets dir entry skill agent backup line
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

    line=""; if [ -f "$dir/CLAUDE.md" ]; then line="$(cat "$dir/CLAUDE.md")"; fi
    if [ "$uninstall" = 1 ]; then
      if [ "$line" = "$IMPORT_LINE" ] || [ "$line" = "$OLD_IMPORT_LINE" ]; then rm "$dir/CLAUDE.md"; echo "  removed $dir/CLAUDE.md"; fi
      continue
    fi

    for skill in "$KIT"/skills/*/; do
      skill="${skill%/}"; link "$skill" "$dir/skills/$(basename "$skill")"
    done
    for agent in "$KIT"/agents/*.md; do
      link "$agent" "$dir/agents/$(basename "$agent")"
    done

    if [ -f "$dir/CLAUDE.md" ] && [ "$line" != "$IMPORT_LINE" ] && [ "$line" != "$OLD_IMPORT_LINE" ]; then
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
  --inspect)   inspect_folder "${1:-.}" ;;
  --project)
    dir="."; private=0
    for arg in "$@"; do
      case "$arg" in --private) private=1 ;; *) dir="$arg" ;; esac
    done
    install_project "$dir" "$private" ;;
  --update)    update_project "${1:-.}" ;;
  --diff)      diff_project "${1:-.}" ;;
  --global)    global_links 0 "$@" ;;
  --uninstall) global_links 1 "$@" ;;
  *)           usage; exit 1 ;;
esac
