# Knowledge — Training and Optimization

Use this file when the paper or extension target involves training, fine-tuning, recipe changes, or measurable optimization.

## Optimizer semantics
- Adam defaults are not universal; transformer papers often use non-default betas and epsilon.
- AdamW is not "Adam with weight decay" in the naive sense.
- Weight decay often excludes bias and normalization parameters even when papers do not say so explicitly.
- SGD recipes often assume momentum 0.9 and LR schedules that are easy to under-specify.

## Learning-rate schedule traps
Check:
- warmup type
- warmup length
- whether stepping is per-step or per-epoch
- cosine vs linear vs inverse-sqrt vs transformer schedule
- whether LR is a base LR or computed formula
- whether LR scaling with batch size is assumed

A schedule mismatch can kill reproduction even when the architecture is correct.

## Batch and token accounting
Always identify:
- sample batch size vs token batch size
- per-device vs global batch
- gradient accumulation steps
- effective batch size
- whether reported steps are optimizer steps or micro-steps

## Mixed precision and EMA
Papers often say "mixed precision" without specifying:
- FP16 or BF16
- whether loss scaling was used
- which ops stayed in FP32

Likewise for EMA:
- decay rate
- when EMA weights are applied
- whether reported eval uses EMA weights or live weights

## Optimization-loop interaction
If the task becomes "search for better settings" rather than "implement the paper," route into `optimization-loop`.
Do not let hyperparameter search silently replace faithful reproduction.
Freeze the paper-faithful baseline first.

## Common training-result mismatch causes
When numbers are off, check:
- schedule mismatch
- batch semantics
- missing weight-decay exclusions
- mixed precision differences
- hidden data filtering
- metric implementation
- evaluation cadence
- seed count
- unofficial code improvements

## Reporting discipline
When changing a training recipe, record:
- exact config change
- baseline
- guardrails
- whether the change is paper-faithful, code-faithful, or extension-only
