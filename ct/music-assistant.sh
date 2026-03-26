#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

APP="Music-Assistant"
var_tags="music;snap;smarthome"
var_cpu="2"
var_ram="2048"
var_disk="8"
var_os="debian"
var_version="13"
var_unprivileged="1"   # jetzt unprivilegiert moeglich!

MY_REPO="https://raw.githubusercontent.com/hiSweid/music-assistant-proxmox-scripts/main"

header_info "$APP"
base_settings
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  msg_info "Updating ${APP} via Snap"
  pct exec "$CT_ID" -- snap refresh music-assistant-server
  msg_ok "Updated ${APP}"
  exit
}

start
build_container

msg_info "Installing Music Assistant via Snap"
curl -fsSL "${MY_REPO}/install/music-assistant-install.sh" -o /tmp/ma-install.sh
pct push "$CT_ID" /tmp/ma-install.sh /root/ma-install.sh --perms 755
rm /tmp/ma-install.sh
pct exec "$CT_ID" -- bash /root/ma-install.sh
msg_ok "Installed Music Assistant"

description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8095${CL}"
