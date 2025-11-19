#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#######################################
# Enable passwordless sudo for the sudo group
# Configures sudoers.d to allow sudo group members to use sudo without password
# Similar to AWS VM configurations
# Arguments:
#   None
# Returns:
#   0 on success, 1 if user cancelled
#######################################
function main() {

  if (confirm --title "Passwordless sudo" --yesno "Would you like to enable passwordless sudo?\n\nThis will allow members of the sudo group to use sudo without entering a password.\n\nNote: This is similar to how AWS VMs are configured." 11 75); then
    echo "Enabling passwordless sudo..."

    # Check if WSL-Hello-sudo is installed and remove it
    if [[ -f /lib/x86_64-linux-gnu/security/pam_wsl_hello.so ]] || [[ -f /usr/local/lib/pam_wsl_hello.so ]]; then
      if (confirm --title "WSL-Hello-sudo detected" --yesno "WSL-Hello-sudo is currently installed and is incompatible with passwordless sudo.\n\nWould you like to remove WSL-Hello-sudo?" 10 75); then
        echo "Removing WSL-Hello-sudo..."
        bash "$(dirname "$0")/uninstall/wsl-hello-sudo.sh" --skip-warning
      else
        echo "Cannot enable passwordless sudo while WSL-Hello-sudo is installed"
        return 1
      fi
    fi

    # Create sudoers.d file for passwordless sudo
    local sudoers_file="/etc/sudoers.d/passwordless-sudo"
    echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL" | sudo EDITOR='tee' visudo --quiet --file="${sudoers_file}"

    echo ""
    echo "Passwordless sudo has been enabled successfully!"
    echo "Members of the sudo group can now use sudo without a password."
    echo ""

    message --title "Passwordless sudo" --msgbox "Passwordless sudo has been enabled successfully!\n\nMembers of the sudo group can now use sudo without a password." 9 70

    return 0
  else
    echo "Skipping passwordless sudo"
    return 1
  fi
}

main "$@"
