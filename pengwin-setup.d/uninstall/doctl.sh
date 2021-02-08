#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling Digital Ocean CTL"

  sudo_rem_file "/usr/local/bin/doctl"

  echo "Removing bash completion..."
  sudo_rem_file "/etc/bash_completion.d/doc.bash_completion"

}

if show_warning "Digital Ocean CTL" "$@"; then
  main "$@"
fi
