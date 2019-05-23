#!/usr/bin/env bash

DEST_PATH=$(wslpath "$(wslvar -l Programs)")/Pengwin\ Applications

function create_shortcut() {
  local cmdName="$1"
  local cmdToExec="$2"
  local cmdIcon="$3"
  local cmdGui="$4"

  echo wslusc --name "${cmdName}" ${cmdIcon} ${gui} "${cmdToExec}"
  wslusc --name "${cmdName}" ${cmdIcon} ${gui} "${cmdToExec}"

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
              cmdName="${value}"
            fi

            ;;
          Exec)

            if [[ -z "${cmdToExec}" ]]; then
              local cmdToExecArray
              read -ra cmdToExecArray <<< "${value}"

              cmdToExec="${cmdToExecArray[0]}"
            fi

            ;;

          Icon)

            if [[ -z "${cmdIcon}" ]]; then

              if [[ ! -f "${value}" ]]; then
                cmdIcon=$(find /usr/share/pixmaps -name "${value}*" | head -n 1)
              else
                cmdIcon="${value}"
              fi

              if [[ -n "${cmdIcon}" ]]; then
                cmdIcon="--icon ${cmdIcon}"
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
          esac


        ;;

      esac
  done < "${desktopFile}"

  create_shortcut "${cmdName}" "${cmdToExec}" "${cmdIcon}" "${gui}"
}


function main() {

  rm "${DEST_PATH}"/*

  find /usr/share/applications -name *.desktop | while read desktopFile; do

    create_shortcut_from_desktop "${desktopFile}"

  done

}

main