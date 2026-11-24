# Setting up the kit in a folder

You're a Claude session that Sid asked to set up this kit in the folder you're running in. This file is in the kit's clone. Call that clone's folder KIT, and write its full path in every command, because `$TMPDIR` can point somewhere else in a command that runs outside the sandbox.

Read `KIT/CLAUDE.md` before anything else. It's how Sid wants to be worked with, and this session doesn't have it loaded, because the kit isn't installed here yet. Follow it from your first reply: keep replies short, put long drafts in a file and give the path, and ask questions with no lean. When a setup test ran without it, the session recommended an option to Sid.

No two folders are alike. One is empty, one is Sid's own repo, one is a team's repo with its own CLAUDE.md, and one is an old project of Sid's with an older kit in it. The script only copies files. You look at the folder and fit the kit to it.

## 1. Look, and change nothing

Run `KIT/install.sh --inspect .`. It prints facts and writes nothing. Then read whatever it lists that you need in order to judge: an existing CLAUDE.md, AGENTS.md or README, and anything already in `.claude/`.

Work out which case in section 3 this is. A remote under `sidfeels` is Sid's. Any other remote, including one at Sid's employer, is a team's repo unless Sid says otherwise. If you can't tell, ask.

## 2. Tell Sid, then wait

Tell Sid in a few lines:

- what this folder is, and which case;
- what you'll add;
- what you'll leave alone;
- anything you'd delete, move or rewrite, one per line;
- which model the project's sessions and workers should use. Ask this once, with no lean, and show the one `.claude/settings.json` (or `settings.local.json`) already sets, if any.

Then wait. Sid's go covers what you listed and nothing more. Anything new that comes up halfway gets its own question.

## 3. The cases

In every case, once the kit is in, write the model Sid chose into `.claude/settings.json`, keeping its other keys. In a team's repo their settings.json stays theirs, so use `.claude/settings.local.json`, which overrides it and which `--private` keeps out of git.

```
f=.claude/settings.json   # .claude/settings.local.json in a team's repo
[ -s "$f" ] || echo '{}' > "$f"; jq --arg m "<model>" '.model = $m' "$f" > "$f.new" && mv "$f.new" "$f"
```

### A new folder, or Sid's own repo without the kit

1. If there's no git, run `git init`.
2. `KIT/install.sh --project .`
3. Add the lines of `KIT/skills/kit/templates/gitignore` to `.gitignore`, then check that `git check-ignore sid.md .kit/` prints both names, and that `git check-ignore .claude/skills/kit/templates/sid.md` prints nothing (an unanchored `sid.md` line hides the kit's own template). Do this before the first commit, because the first commit is when a private file gets in.
4. Create architecture.md, decisions.md, sid.md and CLAUDE.md from `KIT/skills/kit/templates/`, keeping each file's header. Fill in only what the folder already shows, such as what it is and how to run it. The rest is for `/discuss`. If Sid's repo already has a CLAUDE.md, it's Sid's: show Sid what you'd add to it.
   If Sid asks for one instruction file, merge `KIT/CLAUDE.md` into CLAUDE.md (into CLAUDE.local.md when other people read CLAUDE.md) and delete `.claude/rules/working-with-sid.md`.
5. If a README or a docs folder already explains the project, architecture.md points to it and adds only what it lacks: the open questions, each part's status, and the choices with their reasons.
6. Commit `.claude/` and the new files together. Don't push.

### Someone else's repo

Ask before adding anything. Their CLAUDE.md, AGENTS.md, `.gitignore` and whatever they keep in `.claude/` stay exactly as they are. Claude Code loads their CLAUDE.md and AGENTS.md next to Sid's rules, so there's nothing to merge.

1. `KIT/install.sh --project . --private`. It lists the copy in `.git/info/exclude`, along with sid.md, `.kit/`, CLAUDE.local.md and `.claude/settings.local.json`, so none of Sid's files can show up in their tree.
2. Put what the kit's CLAUDE.md template would hold (where to start, how to run and check the project, Sid's rules for it) in CLAUDE.local.md. Claude Code loads it beside theirs.
3. Add architecture.md and decisions.md only if Sid wants them here, and list each one in `.git/info/exclude` when you do.
4. Check that `git status --porcelain` shows nothing of Sid's.

If the team keeps skills or agents in `.claude/`, the kit's land beside them. One with the same name as a kit piece was kept, so tell Sid, because the kit's version of it isn't in use.

### Sid's older project with the v1 kit

`--inspect` lists what it found under "Sid's old v1 kit". Those files would keep loading next to the new rules, and the two sets of rules pull in different directions. So the v1 files go, but the project knowledge in them stays.

1. Read the old CLAUDE.md. It's the v1 contract copied in, and Sid may have added lines about this project to it: commands, rules, what the project is. Those lines move to the new CLAUDE.md, and the contract itself goes.
2. Read the files the v1 skills kept state in (`.agent/`, RUNBOOK.md, current_state.md and the others `--inspect` lists). They may say what was decided, what works and what failed. Propose what goes into architecture.md, and what into decisions.md as entries dated from those notes. Some of those names may be the project's own files, so open each one before you list it.
3. Check `.claude/settings.json` for hooks that came from the v1 HOOKS.md.
4. Show Sid one list: what moves where, and what gets deleted. After Sid's go, delete with `git rm`, so everything stays in history.
5. Then follow "A new folder, or Sid's own repo".

If it's a team's repo with Sid's v1 files in it, treat it as someone else's repo, and ask about each v1 file.

### A project already on this kit

`--inspect` shows the commit the project's copy came from and the kit's commit now.

1. `KIT/install.sh --diff .` shows what this project changed in its copy. Tell Sid each change in a line, because some may be worth sending back to the kit.
2. After Sid's go, run `KIT/install.sh --update .`. It replaces the files the project never changed, adds the kit's new files, and leaves the rest alone.
3. Under "MERGE BY HAND" are files that both the project and the kit changed. For each one, read the kit's change (the script prints the command) and the project's (from step 1), and write one file that keeps both. When they contradict, ask Sid.
4. For each file the kit no longer has, ask Sid before deleting it.
5. If the kit's rules were merged into CLAUDE.md, `--update` lists `rules/working-with-sid.md` as left deleted whenever the kit changed them, with the command that shows the change. Carry that change into the merged file.
6. If `.claude/rules/this-project.md` exists, it's where an earlier version of the kit put Sid's notes for a team's repo. It still loads. Offer Sid to move it to CLAUDE.local.md, so those notes have one home.
7. In Sid's own repo, commit with both kit commits in the message (`--update` printed them as "updated from the kit's commit X to Y"). In a team's repo the copy is excluded, so there's nothing to commit.

## 4. Things that get in the way

- The sandbox protects `.claude/skills` and `.claude/settings.json` in the folder it runs in, so `--project`, `--update` and the model's `jq` line can fail with "Operation not permitted". Run that one command again outside the sandbox.
- A pre-push hook that refuses dates also refuses decisions.md, whose entries are dated by design. Keep decisions.md local: list `/decisions.md` in `.gitignore` in Sid's own repo (`.git/info/exclude` in a team's), then `git rm --cached decisions.md` and amend the setup commit.
- If `--inspect` lists a global copy of the kit, its skills override this project's. Tell Sid. The kit's README says how to remove it.
- If something `--project` would write is already there, the script keeps it and lists it. Tell Sid which, since that piece of the kit isn't in use.

## 5. Finish

1. Run `KIT/install.sh --inspect .` again and report from this run, not the first. Files can arrive while you work: a CLAUDE.local.md, a hook or a data folder can appear after the first look.
2. If it lists a pre-push hook and there's a setup commit, dry-run the hook on it, from the hooks folder `--inspect` printed: `echo "refs/heads/<branch> <sha> refs/heads/<branch> 0000000000000000000000000000000000000000" | <hooks folder>/pre-push origin <remote url>`. Tell Sid what it refuses.
3. Tell Sid in a few lines what changed. Then say that the kit only loads in a new session: close this one, start `claude` (or `claude2`) in this folder, and type `/` to see the skills.
