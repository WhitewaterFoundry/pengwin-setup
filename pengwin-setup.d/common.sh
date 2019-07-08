#!/bin/bash

function process_arguments() {
  while [[ $# -gt 0 ]]
  do
    case "$1" in
      --debug|-d|--verbose|-v)
        echo "Running in debug/verbose mode"
        set -x
        shift
      ;;
      -y|--yes|--assume-yes)
        echo "Skipping confirmations"
        SkipConfirmations=1
        shift
      ;;
      --noupdate)
        echo "Skipping updates"
        SKIP_UPDATES=1
        shift
      ;;
      --norebuildicons)
        echo "Skipping rebuild start menu"
        SKIP_STARTMENU=1
        shift
      ;;
      *)
        shift
    esac
  done
}

function createtmp {
    echo "Saving current directory as \$CURDIR"
    CURDIR=$(pwd)
    TMPDIR=$(mktemp -d)
    echo "Going to \$TMPDIR: $TMPDIR"
    cd $TMPDIR
}

function cleantmp {
    echo "Returning to $CURDIR"
    cd "$CURDIR"
    echo "Cleaning up $TMPDIR"
    sudo rm -r $TMPDIR  # need to add sudo here because git clones leave behind write-protected files
}

function updateupgrade {
echo "Applying available package upgrades from repositories."
sudo apt-get upgrade -y
echo "Removing unnecessary packages."
sudo apt-get autoremove -y
}

#function getexecname {
#user_path=$(cmd-exe /c "echo %HOMEDRIVE%%HOMEPATH%" | tr -d "\r")
#wslexec_dir=$(echo $PATH | sed -e 's/:/\n/g' | grep 'Program\ Files/WindowsApps')
#execname=$(ls "${wslexec_dir}" | grep '.exe')
#echo "${execname}"
#}

function confirm() {

  if [[ ! ${SkipConfirmations} ]]; then

    whiptail "$@"

    return $?
  else
    return 0
  fi
}

#######################################
# Display a menu using whiptail. Echo the option key or CANCELLED if the user has cancelled
# Globals:
#   CANCELLED
# Arguments:
#   None
# Returns:
#   None
#######################################
function menu() {

  local menu_choice #Splitted to preserve exit code
  menu_choice=$(whiptail "$@" 3>&1 1>&2 2>&3)

  local exit_status=$?

  if [[ ${exit_status} != 0 ]] ; then
    echo ${CANCELLED}
    return
  fi

  if [[ -z "${menu_choice}" ]] ; then

    if (whiptail --title "None Selected" --yesno "No item selected. Would you like to return to the menu?" 8 60  3>&1 1>&2 2>&3) ; then
      menu "$@"

      return
    else
      local exit_status=$?
      echo ${CANCELLED}
      return
    fi
  fi

  echo "${menu_choice}"
}

function setup_env() {

  if ( ! which cmd.exe >/dev/null ); then
    whiptail --title "Wrong user" --msgbox "pengwin-setup was ran with the user \"${USER}\".\n\nRun pengwin-setup from the default user and without sudo" 12 80

    exit 0
  fi

  process_arguments "$@"

  if ( ! wslpath 'C:\' > /dev/null 2>&1 ); then
    shopt -s expand_aliases
    alias wslpath=legacy_wslupath
  fi

  readonly wHomeWinPath=$(cmd-exe /c 'echo %HOMEDRIVE%%HOMEPATH%' | tr -d '\r')
  readonly wHome=$(wslpath -u "${wHomeWinPath}")
  readonly CANCELLED="CANCELLED"

  SetupDir="/usr/local/pengwin-setup.d"

  readonly GOVERSION="1.12"
}

setup_env "$@"
