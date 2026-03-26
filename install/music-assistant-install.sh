#!/usr/bin/env bash
set -euo pipefail

apt-get update -qq
apt-get install -y --no-install-recommends \
  python3 \
  python3-venv \
  python3-pip \
  ffmpeg \
  curl

python3 -m venv /opt/music-assistant
/opt/music-assistant/bin/pip install --quiet --upgrade pip
/opt/music-assistant/bin/pip install --quiet "music-assistant[server]"

cat > /etc/systemd/system/music-assistant.service << 'EOF'
[Unit]
Description=Music Assistant Server
After=network.target

[Service]
Type=simple
ExecStart=/opt/music-assistant/bin/mass
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now music-assistant.service
