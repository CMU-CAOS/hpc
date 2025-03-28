DEVICE=${DEVICE-0}

nvidia-cuda-mps-control -d
export CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
for CUDA_MPS_ACTIVE_THREAD_PERCENTAGE in 12 23 34 45 56 67 78 89 100
do
	mkdir -p output/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
	WANDB_MODE=disabled python main.py --mode train \
	    --config configs/mlperf_hpc.yml \
	    --identifier $CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
done
echo quit | nvidia-cuda-mps-control
