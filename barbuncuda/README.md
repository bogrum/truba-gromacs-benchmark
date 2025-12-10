# Barbuncuda Node Benchmark Results

Benchmark results from TRUBA Barbuncuda GPU nodes (barbun137).

## Status

✅ **Completed** - 2025-12-10

## Overview

- **GROMACS Version:** 2025.3
- **Input:** md_0_250ns_nohmr.tpr (250ns water box simulation)
- **Test Steps:** 50,000 MD steps per run
- **Node:** barbun137
- **Date:** 2025-12-10
- **Successful runs:** 171 out of 192 total runs (89.1%)
- **Best performance:** 147.851 ns/day (6 MPI ranks, 5 OMP threads, 2 GPUs)
- **Results file:** `all_results.csv`

## Directory Structure

```
.
├── benchmark_runs_20251210_000000/
│   ├── run_0/                     # Individual benchmark runs
│   ├── run_1/
│   ├── ...
│   └── run_191/
├── all_results.csv                # Compiled performance results
├── combined_benchmark_logs.txt    # All run logs combined
├── parse_logs_to_csv.py          # Script to extract CSV data
├── run_benchmarks.sh             # Main benchmark script
├── run_benchmarks_part2.sh       # Continuation script
├── task_list_clean.txt           # 171 working configs from Akyacuda
└── README.md                     # This file
```

## Results Summary

The benchmarks tested 171 successful configurations from Akyacuda across various parameters:
- **ntmpi:** 1-40 MPI ranks
- **ntomp:** 1-20 OpenMP threads
- **GPUs:** 1-2 GPUs with different IDs
- **Options:** DLB, NOTUNEPME, PIN variations

### Top Configurations

Best performing configurations (ns/day):
1. 147.851 - ntmpi=6, ntomp=5, gpus=2, npme=1
2. 145.010 - ntmpi=8, ntomp=5, gpus=2, npme=1
3. 139.999 - ntmpi=6, ntomp=6, gpus=2, npme=1

All configurations used:
- GPU acceleration for NB, PME, and bonded interactions
- gpu_id=01 (2 GPUs)
- npme=1 (1 PME rank)

## Task List

### task_list_clean.txt

This file contains **171 successful configurations** extracted from **Akyacuda benchmark results**.

**Why cleaned:**
- Akyacuda tested ~400 different parameter combinations in total
- Only 171 completed successfully
- This task list was prepared to test **only the known-working configurations** on Barbuncuda
- Allows direct performance comparison without wasting time on configurations that may fail

**Format:**
```
task_id	command	ntmpi	ntomp	gpu_count	dlb	notunepme	pin
```

Each line represents a GROMACS mdrun configuration that was successful on Akyacuda.
