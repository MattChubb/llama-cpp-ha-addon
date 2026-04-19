FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      jq \
      libgomp1 \
      && \
    rm -rf /var/lib/apt/lists/*

ARG LLAMA_VERSION=b8838
RUN mkdir -p /opt/llama-cpp && \
    curl -sL "https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_VERSION}/llama-${LLAMA_VERSION}-bin-ubuntu-x64.tar.gz" \
      -o /tmp/llama.tar.gz && \
    cd /tmp && tar xzf llama.tar.gz && \
    cp -a /tmp/llama-${LLAMA_VERSION}/* /opt/llama-cpp/ && \
    rm -rf /tmp/llama.tar.gz /tmp/llama-${LLAMA_VERSION} && \
    chmod -R +x /opt/llama-cpp/

# Set library path as build-time ENV
ENV LD_LIBRARY_PATH=/opt/llama-cpp

COPY run.sh /run.sh
RUN chmod +x /run.sh

VOLUME ["/data"]

EXPOSE 8085

CMD ["/run.sh"]
