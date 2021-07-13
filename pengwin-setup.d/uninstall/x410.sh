#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {
  echo "Removing PATH modifier..."
  sudo_rem_file "/etc/profile.d/02-x410.sh"
  sudo_rem_file "${__fish_sysconf_dir:=/etc/fish/conf.d}/02-x410.fish"
}

if show_warning "x410" "$@"; then
  main "$@"
fi
