source $(dirname "$0")/common.sh "$@"

function main() {

  local menu_choice=$(

    menu --title "Terminal Menu" --checklist --separate-output "Install Terminals you want\n[SPACE to select, ENTER to confirm]:" 12 70 5 \
      "TILIX" "Tilix (requires X Server)" off \
      "WINTERMINAL" "Windows Terminal" off \
      "WSLTTY" "WSLtty" off \
      "GTERM" "Gnome Terminal (requires X Server)" off \
      "XFTERM" "Xfce Terminal (requires X Server)" off \

  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *"TILIX"* ]] ; then

  fi

  if [[ ${menu_choice} == *"WINTERMINAL"* ]] ; then

  fi

  if [[ ${menu_choice} == *"WSLTTY"* ]] ; then

  fi

  if [[ ${menu_choice} == *"GTERM"* ]] ; then
  fi

  if [[ ${menu_choice} == *"XFTERM"* ]] ; then

  fi

}

main "$@"