## Implementation Quality — Core

Match the repository. Read neighboring files before writing. Copy successful local patterns before inventing new ones. If the local style is bad, improve only what you touch and only when it materially helps.

Solve the problem with the minimum sufficient design. No abstractions for imagined future reuse. No config knobs nobody needs. No wrappers that merely pass through arguments.

### Anti-slop — catch these in your own output

- **Overengineering**: frameworks, factories, registries, strategy layers that the task does not need.
- **Defensive boilerplate**: null checks, try/except, retries, fallbacks everywhere without a real boundary reason.
- **Fake verification**: tests that only prove mocks behave as mocked. Prefer tests that fail for the same reasons real code fails.
- **Style contamination**: introducing a different style into an area that already has one.
- **Cleanup drift**: mixing unrelated formatting, renaming, or refactoring into a focused task.
- **Ceremonial complexity**: helper layers, status objects, wrapper types, extra scripts just to look production-grade.

### Hard rules

- No mutable default arguments (`def f(x=[])` is a bug).
- No bare `except:` — catch specific exceptions.
- Use `with` for files and resources.
- No hardcoded secrets — use env vars / `.env` and `.gitignore` them.
- No emojis, AI attribution, or decorative unicode in code, comments, or commits.
- Commit messages: short, specific, lowercase, like a developer actually types them.

### Before reporting done

Read your diff as if a senior engineer asked you to justify every touched line. Check: is anything overbuilt? Is anything unverified? Does anything look like an LLM added it reflexively? Fix before claiming completion.