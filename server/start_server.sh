#!/bin/bash
# ABOUTME: Entrypoint for SF AI Game Jam container
# ABOUTME: Runs the original 5090 start script (ComfyUI, SSH, Jupyter, FileBrowser) then starts Flask

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

# Make setup scripts executable
find "$REPO_DIR/setup" -name "*.sh" -exec chmod +x {} \; 2>/dev/null

# Symlink so server.py paths (/workspace/ComfyUI) resolve to the 5090 location
ln -sfn /workspace/runpod-slim/ComfyUI /workspace/ComfyUI 2>/dev/null

# Export repo path for the Flask server
export REPO_DIR="$REPO_DIR"

# Run the original 5090 start script in the background
# (starts SSH, FileBrowser, Jupyter, ComfyUI setup, etc.)
/start.sh &

# Wait for base services to initialize
echo "Waiting for base services to initialize..."
sleep 10

# Start Flask server on port 8090 (foreground, keeps container alive)
echo "Starting SF AI Game Jam server on port 8090..."
exec python3 /usr/local/bin/server.py
