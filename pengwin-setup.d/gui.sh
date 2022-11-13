#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir
declare WSL2
declare WSLG
declare PENGWIN_CONFIG_DIR

#######################################
# Alternates the WSLg between enabled and disabled
# Arguments:
#  None
#######################################
function enable_disable_wslg() {
  if [[ "${wslg_disabled}" == true ]]; then
    if (confirm --title "WSLg" --yesno "Would you like to reenable WSLg support in Pengwin?" 8 52); then
      rm -f "${disable_wslg_flag}"

      enable_should_restart
    fi
  elif (confirm --title "WSLg" --yesno "Would you like to disable WSLg support only in Pengwin?\n\nThis will activate a flag to instruct Pengwin to configure the GUI to use an X server instead of WSLg." 13 55); then
    setup_pengwin_config
    touch "${disable_wslg_flag}"

    enable_should_restart

    if (confirm --title "Setup X server" --yesno "Once WSLg is disabled, you will need an X server, would you like to configure one now?" 10 55); then
      echo "CONFIGURE"

      export WSL2=1
      configure_gui "$@"
    fi
  fi
}

#######################################
# Configures the behaviour to get the ip for the DISPLAY variable
# Arguments:
#   1 - The path of the flag file
#######################################
function configure_display() {

  local display_ip_from_dns_flag=$1

  if [[ -f "${display_ip_from_dns_flag}" ]]; then
    if (confirm --title "DISPLAY" --yesno "Would you like to configure Pengwin to get the DISPLAY variable IP from the host?\n\nMost of the cases you won't need to open the firewall port to use it with VcXsrv." 12 52); then
      rm -r "${display_ip_from_dns_flag}"

      enable_should_restart
    fi
  elif (confirm --title "DISPLAY" --yesno "Would you like to configure Pengwin to get the DISPLAY variable IP from resolv.conf?\n\nThis may require that you open the port in the firewall unless you are using X410." 12 52); then
    setup_pengwin_config
    touch "${display_ip_from_dns_flag}"

    enable_should_restart
  fi

}

function configure_gui() {

  local display_ip_from_dns_flag="${PENGWIN_CONFIG_DIR}/display_ip_from_dns"
  local -i more=0

  if [[ -z ${WSL2} ]]; then #WSL1
    local -a display_ip_from_dns_option
  elif [[ -f "${display_ip_from_dns_flag}" ]]; then
    local -a display_ip_from_dns_option=("DISPLAY" "Get the IP for DISPLAY from the Host (best for VcXSrv)" off)
    more=$((more+1))
  else
    local -a display_ip_from_dns_option=("DISPLAY" "Get the IP for DISPLAY from the resolv.conf (best for X410)" off)
    more=$((more+1))
  fi

  # shellcheck disable=SC2155,SC2188
  local menu_choice=$(

    menu --title "GUI Menu" --checklist --separate-output "Install an X server or start menu shortcuts\n[SPACE to select, ENTER to confirm]:" $((10+more)) 99 $((3+more)) \
      "${display_ip_from_dns_option[@]}" \
      "STARTMENU" "Generates 'Windows Start Menu' shortcuts for GUI applications" off \
      "VCXSRV" "Install the VcXsrv open source X-server" off \
      "X410" "Configure X410 to start on Pengwin launch or view a link to install it   " off \

  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    echo "skip CONFIGURE"
    local status
    main "$@"
    status=$?
    return $status
  fi

  if [[ ${menu_choice} == *"DISPLAY"* ]]; then
    echo "DISPLAY"
    configure_display "${display_ip_from_dns_flag}"
  fi

  if [[ ${menu_choice} == *"X410"* ]]; then
    echo "X410"
    bash "${SetupDir}"/x410.sh "$@"
  fi

  if [[ ${menu_choice} == *"VCXSRV"* ]]; then
    echo "VCXSRV"
    bash "${SetupDir}"/vcxsrv.sh "$@"
  fi

  if [[ ${menu_choice} == *"STARTMENU"* ]]; then
    echo "STARTMENU"
    bash "${SetupDir}"/shortcut.sh "$@"
  fi

}

function main() {
  declare -g disable_wslg_flag="${PENGWIN_CONFIG_DIR}/disable_wslg"

  if [[ -f "${disable_wslg_flag}" ]]; then
    declare -g wslg_disabled=true
  else
    declare -g wslg_disabled=false
  fi

  local -i more=0
  if [[ "${WSL2}" == "${WSLG}" ]]; then
    local -a disable_wslg=("WSLG" "Force disable WSLg just for Pengwin" off)
    more=$((more+1))

    local -a show_configure
  else
    if [[ "${wslg_disabled}" == true ]]; then
      local -a disable_wslg=("WSLG" "Enable WSLg just for Pengwin" off)
      more=$((more+1))
    else
      local -a disable_wslg
    fi

    local show_configure=("CONFIGURE" "Configure GUI (Check this first)" off)
    more=$((more+1))
  fi

  # shellcheck disable=SC2155,SC2188
  local menu_choice=$(

    menu --title "GUI Menu" --checklist --separate-output "Install an X server or various other GUI applications\n[SPACE to select, ENTER to confirm]:" $((14+more)) 99 $((7+more)) \
      "${disable_wslg[@]}" \
      "${show_configure[@]}" \
      "DESKTOP" "Install Desktop environments" off \
      "GUILIB" "Install a base set of libraries for GUI applications" off \
      "HIDPI" "Configure Qt and GTK for HiDPI displays" off \
      "NLI" "Install fcitx or iBus for improved non-Latin input support" off \
      "SYNAPTIC" "Install the Synaptic package manager" off \
      "TERMINAL" "Install Terminals on Windows or WSL for using WSL" off \
      "WINTHEME" "Install a Windows 10 theme along with the LXAppearance theme switcher   " off \

  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"WSLG"* ]]; then
    echo "WSLG"
    enable_disable_wslg "$@"
  fi

  if [[ ${menu_choice} == *"CONFIGURE"* ]]; then
    echo "CONFIGURE"
    configure_gui "$@"
  fi

  if [[ ${menu_choice} == *"GUILIB"* ]]; then
    echo "GUILIB"
    bash "${SetupDir}"/guilib.sh "$@"
  fi

  if [[ ${menu_choice} == *"DESKTOP"* ]]; then
    local desktop_exit_status
    echo "DESKTOP"
    bash "${SetupDir}"/desktop.sh "$@"
    desktop_exit_status=$?

    if [[ ${desktop_exit_status} != 0 ]]; then
      local gui_exit_status
      main "$@"
      gui_exit_status=$?
      return $gui_exit_status
    fi
  fi

  if [[ ${menu_choice} == *"NLI"* ]]; then
    echo "NLI"
    # shellcheck disable=SC2155,SC2188
    local nli_choice=$(

      menu --title "Non-Latin Input" --radiolist --separate-output "Select your choice of input [SPACE to select, ENTER to confirm]:" 9 70 2 \
        "FCITX" "Install fcitx for improved non-Latin input support" off \
        "IBUS" "Install iBus for improved non-Latin input support" off \

      3>&1 1>&2 2>&3)

    if [[ ${nli_choice} == *"FCITX"* ]]; then
      echo "FCITX"
      bash "${SetupDir}"/fcitx.sh "$@"
    fi

    if [[ ${nli_choice} == *"IBUS"* ]]; then
      echo "IBUS"
      bash "${SetupDir}"/ibus.sh "$@"
    fi

    if [[ ${nli_choice} == "CANCELLED" ]]; then
      echo "skip NLI"
      local NLI_exit_status
      main "$@"
      NLI_exit_status=$?
      return $NLI_exit_status
    fi
  fi

  if [[ ${menu_choice} == *"HIDPI"* ]]; then
    echo "HIDPI"
    bash "${SetupDir}"/hidpi.sh "$@"
  fi

  if [[ ${menu_choice} == *"SYNAPTIC"* ]]; then
    echo "SYNAPTIC"
    bash "${SetupDir}"/synaptic.sh "$@"
  fi

  if [[ ${menu_choice} == *"THEME"* ]]; then
    echo "WINTHEME"
    bash "${SetupDir}"/theme.sh "$@"
  fi

  if [[ ${menu_choice} == *"TERMINAL"* ]]; then
    echo "TERMINAL"
    bash "${SetupDir}"/terminal.sh "$@"
  fi

}

main "$@"
