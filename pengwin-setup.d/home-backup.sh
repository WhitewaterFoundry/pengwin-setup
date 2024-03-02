#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare wHome

BACKUPS_DIR="${wHome}/Pengwin/backups"
mkdir -p "${BACKUPS_DIR}"

BACKUP_PATH="${BACKUPS_DIR}/pengwin_home.tgz"
BACKUP_PATH_WIN="$(wslpath -w "${BACKUPS_DIR}")\\pengwin_home.tgz"
BACKUP_IGNORE_FILE="${HOME}/.pengwinbackupignore"

#######################################
# description
# Globals:
#   BACKUPS_DIR
#   BACKUP_IGNORE_FILE
#   BACKUP_PATH
#   BACKUP_PATH_WIN
#   HOME
# Arguments:
#  None
#######################################
function backup() {

  message --title "Ignore Files" --msgbox "You can exclude files and folders from the home backup by putting their names in ${BACKUP_IGNORE_FILE}" 10 70

  if (confirm --title "BACKUP" --yesno "Would you like to backup your directory ${HOME} to ${BACKUP_PATH_WIN} ?" 8 60) ; then
    echo "Making a backup of ${HOME}"

    #Avoid to replace a previous backup
    if [[ -f "${BACKUP_PATH}" ]]; then

      # shellcheck disable=SC2155
      local timestamp="$(date -r "${BACKUP_PATH}" '+%Y_%m_%d__%H_%M_%S')"

      mv "${BACKUP_PATH}" "${BACKUPS_DIR}/pengwin_home_${timestamp}.tgz"
    fi

    #To runs backup with a list of files to be ignored
    if [[ -f "${BACKUP_IGNORE_FILE}" ]]; then
      tar -czvf "${BACKUP_PATH}" -X "${BACKUP_IGNORE_FILE}" "${HOME}"
    else
      tar -czvf "${BACKUP_PATH}" "${HOME}"
    fi

  else
    echo "Skipping BACKUP"
  fi

}

#######################################
# description
# Globals:
#   BACKUP_PATH
#   BACKUP_PATH_WIN
#   HOME
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function restore() {

  if [[ ! -f "${BACKUP_PATH}" ]]; then
    message --title "RESTORE" --msgbox "The file \"${BACKUP_PATH_WIN}\" was not found. If you have a previous backup move it to \"${BACKUP_PATH_WIN}\"" 10 70

    return 1
  fi

  if (confirm --title "RESTORE" --yesno "Would you like to restore your directory ${HOME} from ${BACKUP_PATH_WIN} ?" 8 60) ; then
    echo "Restoring from ${BACKUP_PATH_WIN}"

    tar -xzvf "${BACKUP_PATH}" --directory /
  else
    echo "Skipping RESTORE"
  fi

}

#######################################
# description
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function main() {
  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "Backup Menu" --radiolist "Home folder Backup / Restore options\n[SPACE to select, ENTER to confirm]:" 10 55 2 \
      "BACKUP" 'Backups the ${HOME} directory   ' off \
      "RESTORE" 'Restore the ${HOME} directory' off

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == "BACKUP" ]]; then
    backup
  fi

  if [[ ${menu_choice} == "RESTORE" ]]; then
    restore
  fi

}

main
