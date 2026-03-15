#!/bin/bash
# ABOUTME: Updates ComfyUI to the latest version.
# ABOUTME: Pulls latest code and reinstalls requirements.

set -e

echo "Updating ComfyUI..."

cd /workspace/ComfyUI
source /workspace/runpod-slim/ComfyUI/.venv-cu128/bin/activate
pip install uv 2>/dev/null || true

git stash
git pull --force

uv pip install -r requirements.txt

echo "ComfyUI update complete"
