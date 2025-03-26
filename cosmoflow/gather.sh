DEVICE=${DEVICE-0}

nvidia-cuda-mps-control -d
export CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
for CUDA_MPS_ACTIVE_THREAD_PERCENTAGE in 12 23 34 45 56 67 78 89 100
do
	mkdir -p output/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
	docker run -itu`id -u` -eCUDA_MPS_ACTIVE_THREAD_PERCENTAGE \
	    -v$PWD:$PWD \
	    -v/data2/pcoppock/mlcommons/hpc/cosmoUniverse_2019_05_4parE_tf_v2_mini:/data \
	    -w$PWD --rm --gpus=device=$DEVICE --ipc=host \
	    --ulimit=memlock=-1 --ulimit=stack=67108864 \
	    cosmoflow python train.py \
	    --output-dir=output/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE \
	    configs/cosmo_dummy.yaml
done
echo quit | nvidia-cuda-mps-control
