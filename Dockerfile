FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOST=0.0.0.0
ENV PORT=48285
ENV WORKSPACE_DIR=/workspace
ENV AGENTFLOW_HOME=/root/.agentflow
ENV PATH="/root/.agentflow/bin:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        openssh-client \
        tini && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g npm@latest && \
    npm install -g --include=optional @openai/codex@latest && \
    node --version && \
    npm --version && \
    codex --version && \
    curl -fsSL https://agentflow.geili.ai/installer/getagentflow.sh | \
        AGENTFLOW_SKIP_SERVICE=1 bash -s -- install && \
    mkdir -p /root/.agentflow/data && \
    printf 'HOST=%s\nPORT=%s\n' "$HOST" "$PORT" > /root/.agentflow/data/agentflow.env && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/agentflow-docker-entrypoint
RUN chmod 755 /usr/local/bin/agentflow-docker-entrypoint && \
    mkdir -p "$WORKSPACE_DIR"

WORKDIR /workspace
EXPOSE 48285

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/agentflow-docker-entrypoint"]
CMD ["agentflow"]
