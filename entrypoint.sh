#!/usr/bin/env bash

set -euo pipefail

home_dir="${HOME:-/root}"
agentflow_home="${AGENTFLOW_HOME:-$home_dir/.agentflow}"
agentflow_data_dir="$agentflow_home/data"
agentflow_env_path="$agentflow_data_dir/agentflow.env"
workspace_dir="${WORKSPACE_DIR:-/workspace}"
ssh_dir="${GIT_SSH_DIR:-/root/.ssh}"
ssh_key_path="${GIT_SSH_KEY_PATH:-$ssh_dir/id_ed25519}"
ssh_key_comment="${GIT_SSH_KEY_COMMENT:-agentflow-docker}"

prepare_home() {
  mkdir -p "$home_dir"
}

configure_agentflow_runtime() {
  local tmp_env

  export AGENTFLOW_HOME="$agentflow_home"
  export PATH="$agentflow_home/bin:$PATH"

  mkdir -p "$agentflow_data_dir"
  tmp_env=$(mktemp "$agentflow_data_dir/.agentflow.env.XXXXXX")
  if [ -f "$agentflow_env_path" ]; then
    awk -F= '$1 != "HOST" && $1 != "PORT" { print }' "$agentflow_env_path" >"$tmp_env"
  fi

  {
    printf 'HOST=%s\n' "${HOST:-0.0.0.0}"
    printf 'PORT=%s\n' "${PORT:-48285}"
    cat "$tmp_env"
  } >"$agentflow_env_path"
  rm -f "$tmp_env"
}

configure_git_identity() {
  if [ -n "${GIT_USER_NAME:-}" ]; then
    git config --global user.name "$GIT_USER_NAME"
  fi

  if [ -n "${GIT_USER_EMAIL:-}" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
  fi
}

configure_git_workspace() {
  if ! git config --global --get-all safe.directory | grep -Fx -- "$workspace_dir" >/dev/null; then
    git config --global --add safe.directory "$workspace_dir"
  fi
}

configure_ssh_key() {
  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"

  if [ ! -f "$ssh_key_path" ]; then
    ssh-keygen -q -t ed25519 -C "$ssh_key_comment" -f "$ssh_key_path" -N ""
  elif [ ! -f "$ssh_key_path.pub" ]; then
    ssh-keygen -y -f "$ssh_key_path" >"$ssh_key_path.pub"
  fi

  chmod 600 "$ssh_key_path"
  if [ -f "$ssh_key_path.pub" ]; then
    chmod 644 "$ssh_key_path.pub"
  fi

  touch "$ssh_dir/known_hosts"
  chmod 644 "$ssh_dir/known_hosts"
  if ! ssh-keygen -F github.com -f "$ssh_dir/known_hosts" >/dev/null 2>&1; then
    ssh-keyscan -T 5 -H github.com >>"$ssh_dir/known_hosts" 2>/dev/null || true
  fi
}

prepare_home
configure_agentflow_runtime
configure_git_identity
configure_git_workspace
configure_ssh_key

exec "$@"
