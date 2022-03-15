#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function uninstall_xrdp() {
  echo "Removing XRDP"
  remove_package 'xrdp' 'xorgxrdp'
  sudo_rem_file "/usr/local/bin/remote_desktop.sh"
  sudo_rem_file "/usr/local/bin/start-xrdp"
  sudo_rem_file "/etc/profile.d/start-xrdp.sh"
  sudo_rem_file "/etc/sudoers.d/start-xrdp"
}

function uninstall_xfce() {
  echo "Removing XFCE"
  remove_package 'xfce4' 'xfce4-terminal'
}

function remove_shortcut() {
  echo "Removing Shortcuts"
  local dest_path
  dest_path="$(wslpath "$(wslvar -l Programs)")"/"${SHORTCUTS_FOLDER}"
  sudo_rem_file "${dest_path}"/Xfce\ desktop\ -\ Full\ Screen.lnk
  sudo_rem_file "${dest_path}"/Xfce\ desktop\ -\ 1024x768.lnk
  sudo_rem_file "${dest_path}"/Xfce\ desktop\ -\ 1366x768.lnk
  sudo_rem_file "${dest_path}"/Xfce\ desktop\ -\ 1920x1080.lnk
}

function main() {
  uninstall_xrdp
  uninstall_xfce
  remove_shortcut
}

main "$@"
