#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling WezTerm"

  # Remove Linux installation
  if dpkg-query -s wezterm &>/dev/null; then
    echo "Removing WezTerm Linux package..."
    remove_package wezterm
  fi

  # Remove APT repository and GPG key
  sudo_rem_file "/etc/apt/sources.list.d/wezterm.list"
  sudo_rem_file "/usr/share/keyrings/wezterm-fury.gpg"

  echo "WezTerm uninstallation complete."
  echo ""
  echo "Note: If you installed WezTerm for Windows, please uninstall it"
  echo "through Windows Settings > Apps > Installed Apps."

}

if show_warning "WezTerm" "$@"; then
  main "$@"
fi
