FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      jq \
      && \
    rm -rf /var/lib/apt/lists/*

ARG LLAMA_VERSION=b8838
RUN mkdir -p /opt && \
    curl -sL "https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_VERSION}/llama-${LLAMA_VERSION}-bin-ubuntu-x64.tar.gz" \
      -o /tmp/llama.tar.gz && \
    tar xzf /tmp/llama.tar.gz -C /opt && \
    rm /tmp/llama.tar.gz && \
    ln -s /opt/llama-${LLAMA_VERSION} /opt/llama-cpp && \
    chmod -R +x /opt/llama-${LLAMA_VERSION}/

ENV LD_LIBRARY_PATH=/opt/llama-cpp

COPY run.sh /run.sh
RUN chmod +x /run.sh

VOLUME ["/data"]

EXPOSE 8085

CMD ["/run.sh"]
