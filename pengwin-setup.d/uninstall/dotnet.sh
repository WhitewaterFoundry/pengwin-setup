#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling dotnet"

  remove_package "dotnet-sdk-3.1" "nuget"

  echo "Removing leftover dotnet cli tools directory..."
  rem_dir "$HOME/.dotnet"

  echo "Removing dotnet cli tools PATH modification..."
  sudo_rem_file "/etc/profile.d/dotnet-cli-tools-bin-path.sh"

  echo "Removing APT source(s)..."
  safe_rem_microsoftsrc
  safe_rem_debianstablesrc

  echo "Removing APT key..."
  safe_rem_microsoftgpg

}

if show_warning "dotnet" "$@"; then
  main "$@"
fi
