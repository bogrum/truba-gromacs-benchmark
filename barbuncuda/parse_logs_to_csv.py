#!/usr/bin/env python3
import re
import csv

def parse_benchmark_log(file_path):
    """Parse the benchmark log file and extract structured data."""
    results = []

    with open(file_path, 'r') as f:
        content = f.read()

    # Split by separator
    entries = content.split('=' * 40)

    i = 0
    while i < len(entries):
        entry = entries[i].strip()
        if not entry:
            i += 1
            continue

        # Parse task info
        task_match = re.search(r'Task ID:\s*(\d+),\s*Node:\s*(\S+)', entry)
        if not task_match:
            i += 1
            continue

        task_id = int(task_match.group(1))
        node = task_match.group(2)

        # Parse CPUs and threads
        cpu_match = re.search(r'CPUs \(ntmpi\):\s*(\d+),\s*Threads \(ntomp\):\s*(\d+)', entry)
        if not cpu_match:
            i += 1
            continue

        ntmpi = int(cpu_match.group(1))
        ntomp = int(cpu_match.group(2))

        # Parse GPU info
        gpu_match = re.search(r'GPUs:\s*(\d+),\s*DLB:\s*(\S+),\s*NOTUNEPME:\s*(\d+),\s*PIN:\s*(\d+)', entry)
        if not gpu_match:
            i += 1
            continue

        gpus = int(gpu_match.group(1))
        dlb = gpu_match.group(2)
        notunepme = int(gpu_match.group(3))
        pin = int(gpu_match.group(4))

        # Parse command
        cmd_match = re.search(r'Command:\s*(.+?)(?=\n|$)', entry)
        command = cmd_match.group(1).strip() if cmd_match else ""

        # Parse running command
        running_match = re.search(r'Running:\s*(.+?)(?=\n|$)', entry)
        running_cmd = running_match.group(1).strip() if running_match else ""

        # Parse performance (check next entry)
        performance = None
        if i + 1 < len(entries):
            next_entry = entries[i + 1].strip()
            perf_match = re.search(r'Performance:\s*([\d.]+)\s*ns/day', next_entry)
            if perf_match:
                performance = float(perf_match.group(1))

        # Only add if we have performance data (exclude failed runs)
        if performance is not None:
            # Extract bonded type from command
            bonded = "unknown"
            if "-bonded gpu" in command:
                bonded = "gpu"
            elif "-bonded cpu" in command:
                bonded = "cpu"

            # Extract GPU ID
            gpu_id_match = re.search(r'-gpu_id\s+(\S+)', command)
            gpu_id = gpu_id_match.group(1) if gpu_id_match else ""

            # Extract npme
            npme_match = re.search(r'-npme\s+(\d+)', command)
            npme = int(npme_match.group(1)) if npme_match else 1

            results.append({
                'task_id': task_id,
                'node': node,
                'ntmpi': ntmpi,
                'ntomp': ntomp,
                'gpus': gpus,
                'gpu_id': gpu_id,
                'dlb': dlb,
                'notunepme': notunepme,
                'pin': pin,
                'bonded': bonded,
                'npme': npme,
                'performance_ns_per_day': performance,
                'command': command,
                'running_command': running_cmd
            })

        i += 1

    return results

def write_to_csv(results, output_file):
    """Write results to CSV file, sorted by performance (highest to lowest)."""
    # Sort by performance descending
    sorted_results = sorted(results, key=lambda x: x['performance_ns_per_day'], reverse=True)

    # Define CSV columns
    fieldnames = [
        'task_id',
        'performance_ns_per_day',
        'ntmpi',
        'ntomp',
        'gpus',
        'gpu_id',
        'bonded',
        'npme',
        'dlb',
        'notunepme',
        'pin',
        'node',
        'command',
        'running_command'
    ]

    with open(output_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(sorted_results)

    print(f"Wrote {len(sorted_results)} successful runs to {output_file}")
    print(f"Top 5 performances:")
    for i, result in enumerate(sorted_results[:5], 1):
        print(f"  {i}. Task {result['task_id']}: {result['performance_ns_per_day']:.3f} ns/day")

if __name__ == '__main__':
    input_file = 'combined_benchmark_logs.txt'
    output_file = 'benchmark_results.csv'

    results = parse_benchmark_log(input_file)
    write_to_csv(results, output_file)
