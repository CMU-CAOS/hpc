DEVICE=${DEVICE-0}

nvidia-cuda-mps-control -d
export CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
for CUDA_MPS_ACTIVE_THREAD_PERCENTAGE in 13 25 38 50 63 75 88 100
do
	mkdir -p output/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
	docker run -itu`id -u` -eCUDA_MPS_ACTIVE_THREAD_PERCENTAGE \
	    -v/data2/pcoppock/mlcommons/hpc/deepcam/data:/data -w/opt/deepCam \
	    -v$PWD/output/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE:/results \
	    --rm --gpus=device=$DEVICE --ipc=host \
	    --ulimit=memlock=-1 --ulimit=stack=67108864 \
	    mlperf-deepcam sh run_scripts/run_training.sh
done
echo quit | nvidia-cuda-mps-control
