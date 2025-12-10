#!/bin/bash
#SBATCH --job-name=gmx_benchmark_akya
#SBATCH --account=ecevik
#SBATCH --partition=barbun-cuda
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --gres=gpu:2
#SBATCH --array=0-91
#SBATCH --output=benchmark_runs_barbuncuda/slurm_%A_%a.out
#SBATCH --error=benchmark_runs_barbuncuda/slurm_%A_%a.err

module purge
source /arf/scratch/ecevik/gromacs_work/prep.sh

OFFSET=100
TASK_ID=$((SLURM_ARRAY_TASK_ID + OFFSET))
MAIN_DIR="benchmark_runs_barbuncuda"
TASK_LIST="$MAIN_DIR/task_list_clean.txt"
TPR_FILE="md_0_250ns_nohmr.tpr"

# DÜZELT: cut -f kullan (TAB delimiter)
TASK_LINE=$(sed -n "$((TASK_ID + 1))p" $TASK_LIST)
TASK_NUM=$(echo "$TASK_LINE" | cut -f1)
GMX_CMD=$(echo "$TASK_LINE" | cut -f2)
NTMPI=$(echo "$TASK_LINE" | cut -f3)
NTOMP=$(echo "$TASK_LINE" | cut -f4)
GPU_COUNT=$(echo "$TASK_LINE" | cut -f5)
DLB=$(echo "$TASK_LINE" | cut -f6)
NOTUNEPME=$(echo "$TASK_LINE" | cut -f7)
PIN=$(echo "$TASK_LINE" | cut -f8)

RUN_DIR="$MAIN_DIR/run_${TASK_ID}"
mkdir -p "$RUN_DIR"
cd "$RUN_DIR"

if [ ! -f "$TPR_FILE" ]; then
    cp "${SLURM_SUBMIT_DIR}/$TPR_FILE" . || ln -s "${SLURM_SUBMIT_DIR}/$TPR_FILE" .
fi

LOG_FILE="benchmark_log.txt"
RESULT_FILE="benchmark_result.csv"

echo "========================================" | tee -a $LOG_FILE
echo "Task ID: $TASK_ID, Node: $(hostname)" | tee -a $LOG_FILE
echo "CPUs (ntmpi): $NTMPI, Threads (ntomp): $NTOMP" | tee -a $LOG_FILE
echo "GPUs: $GPU_COUNT, DLB: $DLB, NOTUNEPME: $NOTUNEPME, PIN: $PIN" | tee -a $LOG_FILE
echo "Command: $GMX_CMD" | tee -a $LOG_FILE
echo "========================================" | tee -a $LOG_FILE

START_TIME=$(date +%s)

FULL_CMD="$GMX_CMD -nsteps 50000 -noconfout -dlb $DLB"
if [ "$NOTUNEPME" = "1" ]; then
    FULL_CMD="$FULL_CMD -notunepme"
fi
if [ "$PIN" = "1" ]; then
    FULL_CMD="$FULL_CMD -pin on"
fi

echo "Running: $FULL_CMD" | tee -a $LOG_FILE

eval $FULL_CMD > gmx_output.log 2>&1
GMX_EXIT_CODE=$?

END_TIME=$(date +%s)
RUNTIME=$((END_TIME - START_TIME))

PERFORMANCE=$(grep "Performance:" gmx_output.log | awk '{print $2}')

if [ -z "$PERFORMANCE" ]; then
    PERFORMANCE="0.0"
    STATUS="Failed"
    echo "Status: FAILED" | tee -a $LOG_FILE
else
    STATUS="Success"
    echo "Performance: $PERFORMANCE ns/day" | tee -a $LOG_FILE
fi

echo "timestamp,hostname,task_id,ntmpi,ntomp,gpu_count,dlb,notunepme,pin,runtime_sec,performance_ns_day,status,command" > $RESULT_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S'),$(hostname),$TASK_ID,$NTMPI,$NTOMP,$GPU_COUNT,$DLB,$NOTUNEPME,$PIN,$RUNTIME,$PERFORMANCE,$STATUS,\"$FULL_CMD\"" >> $RESULT_FILE

SUMMARY_FILE="$MAIN_DIR/all_results.csv"
if [ ! -f "$SUMMARY_FILE" ]; then
    echo "timestamp,hostname,task_id,ntmpi,ntomp,gpu_count,dlb,notunepme,pin,runtime_sec,performance_ns_day,status,command" > $SUMMARY_FILE
fi
echo "$(date '+%Y-%m-%d %H:%M:%S'),$(hostname),$TASK_ID,$NTMPI,$NTOMP,$GPU_COUNT,$DLB,$NOTUNEPME,$PIN,$RUNTIME,$PERFORMANCE,$STATUS,\"$FULL_CMD\"" >> $SUMMARY_FILE

echo "Task $TASK_ID completed"
