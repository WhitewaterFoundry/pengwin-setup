#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

#######################################
# Uninstall WSL-Hello-sudo
# Removes WSL-Hello-sudo PAM module and configuration
# Arguments:
#   None
# Returns:
#   None
#######################################
function main() {

  echo "Uninstalling WSL-Hello-sudo"

  # Remove PAM configuration
  echo "Removing PAM configuration..."
  if [[ -f /etc/pam.d/sudo ]]; then
    sudo sed -i '/pam_wsl_hello/d' /etc/pam.d/sudo
  fi

  # Remove the PAM module
  echo "Removing PAM module..."
  sudo_rem_file "/lib/x86_64-linux-gnu/security/pam_wsl_hello.so"
  sudo_rem_file "/usr/local/lib/pam_wsl_hello.so"

  # Remove Windows Hello credential files
  echo "Removing configuration files..."
  if [[ -d "${HOME}/.pam-wsl-hello" ]]; then
    rm -rf "${HOME}/.pam-wsl-hello"
  fi

  echo "WSL-Hello-sudo has been uninstalled."
}

# Check if --skip-warning flag is passed
if [[ "$*" == *"--skip-warning"* ]]; then
  main "$@"
elif show_warning "WSL-Hello-sudo" "$@"; then
  main "$@"
fi
