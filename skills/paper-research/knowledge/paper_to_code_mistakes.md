# Knowledge — Paper to Code Mistakes

Use this file when translating paper claims into code or into an existing research codebase.

## 1. Framework convention mismatches
Common traps:
- BatchNorm momentum means different things across PyTorch and TensorFlow.
- "Dropout 0.1" may mean drop probability or keep probability depending on era and framework.
- LayerNorm epsilon is often omitted and framework defaults differ.
- GELU exact vs tanh approximation changes behavior slightly but materially in some models.
- Adam and AdamW are not interchangeable.
- `CrossEntropyLoss` expects logits, not probabilities.
- `KLDivLoss` argument direction and log-space expectations are easy to get wrong.

Never silently assume the paper’s convention matches your framework.

## 2. Batch size semantics
A paper’s "batch size 256" might mean:
- per-device
- global
- effective batch after accumulation

This can invalidate LR scaling and reproduction attempts.
Always check for:
- number of devices
- gradient accumulation
- token-based vs sample-based batching
- whether the schedule is step-based or epoch-based

## 3. Metric implementation drift
A metric name is often not enough.
Examples:
- BLEU implementation and tokenization differ
- FID depends on exact feature extractor and sample count
- top-k accuracy is easy to define slightly differently
- judge-based scores can shift with prompt, rubric, or model version
- RLHF / preference metrics can depend on tie handling or filtering

If the paper says "we report X" but does not specify the exact implementation, treat that as ambiguity.

## 4. Hidden preprocessing
Papers often bury critical preprocessing in:
- appendix
- captions
- supplementary
- official code configs
- tokenizer or data-collator code

Never assume "standard preprocessing" is harmless.

## 5. Figure-vs-text and equation-vs-prose mismatch
Common pattern:
- the figure shows an older architecture
- the text reflects experiments
- the equation is more precise than the prose
- the official repo later changed the implementation

Record the mismatch; do not flatten it away.

## 6. Reproduction vs code cleanliness tradeoff
A faithful research reproduction sometimes needs odd-looking code or unusual parameter choices.
Do not "clean up" a paper-specific mechanism into a more generic design if that changes semantics.
If contributing into an existing repo, preserve semantics first and move excess provenance into docs rather than littering code.

## 7. Silent fallback defaults
LLMs tend to fill gaps with:
- PyTorch defaults
- Hugging Face defaults
- personal memory of "how this is usually done"
- whatever a popular repo used

These are useful candidates, not truth.
Any such choice must stay visible.

## 8. Seed, hardware, and precision blindness
A failure to match reported numbers may come from:
- seed averaging vs a single run
- hardware-specific kernels
- mixed precision mode
- gradient accumulation
- nondeterministic ops
- newer framework behavior

Do not convert these into "the method is wrong" prematurely.
