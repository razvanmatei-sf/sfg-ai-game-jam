#!/bin/bash
# ABOUTME: Thin bootstrap entrypoint baked into the Docker image.
# ABOUTME: Clones/updates the repo then hands off to the repo's start_server.sh.
# This script should rarely need changes — all logic lives in start_server.sh.

WORKSPACE_DIR="/workspace"
REPO_URL="https://github.com/razvanmatei-sf/sfg-ai-game-jam.git"
REPO_DIR="$WORKSPACE_DIR/sfg-ai-game-jam"
BRANCH="main"
PERSISTENT_WORKFLOWS="$WORKSPACE_DIR/workflows"

# Preserve workflows on network volume BEFORE git touches them
# If the repo has a real workflows dir (not a symlink), back it up first
if [ -d "$REPO_DIR/workflows" ] && [ ! -L "$REPO_DIR/workflows" ]; then
    mkdir -p "$PERSISTENT_WORKFLOWS"
    cp -rn "$REPO_DIR/workflows"/. "$PERSISTENT_WORKFLOWS"/ 2>/dev/null || true
    echo "Backed up workflows to persistent storage"
fi

# Clone or update the repository
echo "Syncing repository..."
if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    # Tell git to ignore workflows/ so reset doesn't touch it
    git fetch --all || echo "Warning: git fetch failed"
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" "origin/$BRANCH" || echo "Warning: checkout failed"
    git reset --hard "origin/$BRANCH" || echo "Warning: reset failed"
    git pull origin "$BRANCH" || echo "Warning: pull failed"
else
    rm -rf "$REPO_DIR"
    git clone -b "$BRANCH" "$REPO_URL" "$REPO_DIR" || echo "Warning: clone failed"
fi

# Always replace repo workflows/ with symlink to persistent storage
mkdir -p "$PERSISTENT_WORKFLOWS"
# Seed persistent dir with any new repo workflows (won't overwrite existing)
if [ -d "$REPO_DIR/workflows" ] && [ ! -L "$REPO_DIR/workflows" ]; then
    cp -rn "$REPO_DIR/workflows"/. "$PERSISTENT_WORKFLOWS"/ 2>/dev/null || true
    rm -rf "$REPO_DIR/workflows"
fi
ln -sfn "$PERSISTENT_WORKFLOWS" "$REPO_DIR/workflows"
echo "Workflows symlinked to persistent storage at $PERSISTENT_WORKFLOWS"

# Hand off to the repo's start script (so future changes take effect without rebuilds)
if [ -x "$REPO_DIR/server/start_server.sh" ]; then
    exec "$REPO_DIR/server/start_server.sh"
else
    chmod +x "$REPO_DIR/server/start_server.sh" 2>/dev/null
    exec "$REPO_DIR/server/start_server.sh"
fi
