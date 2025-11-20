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

  # Call the saved uninstall.sh if it exists
  if [[ -f /usr/local/share/wsl-hello-sudo/uninstall.sh ]]; then
    echo "Running official uninstall script..."
    cd /tmp || exit 1
    sudo bash /usr/local/share/wsl-hello-sudo/uninstall.sh || true
  fi

  # Remove PAM configuration (in case uninstall.sh didn't cover it)
  echo "Removing PAM configuration..."
  if [[ -f /etc/pam.d/sudo ]]; then
    sudo_clean_file "/etc/pam.d/sudo" "pam_wsl_hello"
  fi

  # Remove the PAM module
  echo "Removing PAM module..."
  sudo_rem_file "/lib/x86_64-linux-gnu/security/pam_wsl_hello.so"
  sudo_rem_file "/usr/local/lib/pam_wsl_hello.so"
  sudo_rem_file "/lib/security/pam_wsl_hello.so"

  # Remove Windows Hello credential files
  echo "Removing configuration files..."
  if [[ -d "${HOME}/.pam-wsl-hello" ]]; then
    rm -rf "${HOME}/.pam-wsl-hello"
  fi

  # Remove leftover files that the installer creates
  echo "Removing leftover configuration files..."
  sudo_rem_file "/usr/share/pam-configs/wsl-hello"
  sudo_rem_dir "/etc/pam_wsl_hello"

  # Remove the saved uninstall script directory
  sudo_rem_dir "/usr/local/share/wsl-hello-sudo"

  echo "WSL-Hello-sudo has been uninstalled."
}

# Check if --skip-warning flag is passed
if [[ "$*" == *"--skip-warning"* ]]; then
  main "$@"
elif show_warning "WSL-Hello-sudo" "$@"; then
  main "$@"
fi
