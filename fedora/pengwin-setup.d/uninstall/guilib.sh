#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling base GUI libraries and modifications"

  echo "Removing dbus configuration files..."
  sudo_rem_file "/etc/dbus-1/session.conf"
  sudo_rem_file "/usr/share/dbus-1/session.conf"
  sudo_rem_file "/etc/profile.d/dbus.sh"

  remove_package xclip gnome-themes-standard gtk2-engines-murrine dbus dbus-x11 mesa-utils libqt5core5a binutils libnss3 libegl1-mesa
}

if show_warning "base GUI libraries and modifications" "$@"; then
  main "$@"
fi
