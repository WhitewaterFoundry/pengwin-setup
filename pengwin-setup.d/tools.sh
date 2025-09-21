#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

function main() {

  # shellcheck disable=SC2155,SC2086
  local menu_choice=$(

    menu --title "Tools Menu" "${DIALOG_TYPE}" "Install applications or servers\n[ENTER to confirm]:" 14 87 5 \
      "ANSIBLE" "Install tools to deploy Ansible Playbooks" ${OFF} \
      "CLOUDCLI" "Install CLI tools for cloud management (AWS, Azure, Terraform) " ${OFF} \
      "DOCKER" "Install a secure bridge to Docker Desktop" ${OFF} \
      "HOMEBREW" "Install the Homebrew package manager" ${OFF} \
      "POWERSHELL" "Install PowerShell for Linux" ${OFF}

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  local exit_status

  if [[ ${menu_choice} == *"ANSIBLE"* ]]; then
    echo "ANSIBLE"
    bash "${SetupDir}"/ansible.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"CLOUDCLI"* ]]; then
    echo "CLOUDCLI"
    bash "${SetupDir}"/cloudcli.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"DOCKER"* ]]; then
    echo "DOCKER"
    bash "${SetupDir}"/docker.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"HOMEBREW"* ]]; then
    echo "HOMEBREW"
    bash "${SetupDir}"/brew.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"POWERSHELL"* ]]; then
    echo "POWERSHELL"
    bash "${SetupDir}"/powershell.sh "$@"
    exit_status=$?
  fi

  if [[ ${exit_status} != 0 && ! ${NON_INTERACTIVE} ]]; then
    local status
    main "$@"
    status=$?
    return $status
  fi
}

main "$@"
