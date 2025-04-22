DEVICE=${DEVICE-0}
DOCKER_RUN_FLAGS="-itu`id -u` -eCUDA_MPS_ACTIVE_THREAD_PERCENTAGE -v$PWD:$PWD \
    -w$PWD --rm --gpus=device=$DEVICE --ipc=host \
    --ulimit=memlock=-1 --ulimit=stack=67108864"

cosmoflow() {
	docker run -itu`id -u` -eCUDA_MPS_ACTIVE_THREAD_PERCENTAGE \
	    -v$PWD:$PWD -w$PWD --rm --gpus=device=$DEVICE --ipc=host \
	    --ulimit=memlock=-1 --ulimit=stack=67108864 \
	    cosmoflow python train.py "$@"
}

nvidia-cuda-mps-control -d
export CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
for CUDA_MPS_ACTIVE_THREAD_PERCENTAGE in # 12 23 34 45 56 67 78 89 100
do
	mkdir -p output/s/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
	docker run $DOCKER_RUN_FLAGS cosmoflow python train.py \
	    --output-dir=output/s/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE \
	    configs/cosmo_dummy.yaml
done
echo quit | nvidia-cuda-mps-control

mkdir -p reports
for n in 32 64 # 1 2 4 8 16
do
	mkdir -p output/$n
	docker run $DOCKER_RUN_FLAGS cosmoflow \
	    nsys profile -oreports/$n -tcuda -snone --cpuctxsw=none \
	    python train.py --batch-size=$n \
	    --output-dir=output/n/$n configs/cosmo_dummy.yaml
done
