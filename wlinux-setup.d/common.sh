#!/bin/bash

wHomeWinPath=$(cmd.exe /c 'echo %HOMEDRIVE%%HOMEPATH%' 2>&1 | tr -d '\r')
wHome=$(wslpath -u "${wHomeWinPath}")

if [[ -z ${SetupDir} ]]; then
  SetupDir="$(dirname "$0")"
fi

GOVERSION="1.12"

function ProcessArguments {
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
    cd $CURDIR
    echo "Cleaning up $TMPDIR"
    sudo rm -r $TMPDIR  # need to add sudo here because git clones leave behind write-protected files
}

function updateupgrade {
#echo "Updating apt package index from repositories: $ sudo apt update"
#sudo apt update
echo "Applying available package upgrades from repositories: $ sudo apt upgrade -y"
sudo apt-get upgrade -y
echo "Removing unnecessary packages: $ sudo apt autoremove -y"
sudo apt-get autoremove -y
}

#function getexecname {
#user_path=$(cmd.exe /c "echo %HOMEDRIVE%%HOMEPATH%" 2>&1 | tr -d "\r")
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

function menu() {

  MENU_CHOICE=$(whiptail "$@" 3>&1 1>&2 2>&3)

  local exit_status=$?

  echo "Selected:" ${MENU_CHOICE}
  echo "ExitStatus:" ${exit_status}

  if [[ ${exit_status} != 0 ]] ; then
    echo "Cancelled"
    return ${exit_status}
  fi

  if [[ -z "${MENU_CHOICE}" ]] ; then

    echo "None selected"

    if (whiptail --title "None Selected" --yesno "No item selected. Would you like to return to the menu?" 10 80) ; then
      menu "$@"
    else
      local exit_status=$?

      echo "Cancelled"
      return ${exit_status}
    fi
  fi

}

ProcessArguments "$@"
