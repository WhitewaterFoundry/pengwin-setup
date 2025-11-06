#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

#######################################
# Creates the Start Menu shortcut to start the remote desktop
# Globals:
#   SHORTCUTS_FOLDER
#   SetupDir
# Arguments:
#   1 The name of the shortcut
#   2 The command to execute
#   3 The shortcut icon
#######################################
function create_shortcut() {
  local cmdName="$1"
  local cmdToExec="$2"
  local cmdIcon="$3"
  # shellcheck disable=SC2155
  local dest_path=$(wslpath "$(wslvar -l Programs)")/"${SHORTCUTS_FOLDER}"

  # shellcheck disable=SC2086
  echo wslusc --gui --name "${cmdName}" --icon "${cmdIcon}" --env "env PENGWIN_REMOTE_DESKTOP='${cmdToExec}'" echo
  # shellcheck disable=SC2086
  bash "${SetupDir}"/generate-shortcut.sh --gui --name "${cmdName}" --icon "${cmdIcon}" --env "env PENGWIN_REMOTE_DESKTOP='${cmdToExec}'" echo

  mkdir -p "${dest_path}"
  cp "$(wslpath "$(wslvar -l Desktop)")/${cmdName}.lnk" "${dest_path}"
  rm "$(wslpath "$(wslvar -l Desktop)")/${cmdName}.lnk"
}

function package_installed() {

  # shellcheck disable=SC2155
  local result=$(apt -qq list $1 2>/dev/null | grep -c "\[install") # so it matches english "install" and also german "installiert"

  if [[ $result == 0 ]]; then
    return 1
  else
    return 0
  fi
}

function install_dependencies() {
  local dependencies_instaled
  echo "Installing dependencies"
  bash "${SetupDir}"/guilib.sh --yes "$@"
  if [[ -f /etc/profile.d/dbus.sh ]]; then
    bash "${SetupDir}"/hidpi.sh --yes --quiet "$@"
    if [[ -f /etc/profile.d/hidpi.sh ]]; then
      dependencies_instaled=0
    else
      dependencies_instaled=1
      echo "There is a problem installing hidpi"
    fi
  else
    dependencies_instaled=1
    echo "There is a problem installing guilib utilities"
  fi
  return $dependencies_instaled
}

function install_xrdp() {
  local port

  if [[ -z "${NON_INTERACTIVE}" ]]; then
    port=$(${DIALOG_COMMAND} --title "Enter the desired RDP Port" --inputbox "RDP Port: " 8 50 "3395" 3>&1 1>&2 2>&3)
    if [[ -z ${port} ]]; then
      echo "Cancelled"
      return 1
    fi
  else
    port="3395"
  fi

  install_packages xrdp xorgxrdp pulseaudio crudini

  # Use crudini for safer INI file manipulation
  sudo crudini --set /etc/xrdp/xrdp.ini Globals port "${port}"
  sudo crudini --set /etc/xrdp/xrdp.ini Globals bitmap_cache true
  sudo crudini --set /etc/xrdp/xrdp.ini Globals bitmap_compression true
  sudo crudini --set /etc/xrdp/xrdp.ini Globals bulk_compression true
  sudo crudini --set /etc/xrdp/xrdp.ini Globals max_bpp 24
  sudo crudini --set /etc/xrdp/xrdp.ini Globals blue 41004d
  sudo crudini --set /etc/xrdp/xrdp.ini Globals ls_title "Welcome to Pengwin"
  sudo crudini --set /etc/xrdp/xrdp.ini Globals ls_top_window_bg_color 41004d
  sudo crudini --set /etc/xrdp/xrdp.ini Globals ls_logo_filename /usr/share/images/pengwin-xrdp.bmp

  # shellcheck disable=SC2155
  local sesman_port=$(echo "${port} - 50" | bc)

  # Fix the thinclient_drives error, also not needed in WSL
  # Use crudini for safer INI file manipulation
  sudo crudini --set /etc/xrdp/sesman.ini Chansrv FuseMountName "/tmp/%u/thinclient_drives"
  sudo crudini --set /etc/xrdp/sesman.ini Globals ListenPort "${sesman_port}"

  sudo /etc/init.d/xrdp start

  sudo tee '/usr/local/bin/remote_desktop.sh' <<EOF
#!/bin/bash

function execute_remote_desktop() {
  if [ -z "\${WSL2}" ]; then
    local host_ip=127.0.0.1
  else
    # shellcheck disable=SC2155
    local host_ip=\$(ip -o -f inet addr show | grep eth | awk '{printf "%s", \$4}' | cut -f1 -d/)
  fi

  local user_name=\$(whoami)
  echo -e "username:s:\${user_name}\nsession bpp:i:32\nallow desktop composition:i:1\nconnection type:i:6\n" > /tmp/remote_desktop_config.rdp
  echo -e "networkautodetect:i:0\nbandwidthautodetect:i:1\n" >> /tmp/remote_desktop_config.rdp
  echo -e "audiocapturemode:i:1\naudiomode:i:0\n" >> /tmp/remote_desktop_config.rdp
  cd /tmp || return
  mstsc.exe remote_desktop_config.rdp  /v:"\${host_ip}":${port} "\$@"
}

execute_remote_desktop "\$@"
EOF

  sudo tee '/usr/local/bin/start-xrdp' <<EOF
#!/bin/bash

sudo service xrdp start >/dev/null 2>&1
EOF

  sudo tee '/etc/profile.d/start-xrdp.sh' <<EOF
#!/bin/sh

if [ -n "\${XRDP_SESSION}" ]; then
  return
fi

saved_param="\${PENGWIN_REMOTE_DESKTOP}"
unset PENGWIN_REMOTE_DESKTOP

sudo /usr/local/bin/start-xrdp

if [ -n "\${saved_param}" ]; then
  /usr/local/bin/remote_desktop.sh \${saved_param}

  unset saved_param
fi

EOF

  sudo chmod +x /usr/local/bin/start-xrdp
  sudo chmod +x /usr/local/bin/remote_desktop.sh
  echo '%sudo   ALL=NOPASSWD: /usr/local/bin/start-xrdp' | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/start-xrdp

}

function install_xfce() {
  if install_dependencies "$@"; then
    install_xrdp
    local exit_status=$?

    if [[ ${exit_status} != 0 && ! ${NON_INTERACTIVE} ]]; then
      return ${exit_status}
    fi

    start_indeterminate_progress

    install_packages xfce4 xfce4-terminal

    if package_installed "xfce4-terminal" && package_installed "xfce4"; then
      create_shortcut "Xfce desktop - Full Screen" "/f" "/usr/share/pixmaps/xfce4_xicon.png"
      create_shortcut "Xfce desktop - 1024x768" "/w:1024 /h:768" "/usr/share/pixmaps/xfce4_xicon.png"
      create_shortcut "Xfce desktop - 1366x768" "/w:1366 /h:768" "/usr/share/pixmaps/xfce4_xicon.png"
      create_shortcut "Xfce desktop - 1920x1080" "/w:1920 /h:1080" "/usr/share/pixmaps/xfce4_xicon.png"

      message --title "Desktop installation" --msgbox "Your desktop is installed. To use it there are new Start Menu shortcuts:

      Xfce desktop - 1024x768
      Xfce desktop - 1366x768
      Xfce desktop - 1920x1080
      Xfce desktop - Full Screen

Just click on one of them and login with your Pengwin credentials." 15 80
    else
      echo "There is a problem with xfce4 installation"
    fi

    stop_indeterminate_progress
  fi

}

function main() {
  # shellcheck disable=SC2155,SC2188
  local menu_choice=$(

    menu --title "Desktop Menu" --menu "Install Desktop environments\n[ENTER to confirm]:" 12 55 1 \
      "XFCE" "Install XFCE Desktop environment"

    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"XFCE"* ]]; then
    install_xfce "$@"
  fi

}

main "$@"
