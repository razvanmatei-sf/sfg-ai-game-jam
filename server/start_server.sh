#!/bin/bash
# ABOUTME: Starts the SF AI Game Jam server from the git repo.
# ABOUTME: Called by entrypoint.sh after the repo is cloned/updated.
# This file lives in the repo so changes take effect on pod restart (no rebuild).

WORKSPACE_DIR="/workspace"
REPO_DIR="${REPO_DIR:-$WORKSPACE_DIR/sfg-ai-game-jam}"

# Make setup scripts executable
find "$REPO_DIR/setup" -name "*.sh" -exec chmod +x {} \; 2>/dev/null

# Symlink so server.py paths (/workspace/ComfyUI) resolve to the 5090 location
ln -sfn /workspace/runpod-slim/ComfyUI /workspace/ComfyUI 2>/dev/null

# Initialize passwords file on network volume (creates only if missing)
bash "$REPO_DIR/setup/init_passwords.sh"

# Symlink repo server files over image copies so the server always runs latest code
echo "Linking server files from repo..."
ln -sfn "$REPO_DIR/server/server.py" /usr/local/bin/server.py
ln -sfn "$REPO_DIR/server/user_management.py" /usr/local/bin/user_management.py
ln -sfn "$REPO_DIR/server/templates" /usr/local/bin/templates
ln -sfn "$REPO_DIR/server/static" /usr/local/bin/static

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
