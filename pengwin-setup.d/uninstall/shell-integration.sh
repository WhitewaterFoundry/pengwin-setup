#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

#Imported from uninstall-common.sh
declare HOME

# We need to delete everything between 2 instances of this string
readonly PENGWIN_SHELL_INTEGRATION_MARKER='### PENGWIN WINDOWS TERMINAL SHELL INTEGRATION'
readonly SHELL_INTEGRATION_SCRIPT='/etc/profile.d/wt-shell-integration.sh'

#######################################
# Uninstall Windows Terminal shell integration
# Removes the source line from ~/.bashrc and the script from /etc/profile.d
# Globals:
#   HOME
#   PENGWIN_SHELL_INTEGRATION_MARKER
#   SHELL_INTEGRATION_SCRIPT
# Arguments:
#   None
#######################################
function main() {
  echo "Uninstalling Windows Terminal shell integration"

  local bashrc="${HOME}/.bashrc"

  # Remove source line from .bashrc
  echo "Cleaning ${bashrc}"
  if [[ -f "${bashrc}" ]]; then
    if grep -q "${PENGWIN_SHELL_INTEGRATION_MARKER}" "${bashrc}" 2>/dev/null; then
      inclusive_file_clean "${bashrc}" "${PENGWIN_SHELL_INTEGRATION_MARKER}"
      echo "Source line removed from ${bashrc}"
    else
      echo "... shell integration not found in ${bashrc}!"
    fi
  else
    echo "... ${bashrc} not found!"
  fi

  # Remove the shell integration script from /etc/profile.d
  echo "Removing ${SHELL_INTEGRATION_SCRIPT}"
  if [[ -f "${SHELL_INTEGRATION_SCRIPT}" ]]; then
    sudo rm -f "${SHELL_INTEGRATION_SCRIPT}"
    echo "Shell integration script removed."
  else
    echo "... script not found!"
  fi

  echo "Windows Terminal shell integration uninstalled successfully."
}

if show_warning "Windows Terminal shell integration" "$@"; then
  main "$@"
fi
