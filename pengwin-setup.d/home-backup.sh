#!/bin/bash

source $(dirname "$0")/common.sh "$@"

BACKUPS_DIR="${wHome}/Pengwin/backups"
BACKUP_PATH="${BACKUPS_DIR}/pengwin_home.tgz"
BACKUP_PATH_WIN="$(wslpath -w "${BACKUP_PATH}")"

function backup() {


  if (whiptail --title "BACKUP" --yesno "Would you like to backup your directory ${HOME} to ${BACKUP_PATH_WIN} ?" 8 60) ; then
    echo "Making a backup of ${HOME}"

    #Avoid to replace a previous backup
    if [[ -f "${BACKUP_PATH}" ]]; then

      local timestamp="$(date -r "${BACKUP_PATH}" '+%Y_%m_%d__%H_%M_%S')"

      mv "${BACKUP_PATH}" "${BACKUPS_DIR}/pengwin_home_${timestamp}.tgz"
    else

      mkdir -p "${BACKUPS_DIR}"
    fi

    tar -czvf "${BACKUP_PATH}" ${HOME}
  else
    echo "Skipping BACKUP"
  fi

}

function restore() {

  if (whiptail --title "RESTORE" --yesno "Would you like to restore your directory ${HOME} from ${BACKUP_PATH_WIN} ?" 8 60) ; then
    echo "Restoring from ${BACKUP_PATH_WIN}"

    tar -xzvf "${BACKUP_PATH}" --directory /
  else
    echo "Skipping RESTORE"
  fi

}

function main {
  local menu_choice=$(

    menu --title "Backup Menu" --radiolist --separate-output "Home folder Backup / Restore options\n[SPACE to select, ENTER to confirm]:" 10 55 2 \
        "BACKUP" 'Backups the ${HOME} directory   ' off \
        "RESTORE" 'Restore the ${HOME} directory' off \

    3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == "BACKUP" ]] ; then
    backup
  fi

  if [[ ${menu_choice} == "RESTORE" ]] ; then
    restore
  fi


}

main