# Knowledge — Agentic and Post-Training Papers

Use this file for RLHF, DPO, GRPO, reward-model, judge-model, agent-harness, red-teaming, or prompt-sensitive papers.

## 1. Prompt and template are part of the method
In these papers, details like:
- system prompt
- rubric prompt
- judge prompt
- conversation template
- stop tokens
- tool descriptions
- few-shot examples

may be part of the method, not just implementation garnish.

If the paper is vague on prompt or template details, that can be a high-severity ambiguity.

## 2. Reward / judge leakage
For papers involving reward models or judges:
- do not let training data and eval data leak
- do not reuse the same judge prompt for both method design and final evaluation without noting it
- watch for target formatting quirks that inflate scores without improving underlying quality

A judge score jump with no plausible mechanism is a warning sign.

## 3. Post-training objective mismatch
Different papers may mean different things by:
- DPO
- IPO
- ORPO
- GRPO
- RLAIF
- rejection sampling
- reward-weighted fine-tuning

Do not assume a familiar label means the same loss, reference model handling, clipping, or normalization.

## 4. Rollout vs evaluation mismatch
Agent and post-training papers often hide major differences between:
- training prompt
- rollout environment
- evaluation environment
- allowed tools
- timeouts / max turns
- context window
- stop criteria

These differences can dominate results. Record them explicitly.

## 5. Harness behavior is part of the result
For agentic papers, the harness may define:
- retry policy
- parallelism
- planning scaffold
- tool availability
- file visibility
- memory behavior
- judge aggregation
- early stopping

A faithful reproduction needs enough of this harness behavior to test the claim honestly.

## 6. Extension surfaces
Good extension surfaces in this domain include:
- judge design and robustness
- reward-model calibration
- prompt invariance
- failure categorization
- verifier integrity
- trajectory memory hygiene
- search strategy
- tool-use policy
- cost/latency vs quality tradeoffs

If the task becomes optimization-heavy, route to `optimization-loop`.

## 7. Claim labels
Be careful with labels like:
- "agent got better"
- "reasoning improved"
- "reward hacking solved"

Prefer narrower statements tied to measurable outcomes and evaluation integrity.
