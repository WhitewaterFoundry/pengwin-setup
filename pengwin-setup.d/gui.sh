#!/bin/bash

source $(dirname "$0")/common.sh "$@"

#Imported from common.h
declare SetupDir

function main() {

  local menu_choice=$(

    menu --title "GUI Menu" --checklist --separate-output "Install an X server or various other GUI applications\n[SPACE to select, ENTER to confirm]:" 16 99 8 \
      "FCITX" "Install fcitx for improved non-Latin input support" off \
      "GUILIB" "Install a base set of libraries for GUI applications" off \
      "HIDPI" "Configure Qt and GTK for HiDPI displays (experimental)" off \
      "STARTMENU" "Generates Windows Start Menu shortcuts for GUI applications" off \
      "TERMINAL" "Install Terminals on Windows or WSL for using WSL" off \
      "SYNAPTIC" "Install the Synaptic package manager" off \
      "VCXSRV" "Install the VcXsrv open source X-server" off \
      "WINTHEME" "Install a Windows 10 theme along with the LXAppearance theme switcher   " off \
      "X410" "Configure X410 to start on Pengwin launch or view a link to install it" off \

  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *"X410"* ]] ; then
    echo "X410"
    bash ${SetupDir}/x410.sh "$@" 
  fi

  if [[ ${menu_choice} == *"VCXSRV"* ]] ; then
    echo "VCXSRV"
    bash ${SetupDir}/vcxsrv.sh "$@"
  fi

  if [[ ${menu_choice} == *"GUILIB"* ]] ; then
    echo "GUILIB"
    bash ${SetupDir}/guilib.sh "$@"
  fi

  if [[ ${menu_choice} == *"FCITX"* ]] ; then
    echo "FCITX"
    bash ${SetupDir}/fcitx.sh
  fi

  if [[ ${menu_choice} == *"HIDPI"* ]] ; then
    echo "HIDPI"
    bash ${SetupDir}/hidpi.sh
  fi

  if [[ ${menu_choice} == *"STARTMENU"* ]] ; then
    echo "STARTMENU"
    bash ${SetupDir}/shortcut.sh "$@"
  fi

  if [[ ${menu_choice} == *"SYNAPTIC"* ]] ; then
    echo "SYNAPTIC"
    bash ${SetupDir}/synaptic.sh "$@"
  fi

  if [[ ${menu_choice} == *"THEME"* ]] ; then
    echo "WINTHEME"
    bash ${SetupDir}/theme.sh "$@"
  fi

  if [[ ${menu_choice} == *"TERMINAL"* ]] ; then
    echo "TERMINAL"
    bash ${SetupDir}/terminal.sh "$@"
  fi

}

main "$@"
