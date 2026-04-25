# Guardrail — Environment and Compute

## Purpose
Prevent careless environment changes, shared-resource misuse, and artifact sprawl.

## First question
Before builds, downloads, or runs, determine the environment:

- **local-mac**
- **shared-gpu-server**
- **other / unknown**

If unknown, ask Sid before proceeding with anything expensive or invasive.

## Artifact storage defaults
For this workflow, keep research artifacts inside the active project:
- `.paper_research_work/<paper_slug>/artifacts/`
- `.paper_research_work/<paper_slug>/logs/`
- `.paper_research_work/<paper_slug>/results/`

Do not scatter papers, extracted sources, notebooks, or logs across home directories or shared temp directories unless Sid explicitly wants that.

## Python environment default
Use a **project-local** environment.
Prefer:
```bash
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

Do not install project dependencies into system Python.
Do not use global `pip install` for project-specific work.

## Local Mac profile
Use when Sid is working on the personal machine.

Known facts:
- MacBook Pro
- Apple M4 Pro
- ARM64 / Apple Silicon
- macOS 15.6
- system Python 3.9.6
- `uv 0.9.10` available
- PyTorch work should prefer MPS, not CUDA

Implications:
- use a project-local `.venv`
- avoid CUDA-only assumptions
- prefer CPU or MPS smoke checks unless Sid explicitly wants more
- keep project work inside the project directory, not the home directory root

If a paper or repo assumes CUDA, note that local Mac execution may only support:
- CPU
- MPS
- or partial verification

Do not pretend a CUDA-only reproduction is locally reproducible on Mac if it is not.

## Shared GPU server profile
Use when Sid says the task is on the shared GPU box.

Known facts:
- user: `sid`
- home: `/home/sid`
- Ubuntu 22.04
- Python 3.10.12
- `uv 0.9.16`
- CUDA 13.0
- PyTorch 2.9.0+cu128
- 4x NVIDIA RTX PRO 6000 GPUs
- shared multi-user machine
- disk is often tight; avoid unnecessary large downloads

Strict rules:
- never use `sudo`
- never kill or pkill arbitrary processes
- never kill ports to free them; find a free port instead
- stay inside Sid’s directories
- ask Sid before starting GPU-heavy or long-running jobs
- use a project-local `.venv`
- use `CUDA_VISIBLE_DEVICES` if Sid specifies a GPU
- use `tmux` or similar for long-running jobs
- do not clutter shared `/tmp`
- do not download giant models or datasets without checking whether they already exist or whether Sid wants them
- before downloading large models/datasets, check for an org-shared cache convention (e.g. `HF_HOME`, `TRANSFORMERS_CACHE`, `HF_DATASETS_CACHE` pointing at a shared directory; or a mounted dataset path). Duplicating large downloads per-user wastes shared disk and is one of the most common preventable mistakes on shared GPU boxes
- never touch `/home/other_user/`, `/etc/`, or other system-owned locations

Suggested working locations:
- project code: `~/work/<project>/`
- reusable models/checkpoints: `~/models/`
- project-local research artifacts: `<project>/.paper_research_work/`

Before any GPU job, check availability with `nvidia-smi`.

If a port is busy, find another free port instead of killing the process using it.

## Heavy operations that require Sid confirmation
Ask before:
- full training runs
- long GPU jobs
- large dataset downloads
- multi-GB checkpoint downloads
- new environment stacks that materially change the machine state
- benchmark runs that could monopolize shared resources

## Environment updates
If new durable environment facts are discovered, record them in the appropriate environment file or project notes.
Do not update environment docs with transient one-off facts that will go stale quickly.
