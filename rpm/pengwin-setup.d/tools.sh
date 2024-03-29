#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

function main() {

  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "Tools Menu" --separate-output --checklist "Install applications or servers\n[SPACE to select, ENTER to confirm]:" 12 87 5 \
      "ANSIBLE" "Install tools to deploy Ansible Playbooks" off \
      "CLOUDCLI" "Install CLI tools for cloud management (AWS, Azure, Terraform) " off \
      "DOCKER" "Install a secure bridge to Docker Desktop" off \
      "HOMEBREW" "Install the Homebrew package manager" off \
      "POWERSHELL" "Install PowerShell for Linux" off

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"ANSIBLE"* ]]; then
    echo "ANSIBLE"
    bash "${SetupDir}"/ansible.sh "$@"
  fi

  if [[ ${menu_choice} == *"CLOUDCLI"* ]]; then
    echo "CLOUDCLI"
    bash "${SetupDir}"/cloudcli.sh "$@"
  fi

  if [[ ${menu_choice} == *"DOCKER"* ]]; then
    echo "DOCKER"
    bash "${SetupDir}"/docker.sh "$@"
  fi

  if [[ ${menu_choice} == *"HOMEBREW"* ]]; then
    echo "HOMEBREW"
    bash "${SetupDir}"/brew.sh "$@"
  fi

  if [[ ${menu_choice} == *"POWERSHELL"* ]]; then
    echo "POWERSHELL"
    bash "${SetupDir}"/powershell.sh "$@"
  fi

}

main "$@"
