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

# Persist ComfyUI settings across container restarts
COMFY_SETTINGS="/workspace/ComfyUI/user/default/comfy.settings.json"
PERSISTED_SETTINGS="/workspace/.comfy.settings.json"
if [ ! -L "$COMFY_SETTINGS" ]; then
    mkdir -p "$(dirname "$COMFY_SETTINGS")"
    [ -f "$COMFY_SETTINGS" ] && [ ! -f "$PERSISTED_SETTINGS" ] && mv "$COMFY_SETTINGS" "$PERSISTED_SETTINGS"
    rm -f "$COMFY_SETTINGS"
    [ ! -f "$PERSISTED_SETTINGS" ] && echo '{}' > "$PERSISTED_SETTINGS"
    ln -s "$PERSISTED_SETTINGS" "$COMFY_SETTINGS"
    echo "Symlinked ComfyUI settings to persistent storage"
fi

# Persist ComfyUI user workflows on network volume (shared across all pods)
COMFY_WORKFLOWS="/workspace/ComfyUI/user/default/workflows"
PERSISTED_COMFY_WORKFLOWS="/workspace/.comfy-workflows"
if [ ! -L "$COMFY_WORKFLOWS" ]; then
    mkdir -p "$PERSISTED_COMFY_WORKFLOWS"
    # Back up any existing workflows before replacing
    if [ -d "$COMFY_WORKFLOWS" ]; then
        cp -rn "$COMFY_WORKFLOWS"/. "$PERSISTED_COMFY_WORKFLOWS"/ 2>/dev/null || true
        rm -rf "$COMFY_WORKFLOWS"
    fi
    ln -sfn "$PERSISTED_COMFY_WORKFLOWS" "$COMFY_WORKFLOWS"
    echo "Symlinked ComfyUI user workflows to persistent storage"
fi

# Symlink repo server files over image copies so the server always runs latest code
echo "Linking server files from repo..."
ln -sfn "$REPO_DIR/server/server.py" /usr/local/bin/server.py
ln -sfn "$REPO_DIR/server/user_management.py" /usr/local/bin/user_management.py
ln -sfn "$REPO_DIR/server/templates" /usr/local/bin/templates
ln -sfn "$REPO_DIR/server/static" /usr/local/bin/static

# Export repo path for the Flask server
export REPO_DIR="$REPO_DIR"

# Start only the services we need — NOT /start.sh which modifies ComfyUI on the network volume
echo "Starting SSH..."
service ssh start 2>/dev/null || /usr/sbin/sshd 2>/dev/null || true

echo "Starting FileBrowser..."
if command -v filebrowser &>/dev/null; then
    filebrowser -r /workspace -p 8080 -a 0.0.0.0 --noauth &>/dev/null &
fi

# Start Flask server on port 8090 (foreground, keeps container alive)
echo "Starting SF AI Game Jam server on port 8090..."
exec python3 /usr/local/bin/server.py
