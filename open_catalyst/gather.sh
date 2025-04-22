DEVICE=${DEVICE-0}
export WANDB_MODE=disabled

nvidia-cuda-mps-control -d
export CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
for CUDA_MPS_ACTIVE_THREAD_PERCENTAGE in # 12 23 34 45 56 67 78 89 100
do
	mkdir -p output/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
	python main.py --mode train --config configs/mlperf_hpc.yml \
	    --identifier $CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
done
echo quit | nvidia-cuda-mps-control

mkdir -p reports
for n in 2 64 128 256 # 1 2 4 8 16 32
do
	# mkdir -p output/n-$n
	nsys profile -oreports/$n -tcuda -snone --cpuctxsw=none \
	    python main.py --mode train --config configs/mlperf_hpc.yml \
	    --optim.batch_size=$n --identifier n-$n
	nsys stats -fcsv -o. -rcuda_gpu_trace reports/$n.nsys-rep
done
