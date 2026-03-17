#!/bin/bash
# ABOUTME: Thin bootstrap entrypoint baked into the Docker image.
# ABOUTME: Clones/updates the repo then hands off to the repo's start_server.sh.
# This script should rarely need changes — all logic lives in start_server.sh.

WORKSPACE_DIR="/workspace"
REPO_URL="https://github.com/razvanmatei-sf/sfg-ai-game-jam.git"
REPO_DIR="$WORKSPACE_DIR/sfg-ai-game-jam"
BRANCH="main"
PERSISTENT_WORKFLOWS="$WORKSPACE_DIR/workflows"

# Ensure persistent workflows dir exists
mkdir -p "$PERSISTENT_WORKFLOWS"

# Clone or update the repository
echo "Syncing repository..."
if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    git pull origin "$BRANCH" || echo "Warning: pull failed"
else
    git clone -b "$BRANCH" "$REPO_URL" "$REPO_DIR" || echo "Warning: clone failed"
fi

# Replace repo workflows/ with symlink to persistent network volume.
# Workflows live ONLY on the network volume — git repo copies are discarded.
rm -rf "$REPO_DIR/workflows"
ln -sfn "$PERSISTENT_WORKFLOWS" "$REPO_DIR/workflows"
echo "Workflows symlinked to persistent storage at $PERSISTENT_WORKFLOWS"

# Hand off to the repo's start script (so future changes take effect without rebuilds)
if [ -x "$REPO_DIR/server/start_server.sh" ]; then
    exec "$REPO_DIR/server/start_server.sh"
else
    chmod +x "$REPO_DIR/server/start_server.sh" 2>/dev/null
    exec "$REPO_DIR/server/start_server.sh"
fi
