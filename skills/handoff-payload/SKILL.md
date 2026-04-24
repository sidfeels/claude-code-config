---
name: handoff-payload
description: Build a self-contained payload file (code corpus + unbiased framing + structured ask) for manual paste into a web-only frontier model like GPT-5.4 Pro, Gemini web, or Claude web. Uses code2prompt for the corpus and prompting-techniques for the framing. Load whenever Sid wants to consult a web-only model about code.
argument-hint: "[question / goal / target files]"
---

# Handoff Payload

Build a single file Sid can paste into a web-only model (GPT-5.4 Pro, Claude web, Gemini web, etc.). The file combines three layers:

1. Minimal unbiased context at the top
2. Codebase corpus in the middle (via `code2prompt`)
3. Structured ask at the bottom (framed through `prompting-techniques`)

This skill is for manual handoffs only. For Codex delegation, use `/codex:rescue` directly — no payload file needed.

## Always load alongside
- `prompting-techniques` — the framing rules and templates live there. This skill applies them and adds the corpus layer. Do not write the Task section without reading it first.

## Output convention
Write to `HANDOFF_PAYLOAD.md` in the project root. **Overwrite the same file every time** — no timestamps, no multiple drafts. Sid copies the file, pastes it into the web UI, discards it on the next run. If he needs to keep a prior payload, he will save it out manually before regeneration.

Add `HANDOFF_PAYLOAD.md` to `.gitignore` if not already present.

## Prerequisite check
Run `command -v code2prompt` at the start. If missing, print the install command and stop — do not auto-install.

```bash
# macOS (preferred)
brew install code2prompt

# Or via cargo
cargo install code2prompt
```

Skill was tested against `code2prompt 4.2.0` (the current brew release). The CLI flag surface has drifted across releases — notably clipboard default flipped from opt-out in 4.0.x to opt-in in 4.2.x, and `--token-format` ↔ `--tokens` has swapped. If any command errors with `unexpected argument`, run `code2prompt --help` to confirm the installed surface and adjust before proceeding.

## Workflow

### 1. Understand the real ask
Extract from Sid's invocation and recent conversation:
- **Goal** — the real decision or question
- **Verified facts** — observed in code, logs, tests, traces
- **Observations** — patterns seen, not yet causally explained
- **Suspicions** — current hypotheses, labelled; never promoted to fact
- **Desired deliverable** — ranked hypotheses, critique, rewrite, plan, etc.

If the ask is leadingly phrased ("I think X is the bug, review this"), rewrite it through a blind-diagnosis or targeted-falsification frame before building the payload. Show Sid both the original and the rewrite and let him pick.

### 2. Map the codebase surface
Before running `code2prompt`, use Glob/Grep to identify relevant files. Classify each into one tier:
- **must-include** — target files, entry points, relevant configs, `README.md`, `CLAUDE.md`
- **context-include** — neighboring modules, shared types/interfaces, tests that define behavior
- **noise-exclude** — binaries, checkpoints, datasets, caches, lockfiles (see default list below)

Do not skip this step. Dumping a whole repo with only `.gitignore` as a filter usually ships 10x the needed context and invites context rot.

### 3. Size-check before generating
Run `code2prompt` with `--token-map` **before** writing the final payload. Route output to `/dev/null` for the size probe so stdout stays clean and only the map is printed:

```bash
code2prompt . \
  -i "src/foo/**" -i "README.md" -i "CLAUDE.md" \
  -e "*.pth" -e "*.ckpt" \
  --token-map --token-format format \
  -O /dev/null -q
```

Read the token map. If one file dominates disproportionately, check whether it is truly needed or can be excluded or summarized.

### 4. Manage the token budget
Check the target model's current context window before leaning on large payloads — windows and pricing change. Regardless of the nominal window, performance still degrades as context grows: context rot is real even inside the advertised limit. Single-turn paste is more resilient than multi-turn, which buys some headroom, but it does not eliminate the cost.

Working heuristics, not hard rules:
- **Under 100k tokens** — sweet spot, ship it.
- **100k–200k** — fine for most one-shot handoffs. Target zone when the task needs breadth.
- **200k–500k** — acceptable for important tasks that genuinely need it. Expect degradation; compensate with tighter framing and explicit "focus on X" cues in the Task section.
- **Over 500k** — only if truly unavoidable. Consider two payloads (code vs logs), summarizing a subsystem, or narrowing the question.

Never silently ship a 400k payload for a question that needs 50k. Report the count to Sid and let him decide whether the breadth is worth the rot.

### 5. Generate the corpus
Once include/exclude are dialed in:

```bash
code2prompt . \
  -i "src/foo/**" -i "src/shared/types/**" -i "README.md" -i "CLAUDE.md" \
  -e "*.pth" -e "*.ckpt" -e "*.safetensors" -e "dist/**" \
  --full-directory-tree \
  --line-numbers \
  -F markdown \
  -O HANDOFF_PAYLOAD.md \
  -q
```

- `--full-directory-tree` — shows the model what exists even in excluded areas, so it knows the repo shape
- `--line-numbers` — lets the model cite exact lines in its answer
- `-F markdown` — default; use `xml` only if the target model handles it better for your task
- Clipboard is opt-in in v4.2+ (via `-c, --clipboard`). Since we write to a file, do **not** pass it — otherwise the full corpus lands on the system clipboard and clobbers whatever Sid had copied.

### 6. Wrap with framing
After `code2prompt` writes the file, prepend the Context header and append the Task section. Final shape:

```markdown
# [Short project / subsystem name]

## Context (take with a grain of salt — my framing may be wrong)
[1–3 factual sentences on what the project is and what subsystem we are in.
No root-cause claims. No preferred hypotheses. No "I think...".]

## Codebase
<code2prompt output from step 5>

## Task
[Structured ask. Pick a template from prompting-techniques:
 - Template A — blind diagnosis
 - Template B — targeted falsification
 - Template C — plan critique
 - Template E — rescue / plateau
 - Template F — deep outside consultation (default for GPT-5.4 Pro)]
```

The top Context header is deliberately minimal so the model does not anchor on one interpretation. The full structured ask goes at the bottom so instructions are freshest when the model starts composing its answer.

### 7. Hand off
Report to Sid:
- file path: `./HANDOFF_PAYLOAD.md`
- final token count and which budget zone it falls in
- which Task template was used and why
- one line on what kind of answer to expect back

Sid copies the file verbatim. Do not paraphrase the payload in chat.

## File selection recipes

All recipes assume you have already done the size-check from step 3. Every generation command writes to the file; clipboard is opt-in in v4.2+ so we just omit `-c`.

### Narrow question on a small repo
```bash
code2prompt . \
  -e "*.pth" -e "*.ckpt" -e "*.bin" \
  -O HANDOFF_PAYLOAD.md -q
```
`.gitignore` handling covers most noise. Just drop weights and big binaries.

### Subsystem question on a medium repo
```bash
code2prompt . \
  -i "src/<subsystem>/**" \
  -i "src/shared/**" \
  -i "tests/<subsystem>/**" \
  -i "README.md" -i "CLAUDE.md" \
  -i "pyproject.toml" \
  -O HANDOFF_PAYLOAD.md -q
```

### Surgical on a large repo
Do Glob/Grep first, then include exact files and probe the size:
```bash
code2prompt . \
  -i "src/foo/loop.py" \
  -i "src/foo/data.py" \
  -i "src/foo/config.yaml" \
  -i "README.md" \
  --token-map --token-format format \
  -O /dev/null -q
```
Iterate on the include list until the token map is reasonable, then drop `--token-map --token-format format` and swap `/dev/null` for `HANDOFF_PAYLOAD.md` to write the real file.

### Bug or regression diagnosis
Add git history so the model can see what changed. Note `--git-log-branch` takes two space-separated refs, not comma-separated:
```bash
code2prompt . \
  -i "src/foo/**" \
  --diff \
  --git-log-branch main HEAD \
  -O HANDOFF_PAYLOAD.md -q
```

### Including state files from adjacent skills
If you have state files from other skills that carry thinking the model should see — paper-research artifacts, optimization-loop experiment logs, tried-approaches notes, handoff docs — include them in the `-i` list alongside code. The model then sees the reasoning, not just the source. Example: `-i ".paper_research_work/**/AMBIGUITY_LEDGER.md"` when extending a research-derived codebase and the faithfulness of the baseline is part of the question.

## Default noise exclude list
Start from this for ML and research repos unless a file is specifically needed:

```
-e "*.pth" -e "*.ckpt" -e "*.safetensors" -e "*.bin" -e "*.onnx" -e "*.pt"
-e "*.npy" -e "*.npz" -e "*.parquet" -e "*.arrow" -e "*.h5"
-e "*.log" -e "*.out"
-e "*.lock" -e "poetry.lock" -e "uv.lock" -e "package-lock.json" -e "Cargo.lock"
-e "dist/**" -e "build/**" -e "target/**" -e "*.egg-info/**"
-e "__pycache__/**" -e ".pytest_cache/**" -e ".ruff_cache/**" -e ".mypy_cache/**"
-e "data/**" -e "datasets/**" -e "checkpoints/**" -e "wandb/**" -e "mlruns/**"
-e "node_modules/**" -e ".next/**"
```

Do **not** blanket-exclude `.md`. Docs are context. Only narrow the `.md` scope when the payload is over budget and specific docs are clearly irrelevant to the ask.

## Anti-bias rules (enforced at payload time)
From `prompting-techniques` — restated because this skill is where they bite hardest:

- Never lead with "I think X is the cause, confirm." Use a blind-diagnosis frame.
- In the Task section, label facts, observations, and suspicions separately. Never promote suspicions to facts in the framing.
- Always request structured output (top-N hypotheses, disconfirming evidence, next checks).
- For targeted falsification, ask the model to try to break the hypothesis *first* before supporting it.
- Strip internal commentary that leaks a preferred answer ("obviously the issue is...", "this regressed after the refactor, I'm sure").

If Sid's request itself is leadingly phrased, rewrite it before building the payload. Show both the original and the unbiased rewrite so Sid can choose.

## Common failure modes
- **Over-including** — shipping the whole repo "just in case." Context rot plus wasted Sid time pasting. Always do the token-map step.
- **Under-framing** — no Context header. The model has to infer the project shape from raw code and burns reasoning budget on it.
- **Over-framing** — a 500-word "here is what I think is happening" at the top. The model anchors on your theory. Keep the header to 1–3 factual sentences.
- **Leaking suspicions as facts** — "The bug is in the caching layer. Please review." Rewrite as symptoms + request for ranked hypotheses.
- **Skipping the size check** — generating, then discovering the file is 800k, then regenerating. Always `--token-map` first.
- **Clever templates** — writing custom Handlebars templates to "improve" the corpus format. Use the default markdown output. The model does not need novelty.

## Relationship to other skills
- `prompting-techniques` — always loaded alongside this skill. Templates and framing rules live there.
- `paper-research` — its state files (`PAPER_BRIEF.md`, `AMBIGUITY_LEDGER.md`, `RESULTS.md`) are excellent payload inputs when the ask is research-adjacent.
- `optimization-loop` — when stuck in a plateau, a handoff payload with baseline + tried approaches + plateau pattern is often the unblock. Use Template E.
- `/codex:rescue` — for Codex delegation. No payload file required; Codex sees the repo directly. Use this skill only when the target is web-only.
