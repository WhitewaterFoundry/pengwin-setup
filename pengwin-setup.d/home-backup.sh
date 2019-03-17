#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function backup() {


  local dest_path="${wHomeWinPath}\\pengwin_home.tgz"
  if (whiptail --title "BACKUP" --yesno "Would you like to backup your directory ${HOME} to ${dest_path} ?" 8 60) ; then
    echo "Making a backup of ${HOME}"

    tar -czvf "${wHome}/pengwin_home.tgz" ${HOME}
  else
    echo "Skipping BACKUP"
  fi

}

function restore() {


  local src_path="${wHomeWinPath}\\pengwin_home.tgz"
  if (whiptail --title "BACKUP" --yesno "Would you like to restore your directory ${HOME} from ${src_path} ?" 8 60) ; then
    echo "Restoring from ${src_path}"

    tar -xzvf "${wHome}/pengwin_home.tgz" --directory /
  else
    echo "Skipping RESTORE"
  fi

}

function main {
  local choice=$(
    whiptail --title "Backup Menu" --radiolist --separate-output "Home folder Backup / Restore options\n[SPACE to select, ENTER to confirm]:" 10 80 4 \
        "BACKUP" "Backup" off \
        "RESTORE" "Restore                     " off 3>&1 1>&2 2>&3
  )

  if [[ ${choice} == "BACKUP" ]] ; then
    backup
  fi

  if [[ ${choice} == *"RESTORE"* ]] ; then
    restore
  fi


}

main