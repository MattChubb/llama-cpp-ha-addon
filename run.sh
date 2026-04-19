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

if [ ! -f "$MODEL_PATH" ] && [ -n "$MODEL_URL" ]; then
    echo "Downloading model from $MODEL_URL ..."
    mkdir -p "$MODEL_DIR"
    curl -L --progress-bar -o "$MODEL_PATH" "$MODEL_URL"
    echo "Model downloaded successfully."
elif [ ! -f "$MODEL_PATH" ]; then
    echo "ERROR: No model found and no model_url configured."
    exit 1
else
    echo "Using existing model at $MODEL_PATH"
fi

echo "=== DEBUG: Checking library dependencies ==="
cd /opt/llama-cpp

# Check if libggml.so symlink chain is intact
echo "--- libggml.so symlink chain ---"
ls -la libggml.so* 2>/dev/null
echo "--- libggml-base.so symlink chain ---"
ls -la libggml-base.so* 2>/dev/null
echo "--- libllama.so symlink chain ---"
ls -la libllama.so* 2>/dev/null

# Try to manually load a CPU backend and see what error we get
echo "--- Testing CPU backend load ---"
LD_LIBRARY_PATH=/opt/llama-cpp ldd libggml-cpu-haswell.so 2>&1 | head -20

echo "--- Testing RPC backend load (for comparison) ---"
LD_LIBRARY_PATH=/opt/llama-cpp ldd libggml-rpc.so 2>&1 | head -20

echo "=== END DEBUG ==="

echo "Starting llama.cpp server..."
exec /lib64/ld-linux-x86-64.so.2 \
    --library-path /opt/llama-cpp \
    /opt/llama-cpp/llama-server \
    -m "$MODEL_PATH" \
    -c "$CONTEXT_SIZE" \
    -t "$THREADS" \
    -ngl "$GPU_LAYERS" \
    --host 0.0.0.0 \
    --port 8085 \
    --no-warmup
