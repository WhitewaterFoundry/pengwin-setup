#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling OpenStack CLI"

  sudo_pip_uninstall "2" "python-openstackclient" "openstacksdk"

  echo "Removing bash completion..."
  sudo_rem_file "/etc/bash_completion.d/osc.bash_completion"

}

if show_warning "OpenStack CLI" "$@"; then
  main "$@"
fi
