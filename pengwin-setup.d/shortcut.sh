#!/bin/bash

source $(dirname "$0")/common.sh "$@"

#Globals
declare DEST_PATH
declare SKIP_STARTMENU
readonly NO_ICON="NO_ICON"

function create_shortcut() {
  local cmdName="$1"
  local cmdToExec="$2"
  local cmdIcon="$3"
  local gui="$4"

  if [[ -z "${cmdIcon}" ]]; then
    return

  elif [[ "${cmdIcon}" == ${NO_ICON} ]]; then

    cmdIcon=""
  fi

  echo wslusc --name "${cmdName}" ${cmdIcon} ${gui} "${cmdToExec}"
  bash "${SetupDir}"/generate-shortcut.sh --name "${cmdName}" ${cmdIcon} ${gui} "${cmdToExec}"

  mkdir -p "${DEST_PATH}"
  mv "$(wslpath "$(wslvar -l Desktop)")/${cmdName}.lnk" "${DEST_PATH}"
}

function create_shortcut_from_desktop() {

  local desktopFile=$1
  declare -i state=0
  local state
  local cmdToExec
  local cmdName
  local cmdIcon
  local line
  local gui="--gui"

  while read line; do

    case ${state} in
      0*) #Looking for entry

        if [[ ${line} == "[Desktop Entry]" ]]; then
          ((state++))
        fi
        ;;
      1*)

        if [[ ${line} == [* ]]; then
          break
        fi

        IFS='=' read -ra keyValue <<< "${line}"

        local key="${keyValue[0]}"
        local value="${keyValue[1]}"

        case "${key}" in
          Name)

            if [[ -z "${cmdName}" ]]; then
              cmdName="${value} (WSL)"
            fi
            ;;

          Exec)

            if [[ -z "${cmdToExec}" ]]; then

              declare -a cmdToExecArray
              local cmdToExecArray
              read -ra cmdToExecArray <<< "${value}"

              cmdToExec="${cmdToExecArray[0]}"

              case "${cmdToExec}" in
                *display-im6.q16)
                  return
                  ;;
                synaptic*)
                  return
                  ;;
                *code-insiders)
                  cmdToExec="code-insiders"
                  ;;
                *code)
                  cmdToExec="code"
                  ;;
              esac

            fi

            ;;

          Icon)

            if [[ -z "${cmdIcon}" ]]; then

              if [[ "${value}" == "com.visualstudio.code" ]]; then
                cmdIcon="/usr/share/pixmaps/com.visualstudio.code.png"

              elif [[ ! -f "${value}" ]]; then
                cmdIcon=$(find /usr/share/pixmaps \
                  \
                  /usr/share/icons/hicolor/256x256/apps \
                  /usr/share/icons/Adwaita/256x256/apps \
                  /usr/share/icons/gnome/256x256/apps \
                  /usr/share/icons/hicolor/128x128/apps \
                  /usr/share/icons/hicolor/scalable/apps \
                  /usr/share/icons/hicolor/48x48/apps \
                  /usr/share/icons/breeze/apps/64 \
                  /usr/share/icons/Adwaita/48x48/apps \
                  /usr/share/icons/gnome/48x48/apps \
                  /usr/share/icons/Adwaita/512x512/places \
                  /usr/share/icons/Adwaita/256x256/devices \
                  ${HOME}/.local/share/icons/hicolor/256x256/apps \
                  /usr/share/icons \
                  \
                  -maxdepth 1 -name "${value}*" -type f,l | head -n 1)
              else
                cmdIcon="${value}"
              fi

              if [[ -n "${cmdIcon}" ]]; then
                cmdIcon="--icon ${cmdIcon}"
              else
                cmdIcon="${NO_ICON}"
              fi
            fi


            ;;

          Type)

            if [[ "${value}" != "Application" ]]; then
              return
            fi


            ;;

          Terminal)

            if [[ "${value}" == "true" ]]; then
              gui=""
            fi


            ;;

           NoDisplay)

            if [[ "${value}" == "true" ]]; then
              return
            fi


            ;;

          esac


        ;;

      esac
  done < "${desktopFile}"

  create_shortcut "${cmdName}" "${cmdToExec}" "${cmdIcon}" "${gui}"
}

function main() {

  if [[ ${SKIP_STARTMENU} ]]; then
    return
  fi

  if (confirm --title "Start Menu" --yesno "Would you like to generate / regenerate the Start Menu shortcuts for the GUI applications installed in Pengwin?\n\nThe applications will be placed in the 'Pengwin Applications' folder in Windows Start Menu." 12 70) ; then

    echo "Generating Start Menu"

    DEST_PATH=$(wslpath "$(wslvar -l Programs)")/Pengwin\ Applications

    rm "${DEST_PATH}"/*

    filelistarray=()

    while IFS=  read -r -d $'\0'; do

        filelistarray+=("$REPLY")

    done < <(find /usr/share/applications \
                ${HOME}/.local/share/applications -name '*.desktop' -print0)

    #Be sure the executable is updated

    rm ~/.config/wslu/baseexec

    for desktopFile in "${filelistarray[@]}"; do

      create_shortcut_from_desktop "${desktopFile}"

    done

  else
    echo "Skipping Start Menu Generation"
  fi

}

main
