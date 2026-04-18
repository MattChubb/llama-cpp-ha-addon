# llama.cpp Home Assistant Add-on

Run local LLM inference directly on your Home Assistant server using [llama.cpp](https://github.com/ggml-org/llama.cpp).

Provides an OpenAI-compatible API endpoint (`/v1/chat/completions`) that works with HA integrations like [Llama Assist](https://github.com/M4TH1EU/llama-assist) or any OpenAI-compatible client.

## Features

- Supports any GGUF model (including 1-bit Q1_0 quantisation like [Bonsai](https://github.com/PrismML-Eng/Bonsai-demo))
- OpenAI-compatible API on port 8080
- Automatic model download on first start
- Configurable context size, threads, and GPU layers
- Runs on CPU (no GPU required)

## Installation

1. Go to **Settings → Add-ons → Add-on Store**
2. Click **⋮ → Repositories**
3. Add this repository URL
4. Find "llama.cpp Server" and click **Install**

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `model_url` | string | *(required)* | Direct URL to a GGUF model file |
| `context_size` | int | 2048 | Context window in tokens |
| `threads` | int | 4 | Number of CPU threads |
| `gpu_layers` | int | 0 | GPU layers to offload (0 = CPU only) |

### Example model URLs

- **Bonsai 1.7B (Q1_0):** `https://huggingface.co/prism-ml/Bonsai-1.7B-gguf/resolve/main/Bonsai-1.7B-Q1_0.gguf`
- **Bonsai 4B (Q1_0):** `https://huggingface.co/prism-ml/Bonsai-4B-gguf/resolve/main/Bonsai-4B-Q1_0.gguf`

## Usage

Once running, the API is available at:

```
http://<ha-ip>:8080/v1/chat/completions
```

Test with curl:
```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello!"}],"max_tokens":50}'
```

## Memory Requirements

| Model | Context | RAM needed |
|-------|---------|------------|
| Bonsai 1.7B Q1_0 | 2048 | ~760 MB |
| Bonsai 4B Q1_0 | 2048 | ~1.5 GB |
| Bonsai 8B Q1_0 | 8192 | ~2.5 GB |

## Performance Note

CPU-only inference is slow (~0.5-1 token/sec). For usable speeds, you need a GPU. This add-on is best for experimenting with local LLMs on HA hardware.
