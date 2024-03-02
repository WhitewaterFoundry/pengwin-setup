#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

#######################################
# description
# Globals:
#   SetupDir
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function main() {

  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "Maintenance Menu" --separate-output --checklist "Various maintenance tasks like home backup\n[SPACE to select, ENTER to confirm]:" 10 70 1 \
      "HOMEBACKUP" 'Backups and restore the ${HOME} directory    ' on

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"HOMEBACKUP"* ]]; then
    echo "HOMEBACKUP"
    bash ${SetupDir}/home-backup.sh "$@"
  fi

}

main "$@"
