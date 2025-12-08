# Barbuncuda Node Benchmark Results

Benchmark results from TRUBA Barbuncuda GPU nodes.

## Status

🔄 **To be added**

Benchmarks will be run with identical parameters as Akyacuda for fair comparison:
- Same GROMACS version (2025.3)
- Same input file (md_0_250ns_nohmr.tpr)
- Same parameter space (ntmpi 1-40, ntomp 1-20, etc.)
- 50,000 MD steps per run

## Planned Structure

```
benchmark_runs_YYYYMMDD_HHMMSS/
├── run_1/
├── run_2/
├── ...
└── failed/          # If any runs fail
```

## Task List

### task_list_clean.txt

This file contains **171 successful configurations** extracted from **Akyacuda benchmark results**.

**Why cleaned:**
- Akyacuda tested 350 different parameter combinations in total
- Only 171 of them completed successfully (some configurations failed due to runtime errors, resource constraints, etc.)
- This task list was prepared to test **only the known-working configurations** on Barbuncuda
- This allows direct performance comparison without wasting time on configurations that may fail

**Format:**
```
task_id	command	ntmpi	ntomp	gpu_count	dlb	notunepme	pin
```

Each line represents a GROMACS mdrun configuration that was successful on Akyacuda.

## Expected Results

Results will include performance metrics (ns/day) across different configurations to compare Barbuncuda GPU performance with Akyacuda nodes.
