#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {
  echo "Uninstalling Microsoft Edit"
  sudo_rem_file "/usr/local/bin/edit"
  sudo update-alternatives --remove editor /usr/local/bin/edit || true
}

if show_warning "Microsoft Edit" "$@"; then
  main "$@"
fi
