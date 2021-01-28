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

function install_xfce() {
  if install_dependencies "$@" ; then
    install_packages xfce4-terminal
    install_packages xfce4

    if package_installed "xfce4-terminal" && package_installed "xfce4"; then
      create_shortcut "Xfce desktop (WSL)" "xfce4-session" "/usr/share/pixmaps/xfce4_xicon.png"
    else
      echo "There is a problem with xfce4 instalation"
    fi
  fi

}

function install_mate() {
  if install_dependencies "$@" ; then
    install_packages mate-desktop-environment

    if package_installed "mate-desktop-environment" ; then
      create_shortcut "Mate desktop (WSL)" "mate-session" "/usr/share/icons/mate/16x16/apps/mate-desktop.png"
    else
      echo "There is a problem with mate instalation"
    fi
  fi
}


function main() {
  local menu_choice=$(

    menu --title "GUI Menu" --checklist --separate-output "Install an X server or various other GUI applications\n[SPACE to select, ENTER to confirm]:" 8 50 2 \
      "XFCE" "Install XFCE Desktop environment" off \
      "MATE" "Install MATE Desktop environment" off \


  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"XFCE"* ]]; then
    install_xfce "$@"
  fi

  if [[ ${menu_choice} == *"MATE"* ]]; then
    install_mate "$@"
  fi

}

main "$@"