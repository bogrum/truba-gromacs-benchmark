# GROMACS Benchmark Results - TRUBA GPU Nodes

TRUBA GPU cluster benchmark results for GROMACS molecular dynamics simulations on Akyacuda and Barbuncuda nodes.

## Overview

- **GROMACS Version:** 2025.3
- **Input:** md_0_250ns_nohmr.tpr (250ns water box simulation)
- **Test Steps:** 50,000 MD steps per run
- **Parameter Space:** ntmpi (1-40), ntomp (1-20), GPUs (1-2), DLB/NOTUNEPME/PIN options

## Results Summary

### Akyacuda Node
- **Date:** 2025-12-06 19:07 - 2025-12-08 03:16
- **Status:** ✅ Completed
- **Successful runs:** 171 (42.8%)
- **Failed runs:** 210 (52.5%)
- **Total runs:** 400
- **Best performance:** 227.79 ns/day (6 MPI ranks, 6 OMP threads, 2 GPUs)
- **Results file:** `akyacuda/all_results.csv`

### Barbuncuda Node
- **Status:** 🔄 To be added

## Directory Structure

```
.
├── akyacuda/
│   ├── benchmark_runs_20251206_190739/
│   │   ├── run_1/                    # Successful benchmark runs
│   │   ├── run_2/
│   │   ├── ...
│   │   └── failed/                   # Failed runs (moved here)
│   │       ├── run_3/
│   │       ├── run_8/
│   │       └── ...
│   └── failed_runs.txt               # List of failed run IDs
├── barbuncuda/
│   └── (to be added)
├── md_0_250ns_nohmr.tpr             # Input file (3.6 MB)
├── run_benchmarks.sh                # Benchmark script
└── README.md                        # This file
```

## Each Run Contains

- `benchmark_result.csv` - Performance metrics (ns/day, runtime, etc.)
- `benchmark_log.txt` - Run configuration and status
- `md.log` - GROMACS simulation log
- `gmx_output.log` - GROMACS stdout/stderr
- `ener.edr` - Energy output file

## Failed Runs Analysis (Akyacuda)

**Primary failure cause:** Missing `-npme` parameter when using multi-rank GPU PME

```
Feature not implemented:
PME tasks were required to run on GPUs with multiple ranks but the -npme
option was not specified. A non-negative value must be specified for -npme.
```

Most failures occurred with:
- `ntmpi >= 4` (multiple MPI ranks)
- GPU PME enabled without explicit PME rank specification
- Configuration: `NOTUNEPME=0` (auto PME tuning disabled)

See `akyacuda/failed_runs.txt` for complete list of failed run IDs.

## Usage

### Analyze Akyacuda Results

```bash
# View all successful results
cat akyacuda/benchmark_runs_20251206_190739/run_*/benchmark_result.csv

# Find best performance
grep Success akyacuda/benchmark_runs_20251206_190739/run_*/benchmark_result.csv | \
  awk -F',' '{print $11 " ns/day - " $0}' | sort -rn | head -10

# List failed run IDs
cat akyacuda/failed_runs.txt

# Check failure reasons
grep "Error\|Feature not implemented" \
  akyacuda/benchmark_runs_20251206_190739/failed/*/gmx_output.log
```

### Compare Nodes (after Barbuncuda data is added)

```bash
# Compare best performance across nodes
for node in akyacuda barbuncuda; do
  echo "=== $node ==="
  grep Success $node/*/run_*/benchmark_result.csv 2>/dev/null | \
    awk -F',' '{print $11}' | sort -rn | head -1
done
```

## Reproducibility

All runs used identical simulation parameters:
- 50,000 MD steps
- No configuration output (`-noconfout`)
- GPU acceleration (NB, PME, bonded)
- Same input topology and coordinates

## Notes

- Original dataset size: ~1.4 GB per node (with duplicate .tpr files)
- Optimized size: ~35 MB per node (removed redundant .tpr copies)
- Failed runs preserved for transparency and debugging
- All performance data is from single-node GPU runs on TRUBA infrastructure
- Each node uses identical simulation parameters for fair comparison

## Citation

If you use this benchmark data, please cite GROMACS:
- Abraham et al., SoftwareX 1-2 (2015) 19-25
- DOI: 10.1016/j.softx.2015.06.001
