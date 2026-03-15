#!/bin/bash

# Setup SSH keys from persistent storage (for private repo access)
mkdir -p ~/.ssh
if [ -d "/workspace/.ssh" ]; then
    cp -r /workspace/.ssh/* ~/.ssh/ 2>/dev/null || true
    chmod 600 ~/.ssh/id_* 2>/dev/null || true
fi
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts 2>/dev/null

# Sync workflows from private repo
cd /workspace/runpod-slim/ComfyUI/user/default/workflows
git pull

apt update
apt install -y psmisc
fuser -k 8188/tcp 2>/dev/null || true

source /workspace/runpod-slim/ComfyUI/.venv-cu128/bin/activate
cd /workspace/runpod-slim/ComfyUI

# Build command args
ARGS="--listen 0.0.0.0"
if [ -n "$COMFY_OUTPUT_DIR" ]; then
    mkdir -p "$COMFY_OUTPUT_DIR"
    ARGS="$ARGS --output-directory \"$COMFY_OUTPUT_DIR\""
fi

eval python main.py $ARGS
