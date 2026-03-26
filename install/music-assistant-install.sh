#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen >/dev/null 2>&1 || true

apt-get update -qq
apt-get install -y --no-install-recommends \
  ffmpeg \
  python3 \
  python3-venv \
  python3-pip

python3 -m venv /opt/music-assistant
/opt/music-assistant/bin/pip install --quiet --upgrade pip
/opt/music-assistant/bin/pip install --quiet music-assistant

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
