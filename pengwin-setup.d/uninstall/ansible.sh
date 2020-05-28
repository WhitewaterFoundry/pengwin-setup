#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling Ansible"

  remove_package "ansible"

  rem_dir "${HOME}/.ansible"
}

if show_warning "ansible" "$@"; then
  main "$@"
fi
