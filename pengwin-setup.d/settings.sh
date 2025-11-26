#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

function main() {

  # shellcheck disable=SC2155,SC2086
  local menu_choice=$(

    menu --title "Settings Menu" "${DIALOG_TYPE}" "Change various settings in Pengwin\n[ENTER to confirm]:" 15 97 6 \
      "EXPLORER" "Enable right-click on folders in Windows Explorer to open them in Pengwin  " ${OFF} \
      "COLORTOOL" "Install ColorTool to set Windows console color schemes" ${OFF} \
      "GPU" "Configure GPU hardware acceleration settings" ${OFF} \
      "LANGUAGE" "Change default language and keyboard setting in Pengwin" ${OFF} \
      "MOTD" "Configures the Message Of The Day behaviour" ${OFF} \
      "SHELLS" "Install and configure zsh, csh, fish or readline improvements" ${OFF}

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  local exit_status

  if [[ ${menu_choice} == *"EXPLORER"* ]]; then
    echo "EXPLORER"
    bash "${SetupDir}"/explorer.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"COLORTOOL"* ]]; then
    echo "COLORTOOL"
    bash "${SetupDir}"/colortool.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"GPU"* ]]; then
    echo "GPU"
    bash "${SetupDir}"/gpu-accel.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"LANGUAGE"* ]]; then
    echo "LANGUAGE"
    bash "${SetupDir}"/language.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"MOTD"* ]]; then
    echo "MOTD"
    bash "${SetupDir}"/motd.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"SHELLS"* ]]; then
    echo "SHELLS"
    bash "${SetupDir}"/shells.sh "$@"
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
