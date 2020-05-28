#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling Keychain and profile modifications"

  echo "Removing profile modification..."
  sudo_rem_file "/etc/profile.d/keychain.sh"

  remove_package "keychain"

}

if show_warning "Keychain" "$@"; then
  main "$@"
fi
