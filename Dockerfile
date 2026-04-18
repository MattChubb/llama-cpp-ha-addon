FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      jq \
      && \
    rm -rf /var/lib/apt/lists/*

# We'll download the llama.cpp binary at build time
ARG LLAMA_VERSION=b8838
RUN mkdir -p /opt/llama-cpp && \
    curl -sL "https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_VERSION}/llama-${LLAMA_VERSION}-bin-ubuntu-x64.tar.gz" \
      -o /tmp/llama.tar.gz && \
    tar xzf /tmp/llama.tar.gz -C /opt/llama-cpp --strip-components=1 && \
    rm /tmp/llama.tar.gz && \
    chmod +x /opt/llama-cpp/llama-server /opt/llama-cpp/llama-cli

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Persistent data mount
VOLUME ["/data"]

EXPOSE 8080

CMD ["/run.sh"]
