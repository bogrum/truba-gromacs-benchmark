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

## Expected Results

Results will include performance metrics (ns/day) across different configurations to compare Barbuncuda GPU performance with Akyacuda nodes.
