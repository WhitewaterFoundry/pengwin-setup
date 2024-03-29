#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstall Azure command line tools"

  # Remove packages
  remove_package "azure-cli" "jq"

  echo "Removing bash completion..."
  sudo_rem_file "/etc/bash_completion.d/azure-cli"

  echo "Removing APT source..."
  sudo_rem_file "/etc/apt/sources.list.d/azurecli.list"

  echo "Removing APT key..."
  safe_rem_microsoftgpg

  echo "Restoring wslview as the default browser"
  wslview -r
}

if show_warning "Azure CLI" "$@"; then
  main "$@"
fi
