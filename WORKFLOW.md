# How to use this kit

Each project has one main session. It holds the whole picture, and it's the only session you need to keep. Every other session works on one part and writes back to the project files before you close it, so after "save" you can close any session except main.

Layout: main on the left; the session you're focused on dragged to the left beside it; everything else on the right.

Everything runs in Orca, in tabs. Open main as a terminal (CLI) tab, not a chat, because the kit reaches main by its terminal address.

## When you want to…

**Set up a folder.** Open it in Orca, start `claude` in a terminal tab, and paste this:

```
Set up Sid's kit in this folder. Run the command below. Then read .claude/skills/kit/SKILL.md and follow its section "Fitting the kit into a folder". Tell me what you found and what you suggest before you change anything else.

rm -rf /tmp/sid-kit && git clone -q --depth 1 https://github.com/sidfeels/claude-code-config /tmp/sid-kit && /tmp/sid-kit/install.sh --project .
```

The session installs the kit into the folder's `.claude/`, where both accounts read it. Then it looks at what's already there, such as a team's CLAUDE.md or a `.gitignore` that doesn't cover your private notes, and tells you how it suggests fitting the kit in. When it's done, close that session and start a new one, so the kit is loaded from the start.

**Start a project.** Start `claude` in the folder, or `claude-personal` for the personal account. That session is main. Type `/discuss` followed by what you want to build. It asks a few questions at a time and creates the project files. It's done when you've confirmed the whole thing in five sentences of your own, and each part has two or three examples of it working, in your words.

**Go deep on one part, or two or three related parts.** In main, type `/spinoff <part>`. A "Discuss: <part>" tab opens. Talk there. When the part feels settled, say "save": that session writes everything into the files and tells main. Then close it.

**Hear how an expert would do it.** Type `/expert <question>`. Fresh subagents that haven't seen our plan each answer through a different lens. When they disagree, or you say "council", the two strongest views argue it out for up to two rounds, and whatever they still disagree on comes to you as the decision.

**Run an experiment or a red-team campaign.** Treat it as a part whose output is a finding. Discuss writes down the claim and the result that would prove it wrong, and runs the cheapest check first. A negative result still counts.

**Build.** Once architecture.md shows parts as settled, type `/build` in main.
- The first wave builds a thin skeleton that runs end to end.
- After the skeleton, and after every wave, main shows you real output and asks if it's what you meant.
- After that, there's one "Build: <part>" worker per part, each reporting to main.
- At the end of each wave, main runs everything for real, saves a checkpoint, has fresh agents review the riskiest part and the tests, and tells you what needs your eyes.

**Review a part.** Drag its Build tab to the left beside main and talk to it. The worker tells main about anything it changes. Close the tab when you're happy.

**Use the other account.** A session the kit opens uses the same account as the session that opened it. To get the other one, say so: "open this spinoff on personal". Build workers always use the account selected in Orca.

**Add a thought while a worker is busy.** If it changes what the worker is building, press Esc in that tab, then type. Otherwise tell main, and it passes the thought on.

**Pick up after a break, or after main was closed.** Ask main "where are we". It rebuilds the picture from the files and from Orca's records.

**Fix something old that turned out broken.** Tell main. It reproduces the failure for real first. If the design was wrong, the part goes back to discussion; if the build was wrong, it's fixed as a wave of one.

**Get tests you can trust.** Use `/tests` while working. Use `/tests audit` to have a fresh agent judge the suite and prune it.

**Write something for other people.** Type `/rewrite` followed by the text or a file. For Slack, type `/rewrite slack` followed by your draft.

**Improve how this works.** Every week or so, or after a session that annoyed you, type `/retro`. It finds what cost you time and proposes fixes. Fixes to skills go into this project's own copy, and it tells you which ones are worth sending back to the kit.

## Habits that save trouble

- Say "save" before closing any session that taught you something.
- Don't leave a half-typed message in main for more than about 10 minutes while workers are running, because Orca may type a wake-up into the same box.
- Keep main open. Close everything else freely.

## One-time setup

In Orca:
- Settings → Claude accounts → "When you switch accounts while Claude is running": choose **Never restart**.
- Leave hibernation off, so main never sleeps through a report.

Optional, in Claude Code:
- If the work account's sandbox keeps blocking `orca`, add it to `sandbox.excludedCommands` in `~/.claude/settings.json`.

## Short prompts

[ARSENAL.md](ARSENAL.md) has short prompts worth keeping at hand.
