#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

#######################################
# Sudo Management Menu
# Provides options for managing sudo authentication methods
# Options:
#   1. Passwordless sudo - No password required for sudo group
#   2. WSL-Hello-sudo - Use Windows Hello for sudo authentication
# Arguments:
#   None
# Returns:
#   0 on success, 1 if cancelled
#######################################
function main() {

  # shellcheck disable=SC2155,SC2086
  local menu_choice=$(

    menu --title "Sudo Management Menu" --menu "Configure sudo authentication method\n[ENTER to confirm]:" 12 75 2 \
      "PASSWORDLESS" "Enable passwordless sudo (no password required)" \
      "WSL-HELLO-SUDO" "Use Windows Hello for sudo authentication"

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"PASSWORDLESS"* ]]; then
    echo "PASSWORDLESS"
    bash "${SetupDir}"/passwordless-sudo.sh "$@"
  fi

  if [[ ${menu_choice} == *"WSL-HELLO-SUDO"* ]]; then
    echo "WSL-HELLO-SUDO"
    bash "${SetupDir}"/wsl-hello-sudo.sh "$@"
  fi
}

main "$@"
