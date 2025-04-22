DEVICE=${DEVICE-0}
DOCKER_RUN_FLAGS="-itu`id -u` -eCUDA_MPS_ACTIVE_THREAD_PERCENTAGE \
    -v$HOME/coppock-az/deepcam:/data -w/opt/deepCam \
    --rm --gpus=device=$DEVICE --ipc=host \
    --ulimit=memlock=-1 --ulimit=stack=67108864"

nvidia-cuda-mps-control -d
export CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
for CUDA_MPS_ACTIVE_THREAD_PERCENTAGE in # 12 23 34 45 56 67 78 89 100
do
	# mkdir -p output/s/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
	docker run $DOCKER_RUN_FLAGS \
	    -v$PWD/output/s/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE:/results \
	    mlperf-deepcam sh run_scripts/run_training.sh
done
echo quit | nvidia-cuda-mps-control

for n in 1 2 4 8 16 32
do
	mkdir -p output/n/$n reports
	docker run $DOCKER_RUN_FLAGS -v$PWD/output/n/$n:/results \
	    -v$PWD/reports:/opt/deepCam/reports mlperf-deepcam \
	    nsys profile -oreports/$n -tcuda -snone --cpuctxsw=none \
	    sh run_scripts/run_training.sh --local_batch_size $n
	nsys stats -fcsv -o. -rcuda_gpu_trace reports/$n.qdrep
done
