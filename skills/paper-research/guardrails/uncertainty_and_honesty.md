# Guardrail — Uncertainty and Honesty

## Bright-line rule
If a detail is not stated in the paper artifact graph, it is **not paper-specified**.
Do not silently promote:
- field defaults
- model memory
- framework defaults
- official-code choices
- strong hunches

into paper truth.

## Allowed provenance labels
Use these precisely:
- **SPECIFIED** — stated in the paper artifacts
- **PARTIALLY_SPECIFIED** — hinted but ambiguous
- **UNSPECIFIED** — missing from the paper artifacts
- **FROM_OFFICIAL_CODE** — resolved by official code
- **CONTRADICTED** — sources disagree materially

## Priority when sources disagree
1. algorithm boxes and equations
2. method text
3. appendix / supplementary / footnotes / captions
4. later arXiv versions / errata
5. official code

When in doubt, record the disagreement explicitly instead of pretending one source silently wins.

## Never-invent protocol
When you must choose for an unspecified item:
- state that it is unspecified
- give the chosen default
- list plausible alternatives
- explain whether the choice is low-impact, high-impact, or blocking

## Phrases to avoid
Never justify an implementation choice with empty phrases like:
- "standard practice"
- "obviously"
- "as usual"
- "should work"
- "for simplicity"

unless you also specify exactly what is meant and why it is acceptable.

## Claim honesty
Do not say:
- "reproduced" when you built a scaffold
- "paper-faithful" when you leaned heavily on official code
- "the paper is impossible" when the real state is "blocking ambiguity remains"

Use narrower language:
- scaffold built
- partial reproduction
- baseline verified
- audit completed
- claim still blocked by X
