#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

wslconf_rgx='^[^#]*systemd.*=.*true$'

function main() {

  echo "Disabling SystemD"

  echo "Cleaning changes from /etc/wsl.conf"
  sudo_clean_file "/etc/wsl.conf" "${wslconf_rgx}"

  enable_should_restart
}

if show_warning "SystemD support" "$@"; then
  main "$@"
fi
