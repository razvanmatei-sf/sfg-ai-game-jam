#!/bin/bash
# ABOUTME: Sets up symlinked folder structure for ComfyUI after installation.
# ABOUTME: Moves models/output/input folders to /workspace and creates symlinks back.

set -e

echo "Setting up ComfyUI folder structure..."

COMFY_DIR="/workspace/ComfyUI"

# Function to move folder and create symlink
# Usage: setup_folder <comfy_subfolder> <workspace_destination>
setup_folder() {
    local comfy_path="$COMFY_DIR/$1"
    local workspace_path="/workspace/$2"
    
    # Skip if source doesn't exist
    if [ ! -e "$comfy_path" ]; then
        echo "Warning: $comfy_path does not exist, skipping"
        return
    fi
    
    # Skip if already a symlink (already set up)
    if [ -L "$comfy_path" ]; then
        echo "$1 is already a symlink, skipping"
        return
    fi
    
    echo "Moving $1 to $workspace_path..."
    mv "$comfy_path" "$workspace_path"
    
    echo "Creating symlink: $comfy_path -> $workspace_path"
    ln -s "$workspace_path" "$comfy_path"
}

setup_folder "models" "models"
setup_folder "output" "outputs"
setup_folder "input" "inputs"

# Setup workflows symlink
# /workspace/workflows/ is for user workflows saved in ComfyUI
echo "Setting up workflows folder..."

COMFY_WORKFLOWS="$COMFY_DIR/user/default/workflows"
WORKSPACE_WORKFLOWS="/workspace/workflows"

if [ -L "$COMFY_WORKFLOWS" ]; then
    echo "Workflows is already a symlink, skipping"
else
    mkdir -p "$WORKSPACE_WORKFLOWS"
    rm -rf "$COMFY_WORKFLOWS"
    mkdir -p "$COMFY_DIR/user/default"
    ln -s "$WORKSPACE_WORKFLOWS" "$COMFY_WORKFLOWS"
    echo "Created symlink: $COMFY_WORKFLOWS -> $WORKSPACE_WORKFLOWS"
fi

# Setup settings persistence
# ComfyUI saves settings to user/default/comfy.settings.json
# Symlink it to /workspace so it survives container restarts
echo "Setting up settings persistence..."

COMFY_SETTINGS_FILE="$COMFY_DIR/user/default/comfy.settings.json"
PERSISTED_SETTINGS="/workspace/.comfy.settings.json"

if [ -L "$COMFY_SETTINGS_FILE" ]; then
    echo "Settings file is already a symlink, skipping"
else
    mkdir -p "$COMFY_DIR/user/default"
    # Preserve existing settings if any
    if [ -f "$COMFY_SETTINGS_FILE" ] && [ ! -f "$PERSISTED_SETTINGS" ]; then
        mv "$COMFY_SETTINGS_FILE" "$PERSISTED_SETTINGS"
    else
        rm -f "$COMFY_SETTINGS_FILE"
    fi
    # Create persistent file if it doesn't exist yet
    [ ! -f "$PERSISTED_SETTINGS" ] && echo '{}' > "$PERSISTED_SETTINGS"
    ln -s "$PERSISTED_SETTINGS" "$COMFY_SETTINGS_FILE"
    echo "Created symlink: $COMFY_SETTINGS_FILE -> $PERSISTED_SETTINGS"
fi

echo "Folder structure setup complete"
echo "  /workspace/models -> /workspace/ComfyUI/models"
echo "  /workspace/outputs -> /workspace/ComfyUI/output"
echo "  /workspace/inputs -> /workspace/ComfyUI/input"
echo "  /workspace/workflows -> /workspace/ComfyUI/user/default/workflows"
echo "  /workspace/.comfy.settings.json -> ComfyUI settings (persistent)"
