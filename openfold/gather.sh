DEVICE=${DEVICE-0}

nvidia-cuda-mps-control -d
export CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
for CUDA_MPS_ACTIVE_THREAD_PERCENTAGE in 13 25 38 50 63 75 88 100
do
	mkdir -p output/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE
	docker run -itu`id -u` -eCUDA_MPS_ACTIVE_THREAD_PERCENTAGE \
	    -v$HOME/coppock-az:/data \
	    -v$PWD/output/$CUDA_MPS_ACTIVE_THREAD_PERCENTAGE:/results \
	    --rm --gpus=device=$DEVICE --ipc=host \
	    --ulimit=memlock=-1 --ulimit=stack=67108864 \
	    openfold_pyt python train.py \
	    --training_dirpath /results \
	    --pdb_mmcif_chains_filepath /data/pdb_data/pdb_mmcif/processed/chains.csv \
	    --pdb_mmcif_dicts_dirpath /data/pdb_data/pdb_mmcif/processed/dicts \
	    --pdb_obsolete_filepath /data/pdb_data/pdb_mmcif/processed/obsolete.dat \
	    --pdb_alignments_dirpath /data/pdb_data/open_protein_set/processed/pdb_alignments \
	    --initialize_parameters_from /data/mlperf_hpc_openfold_resumable_checkpoint_b518be46.pt \
	    --train_max_pdb_release_date 2021-12-11 \
	    --target_avg_lddt_ca_value 0.9 \
	    --seed 1234567890 \
	    --num_train_iters 8 \
	    --local_batch_size 1 \
	    --base_lr 1e-3 \
	    --warmup_lr_init 1e-5 \
	    --warmup_lr_iters 0 \
	    --num_train_dataloader_workers 2 \
	    --num_val_dataloader_workers 1 \
	    --use_only_pdb_chain_ids 7ny6_A 7e6g_A
done
echo quit | nvidia-cuda-mps-control
