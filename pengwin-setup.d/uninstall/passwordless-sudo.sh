#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

#######################################
# Uninstall passwordless sudo
# Removes the sudoers.d configuration for passwordless sudo
# Arguments:
#   None
# Returns:
#   None
#######################################
function main() {

  echo "Uninstalling passwordless sudo"

  # Remove sudoers.d file
  echo "Removing sudoers configuration..."
  sudo_rem_file "/etc/sudoers.d/passwordless-sudo"

  echo "Passwordless sudo has been disabled."
  echo "You will now need to enter your password when using sudo."
}

if show_warning "Passwordless sudo" "$@"; then
  main "$@"
fi
