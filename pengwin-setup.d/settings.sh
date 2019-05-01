#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function main() {

  local menu_choice=$(

    menu --title "Settings Menu" --checklist --separate-output "Change various settings in Pengwin\n[SPACE to select, ENTER to confirm]:" 12 97 4 \
      "EXPLORER" "Enable right-click on folders in Windows Explorer to open them in Pengwin  " off \
      "COLORTOOL" "Install ColorTool to set Windows console color schemes" off \
      "LANGUAGE" "Change default language and keyboard setting in Pengwin" off \
      "SHELLS" "Install and configure zsh, csh, fish or readline improvements" off \

  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *"EXPLORER"* ]] ; then
    echo "EXPLORER"
    bash ${SetupDir}/explorer.sh "$@"
  fi

  if [[ ${menu_choice} == *"COLORTOOL"* ]] ; then
    echo "COLORTOOL"
    bash ${SetupDir}/colortool.sh "$@"
  fi

  if [[ ${menu_choice} == *"LANGUAGE"* ]] ; then
    echo "LANGUAGE"
    bash ${SetupDir}/language.sh "$@"
  fi

  if [[ ${menu_choice} == *"SHELLS"* ]] ; then
    echo "SHELLS"
    bash ${SetupDir}/shells.sh "$@"
  fi


}

main "$@"
