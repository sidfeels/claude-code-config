# Arsenal

These are prompts too small to be skills. Paste them as they are, or add a word of context.

## Set up a folder

Start `claude` in the folder and paste this. It installs the kit for both accounts, then fits it to what the folder already has:

```
Set up Sid's kit in this folder. Run the command below. Then read .claude/skills/kit/SKILL.md and follow its section "Fitting the kit into a folder". Tell me what you found and what you suggest before you change anything else.

rm -rf /tmp/sid-kit && git clone -q --depth 1 https://github.com/sidfeels/claude-code-config /tmp/sid-kit && /tmp/sid-kit/install.sh --project .
```

## Make it better before it's built

- What is a more ambitious version of this?
- I want a deeper version of this task, not a bigger one. Before you rewrite my prompt, tell me four things:
  - what a top professional in this field would do here that I'm not asking for;
  - the rawest material they'd start from;
  - the methods they'd use;
  - what, other than you or me, would show the result is right.

  Then rewrite my prompt to ask for exactly that.
- It must remain easy to reason about.
- What would show us what this really does, rather than what we hope it does?

## Make sure we mean the same thing

- In your own words, what am I trying to do here, and why?
- Ask me a few rounds of questions until we agree on the vision.
- Explain it from fundamentals, in simple terms.
- What did you assume that I never said?

## Think past the obvious

- I'm pointing at <X>. What else lives near it that I haven't said?
- If this goes through, what happens next? Walk it forward: first real use, the worst day, when something upstream changes, a month from now.
- List every state this can be in and every move between them, including failure and retry. Which states does nothing handle?
- What does this depend on that we haven't checked?
- What could this break outside the diff? Find the one fact that makes it safe, and prove that fact by running real code.

## Fix it properly

- Fix the problem, not the symptom.
- Is there a fix that removes complexity instead of adding it?
- Can our tests actually create this condition (the race, the load, the failure), or do they only hope for it?

## After tests are written

- For each test you just wrote, name the wrong version of the code it would catch. Break the code that way in a scratch copy, and show me that the test fails on its assertion.
- Which of these tests could never fail? Delete them.

## Checking work

- How far did you check that: said it, pointed at the line, ran it, or reproduced it for real?
- Show me the output, not the conclusion.
