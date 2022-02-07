#!/bin/bash

source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir


function create_shortcut() {
  local cmdName="$1"
  local cmdToExec="$2"
  local cmdIcon="$3"
  local DEST_PATH=$(wslpath "$(wslvar -l Programs)")/Pengwin\ Applications

  # shellcheck disable=SC2086
  echo wslusc --name "${cmdName}" --icon "${cmdIcon}" --gui "${cmdToExec}"
  # shellcheck disable=SC2086
  bash "${SetupDir}"/generate-shortcut.sh --gui --name "${cmdName}" --icon "${cmdIcon}"  "${cmdToExec}"

  mkdir -p "${DEST_PATH}"
  mv "$(wslpath "$(wslvar -l Desktop)")/${cmdName}.lnk" "${DEST_PATH}"
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
  echo "installing dependencies"
  bash "${SetupDir}"/guilib.sh --yes "$@"
  if [[ -f /etc/profile.d/dbus.sh ]]; then
    bash "${SetupDir}"/hidpi.sh --yes "$@"
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
  install_packages xrdp
  install_packages xorgxrdp
  sudo sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini
  sudo /etc/init.d/xrdp start
  
  sudo bash -c 'cat > /usr/local/bin/remote_desktop.sh' << EOF
#!/bin/bash

function execute_remote_desktop(){
    host_ip=\$(ip -o -f inet addr show | grep -v 127.0.0 | awk '{printf "%s", \$4}' | cut -f1 -d/)
    user_name=\$(whoami)
    echo "username:s:\$user_name" > /tmp/remote_desktop_config.rdp
    cd /tmp
    mstsc.exe remote_desktop_config.rdp  /v:\$host_ip:3390 /f
}

execute_remote_desktop
EOF

    sudo bash -c 'cat > /usr/local/bin/start-xrdp' << EOF
#!/bin/bash

sudo service xrdp start >/dev/null 2>&1 
EOF

    sudo tee '/etc/profile.d/start-xrdp.sh' << EOF
#!/bin/sh

sudo /usr/local/bin/start-xrdp
EOF

  sudo chmod +x /usr/local/bin/start-xrdp
  sudo chmod +x /usr/local/bin/remote_desktop.sh
  echo '%sudo   ALL=NOPASSWD: /usr/local/bin/start-xrdp' | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/start-xrdp

}
xrdp

function install_xfce() {
  if install_dependencies "$@" ; then
    install_packages xfce4-terminal
    install_packages xfce4
    install_xrdp
    if package_installed "xfce4-terminal" && package_installed "xfce4"; then
      create_shortcut "Xfce desktop (WSL)" "/usr/local/bin/remote_desktop.sh" "/usr/share/pixmaps/xfce4_xicon.png"
    else
      echo "There is a problem with xfce4 instalation"
    fi
  fi

}

function main() {
  local menu_choice=$(

    menu --title "GUI Menu" --checklist --separate-output "Install an X server or various other GUI applications\n[SPACE to select, ENTER to confirm]:" 8 50 2 \
      "XFCE" "Install XFCE Desktop environment" off \


  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"XFCE"* ]]; then
    install_xfce "$@"
  fi

}

main "$@"