#!/bin/bash

wHomeWinPath=$(cmd.exe /c 'echo %HOMEDRIVE%%HOMEPATH%' 2>&1 | tr -d '\r')
wHome=$(wslpath -u "${wHomeWinPath}")
SetupDir="/usr/local/wlinux-setup.d"

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
sudo apt upgrade -y
echo "Removing unnecessary packages: $ sudo apt autoremove -y"
sudo apt autoremove -y
}

#function getexecname {
#user_path=$(cmd.exe /c "echo %HOMEDRIVE%%HOMEPATH%" 2>&1 | tr -d "\r")
#wslexec_dir=$(echo $PATH | sed -e 's/:/\n/g' | grep 'Program\ Files/WindowsApps')
#execname=$(ls "${wslexec_dir}" | grep '.exe')
#echo "${execname}"
#}

ProcessArguments "$@"
