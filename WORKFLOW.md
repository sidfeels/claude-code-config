# How to use this kit

Each project has one main session. It holds the whole picture, and it's the only session you need to keep. Every other session works on one part and writes back to the project files before you close it, so after "save" you can close any session except main.

Layout: main on the left; the session you're focused on dragged to the left beside it; everything else on the right.

Everything runs in Orca, in tabs. Open main as a terminal (CLI) tab, not a chat, because the kit reaches main by its terminal address.

## When you want to…

**Start a project.** Open main in the project folder and type `/discuss` followed by what you want to build. It asks a few questions at a time and creates the project files. It's done when you've confirmed the whole thing in five sentences of your own.

**Go deep on one part, or two or three related parts.** In main, type `/spinoff <part>`. A "Discuss: <part>" tab opens. Talk there. When the part feels settled, say "save": that session writes everything into the files and tells main. Then close it.

**Hear how an expert would do it.** Type `/expert <question>`. Fresh subagents that haven't seen our plan each answer through a different lens. When they disagree, or you say "council", the two strongest views argue it out for up to two rounds, and whatever they still disagree on comes to you as the decision.

**Run an experiment or a red-team campaign.** Treat it as a part whose output is a finding. Discuss writes down the claim and the result that would prove it wrong, and runs the cheapest check first. A negative result still counts.

**Build.** Once architecture.md shows parts as settled, type `/build` in main.
- The first wave builds a thin skeleton that runs end to end.
- After that, there's one "Build: <part>" worker per part, each reporting to main.
- At the end of each wave, main runs everything for real, saves a checkpoint, has fresh agents review the riskiest part and the tests, and tells you what needs your eyes.

**Review a part.** Drag its Build tab to the left beside main and talk to it. The worker tells main about anything it changes. Close the tab when you're happy.

**Add a thought while a worker is busy.** If it changes what the worker is building, press Esc in that tab, then type. Otherwise tell main, and it passes the thought on.

**Pick up after a break, or after main was closed.** Ask main "where are we". It rebuilds the picture from the files and from Orca's records.

**Fix something old that turned out broken.** Tell main. It reproduces the failure for real first. If the design was wrong, the part goes back to discussion; if the build was wrong, it's fixed as a wave of one.

**Get tests you can trust.** Use `/tests` while working. Use `/tests audit` to have a fresh agent judge the suite and prune it.

**Write something for other people.** Type `/rewrite` followed by the text or a file. For Slack, type `/rewrite slack` followed by your draft.

**Go to sleep.** Type `/overnight` followed by what should be done by morning. Check the plan and the budget it shows you, paste the `/goal` line it gives you, and go. In the morning, read the "Morning report". If the night got cut off and the session still says you're away, change the first line of `.kit/overnight.md` to `Status: done`.

**Improve how this works.** Every week or so, or after a session that annoyed you, type `/retro`. It finds what cost you time and proposes fixes. Changes to the kit itself come to you as a PR.

## Habits that save trouble

- Say "save" before closing any session that taught you something.
- Don't leave a half-typed message in main for more than about 10 minutes while workers are running, because Orca may type a wake-up into the same box.
- Keep main open. Close everything else freely.

## One-time setup

In Orca:
- Settings → Claude accounts → "When you switch accounts while Claude is running": choose **Never restart**.
- Leave hibernation off, so main never sleeps through a report.
- Restart Orca once after installing the kit. That copies the kit's agents and CLAUDE.md into Orca's account folders.

Optional, in Claude Code:
- To let overnight runs survive a usage limit, set `"autoContinueAtUsageLimit": true` in `~/.claude/settings.json`, and in `~/.claude-personal/settings.json`.
- If the work account's sandbox keeps blocking `orca`, add it to `sandbox.excludedCommands` in `~/.claude/settings.json`.

## Short prompts

[ARSENAL.md](ARSENAL.md) has short prompts worth keeping at hand.
