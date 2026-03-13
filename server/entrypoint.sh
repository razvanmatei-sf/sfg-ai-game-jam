#!/bin/bash
# ABOUTME: Thin bootstrap entrypoint baked into the Docker image.
# ABOUTME: Clones/updates the repo then hands off to the repo's start_server.sh.
# This script should rarely need changes — all logic lives in start_server.sh.

WORKSPACE_DIR="/workspace"
REPO_URL="https://github.com/razvanmatei-sf/sfg-ai-game-jam.git"
REPO_DIR="$WORKSPACE_DIR/sfg-ai-game-jam"
BRANCH="main"

# Clone or update the repository
echo "Syncing repository..."
if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    git fetch --all || echo "Warning: git fetch failed"
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" "origin/$BRANCH" || echo "Warning: checkout failed"
    git reset --hard "origin/$BRANCH" || echo "Warning: reset failed"
    git pull origin "$BRANCH" || echo "Warning: pull failed"
else
    rm -rf "$REPO_DIR"
    git clone -b "$BRANCH" "$REPO_URL" "$REPO_DIR" || echo "Warning: clone failed"
fi

# Hand off to the repo's start script (so future changes take effect without rebuilds)
if [ -x "$REPO_DIR/server/start_server.sh" ]; then
    exec "$REPO_DIR/server/start_server.sh"
else
    chmod +x "$REPO_DIR/server/start_server.sh" 2>/dev/null
    exec "$REPO_DIR/server/start_server.sh"
fi
