#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Disabling systemd"

  install_packages crudini

  # Use crudini to set systemd to false in the wsl.conf file
  echo "Setting systemd to false in /etc/wsl.conf"
  sudo crudini --set /etc/wsl.conf boot systemd false

  enable_should_restart
}

if show_warning "systemd support" "$@"; then
  main "$@"
fi
