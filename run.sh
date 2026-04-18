#!/bin/bash
set -e

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
echo "Starting llama.cpp server on port 8080 ..."
echo "  Context size: ${CONTEXT_SIZE}"
echo "  Threads: ${THREADS}"
echo "  GPU layers: ${GPU_LAYERS}"

export LD_LIBRARY_PATH=/opt/llama-cpp:$LD_LIBRARY_PATH

exec /opt/llama-cpp/llama-server \
    -m "$MODEL_PATH" \
    -c "$CONTEXT_SIZE" \
    -t "$THREADS" \
    -ngl "$GPU_LAYERS" \
    --host 0.0.0.0 \
    --port 8080 \
    --no-warmup
