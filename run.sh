#!/bin/bash
set -e

# Read config from HA options.json
if [ -f /data/options.json ]; then
    MODEL_URL=$(jq -r '.model_url // empty' /data/options.json)
    CONTEXT_SIZE=$(jq -r '.context_size // 2048' /data/options.json)
    THREADS=$(jq -r '.threads // 4' /data/options.json)
    GPU_LAYERS=$(jq -r '.gpu_layers // 0' /data/options.json)
else
    echo "ERROR: /data/options.json not found"
    exit 1
fi

MODEL_DIR="/data/models"
MODEL_PATH="${MODEL_DIR}/model.gguf"

# Download model on first run if URL is provided
if [ ! -f "$MODEL_PATH" ] && [ -n "$MODEL_URL" ]; then
    echo "Downloading model from $MODEL_URL ..."
    mkdir -p "$MODEL_DIR"
    curl -L --progress-bar -o "$MODEL_PATH" "$MODEL_URL"
    echo "Model downloaded successfully."
elif [ ! -f "$MODEL_PATH" ]; then
    echo "ERROR: No model found and no model_url configured."
    echo "Set model_url in the add-on configuration to a GGUF file URL."
    exit 1
else
    echo "Using existing model at $MODEL_PATH"
fi

MODEL_SIZE=$(du -h "$MODEL_PATH" | cut -f1)
echo "Model size: $MODEL_SIZE"
echo "Starting llama.cpp server on port 8085 ..."
echo "  Context size: ${CONTEXT_SIZE}"
echo "  Threads: ${THREADS}"
echo "  GPU layers: ${GPU_LAYERS}"

# Explicitly set LD_LIBRARY_PATH and verify libraries are present
export LD_LIBRARY_PATH=/opt/llama-cpp
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "Libraries found:"
ls /opt/llama-cpp/libggml-cpu-*.so 2>/dev/null || echo "  WARNING: No CPU backend libraries found!"
ls /opt/llama-cpp/libggml.so 2>/dev/null || echo "  WARNING: libggml.so not found!"

exec /opt/llama-cpp/llama-server \
    -m "$MODEL_PATH" \
    -c "$CONTEXT_SIZE" \
    -t "$THREADS" \
    -ngl "$GPU_LAYERS" \
    --host 0.0.0.0 \
    --port 8085 \
    --no-warmup
