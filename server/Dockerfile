# ABOUTME: Docker image for SF AI Game Jam
# ABOUTME: Layers Flask server on top of RunPod's ComfyUI 5090 base image
FROM runpod/comfyui:latest-5090

# Copy server files as fallback (used only until git clone completes)
COPY start_server.sh /usr/local/bin/start_server.sh
COPY server.py /usr/local/bin/server.py
COPY user_management.py /usr/local/bin/user_management.py
COPY templates /usr/local/bin/templates
COPY static /usr/local/bin/static

# Copy the bootstrap entrypoint (thin wrapper that hands off to the repo)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/start_server.sh /usr/local/bin/entrypoint.sh

# Install Flask (Python 3.12 is already in the base image)
RUN pip install --no-cache-dir --ignore-installed Flask

# Expose Flask server port (8090 to avoid clash with FileBrowser on 8080)
EXPOSE 8090

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
