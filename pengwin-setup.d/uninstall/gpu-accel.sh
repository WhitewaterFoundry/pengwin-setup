#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling GPU acceleration settings"
  sudo_rem_file "/etc/profile.d/disable-gpu-accel.sh"
  sudo_rem_file "${__fish_sysconf_dir:=/etc/fish/conf.d}/disable-gpu-accel.fish"

}

if show_warning "GPU acceleration settings" "$@"; then
  main "$@"
fi
