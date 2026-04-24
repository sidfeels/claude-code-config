## Implementation Quality — Core

Match the repository. Read neighboring files before writing. Copy successful local patterns before inventing new ones. If the local style is bad, improve only what you touch and only when it materially helps.

Solve the problem with the minimum sufficient design. No abstractions for imagined future reuse. No config knobs nobody needs. No wrappers that merely pass through arguments.

### Anti-slop — catch these in your own output

Named LLM failure modes (use these names when flagging in review):

- **Overengineering**: frameworks, factories, registries, strategy layers that the task does not need.
- **LLM architecture cosplay**: builder/director/registry/strategy patterns for small tasks — production-grade scaffolding around a two-function problem.
- **Defensive boilerplate**: null checks, try/except, retries, fallbacks everywhere without a real boundary reason.
- **Mock theater**: tests that only prove mocks behave as mocked; no real behavior is verified. Especially dangerous for LLM/API/tool/agent code — mocks silently pass the class of bugs that matter most (refusals, format drift, tool-schema brittleness, long-tail generations).
- **Comment certainty**: comments asserting a causal story that was never verified against docs, tests, or execution.
- **Style contamination / style transplant**: introducing a different style into an area that already has one, or code that looks imported from another repo.
- **Cleanup drift**: mixing unrelated formatting, renaming, or refactoring into a focused task.
- **Ceremonial complexity**: helper layers, status objects, wrapper types, extra scripts just to look production-grade.
- **Fake verification**: code-looks-right claimed as success, without running the strongest available verifier.

### Hard rules

- No mutable default arguments (`def f(x=[])` is a bug).
- No bare `except:` — catch specific exceptions.
- Use `with` for files and resources.
- No hardcoded secrets — use env vars / `.env` and `.gitignore` them.
- No emojis, AI attribution, or decorative unicode in code, comments, or commits.
- Commit messages: short, specific, lowercase, like a developer actually types them.
- **Real-model and real-tool verification required for agentic code**: if the change touches code that calls an LLM, a tool, an agent loop, a browser, an external API, or an LLM-based judge, run at least one cheap real call before claiming the behavior works. Save the transcript (prompt, model/version, tool schemas, raw response, parsed output) as an artifact. Mocks may test wrappers and parsers; they do not verify behavior.

### Before reporting done

Read your diff as if a senior engineer asked you to justify every touched line. Check:
- is anything overbuilt?
- is anything unverified?
- does anything look like an LLM added it reflexively (cosplay, mock theater, comment certainty)?
- does the diff mix behavior change with cleanup?
- are any behavior claims backed by real execution, not by inspection alone?

Fix before claiming completion.
