#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#Globals
declare DEST_PATH
declare SKIP_STARTMENU
declare SetupDir
readonly NO_ICON="NO_ICON"

function create_shortcut() {
  local cmdName="$1"
  local cmdToExec="$2"
  local cmdIcon="$3"
  local gui="$4"

  if [[ -z "${cmdIcon}" ]]; then
    return

  elif [[ "${cmdIcon}" == "${NO_ICON}" ]]; then

    cmdIcon=""
  fi

  # shellcheck disable=SC2086
  echo wslusc --name "${cmdName}" ${cmdIcon} ${gui} --env "env PENGWIN_COMMAND='${cmdToExec}'" echo
  # shellcheck disable=SC2086
  bash "${SetupDir}"/generate-shortcut.sh --name "${cmdName}" ${cmdIcon} ${gui} --env "env PENGWIN_COMMAND='${cmdToExec}'" echo

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
  local -a key_value

  while read -r line; do

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


      IFS='=' read -ra key_value <<<"${line}"

      local key="${key_value[0]}"
      local value="${key_value[1]}"

      case "${key}" in
      Name)

        if [[ -z "${cmdName}" ]]; then
          cmdName="${value} (Pengwin)"
        fi
        ;;

      Exec)

        if [[ -z "${cmdToExec}" ]]; then

          declare -a cmdToExecArray
          local cmdToExecArray
          read -ra cmdToExecArray <<<"${value}"

          cmdToExec="${cmdToExecArray[0]}"

          case "${cmdToExec}" in
          *display-im6.q16)
            return
            ;;
          synaptic*)
            return
            ;;
          exo-*)
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
              /usr/share/icons/Adwaita/256x256/legacy \
              "${HOME}"/.local/share/icons/hicolor/256x256/apps \
              /usr/share/icons \
              -maxdepth \
              1 \
              -name "${value}*" -type f,l | head -n 1)
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

  if [[ ${WSL_DISTRO_NAME:-WLinux} != "WLinux" ]]; then
    return
  fi

  if (confirm --title "Start Menu" --yesno "Would you like to generate / regenerate the Start Menu shortcuts for the GUI applications installed in Pengwin?\n\nThe applications will be placed in the 'Pengwin Applications' folder in Windows Start Menu." 12 70); then

    start_indeterminate_progress

    echo "Generating Start Menu"

    DEST_PATH=$(wslpath "$(wslvar -l Programs)")/"${SHORTCUTS_FOLDER}"

    rm "${DEST_PATH}"/*\ \(WSL\).lnk

    local file_list_array=()

    while IFS= read -r -d $'\0'; do

      file_list_array+=("$REPLY")

    done < <(find /usr/share/applications \
      "${HOME}"/.local/share/applications -name '*.desktop' -print0)

    #Be sure the executable is updated

    rm ~/.config/wslu/baseexec

    for desktopFile in "${file_list_array[@]}"; do

      create_shortcut_from_desktop "${desktopFile}"

    done

    stop_indeterminate_progress

  else
    echo "Skipping Start Menu Generation"
  fi

}

main
