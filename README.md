# AgentFlow Docker

执行以下命令。

## Build

```bash
docker build -t agentflow:latest .
```

## Run

```bash
docker run -d \
  --name agentflow \
  -p 3333:3333 \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="you@example.com" \
  -v "$(pwd)/workspace":/workspace \
  -v "$(pwd)/ssh":/root/.ssh \
  -v "$(pwd)/data":/root/.agentflow/data \
  agentflow:latest
```

## Mounted Directories

- `$(pwd)/workspace`: project workspace mounted to `/workspace`
- `$(pwd)/ssh`: Git SSH keys mounted to `/root/.ssh`
- `$(pwd)/data`: AgentFlow data mounted to `/root/.agentflow/data`
