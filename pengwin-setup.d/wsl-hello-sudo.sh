#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# Imported from common.sh
declare wHome

#######################################
# Install WSL-Hello-sudo
# Allows using Windows Hello for sudo authentication in WSL
# Globals:
#   wHome - Windows home directory path
# Arguments:
#   None
# Returns:
#   0 on success, 1 if user cancelled
#######################################
function main() {

  if (confirm --title "WSL-Hello-sudo" --yesno "Would you like to install WSL-Hello-sudo?\n\nThis enables using Windows Hello (fingerprint, face recognition, PIN) for sudo authentication in WSL." 10 75); then
    echo "Installing WSL-Hello-sudo..."

    createtmp

    # Install required dependencies
    echo "Installing dependencies..."
    install_packages build-essential libpam0g-dev wget

    # Download and install the latest release
    echo "Downloading WSL-Hello-sudo installer..."
    wget https://github.com/nullpo-head/WSL-Hello-sudo/releases/latest/download/release.tar.gz

    echo "Extracting installer..."
    tar -xf release.tar.gz

    echo "Running installer..."
    cd ./release || exit 1
    ./install.sh

    cleantmp

    echo ""
    echo "WSL-Hello-sudo has been installed successfully!"
    echo "You can now use Windows Hello for sudo authentication."
    echo ""
    echo "Note: You may need to restart your WSL session for changes to take full effect."

    message --title "WSL-Hello-sudo" --msgbox "WSL-Hello-sudo has been installed successfully!\n\nYou can now use Windows Hello for sudo authentication.\n\nNote: Please restart your WSL session for changes to take full effect." 11 70

    enable_should_restart

    return 0
  else
    echo "Skipping WSL-Hello-sudo"
    return 1
  fi
}

main "$@"
