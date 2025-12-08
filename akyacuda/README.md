# Akyacuda Node Benchmark Results

Benchmark results from TRUBA Akyacuda GPU nodes.

## Run Information

- **Date:** 2025-12-06 19:07 - 2025-12-08 03:16
- **Duration:** ~8 hours
- **Nodes Used:** akya2, akya5, akya6, akya9, akya10, akya11, akya12
- **Total Runs:** 400 (171 successful, 210 failed, 19 incomplete/missing data)
- **Consolidated Results:** `all_results.csv` (35 KB, 171 successful runs)

## Performance Highlights

### Top 5 Configurations

| Rank | Performance (ns/day) | Task ID | ntmpi | ntomp | GPUs | Configuration |
|------|---------------------|---------|-------|-------|------|---------------|
| 1 | **227.79** | 149 | 6 | 6 | 2 | dlb=yes, notunepme=0 |
| 2 | **220.08** | 181 | 8 | 5 | 2 | dlb=yes, notunepme=0 |
| 3 | **215.86** | 138 | 6 | 4 | 2 | dlb=yes, notunepme=1, pin=1 |
| 4 | **207.47** | 175 | 8 | 4 | 2 | dlb=yes, notunepme=1 |
| 5 | **200.52** | 180 | 8 | 5 | 2 | dlb=yes, notunepme=1, pin=1 |

### Key Findings

- **Best performance:** 227.79 ns/day with 6 MPI ranks, 6 OpenMP threads, 2 GPUs
- **Optimal GPU count:** 2 GPUs consistently outperform single GPU configurations
- **Optimal parallelization:** 6-8 MPI ranks with 4-6 OpenMP threads per rank
- **Sweet spot:** Total of 24-48 cores (ntmpi × ntomp)

## Directory Contents

```
akyacuda/
├── all_results.csv                    # Consolidated results (171 successful runs)
├── failed_runs.txt                    # List of 210 failed run IDs
├── benchmark_runs_20251206_190739/
│   ├── run_1/                         # Individual successful runs
│   ├── run_2/
│   ├── ...
│   └── failed/                        # Failed runs (210 total)
│       ├── run_3/
│       ├── run_8/
│       └── ...
└── README.md                          # This file
```

## Failed Runs

See `failed_runs.txt` for complete list of 210 failed run IDs.

**Common failure pattern:** Missing `-npme` parameter when `ntmpi >= 4` with GPU PME enabled.

## Each Run Directory Contains

- `benchmark_result.csv` - Summary: timestamp, hostname, task_id, ntmpi, ntomp, gpu_count, dlb, notunepme, pin, runtime_sec, performance_ns_day, status, command
- `benchmark_log.txt` - Configuration and status
- `md.log` - Full GROMACS simulation log
- `gmx_output.log` - GROMACS stdout/stderr
- `ener.edr` - Energy trajectory (binary)

## Quick Analysis

```bash
# View consolidated results
cat all_results.csv

# Find top 10 best performing runs
tail -n+2 all_results.csv | sort -t',' -k11 -rn | head -10 | \
  awk -F',' '{print $11 " ns/day - Task " $3 " (ntmpi=" $4 ", ntomp=" $5 ", GPUs=" $6 ")"}'

# Average performance by GPU count
echo "Single GPU average:" && \
  awk -F',' '$6==1 {sum+=$11; count++} END {print sum/count " ns/day"}' all_results.csv
echo "Dual GPU average:" && \
  awk -F',' '$6==2 {sum+=$11; count++} END {print sum/count " ns/day"}' all_results.csv

# Performance distribution by ntmpi
tail -n+2 all_results.csv | awk -F',' '{print $4}' | sort -n | uniq -c

# Check which nodes were used
tail -n+2 all_results.csv | awk -F',' '{print $2}' | sort | uniq -c

# Count failures by thread count
grep Failed benchmark_runs_20251206_190739/*/benchmark_result.csv | \
  awk -F',' '{print $4}' | sort -n | uniq -c
```
