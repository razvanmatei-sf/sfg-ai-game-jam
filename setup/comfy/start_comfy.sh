#!/bin/bash

# Install psmisc (for fuser) if not already present
command -v fuser >/dev/null 2>&1 || { apt update && apt install -y psmisc; }

# Kill ALL ComfyUI processes and wait for port 8188 to free
pkill -9 -f "ComfyUI/main.py" 2>/dev/null || true
fuser -k -9 8188/tcp 2>/dev/null || true
for i in $(seq 1 30); do
    fuser 8188/tcp >/dev/null 2>&1 || break
    sleep 1
done
# Final force kill if something is still holding the port
fuser -k -9 8188/tcp 2>/dev/null || true
sleep 1

source /workspace/runpod-slim/ComfyUI/.venv-cu128/bin/activate
cd /workspace/runpod-slim/ComfyUI

# Build command args
ARGS="--listen 0.0.0.0"
if [ -n "$COMFY_OUTPUT_DIR" ]; then
    mkdir -p "$COMFY_OUTPUT_DIR"
    ARGS="$ARGS --output-directory \"$COMFY_OUTPUT_DIR\""
fi

eval python main.py $ARGS
