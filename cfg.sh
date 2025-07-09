#!/bin/bash

set -e
ROOT="configs"
NUM_GPUS=4

START_TIME=$(date +%s)
CONFIGS=($(ls $ROOT/*.yaml))
CONFIGS=($(printf "%s\n" "${CONFIGS[@]}" | sort -R))
TOTAL_CONFIGS=${#CONFIGS[@]}
# Calculate how many configs to assign to each GPU
CONFIGS_PER_GPU=$(( (TOTAL_CONFIGS + NUM_GPUS - 1) / NUM_GPUS ))

process_configs() {
    local gpu=$1
    local start_idx=$2
    local end_idx=$3

    for ((i=start_idx; i<end_idx; i++)); do
        local CONFIG=${CONFIGS[$i]}
        local NAME=$(basename "$CONFIG" .yaml)

        if [[ $NAME == qwen_dare_linear* ]]; then
            echo "Processing $NAME on GPU $gpu"
            CUDA_VISIBLE_DEVICES=$gpu mergekit-yaml "$CONFIG" "./merge_qwen/$NAME" --cuda
        fi
        if [[ $NAME == qwen_linear* ]]; then
            echo "Processing $NAME on GPU $gpu"
            CUDA_VISIBLE_DEVICES=$gpu mergekit-yaml "$CONFIG" "./merge_qwen/$NAME" --cuda
        fi
        if [[ $NAME == qwen_ties* ]]; then
            echo "Processing $NAME on GPU $gpu"
            CUDA_VISIBLE_DEVICES=$gpu mergekit-yaml "$CONFIG" "./merge_qwen/$NAME" --cuda
        fi
        if [[ $NAME == llama_dare_linear* ]]; then
            echo "Processing $NAME on GPU $gpu"
            CUDA_VISIBLE_DEVICES=$gpu mergekit-yaml "$CONFIG" "./merge_llama/$NAME" --cuda
        fi
        if [[ $NAME == llama_linear* ]]; then
            echo "Processing $NAME on GPU $gpu"
            CUDA_VISIBLE_DEVICES=$gpu mergekit-yaml "$CONFIG" "./merge_llama/$NAME" --cuda
        fi
        if [[ $NAME == llama_ties* ]]; then
            echo "Processing $NAME on GPU $gpu"
            CUDA_VISIBLE_DEVICES=$gpu mergekit-yaml "$CONFIG" "./merge_llama/$NAME" --cuda
        fi
        # if [[ $NAME == phi_dare_linear* ]]; then
        #     echo "Processing $NAME on GPU $gpu"
        #     CUDA_VISIBLE_DEVICES=$gpu mergekit-yaml "$CONFIG" "./merge1/$NAME" --cuda
        # fi
        # if [[ $NAME == phi_linear* ]]; then
        #     echo "Processing $NAME on GPU $gpu"
        #     CUDA_VISIBLE_DEVICES=$gpu mergekit-yaml "$CONFIG" "./merge1/$NAME" --cuda
        # fi
        # if [[ $NAME == phi_ties* ]]; then
        #     echo "Processing $NAME on GPU $gpu"
        #     CUDA_VISIBLE_DEVICES=$gpu mergekit-yaml "$CONFIG" "./merge1/$NAME" --cuda
        # fi
    done
}

# Process configs in parallel across GPUs
for ((gpu=0; gpu<NUM_GPUS; gpu++)); do
    start_idx=$((gpu * CONFIGS_PER_GPU))
    end_idx=$((start_idx + CONFIGS_PER_GPU))
    
    # Ensure we don't go past the total number of configs
    if [ $start_idx -lt $TOTAL_CONFIGS ]; then
        if [ $end_idx -gt $TOTAL_CONFIGS ]; then
            end_idx=$TOTAL_CONFIGS
        fi
        process_configs $gpu $start_idx $end_idx &
    fi
done

# Wait for all GPU processes to finish
wait

COST_TIME=$(( $(date +%s) - $START_TIME ))
echo "All models processed in $(($COST_TIME/3600)):$(($COST_TIME%3600/60)):$(($COST_TIME%60))"