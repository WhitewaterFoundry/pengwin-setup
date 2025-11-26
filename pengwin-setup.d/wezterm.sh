#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.sh
declare wHome

#######################################
# Install WezTerm for Windows using the installer from GitHub releases
# Downloads and runs the Windows installer
# Arguments:
#   None
#######################################
function install_wezterm_windows() {
  echo "Installing WezTerm for Windows"

  createtmp

  # Get the latest release download URL for Windows setup
  echo "Fetching latest WezTerm release..."
  local download_url
  download_url=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | \
    grep -o '"browser_download_url": "[^"]*WezTerm-windows-[^"]*\.exe"' | \
    head -1 | \
    cut -d'"' -f4)

  if [[ -z "${download_url}" ]]; then
    echo "Error: Could not find WezTerm Windows installer"
    cleantmp
    return 1
  fi

  echo "Downloading WezTerm installer..."
  install_packages wget
  wget --progress=dot "${download_url}" -O wezterm-setup.exe 2>&1 | \
    sed -un 's/.* \([0-9]\+\)% .*/\1/p' | \
    ${DIALOG_COMMAND} --title "WezTerm" --gauge "Downloading WezTerm..." 7 50 0

  echo "Running WezTerm installer..."
  # Copy to Windows home directory and run
  cp wezterm-setup.exe "${wHome}/wezterm-setup.exe"
  cmd-exe /C "$(wslpath -w "${wHome}/wezterm-setup.exe")"

  # Clean up installer
  rm -f "${wHome}/wezterm-setup.exe"

  cleantmp

  message --title "WezTerm" --msgbox "WezTerm for Windows installation completed.\n\nYou can find WezTerm in your Start Menu." 10 60
}

#######################################
# Install WezTerm for Linux using the official APT repository
# Arguments:
#   None
#######################################
function install_wezterm_linux() {
  echo "Installing WezTerm for Linux"

  # Add WezTerm APT repository
  echo "Adding WezTerm repository..."

  # Install required dependencies
  install_packages curl gpg

  # Add the GPG key
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg

  # Add the repository
  echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" | \
    sudo tee /etc/apt/sources.list.d/wezterm.list

  # Update package list
  update_packages

  # Install WezTerm
  install_packages wezterm

  message --title "WezTerm" --msgbox "WezTerm for Linux installation completed.\n\nYou can start it by running: wezterm" 10 60
}

function main() {

  if (confirm --title "WezTerm" --yesno "Would you like to install WezTerm terminal emulator?\n\nhttps://wezterm.org/" 10 60); then
    echo "Installing WezTerm"

    # shellcheck disable=SC2155
    local version_choice=$(
      menu --title "WezTerm Version" --menu "Select which version of WezTerm to install:\n\n- Windows: Better window management, runs natively on Windows\n- Linux: Runs within WSL, requires X server or WSLg\n\n[ENTER to confirm]:" 16 75 2 \
        "WINDOWS" "Install WezTerm for Windows (recommended)" \
        "LINUX" "Install WezTerm for Linux (requires X/WSLg)"

      3>&1 1>&2 2>&3
    )

    if [[ ${version_choice} == "CANCELLED" ]]; then
      echo "Skipping WezTerm"
      return 1
    fi

    if [[ ${version_choice} == *"WINDOWS"* ]]; then
      install_wezterm_windows
    fi

    if [[ ${version_choice} == *"LINUX"* ]]; then
      install_wezterm_linux
    fi
  else
    echo "Skipping WezTerm"
  fi
}

main "$@"
