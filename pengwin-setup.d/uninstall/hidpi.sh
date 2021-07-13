#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling Qt and GTK HiDPI modifications"
  sudo_rem_file "/etc/profile.d/hidpi.sh"
  sudo_rem_file "${__fish_sysconf_dir:=/etc/fish/conf.d}/hidpi.fish"

}

if show_warning "HiDPI modifications" "$@"; then
  main "$@"
fi
