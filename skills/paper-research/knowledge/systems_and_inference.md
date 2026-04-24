# Knowledge — Systems and Inference Papers

Use this file for inference-engine, systems, kernel, serving, caching, or throughput/latency papers.

## 1. Benchmark integrity
Always ask:
- what hardware was used?
- what precision?
- what batch shape?
- warm vs cold runs?
- end-to-end latency or kernel-only?
- were asynchronous effects synchronized before timing?
- is the benchmark measuring useful work or a narrower proxy?

Systems papers are especially vulnerable to apples-to-oranges comparisons.

For benchmark traces, logs, and profiler outputs, run `data-trace-inspection` — sampling raw traces before interpreting aggregates catches most benchmark-integrity violations (dropped work silently, cache state between runs, unsynchronized timing, etc.).

## 2. Build and runtime flags matter
Performance can depend on:
- compiler flags
- CUDA version
- kernel availability
- BLAS/cuDNN choices
- graph capture / torch.compile / XLA / Triton settings
- environment variables
- allocator behavior

If these are unspecified, that is not a minor detail.

## 3. Correctness can silently degrade
A speedup might come from:
- dropped work
- changed precision
- different sampling behavior
- shorter context
- disabled safety or validation checks
- reduced metric fidelity

Always pair performance claims with correctness guardrails.

## 4. Inference-specific ambiguity
Check:
- KV-cache behavior
- batching policy
- scheduler policy
- quantization calibration
- speculative decoding settings
- prefill vs decode timing
- prompt packing
- cache eviction
- memory format assumptions

## 5. Extension surfaces
For systems/inference extensions, good options include:
- throughput vs latency tradeoffs
- cache policy changes
- batching or scheduling changes
- quantization variants
- kernel fusion / compile strategy
- CPU/GPU overlap
- verification and profiling improvements

Again: freeze a faithful baseline before optimizing it.
