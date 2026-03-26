#!/usr/bin/env bash

# Copyright (c) 2026 Henryk Hanke
# License: MIT
# Source: https://music-assistant.io

source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

APP="Music-Assistant"
var_tags="music;docker;smarthome"
var_cpu="2"
var_ram="2048"
var_disk="8"
var_os="debian"
var_version="13"
var_unprivileged="0"  # privilegiert - Pflicht fuer Docker + SMB-Mounts

# Eigene Repo-URL - hier deinen GitHub-Username eintragen!
MY_REPO="https://raw.githubusercontent.com/DEIN-USERNAME/proxmox-scripts/main"

header_info "$APP"
base_settings
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /opt/music-assistant/docker-compose.yml ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Updating ${APP}"
  pct exec "$CT_ID" -- bash -c "cd /opt/music-assistant && docker compose pull && docker compose up -d --remove-orphans"
  msg_ok "Updated ${APP}"
  exit
}

start
build_container  # erstellt Container; 404 auf community-scripts install-script wird ignoriert

# AppArmor + Capabilities fuer Docker & SMB-Mounts
msg_info "Applying AppArmor & capabilities config"
LXC_CONFIG="/etc/pve/lxc/${CT_ID}.conf"
if ! grep -q "lxc.apparmor.profile" "$LXC_CONFIG"; then
  {
    echo "lxc.apparmor.profile: unconfined"
    echo "lxc.cgroup2.devices.allow: c 10:237 rwm"
    echo "lxc.cap.drop:"
  } >> "$LXC_CONFIG"
fi
pct stop "$CT_ID"
sleep 3
pct start "$CT_ID"
sleep 12
msg_ok "AppArmor config applied"

# Install-Script von eigenem GitHub-Repo holen und in Container pushen
msg_info "Fetching install script from GitHub"
curl -fsSL "${MY_REPO}/install/music-assistant-install.sh" -o /tmp/ma-install.sh
pct push "$CT_ID" /tmp/ma-install.sh /root/ma-install.sh --perms 755
rm /tmp/ma-install.sh
msg_ok "Install script ready"

msg_info "Installing Docker & Music Assistant (this takes a few minutes)"
pct exec "$CT_ID" -- bash /root/ma-install.sh
msg_ok "Docker & Music Assistant installed"

description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8095${CL}"
