#!/bin/bash
# 使用 llama.cpp 将 Llama-2-7B 量化为 2-bit (K_S)，以适配 4GB 内存环境

MODEL_DIR="./models/Llama2-7B"
OUT_DIR="./models/quantized"

echo "Step 1: Converting model to GGUF format..."
python3 convert.py $MODEL_DIR

echo "Step 2: Quantizing to Q2_K (Extreme compression for 4GB RAM)..."
# Q2_K 量化通常能将 7B 模型压缩至 2.8GB 左右，预留 1.2GB 给 OS 和 Occlum
./quantize $MODEL_DIR/ggml-model-f16.gguf $OUT_DIR/model_q2_k.gguf Q2_K

echo "Quantization complete. Estimated memory footprint: 2.9GB"