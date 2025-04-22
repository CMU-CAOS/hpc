DEVICE=${DEVICE-0}
DOCKER_RUN_FLAGS="-itu`id -u` -eCUDA_MPS_ACTIVE_THREAD_PERCENTAGE \
    -v$HOME/coppock-az:/data --rm --gpus=device=$DEVICE --ipc=host \
    --ulimit=memlock=-1 --ulimit=stack=67108864"
TRAIN_FLAGS="--training_dirpath /results \
    --pdb_mmcif_chains_filepath /data/pdb_data/pdb_mmcif/processed/chains.csv \
    --pdb_mmcif_dicts_dirpath /data/pdb_data/pdb_mmcif/processed/dicts \
    --pdb_obsolete_filepath /data/pdb_data/pdb_mmcif/processed/obsolete.dat \
    --pdb_alignments_dirpath /data/pdb_data/open_protein_set/processed/pdb_alignments \
    --initialize_parameters_from /data/mlperf_hpc_openfold_resumable_checkpoint_b518be46.pt \
    --train_max_pdb_release_date 2021-12-11 \
    --target_avg_lddt_ca_value 0.9 \
    --seed 1234567890 \
    --num_train_iters 8 \
    --base_lr 1e-3 \
    --warmup_lr_init 1e-5 \
    --warmup_lr_iters 0 \
    --num_train_dataloader_workers 2 \
    --num_val_dataloader_workers 1 \
    --use_only_pdb_chain_ids 7ny6_A 7e6g_A"

nvidia-cuda-mps-control -d
export CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
for CUDA_MPS_ACTIVE_THREAD_PERCENTAGE in # 12 23 34 45 56 67 78 89 100
do
	# mkdir -p output/s/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
	docker run $DOCKER_RUN_FLAGS \
	    -v$PWD/output/s/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE:/results \
	    openfold_pyt python train.py $TRAIN_FLAGS --local_batch_size 1
done
echo quit | nvidia-cuda-mps-control

mkdir -p reports
for n in 1 2 4
do
	mkdir -p output/n/$n
	docker run $DOCKER_RUN_FLAGS -v$PWD/output/n/$n:/results \
	    -v$PWD/reports:/workspace/openfold/reports openfold_pyt \
	    nsys profile -oreports/$n -tcuda -snone --cpuctxsw=none \
	    python train.py $TRAIN_FLAGS --local_batch_size $n
	nsys stats -fcsv -o. -rcuda_gpu_trace reports/$n.nsys-rep
done
