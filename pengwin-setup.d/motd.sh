#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#######################################
# Arguments:
#  None
# Returns:
#   1 if cancelled
#######################################
function main() {

  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "MOTD" --radiolist --separate-output "Message Of The Day Settings\n[SPACE to select, ENTER to confirm]:" 12 78 3 \
      "MOTD_ONCE_PER_DAY" 'Only shows the message once per day (default)  ' off \
      "MOTD_ALWAYS" 'Shows the message in every login ' off \
      "MOTD_NEVER" 'Never shows the message ' off

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  echo "Selected:" "${menu_choice}"

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"MOTD_ONCE_PER_DAY"* ]]; then
    set_once_per_day
  fi

  if [[ ${menu_choice} == *"MOTD_ALWAYS"* ]]; then
    set_always
  fi

  if [[ ${menu_choice} == *"MOTD_NEVER"* ]]; then
    set_never
  fi

}

#######################################
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function set_once_per_day() {
  echo "Setting MOTD to once per day"
  rm "${HOME}"/.hushlogin
  rm "${HOME}"/.motd_show_always

  enable_should_restart
}

#######################################
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function set_never() {
  echo "Setting MOTD to never"
  touch "${HOME}"/.hushlogin

  enable_should_restart
}

#######################################
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function set_always() {
  echo "Setting MOTD to never"
  touch "${HOME}"/.motd_show_always

  enable_should_restart
}


main "$@"

