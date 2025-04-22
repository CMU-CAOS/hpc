#!/bin/bash
  
# Function to run the training script multiple times
run_training_iterations() {
  local outer_index=$1
  for i in {1..1}; do
    echo "Outer loop index: $outer_index, Starting iteration $i..."
    # Run the training script in the background, redirecting all output to out_outerIndex_i.txt
    #WANDB_MODE=disabled time python main.py --mode train --config-yml configs/mlperf_hpc.yml > "timing_results/out_${outer_index}_${i}.txt" 2>&1
    #python3 train.py --data-dir /hpc/cosmoflow/data/cosmoUniverse_2019_05_4parE_tf_v2_mini --n-train 1024 --n-valid 1024 --n-epochs 5 > "timing_results/out_${outer_index}_${i}v2.txt" 2>&1
    python train.py --output-dir=timing_results configs/cosmo_dummy.yaml > "timing_results/out_${outer_index}_${i}v2.txt" 2>&1
    #wait
  done
  echo "All iterations initiated for outer loop index: $outer_index."
}

# Outer loop to call the function 10 times
# Declare an array with desired GPU clock speeds
clock_speeds=(1410 1320 1215 1110 1005 900 810 705 600 510)
for j in {1..10}; do
  # Select the third clock speed (index 2)
  selected_speed=${clock_speeds[$j-1]}
  nvidia-smi -lgc $selected_speed,$selected_speed
  sleep 5
  ./power > "power_results/power_${j}v2.txt" &
  POWER_PID=$!
  #run_training_iterations $j
  #WANDB_MODE=disabled time python main.py --mode train --config-yml configs/mlperf_hpc.yml > "timing_results/out_${j}_1.txt" 2>&1
  #python3 train.py --data-dir /hpc/cosmoflow/data/cosmoUniverse_2019_05_4parE_tf_v2_mini --n-train 1024 --n-valid 1024 --n-epochs 5 > "timing_results/out_${j}_1v2.txt" 2>&1
  python train.py --output-dir=timing_results configs/cosmo_dummy.yaml > "timing_results/out_${j}_1v2.txt" 2>&1
  kill -9 ${POWER_PID}
  "$POWER_PID" 2>/dev/null
  sleep 5
done
