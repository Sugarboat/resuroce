#!/bin/bash
# Description: Quantization script to fit 7B LLM into a 4GB RAM TEE environment.
# Tool: llama.cpp

set -e

MODEL_NAME="Llama-2-7b-chat"
ORIGINAL_MODEL="./models/$MODEL_NAME"
GGUF_MODEL="./models/$MODEL_NAME-f16.gguf"
QUANTIZED_MODEL="./models/$MODEL_NAME-Q4_K_M.gguf"

echo "[1/3] Converting original weights to GGUF format..."
python3 convert.py $ORIGINAL_MODEL --outfile $GGUF_MODEL

echo "[2/3] Quantizing to 4-bit (Q4_K_M)..."
# Q4_K_M is the best balance for 4GB RAM systems.
./quantize $GGUF_MODEL $QUANTIZED_MODEL Q4_K_M

echo "[3/3] Verification:"
ls -lh $QUANTIZED_MODEL
echo "Final model size should be approx 3.8GB, fitting within the 4.2GB TEE footprint."