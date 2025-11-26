#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

#Imported from uninstall-common.sh
declare HOME

# We need to delete everything between 2 instances of this string
readonly PENGWIN_SHELL_INTEGRATION_MARKER='### PENGWIN WINDOWS TERMINAL SHELL INTEGRATION'

#######################################
# Uninstall Windows Terminal shell integration from ~/.bashrc
# Removes the block between marker strings
# Globals:
#   HOME
#   PENGWIN_SHELL_INTEGRATION_MARKER
# Arguments:
#   None
#######################################
function main() {
  echo "Uninstalling Windows Terminal shell integration"

  local bashrc="${HOME}/.bashrc"

  echo "Cleaning ${bashrc}"
  if [[ -f "${bashrc}" ]]; then
    if grep -q "${PENGWIN_SHELL_INTEGRATION_MARKER}" "${bashrc}" 2>/dev/null; then
      inclusive_file_clean "${bashrc}" "${PENGWIN_SHELL_INTEGRATION_MARKER}"
      echo "Windows Terminal shell integration removed successfully."
    else
      echo "... shell integration not found in ${bashrc}!"
    fi
  else
    echo "... ${bashrc} not found!"
  fi
}

if show_warning "Windows Terminal shell integration" "$@"; then
  main "$@"
fi
