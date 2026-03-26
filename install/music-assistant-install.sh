#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "[1/4] Installing dependencies..."
apt-get update -qq
apt-get install -y --no-install-recommends curl ca-certificates

echo "[2/4] Installing Docker..."
curl -fsSL https://get.docker.com | sh

echo "[3/4] Creating Music Assistant config..."
mkdir -p /opt/music-assistant/data
cat > /opt/music-assistant/docker-compose.yml << 'YAMLEOF'
services:
  music-assistant-server:
    image: ghcr.io/music-assistant/server:latest
    container_name: music-assistant-server
    restart: unless-stopped
    network_mode: host
    volumes:
      - /opt/music-assistant/data:/data/
    cap_add:
      - SYS_ADMIN
      - DAC_READ_SEARCH
    security_opt:
      - apparmor:unconfined
    environment:
      - LOG_LEVEL=info
YAMLEOF

echo "[4/4] Starting Music Assistant..."
cd /opt/music-assistant
docker compose up -d

echo "Done! Music Assistant is running on port 8095."
